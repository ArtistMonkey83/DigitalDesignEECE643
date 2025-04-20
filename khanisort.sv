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

    int i, j, pos, out_ptr, original_pos;
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
            DONE




