module RX_TOP (UCLK,BCLK,reset,R_data,rd_uart,rx,rx_empty/*,wr_rst_busy,rd_rst_busy*/);
    parameter OVERSAMPLE = 16;
    parameter DATA_WIDTH = 8;
    parameter DATA_BITS = $clog2(DATA_WIDTH);

    input UCLK,BCLK,reset;
    input rx;
    input rd_uart;

    output rx_empty;
    output [DATA_WIDTH-1:0] R_data;
    //output wr_rst_busy,rd_rst_busy;

    wire rx_done_tk;
    wire [DATA_WIDTH-1:0] rx_dout;
    wire full;

    RX rx_blk (BCLK,reset,rx_dout,full,rx_done_tk,rx);
    
// you can use the fifo generator block that is in ip catalog in VIVADO and customize it
   /* fifo_generator_0 rx_fifo (
  .rst(reset),                  // input wire rst
  .wr_clk(BCLK),            // input wire wr_clk
  .rd_clk(UCLK),            // input wire rd_clk
  .din(rx_dout),                  // input wire [7 : 0] din
  .wr_en(rx_done_tk),              // input wire wr_en
  .rd_en(rd_uart),              // input wire rd_en
  .dout(R_data),                // output wire [7 : 0] dout
  .full(full),                // output wire full
  .empty(rx_empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);*/
    FIFO rx_fifo (UCLK,BCLK,reset,rx_done_tk,rd_uart,rx_dout,R_data,full,rx_empty);
endmodule