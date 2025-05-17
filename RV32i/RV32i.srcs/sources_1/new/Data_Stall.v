`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/12 08:46:15
// Design Name: 
// Module Name: Data_Stall
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Data_Stall(
        input [1:0] ForwardA, // 00: no forward, 01: from E.ALUout, 10: from M.data_in
        input [1:0] ForwardB, 

        input [4:0] IF_ID_written_reg,
        input [4:0] IF_ID_read_reg1,
        input [4:0] IF_ID_read_reg2,
        input [4:0] ID_EXE_written_reg,
        input [4:0] ID_EXE_read_reg1,
        input [4:0] ID_EXE_read_reg2,
        input [4:0] EXE_MEM_written_reg,
        input [4:0] EXE_MEM_read_reg1,
        input [4:0] EXE_MEM_read_reg2,
        
        output reg PC_dstall,
        output reg IF_ID_dstall,
        output reg ID_EXE_dstall       
    );
    always @ (*) begin

        PC_dstall = 0;
        IF_ID_dstall = 0;
        ID_EXE_dstall = 0;

        if (
                // r1 is being written by some other insts (E or M), and can be forwarded from (E or M)
                (
                        // E
                        (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg1 && ForwardA == 2'b01)
                        ||  
                        // M    
                        (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg1 && ForwardA == 2'b10)
                )  
                && 
                // r2 
                (
                        // E
                        (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg2 && ForwardB == 2'b01)
                        ||  
                        // M    
                        (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2 && ForwardB == 2'b10)
                ) 
        ) begin 
                PC_dstall = 0;
                IF_ID_dstall = 0;
                ID_EXE_dstall = 0;
        end else begin
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
        end
    end
endmodule