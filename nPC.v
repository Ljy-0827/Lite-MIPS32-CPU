`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
//
// Module Name: nPC
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module nPC(PC, nPC, PC_4, nPC_Op, imm16, inst_index26, jr_value, eret_addr, zero);
    
    // nPC_Op
	// 000: PC+4
	// 001: j/jal跳指令地址(4'_PC+4|26'_inst|00)
    // 010: jr跳寄存器$ra地址
	// 011: beq跳指令地址(PC + {32'_signext(imm16)<<00})
	// 100: eret跳转至eret地址eret_addr
	// 101: 中断发生时跳转0x0000_4180
    input [2:0] nPC_Op;

    input [31:0] PC, jr_value, eret_addr;
	input [15:0] imm16;
	input [25:0] inst_index26;
	input zero;
    
	output [31:0] PC_4, nPC;
    
	assign PC_4 = PC + 4;
	
	assign nPC = (nPC_Op == 3'b000) ? PC_4 : 
	             (nPC_Op == 3'b001) ? {PC[31:28], inst_index26, 2'b00} :
				 (nPC_Op == 3'b010) ? jr_value : 
				 (nPC_Op == 3'b011 && zero) ? PC + {{14{imm16[15]}}, imm16, 2'b00} : 
				 (nPC_Op == 3'b100) ? eret_addr : 
				 (nPC_Op == 3'b101) ? 32'h0000_4180 : 32'h0000_3000;
endmodule
