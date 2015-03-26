module mojo_com #(
	parameter ADDR_SPACE = 256,
	parameter SERIAL_BAUD_RATE = 9600
)(
	input clk,
	input rst,
	//UART connections
	output tx,
	input  rx,
	//Interface, doesn't guarantee atomicity
	output reg [7:0] rx_arr [ADDR_SPACE-1:0],
	output rx_busy,
	output new_rx,
	input  [7:0] tx_arr [ADDR_SPACE-1:0],
	output tx_busy
);

//Serial setup
reg [7:0] ser_tx_data;
reg ser_new_tx_data;
wire ser_tx_busy;
wire [7:0] ser_rx_data;
wire ser_new_rx_data;
wire ser_zero;
assign ser_zero = 1'b0;
serial_interface #(.SERIAL_BAUD_RATE(SERIAL_BAUD_RATE)) connector (
	 .clk(clk),
	 .rst(rst),
	 .tx(tx),
	 .rx(rx),
	 .tx_data(ser_tx_data),
	 .new_tx_data(ser_new_tx_data),
	 .tx_busy(ser_tx_busy),
	 .tx_block(ser_zero),
	 .rx_data(ser_rx_data),
	 .new_rx_data(ser_new_rx_data)
);

//Interface setup
reg rx_busy_q, rx_busy_d, tx_busy_q, tx_busy_d, new_rx_q, new_rx_d;
assign rx_busy = rx_busy_q;
assign new_rx  = new_rx_q;
assign tx_busy = tx_busy_q;

//FSM setup
localparam STATE_SIZE = 2;
localparam 	IDLE 	= 0,
			GET_LEN = 1,
			RECEIVE = 2,
			SEND	= 3;	
reg [STATE_SIZE - 1:0] state_d, state_q;

//FSM inputs and parameters
reg write_q, write_d; //Is this a write
reg [7:0] addr_q, addr_d, end_addr_q, end_addr_d; //End addr is last to access
reg [6:0] len;//temp variable to compute end_addr from addr

always @(*) begin
	state_d    = state_q;
	write_d    = write_q;
	addr_d     = addr_q;
	end_addr_d = end_addr_q;
	//Interface
	rx_busy_d = rx_busy_q;
	tx_busy_d = tx_busy_q;
	new_rx_d  = 0;
	//Serial comms
	ser_new_tx_data = 0;


	case(state_q)
		IDLE: begin
			if(ser_new_rx_data) begin
				write_d = ser_rx_data[7];
				len     = ser_rx_data[6:0]-1;
				//TODO:len 0 could mess stuff up
				if(ser_rx_data[6:0] == 0) begin
					state_d = IDLE;
				end else begin
					state_d = GET_LEN;
				end
			end
		end
		GET_LEN: begin
			if(ser_new_rx_data) begin
				addr_d     = ser_rx_data;
				end_addr_d = ser_rx_data + len;
				if(write_q) begin
					tx_busy_d = 1;
					state_d = SEND;
				end else begin
					rx_busy_d = 1;
					state_d = RECEIVE;
				end
			end
		end
		RECEIVE: begin
			if(ser_new_rx_data) begin
				rx_arr[addr_d] = ser_rx_data;//TODO, might need reg
				if(addr_d == end_addr_q) begin
					new_rx_d  = 1;
					rx_busy_d = 0;
					state_d   = IDLE;
				end
				addr_d = addr_d + 1;
			end
		end
		SEND: begin
			if(~ser_tx_busy) begin
				ser_tx_data = tx_arr[addr_d];
				ser_new_tx_data = 1;
				if(addr_d == end_addr_q) begin
					tx_busy_d = 0;
					state_d = IDLE;
				end
				addr_d = addr_d + 1;
			end
		end
		default: state_d = IDLE;
	endcase
end

always @(posedge clk) begin
	if(rst) begin
		state_q <= IDLE;
	end else begin
		state_q <= state_d;
	end
end

endmodule
