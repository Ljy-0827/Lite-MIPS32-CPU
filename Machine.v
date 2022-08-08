`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: Machine
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module Machine(clk, reset, DEV_input);
    input clk, reset;
    input [31:0] DEV_input;
    wire [31:0] PrWd, Mips_PC, CP0_Rd, EPC, PrRd, PrAddr, DEV1_Rd, DEV2_Rd, DEV3_Rd, DEV_Wd;
    wire CP0_Wr, IntReq, CPU_Wr, EXL_set, EXL_clr, Timer_IRQ, Output_Dev_Wr, Timer_Wr;
    wire [4:0] CP0_Addr;

    wire [5:0] HWInt;  //6位中断请求信号，timer发出的中断请求信号放在最低位，其余全0
    wire [1:0] DEV_Addr;
    
    CPU CPU(
        .clk(clk), .reset(reset), .Mips_PC(Mips_PC), .CP0_Rd(CP0_Rd), .CP0_Addr(CP0_Addr), .CP0_Wr(CP0_Wr), 
        .EPC(EPC), .PrAddr(PrAddr), .PrRd(PrRd), .PrWd(PrWd), .CPU_Wr(CPU_Wr), .EXL_set(EXL_set), .EXL_clr(EXL_clr), .IntReq(IntReq)
    );
    Bridge Bridge(
        .PrAddr(PrAddr), .PrRd(PrRd), .PrWd(PrWd), .DEV1_Rd(DEV1_Rd), .DEV2_Rd(DEV2_Rd), .DEV3_Rd(DEV3_Rd), .DEV_Wd(DEV_Wd), .DEV_Addr(DEV_Addr), 
        .Output_Dev_Wr(Output_Dev_Wr), .Timer_Wr(Timer_Wr), .CPU_Wr(CPU_Wr), .Timer_IRQ(Timer_IRQ), .HWInt(HWInt)
    );
    CP0 CP0(
        .clk(clk), .reset(reset), .IntReq(IntReq), .PC(Mips_PC), .DataIn(PrWd),. DataOut(CP0_Rd), .Reg_sel(CP0_Addr), .CP0_Wr(CP0_Wr), 
        .HWInt(HWInt), .EXL_set(EXL_set), .EXL_clr(EXL_clr), .EPC_out(EPC)
    );
    Input_Dev Input_Dev(
        .DataIn(DEV_input), .DataOut(DEV3_Rd)
    );
    Output_Dev Output_Dev(
        .Output_Dev_Wr(Output_Dev_Wr), .DataIn(DEV_Wd), .DataOut(DEV2_Rd), .clk(clk), .addr(DEV_Addr)
    );
    Timer_Dev Timer_Dev(
        .clk(clk), .reset(reset), .addr(DEV_Addr), .Timer_Wr(Timer_Wr), .DataIn(DEV_Wd), .DataOut(DEV1_Rd), .Timer_IRQ(Timer_IRQ)
    );
endmodule

