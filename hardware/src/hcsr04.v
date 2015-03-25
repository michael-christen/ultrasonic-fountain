`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Michael Christen
// 
// Create Date:    11:32:43 03/09/2015 
// Design Name: 
// Module Name:    hcsr04 
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
module hcsr04 #(
	parameter TRIGGER_DURATION = 500,
	parameter MAX_COUNT = 3000000
)(
	input rst,
	input clk,
	input tclk,
	input measure,
	input echo,
	
	output reg [15:0] ticks,
	output reg valid,
	output reg trigger
    );
	 
    localparam STATE_SIZE = 3,
	 CTR_SIZE = 16;
    localparam STATE_RESET = 3'd0,
    STATE_IDLE = 3'd1,
    STATE_TRIGGER = 3'd2,
	 STATE_COUNT = 3'd3,
	 STATE_COOLDOWN = 3'd4;
	 
	 reg [CTR_SIZE-1:0] ctr_d, ctr_q;
	 reg [STATE_SIZE-1:0] state_d, state_q;
	 reg [15:0] ticks_d;
	 reg trigger_d, valid_d;
	 reg echo_old;
	 
	 reg echo_chg, echo_pos, echo_neg;
	 
	 
	 always @(*) begin
		echo_chg = echo_old ^ echo;
		echo_pos = echo_chg & echo;
		echo_neg = echo_chg & (~echo);
		ctr_d = ctr_q;
		state_d = state_q;
		trigger_d = 0;
		valid_d = valid;
		ticks_d = ticks;
		
		case (state_q)
			STATE_RESET: begin
				ctr_d = 0;
				valid_d = 0;
				ticks_d = 0;
				state_d = STATE_IDLE;
			end
			STATE_IDLE: begin
				ctr_d = 0;
				if(measure) begin
					state_d = STATE_TRIGGER;
				end else begin
					state_d = STATE_IDLE;
				end
			end
			STATE_TRIGGER: begin
				if(tclk) begin
					ctr_d = ctr_q + 1;
				end
				trigger_d = 1'b1;
				if(ctr_q == TRIGGER_DURATION) begin
					state_d = STATE_COUNT;
				end
			end
			STATE_COUNT: begin
				if(tclk) begin
					ctr_d = ctr_q + 1;
				end
				if(ctr_q == MAX_COUNT) begin
					ticks_d = MAX_COUNT;
					state_d = STATE_IDLE;
				end else if(echo_neg) begin
					ticks_d = ctr_q;
					valid_d = 1'b1;
					state_d = STATE_IDLE;
				end else if(echo_pos) begin
					ctr_d = 0;
				end
			end
		endcase
	 end

    always @(posedge clk) begin
        if (rst) begin
            state_q <= STATE_RESET;
				ctr_q   <= 0;
				ticks   <= 0;
				valid   <= 0;
				trigger <= 0;
				echo_old <= 0;
        end else begin
				state_q <= state_d;
				ctr_q   <= ctr_d;
				ticks   <= ticks_d;
				valid   <= valid_d;
				trigger <= trigger_d;
				echo_old <= echo;
		  end
	 end 

endmodule
