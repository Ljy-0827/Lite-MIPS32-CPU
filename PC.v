`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: PC
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module PC (clk, reset, PC_Wr, nPC, PC);
    input clk, reset, PC_Wr;
    input [31:0] nPC;
    output [31:0] PC;

    reg [31:0] PC_tmp;
    
    assign PC = PC_tmp;
    
    always @ (posedge clk or posedge reset)
    begin
        if(reset == 1) PC_tmp <= 32'h0000_3000;
        else if(PC_Wr == 1) PC_tmp <= nPC;
        else PC_tmp <= PC_tmp;   //±£³Ö
    end
    
endmodule
