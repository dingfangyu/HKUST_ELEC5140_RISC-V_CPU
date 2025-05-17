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
        if (ID_EXE_written_reg != 0 && (ID_EXE_written_reg == IF_ID_read_reg1 || ID_EXE_written_reg == IF_ID_read_reg2)) begin
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
        end
        else if (EXE_MEM_written_reg != 0 && (EXE_MEM_written_reg == IF_ID_read_reg1 || EXE_MEM_written_reg == IF_ID_read_reg2)) begin
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
        end
    end
endmodule

/*
if (ID_EXE_written_reg != 0 && (ID_EXE_written_reg == IF_ID_read_reg1 || ID_EXE_written_reg == IF_ID_read_reg2)) begin
        PC_dstall = 1;
        IF_ID_dstall = 1;
        ID_EXE_dstall = 1;
end
else if (EXE_MEM_written_reg != 0 && (EXE_MEM_written_reg == IF_ID_read_reg1 || EXE_MEM_written_reg == IF_ID_read_reg2)) begin
        PC_dstall = 1;
        IF_ID_dstall = 1;
        ID_EXE_dstall = 1;
end





ID_EXE_written_reg IF_ID_read_reg1 IF_ID_read_reg2
EXE_MEM_written_reg IF_ID_read_reg1 IF_ID_read_reg2

r1 r2 [4:0]
PC_out ~ inst_in => IF_ID_inst_in ~ r1 r2

IF_ID_inst_in ~ IF_ID_written_reg => ID_EXE_written_reg => EXE_MEM_written_reg

if the E, M stages want to write a reg, and the reg is required by the current inst as r1 or r2
then dstall: PC, IF_ID, ID_EXE

PC_dstall = 1;  => PC does not update at posedge clk
IF_ID_dstall = 1; => IF_ID_REG does not update PC, inst
ID_EXE_dstall = 1; => ID_EXE_REG does not update

M, W stages do not have a stall, only the first 3 stages (F, D, E) do

how to forward?

        E -> D
        ALU_A / ALU_B (D stage) <= ALU_out (E stage)
        ID_EXE_ALU_out? EXE_MEM_ALU_out? 

        M -> D
        ALU_A / ALU_B (D stage) <= data_in (M stage, loaded from mem)
        data_in? MEM_WB_Data_in? 

should it forwards from the outbuffer rather than in-stage results? yes

A = regfile[reg]
A = loaded_data
A = alu_out

cases:
E->D
        F D E M W
          F D E M W : E -> E

        if E is writing (and op = 0110011 (R) or 0010011 (I)), use it
        else stall

M->D
        F D E M W
          F D   E M W : M -> E

        F D E M W : M
          F D E M W
            F D E M W : E

        if M is writing (load: 7'b0000011), use it
        else stall
*/



// module Forward_Unit (
//         input [4:0] IF_ID_read_reg1,
//         input [4:0] IF_ID_read_reg2,
//         input [4:0] EXE_MEM_written_reg,
//         input [4:0] MEM_WB_written_reg,

//         output ForwardA,
//         output ForwardB,
//         output [31:0] ForwardA_data,
//         output [31:0] ForwardB_data,
// );

// endmodule