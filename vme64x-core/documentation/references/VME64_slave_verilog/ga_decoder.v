module ga_decoder(GA, BAR);

input[4:0]	GA;
output[7:0]	BAR;

wire[4:0]	GA;
reg[7:0]	BAR;

always @(GA)
begin
case(GA)
	5'h1E:	BAR <= 8'h08; //SLOT 1
	5'h1D:	BAR <= 8'h10; //SLOT 2
	5'h1C:	BAR <= 8'h18; //SLOT 3
	5'h1B:	BAR <= 8'h20; //SLOT 4

	5'h1A:	BAR <= 8'h28; //SLOT 5
	5'h19:	BAR <= 8'h30; //SLOT 6
	5'h18:	BAR <= 8'h38; //SLOT 7
	5'h17:	BAR <= 8'h40; //SLOT 8

	5'h16:	BAR <= 8'h48; //SLOT 9
	5'h15:	BAR <= 8'h50; //SLOT 10
	5'h14:	BAR <= 8'h58; //SLOT 11
	5'h13:	BAR <= 8'h60; //SLOT 12

	5'h12:	BAR <= 8'h68; //SLOT 13
	5'h11:	BAR <= 8'h70; //SLOT 14
	5'h10:	BAR <= 8'h78; //SLOT 15
	5'h0F:	BAR <= 8'h80; //SLOT 16

	5'h0E:	BAR <= 8'h88; //SLOT 17
	5'h0D:	BAR <= 8'h90; //SLOT 18
	5'h0C:	BAR <= 8'h98; //SLOT 19
	5'h0B:	BAR <= 8'hA0; //SLOT 20

	5'h0A:	BAR <= 8'hA8; //SLOT 21
endcase
end


endmodule
