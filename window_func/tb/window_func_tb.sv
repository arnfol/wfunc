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
`timescale 1 ns / 1 ps
module window_func_tb ();

	initial $timeformat(-9, 0, " ns", 10);

	import axis_pkg::*;

	localparam FFT_SIZE = 8192;
	localparam BUS_NUM = 2;
	localparam APB_A_REV = 1;


	logic in_tlast;
	sample_t_int in_tdata[BUS_NUM];

	logic out_tlast;
	sample_t_int out_tdata[BUS_NUM];

	/*------------------------------------------------------------------------------
	--  Clock
	------------------------------------------------------------------------------*/
	bit clk;
	bit rst_n;

	always #5 clk = ~clk;

	initial begin 
		repeat(200000) @(posedge clk);
		$display("%t : %-9s : %s", $time, "ERROR","Simulation terminated by timeout!");
		$stop;
	end

	/*------------------------------------------------------------------------------
	--  Interfaces
	------------------------------------------------------------------------------*/
	`include "apb_defines.svh"
	`APB_MST(clk)

	`include "axis_defines.svh"

	`AXIS_MST(in)
	assign in_tclk  = clk;
	
	`AXIS_SLV(out)
	assign out_tclk = clk;

	/*------------------------------------------------------------------------------
	--  Main
	------------------------------------------------------------------------------*/
	initial begin
		reset(1);
		$display("%t : %-9s : Check initial APB values", $time, "TEST 1");
		test1();

		reset(1);
		$display("%t : %-9s : Check APB reg types", $time, "TEST 2");
		test1();

		repeat(10) @(posedge clk);
		$display("%t : %-9s : Test complete.", $time, "MAIN");
		$stop;
	end

	task reset(int cycles=1);
		rst_n <= 0;
		`AXIS_MST_RST(in,<=)
		`AXIS_SLV_RST(out,<=)
		`APB_MST_RST(<=)

		repeat(cycles) @(posedge clk);
		rst_n <= 1;
	endtask : reset

	/*------------------------------------------------------------------------------
	--  Tests' tasks
	------------------------------------------------------------------------------*/
	task test1(bit verbose=0);

		// check initial values
		for(int i = 0; i < FFT_SIZE; i++) begin
			apb_read(i<<2,verbose);
			assert(prdata === 32'dx);
		end
		apb_read(FFT_SIZE<<2,verbose);
		assert(prdata == 32'd0);
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'd0);

	endtask : test1	

	task test2(bit verbose=0);
		int data;

		// check apb regs
		for(int i = 0; i < FFT_SIZE; i++) begin
			data = $urandom;

			apb_write(i<<2,data,verbose);
			apb_read(i<<2,verbose);
			assert(prdata === data);
		end

		apb_write(FFT_SIZE<<2,'hFFFF_FFFF,verbose);
		apb_read(FFT_SIZE<<2,verbose);
		assert(prdata == 32'd0);

		apb_write((FFT_SIZE+1)<<2,'hFFFF_FFFF,verbose);
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'd1);

		apb_write((FFT_SIZE+1)<<2,'hFFFF_FFFE,verbose);
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'd0);

	endtask : test2	

	/*------------------------------------------------------------------------------
	--  DUT
	------------------------------------------------------------------------------*/
	window_func #(
		.FFT_SIZE (FFT_SIZE),
		.BUS_NUM  (BUS_NUM),
		.APB_A_REV(APB_A_REV)
	) u_window_func (
		.clk       (clk       ), 
		.rst_n     (rst_n     ), 

		.in_tvalid (in_tvalid ),
		.in_tready (in_tready ),
		.in_tlast  (in_tlast  ),
		.in_tdata  (in_tdata  ),

		.out_tvalid(out_tvalid),
		.out_tready(out_tready),
		.out_tlast (out_tlast ),
		.out_tdata (out_tdata ),

		.psel      (psel      ),
		.paddr     (paddr     ),
		.penable   (penable   ),
		.pwrite    (pwrite    ),
		.pwdata    (pwdata    ),
		.prdata    (prdata    )
	);


endmodule