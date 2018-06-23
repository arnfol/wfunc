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
                  TASKS FOR TESTING

*/




`define AXIS_MST(pref)\
\
logic  ``pref``_tclk  ;\
logic  ``pref``_tvalid;\
logic  ``pref``_tready;\
axis_t ``pref``_tr    ;\
axis_t ``pref``_history[$];\
\
\
/* low-level tasks*/\
task ``pref``_cyc_wait(int cycles = 1);\
	repeat(cycles) @(posedge ``pref``_tclk);\
endtask\
\
function ``pref``_hshake();\
	``pref``_hshake = ``pref``_tvalid && ``pref``_tready;\
endfunction\
\
function ``pref``_eop();\
	``pref``_eop = ``pref``_hshake && ``pref``_tr.tlast;\
endfunction \
\
/* monitor tasks */\
task ``pref``_mon(string src="AXIS_SLV", msg="get", bit verbose=1, bit save=0);\
	do @(posedge ``pref``_tclk); while(!``pref``_hshake());\
	if(verbose) $display("%t : %9s : %s",$time, src, msg);\
	if(save) ``pref``_history.push_front(``pref``_tr);\
endtask\
\
task ``pref``_mon_pack(string src="AXIS_SLV", msg="get", bit verbose=1, bit save=0);\
	do ``pref``_mon(src,msg,verbose,save); while(!``pref``_eop());\
endtask\
\
/* transmit tasks */\
task ``pref``_send(axis_t data);\
	``pref``_tr     <= data;\
	``pref``_tvalid <= 1;\
	do @(posedge ``pref``_tclk); while(!``pref``_hshake());\
	``pref``_tr.tdata.re <= 0;\
	``pref``_tr.tdata.im <= 0;\
	``pref``_tr.tlast    <= 0;\
	``pref``_tvalid <= 0;\
endtask\
\
/* data       -- data words for packet */\
/* wait_seed  -- max number of wait states between transactions (wait states number is a random value) */\
task ``pref``_pack(sample_t data[], int wait_seed=0);\
	axis_t tmp;\
	foreach(data[i]) begin\
		tmp.tdata = data[i]; \
		tmp.tlast = (i==($size(data)-1)); \
		if(wait_seed != 0) ``pref``_cyc_wait($urandom_range(wait_seed));\
		``pref``_send(tmp);\
	end\
endtask

      
`define AXIS_SLV(pref)\
\
logic  ``pref``_tclk  ;\
logic  ``pref``_tvalid;\
logic  ``pref``_tready;\
axis_t ``pref``_tr    ;\
axis_t ``pref``_history[$];\
\
\
/* low-level tasks*/\
task ``pref``_cyc_wait(int cycles = 1);\
	repeat(cycles) @(posedge ``pref``_tclk);\
endtask\
\
function ``pref``_hshake();\
	``pref``_hshake = ``pref``_tvalid && ``pref``_tready;\
endfunction\
\
function ``pref``_eop();\
	``pref``_eop = ``pref``_hshake && (``pref``_tr.tlast === 1'b1);\
endfunction \
\
/* monitor tasks */\
task ``pref``_mon(string src="AXIS_SLV", msg="get", bit verbose=1, bit save=0);\
	do @(posedge ``pref``_tclk); while(!``pref``_hshake());\
	if(verbose) $display("%t : %9s : %s",$time, src, msg);\
	if(save) ``pref``_history.push_front(``pref``_tr);\
endtask\
\
task ``pref``_mon_pack(string src="AXIS_SLV", msg="get", bit verbose=1, bit save=0);\
	do ``pref``_mon(src,msg,verbose,save); while(!``pref``_eop());\
endtask\
\
/* receive tasks */\
task ``pref``_get(int wait_for=0, bit rand_wait=0);\
	if(wait_for != 0) begin\
		if(rand_wait) ``pref``_cyc_wait($urandom_range(wait_for));\
		else          ``pref``_cyc_wait(wait_for);\
	end\
	``pref``_tready <= 1;\
	do @(posedge ``pref``_tclk); while(!``pref``_hshake());\
	``pref``_tready <= 0;\
endtask\
\
task ``pref``_get_pack(int wait_for=0, bit rand_wait=1);\
	do begin\
		``pref``_get(wait_for,rand_wait);\
	end while (!``pref``_eop());\
endtask



`define AXIS_MST_RST(pref,eq)\
\
``pref``_tvalid      ``eq`` 0;\
``pref``_tr.tdata.re ``eq`` 0;\
``pref``_tr.tdata.im ``eq`` 0;\
``pref``_tr.tlast    ``eq`` 0;

`define AXIS_SLV_RST(pref,eq)\
\
``pref``_tready ``eq`` 0;\

