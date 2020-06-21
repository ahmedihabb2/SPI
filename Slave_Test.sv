
module Slave_Test();

reg clk=1'b0;  //initial value for input clock, this will be given from the Master
reg reset;
reg load;
reg [1:0] Mode; //Select Mode                                     
reg enable;
reg [7:0]inload;//Load the Slave's register with this value
reg SS=0; //Select the slave
wire Slave_Done;
wire [7:0] Slave_SR;
wire MISO;
reg MOSI;
localparam PERIOD=10;
always #(PERIOD/2) clk=~clk;           //Generate Random clk
////----- For Self Checking Stage----\\\\\\
reg [7:0] Expected_Output ;
reg test=0;
integer Z=0;
/////////////////////////////////////////////
Slave  Volibear(clk,reset,load,Mode,MISO,enable,SS,MISO,Slave_SR,Slave_Done,inload);
initial begin
$display("Done	Enable     Reset     Load     Mode    Slave_SR    MISO    MOSI ");
$monitor(" %b	%b       %b          %b       %b       %b       %b       %b ",Slave_Done,enable,reset,load,Mode,Slave_SR,MISO,MISO);
for(integer i=0 ; i< 4 ; i = i+1)
begin
if(i==0)
begin
Mode=0;
inload=8'b10100101;
end
if(i==1)
begin
Mode=1;
inload=8'b00011000;
end
if(i==2)
begin
Mode=2;
inload=8'b11101110;
end
if(i==3)
begin
Mode=3;
inload=8'b00011101;
end
#(PERIOD*2)
Expected_Output=inload;
#(PERIOD*2)
reset=1;
#(PERIOD*2)
reset=0;
#(PERIOD*2)
load=1;
#(PERIOD*2)
load=0;
#(PERIOD*2)
repeat(5) @(posedge clk)
enable=0;
#(PERIOD*2)
enable=1;
#(PERIOD*2)
repeat(10) @(posedge clk)
begin
enable=1;
MOSI=MISO;
if(Slave_Done == 1)
enable =0;
end
#(PERIOD*3)
test=1;
end
#(PERIOD*3)
$display("");
$display("Number of Runs:", 4 );
$display("Number of Successful Runs:", Z );
$stop;
end
always @(test==1)
begin
$display("-----> SelfChecking Stage <-----");
$display("Expected_Output = %b",Expected_Output);
if(Slave_SR === Expected_Output)
begin
$display("Test Succeed");
Z+=1;
end
else
$display("Test Failed");
test=0;
end
endmodule 