module cordic_top #(
    // stage number [3:$clog2(NFFT)] stage 1 and 2 in DIT( $clog2(NFFT) and $clog2(NFFT)-1 in DIF)
    // calc without cordic
    parameter FFT_STAGE         = 3          ,
    // last stage number needs for choosing norming const
    parameter LAST_STAGE        = 8          ,
    //parameter for parallel packing ( set number of parallel flows )
    parameter PARL              = 1          ,
    //fict param, used as local( MUST BE DEFAULT)
    parameter CR_STAGE_NUM_LAST = (LAST_STAGE  < 5 ? 10 : LAST_STAGE + 5) //local
) (
    input                                           clk           , // Clock
    input                                           rst_n         , // Asynchronous reset active low
    output logic                                    tvalid        ,
    input                                           tready        ,
    output logic [$clog2(1<<(CR_STAGE_NUM_LAST)):0] cos     [PARL],
    output logic                                    cos_sign[PARL],
    output logic [$clog2(1<<(CR_STAGE_NUM_LAST)):0] sin     [PARL],
    output logic                                    sin_sign[PARL]

);


logic cen;
logic [$clog2(1<<(FFT_STAGE-1)-1):0] angle[PARL];

localparam CR_STAGE_NUM = FFT_STAGE < 5 ? 10 : FFT_STAGE + 5;

// localparam CR_STAGE_NUM_LAST = (LAST_STAGE < 5 ? 10 : LAST_STAGE + 5);

localparam CR_NORM = CR_STAGE_NUM_LAST - CR_STAGE_NUM;

logic [$clog2(1<<(CR_STAGE_NUM)):0] cos_cr     [PARL];
logic                               cos_sign_cr[PARL];
logic [$clog2(1<<(CR_STAGE_NUM)):0] sin_cr     [PARL];

logic preset;
logic [$clog2(CR_STAGE_NUM-1):0] preset_cnt;

generate for (genvar i = 0; i < PARL; i++) begin


angle_generator #(
    .STAGE     (FFT_STAGE),
    .INIT_PHASE(i        ),
    .PARL      (PARL     )
) i_angle_generator (
    .clk  (clk     ),
    .rst_n(rst_n   ),
    .cen  (cen     ),
    .angle(angle[i])
);

cordic_rot #(
    .CR_STAGE_NUM(CR_STAGE_NUM),
    .FFT_STAGE   (FFT_STAGE)
) i_cordic (
    .clk     (clk           ),
    .rst_n   (rst_n         ),
    .cen     (cen           ),
    .angle   (angle[i]      ),
    .cos     (cos_cr[i]     ),
    .cos_sign(cos_sign_cr[i]),
    .sin     (sin_cr[i]     )
);


end
endgenerate

always_comb begin : out_logic
    tvalid = !preset;
    cen = preset ? 1 : (tvalid && tready);
end

always_comb begin : proc_norm
    for (int i = 0; i < PARL; i++) begin
        sin_sign[i] = 1;
    end
    for (int i = 0; i < PARL; i++) begin
        cos[i] = cos_cr[i]<<(CR_NORM);
        sin[i] = sin_cr[i]<<(CR_NORM);
        cos_sign[i] = cos_sign_cr[i];
    end
end

always_ff @(posedge clk or negedge rst_n) begin : proc_preset
    if(~rst_n) begin
        preset_cnt <= '0;
        preset     <= 1;
    end
    else if(preset) begin
        preset_cnt <= preset_cnt + 1;
        if(preset_cnt == CR_STAGE_NUM-1)
            preset <= 0;
    end
end

endmodule
