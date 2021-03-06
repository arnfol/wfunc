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

## [FFT_SIZE*4] : Control register ##

| BITS       | ACCESS  | RST VALUE  | DESCRIPTION                                        |
|------------|---------|------------|----------------------------------------------------|
| 31-9       |  RO     |  x000000   | Unused                                             |
| 8          |  RW     |  -         | Writing 1 executes command "CHANGE STATE"          |
| 7-1        |  RO     |  x00       | Unused                                             |
| 0          |  WO     |  -         | FSM reset. Writing 1 puts FSM into IDLE state      |

**Note:** In states IDLE or WAIT command "CHANGE STATE" immediately forces FSM to move to 
the next state. In this case corresponding bit (bit 8) in Control register is deasserted
on the next clock edge after it was asserted. However, in BUSY state this bit stores its
value waiting for FSM to move to another state.

## [(FFT_SIZE+1)*4] : Status register ##

| BITS       | ACCESS  | RST VALUE  | DESCRIPTION                                        |
|------------|---------|------------|----------------------------------------------------|
| 31-10      |  RO     |  x000000   | Unused                                             |
| 9-8        |  RO     |  x0        | FSM state. IDLE=x0, WAIT=x1, BUSY=x2.              |
| 7-0        |  RO     |  x00       | Unused                                             |

# FSM #
## State diagram ##

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
x0000-[(FFT_SIZE-1)*4]). After reception of TLAST FSM goes  to WAIT state (5).
				  
*/
module window_func #(
	FFT_SIZE     = 8192                        , // should be power of 2
	BUS_NUM      = 2                           , // should be >= 2
	APB_A_REV    = 0                           , // either do bit revert on APB address (1) or not (0)
	ADD_PIPE_NUM = 7                           , // either do bit revert on APB address (1) or not (0)
	APB_AW       = $clog2(FFT_SIZE-1)+2+1        // do not change it
) (
	input                                 clk       ,
	input                                 rst_n     ,
	// AXIS input
	input                                 in_tvalid ,
	output logic                          in_tready ,
	input        [BUS_NUM-1:0][1:0][15:0] in_tdata  , // in each bus 1 - Im, 0 - Re
	// AXIS output
	output logic                          out_tvalid,
	input                                 out_tready,
	output logic                          out_tlast ,
	output logic [BUS_NUM-1:0][1:0][31:0] out_tdata , // in each bus 1 - Im, 0 - Re
	// APB bus
	input                                 psel      ,
	input        [ APB_AW-1:0]            paddr     ,
	input                                 penable   ,
	input                                 pwrite    ,
	input        [       31:0]            pwdata    ,
	output logic [       31:0]            prdata
);

	import complex_pkg::*;
	
	localparam MEM_AW = $clog2((FFT_SIZE/BUS_NUM)-1);
	localparam MATH_DELAY = 3 + ADD_PIPE_NUM;

	// function returns bit-reverse vector
	function logic [APB_AW-2:2] bit_rev(logic [APB_AW-2:2] in);
		logic [APB_AW-2:2] out;

		for (int i = 2; i < APB_AW-1; i++) begin
			out[i] = in[APB_AW-i];
		end
		// out = out ^ ~(1<<APB_AW-3); // invert all bits except the MSB
		return out;
	endfunction : bit_rev


	enum logic [1:0] {IDLE = 2'b00,
					  WAIT = 2'b01,
					  BUSY = 2'b10} state, nxt_state;

	logic [MEM_AW-1:0] sample_cntr;

	logic [         APB_AW-2:2] fsm_addr;
	logic [$clog2(BUS_NUM)-1:0] fsm_cs  ;

	logic [MEM_AW-1:0]        mem_addr ;
	logic                     mem_write;
	logic [BUS_NUM-1:0][31:0] mem_wdata;
	logic [BUS_NUM-1:0][31:0] mem_rdata;
	logic [BUS_NUM-1:0]       mem_cs   ;

	logic [MATH_DELAY-1:0] tvalid_pipe ;
	logic [MATH_DELAY-1:0] tlast_pipe  ;
	logic                  data_line_en;


	localparam REGS_NUM = 2;
	localparam [REGS_NUM-1:0][31:0] regs_rst = {32'd0,32'd0};
	// logic [REGS_NUM-1:0][31:0] wr_regs;
	logic [REGS_NUM-1:0][31:0] rd_regs;

	logic [APB_AW-4:0] reg_addr ;
	logic              reg_write;
	logic [      31:0] reg_wdata;
	logic [      31:0] reg_rdata;
	logic              reg_en   ;

	logic soft_rst;
	logic change_state;

	logic     in_tlast_pipe           ;
	logic     in_tlast_pipe_          ;
	logic     in_hshake_pipe          ;
	logic     in_hshake_pipe_         ;
	logic     in_hshake               ;
	complex32 in_tdata_pipe  [BUS_NUM];
	complex32 in_tdata_pipe_ [BUS_NUM];

	logic     tvalid_save              ;
	logic     tlast_save               ;
	logic     save_trans               ;
	logic     data_line_en_del         ;
	complex64 z               [BUS_NUM];
	complex64 z_del           [BUS_NUM];

	logic [$clog2(FFT_SIZE/BUS_NUM)-1:0] in_tlast_cntr;


	/*------------------------------------------------------------------------------
	--  FSM
	------------------------------------------------------------------------------*/
	assign fsm_addr = (APB_A_REV) ? bit_rev(paddr[APB_AW-2:2]) : paddr[APB_AW-2:2];
	assign fsm_cs   = (APB_A_REV) ? bit_rev(paddr[APB_AW-2:2]) : paddr[APB_AW-2:2]; // automatically truncated

	always_ff @(posedge clk or negedge rst_n) begin : proc_prdata
		if(~rst_n) begin
			prdata <= '0;
		end else begin
			prdata <= (paddr[APB_AW-1]) ? reg_rdata : mem_rdata[fsm_addr[$clog2(BUS_NUM)+1:2]];
		end
	end
	
	always_comb begin : proc_fsm
		mem_write = '0;
		mem_wdata = '0;
		mem_addr = '0;
		mem_cs = '0;
		in_tready = 0;
		nxt_state = IDLE;

		case (state)
			IDLE : begin // APB access
				for (int i = 0; i < BUS_NUM; i++) begin
					mem_wdata[i] = pwdata;
				end
				mem_write = pwrite;
				mem_addr  = fsm_addr >> $clog2(BUS_NUM);
				mem_cs[fsm_cs] = (!paddr[APB_AW-1]) ? psel & !penable : '0;

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

				nxt_state = (data_line_en_del & in_hshake_pipe & in_tlast_pipe) ? WAIT : BUSY;
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
	--  MEM for window
	------------------------------------------------------------------------------*/
	genvar i;
	generate for (i = 0; i < BUS_NUM; i++) begin : mem_gen
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
	--  INPUT STAGE for memory delay compensation
	------------------------------------------------------------------------------*/

	assign in_hshake = in_tvalid & in_tready;

	always_ff @(posedge clk or negedge rst_n) begin : proc_in_stage1_hshake
		if(~rst_n) begin
			in_hshake_pipe_ <= 0;
		end else if(data_line_en) begin
			in_hshake_pipe_ <= in_hshake;
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_in_stage1
		if(~rst_n) begin
			sample_cntr    <= '1;
			in_tlast_cntr  <= '1;
			in_tlast_pipe_ <= 0;
			for (int i = 0; i < BUS_NUM; i++) begin
				in_tdata_pipe_[i] <= '{0,0};
			end
		end else if(in_hshake) begin
			sample_cntr    <= sample_cntr+1; // counter for memory access
			in_tlast_cntr  <= in_tlast_cntr-1; // counter for input tlast generation
			in_tlast_pipe_ <= (in_tlast_cntr == 0);
			for (int i = 0; i < BUS_NUM; i++) begin
				in_tdata_pipe_[i].re <= in_tdata[i][RE];
				in_tdata_pipe_[i].im <= in_tdata[i][IM];
			end
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_in_stage2
		if(~rst_n) begin
			in_hshake_pipe <= 0;
			in_tlast_pipe  <= 0;
			for (int i = 0; i < BUS_NUM; i++) begin
				in_tdata_pipe[i] <= '{0,0};
			end
		end else begin
			in_hshake_pipe <= in_hshake_pipe_;
			in_tlast_pipe  <= in_tlast_pipe_;
			for (int i = 0; i < BUS_NUM; i++) begin
				in_tdata_pipe[i] <= in_tdata_pipe_[i];
			end
		end
	end


	/*------------------------------------------------------------------------------
	--  MATH DATA LINE
	------------------------------------------------------------------------------*/

	assign data_line_en = out_tready | !out_tvalid;

	always_ff @(posedge clk or negedge rst_n) begin : proc_data_line_del
		if(~rst_n) begin
			data_line_en_del <= 0;
		end else begin
			data_line_en_del <= data_line_en;
		end
	end

	// pipeline for math delay compensation
	always_ff @(posedge clk or negedge rst_n) begin : proc_tvalid_pipe
		if(~rst_n) begin
			tvalid_pipe <= '0;
			tlast_pipe  <= '0;
		end else if(data_line_en_del) begin
			tvalid_pipe <= {tvalid_pipe[MATH_DELAY-2:0],in_hshake_pipe};
			tlast_pipe  <= {tlast_pipe[MATH_DELAY-2:0],in_tlast_pipe};
		end
	end

	// math
	generate for (i = 0; i < BUS_NUM; i++) begin : mult_gen
				
		complex32 a;
		complex32 b;

		assign a = in_tdata_pipe[i];
		assign b.re = mem_rdata[i][15:0];
		assign b.im = mem_rdata[i][31:16];

		complex_int_mult #(.PIPE_NUM(MATH_DELAY), .DISPLNUM(i)) u_complex_int_mult (
			.clk  (clk             ),
			.rst_n(rst_n           ),
			.en   (data_line_en_del),
			.a    (a               ),
			.b    (b               ),
			.z    (z[i]            )
		);

	end endgenerate

	assign save_trans = !out_tready & data_line_en_del & tvalid_pipe[MATH_DELAY-1];

	// additional register to save pushed out transaction
	always_ff @(posedge clk or negedge rst_n) begin : proc_save_trans
		if(~rst_n) begin
			tvalid_save <= 0;
			tlast_save  <= 0;
			for (int i = 0; i < BUS_NUM; i++) begin
				z_del[i] <= '{0,0};
			end
		end else if(!tvalid_save | in_tready) begin
			tvalid_save <= (save_trans) ? tvalid_pipe[MATH_DELAY-1] : 0;
			tlast_save  <= (save_trans) ? tlast_pipe[MATH_DELAY-1] : 0;
			for (int i = 0; i < BUS_NUM; i++) begin
				z_del[i] <= (save_trans) ? z[i] : {32'd0,32'd0};
			end
		end
	end

	// output mux
	always_comb begin : proc_out_mux
		out_tvalid = (tvalid_save) ? tvalid_save : tvalid_pipe[MATH_DELAY-1];
		out_tlast  = (tvalid_save) ? tlast_save  : tlast_pipe[MATH_DELAY-1];
		for (int i = 0; i < BUS_NUM; i++) begin
			out_tdata[i][RE] = (tvalid_save) ? z_del[i].re : z[i].re;
			out_tdata[i][IM] = (tvalid_save) ? z_del[i].im : z[i].im;
		end
	end

	/*------------------------------------------------------------------------------
	--  APB CONTROL REGS
	------------------------------------------------------------------------------*/
	assign reg_addr  = paddr[APB_AW-2:2];
	assign reg_write = pwrite;
	assign reg_wdata = pwdata;
	assign reg_rdata = rd_regs[reg_addr];
	assign reg_en    = psel & !penable & paddr[APB_AW-1];

	always_comb begin 
		rd_regs = regs_rst;

		rd_regs[0][8] = change_state;
		rd_regs[1][9:8] = state;
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_change_state
		if(~rst_n) begin
			change_state <= 0;
			soft_rst <= 0;
		end else begin
			change_state <= (state == IDLE | state == WAIT) ? 0 : change_state;
			soft_rst <= 0;
			if(reg_en & reg_write & reg_addr==0) begin
				change_state <= reg_wdata[8];
				soft_rst <= reg_wdata[0];
			end
		end
	end

endmodule