module TX (BCLK,reset,tx_din,tx_start,tx_done_tk,tx);
    
    parameter OVERSAMPLE = 16;
    parameter DATA_WIDTH = 8;
    parameter DATA_BITS = $clog2(DATA_WIDTH);
    parameter IDLE = 0;
    parameter START = 1;
    parameter DATA = 2;
    parameter STOP = 3;

    input BCLK,reset;
    input tx_start;
    input [DATA_WIDTH-1:0] tx_din;

    output reg tx_done_tk;
    output reg tx;

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
                if (tx_start == 1) begin
                    tx_done_tk = 1;
                    next_state = START;
                end
                else begin
                    next_state = IDLE;
                    tx_done_tk = 0;
                end
                tk_counter_reset = 1;
                shift_reg_value = 0;
                data_bits_counter_value = 0;
                tx = 1'b1;
            end 

            START: begin
                tx = 1'b0;
                shift_reg_value = tx_din;
                tx_done_tk = 0;
                data_bits_counter_value = 0;
                if (tk_counter == OVERSAMPLE-1) begin
                    tk_counter_reset = 1;
                    next_state = DATA;
                end
                else begin
                    tk_counter_reset = 0;
                    next_state = START;
                end
            end

            DATA: begin
                tx = shift_reg[0];
                tx_done_tk = 0;
                if (tk_counter == OVERSAMPLE-1) begin
                    tk_counter_reset = 1;
                    data_bits_counter_value = 1;
                    shift_reg_value = {1'b0,shift_reg_value[DATA_WIDTH-1:1]};
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
                tx = 1'b1;
                tk_counter_reset = 0;
                data_bits_counter_value = 0;
                tx_done_tk = 0;
                if (tk_counter == OVERSAMPLE-1) begin
                    next_state = IDLE;
                end else begin
                    next_state = STOP;
                end
            end
            default: begin
                tx = 1'b0;
                tk_counter_reset = 1;
                tx_done_tk = 0;
                data_bits_counter_value = 0;
                shift_reg_value = 0;
                next_state = IDLE;
            end
        endcase
    end
endmodule