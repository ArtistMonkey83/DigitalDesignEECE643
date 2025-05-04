`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Amant Kaur & Yolanda Reyes
// 
// Version Date:    4/18/2025 10:07:59 AM
// Design Name:     Matrix Multiplication
// Module Name:     matrix_mult
// Project Name:    Designing a Hardware-Based Matrix Multiplier
// Target Devices:  Basys 3 FPGA
// Tool Versions:
// Description: M = rows & N = columsn in A for array_a => in mxn
//              N = rows in B & P = column for array_b => in nxp
//
// Dependencies: multiply.cv & matrix_mult_tb.sv
// 
// Revision:
// Revision 3.1 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//259Mhz
module matrix_mult #(parameter int M = 2,
                    parameter int N = 2,
                    parameter int P = 2
                   )(input logic clk, reset,
                   input logic [31:0] array_a [M][N],
                   input logic [31:0] array_b [N][P],
                   output logic [63:0] array_c [M][P],
                   output logic ready);

//*******************************Local Variables*******************************//
    logic [63:0] products[M][P][N];      //Contains all products from the multiply.sv module.
    logic [63:0] sums = 0;               //Temporary variable to hold individual array_c element sums.
    logic ready_array[M][P][N];          //Array to indicate all products have been calculated
    logic all_ready;                     //If set, all products are calculated, can move to nextstate.
    
//*******************Parallel Instatiations for multiply.sv********************//
    genvar k, i, j;
    generate
        for (i = 0; i < M; i++) begin
            for (j = 0; j < P; j++) begin
                for (k = 0; k < N; k++) begin : gen_mults
                    multiply insts (
                        .clk(clk),
                        .reset(reset),
                        .a_in(array_a[i][k]),                   //One element from array A
                        .b_in(array_b[k][j]),                   //One element from array B
                        .one_product(products[i][j][k]),        //Obtains each product
                        .single_done(ready_array[i][j][k]));    //Indicates product result is ready
                end
            end
        end
    endgenerate
    
//**************Finite State Machine #1; Accumulation and Result***************//    
    typedef enum logic [1:0] {INIT, READY, COMBINE, FINISH} statetype;
    statetype current_state, nextstate;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) current_state <= INIT;
        else current_state <= nextstate;
    end
    
    always_comb begin
        case(current_state)
            INIT:       nextstate = READY;
            READY:      nextstate = (all_ready) ? COMBINE : READY;
                        //Remain in READY until all elements in ready_array are set to 1.
            COMBINE:    nextstate = FINISH;
            FINISH:     nextstate = FINISH;
            default:    nextstate = INIT;
        endcase
    end
    
    always_ff @(posedge clk) begin
        case(current_state)
            INIT: begin     //Set each position in output array to zero to start.
                for (int i = 0; i < M; i++) begin
                    for (int j = 0; j < P; j++) begin
                        array_c[i][j] <= 0;
                    end
                end
            end
            READY: begin    //Monitor ready_array to make sure all products have been calculated.
                all_ready = 1;
                for (int i = 0; i < M; i++) begin
                    for (int j = 0; j < P; j++) begin
                        for (int k = 0; k < N; k++) begin
                            if (!ready_array[i][j][k])
                                all_ready = 0;
                        end
                    end
                end
            end
            COMBINE: begin  //Sum corresponding products and place into respective position in array_c.
                if (all_ready) begin
                    for (int i = 0; i < M; i++) begin
                        for (int j = 0; j < P; j++) begin
                            sums = 0;
                            for (int k = 0; k < N; k++) begin
                                sums = sums + products[i][j][k];
                            end
                            array_c[i][j] <= sums;
                        end
                    end
                 end
            end
            FINISH: begin
                ready <= 1; //Set ready bit to 1 to indicate to testbench to continue.
            end
        endcase
    end
      
endmodule