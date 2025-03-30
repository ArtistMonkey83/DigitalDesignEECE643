`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/29/2025 07:29:54 PM
// Design Name: Optimized state diagram implementation
// Module Name: activ4b_tb
// Project Name: Activity 4
// Target Devices: 
// Tool Versions: 
// Description: Optimized version of the FSM presented in Activity #4, with the purpose of assessing if 
// there is a reduction in flip-flops with this design compared to activ4a design
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module activ4b_tb;
    logic clk, reset, x, y;
    logic [2:0] currentState, nextState;
    
    activ4b dut(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .currentState(currentState),
        .nextState(nextState)
    );
    
    initial begin clk = 1'b0;
    forever #10 clk = ~clk; end
    
    typedef struct packed{
    logic x, y;
    logic [2:0] cState, nState;
    }test_vector_t;
    
    test_vector_t test_vectors[] = {  // x, y, currentState, nextState
                                    {1'b0, 1'b0,3'b000,3'b011}, // S0 with x == 0 ∴ y == 0 & nextState == S3 
                                    {1'b1, 1'b0,3'b000,3'b001}, // S0 with x == 1 ∴ y == 0 & nextState == S1 
                                    
                                    {1'b0, 1'b0,3'b001,3'b010}, // S1 with x == 0 ∴ y == 0 & nextState == S2 
                                    {1'b1, 1'b0,3'b001,3'b000}, // S1 with x == 1 ∴ y == 0 & nextState == S0 
                                    
                                    {1'b0, 1'b1,3'b010,3'b100}, // S2 with x == 0 ∴ y == 1 & nextState == S4 
                                    {1'b1, 1'b0,3'b010,3'b000}, // S2 with x == 1 ∴ y == 0 & nextState == S0
                                    
                                    {1'b0, 1'b1,3'b011,3'b011}, // S3 with x == 0 ∴ y == 1 & nextState == S3 
                                    {1'b1, 1'b1,3'b011,3'b001}, // S3 with x == 1 ∴ y == 1 & nextState == S1
                                    
                                    {1'b0, 1'b0,3'b100,3'b100}, // S4 with x == 0 ∴ y == 0 & nextState == S4 
                                    {1'b1, 1'b0,3'b001,3'b010}  // S4 with x == 1 ∴ y == 1 & nextState == S2
                                 };                               
    integer i;
    
    initial begin
        reset = 1;
        #10;
        reset = 0;
        #10;
        
        for(i=0 ; i < $size(test_vectors); i++)begin
            #10
            x = test_vectors[i].x;
            #10;
            if ((y!= test_vectors[i].y) || (dut.currentState != test_vectors[i].cState))begin
                $display("Test %0d failed: Expected State: S%0d, Returned State: S%d, Expected Y: %0d, Returned Y: %0d", i, test_vectors[i].cState, currentState,test_vectors[i].y, y);
            end else begin
                $display("Test%0d passed.!",i);
            end
        end
    end
                                        
endmodule