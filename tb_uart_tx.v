`timescale 1ns / 1ps

module tb_uart_tx;

    reg clk;
    reg rst;
    reg tx_en;
    reg tick_8x;      
    reg [7:0] tx_data; 
    
    wire tx_serial;   
    wire busy;
    wire done;

 
    uart_tx uut (
        .clk(clk),
        .rst(rst),
        .tx_en(tx_en),
        .tick_8x(tick_8x), 
        .tx_data(tx_data),
        .tx_serial(tx_serial),
        .busy(busy),
        .done(done)
    );

    // --- 1. Clock Üretimi (100 MHz) ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns periyot
    end

 
    initial begin
        tick_8x = 0;
        forever begin
            repeat(4) @(posedge clk); 
            tick_8x = 1;              
            @(posedge clk);           
            tick_8x = 0;              
        end
    end

  
    initial begin
      
        rst = 1;
        tx_en = 0;
        tx_data = 0;


        #100;
        @(negedge clk);
        rst = 0;
        #100;

        $display("========================================");
        $display("   UART TX TEST STARTING (4 DATA)      ");
        $display("========================================");

      //(Binary: 01010101) 
        send_packet(8'h55);

    //(Binary: 10101010) 
        send_packet(8'hAA);

        // (Binary: 01000001)
        send_packet(8'h41);

        // (Binary: 11111111)
        send_packet(8'hFF);

        $display("========================================");
        $display("   ALL TEST COMPLETED   ");
        $display("========================================");
        $stop; 
    end


    task send_packet(input [7:0] data_in);
        begin

            @(negedge clk); 
            tx_data = data_in;
            tx_en = 1;      
            $display("[Time: %t] Data is ready: 0x%h", $time, data_in);

          
            @(negedge clk);
            tx_en = 0;

            wait(busy == 1);
   
            wait(done == 1);
            $display("[Time: %t] Data sent: 0x%h (DONE is recieved)", $time, data_in);

            #200; 
        end
    endtask

endmodule