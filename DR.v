`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: DR
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module DR(clk, DataIn, DataOut);
    input clk;
    input [31:0] DataIn;
    output [31:0] DataOut;
    reg [31:0] tmp;
    
    assign DataOut = tmp;
    always @ (posedge clk)
    begin
        tmp <= DataIn;
    end
    
endmodule

