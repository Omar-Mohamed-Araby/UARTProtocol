module FIFO(clk_rd,clk_wr,reset,wr_en,rd_en,data_in,data_out,full,empty);
parameter FIFO_WIDTH = 8;
parameter FIFO_DEPTH = 16; 

localparam max_fifo_addr = $clog2(FIFO_DEPTH);

input clk_rd,clk_wr, reset;
input wr_en, rd_en;
input [FIFO_WIDTH-1:0] data_in;

output reg [FIFO_WIDTH-1:0] data_out;
output full, empty;



reg [FIFO_WIDTH-1:0] FIFO_mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] wr_count,rd_count;
wire [max_fifo_addr:0] count;

always @(posedge clk_wr or posedge reset) begin
	if (reset) begin
		wr_ptr <= 0;
	end
	else if (wr_en && !full) begin
		FIFO_mem[wr_ptr] <= data_in;
		wr_ptr <= wr_ptr + 1;
	end
end

always @(posedge clk_rd or posedge reset) begin
	if (reset) begin
		rd_ptr <= 0;
	end
	else if (rd_en && !empty) begin
		data_out <= FIFO_mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
end


always @(posedge clk_wr or posedge reset) begin
	if (reset) begin
		wr_count <= 0;
	end
	else begin
		if	(wr_en && !full)
			wr_count <= wr_count + 1;
		else 
			wr_count <= wr_count;
	end
end

always @(posedge clk_rd or posedge reset) begin
	if (reset) begin
		rd_count <= 0;
	end
	else begin
		if	(rd_en && !empty)
			rd_count <= rd_count + 1;
		else 
			rd_count <= rd_count;
	end
end

assign count = wr_count - rd_count;
assign full = (count == FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;


endmodule