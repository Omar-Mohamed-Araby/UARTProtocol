module RX (BCLK,reset,rx_dout,rx_write,rx_done_tk,rx);
    
    parameter OVERSAMPLE = 16;
    parameter DATA_WIDTH = 8;
    parameter DATA_BITS = $clog2(DATA_WIDTH);
    parameter IDLE = 0;
    parameter START = 1;
    parameter DATA = 2;
    parameter STOP = 3;

    input BCLK,reset;
    input rx;
    input rx_write;

    output reg [DATA_WIDTH-1:0] rx_dout;
    output reg rx_done_tk;

    reg [1:0] current_state ,next_state;
    reg [DATA_WIDTH-1:0] shift_reg,shift_reg_value;
    reg [3:0] tk_counter,tk_counter_reset;
    reg [DATA_BITS-1:0] data_bits_counter,data_bits_counter_value;

    always @(posedge BCLK or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            tk_counter <= 0;
            shift_reg <= 0;
            data_bits_counter <= 0;
        end
        else begin
            current_state <= next_state;
            shift_reg <= shift_reg_value;
            data_bits_counter <= data_bits_counter + data_bits_counter_value;
            if (tk_counter_reset) begin
                tk_counter <= 0;
            end
            else tk_counter = tk_counter + 1;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE:begin
                if (rx == 0) begin
                    next_state = START;
                end
                else begin
                    next_state = IDLE;
                end
                tk_counter_reset = 1;
                data_bits_counter_value = 0;
                shift_reg_value = 0;
                rx_done_tk = 0;
                rx_dout = 0;
            end 

            START: begin
                rx_done_tk = 0;
                rx_dout = 0;
                data_bits_counter_value = 0;
                if (tk_counter == (OVERSAMPLE/2)-1) begin
                    tk_counter_reset = 1;
                    next_state = DATA;
                end
                else begin
                    tk_counter_reset = 0;
                    next_state = START;
                end
            end

            DATA: begin
                rx_done_tk = 0;
                rx_dout = 0;
                if (tk_counter == OVERSAMPLE-1) begin
                    tk_counter_reset = 1;
                    data_bits_counter_value = 1;
                    shift_reg_value = {rx,shift_reg_value[DATA_WIDTH-1:1]};
                    if (data_bits_counter == DATA_WIDTH-1) begin
                        next_state = STOP;
                    end else begin
                        next_state = DATA;
                    end
                end
                else begin
                    tk_counter_reset = 0;
                    data_bits_counter_value = 0;
                    shift_reg_value = shift_reg;
                end
            end

            STOP: begin
                tk_counter_reset = 0;
                data_bits_counter_value = 0;
                if (tk_counter == OVERSAMPLE-1) begin
                    rx_done_tk = 1;
                    if (rx_write) begin
                        rx_dout = 0;  
                    end
                    else
                        rx_dout = shift_reg;
                        
                    next_state = IDLE;
                end else begin
                    rx_done_tk = 0;
                    rx_dout = 0;
                    next_state = STOP;
                end
            end
            default: begin
                tk_counter_reset = 1;
                rx_done_tk = 0;
                data_bits_counter_value = 0;
                shift_reg_value = 0;
                next_state = IDLE; rx_dout = 0;
            end
        endcase
    end
endmodule