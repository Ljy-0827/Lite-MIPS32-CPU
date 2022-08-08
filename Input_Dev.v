`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: Input_Dev
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module Input_Dev(DataIn, DataOut);
    input [31:0] DataIn;
    output [31:0] DataOut;
    
    assign DataOut = DataIn;
endmodule
