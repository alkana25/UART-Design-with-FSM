`timescale 1ns / 1ps
module baud_gen (
    input wire clk,           
    input wire rst,          
    input wire baud_select,   
    output reg tick_1x,      
    output reg tick_8x       
);

  
    localparam DIV_9600   = 1302; // 100MHz / (9600 * 8)
    localparam DIV_115200 = 108;  // 100MHz / (115200 * 8)

   
    reg [10:0] counter;       
    reg [2:0]  sub_counter;  
    reg [10:0] limit;         


    always @* begin
        case (baud_select)
            1'b0: limit = DIV_9600;   // 9600 seçimi
            1'b1: limit = DIV_115200; // 115200 seçimi
        endcase
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            tick_8x <= 0;
        end else begin
            // 8x Tick Üretimi
            if (counter >= limit - 1) begin
                counter <= 0;
                tick_8x <= 1'b1; 
            end else begin
                counter <= counter + 1;
                tick_8x <= 1'b0;
            end
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sub_counter <= 0;
            tick_1x <= 0;
        end else begin
            tick_1x <= 0; 
            
            if (tick_8x) begin
                if (sub_counter == 7) begin 
                    sub_counter <= 0;
                    tick_1x <= 1'b1; 
                end else begin
                    sub_counter <= sub_counter + 1;
                end
            end
        end
    end

endmodule