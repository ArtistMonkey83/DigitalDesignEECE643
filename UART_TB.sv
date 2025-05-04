`timescale 1ns/1ps

module tb_uart;
    parameter CLOCK_FREQ = 100_000_000; // 100 MHz
    parameter BAUD_RATE  = 9600;
    localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    logic        clk;                // Testbench Signals
    logic        rst;
    logic [7:0]  tb_data_in;
    logic        tb_transmit;
    logic        tx_line;
    logic        tx_busy;
    logic [7:0]  rx_data_out;
    logic        rx_data_ready;
    logic        rx_line;            // Loopback wire

    assign rx_line = tx_line;        // Loopback: TX → RX

    uartTX #(                        // Instantiate UART Transmitter (DUT_TX)
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut_tx (
        .clk       (clk),
        .rst       (rst),
        .data_in   (tb_data_in),
        .transmit  (tb_transmit),
        .tx        (tx_line),
        .tx_busy   (tx_busy)
    );

    uartRX #(                       // Instantiate UART Receiver (DUT_RX)
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) dut_rx (
        .clk        (clk),
        .rst        (rst),
        .rx         (rx_line),
        .data_out   (rx_data_out),
        .data_ready (rx_data_ready)
    );

    initial begin                  // Clock Generation: 100MHz → 10ns period
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin                         // 1) Initialize
        rst = 1;
        tb_transmit = 0;
        tb_data_in = 8'h00;
        repeat (2) @(posedge clk);
        rst = 0;
        @(posedge clk);

        logic [7:0] test_vec [0:3];       // 2) Define test vectors
        integer i;
        test_vec[0] = 8'hA5;
        test_vec[1] = 8'h3C;
        test_vec[2] = 8'hFF;
        test_vec[3] = 8'h00;

        for (i = 0; i < 4; i++) begin    // 3) Transmit & Receive Loop
            tb_data_in = test_vec[i];    // Load test byte
            tb_transmit = 1;             // Pulse transmit
            @(posedge clk);
            tb_transmit = 0;             // Deassert

            wait (rx_data_ready);         // Wait for data_ready from RX
            $display("Time %0t: Sent=0x%02h Received=0x%02h", 
                     $time, test_vec[i], rx_data_out);

            repeat (CLKS_PER_BIT*2) @(posedge clk);    // Give some idle time (2 bit periods) before next byte
        end

        $display("UART loopback test complete.");      // 4) Finish simulation
        $finish;
    end
endmodule
