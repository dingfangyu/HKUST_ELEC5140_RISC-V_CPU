`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/10 21:05:36
// Design Name: 
// Module Name: REG_IF_ID
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


    wire [BP_INDEX_BITS - 1:0] BP_index;
    wire [CTR_BITS - 1:0] BP_ctr_out;
    wire prediction; 
    wire [BP_INDEX_BITS - 1:0] IF_ID_BP_index;

module REG_IF_ID #(
    parameter BTB_INDEX_BITS = 8,
    parameter BP_INDEX_BITS = 8
)(
        input clk,
        input rst, 
        input CE,
        input IF_ID_dstall,
        input IF_ID_cstall,
        
        input [31:0] inst_in,
        input [31:0] PC,
        input [BTB_INDEX_BITS - 1:0] BTB_index, // BTB
        input [BP_INDEX_BITS - 1:0] BP_index,
        
        output reg [31:0] IF_ID_inst_in,
        output reg [31:0] IF_ID_PC = 0,
        output reg [BTB_INDEX_BITS - 1:0] IF_ID_BTB_index, // BTB
        output reg [BP_INDEX_BITS - 1:0] IF_ID_BP_index

    );
    always @ (posedge clk or posedge rst) begin
        if (rst == 1) begin
            IF_ID_inst_in <= 32'h00000013;
            IF_ID_PC <= 32'h00000000;
        end
        // A bubble here is a nop, or rather, "addi x0, x0, 0"
        if (IF_ID_dstall == 0) begin
            if (rst == 1 || IF_ID_cstall == 1'b1) begin
                IF_ID_inst_in <= 32'h00000013;
                IF_ID_PC <= 32'h00000000;
                IF_ID_BTB_index <= 0;
                IF_ID_BP_index <= 0;
            end
            else if (CE) begin
                IF_ID_inst_in <= inst_in;
                IF_ID_PC <= PC;
                IF_ID_BTB_index <= BTB_index;
                IF_ID_BP_index <= BP_index;
            end
        end
        // else: if stall, then nothing changes here
    end
endmodule
