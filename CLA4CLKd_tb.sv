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
module CLA4CLKd_tb;
    logic clk, reset;
    logic [3:0] a_in, b_in;
    logic c_in;
    logic [3:0] s;
    logic c_out;

    CLA4CLKd dut (             // Instantiate the CLA4CLKd module
        .clk(clk),
        .reset(reset),
        .a_in(a_in),
        .b_in(b_in),
        .c_in(c_in),
        .s(s),
        .c_out(c_out)
    );

    initial begin              // Clock generation
        clk = 1;
        forever #5 clk = ~clk; // Generated a 10 ns clock period
    end

    typedef struct packed {    // Test vectors and expected results are a contiguous block of memory using packed keyword!
        logic [3:0] a, b;
        logic c;
        logic [3:0] expected_sum;
        logic expected_carry;
    } test_vector_t;

    test_vector_t test_vectors[] = {              // Convention for test vector: A + B + c_in expected results: Sum, C_out
        {4'b1010, 4'b0101, 1'b0, 4'b1111, 1'b0},  // 1010 + 0101 + 0 == 1111 c_out = 0 ∴ 0xA + 0x5 = 0xF
        {4'b1111, 4'b0001, 1'b1, 4'b0001, 1'b1},  // 1111 + 0001 + 1 == 0001 c_out = 1 ∴ 0xF + 0x1 = 0x1
        {4'b0000, 4'b1111, 1'b0, 4'b1111, 1'b0},  // 0000 + 1111 + 0 == 1111 c_out = 0 ∴ 0x0 + 0xF = 0xF
        {4'b1001, 4'b1001, 1'b1, 4'b0011, 1'b1}   // 1001 + 1001 + 1 == 0011 c_out = 1 ∴ 0x9 + 0x9 = 0x3
    };

    integer i;              // To be used in for loops associated with test vector element accessing 
    integer num_errors = 0; // To accumulate the number of errors generated for the self-checking testbench

    initial begin  // Self-checking test execution
        reset = 1; // Assert reset, all registers are initialized to 0s!
        #15;       // Hold reset for a short time
        reset = 0; // Not in reset mode, everything is initialized to 0s!
        #10;       // Wait for a short time

        for (i = 0; i < $size(test_vectors); i++) begin     // Iterate through the size of the test vector to compute each test
            a_in = test_vectors[i].a;                       // Assign the .a member variable of the current test vector to a_in input logic
            b_in = test_vectors[i].b;                       // Assign the .b member variable of the current test vector to b_in input logic
            c_in = test_vectors[i].c;                       // Assign the .c member variable of the current test vector to c_in input logic
            #10;                                            // Wait for the outputs to stabilize

                    // Check outputs for the currect test, %d is decimal form of ith test, %b is binary form 
            if (s !== test_vectors[i].expected_sum || c_out !== test_vectors[i].expected_carry) begin   // Check if sum and carry out are correct!
                $display("Test %d failed: Expected sum=%b, carry=%b, got sum=%b, carry=%b", 
                    i, test_vectors[i].expected_sum, test_vectors[i].expected_carry, s, c_out);         // Executed if incorrect sum and carry out are returned
                num_errors = num_errors + 1;                                                            // Accumulate the number of failed tests
            end else begin
                $display("Test %d passed.", i);                                                         // Executed if all tests are passed!
            end
            #10;                                                                                        // Hold time between tests
        end

        if (num_errors == 0) begin                               // Final report for self-checking testbench
            $display("All tests passed.\_(^.^)_/");              // If there were no errors display TOUCHDOWN!
        end else begin
            $display("%d tests failed.¯\_(ツ)_/¯", num_errors); //If there were errors display shrug... and the number of errors
        end
        $finish;                                                // End simulation
    end
endmodule
