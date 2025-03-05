module testbench;
    // Testbench signals
    logic clk, reset;
    logic a, b, c, y;

    // Instantiate the module under test
    behavioral_model UUT (
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
        forever #5 clk = ~clk;  // Generate a clock with 10 time units period
    end

    // Apply stimulus and check results
    initial begin
        // Initialize all signals
        reset = 1;
        #10;  // Assert reset for a short time
        reset = 0;

        // Test Vector 1
        #10;  // Wait for one clock cycle after reset
        // Checking initial conditions (after reset, expect all zeros)
        check_outputs(0, 0, 0, 1);

        // Test Vector 2
        #10;  // Wait for one clock cycle
        // Force some values to check behavior
        force UUT.a = 1;
        force UUT.b = 1;
        release UUT.a;
        release UUT.b;
        #10;  // Allow changes to propagate
        check_outputs(1, 1, 1, 0);

        // Test Vector 3
        force UUT.b = 0;
        #10;
        check_outputs(0, 0, 1, 1);

        // Conclude the test
        #10;
        $display("All tests completed.");
        $finish;
    end

    // Task to check outputs against expected values
    task check_outputs(logic exp_a, logic exp_b, logic exp_c, logic exp_y);
        if ((a === exp_a) && (b === exp_b) && (c === exp_c) && (y === exp_y)) begin
            $display("Test passed at time %0t: a=%0b, b=%0b, c=%0b, y=%0b", $time, a, b, c, y);
        end else begin
            $display("Test failed at time %0t: Expected a=%0b, b=%0b, c=%0b, y=%0b but got a=%0b, b=%0b, c=%0b, y=%0b",
                     $time, exp_a, exp_b, exp_c, exp_y, a, b, c, y);
            $finish;
        end
    endtask
endmodule
