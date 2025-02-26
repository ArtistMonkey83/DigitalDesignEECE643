`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University,Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 02/24/2025 08:19:53 PM
// Design Name: Carry Look Ahead Adder with pipeline
// Module Name: CAL4CLKd
// Project Name: Activity 2
// Target Devices: That one Basys thing
// Tool Versions: Good question...
// Description: Activity 2 purpose is to perform slack analysis.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
////////////////////////////////////////////////////////////////////////////////

module CLA4CLKd(
    input  logic clk,        // Clock input
    input  logic reset,      // Reset ensures system is initialized into a known state!
    input  logic [3:0] a_in, // Operand a input to the system
    input  logic [3:0] b_in, // Operand b input to the system
    input  logic c_in,       // Carry input is a single bit, read-only signal
    output logic [3:0] s,    // 4-bit sum result, written within the module
    output logic [3:0] s_out,// Register for sum output
    output logic c_out       // Final carry out, written within the module
);
    logic [3:0] a;           // 4-bit first operand, read-only signal, internal values stored in REG a
    logic [3:0] b;           // 4-bit second operand, read-only signal, internal values stored in REG b
    logic cin;               // 1-bit register for the c_in value to the system
    logic cout;              // 1-bit register for the c_out value from the system to indicate overflow

    logic [3:0] G;           // Carry Generate, internal signal 
    logic [3:0] P;           // Carry Propagate, internal signal
    logic [4:0] C;           // Carry bits (including C0 = C4), internal signal
    
    always_ff @(posedge clk or posedge reset) begin  // Launching D flip-flops for input registers
        if(reset) begin            // Initialization to known values during setup
            a <= 4'b0;             // Initialize a REG to all 0s
            b <= 4'b0;             // Initialize b REG to all 0s
        end else begin             // End of reset state initialization
            a <= a_in;             // Register for input a, <= is a NON blocking statement!
            b <= b_in;             // Register for input b, <= is a NON blocking statement!
        end                    
    end

    always_ff @(posedge clk or posedge reset) begin  // Catching D flip-flops for output registers
        if(reset) begin                 // Initialization to known values during setup
            s_out <= 4'b0;              // Initialize sum REG to all 0s
        end else begin                  // End of reset state initialization
            s_out <= s;                 // Register for output s
        end
    end
    
    always_ff @(posedge clk or posedge reset) begin  // Flip-flop for cin
        if(reset) begin                              // Initialization to known value during setup
            cin <= 1'b0;                             // Initialize cin register to 0
        end else begin                               // End of reset state initialization
            cin <= c_in;                             // Register for input cin
        end
    end
    
    always_ff @(posedge clk or posedge reset) begin  // Flip-flop for cout
        if(reset) begin                              // Initialize to a known value during setup
            cout <= 1'b0;                            // Initialize cout register to 0
        end else begin                               // End of reset state initialization
            c_out <= C[4];                           // Added line to use previous convention before CLK was added!
            cout <= c_out;                           // This line will not execute correctly without c_out first acquiring computed value in C[4]!
        end
    end
    
    assign C[0] = cin;     // Initialize carry input

                           // Generate carry look ahead combinational logic
    assign G = a & b;      // G_i = A_i * B_i, with i∈{0,1,2,3} " both bits are 1, ∴  a 10 Generates a carry"
    assign P = a ^ b;      // P_i = A_i ⊕ B_i, with i∈{0,1,2,3} " if at least 1 input == 1,∴ a carry input will pass to higher bit"

    assign C[1] = (P[0] & C[0]) | G[0];         // Compute carry values....
    assign C[2] = (P[1] & G[0]) | (P[1] & P[0] & C[0]) | G[1]; // Implementation via tracing the circuit, "unrolling"... 
    assign C[3] = (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]) | G[2];  // Removes the recursive dependance ...
    assign C[4] =  G[3] | (P[3] & C[3]); // G[3] can generate a carry if a=b=1
                                         // P[3] can propagate a carry if there is a carry in C[3] and if a or b == 1
    assign s[0] = P[0] ^ C[0];           // S_i = P_i ⊕ C_i, with i∈{0,1,2,3}
    assign s[1] = P[1] ^ C[1];
    assign s[2] = P[2] ^ C[2];
    assign s[3] = P[3] ^ C[3];
    //assign s = P[3:0] ^ C[3:0]; // S_i = P_i ⊕ C_i, with i∈{0,1,2,3}... not working... ¯\_(ツ)_/¯
    //assign cout = C[4];         // Assign final carry-out, This was useful before CLK was added, moved to FF block!

endmodule
