module tb_custom_sort;

    // Parameters
    parameter int N = 6;
    parameter int WIDTH = 8;

    // DUT I/O
    logic [WIDTH-1:0] data_in[N];
    logic [WIDTH-1:0] data_sorted[N];

    // Instantiate the sorting module
    custom_sort #(.N(N), .WIDTH(WIDTH)) dut (
        .data_in(data_in),
        .data_sorted(data_sorted)
    );

    // Task to print array contents
    task print_array(input string label, input logic [WIDTH-1:0] arr[N]);
        $display("%s", label);
        for (int i = 0; i < N; i++) begin
            $write("%0d ", arr[i]);
        end
        $display("\n");
    endtask

    initial begin
        // Test vector 1
        data_in = '{5, 0, 2, 1, 1, 3};
        #1; // Let always_comb evaluate
        print_array("Original Input:", data_in);
        print_array("Sorted Output :", data_sorted);

        // Test vector 2
        data_in = '{3, 2, 4, 0, 1, 5};
        #1;
        print_array("Original Input:", data_in);
        print_array("Sorted Output :", data_sorted);

        // Test vector 3 (repeated numbers)
        data_in = '{1, 1, 1, 1, 0, 2};
        #1;
        print_array("Original Input:", data_in);
        print_array("Sorted Output :", data_sorted);

        $finish;
    end

endmodule
