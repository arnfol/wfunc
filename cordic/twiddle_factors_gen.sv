//main module for generating twiddle factors
//include cordics pipes and int2float convecter
module twiddle_factors_gen #(
    // stage number [3:$clog2(NFFT)] stage 1 and 2 in DIT( $clog2(NFFT) and $clog2(NFFT)-1 in DIF)
    // calc without cordic
    parameter FFT_STAGE         = 3          ,
    //if 0 - after float convecter removing KN (which needs for cordic computing)
    //else it must be done after fft (at the end of fft pipe)
    parameter NORM_CONST_EN     = 0          ,
    // last stage number needs for choosing norming const
    parameter LAST_STAGE        = 8          ,
    //parameter for parallel packing ( set number of parallel flows )
    parameter PARL              = 1          ,

) (
    input               clk              , // Clock
    input               rst_n            , // Asynchronous reset active low
    output logic        tvalid           ,
    input               tready           ,
    output logic [31:0] cos_fl     [PARL],
    output logic [31:0] sin_fl     [PARL]
);

localparam CR_STAGE_NUM_LAST = (LAST_STAGE  < 5 ? 10 : LAST_STAGE + 5);

logic [$clog2(1<<(CR_STAGE_NUM_LAST)):0] cos[PARL];
logic cos_sign[PARL];
logic [$clog2(1<<(CR_STAGE_NUM_LAST)):0] sin[PARL];
logic sin_sign[PARL];

logic nrst;
logic [31:0] tdata_s;
logic tvalid_s;
logic tready_s;
logic [31:0] tdata_m;
logic tvalid_m;
logic tready_m;

cordic_top #(.*) i_cordic_top (
    .clk     (clk     ),
    .rst_n   (rst_n   ),
    .tvalid  (tvalid  ),
    .tready  (tready  ),
    .cos     (cos     ),
    .cos_sign(cos_sign),
    .sin     (sin     ),
    .sin_sign(sin_sign)
);

generate for (genvar i = 0; i < PARL; i++) begin : gen_conv


int_to_float_pipe i_int_to_float_pipe_sin (
    .clk     (clk     ),
    .nrst    (nrst    ),
    .tdata_s (tdata_s ),
    .tvalid_s(tvalid_s),
    .tready_s(tready_s),
    .tdata_m (tdata_m ),
    .tvalid_m(tvalid_m),
    .tready_m(tready_m)
);

int_to_float_pipe i_int_to_float_pipe_cos (
    .clk     (clk     ),
    .nrst    (nrst    ),
    .tdata_s (tdata_s ),
    .tvalid_s(tvalid_s),
    .tready_s(tready_s),
    .tdata_m (tdata_m ),
    .tvalid_m(tvalid_m),
    .tready_m(tready_m)
);
end
endgenerate

endmodule
