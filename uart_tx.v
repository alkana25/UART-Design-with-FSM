`timescale 1ns / 1ps

module uart_tx (
    input  wire       clk,       
    input  wire       rst,       
    input  wire       tx_en,    
    input  wire       tick_8x,   
    input  wire [7:0] tx_data,   
    output reg        tx_serial, 
    output reg        busy,      
    output reg        done       
);


    localparam [1:0] 
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    // Registerlar
    reg [1:0] state_reg, state_next;
    reg [2:0] s_reg, s_next; 
    reg [2:0] n_reg, n_next; 
    reg [7:0] b_reg, b_next; 
    reg       tx_reg, tx_next; 

   
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= IDLE;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
            tx_reg    <= 1'b1; 
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
            tx_reg    <= tx_next;
        end
    end

  
    always @(*) begin
        state_next = state_reg;
        s_next     = s_reg;
        n_next     = n_reg;
        b_next     = b_reg;
        tx_next    = tx_reg;
        
        busy = 1'b1; 
        done = 1'b0;

        case (state_reg)
            IDLE: begin
                tx_next = 1'b1;
                busy    = 1'b0;
                
                if (tx_en) begin
                    b_next = tx_data;
                    state_next = START;
                    s_next = 0;
                end
            end

            START: begin
                tx_next = 1'b0; 
                
                if (tick_8x) begin
                    if (s_reg == 7) begin 
                        state_next = DATA;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = b_reg[0]; 
                
                if (tick_8x) begin
                    if (s_reg == 7) begin
                        s_next = 0;
                        b_next = b_reg >> 1;
                        
                        if (n_reg == 7) begin
                            state_next = STOP;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1; 
                
                if (tick_8x) begin
                    if (s_reg == 7) begin
                        state_next = IDLE;
                        done       = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
        endcase
    end


    always @(*) tx_serial = tx_reg;

endmodule