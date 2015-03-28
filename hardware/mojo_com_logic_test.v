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
	localparam WATCH_SPACE = 48;
	wire [WATCH_SPACE -1:0] rx_arr_watch;
	assign rx_arr_watch = rx_arr[WATCH_SPACE-1:0];
	wire rx_busy;
	wire new_rx;
	wire tx_busy;
	
	wire [31:0] cur_addr, end_addr;
	wire [2:0] cur_state;

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
		//debug
		, .cur_addr(cur_addr),
		.end_addr(end_addr),
		.cur_state(cur_state)
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
		  ser_rx_data = 8'b10000010; //write 2 long at
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
        repeat(100) @(posedge clk);
		  ser_rx_data = 8'b00000000; //@ address 0
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
		  repeat(100) @(posedge clk);
		  ser_rx_data = 8'had; //write ad
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
		  repeat(100) @(posedge clk);
		  ser_rx_data = 8'hde; //write de
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
		  repeat(1000) @(posedge clk);
		  //Done testing receive, rx_arr[23:0] should == 24'h06dead
		  
		  //TEST SEND!
		  ser_rx_data = 8'b1; //read 1 long from
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
        repeat(100) @(posedge clk);
		  ser_rx_data = 8'b00000000; //@ address 0
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
		  repeat(100) @(posedge clk);
		  ser_rx_data = 8'b11; //read 3 long from
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
        repeat(100) @(posedge clk);
		  ser_rx_data = 8'b1; //@ address 1
		  ser_new_rx_data = 1;
		  repeat(1) @(posedge clk);
		  ser_new_rx_data = 0;
		  repeat(2) @(posedge clk);
		  ser_tx_busy = 1;
		  repeat(10) @(posedge clk);
		  ser_tx_busy = 0;
		  repeat(100) @(posedge clk);
		  //done testing send, ser_tx_data should look like [ef,... be,ad, ... de]
		  //second wait is from ser_tx_busy
		  //Might need to slow down serial response, because don't have busy line
		  

        $finish;
    end
      
endmodule

