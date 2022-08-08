`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: IM
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module IM(addr, inst);
    input [12:0] addr;
	output [31:0] inst;
	reg [7:0] im[0:8191];
	assign inst = {im[addr[12:0]], im[addr[12:0]+1], im[addr[12:0]+2], im[addr[12:0]+3]};
endmodule
