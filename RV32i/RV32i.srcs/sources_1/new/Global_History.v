`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2025 21:09:40
// Design Name: 
// Module Name: Global_History
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


module Global_History #(parameter HIST_LEN = 16) (
    input clk,
    input rst,

    input [6:0] IF_ID_OPcode,
    input [1:0] ID_branch,
    input IF_ID_dstall,

    output reg [HIST_LEN - 1:0] ghist
);
    

    // update ghist, when a branch is resolved (T / NT) in (the last cycle of) D stage
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            // init
            ghist <= 0;
        end else begin
            // if this inst is a branch inst
            if (IF_ID_OPcode == 7'b1100011 && IF_ID_dstall == 0) begin
                ghist <= ghist << 1;
                ghist[0] <= ID_branch[1];
            end
        end 
    end 
endmodule
