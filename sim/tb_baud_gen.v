`timescale 1ns / 1ps

module tb_baud_gen;

    // Sinyaller
    reg clk;
    reg rst;
    reg baud_select;
    
    wire tick_1x;
    wire tick_8x;

    // Modül Bağlantısı
    baud_gen uut (
        .clk(clk),
        .rst(rst),
        .baud_select(baud_select),
        .tick_1x(tick_1x),
        .tick_8x(tick_8x)
    );

    // Saat Üretimi (100 MHz -> 10ns periyot)
    always #5 clk = ~clk;

    initial begin
        // Başlangıç
        clk = 0;
        rst = 1;
        baud_select = 1; // Önce Hızlı Mod (115200) ile başlayalım
        
        #100;
        rst = 0;
        
        // --- TEST 1: 115200 Baud (Hızlı) ---
        $display("--- Test 1: 115200 Baud ---");
 
        #100000; 
        
        
        // --- TEST 2: 9600 Baud (Yavaş) ---
        $display("--- Test 2: 9600 Baud ---");
        baud_select = 0; 
        rst = 1;        
        #20;
        rst = 0;
        

        #1000000;

        $display("--- Test Completed ---");
        $stop;
    end

endmodule
