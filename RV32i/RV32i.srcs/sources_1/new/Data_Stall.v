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

        input [6:0] IF_ID_OPcode,
        input [4:0] IF_ID_written_reg,
        input [4:0] IF_ID_read_reg1,
        input [4:0] IF_ID_read_reg2,
        input [4:0] ID_EXE_written_reg,
        input [4:0] ID_EXE_read_reg1,
        input [4:0] ID_EXE_read_reg2,
        input [4:0] EXE_MEM_written_reg,
        input [4:0] EXE_MEM_read_reg1,
        input [4:0] EXE_MEM_read_reg2,

        input [1:0] ID_EXE_DatatoReg,
        
        input [1:0] EXE_MEM_DatatoReg,

        input [4:0] MEM_WB_written_reg,
        
        output reg PC_dstall,
        output reg IF_ID_dstall,
        output reg ID_EXE_dstall       
    );
    always @ (*) begin

        PC_dstall = 0;
        IF_ID_dstall = 0;
        ID_EXE_dstall = 0;

        // E load-use hazard, not branch
        if (IF_ID_OPcode != 7'b1100011 && ID_EXE_written_reg != 0 && ((ID_EXE_written_reg == IF_ID_read_reg1 || ID_EXE_written_reg == IF_ID_read_reg2)) && ID_EXE_DatatoReg == 2'b01) begin 
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
        end

        // D branch decision hazard, beq t1 t2 label, jalr x0 ra imm?
        if (IF_ID_OPcode == 7'b1100011 && (
                // E is getting rd
                (ID_EXE_written_reg != 0 && (ID_EXE_written_reg == IF_ID_read_reg1 || ID_EXE_written_reg == IF_ID_read_reg2)) || 
                // M is getting rd and M is load
                (EXE_MEM_written_reg != 0 && (EXE_MEM_written_reg == IF_ID_read_reg1 || EXE_MEM_written_reg == IF_ID_read_reg2) && EXE_MEM_DatatoReg == 2'b01)
        )) begin 
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
        end

        // if (EXE_MEM_written_reg != 0 && ((EXE_MEM_written_reg == ID_EXE_read_reg1 || EXE_MEM_written_reg == ID_EXE_read_reg2)) && EXE_MEM_DatatoReg != 2'b00) begin 
        //         PC_dstall = 1;
        //         IF_ID_dstall = 1;
        //         ID_EXE_dstall = 1;

        // end
        
        // if (EXE_MEM_written_reg != 0 && ((EXE_MEM_written_reg == ID_EXE_read_reg1 && ForwardA == 2'b00) || (EXE_MEM_written_reg == ID_EXE_read_reg2 && ForwardB == 2'b00))) begin
        //         PC_dstall = 1;
        //         IF_ID_dstall = 1;
        //         ID_EXE_dstall = 1;
        // end
        // else if (MEM_WB_written_reg != 0 && ((MEM_WB_written_reg == ID_EXE_read_reg1 && ForwardA == 2'b00) || (MEM_WB_written_reg == ID_EXE_read_reg2 && ForwardB == 2'b00))) begin
        //         PC_dstall = 1;
        //         IF_ID_dstall = 1;
        //         ID_EXE_dstall = 1;
        // end

        // if ((ID_EXE_written_reg != 0 && (ID_EXE_written_reg == IF_ID_read_reg1 || ID_EXE_written_reg == IF_ID_read_reg2)) || (EXE_MEM_written_reg != 0 && (EXE_MEM_written_reg == IF_ID_read_reg1 || EXE_MEM_written_reg == IF_ID_read_reg2))) begin
                
        // if (
        //         // r1 is being written by some other insts (E or M), and can be forwarded from (E or M)
        //         (
        //                 // E
        //                 (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg1 && ForwardA == 2'b01)
        //                 ||  
        //                 // M    
        //                 (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg1 && ForwardA == 2'b10)
        //                 ||
        //                 // no other insts are writting r1
        //                 (ID_EXE_written_reg != IF_ID_read_reg1 && EXE_MEM_written_reg != IF_ID_read_reg1)
        //         )  
        //         && 
        //         // r2 
        //         (
        //                 // E
        //                 (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg2 && ForwardB == 2'b01)
        //                 ||  
        //                 // M    
        //                 (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2 && ForwardB == 2'b10)
        //                 ||
        //                 // no other insts are writting r2
        //                 (ID_EXE_written_reg != IF_ID_read_reg2 && EXE_MEM_written_reg != IF_ID_read_reg2)
        //         ) 
        // ) begin 
        //         PC_dstall = 0;
        //         IF_ID_dstall = 0;
        //         ID_EXE_dstall = 0;
        // end else begin
        //         PC_dstall = 1;
        //         IF_ID_dstall = 1;
        //         ID_EXE_dstall = 1;
        // end

        // end
    end

    
endmodule