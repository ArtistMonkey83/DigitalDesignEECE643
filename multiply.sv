`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Amant Kaur & Yolanda Reyes
// 
// Version Date:    04/19/2025 08:18:38 PM
// Design Name:     Matrix Multiplication
// Module Name:     multiply.sv
// Project Name:    Designing a Hardware-Based Matrix Multiplier
// Target Devices:  Basys 3 FPGA
// Tool Versions:
// Description: M = rows & N = columsn in A for array_a => in mxn
//              N = rows in B & P = column for array_b => in nxp
//
// Dependencies: matrix_mult_tb.sv
// 
// Revision:
// Revision 3.1 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module multiply(input logic clk, reset,
                input logic [31:0] a_in,
                input logic [31:0] b_in,
                output logic [63:0] one_product,
                output logic single_done);

//****************Finite State Machine #2; Multiply and Product****************//    
    typedef enum logic [2:0] {INIT, LOAD, MULTIPLY, SHIFT, STORE, MOVE, DONE} statetype;
    statetype current_state, next_state;

    //Local Variables
    logic [31:0] multiplicand;           //Temp. Multiplicand
    logic [31:0] multiplier;             //Temp. Multiplier
    logic [63:0] product;                //Temp. Product
    logic [6:0]  repetition_counter;     //Counter for tracking repetition
    logic [1:0]  row, column;            //Index values for arrays

    always_ff@(posedge clk or posedge reset) begin
        if (reset) current_state <= INIT;               //Start at INIT
        else if (reset === 1'bz) current_state <= INIT;
        else       current_state <= next_state;         //Continue to next state
    end
    
    //Combinational Statement for state flow
    always_comb begin
        case(current_state)
            INIT:           next_state = LOAD;
            LOAD:           next_state = MULTIPLY;
            MULTIPLY:       next_state = SHIFT;
            SHIFT:          if(repetition_counter < 32) next_state = MULTIPLY;
                            else next_state = STORE;
            STORE:          next_state = MOVE;
            MOVE:           if(row >= 1 & column >= 1) next_state = DONE;
                            else next_state = LOAD;
            DONE:           next_state = DONE;
            default:        next_state = INIT;
        endcase
    end
    
    //State Definitions
    always_ff@(posedge clk) begin
        case(current_state)
            INIT: begin                     //Clear all local variables
                single_done <= 0;           //Indicates this particular element set is ready
                product <= '0;
                row <= 0;
                column <= 0;
                repetition_counter <= 0;
            end
            LOAD: begin
                multiplicand = '0;
                multiplier = '0; 
                multiplicand = a_in;                //Place element from array_a
                multiplier = b_in;                  //Place element from array_b
                one_product <= '0;                  //Set product to zero
            end
            MULTIPLY: begin
                if(multiplier[0] == 1) begin 
                    product += multiplicand;        //If Bit 0 is 1, add multiplicand to product
                end
                repetition_counter++;               //Increment repetition counter
            end
            SHIFT: begin
                multiplicand <= multiplicand << 1;  //Shift multiplicand to left 1 bit
                multiplier <= multiplier >> 1;      //Shift multiplier right 1 bit
            end
            STORE: begin
                one_product <= product;             //Place this result into product
                row++;                              //Increment Row
                column++;                           //Increment Column
            end
            MOVE: begin
                //Buffer State to display in TCL Console the products
                $display("Multiplier: a=%0d, b=%0d => product=%0d", a_in, b_in, one_product);
            end
            DONE: begin
                single_done <= 1;                   //Set single_done for this set of elements
            end
        endcase
    end
    
endmodule
