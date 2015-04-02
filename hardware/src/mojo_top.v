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
	 
	 input [NUM_ULTRASONICS-1:0] echo, //ultrasonic received dur.
	 output [NUM_ULTRASONICS-1:0] trigger //ultrasonic start
    );

wire rst = ~rst_n; // make reset active high
// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;
//assign ext_miso = 1'bz;
assign ext_tx = 1'bz;

//Setup clock
wire clk_10us;
clk_divider #(.DIV(500)) div_clk10us(
	 .clk(clk),
	 .rst(rst),
	 .div_clk(clk_10us));
//Setup hcsr04s
wire measure_dist;
assign measure_dist = 1'b1;
parameter NUM_ULTRASONICS = 9;
//Each distance takes 16 bits
wire [NUM_ULTRASONICS * 16 -1:0] us_dists;
wire [NUM_ULTRASONICS - 1: 0] us_dists_valid;
genvar i;
generate
for (i = 0; i < NUM_ULTRASONICS; i=i+1) begin: us_gen_loop
    hcsr04 #(
   	 .TRIGGER_DURATION(1),
   	 .MAX_COUNT(3800)
    ) ultrasonic(
   	 .clk(clk),
   	 .tclk(clk_10us),
   	 .rst(rst),
   	 .measure(measure_dist),
   	 .echo(echo[i]),
   	 .ticks(us_dists[16*i+16 - 1: 16*i]),
   	 .valid(us_dists_valid[i]),
   	 .trigger(trigger[i]));
end
endgenerate

//Setup comm protocol
localparam ADDR_SPACE = 64;
wire [8*ADDR_SPACE -1:0] mojo_com_rx_arr;
wire [8*ADDR_SPACE -1:0] mojo_com_tx_arr;
//assign mojo_com_tx_arr = {8'hde,8'had,8'hbe,8'hef, us_dists};
assign mojo_com_tx_arr = {480'b0,8'hde,8'had,8'hbe,8'hef};
wire mojo_com_rx_busy, mojo_com_new_rx, mojo_com_tx_busy;
mojo_com #(
	.ADDR_SPACE(ADDR_SPACE))
 com_unit(
	.clk(clk),
	.rst(rst),
	//SPI wires
	.ss(ext_ss),
	.sck(ext_sck),
	.mosi(ext_mosi),
	.miso(ext_miso),
	//Interface wires
	.rx_arr(mojo_com_rx_arr),
	.rx_busy(mojo_com_rx_busy),
	.new_rx(mojo_com_new_rx),
	.tx_arr(mojo_com_tx_arr),
	.tx_busy(mojo_com_tx_busy)
);

assign led = mojo_com_rx_arr[15:8];

endmodule
