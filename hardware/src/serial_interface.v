`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:40:21 03/23/2015 
// Design Name: 
// Module Name:    serial_interface 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module serial_interface #(
    parameter CLK_RATE = 50000000,
    parameter SERIAL_BAUD_RATE = 500000
    )(
    input clk,
    input rst,
	 
	 //Serial Signals
	 output tx,
    input rx,
	 
	 // Serial TX User Interface
    input [7:0] tx_data,
    input new_tx_data,
    output tx_busy,
    input tx_block,

    // Serial Rx User Interface
    output [7:0] rx_data,
    output new_rx_data
);

// CLK_PER_BIT is the number of cycles each 'bit' lasts for
// rtoi converts a 'real' number to an 'integer'
parameter CLK_PER_BIT = $rtoi($ceil(CLK_RATE/SERIAL_BAUD_RATE));
serial_rx #(.CLK_PER_BIT(CLK_PER_BIT)) serial_rx (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .data(rx_data),
    .new_data(new_rx_data)
);

serial_tx #(.CLK_PER_BIT(CLK_PER_BIT)) serial_tx (
    .clk(clk),
    .rst(rst),
    .tx(tx),
    .block(tx_block),
    .busy(tx_busy),
    .data(tx_data),
    .new_data(new_tx_data)
);


	 
endmodule
