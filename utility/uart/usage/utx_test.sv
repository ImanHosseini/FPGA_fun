`timescale 1ns / 1ps

module top(
    input sw,
    input clk,
    output led,
    output uart_txd
    );
    
reg send = 0;
reg [7:0] data = "X";
wire rdy;
wire tx;
assign led = send;

utx utx0(.clk(clk),.send(send),.data(data),.tx(uart_txd),.rdy(rdy));

always @(posedge CLK) begin
    if (sw) begin 
            send <= 1;
        end
end

  
endmodule
