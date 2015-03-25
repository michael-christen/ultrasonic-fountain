`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:03:09 03/24/2015
// Design Name:   clk_divider
// Module Name:   /home/michael/Projects/mojo/ultrasonic-fountain/clk_divider_test.v
// Project Name:  Mojo-Base
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: clk_divider
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module clk_divider_test;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire div_clk_2, div_clk_3, div_clk_4;

	// Instantiate the Unit Under Test (UUT)
	clk_divider #(.DIV(2)) uut2 (
		.rst(rst), 
		.clk(clk), 
		.div_clk(div_clk_2)
	);
	clk_divider #(.DIV(3)) uut3 (
		.rst(rst), 
		.clk(clk), 
		.div_clk(div_clk_3)
	);
	clk_divider #(.DIV(500)) uut4 (
		.rst(rst), 
		.clk(clk), 
		.div_clk(div_clk_4)
	);
	
	reg [31:0] ctr_d, ctr_q;
	always @(*) begin
		ctr_d = ctr_q;
		if(div_clk_4) begin
			ctr_d = ctr_q + 1;
		end
	end
	always @(posedge clk) begin
		if (rst) begin
			ctr_q <= 0;
		end else begin
			ctr_q <= ctr_d;
		end
	end

	initial begin
		// Initialize Inputs
		clk = 0;
      rst = 1'b1;
      repeat(4) #10 clk = ~clk;
      rst = 1'b0;
      forever #10 clk = ~clk; // generate a clock
    end
 
    initial begin
        @(negedge rst); // wait for reset
        repeat(5000) @(posedge clk); //wait for trigger to finish, 10us
        $finish;
    end
      
endmodule

