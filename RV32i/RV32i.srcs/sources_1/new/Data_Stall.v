`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/17 20:31:40
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
        input [4:0] IF_ID_written_reg,
        input [4:0] IF_ID_read_reg1,
        input [4:0] IF_ID_read_reg2,

        input [4:0] ID_EXE_written_reg,
        input [1:0] ID_EXE_DatatoReg,
        input [4:0] ID_EXE_read_reg1,
        input [4:0] ID_EXE_read_reg2,
        input [31:0] ID_EXE_ALU_out,

        input [4:0] EXE_MEM_written_reg,
        input [1:0] EXE_MEM_DatatoReg,
        input [4:0] EXE_MEM_read_reg1,
        input [4:0] EXE_MEM_read_reg2, 

        input [31:0] data_in, // M

        output reg fwd1,
        output reg fwd2,
        output reg [31:0] fwd_reg1_data,
        output reg [31:0] fwd_reg2_data,
        
        output reg PC_dstall,
        output reg IF_ID_dstall,
        output reg ID_EXE_dstall       
    );

    always @ (*) begin
        PC_dstall = 0;
        IF_ID_dstall = 0;
        ID_EXE_dstall = 0;

        fwd1 = 0;
        fwd2 = 0;
        

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


endmodule
