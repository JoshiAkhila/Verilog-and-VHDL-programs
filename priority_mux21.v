`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Akhila Joshi
// 
// Create Date:    18:20:51 01/30/2016 
// Design Name: 
// Module Name:    priority_mux21 
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
module priority_mux21(s0,s1,s2,s3,s4,x1,x2,x3,x4,x5,x6,zout);  // Module name, input and output variables
    input s0,s1,s2,s3,s4;  // input variables
	 input x1,x2,x3,x4,x5,x6; // input variables
    output zout;   // output variables
	 wire w1,w2,w3,w4;  // signal for interconnection
    
	 // muxes chaining together
	 MUX G1(s0,x1,x2,w1);
	 MUX G2(s1,w1,x3,w2);
	 MUX G3(s2,w2,x4,w3);
	 MUX G4(s3,w3,x5,w4);
	 MUX G5(s4,w4,x6,zout);
	 endmodule
