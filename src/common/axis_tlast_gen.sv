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
	              AXI-Stream TLAST signal generator. TLAST is generated in the end 
	              of each packet. Packet size can be set by PACK_SIZE parameter.
*/
module axis_tlast_gen
	import axis_pkg::*;
	#(
	PACK_SIZE = 8192,
	BUS_NUM  = 2     
) (
	input                     clk                ,
	input                     rst_n              ,
	input                     en                 , // enable for module operation
	// AXIS input
	input                     in_tvalid          ,
	output logic              in_tready          ,
	input  sample_t           in_tdata  [BUS_NUM],
	// AXIS output
	output logic              out_tvalid         ,
	input                     out_tready         ,
	output logic              out_tlast          ,
	output sample_t           out_tdata [BUS_NUM]
);

	localparam CNTR_SIZE = $clog2(PACK_SIZE-1);

	logic [CNTR_SIZE-1:0] cntr;


	always_ff @(posedge clk or negedge rst_n) begin : proc_cntr
		if(~rst_n) begin
			cntr <= PACK_SIZE-1;
		end else if(en & in_tvalid & in_tready) begin
			cntr <= (cntr == 0) ? PACK_SIZE-1 : cntr-1;
		end
	end

	assign in_tready  = out_tready;
	assign out_tvalid = in_tvalid ;
	assign out_tlast  = (cntr == 0);
	always_comb begin 
		for (int i = 0; i < BUS_NUM; i++) begin
			out_tdata[i]  = in_tdata[i];
		end
	end 
endmodule
