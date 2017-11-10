// timestep/precision
`timescale 1ns/10ps 

module clock_generator(clk);

parameter PERIOD = 25;

output clk;
reg clk;
	 
always
	begin: CLOCK_DRIVER
		clk <= 1'b0;
		#(PERIOD/2);
		clk <= 1'b1;
		#(PERIOD/2);
	end
endmodule
