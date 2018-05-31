module cordic_tb ();


localparam MAX_ST = 13;
localparam MIN_ST = 3;

logic clk = 0;
logic rst_n;
always #5 clk = ~clk;

logic cen[MAX_ST:MIN_ST];
logic cos_sign[MAX_ST:MIN_ST];
logic [$clog2(1<<(MAX_ST-1)-1):0] angle[MAX_ST:MIN_ST];
logic [$clog2(1<<(MAX_ST+5)):0]       cos[MAX_ST:MIN_ST];
logic [$clog2(1<<(MAX_ST+5)):0]       sin[MAX_ST:MIN_ST];

generate for (genvar i = MIN_ST; i <= MAX_ST; i++) begin

cordic_rot #(.CR_STAGE_NUM(i< 5 ? 10 : i + 5), .FFT_STAGE(i)) i_cordic (
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .cen        (cen[i]     ),
    .angle      (angle[i]   ),
    .cos        (cos[i]     ),
    .sin        (sin[i]     ),
    .cos_sign   (cos_sign[i])
);
end
endgenerate

int fd;

initial begin
    fd = $fopen("cordic_tb.txt","w");
    cen <= '{default:'0};
    rst_n <= '0;
    repeat(10) @(posedge clk);
    rst_n <= 1;
    $fdisplay(fd,"If this file does not contain anything(except the stage numbers), then the cordic is calculated correctly.");
    for (int i = MIN_ST; i <= MAX_ST; i++) begin
        $fdisplay(fd,"stage = %d",i);
        cen[i] <= 1;
        fork
            begin
                for (int j = 0; j < (1<<(i-1)); j++) begin
                    angle[i] = j;
                    @(posedge clk);
                end
                repeat( (i< 5 ? 10 : i + 5)-1) @(posedge clk);
            end
            begin

                repeat( (i< 5 ? 10 : i + 5)) @(posedge clk);
                for (int j = 0; j < (1<<(i-1)); j++) begin
                    int kn;

                    kn = 1<<((i< 5 ? 10 : i + 5));
                    @(posedge  clk);
                    if(
                     ((cos_sign[i] ? -(cos[i]/real'(kn)) : cos[i]/real'(kn)) - $cos(real'(j)/(1<<(i-1))*3.14159265358979) > 0.01) ||
                     ((cos_sign[i] ? -(cos[i]/real'(kn)) : cos[i]/real'(kn)) - $cos(real'(j)/(1<<(i-1))*3.14159265358979) < -0.01) ||
                     (sin[i]/real'(kn) - $sin(real'(j)/(1<<(i-1))*3.14159265358979) > 0.01) ||
                     (sin[i]/real'(kn) - $sin(real'(j)/(1<<(i-1))*3.14159265358979) < -0.01)
                     ) begin
                        $fdisplay(fd, "time = %t, angle = %f, cr_cos = %f, cr_sin = %f",$time,real'(j)/(1<<(i-1))*180,
                            cos_sign[i] ? -(cos[i]/real'(kn)) : cos[i]/real'(kn) ,sin[i]/real'(kn));
                        $fwrite(fd, "\t\t\t\t\t\t rl_cos = %f,",$cos(real'(j)/(1<<(i-1))*3.14159265358979));
                        $fdisplay(fd, " rl_sin = %f",$sin(real'(j)/(1<<(i-1))*3.14159265358979));
                        $fwrite(fd, "\t\t\t\t\t\t df_cos = %f,",
                            (cos_sign[i] ? -(cos[i]/real'(kn)) : cos[i]/real'(kn)) - $cos(real'(j)/(1<<(i-1))*3.14159265358979));
                        $fdisplay(fd, " df_sin = %f",sin[i]/real'(kn) - $sin(real'(j)/(1<<(i-1))*3.14159265358979));
                    end
                end
            end
        join
        cen[i] <= 0;
    end
    repeat(20) @(posedge clk);
    $fclose(fd);
    $stop;
end

endmodule
