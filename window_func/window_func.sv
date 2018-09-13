/*
------------------------------------------------------------------------------
-- The MIT License (MIT)
--
-- Copyright (c) <2018> Konovalov Vitaliy
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-------------------------------------------------------------------------------

Project     : FFT_CORE
Author      : Konovalov Vitaliy 
Description : 
					
Description below is in a markdown format, so you can use an editor to get a pretty view.
To make this document we used TYPORA.

# APB registers map #

Registers are given in a following format: 
## <ADDRESS> : <REG NAME> ##
<DESCRIPTION>

Each register is aligned to 32-bit word bounds, which means 2 least significant bits 
of paddr bus should always be zeros.

## x0000 - [(FFT_SIZE-1)*4] : Window values ##

| BITS       | ACCESS  | RST VALUE  | DESCRIPTION                     |
|------------|---------|------------|---------------------------------|
| 31-16      |  RW     |  xXXXX     | Imaginary part of window sample |
| 15-0       |  RW     |  xXXXX     | Real part of window sample      |

**Note:** If parameter APB_A_REV=1, address of these registers is bit-reverted.
For instance, if FFT_SIZE=8192 and you are writing to address x0004, you will 
access x4000 instead. This was done to simplify work with reverted-order 
packets after FFT.

## [FFT_SIZE*4] : Control register 1 ##

| BITS       | ACCESS  | RST VALUE  | DESCRIPTION                                        |
|------------|---------|------------|----------------------------------------------------|
| 31-9       |  RO     |  x000000   | Unused                                             |
| 8          |  WO     |  -         | Writing 1 executes command "CHANGE STATE"          |
| 7-1        |  RO     |  x00       | Unused                                             |
| 0          |  WO     |  -         | FSM reset. Writing 1 puts FSM into IDLE state      |

## [(FFT_SIZE+1)*4] : Status & Control register 2 ##

| BITS       | ACCESS  | RST VALUE  | DESCRIPTION                                        |
|------------|---------|------------|----------------------------------------------------|
| 31-10      |  RO     |  x000000   | Unused                                             |
| 9-8        |  RO     |  x0        | FSM state. IDLE=x0, WAIT=x1, BUSY=x2.              |
| 7-1        |  RO     |  x00       | Unused                                             |
| 0          |  RW     |  x0        | 1 enables FSM one-packet mode.                     |

**Note:** One-packet mode force FSM moving to the IDLE state after handling one packet.
If not set, after handling a packet FSM goes to the WAIT state and waits for another packet
or command.

# FSM #
## State diagram ##

	                         -4-> IDLE
	IDLE -1-> WAIT -2-> BUSY -5-> WAIT
	               -3-> IDLE

## State description ##
**Note:** In any state write 1 to FSM reset register puts FSM into IDLE state.
### IDLE ###
In this state module does nothing. You can access and configure all registers. After
receiving "CHANGE STATE" command FSM moves to WAIT state (1).
### WAIT ###
In this state module is waiting for new packet on AXI-Stream line. You cannot access
window registers (address x0000-[(FFT_SIZE-1)*4]) in this state. Reception of a new 
AXIS packet moves FSM to BUSY state (2), otherwise "CHANGE STATE" command moves FSM 
to IDLE (3).
### BUSY ###
In BUSY state module handles packet. You also cannot access window registers (address 
x0000-[(FFT_SIZE-1)*4]). After reception of TLAST FSM goes either to the IDLE state (4),
if one-packet mode is enabled, or to WAIT state (5), otherwise.
	              
*/
module window_func
	import axis_pkg::*;
	#(
	FFT_SIZE  = 8192                      , // should be power of 2
	BUS_NUM   = 2                         , // should be >= 2
	APB_A_REV = 1                         , // either do bit revert on APB address (1) or not (0)
	MEM_AW    = $clog2((FFT_SIZE/BUS_NUM)-1),
	APB_AW    = $clog2(FFT_SIZE-1)+2+1      // +2 for LSB in addr for potential byte access, +1 for control regs
) (
	input                     clk                ,
	input                     rst_n              ,
	// AXIS input
	input                     in_tvalid          ,
	output logic              in_tready          ,
	input                     in_tlast           ,
	input  sample_t_int       in_tdata  [BUS_NUM],
	// AXIS output
	output logic              out_tvalid         ,
	input                     out_tready         ,
	output logic              out_tlast          ,
	output sample_t           out_tdata [BUS_NUM],
	// APB bus
	input                     psel               ,
	input        [APB_AW-1:0] paddr              ,
	input                     penable            ,
	input                     pwrite             ,
	input        [      31:0] pwdata             ,
	output logic [      31:0] prdata
);

	function logic [APB_AW-2:2] bit_rev(logic [APB_AW-2:2] in);
		logic [APB_AW-2:2] out;

		for (int i = 2; i < APB_AW-1; i++) begin
			out[i] = in[APB_AW-i];
		end
		out = out ^ ~(1<<APB_AW-3); // invert all bits except the MSB
		return out;
	endfunction : bit_rev

	localparam MATH_DELAY = 10;

	enum logic [1:0] {IDLE = 2'b00,
	                  WAIT = 2'b01,
	                  BUSY = 2'b10} state, nxt_state;

	logic [MEM_AW-1:0] sample_cntr;

	logic [APB_AW-2:2]          fsm_addr;
	logic [$clog2(BUS_NUM)-1:0] fsm_cs;

	logic [MEM_AW-1:0]        mem_addr ;
	logic                     mem_write;
	logic [BUS_NUM-1:0][31:0] mem_wdata;
	logic [BUS_NUM-1:0][31:0] mem_rdata;
	logic [BUS_NUM-1:0]       mem_cs   ;

	logic [MATH_DELAY:0] tvalid_pipe;
	logic                data_line_en;

	localparam REGS_NUM = 2;
	localparam [REGS_NUM-1:0][31:0] regs_rst = {32'd0,32'd0};

	logic [REGS_NUM-1:0][31:0] wr_regs, wr_regs_del, rd_regs;

	logic [APB_AW-4:0] reg_addr ;
	logic              reg_write;
	logic [      31:0] reg_wdata;
	logic [      31:0] reg_rdata;
	logic              reg_en   ;

	logic one_pack_mode;
	logic soft_rst;
	logic change_state;

	logic [MATH_DELAY:0] tlast_delay;

	/*------------------------------------------------------------------------------
	--  MEM
	------------------------------------------------------------------------------*/
	generate for (genvar i = 0; i < BUS_NUM; i++) begin : mem_gen
		spram #(.DW(32), .AW(MEM_AW)) u_spram (
			.clk (clk           ),
			.data(mem_wdata[i]),
			.addr(mem_addr),
			.we  (mem_write),
			.cs  (mem_cs[i]),
			.q   (mem_rdata[i])
		);
	end endgenerate

	/*------------------------------------------------------------------------------
	--  FSM
	------------------------------------------------------------------------------*/
	assign fsm_addr = (APB_A_REV) ?  bit_rev(paddr[APB_AW-2:2]) : paddr[APB_AW-2:2];
	assign fsm_cs   = (APB_A_REV) ? ~bit_rev(paddr[APB_AW-2:2]) : paddr[APB_AW-2:2];

	always_comb begin : proc_fsm
		mem_write = '0;
		mem_addr  = '0;
		mem_cs    = '0;
		mem_wdata = '0;
		prdata    = reg_rdata;

		nxt_state = IDLE;

		case (state)
			IDLE : begin // APB access
				in_tready = 0;

				for (int i = 0; i < BUS_NUM; i++) begin
					mem_wdata[i] = pwdata;
				end
				mem_write = pwrite;
				mem_addr  = fsm_addr >> $clog2(BUS_NUM);
				mem_cs[fsm_cs] = (!paddr[APB_AW-1]) ? psel & !penable : '0;

				if(!paddr[APB_AW-1]) prdata = mem_rdata[fsm_addr[APB_AW-2:MEM_AW+2]];

				nxt_state = (change_state) ? WAIT : IDLE;
			end

			WAIT : begin // wait for new packet
				in_tready = data_line_en;

				mem_cs = '1;
				mem_addr = sample_cntr;

				if(in_tready & in_tvalid) nxt_state = BUSY;
				else if(change_state) nxt_state = IDLE;
				else nxt_state = WAIT;
			end

			BUSY : begin // handle the packet, no APB access to memory
				in_tready = data_line_en;

				mem_cs = '1;
				mem_addr = sample_cntr;

				if(in_tready & in_tvalid & in_tlast) begin 
					nxt_state = (one_pack_mode) ? IDLE : WAIT;
				end else begin 
					nxt_state = BUSY;
				end
			end

			default : begin 
				nxt_state = IDLE;
			end
		endcase
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_state
		if(~rst_n) begin
			state <= IDLE;
		end else if(soft_rst) begin
			state <= IDLE;
		end else begin
			state <= nxt_state;
		end
	end

	/*------------------------------------------------------------------------------
	--  DATA LINE
	------------------------------------------------------------------------------*/
	// enables
	assign data_line_en = out_tready | !out_tvalid;

	always_ff @(posedge clk or negedge rst_n) begin : proc_tvalid_pipe
		if(~rst_n) begin
			tvalid_pipe <= '0;
		end else if(data_line_en) begin
			tvalid_pipe <= {tvalid_pipe[MATH_DELAY-1:0],in_tready&in_tvalid};
		end
	end
	assign out_tvalid = tvalid_pipe[MATH_DELAY];

	// counter for memory
	always_ff @(posedge clk or negedge rst_n) begin : proc_sample_cntr
		if(~rst_n) begin
			sample_cntr <= 0;
		end else if(in_tready & in_tvalid) begin
			sample_cntr <= sample_cntr+1;
		end
	end


	// math
	generate for (genvar i = 0; i < BUS_NUM; i++) begin : mult_gen
				
		sample_t_int a;
		sample_t_int b;

		assign b.re = mem_rdata[i][15:0];
		assign b.im = mem_rdata[i][31:16];

		// additional delay to compensate memory delay
		always_ff @(posedge clk or negedge rst_n) begin : proc_add_delay
			if(~rst_n) begin
				a <= '{0,0};
			end else if(data_line_en) begin
				a <= in_tdata[i];
			end
		end

		complex_int_mult #(.PIPE_NUM(MATH_DELAY), .DISPLNUM(i)) u_complex_int_mult (
			.clk  (clk         ),
			.rst_n(rst_n       ),
			.en   (data_line_en),
			.a    (a           ),
			.b    (b           ),
			.z    (out_tdata[i])
		);

	end endgenerate


	// tlast delay line
	always_ff @(posedge clk or negedge rst_n) begin : proc_tlast_delay
		if(~rst_n) begin
			tlast_delay <= '0;
		end else if(data_line_en) begin
			tlast_delay <= {tlast_delay[MATH_DELAY-1:0],in_tlast};
		end
	end

	assign out_tlast = tlast_delay[MATH_DELAY];

	/*------------------------------------------------------------------------------
	--  APB CONTROL REGS
	------------------------------------------------------------------------------*/
	assign reg_addr  = paddr[APB_AW-2:2];
	assign reg_write = pwrite;
	assign reg_wdata = pwdata;
	assign reg_rdata = rd_regs[reg_addr];
	assign reg_en    = psel & !penable & paddr[APB_AW-1];

	always_ff @(posedge clk or negedge rst_n) begin : proc_regs
		if(~rst_n) begin
			wr_regs_del <= regs_rst;
			wr_regs     <= regs_rst;
		end else begin
			wr_regs_del <= wr_regs;
			if(reg_en & reg_write) wr_regs[reg_addr] <= reg_wdata;
		end
	end

	always_comb begin 
		rd_regs = regs_rst;

		one_pack_mode = wr_regs[1][0];
		rd_regs[1][0] = one_pack_mode;

		rd_regs[1][9:8] = state;
	end

	assign soft_rst     = (wr_regs[0][0] ^ wr_regs_del[0][0]) ? 1 : 0;
	assign change_state = (wr_regs[0][8] ^ wr_regs_del[0][8]) ? 1 : 0;

endmodule