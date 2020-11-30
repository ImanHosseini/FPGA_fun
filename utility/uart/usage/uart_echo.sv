`timescale 1ns / 1ps

module top(
    input sw,
    input CLK,
    input uart_rxd,
    output [1:0] led,
    output uart_txd
    );
    
reg send = 0;
wire rdy;
wire tx;
wire rx_done;
reg [7:0] r_data = "Y";
wire [7:0] w_data;

assign led[0] = send;
reg got = 0;
assign led[1] = got;

utx utx0(.clk(CLK),.send(send),.data(r_data),.tx(uart_txd),.rdy(rdy));
urx urx0(.clk(CLK),.rx(uart_rxd),.rx_done(rx_done),.data(w_data),.reset(0));

reg [2:0] tState = 3'h0;

always @(posedge CLK) begin
    case (tState)
        3'h0: begin
            if (rx_done) begin
                r_data <= w_data;
                tState <= 3'h1;
                got <= 1;
            end
        end
        3'h1: begin
            send <= 1;
            tState <= 3'h2;
        end
        3'h2: begin
            if(rdy == 0 && send == 1) begin
               send <= 0;
               tState <= 3'h0;
            end
        end
        default: tState <= 3'h0;
endcase
end

  
endmodule