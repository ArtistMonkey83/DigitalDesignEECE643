module tb_fsm_sort;

    parameter int N = 6;
    parameter int WIDTH = 8;

    logic clk, rst, start;
    logic [WIDTH-1:0] data_in[N];
    logic done;
    logic [WIDTH-1:0] data_sorted[N];

    // Instantiate the sort module
    fsm_sort #(.N(N), .WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .done(done),
        .data_sorted(data_sorted)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to pulse start
    task pulse_start;
        begin
            start = 1;
            @(posedge clk);
            start = 0;
        end
    endtask

    // Task to wait for done
    task wait_done;
        begin
            @(posedge clk);
            while (!done) @(posedge clk);
        end
    endtask

    // Task to display output
    task show_output(input string label);
        begin
            $display("%s", label);
            for (int i = 0; i < N; i++) begin
                $write("%0d ", data_sorted[i]);
            end
            $display("\n");
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        @(posedge clk);
        rst = 0;

        // Test 1: 5, 0, 2, 1, 1, 3 → Expected sorted: 0 1 1 2 3 5
        data_in = '{5, 0, 2, 1, 1, 3};
        pulse_start();
        wait_done();
        show_output("Test 1 Output:");

        // Test 2: 3, 2, 4, 0, 1, 5 → Expected sorted: 0 1 2 3 4 5
        data_in = '{3, 2, 4, 0, 1, 5};
        pulse_start();
        wait_done();
        show_output("Test 2 Output:");

        // Test 3: 1, 1, 1, 0, 2, x → Pad with zero (x = 0)
        data_in = '{1, 1, 1, 0, 2, 0};
        pulse_start();
        wait_done();
        show_output("Test 3 Output:");

        $finish;
    end

endmodule

