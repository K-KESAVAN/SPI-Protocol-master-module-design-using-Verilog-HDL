`timescale 10ns/1ns
module spi_master(
output reg ss,
output reg mosi,
output reg done,
input [3:0]data_in,
input clk,
input rst,
input start,
output reg[1:0]count,
output reg[1:0]state
);
parameter idle=2'b00;
parameter start_send=2'b01;
parameter finish=2'b10;
parameter next=2'b11;

always@(posedge clk or posedge rst)begin
if(rst)begin
ss<=1'b0;
mosi<=1'b0;
done<=1'b0;
count<=2'b11;
state<=idle;
end
else begin
case(state)
    idle :begin
           ss<=1'b0; //deactivate ss line
           mosi<=1'b0;
           done<=1'b0;
           count<=2'b11;
           if(start)begin
           state<=start_send;
           end
          end
start_send:begin
           ss<=1'b0;//activate ss line
           mosi<=data_in[count];//send data as bit by bit
           if(count==2'b00)begin
           state<=finish;
           end else begin
           count<=count-1;
           end
          end
  finish :begin
           ss<=1'b1;
           done<=1'b1;
           state<=next;
          end
    next :begin
           done<=1'b0;
           state<=idle;
          end
 default :begin
           state<=idle;
          end
endcase
end 
end
endmodule
module spi_master_tb;
reg clk;
reg rst;
reg start;
reg [3:0]data_in;
wire ss;
wire mosi;
wire done;
wire [1:0]count;
wire [1:0]state;
spi_master kk(.ss(ss),.mosi(mosi),.done(done),.data_in(data_in),.clk(clk),.rst(rst),.start(start),.count(count),.state(state));
    initial begin
     clk=0;
     forever #5 clk=~clk;
    end
    initial begin
     rst=1;
     start=0;
     data_in=4'b1101;
   #20
     rst=0;
   //#20
     start=1;
    end
always@(posedge clk)begin
$display(" time=%0t ss=%0b done=%0b state=%0b count=%0b data=%0b mosi=%0b",$time,ss,done,state,count,data_in,mosi);
end
endmodule