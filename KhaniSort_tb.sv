module tb_fsm_sort;

    parameter int N = 6;
    parameter int WIDTH = 8;

    logic clk, rst, start;
    logic done;
    logic [WIDTH-1:0] data_in [N];
    logic [WIDTH-1:0] data_sorted [N];

    // Instantiate the module under test
    fsm_sort #(.N(N), .WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .done(done),
        .data_sorted(data_sorted)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Initial test procedure
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        start = 0;

        // Reset pulse
        #10;
        rst = 0;

        // Read input values from text file
        $display("Reading input values from test.txt...");
        $readmemb("test.txt", data_in); // Use $readmemh if using hex or decimal

        // Display inputs for verification
        for (int i = 0; i < N; i++) begin
            $display("data_in[%0d] = %0d", i, data_in[i]);
        end

        // Start the FSM
        #10;
        start = 1;
        #10;
        start = 0;

        // Wait for done
        wait (done == 1);

        // Show output
        $display("Sorted Output:");
        for (int i = 0; i < N; i++) begin
            $display("data_sorted[%0d] = %0d", i, data_sorted[i]);
        end

        #20;
        $finish;
    end

endmodule


