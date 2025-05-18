`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2025 01:14:42
// Design Name: 
// Module Name: Forwarding_Unit
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

module Forwarding_Unit(
        input [4:0] ID_EXE_read_reg1,
        input [4:0] ID_EXE_read_reg2,

        input EXE_MEM_RegWrite,
        input [1:0] EXE_MEM_DatatoReg,
        input [4:0] EXE_MEM_written_reg,

        input MEM_WB_RegWrite,
        input [1:0] MEM_WB_DatatoReg,
        input [4:0] MEM_WB_written_reg,

        output reg [1:0] ForwardA, // 00: no forward, 01: from E/M.ALUout, 10: from M/W.data_in
        output reg [1:0] ForwardB
    );


    always @ (*) begin
        ForwardA = 2'b00;
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == ID_EXE_read_reg1 && EXE_MEM_DatatoReg == 2'b00) begin
            // alu
            ForwardA = 2'b01; // E/M buffer. alu out -> E's alu_a 
        end 
        else if (MEM_WB_written_reg != 0 && MEM_WB_written_reg == ID_EXE_read_reg1 && MEM_WB_DatatoReg == 2'b01) begin 
            // load: M/W buffer. data in -> E's alu_a 
            ForwardA = 2'b10;
        end 
        else if (MEM_WB_written_reg != 0 && MEM_WB_written_reg == ID_EXE_read_reg1 && MEM_WB_DatatoReg == 2'b00) begin 
            // alu: M/W buffer. alu out -> E's alu_a 
            /*
            for the case:
                F   D   E   M|  W
                    F   D   E   M   W
                        F   D  |E   M   W
            forwarding happens at M -> E
            */
            ForwardA = 2'b11;
        end 

        ForwardB = 2'b00;
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == ID_EXE_read_reg2 && EXE_MEM_DatatoReg == 2'b00) begin
            ForwardB = 2'b01;
        end 
        else if (MEM_WB_written_reg != 0 && MEM_WB_written_reg == ID_EXE_read_reg2 && MEM_WB_DatatoReg == 2'b01) begin 
            ForwardB = 2'b10;
        end
        else if (MEM_WB_written_reg != 0 && MEM_WB_written_reg == ID_EXE_read_reg2 && MEM_WB_DatatoReg == 2'b00) begin 
            ForwardB = 2'b11;
        end 

        
    end 



    // always @ (*) begin
    //     ForwardA = 2'b00;
    //     if (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg1) begin
    //         if (ID_EXE_DatatoReg == 2'b00) begin // ALU op
    //             ForwardA = 2'b01;
    //         end 
    //     end else if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg1 && ID_EXE_DatatoReg == 2'b01) begin 
    //         ForwardA = 2'b10;
    //     end

    //     ForwardB = 2'b00;
    //     if (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg2) begin 
    //         if (ID_EXE_DatatoReg == 2'b00) begin // ALU op
    //             ForwardB = 2'b01;
    //         end
    //     end else if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2 && ID_EXE_DatatoReg == 2'b01) begin 
    //         ForwardB = 2'b10;
    //     end
    // end 
endmodule


/*


        // the current inst is at stage D, if there are some prev ALU operation inst (written_reg != 0 and DatatoReg == 2'b00) at stage E computing the required IF_ID_read_reg1 or IF_ID_read_reg2 for the curr inst, then do not stall, and forward E's ALU_out to the pipeline buffer ID_EX_read_reg 1 or 2 at the next cycle; else, stall curr D, also stall curr E and next F which are blocked by curr E
        if (ID_EXE_written_reg != 0 && (ID_EXE_written_reg == IF_ID_read_reg1 || ID_EXE_written_reg == IF_ID_read_reg2)) 
        begin 
            // E can compute r1/r2
            if (ID_EXE_DatatoReg == 2'b00) begin 
                if (ID_EXE_written_reg == IF_ID_read_reg1) begin
                    fwd_reg1_data = ID_EXE_ALU_out;
                    fwd1 = 1;
                end 
                else if (ID_EXE_written_reg == IF_ID_read_reg2) begin 
                    fwd_reg2_data = ID_EXE_ALU_out;
                    fwd2 = 1;
                end 
            end 
            // E cannot
            else begin
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
            end
        end

        // the current inst is at stage D, if there are some prev load inst (written_reg != 0 and DatatoReg == 2'b01) at stage M loading the required IF_ID_read_reg1 or IF_ID_read_reg2 for the curr inst, then do not stall, and forward M's data_in to the pipeline buffer ID_EX_read_reg 1 or 2 at the next cycle; else, stall curr D, also curr E and next F blocked by curr E
        else if (EXE_MEM_written_reg != 0 && (EXE_MEM_written_reg == IF_ID_read_reg1 || EXE_MEM_written_reg == IF_ID_read_reg2)) begin 
            // M can always load r1/r2, do not stall
            if (EXE_MEM_DatatoReg == 2'b01) begin
                if (EXE_MEM_written_reg == IF_ID_read_reg1) begin 
                    fwd_reg1_data = data_in;
                    fwd1 = 1;
                end 
                else if (EXE_MEM_written_reg == IF_ID_read_reg2) begin 
                    fwd_reg2_data = data_in;
                    fwd2 = 1;
                end 
            end 
        end
    end
*/