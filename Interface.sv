module Interface  ( input Clock, input Master_Reset, input Master_Load,input Slave_Reset_I,input Slave_Reset_II,input Slave_Reset_III,
 input Slave_Load_I,input Slave_Load_II,input Slave_Load_III,
 input [1:0]Mode, input [1:0] Slave_Select, input Enable,  
 input [7:0] Master_Parallel_Load,
 input [7:0] Slave_Parallel_Load_I ,input [7:0] Slave_Parallel_Load_II, input [7:0] Slave_Parallel_Load_III,
 output  Spi_Done,
 output [7:0] Master_Data, //Data in the Master's Shift Register
 output [7:0] Slave_Data  //Data in the current Slave's Shift Register
  ) ;

//Connections:

//From the Master to the Slaves
wire SCLK; 
wire [1:0]Slave_Mode;
wire SS_I;
wire SS_II;
wire SS_III; 
wire MOSI; 
//From the Slaves to the Master
wire MISO_I;
wire MISO_II;
wire MISO_III; 
wire Selected_MISO; //Three slaves, but only one is chosen each time.
wire [7:0] Slave_SR_I;//Three slaves, but only one is chosen each time.
wire [7:0] Slave_SR_II;
wire [7:0] Slave_SR_III;

//Selecting the MISO:
assign Selected_MISO = (Slave_Select==2'b01)? MISO_I : (Slave_Select==2'b10) ? MISO_II :(Slave_Select==2'b11) ? MISO_III : 1;
// So incase the controller inputs 2'b00 the master will keep shifting in ones, we can also shift in 1'bx but that would be harder to debug.

//Selecting the Slave_Data:
assign Slave_Data = (Slave_Select==2'b01)? Slave_SR_I : (Slave_Select==2'b10) ? Slave_SR_II  :(Slave_Select==2'b11) ? Slave_SR_III : 8'b11111111;
//Incase the controller inputs 2'b00 the Slave_Data will be all 1s

 //The Master:
wire Done;
assign Spi_Done=Done; //When the master is done, the SPI is done.
Master Karthus
  ( Clock, Master_Reset, Master_Load, Mode, Selected_MISO , Slave_Select, Enable, 
    SCLK, //<Outputs>
    Slave_Mode, 
    Done, 
    MOSI, 
    SS_I,SS_II,SS_III, 
    Master_Data,//</Outputs>
    Master_Parallel_Load 
   ); 
//The Slaves:
wire D; //We don't need the slaves' 'Done' in the interface.
assign D =1'bz;

Slave Pyke
  ( SCLK, Slave_Reset_I,Slave_Load_I,Slave_Mode, MOSI, Enable, SS_I,
     //<Outputs>
    MISO_I,
   Slave_SR_I,D, //</Outputs>
   Slave_Parallel_Load_I 
   );

Slave Urgot
  ( SCLK, Slave_Reset_II,Slave_Load_II,Slave_Mode, MOSI, Enable, SS_II,
     //<Outputs>
    MISO_II,
   Slave_SR_II,D, //</Outputs>
   Slave_Parallel_Load_II 
   );

Slave Warwick
  ( SCLK, Slave_Reset_III,Slave_Load_III,Slave_Mode,MOSI, Enable, SS_III,
     //<Outputs>
    MISO_III,
   Slave_SR_III,D, //</Outputs>
   Slave_Parallel_Load_III 
   );

endmodule

