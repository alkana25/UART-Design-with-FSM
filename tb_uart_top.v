`timescale 1ns / 1ps

module tb_uart_top;

    reg clk;
    reg rst;
    reg baud_select;
    
    // TX (Verici) Girişleri
    reg tx_en;
    reg [7:0] tx_data_in; 
    
    // RX (Alıcı) Çıkışları
    wire [7:0] rx_data_out; 
    wire rx_done;           
    
    // Durum Sinyalleri
    wire tx_busy, tx_done;
    wire rx_busy;

    // Loopback Hattı
    wire serial_loop; 

    // --- UUT ---
    uart_top uut (
        .clk(clk),
        .rst(rst),
        .baud_select(baud_select),
        .tx_en(tx_en),
        .tx_data(tx_data_in),
        .tx(serial_loop),     
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .rx(serial_loop),      
        .rx_en(1'b1),          
        .rx_data(rx_data_out),
        .rx_busy(rx_busy),
        .rx_done(rx_done)
    );

    // Clock (100 MHz - 10ns)
    always #5 clk = ~clk;

    reg [7:0] test_vectors [0:3];
    integer i;

    initial begin

        test_vectors[0] = 8'h55; 
        test_vectors[1] = 8'hAA; 
        test_vectors[2] = 8'h12; 
        test_vectors[3] = 8'hD4; 

        clk = 0;
        rst = 1;
        baud_select = 0; // 9600 Baud   1 for 
        tx_en = 0;
        tx_data_in = 0;


        #200; 
        @(negedge clk); 
        rst = 0;
        #100;

        $display("========================================");
        $display("   UART LOOPBACK TESTI (TIMING FIX)");
        $display("   (Inputs driven at NEGEDGE)");
        $display("========================================");

        for (i = 0; i < 4; i = i + 1) begin

            @(negedge clk);
            tx_data_in = test_vectors[i];
            tx_en = 1; 
            $display("[%0t] SENDING (Tx): %h", $time, tx_data_in);
            
            @(negedge clk);
            tx_en = 0; 

            wait(rx_done == 1);
            
            #1000; 
            
            
            if (rx_data_out === test_vectors[i])
                $display("   -> [SUCCESSFULL] Rx Read: %h", rx_data_out);
            else
                $display("   -> [ERROR]     Expected: %h, Read: %h", test_vectors[i], rx_data_out);

            
            #20000; 
        end

        $display("========================================");
        $display("   TEST COMPLETED");
        $display("========================================");
        $stop;
    end

endmodule