`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: Controller
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module Controller(clk, reset, rs, IntReq, CP0_Wr, EXL_set, EXL_clr, opcode, funct, nPC_Op, WB_sel, GPR_sel, GPR_Wr, EXT_Op, B_sel, ALU_Op, DM_Wr, IR_Wr, PC_Wr, WD_sel, overflow, zero);
    input clk, reset, zero, overflow, IntReq;
    input [5:0] opcode, funct;
    input [4:0] rs;
    
    output EXL_set, EXL_clr, CP0_Wr;
    output PC_Wr, IR_Wr, GPR_Wr, DM_Wr, B_sel, WB_sel;
    output [1:0] GPR_sel, WD_sel, EXT_Op;
    output [2:0] ALU_Op, nPC_Op;
    
    reg[3:0] current_state, next_state;
    
    //根据输入的opcode和funct确定执行哪条指令 0 - 无效， 1 - 有效
	wire addu = (opcode == 6'b000000 && funct == 6'b100001) ? 1 : 0;
	wire addi = (opcode == 6'b001000) ? 1 : 0;
	wire addiu = (opcode == 6'b001001) ? 1 : 0;
	wire lw = (opcode == 6'b100011) ? 1 : 0;
	wire sw = (opcode == 6'b101011) ? 1 : 0;
	wire subu = (opcode == 6'b000000 && funct == 6'b100011) ? 1 : 0;
	wire beq = (opcode == 6'b000100) ? 1 : 0;
	wire ori = (opcode == 6'b001101) ? 1 : 0;
	wire lui = (opcode == 6'b001111) ? 1 : 0;
	wire slt = (opcode == 6'b000000 && funct == 6'b101010) ? 1 : 0;
	wire j = (opcode == 6'b000010) ? 1 : 0;
	wire jr = (opcode == 6'b000000 && funct == 6'b001000) ? 1 : 0;
	wire jal = (opcode == 6'b000011) ? 1 : 0;
	wire sb = (opcode == 6'b101000) ? 1 : 0;
	wire lb = (opcode == 6'b100000) ? 1 : 0;
	wire eret = (opcode == 6'b010000 && funct == 6'b011000) ? 1 : 0;
	wire mfc0 = (opcode == 6'b010000 && rs == 5'b000000) ? 1 : 0;
	wire mtc0 = (opcode == 6'b010000 && rs == 5'b00100) ? 1 : 0;
	
    /*
	FSM:
	S0: fetch 取指（共用）
	S1：DCD/RF 译码（共用）
	S2：MA 地址计算：lw || sw || lb || sb
	S3：MR 读DM：lw || lb
	S4：MemWB DM输出写回：lw || lb
	S5：MW 写DM：sw || sb
	S6：EXE 执行阶段（R型或I型）：addu || addiu || addi || subu || ori || lui
	S7：ALUWB ALU结果写回
	S8：beq地址计算
	S9：j/jr/jal地址计算
	S10: 中断
	S11: mfc0写回
	S12: mtc0执行
	
	lw || lb: S0 -> S1 -> S2 -> S3 -> S4
	sw || sb: S0 -> S1 -> S2 -> S5
	addu || addiu || addi || subu || ori || lui || slt: S0 -> S1 -> S6 -> S7
	beq: S0 -> S1 -> S8
	j || jr || jal || eret: S0 -> S1 -> S9
	mfc0: S0 -> S1 -> S11
	mtc0: S0 -> S1 -> S12
	*/
	 
	parameter S0 = 4'b0000;
	parameter S1 = 4'b0001;
	parameter S2 = 4'b0010;
	parameter S3 = 4'b0011;
	parameter S4 = 4'b0100;
	parameter S5 = 4'b0101;
	parameter S6 = 4'b0110;
	parameter S7 = 4'b0111;
	parameter S8 = 4'b1000;
	parameter S9 = 4'b1001;
	parameter S10 = 4'b1010;
	parameter S11 = 4'b1011;
	parameter S12 = 4'b1100;
	
	assign CP0_Wr = (current_state == S12 && mtc0) || (current_state == S10);
	
	assign EXL_clr = ((current_state == S9) && eret) ? 1 : 0;  //eret把EXL清零
	
	assign EXL_set = (current_state == S10) ? 1 : 0;  //EXL: 进入中断后进行标记，防止再次进入
	
	assign PC_Wr = (current_state == S0) ? 1 :
	               (current_state == S8) ? (beq && zero) : 
	               (current_state == S9) ? (j || jr || jal) : 
	               (current_state == S10) ? 1 : 0;
	
	// nPC_Op
	// 000: PC+4
	// 001: j/jal跳指令地址(4'_PC+4|26'_inst|00)
    // 010: jr跳寄存器$ra地址
	// 011: beq跳指令地址(PC + {32'_signext(imm16)<<00})  
    // 100: eret跳转至eret地址eret_addr
	// 101: 中断发生时跳转0x0000_4180             
	assign nPC_Op = (current_state == S1 && (j || jal)) ? 3'b001 : 
	                (current_state == S9 && (j || jal)) ? 3'b001 :
	                (current_state == S1 && jr) ? 3'b010 : 
	                (current_state == S9 && jr) ? 3'b010 : 
	                (current_state == S1 && beq) ? 3'b011 : 
	                (current_state == S8 && beq) ? 3'b011 : 
	                ((current_state == S9 || current_state == S0) && eret) ? 3'b100 : 
	                (current_state == S10) ? 3'b101 : 3'b000;
	       
    assign IR_Wr = (current_state == S0) ? 1 : 0;
    

    assign GPR_Wr = (current_state == S4) ? 1 : 
                    (current_state == S7) ? 1 : //addu || addiu || addi || subu || ori || lui || slt 在S6算完，S7稳定存在于ALUOut
                    (current_state == S9) ? jal : 
                    (current_state == S11) ? mfc0 : 0;
    
    assign DM_Wr = (current_state == S5) ? 1 : 0;
    
    // ALU_Op：S1提前设置选择信号
	// 000 - 加法
	// 001 - 减法
	// 010 - 按位或
	// 011 - 带符号小于比较
	// 100 - 直接输出第二操作数(lui)
	// 101 - addi
	assign ALU_Op = (subu || beq) ? 3'b001 : (ori) ? 3'b010 : (slt) ? 3'b011 : (lui) ? 3'b100 : (addi) ? 3'b101 : 3'b000;
    
    // GPR_sel：S1提前设置选择信号
	// 00 - rt
	// 01 - rd
	// 10 - $31(jal返回地址写回)
	// 11 - $30(溢出)
	assign GPR_sel = (addu || subu || slt) ? 2'b01 : (jal) ? 2'b10 : (current_state == S7 && addi && overflow) ? 2'b11 : 2'b00;
	
    /*
    assign GPR_sel = (current_state == S1 || current_state == S2 || current_state == S7) && (addu || subu || slt) ? 2'b01 : 
                     (current_state == S9 && jal) ? 2'b10 : 
                     (current_state == S7 && addi && overflow) ? 2'b11 : 2'b00; 
    */
    
    // WD_sel：S1提前设置选择信号
	// 00: ALU输出写回
	// 01: DM读出写回
	// 10: PC+4写回
	// 11: CP0写回
	assign WD_sel = (lw || lb) ? 2'b01 : (jal) ? 2'b10 : (mfc0) ? 2'b11 : 2'b00;
	
	                
    // B_sel
	// 0 - GPR输出的busB
	// 1 - EXT的输出
    assign B_sel = addi || addiu || lw || lb || sw || sb || ori || lui;
    
    // EXT_Op
	// 00 - 高位0扩展(ori, default)
	// 01 - 符号扩展
	// 10 - 低位0扩展(lui)
	assign EXT_Op = (addi || addiu || beq || lw || sw) ? 2'b01 : (lui) ? 2'b10 : 2'b00;
	
	// WB_sel
	// 1 - 字节操作byte (lb || sb)
	// 0 - 字操作word (lw || sw)
	assign WB_sel = (lb || sb) ? 1 : 0;
	/*
	assign WB_sel = (current_state == S4 && lb) || (current_state == S5 && sb);
	*/
	
	always @ (posedge clk or posedge reset)
    begin
        if(reset == 1) current_state <= S0;
        else current_state <= next_state;
	end
	
	always @ (*)
	begin
        case(current_state)
            S0: next_state <= S1;
            S1: case({(mtc0), (mfc0), (j || jal || jr || eret), (beq), (addu || addi || addiu || subu || ori || lui || slt), (lw || sw || lb || sb)})
                    6'b000001: next_state = S2;   //lw || lb || sw || sb: S0 -> S1 -> S2
                    6'b000010: next_state = S6;   //addu || addi || addiu || subu || ori || lui || slt: S0 -> S1 -> S6
                    6'b000100: next_state = S8;   //beq: S0 -> S1 -> S8
                    6'b001000: next_state = S9;   //j || jal || jr: S0 -> S1 -> S9
                    6'b010000: next_state = S11;  //mfc0
                    6'b100000: next_state = S12;
                    default: next_state = S0;
                endcase
            S2: case({(lw || lb), (sw || sb)})
                    2'b01: next_state = S5;    //sw || sb: S0 -> S1 -> S2 -> S5
                    2'b10: next_state = S3;    //lw || lb: S0 -> S1 -> S2 -> S3
                default: next_state = S0;
                endcase
            S3: next_state = (lw || lb) ? S4 : S0;
            S4:begin
                   if(IntReq == 1) next_state = S10;
                   else next_state = S0;
               end
	        S5: begin
                   if(IntReq == 1) next_state = S10;
                   else next_state = S0;
                end
            S6: next_state = (addu || addiu || addi || subu || ori || lui || slt) ? S7 : S0;
            S7: begin
                   if(IntReq == 1) next_state = S10;
                   else next_state = S0;
                end
            S8: begin
                   if(IntReq == 1) next_state = S10;
                   else next_state = S0;
                end
            S9: begin
                   if(IntReq == 1) next_state = S10;
                   else next_state = S0;
                end
            S10: next_state = S0;
            S11:begin
                    if(IntReq == 1) next_state = S10;
                    else next_state = S0;
                end
            S12:begin
                    if(IntReq == 1) next_state = S10;
                    else next_state = S0;
                end
        endcase
    end

endmodule

