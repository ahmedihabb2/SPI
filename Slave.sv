module Slave
  (input Clock,input Reset,input Load,input [1:0]Mode, input MOSI, //Mode and Clock will be taken from the master
   input Enable, 
   input Slave_Select,
   output reg MISO,
   output reg [7:0] Slave_SR,
   output reg Slave_Done, //Just for the slave's test bench, won't be connected to anything in the interface.
   input  [7:0] Parallel_Load 
   );

//Translating the Mode that the master sent:
wire Clock_Polarity;     
wire Clock_Phase;
assign Clock_Phase = ((Mode == 1) | (Mode == 2)); //We only need to translate modes into phase/polarity because we're following the document's convention
assign Clock_Polarity = ((Mode == 2) | (Mode == 3)); 


//Helping Variables
reg [7:0 ] Data_Buffer;
reg [3:0] Counter_In= 4'b1000; //Decrement this each time a bit goes in 

//Action:
always @(posedge Clock ) 

 begin

 if(Reset )
  begin 
  Data_Buffer<= 0; 
  Slave_SR<= 0; 
  Counter_In <= 4'b1000; 
  Slave_Done<=0;
  MISO=1'bx; //Once we reset the MISO shouldn't keep hold of its latest value.
  end

 else if (Load)
  begin
  Data_Buffer<=Parallel_Load;
  Slave_SR<=Data_Buffer;
  end

  if(!Slave_Select && Enable &&Slave_Done!==1) //If the slave is chosen, the Slave_Done is some sort of an enable.
   begin
//Starting from here, possible modes are:
//00 Read at +VE edge and write at -VE edge
//01 Read at -VE edge and write at +VE edge
//11 Read at -VE edge and write at +VE edge
//10 Read at +VE edge and write at -VE edge

   case ( {Clock_Polarity , Clock_Phase }) //Applying actions that occur at the positive edge

   2'b00:
   if(MOSI !== 1'bx)
   begin //Read
   Data_Buffer = {MOSI,Slave_SR [7:1]};
   Slave_SR = Data_Buffer;
   Counter_In = Counter_In - 1;
   if ( Counter_In == 4'b0000)
   Slave_Done <= 1; 
   end 
  				
   2'b01 : 
   begin //Write
   MISO <= Slave_SR[0];
   end
 
 
   2'b11:
   begin //Write
   MISO <= Slave_SR[0];
   end
 
   2'b10 : 
   if(MOSI !== 1'bx)
   begin //Read
   Data_Buffer = {MOSI,Slave_SR [7:1]};
   Slave_SR   = Data_Buffer;
   Counter_In = Counter_In - 1;
   if ( Counter_In == 4'b0000)
   Slave_Done <= 1; 
   end 
  endcase
 end
end

//Applying actions that occur at the negative edge
always @(negedge Clock )
begin
 if(Enable && !Slave_Select&&Slave_Done!==1)
 begin
 case ( {Clock_Polarity , Clock_Phase }) //Doing action based on the Master's mode.
 
  2'b00:
   begin //Write
   MISO <= Slave_SR[0];
   end
			
  2'b01 : 
   begin //Read
   Data_Buffer = {MOSI,Slave_SR [7:1]};
   Slave_SR = Data_Buffer;
   Counter_In = Counter_In - 1;
   if ( Counter_In == 4'b0000)
   Slave_Done <= 1; 
   end
 
 
  2'b11 :
   begin //Read
   Data_Buffer = {MOSI,Slave_SR [7:1]};
   Slave_SR = Data_Buffer;
   Counter_In = Counter_In - 1;
   if ( Counter_In == 4'b0000)
   Slave_Done <= 1; 
   end 

  2'b10 :
   begin //Write
   MISO <= Slave_SR[0];
   end
 

 endcase
 end
end
		
endmodule
