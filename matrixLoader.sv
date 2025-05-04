// matrix_loader.sv
`timescale 1ns/1ps

module matrix_loader #(
    parameter MAX_M       = 4,
    parameter MAX_N       = 4,
    parameter MAX_P       = 4,
    parameter CLOCK_FREQ  = 50000000,
    parameter BAUD_RATE   = 9600
)(
    input  logic clk,
    input  logic rst_n,
    input  logic uart_rx,
    output logic uart_tx
);

                                                      // Internal memories and FSM for A×B→C go here 
                                                      // But do NOT expose matC[][] at the top!        

                                                      // Instance of UART_RX and UART_TX inside
    logic [7:0] byte_in;
    logic       data_ready;
    logic [7:0] byte_out;
    logic       tx_busy;

    uartRX #(
      .CLOCK_FREQ(CLOCK_FREQ),
      .BAUD_RATE (BAUD_RATE)
    ) rx_i (
      .clk        (clk),
      .rst        (rst_n),
      .rx         (uart_rx),
      .data_out   (byte_in),
      .data_ready (data_ready)
    );

                                  // Feed byte_in into your matrix logic, generate results

    uartTX #(
      .CLOCK_FREQ(CLOCK_FREQ),
      .BAUD_RATE (BAUD_RATE)
    ) tx_i (
      .clk       (clk),
      .rst       (rst_n),
      .data_in   (byte_out),
      .transmit  (data_ready),  // Send result whenever ready
      .tx        (uart_tx),
      .tx_busy   (tx_busy)
    );

                                // Multiplication FSM reads from rx_i, writes into tx_i 

endmodule
