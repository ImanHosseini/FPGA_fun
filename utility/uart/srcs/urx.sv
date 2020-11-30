`timescale 1ns / 1ps

module urx
    #( parameter INPUT_CLK = 100000000,
    parameter BAUD_RATE = 9600,
    parameter SAMPLING = 16
    )
    (
    input wire rx,
    input wire reset,
    input wire clk,
    output logic [7:0] data,
    output logic rx_done
    );

localparam TIMER_MAX = (INPUT_CLK / (BAUD_RATE*SAMPLING*2)) - 1;   

typedef enum logic [1:0] {
    IDLE = 2'h0,
    DATA = 2'h1,
    LD = 2'h2
} rx_state;
logic [1:0] rxState = IDLE;
reg [$clog2(SAMPLING):0] cnt = 0;
reg s_clk = 0;
reg [7:0] data_r = 0;
logic [2:0] d_idx = 3'h0;

integer unsigned bitTmr = 0;

task sm;
case (rxState)
    IDLE: begin
    rx_done <= 0;
        if (rx == 0) begin
            if (cnt == 4'd7) begin
                rxState <= DATA;
                cnt <= 0;
                d_idx <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end else
            cnt <= 0;
    end
    DATA: begin
        if (cnt == 4'd15) begin
            data_r[d_idx] <= rx;
            cnt <= 0;
            if (d_idx == 3'h7) begin
                rxState <= LD;
            end else begin
                d_idx <= d_idx + 1;
            end
        end else begin
            cnt <= cnt + 1;
        end
    end
    LD: 
        begin
            data <= data_r;
            if (cnt == 4'd15) begin
                rx_done <= (rx == 1);
                cnt <= 0;
                rxState <= IDLE;
            end else begin
                cnt <= cnt + 1;
            end
        end
    default: rxState <= IDLE;
endcase
endtask

always @(posedge s_clk) begin
    if (reset) begin
        d_idx <= 0;
        data_r <= 0;
        data <= 0;
        rx_done <= 0;
        cnt <= 0;
        rxState <= IDLE;
    end else begin
        sm;
    end
end

always @(posedge clk) begin
    if (reset) begin  
        bitTmr <= 0;
    end else begin
        if (bitTmr == TIMER_MAX) begin
            s_clk <= ~s_clk;
            bitTmr <= 0;
        end else begin
            bitTmr <= bitTmr + 1;
        end
    end
end


    
endmodule
