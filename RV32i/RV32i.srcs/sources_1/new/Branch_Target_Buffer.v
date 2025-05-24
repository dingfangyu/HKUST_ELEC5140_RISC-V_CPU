`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2025 21:21:48
// Design Name: 
// Module Name: Branch_Target_Buffer
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


module Branch_Target_Buffer #(
    parameter BTB_SIZE = 256,
    parameter BTB_INDEX_BITS = 8, 
    parameter HIST_LEN = 16
) (
    input clk,
    input rst,
    // for reading BTB
    input [31:0] PC_query,  // PC in IF stage

    // outputs read from BTB
    output reg [BTB_INDEX_BITS - 1:0] BTB_index,
    output reg BTB_is_Branch_out, // is branch
    output reg [31:0] BTB_PC_target_out,

    // for writing BTB
    input [31:0] IF_ID_PC,
    input [6:0] IF_ID_OPcode, 
    input IF_ID_dstall,
    input [BTB_INDEX_BITS - 1:0] IF_ID_BTB_index,

    input [1:0] Branch,
    input [31:0] IF_ID_PC_target

);
    // data BTB
    reg BTB_is_Branch [0:BTB_SIZE - 1];
    reg [31:0] BTB_PC_target [0:BTB_SIZE - 1];

    // query BTB (F)
    always @ (*) begin
        BTB_index = PC_query[BTB_INDEX_BITS + 1:2]; // last PC bits for BTB BTB_indexing
        BTB_is_Branch_out = BTB_is_Branch[BTB_index];
        BTB_PC_target_out = BTB_PC_target[BTB_index];
    end 

    // write BTB (D)
    integer i;
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                BTB_is_Branch[i] <= 0;
                BTB_PC_target[i] <= 0;
            end 
        end else begin
            // in: IF_ID_PC_out, Branch, IF_ID_PC_target, IF_ID_BTB_index
            if (IF_ID_dstall == 0) begin // with this cond, there should be only one cyc in D writing BTB
                BTB_is_Branch[IF_ID_BTB_index] <= IF_ID_OPcode == 7'b1100011;
                BTB_PC_target[IF_ID_BTB_index] <= IF_ID_PC_target;
            end 
        end 
    end 

endmodule
