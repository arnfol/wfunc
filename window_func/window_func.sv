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
	              
	              
	              
*/
module window_func
	import axis_pkg::*;
	#(
	FFT_SIZE  = 8192                      , // should be power of 2
	BUS_NUM   = 2                         , // should be >= 2
	APB_A_REV = 1                         , // either do bit revert on APB address (1) or not (0)
	MEM_AW    = $clog2(FFT_SIZE/BUS_NUM-1),
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
	output sample_t_int       out_tdata [BUS_NUM],
	// APB bus
	input                     psel               ,
	input        [APB_AW-1:0] paddr              ,
	input                     penable            ,
	input                     pwrite             ,
	input        [      31:0] pwdata             ,
	output logic [      31:0] prdata
);

	function logic [APB_AW-1:0] bit_rev(logic [APB_AW-1:0] in);
		logic [APB_AW-1:0] out;

		for (int i = 0; i < APB_AW; i++) begin
			out[i] = in[APW-i];
		end

		return out;
	endfunction : bit_rev

	localparam MATH_DELAY = 10;

	enum logic [1:0] {IDLE = 2'b00,
	                  WAIT = 2'b01,
	                  BUSY = 2'b10} state, nxt_state;

	logic [MEM_AW-1:0] sample_cntr;

	logic [APB_AW-2:2] fsm_addr;

	logic [MEM_AW-1:0]    mem_addr ;
	logic                 mem_write;
	logic [BUS_NUM][31:0] mem_wdata;
	logic [BUS_NUM][31:0] mem_rdata;
	logic [BUS_NUM]       mem_cs   ;

	logic [MATH_DELAY:0] tvalid_pipe;
	logic                data_line_en;


	/*------------------------------------------------------------------------------
	--  MEM
	------------------------------------------------------------------------------*/
	generate for (int i = 0; i < BUS_NUM; i++) begin
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
	assign fsm_addr = (APB_A_REV) ? bit_rev(paddr[APB_AW-2:2]) : paddr[APB_AW-2:2];

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
				mem_addr  = fsm_addr[MEM_AW-1:0];
				mem_cs[fsm_addr[APB_AW-1:MEM_AW]]   = psel & !penable;

				if(!paddr[APB_AW-1]) prdata = mem_rdata[fsm_addr[APB_AW-1:MEM_AW]];

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
	generate for (int i = 0; i < BUS_NUM; i++) begin
				
		sample_t_int a;
		sample_t_int b;

		assign b.re = mem_rdata[i][15:0];
		assign b.im = mem_rdata[i][32:16];

		// additional delay to compensate memory delay
		always_ff @(posedge clk or negedge rst_n) begin : proc_add_delay
			if(~rst_n) begin
				a <= '{0,0};
			end else if(data_line_en) begin
				a <= in_tdata[i];
			end
		end

		complex_int_mult #(.PIPE_NUM(MATH_DELAY)) u_complex_int_mult (
			.clk  (clk         ),
			.rst_n(rst_n       ),
			.en   (data_line_en),
			.a    (a           ),
			.b    (b           ),
			.z    (out_tdata[i])
		);

	end endgenerate

	/*------------------------------------------------------------------------------
	--  APB CONTROL REGS
	------------------------------------------------------------------------------*/
	localparam REGS_NUM = 2;
	localparam [REGS_NUM-1:0][31:0] regs_rst = {32'd0,32'd0};

	logic [REGS_NUM-1:0][31:0] wr_regs, wr_regs_del, rd_regs;

	logic [APB_AW-4:0] reg_addr ;
	logic              reg_write;
	logic [      31:0] reg_wdata;
	logic [      31:0] reg_rdata;
	logic              reg_en   ;

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

	assign soft_rst     <= (wr_regs[0][0] ^ wr_regs_del[0][0]) ? 1 : 0;
	assign change_state <= (wr_regs[0][8] ^ wr_regs_del[0][8]) ? 1 : 0;

endmodule