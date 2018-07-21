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
	              TASKS FOR TESTING.

	              Example of declaration:

	              `include "apb_defines.svh"
	              `define PREADY_USED // optional, if your slave drives pready signal
	              `APB_MST(*pclk connection*)

	              Thereafter you can use task in your testbench:

	              initial begin
	                 apb_write('h04,32'hBABA_EDAC,1);
	                 apb_read('h04,1);
	              end

*/

`define APB_MST(pclk_src) \
\
logic        pclk   ;\
\
logic [31:0] paddr  ;\
logic        psel   ;\
logic        penable;\
logic        pwrite ;\
logic [31:0] pwdata ;\
logic [31:0] prdata ;\
logic        pready ;\
\
`ifndef PREADY_USED\
	assign pready = 1;\
`endif\
\
assign pclk = ``pclk_src;\
\
/* basic task */\
task apb_trans([31:0] addr=0, bit write=0, [31:0] data=0, int delay=0, bit display=1);\
	\
	if(delay != 0) repeat(delay) @(posedge pclk); \
\
	psel   <= 1; \
	paddr  <= addr;\
	pwrite <= write;\
	if(write) pwdata <= data;\
\
	@(posedge pclk) penable <= 1; \
	\
	do @(posedge pclk); while(!pready);\
	{psel, penable} <= '0; \
	\
	if(display) begin\
		if(write) $display("%t : %9s : APB write transaction ADR = %0d, WDATA = %8h",$time, "APB MST", addr, data  );\
		else      $display("%t : %9s : APB  read transaction ADR = %0d, RDATA = %8h",$time, "APB MST", addr, prdata);\
	end\
endtask\
\
/* task with randomized delay */\
task apb_trans_delayed([31:0] addr=0, bit write=0, [31:0] data='x, bit display=1, int delay_max=20);\
\
	int delay; \
	\
	case({$random}%10) \
		0       : delay = {$random} % (delay_max-3) + 3;\
		1,2     : delay = 2;\
		3,4,5   : delay = 1;\
		default : delay = 0;\
	endcase     \
\
	apb_trans(addr, write, data, delay, display);\
\
endtask\
\
/* convinient tasks */\
task apb_write ([31:0] addr, data, bit display=0);\
	apb_trans_delayed(addr,1,data,display,);\
endtask\
\
task apb_read ([31:0] addr, bit display=0);\
	apb_trans_delayed(addr,,,display,);\
endtask