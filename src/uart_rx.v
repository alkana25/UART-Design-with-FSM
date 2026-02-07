`timescale 1ns / 1ps

module uart_rx(
    input wire clk,
    input wire rst,
    input wire rx,           
    input wire rx_en,        
    input wire tick_8x,      
    
    output reg [7:0] rx_data, 
    output reg rx_start,     
    output reg rx_busy,      
    output reg rx_done        
    );

    // Durumlar
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] tick_cnt;  
    reg [2:0] bit_cnt;    
    reg [1:0] vote_cnt;   
    reg [7:0] shift_reg;  

   
    reg rx_sync1, rx_sync2;
    wire rx_in = rx_sync2;

    always @(posedge clk) begin
        if (rst) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    
    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            tick_cnt  <= 0;
            bit_cnt   <= 0;
            vote_cnt  <= 0;
            shift_reg <= 0;
            rx_data   <= 0;
            rx_busy   <= 0;
            rx_done   <= 0;
            rx_start  <= 0;
        end else begin
            
            rx_done  <= 0;
            rx_start <= 0;

            case (state)
                
                IDLE: begin
                    rx_busy <= 0;
                    tick_cnt <= 0;
                    bit_cnt <= 0;
                    
                    if (rx_en && rx_in == 1'b0) begin 
                        state    <= START;
                        rx_busy  <= 1;
                        rx_start <= 1; 
                    end
                end

                
                START: begin
                    if (tick_8x) begin
                     
                        if (tick_cnt == 3) begin 
                            if (rx_in == 1'b1) begin
                                state   <= IDLE;
                                rx_busy <= 0;
                            end
                        end
  
                        if (tick_cnt == 7) begin
                            state    <= DATA;
                            tick_cnt <= 0;
                            vote_cnt <= 0;
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end

                DATA: begin
                    if (tick_8x) begin

                        if (tick_cnt == 3 || tick_cnt == 4 || tick_cnt == 5) begin
                            if (rx_in == 1'b1)
                                vote_cnt <= vote_cnt + 1;
                        end

                        if (tick_cnt == 7) begin
                            tick_cnt <= 0;
                            shift_reg <= { (vote_cnt >= 2), shift_reg[7:1] };
                            
                            vote_cnt <= 0; 

                            if (bit_cnt == 7) 
                                state <= STOP;
                            else
                                bit_cnt <= bit_cnt + 1;
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end

                STOP: begin
                    if (tick_8x) begin
                        if (tick_cnt == 7) begin
                            state   <= IDLE;
                            rx_done <= 1;         
                            rx_data <= shift_reg; 
                            rx_busy <= 0;
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end

endmodule
