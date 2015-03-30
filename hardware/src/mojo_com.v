module mojo_com #(
	parameter ADDR_SPACE = 64 //addr is last 6 bits
)(
	input clk,
	input rst,
	//SPI connections
	input ss,
	input sck,
	input mosi,
	output miso,
	//Interface, doesn't guarantee atomicity
	output [8*ADDR_SPACE-1:0] rx_arr,
	output rx_busy,
	output new_rx,
	input [8*ADDR_SPACE-1:0] tx_arr,
	output tx_busy
);

parameter ADDR_BITS = $clog2(ADDR_SPACE);
//SPI addressing setup
wire [ADDR_BITS-1:0] reg_addr;
wire [7:0] write_value, read_value;
wire write, new_req, in_transaction;
spi_addressing spi_interface(
	.clk(clk),
	.rst(rst),
	//SPI pins
	.spi_ss(ss),
	.spi_sck(sck),
	.spi_mosi(mosi),
	.spi_miso(miso),
	//Interface
	.reg_addr(reg_addr),
	.write(write),
	.new_req(new_req),
	.write_value(write_value),
	.read_value(read_value),
	.in_transaction(in_transaction)
);

mojo_com_logic #(.ADDR_SPACE(ADDR_SPACE)) com_logic (
	.clk(clk),
	.rst(rst),
	//SPI addressing interface
	.reg_addr(reg_addr),
	.write(write),
	.new_req(new_req),
	.write_value(write_value),
	.read_value(read_value),
	.in_transaction(in_transaction),
	//Interface
	.rx_arr(rx_arr),
	.rx_busy(rx_busy),
	.new_rx(new_rx),
	.tx_arr(tx_arr),
	.tx_busy(tx_busy)
);

endmodule
