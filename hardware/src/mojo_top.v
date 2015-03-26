module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy, // AVR Rx buffer full
	 
	 //Additional connections
	 //Serial
	 output ext_tx, //FPGA Tx
	 input  ext_rx, //FPGA Rx 
	 //Spi
	 output ext_miso, //35
	 input  ext_mosi, //34
	 input  ext_ss,   //40
	 input  ext_sck, //41
	 
	 input echo, //ultrasonic received dur.
	 output trigger //ultrasonic start
    );
	 
parameter SERIAL_BAUD_RATE=9600;

wire rst = ~rst_n; // make reset active high
// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;

//assign led = 8'b10001011;
reg [7:0] status_out;
/*
assign led = rx_data;

wire [7:0] tx_data;
wire new_tx_data;
wire tx_busy;
wire [7:0] rx_data;
wire new_rx_data;
wire srl_block;
assign srl_block = 1'b0;
*/
wire measure_dist;
wire [15:0] dist;
assign measure_dist = 1'b1;
wire dist_valid;

always @(*) begin
	if(ext_spi_done) begin
		ext_spi_send_data = ext_spi_receive_data;
	end
end

wire clk_10us;

clk_divider #(.DIV(500)) div_clk10us(
	 .clk(clk),
	 .rst(rst),
	 .div_clk(clk_10us));
	 
hcsr04 #(
		.TRIGGER_DURATION(1),
		.MAX_COUNT(3800)
	) ultrasonic(
	 .clk(clk),
	 .tclk(clk_10us),
	 .rst(rst),
	 .measure(measure_dist),
	 .echo(echo),
	 .ticks(dist),
	 .valid(dist_valid),
	 .trigger(trigger));

wire ext_spi_done;
wire [7:0] ext_spi_receive_data;
reg  [7:0] ext_spi_send_data;
spi_slave external_spi (
	.clk(clk),
	.rst(rst),

	.ss(ext_ss),
	.mosi(ext_mosi),
	.miso(ext_miso),
	.sck(ext_sck),

	.done(ext_spi_done),
	.din(ext_spi_send_data),
	.dout(ext_spi_receive_data)
);
wire [7:0] mojo_com_rx_arr [255:0];
reg [7:0] mojo_com_tx_arr [255:0];
wire mojo_com_rx_busy, mojo_com_new_rx, mojo_com_rx_busy;
mojo_com #(
	.SERIAL_BAUD_RATE(SERIAL_BAUD_RATE))
 com_unit(
	.clk(clk),
	.rst(rst),
	.tx(ext_tx),
	.rx(ext_rx),
	.rx_arr(mojo_com_rx_arr),
	.rx_busy(mojo_com_rx_busy),
	.new_rx(mojo_com_new_rx),
	.tx_arr(mojo_com_tx_arr),
	.tx_busy(mojo_com_tx_busy)
);
	

/*
serial_interface #(.SERIAL_BAUD_RATE(SERIAL_BAUD_RATE)) connector (
	 .clk(clk),
	 .rst(rst),
	 .tx(ext_tx),
	 .rx(ext_rx),
	 .tx_data(tx_data),
	 .new_tx_data(new_tx_data),
	 .tx_busy(tx_busy),
	 .tx_block(srl_block),
	 .rx_data(rx_data),
	 .new_rx_data(new_rx_data)
);


message_printer helloWorldPrinter (
    .clk(clk),
    .rst(rst),
    .tx_data(tx_data),
    .new_tx_data(new_tx_data),
    .tx_busy(tx_busy),
    .rx_data(rx_data),
    .new_rx_data(new_rx_data)
);
*/


endmodule
