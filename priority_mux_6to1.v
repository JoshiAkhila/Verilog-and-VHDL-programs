`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:04:55 02/06/2016 
// Design Name:  AKHILA JOSHI
// Module Name:    priority_mux_6to1 
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

module priority_mux_6to1 #(parameter WIDTH = 8) 
(input [WIDTH-1:0] d0, d1, d2, d3, d4, d5, input [4:0] sel, output [WIDTH-1:0] d_out);
	
wire [WIDTH-1:0] d_temp [3:0];

mux_2to1 #(.WIDTH(WIDTH)) mux0 (.d1(d1), .d0(d0),        .sel(sel[0]), .d_out(d_temp[0]));
	
mux_2to1 #(.WIDTH(WIDTH)) mux1 (.d1(d2), .d0(d_temp[0]), .sel(sel[1]), .d_out(d_temp[1]));
	
mux_2to1 #(.WIDTH(WIDTH)) mux2 (.d1(d3), .d0(d_temp[1]), .sel(sel[2]), .d_out(d_temp[2]));
	
mux_2to1 #(.WIDTH(WIDTH)) mux3 (.d1(d4), .d0(d_temp[2]), .sel(sel[3]), .d_out(d_temp[3]));
	
mux_2to1 #(.WIDTH(WIDTH)) mux4 (.d1(d5), .d0(d_temp[3]), .sel(sel[4]), .d_out(d_out));

endmodule
