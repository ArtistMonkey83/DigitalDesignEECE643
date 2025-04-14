module custom_sort #(
    parameter int N = 6,
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] data_in[N],
    output logic [WIDTH-1:0] data_sorted[N]
);

    // Typedefs and declarations
    typedef int signed_weight_t;
    signed_weight_t weight[N];
    int adjusted_weight[N];
    int position[N];
    logic [WIDTH-1:0] strip[N];
    logic used[N];
    logic [WIDTH-1:0] overwritten[N];
    int overwrite_count;

    int i, j, pos, out_idx;

    always_comb begin
        // Init all
        for (i = 0; i < N; i++) begin
            weight[i]        = 0;
            adjusted_weight[i] = 0;
            position[i]      = 0;
            strip[i]         = '0;
            used[i]          = 0;
            overwritten[i]   = '0;
        end
        overwrite_count = 0;

        // Step 1: Calculate weight
        for (i = 0; i < N; i++) begin
            for (j = 0; j < N; j++) begin
                if (data_in[i] < data_in[j])
                    weight[i] -= 1;
                else if (data_in[i] > data_in[j])
                    weight[i] += 1;
                // equal → 0
            end
        end

        // Step 2: Adjust weight (divide by 2)
        for (i = 0; i < N; i++) begin
            if (weight[i] >= 0)
                adjusted_weight[i] = (weight[i] + 1) >>> 1; // ceil
            else
                adjusted_weight[i] = weight[i] >>> 1;        // floor
        end

        // Step 3: Assign to strip using origin
        for (i = 0; i < N; i++) begin
            pos = (N >> 1) + adjusted_weight[i]; // origin = N/2
            if (pos < 0) pos = 0;
            if (pos >= N) pos = N - 1;

            if (!used[pos]) begin
                strip[pos] = data_in[i];
                used[pos] = 1;
            end else begin
                // Overwrite case
                overwritten[overwrite_count] = data_in[i];
                overwrite_count++;
            end
        end

        // Step 4: Assemble output array
        out_idx = 0;
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
