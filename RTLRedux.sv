`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/16/2025 05:01:05 PM
// Design Name: 
// Module Name: RTL_model
// Project Name: Activity 3
// Target Devices: 
// Tool Versions: 
// Description: RTL Model of the circuit for Activity 3
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RTL_model(
    input logic clk,
    input logic reset,
    output logic y
    );
    
logic a, b, c, S0, S1, S2;       // Internal signals

always_ff @( posedge clk or posedge reset)begin
    if(reset)begin 
        {S0, S1, S2} <= 3'b000;  
    end else begin
        {S0, S1, S2} <= {( ~(S0 ^ (~S1))), (~((~S0) & (~S2))), (~(S1 | S2))};
        {S0, S1, S2} <= {(~(S1 | S2)), (~((~S0) & (~S2))), ( ~(S0 ^ (~S1)))};
    end
end

assign y = { ~((~S0) | (~S1))};
assign {a, b, c} = {S0, S1, S2};
    
endmodule
