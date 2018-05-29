module cordic_top_tb ();




logic clk = 0;
logic rst_n = 0;
always #5 clk = ~clk;



logic                     tvalid     ;
logic                     tready     ;
logic [$clog2(1<<(18)):0] cos     [4];
logic                     cos_sign[4];
logic [$clog2(1<<(18)):0] sin     [4];
logic                     sin_sign[4];

cordic_top #(
    .FFT_STAGE (12),
    .LAST_STAGE(13),
    .PARL      (4 )
) i_cordic_top (
    .clk     (clk     ),
    .rst_n   (rst_n   ),
    .tvalid  (tvalid  ),
    .tready  (tready  ),
    .cos     (cos     ),
    .cos_sign(cos_sign),
    .sin     (sin     ),
    .sin_sign(sin_sign)
);

int fd;

initial begin
    int cyc_num;
    cyc_num = 0;
    fd = $fopen("top_tb.txt","w");
    repeat(10) @(posedge clk);
    rst_n <= 1;
    repeat(20) @(posedge clk);
    tready <= 1;
    repeat( (1<<(12-3)) ) begin

        for (int i = 0; i < 4; i++) begin
            $fdisplay(fd,"time = %t:",$time);
            // $fdisplay(fd,"angle = %f",$time,180*(1/3.14159265358979)*$acos(( (cos_sign[i] ? -(cos[i]/real'(1<<18)) : cos[i]/real'(1<<18)) ) ));
            $fdisplay(fd,"\t\t\t r_angle = %f",((cyc_num*(4.0)+i)/(1<<11)*180.0) );
            if(
                (( (cos_sign[i] ? -(cos[i]/real'(1<<18)) : cos[i]/real'(1<<18)) ) - $cos( ((cyc_num*(4.0)+i)/(1<<11))*3.14159265358979)) > 0.01 ||
                (( (cos_sign[i] ? -(cos[i]/real'(1<<18)) : cos[i]/real'(1<<18)) ) - $cos( ((cyc_num*(4.0)+i)/(1<<11))*3.14159265358979)) < -0.01
            )
            $fdisplay(fd,"\t\t\t cos_df = %f",
                ( (cos_sign[i] ? -(cos[i]/real'(1<<18)) : cos[i]/real'(1<<18)) ) -
                    $cos( ((cyc_num*(4.0)+i)/(1<<11))*3.14159265358979) );
            else $fdisplay(fd,"\t\t\t cos - ok\t\t\tcos_df<0.1");
            if(
                (sin[i]/real'(1<<18) - $sin( ((cyc_num*(4.0)+i)/(1<<11))*3.14159265358979)) > 0.01 ||
                (sin[i]/real'(1<<18) - $sin( ((cyc_num*(4.0)+i)/(1<<11))*3.14159265358979)) < -0.01
            )
            $fdisplay(fd,"\t\t\t sin_df = %f",
                 (sin[i]/real'(1<<18)) -
                    $sin( ((cyc_num*(4.0)+i)/(1<<11))*3.14159265358979) );
            else $fdisplay(fd,"\t\t\t sin - ok\t\t\tsin_df<0.1");
        end
        cyc_num += 1;
        @(posedge clk);
        // $stop;
    end
    $fclose(fd);
    $stop;
end

endmodule
