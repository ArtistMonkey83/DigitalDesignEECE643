`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 06:53:20 PM
// Design Name: 
// Module Name: divYR_tb
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


module divYR_tb;
    logic clk, reset, ready;
    logic [31:0] dividend_in, divisor_in, quotient_out, remainder_out;
    
    divYR dut(
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
    
    initial begin
        reset = 1;
        #10 reset = 0;
        for (int i = 0; i <$size(test_vectors); i++)begin
            dividend_in = test_vectors[i].dividend_in;
            divisor_in = test_vectors[i].divisor_in;
            @(posedge clk);
            #1
            
            if (quotient_out != text_vectors[i].quotient_out || remainder_out != test_vectors[i].remainder_out) begin
                $display("Mismatch found on vector %d",i)
            else 
                    $display("Test vector %d passed",i)
            end
endmodule