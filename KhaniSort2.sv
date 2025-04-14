module KhaniSort #(
    parameter int N = 6,
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] data_in[N],
    output logic [WIDTH-1:0] data_sorted[N]
);

    // Internal temporary variables
    typedef int signed_weight_t;
    signed_weight_t weight[N];
    signed_weight_t weight_div2[N];
    int             positions[N];       // Final index on strip
    int             used_count[N];      // Tracks if index is occupied
    logic [WIDTH-1:0] strip[N];
    int idx, i, j;

    always_comb begin
        // Initialize
        for (i = 0; i < N; i++) begin
            weight[i]       = 0;
            used_count[i]   = 0;
            strip[i]        = '0;
        end

        // Step 1: Weight calculation
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

        // Step 2: Normalize weights and get positions
        for (i = 0; i < N; i++) begin
            if (weight[i] >= 0)
                weight_div2[i] = (weight[i] + 1) >>> 1;  // Ceil
            else
                weight_div2[i] = weight[i] >>> 1;        // Floor

            // Clamp to 0..N-1 (strip index)
            positions[i] = weight_div2[i] + (N >> 1); // Centered origin
            if (positions[i] < 0)
                positions[i] = 0;
            else if (positions[i] >= N)
                positions[i] = N - 1;
        end

        // Step 3: Place on strip, resolve overwrite by shifting
        for (i = 0; i < N; i++) begin
            idx = positions[i];
            // Find next free position to the right
            while (idx < N && used_count[idx] != 0)
                idx++;
            if (idx < N) begin
                strip[idx] = data_in[i];
                used_count[idx] = 1;
            end
            else begin
                // Store as overflow to be handled separately
                // Append at end (simple method)
                for (j = 0; j < N; j++) begin
                    if (used_count[j] == 0) begin
                        strip[j] = data_in[i];
                        used_count[j] = 1;
                        break;
                    end
                end
            end
        end

        // Final output
        for (i = 0; i < N; i++) begin
            data_sorted[i] = strip[i];
        end
    end
endmodule
