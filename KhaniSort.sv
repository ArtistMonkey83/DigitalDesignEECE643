module custom_sort #(
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
    logic [WIDTH-1:0] overwrite_list[N];
    int overwrite_count;
    int i, j, pos;

    always_comb begin
        // Step 0: Clear all
        for (i = 0; i < N; i++) begin
            weight[i]         = 0;
            norm_weight[i]    = 0;
            position[i]       = 0;
            used[i]           = 0;
            strip[i]          = '0;
            overwrite_list[i] = '0;
        end
        overwrite_count = 0;

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

        // Step 2: Normalize weights
        for (i = 0; i < N; i++) begin
            if (weight[i] >= 0)
                norm_weight[i] = (weight[i]_
