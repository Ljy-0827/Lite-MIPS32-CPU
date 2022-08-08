`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: DM
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module DM(reset, addr, DM_Wr, clk, DataIn, DataOut);
    input reset;
    input [13:0] addr;  //14位地址
	input [31:0] DataIn;
	input clk, DM_Wr;
	 
	output [31:0] DataOut;
	reg [31:0] DataOut;
	 
	reg [7:0] dm[0:12287];
	
	integer i;
	always @ (posedge reset)
	begin
        if(reset == 1)
        begin
            for(i = 0; i < 12288; i = i+1)    //reset有效时，寄存器组复位0
                dm[i] <= 0;
        end
    end
	 
	always @ (clk)
	begin
        if (DM_Wr == 1) {dm[addr+3], dm[addr+2], dm[addr+1], dm[addr]} <= DataIn;
        else DataOut <= {dm[addr+3], dm[addr+2], dm[addr+1], dm[addr]};
    end
endmodule
