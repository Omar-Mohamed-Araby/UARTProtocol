module Baud_Gen (clk,reset,BCLK);
    parameter BAUD_RATE = 921600;
    parameter OVERSAMPLE = 16;
    parameter CLK_FREQ = 100*(10**6);
    parameter Final_value = ((CLK_FREQ)/(BAUD_RATE * OVERSAMPLE))+0.5; // to ceil the number

    input clk,reset;
    output reg BCLK;

    wire [15:0] divisor;
    reg [15:0] counter;

    assign divisor = Final_value;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            BCLK <= 0;
            counter <=0;
        end
        else if (counter == (divisor-1)) begin
            BCLK <= 1;
            counter <= 0;
        end
        else begin
            BCLK <= 0;
            counter <= counter + 1;
        end
    end
endmodule