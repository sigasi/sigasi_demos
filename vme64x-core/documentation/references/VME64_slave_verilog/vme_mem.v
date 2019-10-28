module vme_rom(addr, clk, dout, sinit);

input	clk, sinit;
input[10:0]	addr;
output[7:0]	dout;


wire		clk, sinit;
wire[10:0]	addr;

reg[7:0]	dout;


reg[7:0]	rom[2047:0];


initial 
begin
	$readmemb("/homedir/ljuslin/vme/vme_rom.mif", rom, 0);
end
 
always @(posedge clk or negedge sinit)
begin
	if (~sinit) dout <= 8'b0;
	else dout <= rom[addr];
end

endmodule
