`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:07:01 03/24/2015
// Design Name:   hcsr04
// Module Name:   /home/michael/Projects/mojo/ultrasonic-fountain/hcsr04_test.v
// Project Name:  Mojo-Base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: hcsr04
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module hcsr04_test;

	// Inputs
	reg rst;
	reg clk;
	reg measure;
	reg echo;

	// Outputs
	wire [15:0] ticks;
	wire valid;
	wire trigger;

	wire clk_10us;
	clk_divider #(.DIV(500)) clk_10usmodule(
		.rst(rst),
		.clk(clk),
		.div_clk(clk_10us)
	);
	// Instantiate the Unit Under Test (UUT)
	hcsr04 #(
		.TRIGGER_DURATION(1),
		.MAX_COUNT(3800)
	)	uut (
		.rst(rst), 
		.clk(clk), 
		.tclk(clk_10us),
		.measure(measure), 
		.echo(echo), 
		.ticks(ticks), 
		.valid(valid), 
		.trigger(trigger)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;
		measure = 0;
		echo = 0;
      clk = 1'b0;
      rst = 1'b1;
      repeat(4) #10 clk = ~clk;
      rst = 1'b0;
      forever #10 clk = ~clk; // generate a clock
    end
 
    initial begin
        measure = 0; // initial value
        @(negedge rst); // wait for reset
        measure = 1;
        repeat(5000) @(posedge clk); //wait for trigger to finish, 10us
        echo = 1;
        repeat(100000) @(posedge clk); //echo for 10ms
		  echo = 0;
		  repeat (100000) @(posedge clk);
        $finish;
    end
      
endmodule

