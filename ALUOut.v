`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: ALUOut
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module ALUOut(clk, ALU_result_in, ALU_result_out);
    input clk;
    input [31:0] ALU_result_in;
    output [31:0] ALU_result_out;
    reg [31:0] tmp;
    
    assign ALU_result_out = tmp;
    
    always @ (posedge clk)
    begin
        tmp <= ALU_result_in;
    end
    
endmodule

