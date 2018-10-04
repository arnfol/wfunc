package complex_pkg;

	localparam IM = 1;
	localparam RE = 0;

	typedef struct packed {
		logic signed [31:0] re;
		logic signed [31:0] im;
	} complex64;

	typedef struct packed {
		logic signed  [15:0] re;
		logic signed  [15:0] im;
	} complex32;
	
endpackage