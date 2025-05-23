
module Branch_Predictor (
    input [31:0] PC,
    input [HIST_LEN - 1:0] ghist,

    // from BTB
    input BTB_is_branch,

    output reg branch_pred, // T or NT, 1 bit
    output reg [31:0] PC_pred

);
    // all is called in F stage

    parameter TAG_BITS = 12;
    parameter INDEX_BITS = 10;
    parameter HIST_LEN = 16;

    function [TAG_BITS+9:0] hash_function;
        input [31:0] pc;
        input [HIST_LEN-1:0] hist;
        begin
            hash_function = (pc ^ {hist, {32-HIST_LEN{1'b0}}}) % 1024;
        end
    endfunction

    // tag, index for TAGE predictor tables, 2**INDEX_BITS entries
    reg [TAG_BITS - 1:0] tag;
    reg [INDEX_BITS - 1:0] index  
    assign {tag, index} = hash_function(PC, ghist);

    // if BTB thinks this PC's inst is a branch inst, BTB predicts PC_tar
    if (BTB_is_branch) begin
        // use tag & index to access TAGE tables, and get the branch prediction of T/NT
        // branch_pred

        // get PC_tar from BTB
        // BTB_PC_tar

        // prediction: T -> BTB_PC_tar, NT -> PC + 4
        // PC_pred
    end else begin
        PC_pred = PC + 4;
    end 
endmodule


// regs for TAGE
module Global_History(
    input clk,
    input rst,
    input [31:0] PC,
    input [6:0] OPcode,
    input [1:0] branch,

    input is_branch, // BTB_is_branch[PC_last_bits]
    
    output reg [HIST_LEN - 1:0] ghist
);
    parameter HIST_LEN = 16;

    // ghist reg
    reg [HIST_LEN - 1:0] ghist;

    // update ghist, when a branch is resolved (T / NT) in (the last cycle of) D stage
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            // init
            ghist <= 0;
        end else begin
            // if PC's inst is a branch inst
            if (OPcode == 7'b1100011) begin
                ghist <= ghist << 1;
                ghist[0] <= branch[1];
            end
        end 
    end 
endmodule


module Branch_Target_Buffer(
    input clk,
    input rst,
    input [31:0] PC,  // IF_ID_PC
    input [6:0] OPcode, // IF_ID_OPcode

    // ground truths, when the branch is really resolved
    input is_branch_GT, // not used
    input [31:0] PC_tar_GT,

    // outputs from BTB
    output reg is_branch, // PC is branch
    output reg [31:0] PC_tar
);
    parameter BTB_SIZE = 1024;
    parameter BTB_INDEX_BITS = 10; // 2**10 == 1024

    // the BTB data structure is {PC: (is_branch, PC_tar)}
    reg BTB_is_branch[BTB_SIZE - 1:0];
    reg [31:0] BTB_PC_tar[BTB_SIZE - 1:0];

    // ****** BTB read (in F stage) ******
    // if PC's inst is a branch inst
    // branch: OPcode == 7'b1100011
    reg is_branch;
    reg PC_BTB_index;
    assign PC_BTB_index = PC[BTB_INDEX_BITS - 1:0]; // last bits of PC
    assign is_branch = (BTB_is_branch[PC_BTB_index] != 0 && OPcode == 7'b1100011);

    // PC_tar
    reg [31:0] PC_tar;
    assign PC_tar = BTB_PC_tar[PC_BTB_index];

    // ****** BTB write (in D stage) ******
    // update brach target buffer (BTB), when the target PC (e.g. PC + imm) is computed in (the first cycle of) D stage 
    integer i;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            // init
            for (i=0; i<BTB_SIZE; i+=1) begin
                BTB_is_branch[i] <= 0;
                BTB_PC_tar[i] <= 0;
            end 
        end else begin
            // update 
            if (OPcode == 7'b1100011) begin
                BTB_is_branch[PC_BTB_index] <= 1;
                BTB_PC_tar[PC_BTB_index] <= PC_tar_GT;
            end 
        end 
    end 
endmodule


module TAGE_States(
    input clk,
    input rst,

    output reg
);
    
    parameter

    // (tag, ctr, u) * N     
    reg

    // update TAGE states: predictor states (a.k.a. counters), useful bits
    always @ (posedge clk or posedge rst) begin

    end 


endmodule



module Flusher(
    input [31:0] PC,    // current inst's PC, IF_ID_PC
    input [31:0] PC_tar,
    input [31:0] PC_pred,
    input [1:0] branch, // T or NT
);
    // Mis-predict recovery
    
    // flush a wrong prefetched instruction (always the next one), when branch & target PC are resolved in the last cycle of D stage
    // flush it by setting cstall signal to 1. 
    //      assign cstall = (PC_tar != PC_pred)
    //      @ posedge clk, IF/ID pipeline buffer is reset, the next prefetched inst does not enter D stage, and the resolved tar PC is in the F stage.
endmodule
