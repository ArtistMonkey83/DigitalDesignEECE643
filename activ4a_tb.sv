`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234624
// 
// Create Date: 03/29/2025 02:54:57 PM
// Design Name: Initial state diagram testbench
// Module Name: activ4a_tb
// Project Name: Activity 4
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the initial state diagram for activity 4
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module activ4a_tb;
    logic clk, reset, x, y;
    logic [2:0] currentState, nextState;
    
    activ4a dut(
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
                                    {1'b0, 1'b0,3'b000,3'b101}, // S0 with x == 0 ∴ y == 0 & nextState == S5 
                                    {1'b1, 1'b0,3'b000,3'b001}, // S0 with x == 1 ∴ y == 0 & nextState == S1 
                                    
                                    {1'b0, 1'b0,3'b001,3'b011}, // S1 with x == 0 ∴ y == 0 & nextState == S3 
                                    {1'b1, 1'b0,3'b001,3'b010}, // S1 with x == 1 ∴ y == 0 & nextState == S2 
                                    
                                    {1'b0, 1'b0,3'b010,3'b101}, // S2 with x == 0 ∴ y == 0 & nextState == S5 
                                    {1'b1, 1'b0,3'b010,3'b100}, // S2 with x == 1 ∴ y == 0 & nextState == S4
                                    
                                    {1'b0, 1'b1,3'b011,3'b110}, // S3 with x == 0 ∴ y == 1 & nextState == S6 
                                    {1'b1, 1'b0,3'b011,3'b000}, // S3 with x == 1 ∴ y == 0 & nextState == S0
                                    
                                    {1'b0, 1'b0,3'b100,3'b011}, // S4 with x == 0 ∴ y == 0 & nextState == S3 
                                    {1'b1, 1'b0,3'b100,3'b010}, // S4 with x == 1 ∴ y == 0 & nextState == S2
                                    
                                    {1'b0, 1'b1,3'b101,3'b101}, // S5 with x == 0 ∴ y == 1 & nextState == S5
                                    {1'b1, 1'b1,3'b101,3'b001}, // S5 with x == 1 ∴ y == 1 & nextState == S1
                                     
                                    {1'b0, 1'b0,3'b110,3'b110}, // S6 with x == 0 ∴ y == 0 & nextState == S6
                                    {1'b1, 1'b1,3'b110,3'b111}, // S6 with x == 1 ∴ y == 1 & nextState == S7
                                    
                                    {1'b0, 1'b1,3'b111,3'b110}, // S7 with x == 0 ∴ y == 1 & nextState == S6           
                                    {1'b1, 1'b0,3'b111,3'b000}  // S7 with x == 1 ∴ y == 0 & nextState == S0  
                                 };                               
    integer i;
    
    initial begin
        reset = 1;
        #10;
        reset = 0;
        #10;
        
        for(i=0 ; i < $size(test_vectors); i++)begin
            x = test_vectors[i].x;
            #20;
            if ((y!= test_vectors[i].y) || (dut.currentState != test_vectors[i].cState))begin
                $display("Test %0d failed: Expected State: S%0d, Returned State: S%d, Expected Y: %0d, Returned Y: %0d", i, test_vectors[i].cState, currentState,test_vectors[i].y, y);
            end else begin
                $display("Test%0d passed.!",i);
            end
        end
    end
                                        
endmodule
