`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:03:51 02/06/2016 
// Design Name: Akhila Joshi
// Module Name:    mux_2to1 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux_2to1 #(parameter WIDTH = 8) 
(input [WIDTH-1:0] d1, d0, input sel, output reg [WIDTH-1:0] d_out);
	
always @ (d1, d0, sel)
		
if( sel )
			
d_out = d1;
		
else
			
d_out = d0;

endmodule

