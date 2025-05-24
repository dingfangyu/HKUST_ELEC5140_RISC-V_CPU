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
    parameter BTB_SIZE = 1024,
    parameter BTB_INDEX_BITS = 10, // 2**10 == 1024
    parameter HIST_LEN = 16,
    parameter HASH_LEN = 8
) (
    input clk,
    input rst,
    // for reading BTB
    input [31:0] PC_query,  // PC in IF stage
    input [HIST_LEN - 1:0] ghist,


    // outputs read from BTB
    output reg [HASH_LEN - 1:0] index,
    output reg BTB_Branch_out, // is branch
    output reg [31:0] BTB_PC_target_out,

    // for writing BTB
    input [31:0] IF_ID_PC,
    input [6:0] IF_ID_OPcode, 
    input IF_ID_dstall,
    input [HASH_LEN - 1:0] IF_ID_index,

    input [1:0] Branch,
    input [31:0] IF_ID_PC_target

);
    // data BTB
    reg BTB_Branch [0:BTB_SIZE - 1];
    reg [31:0] BTB_PC_target [0:BTB_SIZE - 1];

    // query BTB
    function [HASH_LEN-1:0] branch_hash;
        input [31:0] pc;                  // 32位程序计数器
        input [HIST_LEN-1:0] ghr;         // 参数化的全局分支历史寄存器
        input integer HASH_LEN;            // 哈希结果位宽
        
        reg [31:0] pc_xor;                // PC的XOR折叠结果
        reg [HIST_LEN-1:0] ghr_xor;       // GHR的XOR折叠结果
        reg [HASH_LEN-1:0] hash;          // 最终哈希结果
        integer i;
        
        begin
            // 第一步：对PC进行XOR折叠到HASH_LEN*2位
            pc_xor = {HASH_LEN*2{1'b0}};  // 初始化为0
            for (i = 0; i < 32/(HASH_LEN*2); i = i + 1) begin
                pc_xor = pc_xor ^ pc[i*(HASH_LEN*2) +: HASH_LEN*2];
            end
            
            // 第二步：对GHR进行XOR折叠到HASH_LEN*2位
            ghr_xor = {HASH_LEN*2{1'b0}}; // 初始化为0
            for (i = 0; i < HIST_LEN/(HASH_LEN*2); i = i + 1) begin
                ghr_xor = ghr_xor ^ ghr[i*(HASH_LEN*2) +: HASH_LEN*2];
            end
            
            // 第三步：组合PC和GHR的折叠结果，再进行一次XOR
            hash = pc_xor[HASH_LEN-1:0] ^ ghr_xor[HASH_LEN-1:0];
            
            // 返回哈希结果
            branch_hash = hash;
        end
    endfunction

    // readout (in F)
    always @ (*) begin
        index = branch_hash(PC_query, ghist, HASH_LEN);
        BTB_Branch_out = BTB_Branch[index];
        BTB_PC_target_out = BTB_PC_target[index];
    end 

    // write BTB in (D)
    integer i;
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                BTB_Branch[i] <= 0;
                BTB_PC_target[i] <= 0;
            end 
        end else begin
            // in: IF_ID_PC_out, Branch, IF_ID_PC_target, IF_ID_index
            if (IF_ID_dstall == 0 && IF_ID_OPcode == 7'b1100011) begin // the cycle when the branch is resolved in D
                BTB_Branch[IF_ID_index] <= Branch[0];
                BTB_PC_target[IF_ID_index] <= IF_ID_PC_target;
            end 
        end 
    end 

endmodule
