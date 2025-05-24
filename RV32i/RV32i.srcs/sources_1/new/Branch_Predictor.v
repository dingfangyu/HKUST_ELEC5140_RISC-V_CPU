// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date: 24.05.2025 22:48:16
// // Design Name: 
// // Module Name: Branch_Predictor
// // Project Name: 
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////


// module Branch_Predictor #(
//     parameter BP_SIZE = 256,
//     parameter BP_INDEX_BITS = 8, 
//     parameter HIST_LEN = 16,
//     parameter CTR_BITS = 2
// ) (
//     input clk,
//     input rst,

//     // for reading BP
//     input [31:0] PC_query,  // PC in IF stage
//     input [HIST_LEN - 1:0] ghist,

//     // outputs read from BP
//     output reg [BP_INDEX_BITS - 1:0] index,
//     output reg BP_is_Branch_out, // is branch
//     output reg [31:0] BP_PC_target_out,

//     // for writing BP
//     input [31:0] IF_ID_PC,
//     input [6:0] IF_ID_OPcode, 
//     input IF_ID_dstall,
//     input [BP_INDEX_BITS - 1:0] IF_ID_index,

//     input [1:0] Branch,
//     input [31:0] IF_ID_PC_target

// );
//     // data BP
//     reg [CTR_BITS - 1:0] BP_ctr [0:BP_SIZE - 1];

//     // query BP
//     function [BP_INDEX_BITS - 1:0] hash;
//         input [31:0] pc;
//         input [HIST_LEN - 1:0] ghr;
        
//         reg [31:0] temp;
        
//         begin
//             temp = pc ^ {ghr, {32-HIST_LEN{1'b0}}};
//             temp = temp ^ (temp >> 16);
//             temp = temp ^ (temp >> 8);
//             hash = temp[BP_INDEX_BITS - 1:0];
//         end
//     endfunction

//     // readout (in F)
//     always @ (*) begin
//         index = hash(PC_query, ghist); 
//     end 

//     // write BP in (D)
//     integer i;
    
//     always @ (posedge clk or posedge rst) begin
//         if (rst) begin
//             for (i = 0; i < BP_SIZE; i = i + 1) begin
//                 BP_is_Branch[i] <= 0;
//                 BP_PC_target[i] <= 0;
//             end 
//         end else begin
//             // in: IF_ID_PC_out, Branch, IF_ID_PC_target, IF_ID_index
//             if (IF_ID_dstall == 0) begin // with this cond, there should be only one cyc in D writing BP
//                 BP_is_Branch[IF_ID_index] <= IF_ID_OPcode == 7'b1100011;
//                 BP_PC_target[IF_ID_index] <= IF_ID_PC_target;
//             end 
//         end 
//     end 

// endmodule
