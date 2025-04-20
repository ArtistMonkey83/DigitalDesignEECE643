// FSM-based Sorting Module
// Parameters:
// - N: Number of input data elements
// - WIDTH: Bit-width of each data element
module fsm_sort #(
    parameter int N = 6,
    parameter int WIDTH = 8
)(
    input  logic clk,                      // Clock input
    input  logic rst,                      // Asynchronous reset
    input  logic start,                    // Start signal to initiate sorting
    input  logic [WIDTH-1:0] data_in[N],   // Array of N input values to sort
    output logic done,                     // Done signal goes high after sorting is complete
    output logic [WIDTH-1:0] data_sorted[N]// Output array of sorted values
);

    // FSM state declaration using a typedef enum
    typedef enum logic [2:0] {
        IDLE,         // Waiting for the start signal
        INIT,         // Initialize internal structures
        CALC_WEIGHT,  // Calculate weights for sorting
        NORM_WEIGHT,  // Normalize the weights
        PLACE_STRIP,  // Place elements into strip structure based on weights
        COPY_OUTPUT,  // Copy values from strip to temporary output
        WRITE_BACK,   // Write temporary output to final output
        DONE          // Indicate completion
    } state_t;

    // FSM state variables
    state_t state, next_state;

    // Index and utility variables
    int i, j, pos, out_ptr;

    // 2D array to represent "strips" for weight-based placement
    logic [WIDTH-1:0] strip[N][N];

    // Array to track how many elements are in each strip
    int strip_count[N];

    // Raw weights and normalized weights for each input
    int weight[N];
    int weight_div2[N];

    // Temporary array to hold sorted values before output
    logic [WIDTH-1:0] temp_out[N];

    // Edge detection for start signal
    logic start_d, start_rising;

    // Edge detection logic: store delayed version of `start`
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            start_d <= 0;
        else
            start_d <= start;
    end

    // Rising edge detect: goes high only on rising edge of `start`
    assign start_rising = start & ~start_d;

    // State register update logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-state logic for FSM
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

    // Main FSM datapath operations
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            for (i = 0; i < N; i++)
                data_sorted[i] <= 0;
        end else begin
            case (state)

                // Wait state, clear done
                IDLE: done <= 0;

                // Reset all counters, weights, and strip storage
                INIT: begin
                    for (i = 0; i < N; i++) begin
                        strip_count[i] = 0;
                        weight[i] = 0;
                        weight_div2[i] = 0;
                        for (j = 0; j < N; j++)
                            strip[i][j] = 0;
                    end
                end

                // Compute weight of each input value:
                // +1 for each value less than it, -1 for each value greater
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

                // Normalize weights by dividing by 2, rounding up if positive
                NORM_WEIGHT: begin
                    for (i = 0; i < N; i++) begin
                        if (weight[i] >= 0)
                            weight_div2[i] = (weight[i] + 1) >>> 1;
                        else
                            weight_div2[i] = weight[i] >>> 1;
                    end
                end

                // Place data into the appropriate "strip" based on normalized weight
                PLACE_STRIP: begin
                    for (i = 0; i < N; i++) begin
                        // Convert normalized weight to strip index
                        pos = (N >> 1) + weight_div2[i];

                        // Clamp to bounds
                        if (pos < 0) pos = 0;
                        else if (pos >= N) pos = N - 1;

                        // Resolve collisions by incrementing position
                        while (strip_count[pos] != 0 && pos < N - 1)
                            pos++;

                        // Place value in strip and increment strip count
                        strip[pos][strip_count[pos]] = data_in[i];
                        strip_count[pos]++;
                    end
                end

                // Copy values from strip into temp_out in order
                COPY_OUTPUT: begin
                    out_ptr = 0;
                    for (i = 0; i < N; i++) begin
                        for (j = 0; j < strip_count[i]; j++) begin
                            temp_out[out_ptr] = strip[i][j];
                            out_ptr++;
                        end
                    end

                    // Fill any remaining slots with 0
                    for (; out_ptr < N; out_ptr++) begin
                        temp_out[out_ptr] = 0;
                    end
                end

                // Final write of sorted values to output
                WRITE_BACK: begin
                    for (i = 0; i < N; i++)
                        data_sorted[i] <= temp_out[i];
                end

                // Sorting is complete
                DONE: done <= 1;

            endcase
        end
    end

endmodule








