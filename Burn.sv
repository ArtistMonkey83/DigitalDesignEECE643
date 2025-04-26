module multiply(
    input logic clk,
    input logic reset,
    input logic [31:0] a_in,
    input logic [31:0] b_in,
    output logic [63:0] product_out,
    output logic done
);

    logic [31:0] multiplicand, multiplier;
    logic [63:0] product;
    logic single_done;

    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        MULTIPLY,
        SHIFT,
        STORE,
        DONE
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        case(current_state)
            IDLE: next_state = LOAD;
            LOAD: next_state = MULTIPLY;
            MULTIPLY: next_state = SHIFT;
            SHIFT: next_state = STORE;
            STORE: next_state = DONE;
            DONE: next_state = DONE;
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        case(current_state)
            IDLE: begin
                single_done <= 0;
                product <= 0;
            end
            LOAD: begin
                multiplicand <= a_in;
                multiplier <= b_in;
                product <= 0;
            end
            MULTIPLY: begin
                if (multiplier[0] == 1) begin
                    product <= product + multiplicand;
                end
                multiplier <= multiplier >> 1;
                multiplicand <= multiplicand << 1;
            end
            SHIFT: begin
                // Shift operations incorporated in MULTIPLY for this example
            end
            STORE: begin
                product_out <= product;
                single_done <= 1;
            end
            DONE: begin
                done <= single_done;
            end
        endcase
    end
endmodule
