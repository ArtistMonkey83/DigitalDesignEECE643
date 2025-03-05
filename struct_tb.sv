`timescale 1ns/1ps

module testbench;
    // Inputs to the module
    logic clk, reset;
    // Outputs from the module
    logic a, b, c, y;

    // Instantiate the structural model
    structural_model MUT (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .c(c),
        .y(y)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Clock with period of 20 ns
    end

    // Reset behavior
    initial begin
        reset = 1;
        #15 reset = 0;  // Apply reset for 15 ns
    end

    // Test vectors and checking
    initial begin
        // Wait for reset release
        @(negedge reset);
        #5;  // Small delay after reset

        // Apply first test vector
        drive_and_check(0, 0);  // Test with c=0, b=0
        drive_and_check(0, 1);  // Test with c=0, b=1
        drive_and_check(1, 0);  // Test with c=1, b=0
        drive_and_check(1, 1);  // Test with c=1, b=1

        $finish;  // End simulation
    end

    // Task to drive inputs and check outputs
    task drive_and_check(logic test_c, logic test_b);
        begin
            // Drive inputs
            MUT.c = test_c;
            MUT.b = test_b;
            #10;  // Wait for logic to settle

            // Check outputs
            // Since your model is combinational in this context, we check immediately after settling time
            if (a !== ~(test_c | test_b) ||
                b !== ~(~(~test_c & ~a) & ~(~test_c)) ||
                c !== ~(a ^ ~test_b) ||
                y !== ~(~test_b & ~a)) begin
                $display("Test failed for c=%0b, b=%0b: Expected a=%b, b=%b, c=%b, y=%b, but got a=%b, b=%b, c=%b, y=%b",
                        test_c, test_b, ~(test_c | test_b), ~(~(~test_c & ~a) & ~(~test_c)), ~(a ^ ~test_b), ~(~test_b & ~a), a, b, c, y);
            end else begin
                $display("Test passed for c=%0b, b=%0b: a=%b, b=%b, c=%b, y=%b",
                        test_c, test_b, a, b, c, y);
            end
        end
    endtask

endmodule
