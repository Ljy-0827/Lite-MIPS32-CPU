`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: CP0
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module CP0(clk, reset, IntReq, PC, DataIn, DataOut, Reg_sel, CP0_Wr, HWInt, EXL_set, EXL_clr, EPC_out);
    input clk, reset, EXL_set, EXL_clr, CP0_Wr;
    input [4:0] Reg_sel;
    input [31:0] DataIn, PC;  //把PC+4传给EPC
    input [5:0] HWInt;  //IP[7:2]（IP[15:10]）
    
    output IntReq;  //输出给CPU，使得在最后一个状态切换至S10
    reg IntReq;
    output [31:0] DataOut, EPC_out;
    
    reg [31:0] SR, Cause, EPC, PrId;
    
    //$12: SR
    //$13: Cause
    //$14: EPC
    //$15: PrId
    assign DataOut = (Reg_sel == 5'b01100) ? SR : 
                     (Reg_sel == 5'b01101) ? Cause :
                     (Reg_sel == 5'b01110) ? EPC :
                     (Reg_sel == 5'b01111) ? PrId : DataOut;

    assign EPC_out = EPC;   
    
    always @ (*)
    begin
        if(reset == 0)
        begin
        Cause[15:10] = Cause[15:10] | HWInt;
        if (EXL_set == 1) SR[1] = 1;  //EXL置1
        if (EXL_clr == 1) 
            begin
                SR[1] = 0;  //EXL置0
                Cause[10] = 0;  //IP
        end
        IntReq = (|(Cause[15:10] & SR[15:10])) & SR[0] & ~SR[1];
        end
    end
    
    always @ (posedge clk or posedge reset)
    begin
        if (reset == 1)
        begin
            EPC <= 0;
            SR <= 0;
            Cause <= 0;
            PrId <= 32'h2008_0204;
        end
        else
        begin
            if(CP0_Wr)
            begin
                if(Reg_sel == 5'b01100) SR <= {16'b0, DataIn[15:10], 8'b0, DataIn[1:0]};
                if(Reg_sel == 5'b01110) EPC <= DataIn;
                if(EXL_set) EPC <= PC;
            end
        end
    end
        

endmodule

