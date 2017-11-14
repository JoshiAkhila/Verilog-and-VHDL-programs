`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:   Akhila Joshi
// Create Date:   20:49:22 02/06/2016
// Design Name:   priority_mux_6to1
// Module Name:   C:/Xilinx/finalmux/priority_mux_testbench.v
// Project Name:  finalmux
// Revision 0.01 - File Created
// Additional Comments:
////////////////////////////////////////////////////////////////////////////////
module priority_mux_testbench;

	// Inputs
	reg [7:0] d0;
	reg [7:0] d1;
	reg [7:0] d2;
	reg [7:0] d3;
	reg [7:0] d4;
	reg [7:0] d5;
	reg [4:0] sel;
   
	// Outputs
	wire [7:0] d_out;
	 
   // signals 
		integer error_count= 1'b0;
	   integer i;
	// Instantiate the Unit Under Test (UUT)
	priority_mux_6to1 uut (
		.d0(d0), 
		.d1(d1), 
		.d2(d2), 
		.d3(d3), 
		.d4(d4), 
		.d5(d5), 
		.sel(sel), 
		.d_out(d_out)
	);

	initial begin
	     $display("**********************************");
		  $display(" Starting Simulation");
		  $display("**********************************");
		// Initialize Inputs
		
		    d0=8'b10111000;
     		 d1=8'b11110000; 
			 d2=8'b01010101; 
			 d3=8'b00110011;
			 d4=8'b11100011; 
			 d5=8'b10101010;
			 sel=5'b00000;
			 
     // For every combination of sel check output and errors
	  
			 for(i=0; i<32 ; i= i+1)
			 begin
			 #20;
			 
			 if(sel== 0)
			 begin
			 #5 $display("sel %b & output is %b",sel,d_out);
			     	 if(d_out != d0)
					 error_count= error_count+1; 
             end
				
			if(sel == 1)
				begin
				#5 $display("sel %b & output is %b",sel,d_out);
				    if(d_out != d1)
					 error_count= error_count+1; 
			     end
							
		   if(sel== 2 || sel== 3)
			      begin
				#5 $display("sel %b & output is %b",sel,d_out);
					if(d_out != d2)
					 error_count= error_count+1; 
					end
							
			 if(sel== 4 || sel== 5 || sel== 6 || sel== 7)
			      begin
				#5 $display("sel %b & output is %b",sel,d_out);
					 if(d_out != d3)
					 error_count= error_count+1; 
	            end
					
			 if(sel== 8 || sel== 9 || sel== 10 || sel== 11 || sel== 12 || sel== 13 || sel== 14 || sel== 15)
			      begin
				#5 $display("sel %b & output is %b",sel,d_out);
				    if(d_out != d4)
					 error_count= error_count+1; 
						end
						
			 if(sel== 16 || sel== 17 || sel== 18 || sel== 19 || sel==20 || sel== 21 || sel== 22 || sel== 23 ||
			    sel== 24 || sel== 25 || sel== 26 || sel== 27 || sel== 28 || sel==29 || sel==30 || sel==31)
			      begin
			  #5 $display("sel %b & output is %b",sel,d_out);
				    if(d_out != d5)
					 error_count= error_count+1; 
					   end
						
						sel = sel + 1;
			end
		   $display("[T=%d] Simulation complete",$time);
         $display("**********************************");
         $display("**%d total error",error_count);
         $display("**********************************");
         $stop;
	 end
	      
endmodule			
