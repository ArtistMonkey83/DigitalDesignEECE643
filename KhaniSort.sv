module custom_sort #(
    parameter int N = 6,
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] data_in[N],
    output logic [WIDTH-1:0] data_sorted[N]
);

    // Internal weights and position arrays
    logic signed [$clog2(N*N):0] weights[N];      // Allow large enough size for sum of ±(N-1)
    logic signed [$clog2(N*N):0] new_weights[N];
    logic [$clog2(N)-1:0]        final_pos[N];
    logic [WIDTH-1:0]            strip[N];        // Output strip (temp)
    int                          overwrite_count[N];
    int                          i, j;

    // Step 1: Calculate weights
    always_comb begin
        // Initialize everything
        for (i = 0; i < N; i++) begin
            weights[i] = 0;
            overwrite_count[i] = 0;
        end

        // Weight calculation: compare data_in[i] to all others
        for (i = 0; i < N; i++) begin
            for (j = 0; j < N; j++) begin
                if (i != j) begin
                    if (data_in[i] < data_in[j])
                        weights[i] -= 1;
                    else if (data_in[i] > data_in[j])
                        weights[i] += 1;
                end
            end
        end

        // Step 2: Divide by 2 and round
        for (i = 0; i < N; i++) begin
            if (weights[i] >= 0)
                new_weights[i] = (weights[i] + 1) >>> 1;  // Ceil for positive
            else
                new_weights[i] = weights[i] >>> 1;        // Floor for negative

            // Clamp to [0, N-1]
            if (new_weights[i] < 0)
                final_pos[i] = 0;
            else if (new_weights[i] >= N)
                final_pos[i] = N-1;
            else
                final_pos[i] = new_weights[i];
        end

        // Step 3: Place elements onto the strip and count overwrites
        for (i = 0; i < N; i++) begin
            if (overwrite_count[final_pos[i]] == 0)
                strip[final_pos[i]] = data_in[i];
            else begin
                // Find next available space to right
                int k = final_pos[i] + 1;
                while (k < N && overwrite_count[k] != 0)
                    k++;
                if (k < N) begin
                    strip[k] = data_in[i];
                    overwrite_count[k]++;
                end
            end
            overwrite_count[final_pos[i]]++;
        end

        // Step 4: Output strip as sorted result
        for (i = 0; i < N; i++)
            data_sorted[i] = strip[i];
    end

endmodule
