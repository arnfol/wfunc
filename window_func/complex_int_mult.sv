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
                  Very simplified model of complex multimplier in int.

*/
module complex_int_mult
    import axis_pkg::*;
#(
    PIPE_NUM = 10
) (
    input               clk  ,
    input               rst_n,
    input               en   ,
    input  sample_t_int a    , // input 1
    input  sample_t_int b    , // input 2
    output sample_t_int z      // result
);

    output sample_t_int z_reg[PIPE_NUM]; // not pipelined result

    // pipeline
    always_ff @(posedge clk or negedge rst_n) begin : proc_z_reg
        if(~rst_n) begin
            for (int i = 0; i < PIPE_NUM; i++) begin
                z_reg[i] <= '{0,0};
            end 
        end else if(en) begin
            z_reg[0].re <= a.re*b.re - a.im*b.im;
            z_reg[0].im <= a.re*b.im + a.im*b.re;
            for (int i = 1; i < PIPE_NUM; i++) begin
                z_reg[i] <= z_reg[i-1];
            end 
        end
        end // of for
    end

    assign z = z_reg[PIPE_NUM];

endmodule