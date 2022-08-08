`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: IR
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module IR(clk, IR_Wr, inst, opcode, funct, rs, rt, rd, inst_index26, imm16);
    input clk, IR_Wr;
    input [31:0] inst;
    output [5:0] opcode, funct;
    output [4:0] rs, rt, rd;
    output [15:0] imm16;
    output [26:0] inst_index26;
    
    reg [31:0] inst_reg;
    assign opcode = inst_reg[31:26];
    assign funct = inst_reg[5:0];
    assign rs = inst_reg[25:21];
    assign rt = inst_reg[20:16];
    assign rd = inst_reg[15:11];
    assign imm16 = inst_reg[15:0];
    assign inst_index26 = inst_reg[25:0];
    
    always @ (clk)
    begin
        if (IR_Wr == 1) inst_reg <= inst;
        else inst_reg <= inst_reg;
    end
    
endmodule