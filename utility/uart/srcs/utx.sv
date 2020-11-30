`timescale 1ns / 1ps

module utx
    #( parameter INPUT_CLK = 100000000,
    parameter BAUD_RATE = 9600)
    (
    input wire send,
    input wire [7:0] data,
    input wire clk,
    output wire rdy,
    output wire tx
    );


localparam TIMER_MAX = (INPUT_CLK / BAUD_RATE) - 1;

typedef enum logic [1:0] {
    RDY = 2'h0,
    LD = 2'h1,
    BITSEND = 2'h2
} tx_state;

localparam BITMAX = 10;
reg [9:0] txData;
tx_state txState = RDY;
integer unsigned bitTmr = 0;
reg bitDone;
reg txBit = 1;
reg [3:0] bitIdx;

assign tx = txBit;
assign rdy = (txState==RDY); 

task bit_counting;
    if (txState == RDY) begin
        bitIdx <= 0;
    end else if (txState == LD) begin
        bitIdx <= bitIdx + 1;
    end
endtask

task tx_proc;
    if (send == 1)
        txData <= {1'b1, data, 1'b0}; 
endtask

task tx_bit;
    if (txState == RDY)
        txBit <= 1;
    else if (txState == LD)
        txBit <= txData[bitIdx];
endtask

task bit_timing;
    if (txState == RDY) begin
        bitTmr <= 0;
    end 
    else begin
        if (bitDone == 1) begin
            bitTmr <= 0;
        end
        else begin
            bitTmr <= bitTmr + 1;
        end
    end
endtask

task sm;
case (txState)
    RDY: begin
        if (send)
            txState <= LD;
    end
    LD: txState <= BITSEND;
    BITSEND: 
        begin
            if (bitDone == 1)
                if (bitIdx == BITMAX)
                    txState <= RDY;
                else
                    txState <= LD;
        end
    default: txState <= RDY;
endcase
endtask

always @(posedge clk) begin
    bit_timing;
    bit_counting;
    tx_bit;
    tx_proc;
    sm;
    if (bitTmr == TIMER_MAX)
        bitDone <= 1;
    else begin
        bitDone <= 0;
    end
end
  
endmodule
