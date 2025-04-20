module tb_fsm_sort;

    parameter int N = 6;            // Number of elements to sort
    parameter int WIDTH = 8;

    logic clk, rst, start;
    logic [WIDTH-1:0] data_in[N];
    logic done;
    logic [WIDTH-1:0] data_sorted[N];

    fsm_sort #(.N(N), .WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .done(done),
        .data_sorted(data_sorted)
    );

    always #5 clk = ~clk;

    task pulse_start;
        @(negedge clk);
        start = 1;
        @(negedge clk);
        start = 0;
    endtask

    task wait_done;
        do @(posedge clk); while (!done);
    endtask

    task show_output(input string label);
        $display("%s", label);
        for (int i = 0; i < N; i++)
            $write("%0d ", data_sorted[i]);
        $display("\n");
    endtask

    initial begin
        clk = 0; rst = 1; start = 0;
        @(negedge clk); rst = 0;

        // Test 1
        data_in = '{5, 0, 2, 1, 1, 3};
        pulse_start();
        wait_done();
        show_output("Test 1 Output:");

        // Test 2
        data_in = '{3, 2, 4, 0, 1, 5};
        pulse_start();
        wait_done();
        show_output("Test 2 Output:");

        // Test 3
        data_in = '{1, 1, 1, 0, 2, 0};
        pulse_start();
        wait_done();
        show_output("Test 3 Output:");

        $finish;
    end
endmodule

