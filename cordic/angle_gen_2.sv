module angle_generator #(
    parameter                            STAGE      = 3,
    parameter [$clog2(1<<(STAGE-1)-1):0] INIT_PHASE = 0,
    parameter                            PARL       = 1
) (
    input                                   clk  , // Clock
    input                                   rst_n, // Asynchronous reset active low
    input                                   cen  ,
    output logic [$clog2(1<<(STAGE-1)-1):0] angle
);


always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        angle <= INIT_PHASE;
    end
    else if(cen) begin
        angle <= angle + PARL;
    end
end

endmodule
