`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/12 08:45:29
// Design Name: 
// Module Name: Control_Stall
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


module Control_Stall(
        input [1:0] Branch,
        // output reg IF_ID_cstall

        output reg PC_dstall,
        output reg IF_ID_dstall,
        output reg ID_EXE_dstall      
    );
    always @ (*) begin
        // IF_ID_cstall = 1'b0;

                PC_dstall = 0;
                IF_ID_dstall = 0;
                // ID_EXE_dstall = 1;
        if (Branch[1:0] != 2'b00) begin
            // IF_ID_cstall = 1'b1;

                PC_dstall = 1;
                IF_ID_dstall = 1;
                // ID_EXE_dstall = 1;
        end
    end
endmodule
