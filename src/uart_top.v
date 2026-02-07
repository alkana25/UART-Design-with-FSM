`timescale 1ns / 1ps

module uart_top (
    input wire clk,           
    input wire rst,           
    input wire baud_select,  

    input wire tx_en,       
    input wire [7:0] tx_data, 
    output wire tx,         
    output wire tx_busy,     
    output wire tx_done,      
    
   
    input wire rx,            
    input wire rx_en,         
    output wire [7:0] rx_data,
    output wire rx_busy,    
    output wire rx_done      
);

    wire tick_1x_w; 
    wire tick_8x_w; 
    
    wire tx_start_unused;
    wire rx_start_unused;

    // ----------------------------------------------------------------
    // 1. BAUD RATE GENERATOR INSTANCE
    // ----------------------------------------------------------------
    baud_gen inst_baud_gen (
        .clk(clk),
        .rst(rst),
        .baud_select(baud_select),
        .tick_1x(tick_1x_w),
        .tick_8x(tick_8x_w)  
    );

    // ----------------------------------------------------------------
    // 2. UART TRANSMITTER INSTANCE
    // ----------------------------------------------------------------
uart_tx inst_uart_tx (
        .clk(clk),
        .rst(rst),
        .tx_en(tx_en),
        .tick_8x(tick_8x_w), 
        .tx_data(tx_data),
        .tx_serial(tx),
        .busy(tx_busy),
        .done(tx_done)

    );;

    // ----------------------------------------------------------------
    // 3. UART RECEIVER INSTANCE
    // ----------------------------------------------------------------
    uart_rx inst_uart_rx (
        .clk(clk),
        .rst(rst),
        .rx(rx),               
        .rx_en(rx_en),
        .tick_8x(tick_8x_w),   
        .rx_data(rx_data),
        .rx_start(rx_start_unused),
        .rx_busy(rx_busy),
        .rx_done(rx_done)
    );

endmodule
