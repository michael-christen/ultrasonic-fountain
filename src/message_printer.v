module message_printer (
    input clk,
    input rst,
    output [7:0] tx_data,
    output reg new_tx_data,
    input tx_busy,
    input [7:0] rx_data,
    input new_rx_data
);
 
localparam STATE_SIZE = 2;
localparam IDLE = 0,
           PRINT_MESSAGE = 1,
			  WAIT_FIRST = 2,
			  END = 3;
 
localparam MESSAGE_LEN = 2;
 
reg [STATE_SIZE-1:0] state_d, state_q;
 
reg [3:0] addr_d, addr_q;
reg [7:0] send_data_d, send_data_q;

wire [7:0] s_data;
message_rom message_rom (
    .clk(clk),
    .addr(addr_q),
    .data(s_data)
);

assign tx_data = send_data_q;
 
always @(*) begin
    state_d = state_q; // default values
    addr_d = addr_q;   // needed to prevent latches
    new_tx_data = 1'b0;
	 send_data_d = send_data_q;
 
    case (state_q)
        IDLE: begin
            addr_d = 4'd0;
            if (new_rx_data) begin
					 send_data_d = rx_data;
                state_d = WAIT_FIRST;
				end
        end
		  WAIT_FIRST: begin
				if (!tx_busy) begin
					new_tx_data = 1'b1;
					state_d = PRINT_MESSAGE;
				end
		  end
        PRINT_MESSAGE: begin
            if (!tx_busy) begin
                new_tx_data = 1'b1;
                addr_d = addr_q + 1'b1;
                if (addr_q == MESSAGE_LEN-1) begin
                    state_d = END;
						  send_data_d = "\n";
					 end
            end
        end
		  END: begin
				if(!tx_busy) begin
					new_tx_data = 1'b1;
					state_d = IDLE;
				end
		  end
        default: state_d = IDLE;
    endcase
end
 
always @(posedge clk) begin
    if (rst) begin
        state_q <= IDLE;
		  send_data_q <= "\n";
    end else begin
        state_q <= state_d;
		  send_data_q <= send_data_d;
    end
 
    addr_q <= addr_d;
end
 
endmodule