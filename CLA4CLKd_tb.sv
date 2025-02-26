`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 02/25/2025 09:44:26 PM
// Design Name: Carry Look Ahead Adder with Pipeline Testbench
// Module Name: CLA4CLKd_tb
// Project Name: Activity 2
// Target Devices: That one Basys thing
// Tool Versions: Still a good question...
// Description: Activity 2 purpose is to perform slack analysis
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module CLA4CLKd_tb;
    logic clk, reset;
    logic [3:0] a_in, b_in;
    logic c_in;
    logic [3:0] s;
    logic c_out;

    // Instantiate the CLA4CLKd module
    CLA4CLKd dut (
        .clk(clk),
        .reset(reset),
        .a_in(a_in),
        .b_in(b_in),
        .c_in(c_in),
        .s(s),
        .c_out(c_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Generate a 10 ns clock period
    end

    // Test vectors and expected results
    typedef struct packed {
        logic [3:0] a, b;
        logic c;
        logic [3:0] expected_sum;
        logic expected_carry;
    } test_vector_t;

    test_vector_t test_vectors[] = {              // A + B + c_in 
        {4'b1010, 4'b0101, 1'b0, 4'b1111, 1'b0},  // 1010 + 0101 + 0 == 1111 c_out = 0 ∴ 0xA + 0x5 = 0xF
        {4'b1111, 4'b0001, 1'b1, 4'b0001, 1'b1},  // 1111 + 0001 + 1 == 0001 c_out = 1 ∴ 0xF + 0x1 = 0x1
        {4'b0000, 4'b1111, 1'b0, 4'b1111, 1'b0},  // 0000 + 1111 + 0 == 1111 c_out = 0 ∴ 0x0 + 0xF = 0xF
        {4'b1001, 4'b1001, 1'b1, 4'b0011, 1'b1}   // 1001 + 1001 + 1 == 0011 c_out = 1 ∴ 0x9 + 0x9 = 0x3
    };

    integer i;
    integer num_errors = 0;

    // Test execution
    initial begin
        reset = 1; // Assert reset
        #15;       // Hold reset for a short time
        reset = 0; // Deassert reset
        #10;       // Wait for reset effects

        for (i = 0; i < $size(test_vectors); i++) begin
            // Apply inputs
            a_in = test_vectors[i].a;
            b_in = test_vectors[i].b;
            c_in = test_vectors[i].c;
            #10; // Wait for the outputs to stabilize

            // Check outputs
            if (s !== test_vectors[i].expected_sum || c_out !== test_vectors[i].expected_carry) begin
                $display("Test %d failed: Expected sum=%b, carry=%b, got sum=%b, carry=%b", 
                    i, test_vectors[i].expected_sum, test_vectors[i].expected_carry, s, c_out);
                num_errors = num_errors + 1;
            end else begin
                $display("Test %d passed.", i);
            end

            #10; // Time between tests
        end

        // Final report
        if (num_errors == 0) begin
            $display("All tests passed.");
        end else begin
            $display("%d tests failed.", num_errors);
        end
        
        $finish; // End simulation
    end
endmodule
