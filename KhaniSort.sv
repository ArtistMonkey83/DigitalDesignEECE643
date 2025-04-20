// FSM-based sorting module using a weight-based algorithm
module fsm_sort #(
    parameter int N = 6,            // Number of data inputs
    parameter int WIDTH = 8         // Bit-width of each data element
)(
    input  logic clk,                      // Clock input
    input  logic rst,                      // Reset input (active high)
    input  logic start,                    // Start signal for initiating sorting
    input  logic [WIDTH-1:0] data_in[N],   // Array of N input data values
    output logic done,                     // Asserted when sorting is complete
    output logic [WIDTH-1:0] data_sorted[N]// Array of N sorted output values
);

    // Define FSM states
    typedef enum logic [2:0] {
        IDLE,         // Wait for the start signal
        INIT,         // Initialize all variables
        CALC_WEIGHT,  // Compute weight for each element
        NORM_WEIGHT,  // Normalize weight (divide by 2)
        PLACE_STRIP,  // Place values into strips based on normalized weight
        COPY_OUTPUT,  // Flatten strips into a 1D buffer
        WRITE_BACK,   // Copy buffer to output
        DONE          // Signal sorting is complete
    } state_t;

    state_t state, next_state;  // Current and next state variables

    // Loop and working variables
    int i, j, pos, out_ptr;

    // 2D strip structure used to group data by weight
    logic [WIDTH-1:0] strip[N][N]; // Each row holds a strip; max N items per strip
    int strip_count[N];           // Number of elements in each strip

    // Weight calculations
    int weight[N];                // Raw weight: compares data_in[i] to all others
    int weight_div2[N];           // Normalized weight: weight[i] / 2

    // Temporary buffer to hold flattened and sorted data
    logic [WIDTH-1:0] temp_out[N];

    // Start signal rising-edge detection
    logic start_d, start_rising;

    // Store delayed version of start to detect rising edge
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            start_d <= 0;
        else
            start_d <= start;
    end

    // Detect rising edge of start
    assign start_rising = start & ~start_d;

    // FSM state update
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM next-state logic
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

    // FSM datapath operations for each state
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset output and done flag
            done <= 0;
            for (i = 0; i < N; i++)
                data_sorted[i] <= 0;
        end else begin
            case (state)

                // Clear done signal in IDLE
                IDLE: done <= 0;

                // Initialize arrays and counters
                INIT: begin
                    for (i = 0; i < N; i++) begin
                        strip_count[i] = 0;        // Clear number of items in each strip
                        weight[i] = 0;             // Reset weight array
                        weight_div2[i] = 0;        // Reset normalized weights
                        for (j = 0; j < N; j++)
                            strip[i][j] = 0;       // Clear the strip entries
                    end
                end

                // Calculate how many values are less or greater than data_in[i]
                CALC_WEIGHT: begin
                    for (i = 0; i < N; i++) begin
                        weight[i] = 0;  // Reset current weight
                        for (j = 0; j < N; j++) begin
                            if (data_in[i] < data_in[j])
                                weight[i] -= 1;  // Subtract for values larger than i
                            else if (data_in[i] > data_in[j])
                                weight[i] += 1;  // Add for values smaller than i
                        end
                    end
                end

                // Normalize weight (divide by 2 using arithmetic shift)
                NORM_WEIGHT: begin
                    for (i = 0; i < N; i++) begin
                        if (weight[i] >= 0)
                            weight_div2[i] = (weight[i] + 1) >>> 1; // Round up for positives
                        else
                            weight_div2[i] = weight[i] >>> 1;       // Arithmetic shift for negatives
                    end
                end

                // Place values into strip array based on normalized weight
                PLACE_STRIP: begin
                    for (i = 0; i < N; i++) begin
                        pos = (N >> 1) + weight_div2[i]; // Center weight in strip range

                        // Clamp to valid index bounds
                        if (pos < 0) pos = 0;
                        else if (pos >= N) pos = N - 1;

                        // Handle collision: if strip already used, find next free spot
                        while (strip_count[pos] != 0 && pos < N - 1)
                            pos++;

                        // Insert current input into strip at calculated position
                        strip[pos][strip_count[pos]] = data_in[i];

                        // Increment how many items are in this strip
                        strip_count[pos]++;
                    end
                end

                // Flatten strips into temp_out in row-major order
                COPY_OUTPUT: begin
                    out_ptr = 0;  // Reset output pointer
                    for (i = 0; i < N; i++) begin
                        for (j = 0; j < strip_count[i]; j++) begin
                            temp_out[out_ptr] = strip[i][j]; // Copy strip to temp output
                            out_ptr++;                        // Move to next output slot
                        end
                    end

                    // Fill remaining unused slots with 0s (optional cleanup)
                    for (; out_ptr < N; out_ptr++) begin
                        temp_out[out_ptr] = 0;
                    end
                end

                // Write sorted values to output port
                WRITE_BACK: begin
                    for (i = 0; i < N; i++)
                        data_sorted[i] <= temp_out[i];
                end

                // Signal that sorting is complete
                DONE: done <= 1;

            endcase
        end
    end

endmodule










