`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: Output_Dev
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module Output_Dev(Output_Dev_Wr, DataIn, DataOut, clk, addr);
    input [31:0] DataIn;
    input clk, Output_Dev_Wr, addr;
    
    output [31:0] DataOut;
    reg [31:0] Dev_Reg [1:0];
    
    assign DataOut = Dev_Reg[addr];
    
    always @ (posedge clk)
    begin
        if(Output_Dev_Wr == 1) Dev_Reg[addr] <= DataIn;
    end
endmodule

