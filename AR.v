`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: AR
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module AR(clk, a_in, a_out);
    input clk;
    input [31:0] a_in;
    output [31:0] a_out;
    
    reg [31:0] tmp;
    assign a_out = tmp;
    
    always @ (posedge clk)
    begin
        tmp <= a_in;
    end
    
endmodule

