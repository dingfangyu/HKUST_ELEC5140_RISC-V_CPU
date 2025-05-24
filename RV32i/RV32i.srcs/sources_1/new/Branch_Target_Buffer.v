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


module Branch_Target_Buffer#(
    parameter BTB_SIZE = 1024,
    parameter BTB_INDEX_BITS = 10, // 2**10 == 1024
    parameter HIST_LEN = 16,
    parameter HASH_LEN = 8,
) (
    input clk,
    input rst,
    // for reading BTB
    input [31:0] PC_query,  // PC in IF stage
    input [HIST_LEN - 1:0] ghist,

    // for writing BTB
    input [31:0] IF_ID_PC,
    input [6:0] IF_ID_OPcode, 
    input IF_ID_dstall,

    input [31:0] IF_ID_PC_target,

    // outputs from BTB
    output [HASH_LEN - 1:0] reg index,
    output reg BTB_Branch_out, // is branch
    output reg [31:0] BTB_PC_target_out
);
    // data BTB
    reg BTB_Branch [0:BTB_SIZE - 1];
    reg [31:0] BTB_PC_target [0:BTB_SIZE - 1];

    // query BTB
    function [HASH_LEN - 1:0] hash_PC_ghist;
        input [31:0] PC,
        input [HIST_LEN - 1:0] ghist
        ;
        begin
            hash_PC_ghist = PC[HASH_LEN + 1:2] ^ ghist[HASH_LEN - 1:0];
        end 
    endfunction 

    // readout
    always @ (*) begin
        index = hash_PC_ghist(PC_query, ghist);
        BTB_Branch_out = BTB_Branch[index];
        BTB_PC_target_out = BTB_PC_target[index];
    end 

    // write BTB

endmodule
