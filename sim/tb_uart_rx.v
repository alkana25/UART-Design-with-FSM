`timescale 1ns / 1ps

module tb_uart_rx;

    reg clk;
    reg rst;
    reg rx;
    reg rx_en;
    reg tick_8x; 

    wire [7:0] rx_data;
    wire rx_start;
    wire rx_busy;
    wire rx_done;

    uart_rx uut (
        .clk(clk), 
        .rst(rst), 
        .rx(rx), 
        .rx_en(rx_en), 
        .tick_8x(tick_8x), 
        .rx_data(rx_data), 
        .rx_start(rx_start), 
        .rx_busy(rx_busy), 
        .rx_done(rx_done)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    localparam TICK_PERIOD = 400; // 400ns
    
    initial begin
        tick_8x = 0;
        forever begin
            #(TICK_PERIOD); 
            tick_8x = 1;
            #10;
            tick_8x = 0;
        end
    end

    initial begin
        rst = 1;
        rx_en = 1; 
        rx = 1;   
        #200;
        rst = 0;
        #500;

        // TEST 1: Normal Veri (0x55 - 01010101)
        $display("TEST 1: 0x55 Gonderiliyor...");
        uart_send_byte(8'h55);
        #2000; // Paketler arası boşluk

        // TEST 2: Faz Farklı Veri (0xAA - 10101010)
 
        #353; 
        $display("TEST 2: 0xAA Gonderiliyor (Faz farkli)...");
        uart_send_byte(8'hAA);
        #2000;

        // TEST 3: 0xC3 (11000011)
        #127; 
        $display("TEST 3: 0xC3 Gonderiliyor...");
        uart_send_byte(8'hC3);
        #2000;

        // TEST 4: 0x18 (00011000)
        #88;
        $display("TEST 4: 0x18 Gonderiliyor...");
        uart_send_byte(8'h18);
        #2000;

        $stop;
    end


    task uart_send_byte(input [7:0] data);
        integer i;
        begin
            // 1. Start Bit (Low)
            rx = 0;
            #(TICK_PERIOD * 8 + 10); // 1 Bit süresi bekle (tick_period * 8)

            // 2. Data Bits (LSB First)
            for (i=0; i<8; i=i+1) begin
                rx = data[i];
                #(TICK_PERIOD * 8 + 10);
            end

            // 3. Stop Bit (High)
            rx = 1;
            #(TICK_PERIOD * 8 + 10);
        end
    endtask

endmodule
