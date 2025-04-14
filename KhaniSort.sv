module KhaniSort #(
    parameter int N = 6,
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] data_in[N],
    output logic [WIDTH-1:0] data_sorted[N]
);

    typedef int signed_weight_t;
    signed_weight_t weight[N];
    signed_weight_t norm_weight[N];
    int final_pos[N];
    int write_count[N];  // overwrite tracker
    logic [WIDTH-1:0] strip_temp[N];
    int i, j;

    always_comb begin
        // Step 1: init
        for (i = 0; i < N; i++) begin
            weight[i]      = 0;
            norm_weight[i] = 0;
            final_pos[i]   = 0;
            write_count[i] = 0;
            strip_temp[i]  = '0;
        end

        // Step 2: compute weights
        for (i = 0; i < N; i++) begin
            for (j = 0; j < N; j++) begin
                if (i != j) begin
                    if (data_in[i] < data_in[j])
                        weight[i] -= 1;
                    else if (data_in[i] > data_in[j])
                        weight[i] += 1;
                end
            end
        end

        // Step 3: normalize weights (ceil/floor)
        for (i = 0; i < N; i++) begin
            if (weight[i] >= 0)
                norm_weight[i] = (weight[i] + 1) >>> 1; // ceil
            else
                norm_weight[i] = weight[i] >>> 1;        // floor
        end

        // Step 4: write to strip
        int placed = 0;
        for (i = 0; i < N; i++) begin
            int pos = (N / 2) + norm_weight[i];
            if (pos < 0) pos = 0;
            if (pos >= N) pos = N - 1;

            // If slot taken, shift right to next free
            while (pos < N && write_count[pos] != 0)
                pos++;

            if (pos < N) begin
                strip_temp[pos] = data_in[i];
                write_count[pos]++;
            end else begin
                // If no slot, start from left and find first free
                for (j = 0; j < N; j++) begin
                    if (write_count[j] == 0) begin
                        strip_temp[j] = data_in[i];
                        write_count[j]++;
                        break;
                    end
                end
            end
        end

        // Step 5: Copy to output
        for (i = 0; i < N; i++) begin
            data_sorted[i] = strip_temp[i];
        end
    end

endmodule

  
