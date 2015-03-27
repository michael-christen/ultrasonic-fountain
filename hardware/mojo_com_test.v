`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:09:24 03/26/2015
// Design Name:   mojo_com
// Module Name:   /home/michael/Projects/mojo/ultrasonic-fountain/hardware/mojo_com_test.v
// Project Name:  Mojo-Base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mojo_com
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mojo_com_test;

	// Inputs
	reg clk;
	reg rst;
	//reg rx;
	localparam DATA_SIZE = 1;
	reg [DATA_SIZE * 8 -1:0] tx_arr;

	// Outputs
	//wire tx;
	reg [DATA_SIZE * 8 -1:0] rx_arr;
	//wire rx_busy;
	//wire new_rx;
	//wire tx_busy;

	// Instantiate the Unit Under Test (UUT)
	/*
	mojo_com uut (
		.clk(clk), 
		.rst(rst), 
		.tx(tx), 
		.rx(rx), 
		.rx_arr(rx_arr), 
		.rx_busy(rx_busy), 
		.new_rx(new_rx), 
		.tx_arr(tx_arr), 
		.tx_busy(tx_busy)
	);
	*/
	assign tx_arr = 8'h01;
		//{8'h01,8'h01,8'h02,8'hff,96'b0};
	reg [7:0] tmp_tx_q, tmp_tx_d;
	reg [0:0] addr_q, addr_d;
	always @(*) begin
		addr_d = addr_q + 1;
		tmp_tx_d = tx_arr[addr_q+:7];
      rx_arr[addr_q+:7] = tmp_tx_q;
	end
	always @(posedge clk) begin
		if(rst) begin
			addr_q <= 0;
			tmp_tx_q <= 0;
		end else begin
			addr_q <= addr_d;
			tmp_tx_q <= tmp_tx_d;
		end
	end

	initial begin
		// Initialize Inputs
      clk = 1'b0;
      rst = 1'b1;
      repeat(4) #10 clk = ~clk;
      rst = 1'b0;
      forever #10 clk = ~clk; // generate a clock
    end
	 
    initial begin
        @(negedge rst); // wait for reset

        repeat(17) @(posedge clk); //wait for trigger to finish, 10us
        $finish;
    end
      
endmodule

