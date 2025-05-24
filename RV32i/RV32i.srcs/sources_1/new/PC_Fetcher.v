`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2025 23:50:03
// Design Name: 
// Module Name: PC_Fetcher
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


    // pc_out : BTB: is_branch, PC_tar
    //      BP: pred(T/NT)
    // is_branch && T: PC_wb = PC_tar
    // else PC_wb +=4

    // PC_wb -> F/D
    // F/D.PC_wb != PC_wb_GT => flush, cstall =1, PC_wb = GT
    //           ==          => PC_wb

module PC_Fetcher (
    input clk,
    input rst,

    input [31:0] PC_query,

    // from BTB
    input BTB_is_Branch_out, // is branch
    input [31:0] BTB_PC_target_out,

    // from BP
    input prediction, 

    // from F/D
    input [31:0] IF_ID_PC_wb,
    input [31:0] PC_wb_gt, // from MUX5, D stage
    input IF_ID_dstall,

    output reg [31:0] PC_pred,
    output reg [31:0] PC_wb, 
    output reg IF_ID_cstall

    );
    
    
    always @ (*) begin

        IF_ID_cstall = 0;

        if (PC_wb_gt != 0 && IF_ID_dstall == 0) begin 
            if (IF_ID_PC_wb == PC_wb_gt) begin 
                if (BTB_is_Branch_out && prediction) PC_wb = BTB_PC_target_out;
                else PC_wb = PC_query + 32'b0100;
            end else begin 
                IF_ID_cstall = 1;
                PC_wb = PC_wb_gt; 
            end 
        end 
    end 

endmodule
