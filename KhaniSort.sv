always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        done <= 0;
        for (i = 0; i < N; i++)
            data_sorted[i] <= 0;
    end else begin
        case (state)

            // Clear 'done' flag in idle state
            IDLE: done <= 0;

            // Initialize arrays and variables used in sorting
            INIT: begin
                for (i = 0; i < N; i++) begin
                    strip_count[i] = 0;        // Reset the count of elements in each strip
                    weight[i] = 0;             // Reset raw weight for each input
                    weight_div2[i] = 0;        // Reset normalized weight
                    for (j = 0; j < N; j++)
                        strip[i][j] = 0;       // Clear 2D strip buffer for placing sorted values
                end
            end

            // Calculate the "weight" of each input element
            CALC_WEIGHT: begin
                for (i = 0; i < N; i++) begin
                    weight[i] = 0;  // Start weight at zero for input[i]
                    for (j = 0; j < N; j++) begin
                        // Compare data_in[i] to every other data_in[j]
                        if (data_in[i] < data_in[j])
                            weight[i] -= 1;  // Penalize if i-th element is smaller
                        else if (data_in[i] > data_in[j])
                            weight[i] += 1;  // Reward if i-th element is larger
                        // The final weight reflects how many values it's larger/smaller than
                    end
                end
            end

            // Normalize weight by dividing by 2 using arithmetic shift
            NORM_WEIGHT: begin
                for (i = 0; i < N; i++) begin
                    if (weight[i] >= 0)
                        weight_div2[i] = (weight[i] + 1) >>> 1;
                        // Bias toward rounding up when weight is positive (to reduce collision)
                    else
                        weight_div2[i] = weight[i] >>> 1;
                        // Standard signed shift for negative values (arithmetic right shift)
                end
            end

            // Use normalized weights to determine strip placement
            PLACE_STRIP: begin
                for (i = 0; i < N; i++) begin
                    pos = (N >> 1) + weight_div2[i];
                    // Convert normalized weight to a position in the middle-based strip array
                    // (N >> 1) centers the index, weight_div2 offsets left/right

                    if (pos < 0) pos = 0;
                    else if (pos >= N) pos = N - 1;
                    // Clamp position to valid bounds [0, N-1]

                    while (strip_count[pos] != 0 && pos < N - 1)
                        pos++;
                    // If strip[pos] already has an entry, try the next one
                    // This prevents overwriting values and acts as collision resolution

                    strip[pos][strip_count[pos]] = data_in[i];
                    // Store the current input in the calculated strip at the next available slot

                    strip_count[pos]++;
                    // Track how many values have been inserted into this strip
                end
            end

            // Flatten the 2D strip into a 1D temporary output array
            COPY_OUTPUT: begin
                out_ptr = 0;  // Reset output pointer
                for (i = 0; i < N; i++) begin
                    for (j = 0; j < strip_count[i]; j++) begin
                        temp_out[out_ptr] = strip[i][j];
                        // Copy each strip element to the linear output
                        out_ptr++;
                    end
                end

                // Fill any unused slots in temp_out with zero (optional cleanup)
                for (; out_ptr < N; out_ptr++) begin
                    temp_out[out_ptr] = 0;
                end
            end

            // Write sorted output into the output port array
            WRITE_BACK: begin
                for (i = 0; i < N; i++)
                    data_sorted[i] <= temp_out[i];
                    // Transfer sorted values from temp buffer to output
            end

            // Set done flag high to indicate operation is complete
            DONE: done <= 1;

        endcase
    end
end









