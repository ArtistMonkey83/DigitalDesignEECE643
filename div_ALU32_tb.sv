`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University,Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/02/2025 11:20:26 PM
// Design Name: 32-bit Division ALU module with ready bit and clock
// Module Name: divALU32_t
// Project Name: Homework 0
// Target Devices: That one Basys thing
// Tool Versions: After all this time still a good question...
// Description: Homework 0 purpose is to perform timing and slack analysis
// 
// Dependencies: Electricity, generated from combusting long dead conifers and dinosaurs 
//               or if we are lucky provided by Ehecatl and/or Xiuhcoatl
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divALU32_tb;
    logic clk, reset, ready;
    logic [31:0] dividend_in, divisor_in, quotient_out, remainder_out;
    
    divALU32 dut(
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .dividend_in(dividend_in),
        .divisor_in(divisor_in),
        .quotient_out(quotient_out),
        .remainder_out(remainder_out)
    );
    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    typedef struct packed{
        logic [31:0] dividend_in, divisor_in, quotient_out, remainder_out;
    } test_vector_t;
    
    // Convention for the test vector: {dividend, divisor, quotient, remainder}
    test_vector_t test_vectors[] = {       
    {32'd10,32'd3,32'd3,32'd1},
    {32'd100,32'd5,32'd20,32'd0},
    {32'd30,32'd4,32'd7,32'd2},
    {32'd256,32'd8,32'd32,32'd0},
    {32'd10,32'd10,32'd1,32'd0},
    {32'd10,32'd2,32'd5,32'd0},
    {32'd9,32'd3,32'd3,32'd0},
    {32'd40,32'd2,32'd20,32'd0},
    {32'd1024,32'd2,32'd10,32'd0},
    {32'd8,32'd3,32'd2,32'd0}
    };   
    
endmodule
