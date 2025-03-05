`timescale 1ns/1ps

module testbench;
    logic clk, reset;
    logic a, b, c, y;

    // Instantiate the dataflow model
    dataflow_model DUT (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .c(c),
        .y(y)
    );

    // Clock generation (if needed for timing tests)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset behavior
    initial begin
        reset = 1;
        #10 reset = 0;
    end

    // Test vectors and expected results
    initial begin
        @(negedge reset);
        #5; // Allow for reset propagation

        // Test different combinations
        test_logic(0, 0);
        test_logic(0, 1);
        test_logic(1, 0);
        test_logic(1, 1);

        $finish; // End simulation after tests
    end

    // Task to apply test vectors and check results
    task test_logic(input logic test_c, input logic test_b);
        begin
            DUT.c = test_c;
            DUT.b = test_b;
            #10; // Wait for propagation

            // Compute expected results
            logic exp_a = ~(test_c | test_b);
            logic exp_b = ~(~(~test_c & ~exp_a) & ~test_c);
            logic exp_c = ~(exp_a ^ ~test_b);
            logic exp_y = ~(~test_b & ~exp_a);

            // Check and display results
            if (a !== exp_a || b !== exp_b || c !== exp_c || y !== exp_y) begin
                $display("Failure for c=%0b, b=%0b: Expected a=%b, b=%b, c=%b, y=%b, Got a=%b, b=%b, c=%b, y=%b",
                         test_c, test_b, exp_a, exp_b, exp_c, exp_y, a, b, c, y);
            end else begin
                $display("Success for c=%0b, b=%0b: Correctly computed a=%b, b=%b, c=%b, y=%b",
                         test_c, test_b, a, b, c, y);
            end
        end
    endtask

endmodule
