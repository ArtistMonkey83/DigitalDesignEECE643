module matrix_loader #(
    parameter MAX_M = 4,
    parameter MAX_N = 4,
    parameter MAX_P = 4
)(
    input  logic clk,
    input  logic rst_n,
    input  logic uart_rx,               // UART serial input
    output logic done,                  // Goes high when computation is complete
    output logic [31:0] result [MAX_M][MAX_P] // Final output matrix
);

    // === Internal wires and registers ===
    logic [7:0] uart_byte;              // Byte received from UART
    logic uart_byte_valid;              // High for 1 clk when byte is valid
    logic [31:0] word_buffer;           // Temporary 32-bit assembler
    logic [1:0] byte_index;             // Byte counter (0 to 3 for 32-bit word assembly)
    
    logic [31:0] M, N, P;               // Dimensions received from UART
    logic [31:0] matA [0:MAX_M-1][0:MAX_N-1]; // A is M×N
    logic [31:0] matB [0:MAX_N-1][0:MAX_P-1]; // B is N×P
    logic [31:0] matC [0:MAX_M-1][0:MAX_P-1]; // C is M×P

    typedef enum logic [2:0] {
        IDLE,
        READ_DIMS,
        READ_A,
        READ_B,
        COMPUTE,
        DONE
    } state_t;

    state_t state, next_state;

    integer i = 0, j = 0, k = 0;
    integer total_words_needed;
    integer current_word_count;

    // === Instantiate UART Receiver ===
    uart_rx uart_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_rx),
        .data_out(uart_byte),
        .data_ready(uart_byte_valid)
    );

    // === FSM Transition Logic ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        case (state)
            IDLE:       next_state = uart_byte_valid ? READ_DIMS : IDLE;
            READ_DIMS:  next_state = (current_word_count == 3) ? READ_A : READ_DIMS;
            READ_A:     next_state = (current_word_count == M * N) ? READ_B : READ_A;
            READ_B:     next_state = (current_word_count == N * P) ? COMPUTE : READ_B;
            COMPUTE:    next_state = DONE;
            DONE:       next_state = DONE;
            default:    next_state = IDLE;
        endcase
    end

    // === Byte Assembler and Loader ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_index <= 0;
            word_buffer <= 0;
            current_word_count <= 0;
            done <= 0;
        end else if (uart_byte_valid) begin
            // Shift received byte into buffer (big-endian)
            word_buffer <= {word_buffer[23:0], uart_byte};
            byte_index <= byte_index + 1;

            if (byte_index == 2'd3) begin
                // Full word assembled
                case (state)
                    READ_DIMS: begin
                        if (current_word_count == 0) M <= word_buffer;
                        else if (current_word_count == 1) N <= word_buffer;
                        else if (current_word_count == 2) P <= word_buffer;
                        current_word_count <= current_word_count + 1;
                    end
                    READ_A: begin
                        matA[i][j] <= word_buffer;
                        if (j == N - 1) begin
                            j <= 0;
                            i <= i + 1;
                        end else
                            j <= j + 1;
                        current_word_count <= current_word_count + 1;
                    end
                    READ_B: begin
                        matB[i][j] <= word_buffer;
                        if (j == P - 1) begin
                            j <= 0;
                            i <= i + 1;
                        end else
                            j <= j + 1;
                        current_word_count <= current_word_count + 1;
                    end
                endcase
                byte_index <= 0;
            end
        end

        // Reset matrix indexes when transitioning states
        if (state != next_state) begin
            i <= 0;
            j <= 0;
            current_word_count <= 0;
        end
    end

    // === Matrix Multiplication Logic ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < MAX_M; i++)
                for (j = 0; j < MAX_P; j++)
                    matC[i][j] <= 0;
        end else if (state == COMPUTE) begin
            for (i = 0; i < M; i++)
                for (j = 0; j < P; j++) begin
                    matC[i][j] = 0;
                    for (k = 0; k < N; k++)
                        matC[i][j] += matA[i][k] * matB[k][j];
                end
            done <= 1;
        end
    end

    // === Connect output result matrix ===
    genvar row, col;
    generate
        for (row = 0; row < MAX_M; row++) begin : result_row
            for (col = 0; col < MAX_P; col++) begin : result_col
                assign result[row][col] = matC[row][col];
            end
        end
    endgenerate
endmodule
