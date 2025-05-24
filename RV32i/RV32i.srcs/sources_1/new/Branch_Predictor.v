`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2025 22:48:16
// Design Name: 
// Module Name: Branch_Predictor
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


module Branch_Predictor #(
    parameter BP_SIZE = 256,
    parameter BP_INDEX_BITS = 8, 
    parameter HIST_LEN = 16,
    parameter CTR_BITS = 2
) (
    input clk,
    input rst,

    // for reading BP
    input [31:0] PC_query,  // PC in IF stage
    input [HIST_LEN - 1:0] ghist,

    // outputs read from BP
    output reg [BP_INDEX_BITS - 1:0] BP_index,
    output reg [CTR_BITS - 1:0] BP_ctr_out,
    output reg prediction, 

    // // for writing BP
    input [6:0] IF_ID_OPcode, 
    input IF_ID_dstall,
    input [BP_INDEX_BITS - 1:0] IF_ID_BP_index,
    input [1:0] Branch
);
    // data BP
    reg [CTR_BITS - 1:0] BP_ctr [0:BP_SIZE - 1];

    // query BP (in F)
    function [BP_INDEX_BITS - 1:0] hash;
        input [31:0] pc;
        input [HIST_LEN - 1:0] ghr;
        
        reg [31:0] temp;
        
        begin
            temp = pc ^ {ghr, {32-HIST_LEN{1'b0}}};
            temp = temp ^ (temp >> 16);
            temp = temp ^ (temp >> 8);
            hash = temp[BP_INDEX_BITS - 1:0];
        end
    endfunction

    always @ (*) begin
        BP_index = hash(PC_query, ghist); 
        BP_ctr_out = BP_ctr[BP_index];
        prediction = BP_ctr_out[CTR_BITS - 1]; // the first bit
    end 
    
    // write BP (in D)
    integer i;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < BP_SIZE; i = i + 1) begin
                BP_ctr[i] <= {1'b1, {CTR_BITS - 1{1'b0}}}; // weak taken initialization
            end 
        end else begin
            // Branch, IF_ID_BP_index
            if (IF_ID_dstall == 0 && IF_ID_OPcode == 7'b1100011) begin 
                if (BP_ctr[IF_ID_BP_index] < {CTR_BITS{1'b1}} && Branch[0] != 0) begin
                    BP_ctr[IF_ID_BP_index] <= BP_ctr[IF_ID_BP_index] + 1; // T
                end else if (BP_ctr[IF_ID_BP_index] > 0 && Branch[0] == 0) begin
                    BP_ctr[IF_ID_BP_index] <= BP_ctr[IF_ID_BP_index] - 1; // NT
                end
            end 
        end 
    end 

endmodule
