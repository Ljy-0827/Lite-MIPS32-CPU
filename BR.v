`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: BR
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module BR(clk, b_in, EXT_out, B_sel, b_out, GPR_busB_reg);

    input clk, B_sel;
    input [31:0] b_in, EXT_out;
    output [31:0] b_out, GPR_busB_reg;
    
    reg [31:0] tmp, tmp_GPR_busB;
    assign b_out = tmp;
    assign GPR_busB_reg = tmp_GPR_busB;
    
    always @ (posedge clk)
    begin
        tmp <= (B_sel) ? EXT_out : b_in;
        tmp_GPR_busB <= b_in;
    end
    
endmodule
