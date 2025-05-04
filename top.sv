
`timescale 1ns/1ps          // top.sv

module top(
    input  logic clk,       // 100 MHz onboard clock
    input  logic rst_n,     // Active-low reset pushbutton
    input  logic uart_rx,   // USB-UART RX from PC
    output logic uart_tx    // USB-UART TX to PC
);
  
  matrix_loader #(            // Instantiate your matrix loader/multiplier,
    .MAX_M       (4),         // but expose only the UART interface at top level:
    .MAX_N       (4),
    .MAX_P       (4),
    .CLOCK_FREQ  (50000000),  // 50 MHz logic clock inside loader
    .BAUD_RATE   (9600)
  ) u_matrix (
    .clk       (clk),
    .rst_n     (rst_n),
    .uart_rx   (uart_rx),
    .uart_tx   (uart_tx)
                              // Overutilization error FIX ← NO result[ ][ ] ports here!
  );

endmodule
