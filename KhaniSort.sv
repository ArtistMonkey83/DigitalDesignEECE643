module fsm_sort #(
    parameter int N = 6,
    parameter int WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [WIDTH-1:0] data_in[N],
    output logic done,
    output logic [WIDTH-1:0] data_sorted[N]
);

    typedef enum logic [2:0] {
        IDLE,
        INIT,
        CALC_WEIGHT,
        NORM_WEIGHT,
        PLACE_STRIP,
        COPY_OUTPUT,
        WRITE_BACK,
        DONE
    } state_t;

    state_t state, next_state;

    int i, j, pos, out_ptr;
    logic [WIDTH-1:0] strip[N][N];
    int strip_count[N];
    int weight[N];
    int weight_div2[N];
    logic [WIDTH-1:0] temp_out[N];

    logic start_d, start_rising;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            start_d <= 0;
        else
            start_d <= start;
    end

    assign start_rising = start & ~start_d;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        case (state)
            IDLE:         next_state = start_rising ? INIT : IDLE;
            INIT:         next_state = CALC_WEIGHT;
            CALC_WEIGHT:  next_state = NORM_WEIGHT;
            NORM_WEIGHT:  next_state = PLACE_STRIP;
            PLACE_STRIP:  next_state = COPY_OUTPUT;
            COPY_OUTPUT:  next_state = WRITE_BACK;
            WRITE_BACK:   next_state = DONE;
            DONE:         next_state = IDLE;
            default:      next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            for (i = 0; i < N; i++)
                data_sorted[i] <= 0;
        end else begin
            case (state)

                IDLE: done <= 0;

                INIT: begin
                    for (i = 0; i < N; i++) begin
                        strip_count[i] = 0;
                        weight[i] = 0;
                        weight_div2[i] = 0;
                        for (j = 0; j < N; j++)
                            strip[i][j] = 0;
                    end
                end

                CALC_WEIGHT: begin
                    for (i = 0; i < N; i++) begin
                        weight[i] = 0;
                        for (j = 0; j < N; j++) begin
                            if (data_in[i] < data_in[j])
                                weight[i] -= 1;
                            else if (data_in[i] > data_in[j])
                                weight[i] += 1;
                        end
                    end
                end

                NORM_WEIGHT: begin
                    for (i = 0; i < N; i++) begin
                        if (weight[i] >= 0)
                            weight_div2[i] = (weight[i] + 1) >>> 1;
                        else
                            weight_div2[i] = weight[i] >>> 1;
                    end
                end
                
                PLACE_STRIP: begin
                     for (i = 0; i < N; i++) begin
                             pos = (N >> 1) + weight_div2[i];
                             if (pos < 0) pos = 0;
                             else if (pos >= N) pos = N - 1;

        // Find correct placement considering ordering
           int insert_pos = pos;

        // Move right if new number is greater
        while (insert_pos < N && strip_count[insert_pos] != 0 && data_in[i] > strip[insert_pos][0]) 
            insert_pos++;

        // Move left if new number is smaller or equal
        while (insert_pos > 0 && strip_count[insert_pos] != 0 && data_in[i] <= strip[insert_pos][0]) 
            insert_pos--;

        // If landed on occupied position after move left, shift larger elements right
        if (strip_count[insert_pos] != 0 && data_in[i] <= strip[insert_pos][0]) begin
            int shift_pos = insert_pos;
            // Find right-most free slot
            while (shift_pos < N && strip_count[shift_pos] != 0) shift_pos++;
            // Shift elements rightward
            for (int k = shift_pos; k > insert_pos; k--) begin
                strip[k][0] = strip[k-1][0];
                strip_count[k] = strip_count[k-1];
            end
            strip_count[insert_pos] = 0; // make space
        end

        // Place the number correctly
        strip[insert_pos][0] = data_in[i];
        strip_count[insert_pos] = 1;
    end
end


                COPY_OUTPUT: begin
                    out_ptr = 0;
                    for (i = 0; i < N; i++) begin
                        for (j = 0; j < strip_count[i]; j++) begin
                            temp_out[out_ptr] = strip[i][j];
                            out_ptr++;
                        end
                    end

                    // Fill any remaining output slots explicitly with zero
                    for (; out_ptr < N; out_ptr++) begin
                        temp_out[out_ptr] = 0;
                    end
                end

                WRITE_BACK: begin
                    for (i = 0; i < N; i++)
                        data_sorted[i] <= temp_out[i];
                end

                DONE: done <= 1;

            endcase
        end
    end

endmodule



