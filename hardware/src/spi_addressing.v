module spi_addressing (
	input clk,
    input rst,

    // SPI Signals
    output spi_miso,
    input spi_mosi,
    input spi_sck,
    input spi_ss,

    // Register interface signals
    output [5:0] reg_addr,
    output write,
    output new_req,
    output [7:0] write_value,
    input [7:0] read_value,
	output in_transaction
);

wire spi_done;
wire [7:0] spi_dout;
wire frame_start, frame_end;

wire spi_miso_m;

localparam STATE_SIZE = 2;
localparam IDLE = 0,
           ADDR = 1,
           WRITE = 2,
           READ = 3;

reg [STATE_SIZE-1:0] state_d, state_q;

reg [7:0] write_value_d, write_value_q;
reg write_d, write_q;
reg auto_inc_d, auto_inc_q;
reg [5:0] reg_addr_d, reg_addr_q;
reg new_req_d, new_req_q;
reg first_write_d, first_write_q;

assign reg_addr = reg_addr_q;
assign write = write_q;
assign new_req = new_req_q;
assign write_value = write_value_q;

assign spi_miso = !spi_ss ? spi_miso_m : 1'bZ;
assign in_transaction = !spi_ss;

always @(*) begin
    write_value_d = write_value_q;
    write_d = write_q;
    auto_inc_d = auto_inc_q;
    reg_addr_d = reg_addr_q;
    new_req_d = 1'b0;
    state_d = state_q;
    first_write_d = first_write_q;

    case (state_q)
        IDLE: begin
            if (frame_start)
                state_d = ADDR;
        end
        ADDR: begin
            if (spi_done) begin
                first_write_d = 1'b1;
                {write_d, auto_inc_d, reg_addr_d} = spi_dout;
                if (spi_dout[7]) begin
                    state_d = WRITE;
                end else begin
                    state_d = READ;
                    new_req_d = 1'b1;
                end
            end
        end
        WRITE: begin
            if (spi_done) begin
                first_write_d = 1'b0;
                if (auto_inc_q && !first_write_q)
                    reg_addr_d = reg_addr_q + 1'b1;
                new_req_d = 1'b1;
                write_value_d = spi_dout;
            end
        end
        READ: begin
            if (spi_done) begin
                if (auto_inc_q)
                    reg_addr_d = reg_addr_q + 1'b1;
                new_req_d = 1'b1;
            end
        end
        default: state_d = IDLE;
    endcase

    if (frame_end)
        state_d = IDLE;

end

always @(posedge clk) begin
    if (rst) begin
        state_q <= IDLE;
    end else begin
        state_q <= state_d;
    end

    write_value_q <= write_value_d;
    write_q <= write_d;
    auto_inc_q <= auto_inc_d;
    reg_addr_q <= reg_addr_d;
    new_req_q <= new_req_d;
    first_write_q <= first_write_d;
end


endmodule
