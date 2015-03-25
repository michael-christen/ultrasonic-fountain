`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:35 03/24/2015 
// Design Name: 
// Module Name:    clk_divider 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: DIV min is 2, don't do 1 or 0
//
//////////////////////////////////////////////////////////////////////////////////
module clk_divider #(
	parameter DIV = 2
)(
	input rst,
	input clk,
	output div_clk
    );
	 
    parameter CTR_SIZE = $clog2(DIV);
	 reg [CTR_SIZE-1:0] ctr_d, ctr_q;
	 reg div_clk_d, div_clk_q;
	 assign div_clk = div_clk_q;
	 
	 always @(*) begin
		div_clk_d = div_clk_q;
		ctr_d     = ctr_q + 1;
		//Div clk goes high at 0, and lasts period of clk
		if (ctr_q == 0) begin
			div_clk_d = 1;
		end else begin
			div_clk_d = 0;
		end
		//Restart when reach DIV cnts
		if(ctr_q == DIV-1) begin
			ctr_d = 0;
		end
	 end

	 always @(posedge clk) begin
		if (rst) begin
			div_clk_q <= 0;
			ctr_q     <= 0;
		end else begin
			div_clk_q <= div_clk_d;
			ctr_q     <= ctr_d;
		end
	 end
	 
endmodule
