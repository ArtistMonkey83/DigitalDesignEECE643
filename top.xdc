## Clock input (100 MHz on Basys3 = W5)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Reset button (BTNC = U18)
set_property PACKAGE_PIN U18 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## UART RX  (USB-UART → FPGA)
set_property PACKAGE_PIN U2  [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]

## UART TX  (FPGA → USB-UART)
set_property PACKAGE_PIN V4  [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
