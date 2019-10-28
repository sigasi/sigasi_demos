module mpx_4(sel, din0, din1, din2, din3, dout);

input[1:0]			sel;
input[7:0]			din0, din1, din2, din3;

output[7:0]			dout;

wire[1:0]			sel;
wire[7:0]			din0, din1, din2, din3, din4;
wire[7:0]			din5, din6, din7, din8, din9, dout;

reg[7:0]			mpx_out;


assign				dout = mpx_out;

 
always @(sel or din3 or din2 or din1 or din0)
begin : read_mux
	case (sel) 
		2'b11:		mpx_out <= #1 din0;
		2'b10:		mpx_out <= #1 din1;	
		2'b01:		mpx_out <= #1 din2;	
		2'b00:		mpx_out <= #1 din3;	
			
		default:	mpx_out <= #1 8'hFF;
	
	endcase
end



endmodule

