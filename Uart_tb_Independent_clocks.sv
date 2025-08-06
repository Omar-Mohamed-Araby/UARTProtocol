module UART_TOP_tb;

    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD_tx = 8;  // 125 MHz
    parameter CLK_PERIOD_rx = 10;  // 100 MHz

    reg UCLK_tx,UCLK_rx;
    reg reset;
    reg [DATA_WIDTH-1:0] W_data;
    reg wr_uart;
    reg rd_uart;
    wire [DATA_WIDTH-1:0] R_data;
    wire tx_full;
    wire rx_empty;

    UART_TOP #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .UCLK_tx(UCLK_tx),
        .UCLK_rx(UCLK_rx),
        .reset(reset),
        .W_data(W_data),
        .wr_uart(wr_uart),
        .tx_full(tx_full),
        .R_data(R_data),
        .rd_uart(rd_uart),
        .rx_empty(rx_empty)
    );
    initial UCLK_tx = 0;
    always #(CLK_PERIOD_tx / 2) UCLK_tx = ~UCLK_tx;

    initial UCLK_rx = 0;
    always #(CLK_PERIOD_rx / 2) UCLK_rx = ~UCLK_rx;

    initial begin
        reset    = 1;
        W_data   = 0;
        wr_uart  = 0;
        rd_uart  = 0;
        // Wait for reset
        #100;
        reset = 0;

        // Write 0xAA and 0x55 to TX FIFO
        @(posedge UCLK_tx);
        W_data  = 8'hAA;
        wr_uart = 1;
        @(posedge UCLK_tx);
        W_data  = 8'h55;
        @(posedge UCLK_tx);
        wr_uart = 0;

        #(16 * 10 * 54 * CLK_PERIOD_rx);  // Oversample * 10 bits * divisor * clk period

        // Enable read from RX FIFO
        @(posedge UCLK_rx);
        rd_uart = 1;
        @(posedge UCLK_rx);
        rd_uart = 0;
        #100;
        $display("Received Data: %h", R_data);

        #(16 * 10 * 54 * CLK_PERIOD_rx);
        // Enable read from RX FIFO
        @(posedge UCLK_rx);
        rd_uart = 1;
        @(posedge UCLK_rx);
        rd_uart = 0;

        // Wait a bit and finish
        #100;
        $display("Received Data: %h", R_data);
        $stop;
    end
endmodule
