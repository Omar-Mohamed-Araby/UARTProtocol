module UART_TOP_tb;

    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10;  // 100 MHz
    parameter BAUD_RATE = 115200;
    parameter OVERSAMPLE = 16;
    parameter CLK_FREQ = 100*(10**6);
    parameter Final_value = ((CLK_FREQ)/(BAUD_RATE * OVERSAMPLE))+0.5; // to ceil the number

    reg UCLK;
    reg reset;
    reg [DATA_WIDTH-1:0] W_data;
    reg wr_uart;
    reg rd_uart;
    wire [DATA_WIDTH-1:0] R_data;
    wire tx_full;
    wire rx_empty;

    UART_TOP #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .UCLK(UCLK),
        .reset(reset),
        .W_data(W_data),
        .wr_uart(wr_uart),
        .tx_full(tx_full),
        .R_data(R_data),
        .rd_uart(rd_uart),
        .rx_empty(rx_empty)
    );
    initial UCLK= 0;
    always #(CLK_PERIOD / 2) UCLK = ~UCLK;


    initial begin
        reset    = 1;
        W_data   = 0;
        wr_uart  = 0;
        rd_uart  = 0;
        // Wait for reset
        #100;
        reset = 0;

        // Write 0xAA and 0x55 to TX FIFO
        @(posedge UCLK);
        W_data  = 8'hAA;
        wr_uart = 1;
        @(posedge UCLK);
        W_data  = 8'h55;
        @(posedge UCLK);
        wr_uart = 0;

        #(16 * 10 * Final_value * CLK_PERIOD);  // Oversample * 10 bits * divisor * clk period

        // Enable read from RX FIFO
        @(posedge UCLK);
        rd_uart = 1;
        @(posedge UCLK);
        rd_uart = 0;
        #100;
        $display("Received Data: %h", R_data);

        #(16 * 10 * Final_value * CLK_PERIOD);
        // Enable read from RX FIFO
        @(posedge UCLK);
        rd_uart = 1;
        @(posedge UCLK);
        rd_uart = 0;

        // Wait a bit and finish
        #100;
        $display("Received Data: %h", R_data);
        $stop;
    end
endmodule