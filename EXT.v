`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: EXT
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module EXT(Ext_Op, imm16_in, imm32_out);
    input [1:0] Ext_Op;
    input [15:0] imm16_in;
	output [31:0] imm32_out;
	reg [31:0] imm32_out;
	
    wire [31:0] high_zero_ext;
	wire [31:0] sign_ext;
	wire [31:0] low_zero_ext;
	
    parameter ext_zero16 = 16'b0;    //扩展用16位常数0
	wire [15:0] ext_sign16 = {16{imm16_in[15]}};    //扩展用16位符号位
    
	assign high_zero_ext = {ext_zero16, imm16_in};
	assign sign_ext = {ext_sign16, imm16_in};
	assign low_zero_ext = {imm16_in, ext_zero16};
	 
	always @ (*)
	begin
        case(Ext_Op)
            2'b00: imm32_out = high_zero_ext;
		    2'b01: imm32_out = sign_ext;
		    2'b10: imm32_out = low_zero_ext;
		    default: imm32_out = 0;
        endcase
    end

endmodule

