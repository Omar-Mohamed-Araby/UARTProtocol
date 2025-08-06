module UART_TOP (UCLK,reset,W_data,wr_uart,tx,tx_full,R_data,rd_uart,rx,rx_empty);
//(UCLK,reset,W_data,wr_uart,tx_full,R_data,rd_uart,rx_empty);
    parameter OVERSAMPLE = 16;
    parameter DATA_WIDTH = 8;
    parameter DATA_BITS = $clog2(DATA_WIDTH);
    
    
    input UCLK,reset;
    input [DATA_WIDTH-1:0] W_data;
    input wr_uart;
    input rx;
    input rd_uart;

    output rx_empty;
    output [DATA_WIDTH-1:0] R_data;
    output tx_full;
    output tx;

   // wire tx_rx; 
    /* connect tx with rx for only simulation cases as for real case 
    the tx is the output from the uart connected to rx from another uart block and vise vera*/

    wire BCLK;

    Baud_Gen baun_generator (UCLK,reset,BCLK);
    TX_TOP tx_top_blk (UCLK,BCLK,reset,W_data,wr_uart,tx,tx_full);
    RX_TOP rx_top_blk (UCLK,BCLK,reset,R_data,rd_uart,rx,rx_empty);

    //TX_TOP tx_top_blk (UCLK,BCLK,reset,W_data,wr_uart,tx_rx,tx_full);
    //RX_TOP rx_top_blk (UCLK,BCLK,reset,R_data,rd_uart,tx_rx,rx_empty);

endmodule


 //(* dont_touch = "true" *)