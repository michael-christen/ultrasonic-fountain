module mojo_com #(
	parameter ADDR_SPACE = 256,
	parameter SERIAL_BAUD_RATE = 9600
)(
	input clk,
	input rst,
	//UART connections
	output tx,
	input  rx,
	//Interface, doesn't guarantee atomicity
	output [8*ADDR_SPACE-1:0] rx_arr,
	output rx_busy,
	output new_rx,
	input [8*ADDR_SPACE-1:0] tx_arr,
	output tx_busy
);

//Serial setup
wire [7:0] ser_tx_data;
wire ser_new_tx_data;
wire ser_tx_busy;
wire [7:0] ser_rx_data;
wire ser_new_rx_data;
wire ser_zero;
assign ser_zero = 1'b0;
serial_interface #(.SERIAL_BAUD_RATE(SERIAL_BAUD_RATE)) connector (
	 .clk(clk),
	 .rst(rst),
	 .tx(tx),
	 .rx(rx),
	 .tx_data(ser_tx_data),
	 .new_tx_data(ser_new_tx_data),
	 .tx_busy(ser_tx_busy),
	 .tx_block(ser_zero),
	 .rx_data(ser_rx_data),
	 .new_rx_data(ser_new_rx_data)
);

mojo_com_logic #(.ADDR_SPACE(ADDR_SPACE)) com_logic (
	.clk(clk),
	.rst(rst),
	.ser_tx_data(ser_tx_data),
	.ser_new_tx_data(ser_new_tx_data),
	.ser_tx_busy(ser_tx_busy),
	.ser_rx_data(ser_rx_data),
	.ser_new_rx_data(ser_new_rx_data),
	//Interface
	.rx_arr(rx_arr),
	.rx_busy(rx_busy),
	.new_rx(new_rx),
	.tx_arr(tx_arr),
	.tx_busy(tx_busy)
);

endmodule
