`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2025 22:03:57
// Design Name: 
// Module Name: ALU_B_Fwd
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


module ALU_B_Fwd(
    input [1:0] ID_EXE_ALUSrc_B,
    input [1:0] ForwardB,

    input [31:0] ID_EXE_ALU_B,
    input [31:0] EXE_MEM_ALU_out,
    input [31:0] MEM_WB_Data_in,
    input [31:0] MEM_WB_ALU_out,

    output reg [31:0] ALU_B_fwd
    );

    always @ (*) begin
        if (ID_EXE_ALUSrc_B == 2'b00) begin
            // reg2 == ALU B
            case(ForwardB)
                2'b00: ALU_B_fwd = ID_EXE_ALU_B;
                2'b01: ALU_B_fwd = EXE_MEM_ALU_out;
                2'b10: ALU_B_fwd = MEM_WB_Data_in;
                2'b11: ALU_B_fwd = MEM_WB_ALU_out;
                default: ALU_B_fwd = ID_EXE_ALU_B;
            endcase
        end 
        else begin
            // ALU B is not reg2
            ALU_B_fwd = ID_EXE_ALU_B;
        end 
    end 
endmodule
