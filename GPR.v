`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: GPR
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module GPR(rW, rA, rB, busA, busB, GPR_Wr, GPR_sel, clk, reset, busW);
    input clk, reset;
    input [4:0] rA, rB, rW;
	input [1:0] GPR_sel;
	input GPR_Wr;
	input [31:0] busW;
	 
	output [31:0] busA, busB;
	 
	reg [31:0] reg_group[31:0];  //32个32位寄存器
	integer i;
	 
    always @ (posedge clk or posedge reset)
    begin
        if(reset == 1)
        begin
            for(i = 0; i < 32; i = i+1)    //reset有效时，寄存器组复位0
                reg_group[i] <= 0;
            reg_group[28] <= 32'h0000_1800;
            reg_group[29] <= 32'h0000_2ffc;
        end
		  
	    else
		begin
            if (GPR_Wr == 1 && GPR_sel != 2'b11)    //没有溢出
            begin
                if(rW != 0)  reg_group[rW] <= busW;  //修改非$0寄存器内数据
            end
			else if (GPR_Wr == 1 && GPR_sel == 2'b11) //有溢出
			begin
                reg_group[30][0] <= 1;
			end
        end
    end
    
    assign busA = reg_group[rA];
	assign busB = reg_group[rB];
endmodule
