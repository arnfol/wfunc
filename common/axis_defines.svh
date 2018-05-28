


// // ------------------------------------------------------------------------------
// // --  TASKS FOR TESTING
// // ------------------------------------------------------------------------------

// // ------------------------------------------
// // send data tasks

// // data       -- data words for packet
// // wait_seed  -- max number of wait states between transactions (wait states number is a random value)
// task automatic pack(sample_t data[], int wait_seed=0);
// 	axis_t tmp;

// 	foreach(data[i]) begin
// 		tmp.tdata = data[i]; 
// 		tmp.tlast = (i==0); 

// 		if(wait_seed != 0) cyc_wait($urandom_range(wait_seed));
// 		send(tmp);
// 	end

// endtask

// // simple axis transaction
// task automatic send(axis_t data);
// 	trans  <= data;
// 	tvalid <= 1;

// 	do @(posedge tclk); while(!hshake());

// 	trans  <= axis_trans0;
// 	tvalid <= 0;

// endtask

// // ------------------------------------------
// // receive & monitor data tasks

// // receive axis transaction
// task automatic get(int wait_for=0, bit rand_wait=0);
// 	if(wait_for != 0) begin
// 		if(rand_wait) cyc_wait($urandom_range(wait_for));
// 		else          cyc_wait(wait_for);
// 	end

// 	tready <= 1;
// 	do @(posedge tclk); while(!hshake());
// 	tready <= 0;
// endtask

// // receive axis packet
// task automatic get_pack(int wait_for=0, bit rand_wait=1);
// 	do begin
// 		get(wait_for,rand_wait);
// 	end while (!eop());
// endtask

// // simple axis monitor with history save
// task automatic mon(string src="AXIS_SLV", msg="get", bit verbose=1, bit save=0);
// 	do @(posedge tclk); while(!hshake());

// 	if(verbose) $display(
// 		"%t : %9s : %s data.Re=%8h, data.im=%8h, tlast=%b",
// 		$time, src, msg, trans.tdata.re, trans.tdata.im, trans.tlast);

// 	if(save) history.push_front(trans);
// endtask

// // monitor full packet
// task automatic mon_pack(string src="AXIS_SLV", msg="get", bit verbose=1, bit save=0);
// 	do mon(src,msg,verbose,save); while(!eop());
// endtask

      
`define LOW_LVL_AXIS_TASKS(pref)                           \
                                                           \
logic  ``pref``_tclk  ;                                    \
logic  ``pref``_tvalid;                                    \
logic  ``pref``_tready;                                    \
axis_t ``pref``_tr    ;                                    \
                                                           \
task automatic ``pref``_cyc_wait(int cycles = 1);          \
	repeat(cycles) @(posedge ``pref``_tclk);               \
endtask                                                    \
                                                           \
function automatic ``pref``_hshake();                      \
	``pref``_hshake = ``pref``_tvalid && ``pref``_tready;  \
endfunction                                                \
                                                           \
function automatic ``pref``_eop();                         \
	``pref``_eop = ``pref``_hshake && ``pref``_tr.tlast;   \
endfunction 