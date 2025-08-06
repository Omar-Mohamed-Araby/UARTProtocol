module UART_TOP //(UCLK,reset,W_data,wr_uart,tx,tx_full,R_data,rd_uart,rx,rx_empty);     // for Synthesis (normal case (same clock))
(UCLK,reset,W_data,wr_uart,tx_full,R_data,rd_uart,rx_empty); // connect tx with rx for only simulation cases 
    parameter OVERSAMPLE = 16;
    parameter DATA_WIDTH = 8;
    parameter DATA_BITS = $clog2(DATA_WIDTH);
    
    
    //input UCLK_tx,UCLK_rx;
    input reset;
    input UCLK;
    input [DATA_WIDTH-1:0] W_data;
    input wr_uart;
    //input rx;
    input rd_uart;

    output rx_empty;
    output [DATA_WIDTH-1:0] R_data;
    output tx_full;
    //output tx;

    wire tx_rx; 
    /* connect tx with rx for only simulation cases as for real case 
    the tx is the output from the uart connected to rx from another uart block and vise vera*/

    //wire BCLK_tx,BCLK_rx;

    wire BCLK;

    //Baud_Gen  #(.CLK_FREQ(125*(10**6))) baun_generator_tx (UCLK_tx,reset,BCLK_tx);
    //Baud_Gen  #(.CLK_FREQ(100*(10**6)))  baun_generator_rx (UCLK_rx,reset,BCLK_rx);  

    TX_TOP tx_top_blk (UCLK,BCLK,reset,W_data,wr_uart,tx_rx,tx_full);
    RX_TOP rx_top_blk (UCLK,BCLK,reset,R_data,rd_uart,tx_rx,rx_empty);

    // for Synthesis (normal case (same clock))
    Baud_Gen  baun_generator (UCLK,reset,BCLK); 
    //TX_TOP tx_top_blk (UCLK,BCLK,reset,W_data,wr_uart,tx,tx_full);
    //RX_TOP rx_top_blk (UCLK,BCLK,reset,R_data,rd_uart,rx,rx_empty);

endmodule
