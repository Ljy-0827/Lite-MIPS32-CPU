`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: CPU
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module CPU(clk, reset, Mips_PC, CP0_Rd, CP0_Addr, CP0_Wr, EPC, PrAddr, PrRd, PrWd, CPU_Wr, EXL_set, EXL_clr, IntReq);
    input clk, reset;
    input IntReq;  //Timer通过Bridge返回给Control
    input [31:0] CP0_Rd, EPC, PrRd;
    
    output [31:0] PrAddr, PrWd;
    output CPU_Wr, CP0_Wr, EXL_set, EXL_clr;
    output [4:0] CP0_Addr; //用于mtc0
    output [31:0] Mips_PC;
    
    wire [31:0] inst;
    wire [31:0] PC, nPC, PC_4, EPC, GPR_busA, GPR_busB, ALU_busA, ALU_busB, busW, ALU_result_in, ALU_result_out, DM_in, DM_out, DR_out, EXT_out, AR_out;
    wire [31:0] ALU_result_out, DR_out, DM_in, DM_out, BR_out, GPR_busB_reg;
    wire [25:0] inst_index26;
    wire [15:0] imm16;
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd, rW;
    wire [2:0] ALU_Op, nPC_Op;
    wire [1:0] GPR_sel, EXT_Op, WD_sel;
    wire PC_Wr, IR_Wr, GPR_Wr, DM_Wr, B_sel, WB_sel, zero, overflow;
    
    wire DM_range;
    wire DM_DEV_sel;
    
    assign DM_range = (ALU_result_out[13:0] < 32'h0000_2fff) ? 1 : 0;
    
    //DM_DEV_sel: 用于判断lw从DM还是DEV取
    //0: DM
    //1: DEV
    
    assign DM_DEV_sel = (opcode == 6'b100011 && ~DM_range) ? 1 : 0;
    
    PC instance_PC(
        .clk(clk), .reset(reset), .PC_Wr(PC_Wr), .nPC(nPC), .PC(PC)
    );
    
    nPC instance_nPC(
        .PC(PC), .nPC(nPC), .PC_4(PC_4), .nPC_Op(nPC_Op), .eret_addr(EPC),
        .imm16(imm16), .inst_index26(inst_index26), .jr_value(AR_out), .zero(zero)
    );
    
    IM instance_IM(
        .addr(PC[12:0]), .inst(inst)
    );
    
    IR instance_IR(
        .clk(clk), .IR_Wr(IR_Wr), .inst(inst), .opcode(opcode), .funct(funct), 
        .rs(rs), .rt(rt), .rd(rd), .inst_index26(inst_index26), .imm16(imm16)
    );
    
    GPR instance_GPR(
        .rW(rW), .rA(rs), .rB(rt), .busA(GPR_busA), .busB(GPR_busB),
        .GPR_Wr(GPR_Wr), .GPR_sel(GPR_sel), .clk(clk), .reset(reset), .busW(busW)
    );
    
    ALU instance_ALU(
         .a_in(AR_out), .b_in(BR_out), .ALU_Op(ALU_Op), .ALU_result(ALU_result_in), .zero(zero), .overflow(overflow)
    );
    
    ALUOut instance_ALUOut(
         .clk(clk), .ALU_result_in(ALU_result_in), .ALU_result_out(ALU_result_out)
    );
    
    AR instance_AR(
        .clk(clk), .a_in(GPR_busA), .a_out(AR_out)
    );
    
    BR instance_BR(
        .clk(clk), .B_sel(B_sel), .b_in(GPR_busB), .EXT_out(EXT_out), .b_out(BR_out), .GPR_busB_reg(GPR_busB_reg)
    );
    
    EXT instance_EXT(
        .Ext_Op(EXT_Op), .imm16_in(imm16), .imm32_out(EXT_out)
    );
    
    DM instance_DM(
        .addr(ALU_result_out[13:0]), .DM_Wr(DM_Wr), .clk(clk), .DataIn(DM_in), .DataOut(DM_out), .reset(reset)
    );
    
    DR instance_DR(
         .clk(clk), .DataIn(DM_out), .DataOut(DR_out)
    );

    Controller instance_Controller(
        .clk(clk), .reset(reset), .opcode(opcode), .funct(funct), .overflow(overflow), .zero(zero), .rs(rs),
        .nPC_Op(nPC_Op), .WB_sel(WB_sel), .GPR_sel(GPR_sel), .GPR_Wr(GPR_Wr), .EXT_Op(EXT_Op), .B_sel(B_sel), 
        .ALU_Op(ALU_Op), .DM_Wr(DM_Wr), .IR_Wr(IR_Wr), .PC_Wr(PC_Wr), .WD_sel(WD_sel), .EXL_set(EXL_set), .EXL_clr(EXL_clr), .IntReq(IntReq), .CP0_Wr(CP0_Wr)
    );
    
    assign PrWd = GPR_busB_reg;
    
    assign CPU_Wr = (DM_Wr && ~DM_range) ? 1 : 0;
    assign PrAddr = ALU_result_out;
    assign CP0_Addr = rd;
    assign Mips_PC = PC;
    
    // DM_in
    // WB - 0 sw
    // WB - 1 sb
    //assign DM_in = (WB_sel == 1) ? {DM_out[31:8], BR_out[7:0]} : BR_out;
    assign DM_in = (WB_sel == 1) ? {DM_out[31:8], GPR_busB_reg[7:0]} : GPR_busB_reg;
    
        
    // rW
	// 00 - rt
	// 01 - rd
	// 10 - $31(jal返回地址写回)
	// 11 - $30(溢出)
    assign rW = (GPR_sel == 2'b00) ? rt :
                (GPR_sel == 2'b01) ? rd :
                (GPR_sel == 2'b10) ? 5'b11111 : 5'b11110;
    
    // busW
	// 00: ALU输出写回
	// 01: DM读出写回
	// 10: PC+4写回
	// 11: mfc0写回
    assign busW = (WD_sel == 2'b00) ? ALU_result_out :
                  (WD_sel == 2'b01 && WB_sel == 0 && DM_DEV_sel == 0) ? DR_out :
                  (WD_sel == 2'b01 && WB_sel == 0 && DM_DEV_sel == 1) ? PrRd :
                  (WD_sel == 2'b01 && WB_sel == 1) ? {{24{DR_out[7]}}, DR_out[7:0]} : 
                  (WD_sel == 2'b11) ? CP0_Rd : PC;
    
endmodule

