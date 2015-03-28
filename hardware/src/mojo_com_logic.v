module mojo_com_logic #(
	parameter ADDR_SPACE = 256
)(
	input clk,
	input rst,
	//Serial Interface 
	output [7:0] ser_tx_data,
	output ser_new_tx_data,
	input ser_tx_busy,
	input [7:0] ser_rx_data,
	input ser_new_rx_data,
	//Interface, doesn't guarantee atomicity
	output [8*ADDR_SPACE-1:0] rx_arr,
	output rx_busy,
	output new_rx,
	input [8*ADDR_SPACE-1:0] tx_arr,
	output tx_busy
	//DEBUG params
	, output [ADDR_BIT_COUNT - 1:0] cur_addr,
	output [ADDR_BIT_COUNT - 1:0] end_addr,
	output [STATE_SIZE - 1:0] cur_state
);
parameter WORD_SIZE = 8;
parameter ADDR_BITS = ADDR_SPACE * 8; //Number of bits in addressable arrs
parameter ADDR_BIT_COUNT = $clog2(ADDR_BITS); //Number of bits to address all bits
assign cur_addr = addr_q;
assign end_addr = end_addr_q;
assign cur_state = state_q;

//Interface setup
reg [ADDR_BITS-1:0] rx_arr_q, rx_arr_d;
reg rx_busy_q, rx_busy_d, tx_busy_q, tx_busy_d, new_rx_q, new_rx_d;
assign rx_arr = rx_arr_q;
assign rx_busy = rx_busy_q;
assign new_rx  = new_rx_q;
assign tx_busy = tx_busy_q;

//Serial setup
reg [WORD_SIZE-1:0] ser_tx_data_q, ser_tx_data_d;
reg ser_new_tx_data_q, ser_new_tx_data_d;
assign ser_tx_data = ser_tx_data_q;
assign ser_new_tx_data = ser_new_tx_data_q;
wire ser_tx_busy;
wire [WORD_SIZE-1:0] ser_rx_data;
wire ser_new_rx_data;

//FSM setup
localparam STATE_SIZE = 2;
localparam 	IDLE 	= 0,
			GET_ADDR = 1,
			RECEIVE = 2,
			SEND	= 3;	
reg [STATE_SIZE - 1:0] state_d, state_q;

//FSM inputs and parameters
reg write_q, write_d; //Is this a write
reg [ADDR_BIT_COUNT - 1:0] addr_q, addr_d, end_addr_q, end_addr_d; //End addr is last to access
reg [ADDR_BIT_COUNT - 1:0] len_q, len_d;//temp variable to compute end_addr from addr

always @(*) begin
	state_d    = state_q;
	write_d    = write_q;
	addr_d     = addr_q;
	end_addr_d = end_addr_q;
	len_d = len_q;
	//Interface
	rx_busy_d = rx_busy_q;
	tx_busy_d = tx_busy_q;
	new_rx_d  = 0;
	rx_arr_d = rx_arr_q;
	//Serial comms
	ser_tx_data_d = 0;
	ser_new_tx_data_d = 0;


	case(state_q)
		IDLE: begin
			if(ser_new_rx_data) begin
				//Write to FPGA
				write_d   = ser_rx_data[7];
				len_d     = ser_rx_data[6:0]- 7'd1;
				//TODO:len 0 could mess stuff up
				if(ser_rx_data[6:0] == 0) begin
					state_d = IDLE;
				end else begin
					state_d = GET_ADDR;
				end
			end
		end
		GET_ADDR: begin
			if(ser_new_rx_data) begin
				addr_d     = ser_rx_data * WORD_SIZE;//{ser_rx_data, 3'b0}; //ser_rx_data * WORD_SIZE; 
				end_addr_d = addr_d + len_q * WORD_SIZE;//{len_q, 3'b0}; //len_q * WORD_SIZE;
				if(write_q) begin
					rx_busy_d = 1;
					state_d = RECEIVE;
				end else begin
					tx_busy_d = 1;
					state_d = SEND;
				end
			end
		end
		RECEIVE: begin
			if(ser_new_rx_data) begin
				rx_arr_d[addr_q+:WORD_SIZE] = ser_rx_data;//TODO, might need reg
				if(addr_q == end_addr_q) begin
					new_rx_d  = 1;
					rx_busy_d = 0;
					state_d   = IDLE;
				end
				addr_d = addr_q + WORD_SIZE;
			end
		end
		SEND: begin
			if(~ser_tx_busy) begin
				ser_tx_data_d = tx_arr[addr_q+:WORD_SIZE];
				ser_new_tx_data_d = 1;
				if(addr_q == end_addr_q) begin
					tx_busy_d = 0;
					state_d = IDLE;
				end
				addr_d = addr_q + WORD_SIZE;
			end
		end
		default: state_d = IDLE;
	endcase
end

always @(posedge clk) begin
	if(rst) begin
		state_q <= IDLE;
		write_q <= 0;
		addr_q  <= 0;
		end_addr_q  <= 0;
		len_q <= 0;

		ser_tx_data_q <= 0;
		ser_new_tx_data_q <= 0;

		rx_busy_q <= 0;
		tx_busy_q <= 0;
		new_rx_q  <= 0;
		rx_arr_q <= 0;
	end else begin
		state_q <= state_d;
		write_q <= write_d;
		addr_q  <= addr_d;
		end_addr_q  <= end_addr_d;
		len_q <= len_d;

		ser_tx_data_q <= ser_tx_data_d;
		ser_new_tx_data_q <= ser_new_tx_data_d;

		rx_busy_q <= rx_busy_d;
		tx_busy_q <= tx_busy_d;
		new_rx_q  <= new_rx_d;
		rx_arr_q  <= rx_arr_d;
	end
end

endmodule
