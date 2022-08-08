`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: Bridge
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module Bridge(PrAddr, PrRd, PrWd, DEV1_Rd, DEV2_Rd, DEV3_Rd, DEV_Wd, DEV_Addr, Output_Dev_Wr, Timer_Wr, CPU_Wr, Timer_IRQ, HWInt);
    input [31:0] PrAddr, PrWd, DEV1_Rd, DEV2_Rd, DEV3_Rd;
    input CPU_Wr;
    input Timer_IRQ;
    
    output [31:0] PrRd, DEV_Wd;
    output [5:0] HWInt;  //6位中断请求信号，timer发出的中断请求信号放在最低位，其余全0
    output [1:0] DEV_Addr;
    output Output_Dev_Wr, Timer_Wr;
    
    wire HitDEV1, HitDEV2, HitDEV3;
    assign HitDEV1 = (PrAddr[31:4] == 28'h0000_7f0) ? 1 : 0;  //Timer: >= 32'h0000_7f00 && <= 32'h0000_7f0B
    assign HitDEV2 = (PrAddr[31:4] == 28'h0000_7f1) ? 1 : 0;  //Output Device: 32'h0000_7f14 || 32'h0000_7f18
    assign HitDEV3 = (PrAddr[31:4] == 28'h0000_7f2) ? 1 : 0;  //Input Device: 32'h0000_7f20

    assign PrRd = (HitDEV1) ? DEV1_Rd :
                  (HitDEV2) ? DEV2_Rd :
                  (HitDEV3) ? DEV3_Rd : 32'h0000_0000;
                  
    assign Timer_Wr = CPU_Wr & HitDEV1;  //只有timer和output device有写允许（input device不写入）
    assign Output_Dev_Wr = CPU_Wr & HitDEV2;
    
    assign DEV_Addr = PrAddr[3:2];
    assign DEV_Wd = PrWd;
    
    assign HWInt = {5'b0, Timer_IRQ};

endmodule

