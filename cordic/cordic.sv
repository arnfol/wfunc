module cordic_rot #(
    parameter CR_STAGE_NUM = 9,
    parameter FFT_STAGE    = 3
) (
    input                                       clk     , // Clock
    input                                       rst_n   , // Asynchronous reset active low
    input                                       cen     ,
    input        [$clog2(1<<(FFT_STAGE-1)-1):0] angle   ,
    output logic [ $clog2(1<<(CR_STAGE_NUM)):0] cos     ,
    output logic                                cos_sign,
    output logic [ $clog2(1<<(CR_STAGE_NUM)):0] sin
);

localparam KN = 1<<(CR_STAGE_NUM);
localparam HA = $clog2(KN>>1);

localparam TABLE_GEN_FOR = 20;

localparam [$clog2(1<<(TABLE_GEN_FOR)>>1):0] angle_table [TABLE_GEN_FOR] = '{
                                                        262144,
                                                        154753,
                                                        81768,
                                                        41507,
                                                        20834,
                                                        10427,
                                                        5215,
                                                        2608,
                                                        1304,
                                                        652,
                                                        326,
                                                        163,
                                                        82,
                                                        41,
                                                        21,
                                                        11,
                                                        6,
                                                        3,
                                                        2,
                                                        1
                                                    };


logic [HA:0]   int_angle                 ;
logic [HA+1:0] x_init,y_init             ;
logic [HA:0]   target_angle[CR_STAGE_NUM];
logic [HA+2:0] z[CR_STAGE_NUM];
logic [HA+2:0] z_next      [CR_STAGE_NUM];
logic signed [HA+2:0] x           [CR_STAGE_NUM];
logic signed [HA+2:0] x_next      [CR_STAGE_NUM];
logic signed [HA+2:0] y           [CR_STAGE_NUM];
logic signed [HA+2:0] y_next      [CR_STAGE_NUM];
logic          turn        [CR_STAGE_NUM];

// localparam logic [$clog2(1<<(CR_STAGE_NUM)):0] CONST_1 = KN/0.607;
localparam START_X = KN*0.607;

localparam MASK = HA - 1;


// function automatic logic [    $clog2(1<<CR_STAGE_NUM):0] angle_table_gen(int i);
//     return KN*($atan( $pow(2.0,-i))/(3.14159265358979));
// endfunction : angle_table_gen

// always_comb begin
//     for (int i = 0; i < CR_STAGE_NUM; i++) begin
//         angle_table[i] = angle_table_gen(i);
//     end
// end

always_comb begin
    if(angle > (1<<(FFT_STAGE-2)) ) begin
        int_angle[MASK:0] =  ((1<<(FFT_STAGE-2)) - angle[$high(angle)-1:0] )<<(CR_STAGE_NUM - FFT_STAGE + 1);
        int_angle[MASK+1] = 1;
    end
    else begin
        int_angle =  (angle )<<(CR_STAGE_NUM - FFT_STAGE + 1);
    end
    x_init    = START_X;
    y_init    = 0;
end

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
         x <= '{default:'0};
         y <= '{default:'0};
         z <= '{default:'0};
         target_angle <= '{default:'1};
    end
    else if(cen) begin
        x[0] <= x_init;
        y[0] <= y_init;
        z[0] <= '0;

        target_angle[0] <= int_angle;
        for (int i = 0; i < (CR_STAGE_NUM-1); i++) begin
            x[i+1] <= x_next[i];
            y[i+1] <= y_next[i];
            z[i+1] <= z_next[i];

            target_angle[i+1] <= target_angle[i];
        end
    end
end

always_comb begin : proc_output
    for (int i = 0; i < (CR_STAGE_NUM); i++) begin
        turn[i] = (target_angle[i][MASK:0] >= z[i][MASK:0])&&(!z[i][MASK+1]) || z[i][HA+2];
        if(turn[i]) begin
            z_next[i] = z[i] + (angle_table[i]>>(TABLE_GEN_FOR - CR_STAGE_NUM)) ;
            x_next[i] = /*y[i][MASK+2] ? x[i] + (y[i]>>i) :*/ x[i] - (y[i]>>>i);
            y_next[i] = /*y[i][MASK+2] ? -y[i] + (x[i]>>i) :*/ y[i] + (x[i]>>>i);
        end
        else begin
            z_next[i] = z[i] - (angle_table[i]>>(TABLE_GEN_FOR - CR_STAGE_NUM)) ;
            x_next[i] = /*y[i][MASK+2] ? x[i] - (y[i]>>i) :*/ x[i] + (y[i]>>>i);
            y_next[i] = /*y[i][MASK+2] ? -(y[i] + (x[i]>>i)) :*/ y[i] - (x[i]>>>i);
        end
    end

    cos = x[CR_STAGE_NUM-1];
    cos_sign = target_angle[CR_STAGE_NUM-1][MASK+1];
    sin = y[CR_STAGE_NUM-1];

    if(target_angle[CR_STAGE_NUM-1][MASK:0] == 0) begin
        if(target_angle[CR_STAGE_NUM-1][MASK+1] == 0) begin // 0
            cos = '0;
            sin = '0;
            cos = KN;
            cos_sign = 0;
        end
        else begin
            cos = '0;
            sin = '0;
            sin =  KN;
            cos_sign = 0;
        end
    end
end

endmodule
