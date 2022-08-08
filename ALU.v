`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: ALU
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module ALU(a_in, b_in, ALU_Op, ALU_result, zero, overflow);
    input [31:0] a_in, b_in;
    input [2:0] ALU_Op;
	 
    output [31:0] ALU_result;
    output overflow, zero;

    assign zero = (a_in - b_in == 0) ? 1 : 0;
    wire [32:0] tmp_add_result = a_in + b_in;  //33位临时变量，用来后续检查是否有溢出
    
    assign overflow = (a_in[31] == 0 && b_in[31] == 0 && tmp_add_result[31] == 1 && ALU_Op == 3'b101) 
                   || (a_in[31] == 1 && b_in[31] == 1 && tmp_add_result[31] == 0 && ALU_Op == 3'b101) ? 1 : 0;
    
    // ALU_ctr
    // 000 - addu / addiu / subu / lw / sw
    // 001 - subu / beq
    // 010 - ori
    // 011 - slt
    // 100 - lui
    // 101 - addi
    assign ALU_result = (ALU_Op == 3'b000) ? tmp_add_result[31:0] :   //取低32位
                        (ALU_Op == 3'b001) ? a_in - b_in : 
                        (ALU_Op == 3'b010) ? a_in | b_in :
                        (ALU_Op == 3'b011) ? (($signed(a_in) < $signed(b_in)) ? 1 : 0) :
                        (ALU_Op == 3'b100) ? b_in : 
                        (ALU_Op == 3'b101) ? tmp_add_result[31:0] : 0;
endmodule
