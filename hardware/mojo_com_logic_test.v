`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:10:03 03/27/2015
// Design Name:   mojo_com_logic
// Module Name:   /home/michael/Projects/mojo/ultrasonic-fountain/hardware/mojo_com_logic_test.v
// Project Name:  Mojo-Base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mojo_com_logic
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mojo_com_logic_test;

	// Inputs
	reg clk;
	reg rst;
	reg ser_tx_busy;
	reg [7:0] ser_rx_data;
	reg ser_new_rx_data;
	reg [2047:0] tx_arr;

	// Outputs
	wire [7:0] ser_tx_data;
	wire ser_new_tx_data;
	wire [2047:0] rx_arr;
	wire rx_busy;
	wire new_rx;
	wire tx_busy;

	// Instantiate the Unit Under Test (UUT)
	mojo_com_logic uut (
		.clk(clk), 
		.rst(rst), 
		.ser_tx_data(ser_tx_data), 
		.ser_new_tx_data(ser_new_tx_data), 
		.ser_tx_busy(ser_tx_busy), 
		.ser_rx_data(ser_rx_data), 
		.ser_new_rx_data(ser_new_rx_data), 
		.rx_arr(rx_arr), 
		.rx_busy(rx_busy), 
		.new_rx(new_rx), 
		.tx_arr(tx_arr), 
		.tx_busy(tx_busy)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		ser_tx_busy = 0;
		ser_rx_data = 0;
		ser_new_rx_data = 0;
		tx_arr = 32'hdeadbeef;
      rst = 1'b1;
      repeat(4) #10 clk = ~clk;
      rst = 1'b0;
      forever #10 clk = ~clk; // generate a clock
    end
 
    initial begin
        @(negedge rst); // wait for reset
		  //Test receive
        ser_rx_data = 8'b10000001; //write 1 long to
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
        repeat(100) @(posedge clk);
		  ser_rx_data = 8'b00000010; //@ address 2
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
		  repeat(100) @(posedge clk);
		  ser_rx_data = 8'b00000110; //write 6
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
		  repeat(100) @(posedge clk);
		  //Test send
		  ser_rx_data = 8'b00000001; //write 1 long at
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
        repeat(100) @(posedge clk);
		  ser_rx_data = 8'b00000011; //@ address 3
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
		  repeat(100) @(posedge clk);
		  //Sending data
		  repeat(100) @(posedge clk);

        $finish;
    end
      
endmodule

