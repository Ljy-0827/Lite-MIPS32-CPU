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
    
    //���������opcode��functȷ��ִ������ָ�� 0 - ��Ч�� 1 - ��Ч
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
	S0: fetch ȡָ�����ã�
	S1��DCD/RF ���루���ã�
	S2��MA ��ַ���㣺lw || sw || lb || sb
	S3��MR ��DM��lw || lb
	S4��MemWB DM���д�أ�lw || lb
	S5��MW дDM��sw || sb
	S6��EXE ִ�н׶Σ�R�ͻ�I�ͣ���addu || addiu || addi || subu || ori || lui
	S7��ALUWB ALU���д��
	S8��beq��ַ����
	S9��j/jr/jal��ַ����
	S10: �ж�
	S11: mfc0д��
	S12: mtc0ִ��
	
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
	
	assign EXL_clr = ((current_state == S9) && eret) ? 1 : 0;  //eret��EXL����
	
	assign EXL_set = (current_state == S10) ? 1 : 0;  //EXL: �����жϺ���б�ǣ���ֹ�ٴν���
	
	assign PC_Wr = (current_state == S0) ? 1 :
	               (current_state == S8) ? (beq && zero) : 
	               (current_state == S9) ? (j || jr || jal) : 
	               (current_state == S10) ? 1 : 0;
	
	// nPC_Op
	// 000: PC+4
	// 001: j/jal��ָ���ַ(4'_PC+4|26'_inst|00)
    // 010: jr���Ĵ���$ra��ַ
	// 011: beq��ָ���ַ(PC + {32'_signext(imm16)<<00})  
    // 100: eret��ת��eret��ַeret_addr
	// 101: �жϷ���ʱ��ת0x0000_4180             
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
                    (current_state == S7) ? 1 : //addu || addiu || addi || subu || ori || lui || slt ��S6���꣬S7�ȶ�������ALUOut
                    (current_state == S9) ? jal : 
                    (current_state == S11) ? mfc0 : 0;
    
    assign DM_Wr = (current_state == S5) ? 1 : 0;
    
    // ALU_Op��S1��ǰ����ѡ���ź�
	// 000 - �ӷ�
	// 001 - ����
	// 010 - ��λ��
	// 011 - ������С�ڱȽ�
	// 100 - ֱ������ڶ�������(lui)
	// 101 - addi
	assign ALU_Op = (subu || beq) ? 3'b001 : (ori) ? 3'b010 : (slt) ? 3'b011 : (lui) ? 3'b100 : (addi) ? 3'b101 : 3'b000;
    
    // GPR_sel��S1��ǰ����ѡ���ź�
	// 00 - rt
	// 01 - rd
	// 10 - $31(jal���ص�ַд��)
	// 11 - $30(���)
	assign GPR_sel = (addu || subu || slt) ? 2'b01 : (jal) ? 2'b10 : (current_state == S7 && addi && overflow) ? 2'b11 : 2'b00;
	
    /*
    assign GPR_sel = (current_state == S1 || current_state == S2 || current_state == S7) && (addu || subu || slt) ? 2'b01 : 
                     (current_state == S9 && jal) ? 2'b10 : 
                     (current_state == S7 && addi && overflow) ? 2'b11 : 2'b00; 
    */
    
    // WD_sel��S1��ǰ����ѡ���ź�
	// 00: ALU���д��
	// 01: DM����д��
	// 10: PC+4д��
	// 11: CP0д��
	assign WD_sel = (lw || lb) ? 2'b01 : (jal) ? 2'b10 : (mfc0) ? 2'b11 : 2'b00;
	
	                
    // B_sel
	// 0 - GPR�����busB
	// 1 - EXT�����
    assign B_sel = addi || addiu || lw || lb || sw || sb || ori || lui;
    
    // EXT_Op
	// 00 - ��λ0��չ(ori, default)
	// 01 - ������չ
	// 10 - ��λ0��չ(lui)
	assign EXT_Op = (addi || addiu || beq || lw || sw) ? 2'b01 : (lui) ? 2'b10 : 2'b00;
	
	// WB_sel
	// 1 - �ֽڲ���byte (lb || sb)
	// 0 - �ֲ���word (lw || sw)
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

