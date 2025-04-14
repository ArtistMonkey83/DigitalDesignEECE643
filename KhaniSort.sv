// FSM-based custom sort module with memory-based strip
module fsm_sort #(parameter N = 6, parameter WIDTH = 8)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [WIDTH-1:0] data_in[N],
    output logic done,
    output logic [WIDTH-1:0] data_sorted[N]
);

    typedef enum logic [2:0] {
        IDLE,
        CALC_WEIGHT,
        NORM_WEIGHT,
        PLACE_STRIP,
        COPY_OUTPUT,
        DONE
    } state_t;

    state_t state, next_state;

    int i, j;
    logic [$clog2(N)-1:0] idx;
    logic signed [WIDTH:0] weight[N];
    logic signed [WIDTH:0] norm_weight[N];
    logic [$clog2(N)-1:0] position[N];
    logic [WIDTH-1:0] strip [0:N-1][0:N-1]; // memory-based strip (each slot stores list)
    logic [2:0] strip_count [0:N-1];        // count of values per strip slot
    logic [WIDTH-1:0] temp_out [0:N-1];     // final output array
    logic [$clog2(N*N):0] out_ptr;

    // FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    always_comb begin
        case (state)
            IDLE:         next_state = (start) ? CALC_WEIGHT : IDLE;
            CALC_WEIGHT:  next_state = NORM_WEIGHT;
            NORM_WEIGHT:  next_state = PLACE_STRIP;
            PLACE_STRIP:  next_state = COPY_OUTPUT;
            COPY_OUTPUT:  next_state = DONE;
            DONE:         next_state = IDLE;
            default:      next_state = IDLE;
        endcase
    end

    // Registers
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < N; i++) begin
                weight[i] <= 0;
                norm_weight[i] <= 0;
                position[i] <= 0;
                strip_count[i] <= 0;
                for (j = 0; j < N; j++) begin
                    strip[i][j] <= '0;
                end
                temp_out[i] <= '0;
                data_sorted[i] <= '0;
            end
            out_ptr <= 0;
            done <= 0;
        end
        else begin
            case (state)
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
                            norm_weight[i] = (weight[i] + 1) >>> 1;
                        else
                            norm_weight[i] = weight[i] >>> 1;
                        position[i] = N/2 + norm_weight[i];
                        if (position[i] < 0) position[i] = 0;
                        if (position[i] >= N) position[i] = N - 1;
                    end
                end

                PLACE_STRIP: begin
                    for (i = 0; i < N; i++) begin
                        idx = strip_count[position[i]];
                        strip[position[i]][idx] = data_in[i];
                        strip_count[position[i]]++;
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
                    for (i = 0; i < N; i++) begin
                        data_sorted[i] <= temp_out[i];
                    end
                    // Clear strip and counts for next run
                    for (i = 0; i < N; i++) begin
                        strip_count[i] <= 0;
                        for (j = 0; j < N; j++) begin
                            strip[i][j] <= '0;
                        end
                    end
                end

                DONE: begin
                    done <= 1;
                end

                default: begin
                    done <= 0;
                end
            endcase
        end
    end
endmodule


  
