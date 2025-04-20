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
        RANK_SORT,
        COPY_OUTPUT,
        WRITE_BACK,
        DONE
    } state_t;

    state_t state, next_state;

    int i, j, out_ptr;
    logic [WIDTH-1:0] strip[N][N];
    int strip_count[N];
    logic [WIDTH-1:0] temp_out[N];

    logic start_d, start_rising;

    // Edge detection for 'start' signal
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            start_d <= 0;
        else
            start_d <= start;
    end

    assign start_rising = start & ~start_d;

    // State transition
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        case (state)
            IDLE:        next_state = start_rising ? INIT : IDLE;
            INIT:        next_state = RANK_SORT;
            RANK_SORT:   next_state = COPY_OUTPUT;
            COPY_OUTPUT: next_state = WRITE_BACK;
            WRITE_BACK:  next_state = DONE;
            DONE:        next_state = IDLE;
            default:     next_state = IDLE;
        endcase
    end

    // Main FSM logic
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
                        for (j = 0; j < N; j++)
                            strip[i][j] = 0;
                    end
                end

                RANK_SORT: begin
                    for (i = 0; i < N; i++) begin
                        int rank = 0;
                        for (j = 0; j < N; j++) begin
                            if (data_in[j] < data_in[i])
                                rank++;
                        end

                        // Resolve duplicates by shifting forward
                        int pos = rank;
                        while (pos < N && strip_count[pos] != 0)
                            pos++;

                        // Fallback if forward positions are full
                        if (pos >= N) begin
                            pos = N - 1;
                            while (pos >= 0 && strip_count[pos] != 0)
                                pos--;
                        end

                        strip[pos][0] = data_in[i];
                        strip_count[pos] = 1;
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



