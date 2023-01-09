`timescale 1ns / 1ps
module top(clk, txd, sw);
input clk;
input [3:0] sw;
output reg txd;

reg [11:0] clk_cnt=0;//숫자 542까지 세야하니까 충분히 만들고
reg [3:0] tx_st=4'b0000;
reg [7:0] tx_result="Z";
reg tx_ch=0;

parameter IDLE_ST=0,
          START_ST=1,
          DATA_ST0=2,
          DATA_ST1=3,
          DATA_ST2=4,
          DATA_ST3=5,
          DATA_ST4=6,
          DATA_ST5=7,
          DATA_ST6=8,
          DATA_ST7=9,
          STOP_ST=10;
          
always @(sw[0] or sw[1] or sw[2] or sw[3])
begin
    tx_ch<=1;
    case(sw)
        4'b0000 : tx_result<="Z";
        4'b0001 : tx_result<="O";
        4'b0010 : tx_result<="T";
        4'b0011 : tx_result<="T";
        4'b0100 : tx_result<="F";
        4'b0101 : tx_result<="F";
        4'b0110 : tx_result<="S";
        4'b0111 : tx_result<="S";
        4'b1000 : tx_result<="E";
        4'b1001 : tx_result<="N";
        //4'b1010 : tx_result<=8'h54;
        4'b1010 : tx_result<="T";
        default : tx_result<="X";
    endcase
end

always @*//clk나 뭐 어떤 것에도 상관 없이
begin
case(tx_st)
    IDLE_ST : txd<=1;
    START_ST : txd<=0;
    DATA_ST0 : txd<=tx_result[0];
    DATA_ST1 : txd<=tx_result[1];
    DATA_ST2 : txd<=tx_result[2];
    DATA_ST3 : txd<=tx_result[3];
    DATA_ST4 : txd<=tx_result[4];
    DATA_ST5 : txd<=tx_result[5];
    DATA_ST6 : txd<=tx_result[6];
    DATA_ST7 : txd<=tx_result[7];
    STOP_ST : txd<=1;
    default : txd<=1;
endcase
end

always @(posedge clk)
begin
if(clk_cnt == 1084)
begin
    clk_cnt<=0;
    case(tx_st)
        IDLE_ST : 
        begin
        if(tx_ch==0)
            tx_st<=IDLE_ST;
        else
            tx_st<=START_ST;
        end
        START_ST : tx_st<=DATA_ST0;
        DATA_ST0 : tx_st<=DATA_ST1;
        DATA_ST1 : tx_st<=DATA_ST2;
        DATA_ST2 : tx_st<=DATA_ST3;
        DATA_ST3 : tx_st<=DATA_ST4;
        DATA_ST4 : tx_st<=DATA_ST5;
        DATA_ST5 : tx_st<=DATA_ST6;
        DATA_ST6 : tx_st<=DATA_ST7;
        DATA_ST7 : tx_st<=STOP_ST;
        STOP_ST : 
        begin
            tx_ch<=0;//이거 안먹힘
            tx_st<=IDLE_ST;
        end
        default : tx_st<=IDLE_ST;
    endcase
end
else
    clk_cnt<=clk_cnt+1;
end

endmodule