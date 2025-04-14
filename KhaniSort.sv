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
    int position[N];
    int used[N];
    logic [WIDTH-1:0] strip[N];
    logic [WIDTH-1:0] overwritten[N];
    int overwrite_count;

    int i, j, pos;

    always_comb begin
        // Initialization
        for (i = 0; i < N; i++) begin
            weight[i]        = 0;
            norm_weight[i]   = 0;
            position[i]      = 0;
            used[i]          = 0;
            strip[i]         = '0;
            overwritten[i]   = '0;
        end
        overwrite_count = 0;

        // Step 1: Compute weights (including self)
        for (i = 0; i < N; i++) begin
            for (j = 0; j < N; j++) begin
                if (data_in[i] < data_in[j])
                    weight[i] -= 1;
                else if (data_in[i] > data_in[j])
                    weight[i] += 1;
            end
        end

        // Step 2: Normalize weight and assign strip positions
        for (i = 0; i < N; i++) begin
            if (weight[i] >= 0)
                norm_weight[i] = (weight[i] + 1) >>> 1; // ceil
            else
                norm_weight[i] = weight[i] >>> 1;        // floor

            // Calculate position relative to origin (origin = N/2)
            position[i] = (N >> 1) + norm_weight[i];
            if (position[i] < 0) position[i] = 0;
            if (position[i] >= N) position[i] = N - 1;
        end

        // Step 3: Write to strip or track overwrites
        for (i = 0; i < N; i++) begin
            pos = position[i];
            if (used[pos] == 0) begin
                strip[pos] = data_in[i];
                used[pos] = 1;
            end else begin
                // Already taken: save overwritten number
                overwritten[overwrite_count] = data_in[i];
                overwrite_count++;
            end
        end

        // Step 4: Merge strip and overwritten values into output
        int out_idx = 0;
        for (i = 0; i < N; i++) begin
            if (used[i]) begin
                data_sorted[out_idx] = strip[i];
                out_idx++;
            end
        end
        for (i = 0; i < overwrite_count; i++) begin
            if (out_idx < N) begin
                data_sorted[out_idx] = overwritten[i];
                out_idx++;
            end
        end
    end
endmodule

