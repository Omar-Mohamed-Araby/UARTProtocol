module TX_TOP (UCLK,BCLK,reset,W_data,wr_uart,tx,tx_full/*,wr_rst_busy,rd_rst_busy*/);
    parameter OVERSAMPLE = 16;
    parameter DATA_WIDTH = 8;
    parameter DATA_BITS = $clog2(DATA_WIDTH);

    input UCLK,BCLK,reset;
    input [DATA_WIDTH-1:0] W_data;
    input wr_uart;

    output tx_full,tx;
    //output wr_rst_busy,rd_rst_busy;

    wire tx_done_tk;
    wire [DATA_WIDTH-1:0] tx_din;
    wire empty;

    TX tx_blk (BCLK,reset,tx_din,!(empty),tx_done_tk,tx); 

    // you can use the fifo generator block that is in ip catalog in VIVADO and customize it
    /* fifo_generator_0 tx_fifo (
  .rst(reset),                  // input wire rst
  .wr_clk(UCLK),            // input wire wr_clk
  .rd_clk(BCLK),            // input wire rd_clk
  .din(W_data),                  // input wire [7 : 0] din
  .wr_en(wr_uart),              // input wire wr_en
  .rd_en(tx_done_tk),              // input wire rd_en
  .dout(tx_din),                // output wire [7 : 0] dout
  .full(tx_full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);*/ 
    FIFO tx_fifo (BCLK,UCLK,reset,wr_uart,tx_done_tk,W_data,tx_din,tx_full,empty);
endmodule