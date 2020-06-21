module Interface_Test();

reg clk=1'b0;    //initial value for input clock, this will be given from the Master
reg master_reset;
reg master_load;
reg slave_reset_I;
reg slave_reset_II;
reg slave_reset_III;
reg slave_load_I;
reg slave_load_II;
reg slave_load_III;
reg[1:0] Mode = 0;  //Select Mode 
reg [1:0] SS;                                   
reg enable;
reg [7:0] master_inload=8'b11101101;
reg [7:0] slaves_inload_I=8'b11000011;
reg [7:0] slaves_inload_II=8'b11100111;
reg [7:0] slaves_inload_III=8'b00010010;           
wire Spi_Done;
wire [7:0] Master_Data;
wire [7:0] Slave_Data;
localparam PERIOD=10;
always #(PERIOD/2) clk=~clk;           //Generate Random clk
////----- For Self Checking Stage----\\\\\\
reg [7:0] Expected_Master;
reg [7:0] Expected_Slave;
integer X;
reg[4:0] test=0;
reg[4:0] Succeeded_Test=0;
/////////////////////////////////////////////

Interface SPI  ( clk, master_reset, master_load, slave_reset_I, slave_reset_II, slave_reset_III,
 slave_load_I, slave_load_II, slave_load_III,
 Mode, SS, enable,  
 master_inload,
 slaves_inload_I, slaves_inload_II, slaves_inload_III,
 Spi_Done,
 Master_Data, //Data in the Master's Shift Register
 Slave_Data  //Data in the current Slave's Shift Register
  ) ;
initial begin
X = $fopen("Interface.txt"); //To write the output in a file.
//$fwrite(X,"Enable	Done	Master SS   Slave   M_Reset     M_Load     S_Reset_I     S_Reset_II    S_Reset_III    slave_load_I    slave_load_II	slave_load_III");
$fwrite(X," Master	            Slave	    SS	       Enable	     Done	     M_Reset       M_Load         S_Reset_I        S_Reset_II        S_Reset_III       slave_load_I        slave_load_II	     slave_load_III   \n");
$fwrite(X,"");
$fmonitor(X,"%b          %b          %b            %b            %b             %b              %b			%b    		  %b	              %b	         %b	             %b	                        %b    ", Master_Data,Slave_Data,SS,enable, Spi_Done, master_reset, master_load, slave_reset_I, slave_reset_II, slave_reset_III,
 slave_load_I, slave_load_II, slave_load_III,
    //Data in the Master's Shift Register
 );
for(integer i=0 ; i< 12 ; i = i+1)
begin
if(test==3)
Mode=1;
if(test==6)
Mode=2;
if(test==9)
Mode=3;
master_reset=1;
#(PERIOD*2)
master_reset=0;
#(PERIOD*2)
slave_reset_I=1;
slave_reset_II=1;
slave_reset_III=1;
#(PERIOD*2)
slave_reset_I=0;
slave_reset_II=0;
slave_reset_III=0;
#(PERIOD*2)
master_load=1; 
#(PERIOD*2)
master_load=0;
#(PERIOD*2)
slave_load_I=0;
slave_load_II=0;
slave_load_III=0;
#(PERIOD*2)
if(test==0 ||test==3 ||test==6 || test==9)
begin
SS=2'b01;
#(PERIOD*2)
slave_load_I=1;
#(PERIOD*2)
slave_load_I=0;
#(PERIOD*2);
end
if(test==1 ||test==4 ||test==7 || test==10)
begin
SS=2'b10;
#(PERIOD*2)
slave_load_II=1;
#(PERIOD*2)
slave_load_II=0;
#(PERIOD*2);
end
if(test==2 ||test==5 ||test==8 || test==11)
begin
SS=2'b11;
#(PERIOD*2)
slave_load_III=1;
#(PERIOD*2)
slave_load_III=0;
#(PERIOD*2);
end
$display("Hey Master Send Your Data To Slave %d",SS," and receive From it");
$display("Mode = %d",Mode);
$display("Master Data = %b",Master_Data);
$display("Slave Data = %b",Slave_Data);
Expected_Master=Slave_Data;
Expected_Slave=Master_Data;
#(PERIOD*2)
repeat(5) @(posedge clk)
enable=0;
#(PERIOD*2)
enable=1;
#(PERIOD*2)
repeat(10) @(posedge clk)
enable=1;
enable=0;
#(PERIOD*2)
$display("Master Data after transfer = %b",Master_Data);
$display("Slave Data after transfer = %b",Slave_Data);
$display("-----> SelfChecking Stage test(%d",test,") <-----");
if(Master_Data ==Expected_Master && Slave_Data == Expected_Slave)
begin
$display("Test %d", test," Succeed");
Succeeded_Test +=1;
end
else
$display("Test %d", test,"Failed");
test += 1;
$display("                           ");
end
$fclose(X);
$display("Number of Succeeded Tests = %d",Succeeded_Test," Out of : %d",test);
$display("                           ");
$display("                           ");
$stop;  
end

endmodule

