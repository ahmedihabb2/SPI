module Master_Test();

reg clk=1'b0;                         //initial value for input clock
reg reset;
reg load;
reg [1:0]Mode;        
                   
reg MISO;                        
reg [1:0]Select=2'b01;                    
reg enable;
reg [7:0]inload;//Load the master register with this value
wire sclk;
wire [1:0] Slave_mode;
wire Done;
wire MOSI;
wire  Slave_I;
wire  Slave_II;
wire  Slave_III;
wire [7:0] Master_SR;
integer Z=0; //counter
localparam PERIOD=10;
always #(PERIOD/2) clk=~clk;           //Generate Random clk

////----- For Self Checking Stage----\\\\\\
reg [7:0] Expected_Output ;
reg test=0;
/////////////////////////////////////////////

Master  Malzahar(clk,reset,load,Mode,MOSI,Select,enable,sclk,Slave_mode,Done,MOSI,Slave_I,Slave_II,Slave_III,Master_SR,inload);
initial begin
$display("Done   Enable     Reset     Load     Mode    Master_SR    MOSI    MISO ");
$monitor(" %b        %b       %b          %b       %d       %b       %b       %b ",Done,enable,reset,load,Mode,Master_SR,MOSI,MOSI);
for(integer i=0 ; i< 4 ; i = i+1)
begin
if(i==0)
begin
Mode=0;
inload=8'b11101001;
end
if(i==1)
begin
Mode=1;
inload=8'b10011001;
end
if(i==2)
begin
Mode=2;
inload=8'b11001001;
end
if(i==3)
begin
Mode=3;
inload=8'b11110000;
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
MISO=MOSI;
if(Done == 1)
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
if(Master_SR === Expected_Output)
begin
$display("Test Succeed");
Z=Z+1;
end
else
$display("Test Failed");
test=0;
end
endmodule
