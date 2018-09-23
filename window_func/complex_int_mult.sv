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
                  Pipelined complex multimplier in int.

*/
module complex_int_mult
    import axis_pkg::*;
#(
    PIPE_NUM = 10, // should be > 2
    DISPLNUM = 0
) (
    input               clk  ,
    input               rst_n,
    input               en   , // enable of the module, 0 stops operation
    input  sample_t_int a    , // input 1
    input  sample_t_int b    , // input 2
    output sample_t     z      // result
);

    localparam ADD_PIPE_NUM = PIPE_NUM-2;

    sample_t z_reg[ADD_PIPE_NUM]; 
    sample_t_int a_del, b_del;
    logic signed [31:0] are_bre, aim_bim, are_bim, aim_bre;



    // input registers
    always_ff @(posedge clk or negedge rst_n) begin : proc_ab_delay
        if(~rst_n) begin
            a_del <= '{0,0}; 
            b_del <= '{0,0};
        end else if(en) begin
            a_del <= a; 
            b_del <= b;
        end
    end

    // multiplication registers
    always_ff @(posedge clk or negedge rst_n) begin : proc_mult
        if(~rst_n) begin
            are_bre <= '0;
            aim_bim <= '0;
            are_bim <= '0;
            aim_bre <= '0;
        end else if(en) begin
            are_bre <= a_del.re*b_del.re; 
            aim_bim <= a_del.im*b_del.im;
            are_bim <= a_del.re*b_del.im; 
            aim_bre <= a_del.im*b_del.re;
        end
    end

    // sum register & additional pipeline for retiming
    always_ff @(posedge clk or negedge rst_n) begin : proc_z_reg
        if(~rst_n) begin
            for (int i = 0; i < ADD_PIPE_NUM; i++) begin
                z_reg[i] <= '{0,0};
            end 
        end else if(en) begin
            z_reg[0].re <= are_bre - aim_bim;
            z_reg[0].im <= are_bim + aim_bre;
            for (int i = 1; i < ADD_PIPE_NUM; i++) begin
                z_reg[i] <= z_reg[i-1];
            end 
        end
    end

    // translate_off
    // // for debug
    // always @(posedge clk) begin 
    //     if(en) begin
    //         $display("%t : MULT%2d : (%d + %dj)*(%d + %dj)=(%d + %dj) // (%h + %hj)",
    //         $time, DISPLNUM, a.re, a.im, b.re, b.im, (a.re*b.re - a.im*b.im), (a.re*b.im + a.im*b.re), (a.re*b.re - a.im*b.im), (a.re*b.im + a.im*b.re));
    //     end
    // end
    // translate_on


    assign z = z_reg[ADD_PIPE_NUM-1];

endmodule