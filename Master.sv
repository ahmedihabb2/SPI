module Master
  (input Clock,input Reset,input Load,input [1:0]Mode, //four modes
   input MISO, 
   input [1:0] Slave_Select,//two binaries are enough to select from four slaves
   input Enable, 
   output SCLK, //The Master has control over the slaves clock
   output [1:0]Slave_Mode, //It will also give it the Clock Mode
   output reg Done, //Flag for complete transmission
   output reg MOSI, 
   output reg Slave_I,output reg Slave_II,output reg Slave_III, //Three Slaves
   output reg [7:0] Master_SR,
   input  [7:0] Parallel_Load 
   );


//Translating Modes:
wire Clock_Polarity;     
wire Clock_Phase;
assign Clock_Phase = ((Mode == 1) | (Mode == 2)); //We only need to translate modes into phase/polarity because we're following the document's convention
assign Clock_Polarity = ((Mode == 2) | (Mode == 3)); 

//Assigning the clock and the mode for the slave:
assign SCLK=(Done) ? Clock_Polarity:Clock; //the SCLK should be idle once data transmission is over
assign Slave_Mode=Mode;

//Helping Variables
reg [3:0] Counter_In= 4'b1000; //Decrement this each time a bit goes in
reg [7:0 ] Data_Buffer ;  //A pinch of delay

//Action:
always @(posedge Clock ) 

 begin

 if(Reset )
  begin 
  Counter_In <= 4'b1000; 
  Data_Buffer<= 0; 
  Master_SR<= 0; 
  Done<= 0;
  MOSI<=1'bx; //Once we reset the MOSI shouldn't keep hold of the last value it.
  end

 else if (Load)
  begin
  Data_Buffer<=Parallel_Load;
  Master_SR<=Data_Buffer;
  end

  case (Slave_Select) //Selecting a Slave
 
  2'b01:
   begin 
   Slave_I <= 0 ; //The 1st slave is chosen
   Slave_II <= 1 ; 
   Slave_III<= 1 ; 
   end  	
 
  2'b10: 	
   begin 
   Slave_I <= 1 ; 	
   Slave_II <= 0 ; //The 2nd slave is chosen
   Slave_III <= 1 ; 
   end 
 
  2'b11: 
   begin 
   Slave_I <= 1 ;  
   Slave_II <= 1 ; 
   Slave_III <= 0 ; //The 3rd slave is chosen
   end 
 
  endcase 
 

//Starting from here, possible modes are:
//00 Read at +VE edge and write at -VE edge
//01 Read at -VE edge and write at +VE edge
//11 Read at -VE edge and write at +VE edge
//10 Read at +VE edge and write at -VE edge

  if(Enable && Done !=1)
  begin
  case ( {Clock_Polarity , Clock_Phase }) //Concatenation

 //Applying actions that occur at the positive edge (00>>Read,01>>Write,10>>Write,11>Read)

  2'b00:
   if(MISO !== 1'bx) //The master can't read if the slave hasn't written yet and vice versa.
   begin //Read
   Data_Buffer={ MISO,Master_SR [7:1]};  //7 6 5 4 3 2 1 0 => 	MISO 7 	6 5 4 3 2 1, reads MISO
   Master_SR  = Data_Buffer;
   Counter_In = Counter_In - 1;
   if ( Counter_In == 4'b0000)
   Done <= 1; 
   end 
  				
  2'b01 : 
   begin //Write
   MOSI <= Master_SR[0]; //7 6 5 4 3 2 1 0 >>> 0, writes 0.
   end 

 
  2'b11 :
   begin //Write
   MOSI <= Master_SR[0];
   end

  2'b10 : 
   if(MISO !== 1'bx)
   begin //Read
     Data_Buffer={ MISO,Master_SR [7:1]};  //7 6 5 4 3 2 1 0 => 	MISO 7 	6 5 4 3 2 1
   Master_SR   = Data_Buffer;
   Counter_In = Counter_In - 1;
   if ( Counter_In == 4'b0000)
   Done <= 1; 
   end 
 endcase
 end
end

//Applying actions that occur at the negative edge, according to the comments following line 80
// (00>>Write,01>>Read,11>>Read,10>Write)
always @(negedge Clock )
begin
 if(Enable && Done !=1)
 begin
 case ( {Clock_Polarity , Clock_Phase }) //Doing action based on the Master's mode.
  
  2'b00:
   begin //Write
   MOSI <= Master_SR[0];
   end
			
  2'b01: 
   if(MISO !== 1'bx)
   begin //Read
     Data_Buffer={ MISO,Master_SR [7:1]};  //7 6 5 4 3 2 1 0 => 	MISO 7 	6 5 4 3 2 1
   Master_SR   = Data_Buffer;
   Counter_In = Counter_In - 1;
   if ( Counter_In == 4'b0000)
   Done <= 1; 
   end 
 
 
  2'b11:
   if(MISO !== 1'bx)
   begin //Read
     Data_Buffer={ MISO,Master_SR [7:1]};  //7 6 5 4 3 2 1 0 		=> 	MISO 7 	6 5 4 3 2 1
   Master_SR   = Data_Buffer;
   Counter_In = Counter_In - 1;
   if ( Counter_In == 4'b0000)
   Done <= 1; 
   end  

  2'b10 : 
   begin //Write
   MOSI <= Master_SR[0]; 
   end

 endcase
 end
end

			
endmodule


