`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Creator: Junyao Liu 
// 
// Module Name: Timer_Dev
// Project Name: MIPS32_CPU
//////////////////////////////////////////////////////////////////////////////////

module Timer_Dev(clk, reset, addr, Timer_Wr, DataIn, DataOut, Timer_IRQ);
    input clk, reset, Timer_Wr;
    input [1:0] addr;
    input [31:0] DataIn;
    
    output [31:0] DataOut;
    reg [31:0] DataOut;
    output Timer_IRQ;
    
    //addr
    //00: ctrl
    //01: preset
    //10: count
    reg [31:0] CTRL, PRESET, COUNT;
    
    assign Timer_IRQ = (COUNT == 0) && (CTRL[3] && (CTRL[2:1] == 2'b00) && CTRL[0]) ? 1 : 0;
    
    always @ (addr)
    begin
        case(addr)
            2'b00: DataOut = CTRL;
            2'b01: DataOut = PRESET;
            2'b10: DataOut = COUNT;
        endcase
    end
    
    always @ (posedge Timer_Wr)
    begin
        case(addr)
            2'b00: CTRL <= DataIn;
            2'b01: begin
                       PRESET <= DataIn;
                       COUNT <= DataIn;
                   end
        endcase
    end
    
    always @ (posedge clk or posedge reset)
    begin
        if(reset == 1)
        begin
            CTRL <= 0;
            PRESET <= 0;
            COUNT <= 0;
        end
        if(CTRL[0] == 1)
        begin
            if(COUNT != 0) COUNT <= COUNT - 1;
            else if (CTRL[2:1] == 2'b01) COUNT <= PRESET;
            else CTRL[0] <= 0;
        end
    end    
    
endmodule

