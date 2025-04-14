module KhaniSort #(
    parameter int N = 6,
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] data_in[N],
    output logic [WIDTH-1:0] data_sorted[N]
);

    typedef int signed_weight_t;

    signed_weight_t weight[N];
    signed_weight_t adjusted[N];
    int             position[N];
    int i, j, pos, idx, out_idx;

    // 2D strip: each index holds up to N values
    logic [WIDTH-1:0] strip[N][N];
    int strip_count[N];

    always_comb begin
        // Init all
        for (i = 0; i < N; i++) begin
            weight[i] = 0;
            adjusted[i] = 0;
            position[i] = 0;
            strip_count[i] = 0;
            for (j = 0; j < N; j++) begin
                strip[i][j] = '0;
            end
        end

        // Step 1: Compute weights
        for (i = 0; i < N; i++) begin
            for (j = 0; j < N; j++) begin
                if (data_in[i] < data_in[j])
                    weight[i] -= 1;
                else if (data_in[i] > data_in[j])
                    weight[i] += 1;
            end
        end

        // Step 2: Normalize weights
        for (i = 0; i < N; i++) begin
            if (weight[i] >= 0)
                adjusted[i] = (weight[i] + 1) >>> 1; // ceil
            else
                adjusted[i] = weight[i] >>> 1;        // floor
        end

        // Step 3: Map to position and insert into strip
        for (i = 0; i < N; i++) begin
            pos = (N >> 1) + adjusted[i]; // origin-centered
            if (pos < 0) pos = 0;
            if (pos >= N) pos = N - 1;

            idx = strip_count[pos];
            strip[pos][idx] = data_in[i];
            strip_count[pos]++;
        end

        // Step 4: Flatten strip left-to-right into sorted output
        for (i = 0; i < N; i++) begin
            for (j = 0; j < strip_count[i]; j++) begin
                data_sorted[out_idx] = strip[i][j];
                out_idx++;
            end
        end
    end

endmodule
