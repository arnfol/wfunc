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

	parameter FFT_SIZE = 128;
	parameter BUS_NUM  = 2;
	parameter APB_A_REV = 0;

	localparam WINDOW_FILE = "../window.txt";
	localparam AXIS_I_FILE = "../axis_i.txt";
	localparam AXIS_O_FILE = "../axis_o.txt";

	parameter IN_RAND = 1;
	parameter OUT_RAND = 1;

	parameter TEST_FSM = 0;

	logic in_tlast;
	sample_t_int in_tdata[BUS_NUM];

	logic out_tlast;
	sample_t out_tdata[BUS_NUM];

	int tr_rd_num;
	int tr_wr_num;

	initial begin
		$display("%-9s : FFT_SIZE=%0d, BUS_NUM=%0d, APB_A_REV=%0d ", "CONFIG", FFT_SIZE, BUS_NUM, APB_A_REV);
		$display("%-9s : IN_RAND=%0d, OUT_RAND=%0d ", "CONFIG", IN_RAND, OUT_RAND);
	end
	/*------------------------------------------------------------------------------
	--  Clock
	------------------------------------------------------------------------------*/
	bit clk;
	bit rst_n;

	always #5 clk = ~clk;

	initial begin 
		repeat(20000000) @(posedge clk);
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
		if(IN_RAND & OUT_RAND) begin // just to reduce number of the same tests in automated runs
			reset(1);
			$display("%t : %-9s : Check initial APB values", $time, "TEST 1");
			test1();

			reset(1);
			$display("%t : %-9s : Check APB reg types", $time, "TEST 2");
			test2();
		end

		reset(1);
		if(!TEST_FSM) begin
			$display("%t : %-9s : Check module work", $time, "TEST 3");
			test3();
		end else begin
			$display("%t : %-9s : Check FSM states' transitions", $time, "TEST 4");
			test4();
		end

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
		/*
			check initial values
		*/

		for(int i = 0; i < FFT_SIZE; i++) begin
			apb_read(i<<2,verbose);
			assert(prdata === 32'dx) else $fatal("Window memory (ADDR=%0h) not empty!",i<<2);
		end
		apb_read(FFT_SIZE<<2,verbose);
		assert(prdata == 32'd0) else $fatal("Register %0h not 0!",FFT_SIZE<<2);
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'd0)else $fatal("Register %0h not 0!",FFT_SIZE+1<<2);

	endtask : test1	

	task test2(bit verbose=0);
		/*
			check apb regs
		*/
		
		int data;

		for(int i = 0; i < FFT_SIZE; i++) begin
			data = $urandom;

			apb_write(i<<2,data,verbose);
			apb_read(i<<2,verbose);
			assert(prdata == data) else $fatal("Window memory (ADDR=%0h) error! %8h expected, %8h got.",i<<2,data,prdata);
		end

		apb_write(FFT_SIZE<<2,'hFFFF_FFFF,verbose);
		apb_read(FFT_SIZE<<2,verbose);
		assert(prdata == 32'd0) else $fatal("Reg %0h error! %8h expected, %8h got.",FFT_SIZE<<2,0,prdata);

		apb_write((FFT_SIZE+1)<<2,'hFFFF_FFFF,verbose);
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'd0) else $fatal("Reg %0h error! %8h expected, %8h got.",FFT_SIZE+1<<2,0,prdata);

	endtask : test2	

	task test3(bit verbose=0);
		window_init(verbose);

		// check IDLE state
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'd0) else $fatal("Reg %0h error! %8h expected, %8h got.",FFT_SIZE+1<<2,0,prdata);

		// start operation
		apb_write(FFT_SIZE<<2,'h0000_0100);

		// check WAIT state
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'h0000_0100) else $fatal("Reg %0h error! %8h expected, %8h got.",FFT_SIZE+1<<2,32'h0000_0100,prdata);

		// run data stream
		fork
			read_axis();
			write_axis();
			for (int i = 0; i < 20; i++) begin
				apb_read((FFT_SIZE+1)<<2,verbose);
				if(prdata == 32'h0000_0200) begin
					$display("%t : %-9s : BUSY state check - OK.", $time, "DEBUG");
					break;
				end
				assert(i != 19) else $fatal("FSM does not move to BUSY state.");
			end
		join_any
		do @(posedge clk); while(tr_wr_num != tr_rd_num);
	endtask : test3

	task test4(bit verbose=0);
		window_init(verbose);

		// check IDLE state
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'd0) else $fatal("Reg %0h error! %8h expected, %8h got.",FFT_SIZE+1<<2,0,prdata);

		// start operation
		apb_write(FFT_SIZE<<2,'h0000_0100);

		// check WAIT state
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'h0000_0100) else $fatal("Reg %0h error! %8h expected, %8h got.",FFT_SIZE+1<<2,32'h0000_0100,prdata);

		// run data stream
		fork
			write_axis();
		join_none

		// check BUSY
		fork
			read_axis_packet();
			for (int i = 0; i < 20; i++) begin
				apb_read((FFT_SIZE+1)<<2,verbose);
				if(prdata == 32'h0000_0200) begin
					$display("%t : %-9s : BUSY state check - OK.", $time, "DEBUG");
					break;
				end
				assert(i != 19) else $fatal("FSM does not move to BUSY state.");
			end
		join

		// check change_state in BUSY
		fork
			read_axis_packet();
			for (int i = 0; i < 20; i++) begin
				apb_read((FFT_SIZE+1)<<2,verbose);
				if(prdata == 32'h0000_0200) begin
					apb_write(FFT_SIZE<<2,'h0000_0100);
					break;
				end
				assert(i != 19) else $fatal("FSM does not move to BUSY state.");
			end
		join
		repeat(10) @(posedge clk);
		apb_read((FFT_SIZE+1)<<2,verbose);
		assert(prdata == 32'h0000_0000) $display("%t : %-9s : BUSY to IDLE through WAIT - OK.", $time, "DEBUG");
			else $fatal("Reg %0h error! %8h expected, %8h got.",FFT_SIZE+1<<2,32'h0000_0000,prdata);

		repeat(50) @(posedge clk); 
	endtask : test4

	/*------------------------------------------------------------------------------
	--  Common tasks
	------------------------------------------------------------------------------*/
	task window_init(bit verbose=0);
		int mem[FFT_SIZE];

		$readmemh(WINDOW_FILE,mem);

		for (int i = 0; i < FFT_SIZE; i++) begin
			apb_write(i<<2,mem[i],verbose);
		end
	endtask : window_init

	task read_axis();
		/* 
		Reads input from file and runs AXIS transactions.
		File format: <tlast(1b)>_<tdata(hex with "_")>
		Example:    0_f12dc8ca_1d337a3e
		            0_459a4094_067b682d
		            0_c7c57277_6063554d
		            0_faf037fb_a7e5f604
		            1_bc4c0c39_45bfc902
		*/
		int rfile;
		bit last;
		logic [BUS_NUM-1:0][31:0] data;
		axis_t dump;

		rfile = $fopen(AXIS_I_FILE,"r");
		while(!$feof(rfile)) begin 
			tr_rd_num++;
			$fscanf(rfile,"%1b_%h\n",last,data);
			// $display("%t : %-9s : data: %h", $time, "DEBUG", data);
			// $display("%t : %-9s : last: %b", $time, "DEBUG", last);
			foreach(data[i]) begin
				// $display("%t : %-9s : data[%2d]: %h", $time, "DEBUG", i, data[i]);
				in_tdata[BUS_NUM-1-i].re <= data[i][15:0];
				in_tdata[BUS_NUM-1-i].im <= data[i][31:16];
			end
			in_tlast <= last;
			if(IN_RAND)	in_cyc_wait($urandom_range(10));
			in_send(dump);
		end
		$fclose(rfile);
	endtask : read_axis

	task read_axis_packet(string file=AXIS_I_FILE);
		/* 
		Reads one axis packet from file and runs AXIS transactions.
		File format: <tlast(1b)>_<tdata(hex with "_")>
		Example:    0_f12dc8ca_1d337a3e
		            0_459a4094_067b682d
		            0_c7c57277_6063554d
		            0_faf037fb_a7e5f604
		            1_bc4c0c39_45bfc902
		*/
		
		bit last;
		int rfile;
		logic [BUS_NUM-1:0][31:0] data;
		axis_t dump;

		last = 0;
		rfile = $fopen(file,"r");

		// if not first call, jump over packets which are already read
		if(tr_rd_num > 0) begin 
			for (int i = 0; i < tr_rd_num; i++) begin
				$fscanf(rfile,"%1b_%h\n",last,data);
			end
		end

		// read transactions and run axis
		do begin 
			tr_rd_num++;
			$fscanf(rfile,"%1b_%h\n",last,data);
			// $display("%t : %-9s : data: %h", $time, "DEBUG", data);
			// $display("%t : %-9s : last: %b", $time, "DEBUG", last);
			foreach(data[i]) begin
				// $display("%t : %-9s : data[%2d]: %h", $time, "DEBUG", i, data[i]);
				in_tdata[BUS_NUM-1-i].re <= data[i][15:0];
				in_tdata[BUS_NUM-1-i].im <= data[i][31:16];
			end
			if(IN_RAND)	in_cyc_wait($urandom_range(10));
			in_send(dump);
		end while(last != 1 & !$feof(rfile));

		$fclose(rfile);

	endtask : read_axis_packet

	task write_axis();
		int wfile;
		int cyc_wait;
		logic [BUS_NUM-1:0][63:0] data;

		wfile = $fopen(AXIS_O_FILE,"w");

		fork
			forever begin 
				cyc_wait = (OUT_RAND) ? $urandom_range(10) : 0;
				out_get(cyc_wait,1);
			end
		join_none

		forever @(posedge clk) begin 
			if(out_tvalid & out_tready) begin 
				tr_wr_num++;
				foreach(data[i]) begin
					data[i] = {out_tdata[BUS_NUM-1-i].im,out_tdata[BUS_NUM-1-i].re};
				end
				$fdisplay(wfile,"%b_%h",out_tlast,data);
			end
		end
	endtask : write_axis

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