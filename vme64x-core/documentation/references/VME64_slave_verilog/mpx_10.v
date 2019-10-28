module mpx_10(sel, din0, din1, din2, din3, din4, din5, din6, din7, din8, din9, dout);

input[3:0]			sel;
input[7:0]			din0, din1, din2, din3, din4, din5, din6, din7, din8, din9;

output[7:0]			dout;

wire[3:0]			sel;
wire[7:0]			din0, din1, din2, din3, din4;
wire[7:0]			din5, din6, din7, din8, din9, dout;

reg[7:0]			mpx_out;


assign       		dout = mpx_out; 

always @(sel or din9 or din8 or din7 or din6 or din5 or din4 or din3 or din2 or din1 or din0)
begin : read_mux
	case (sel) 
		4'b1111:		mpx_out <= #1 din0;
		4'b1110:		mpx_out <= #1 din1;	
		4'b1101:		mpx_out <= #1 din2;	
		4'b1100:		mpx_out <= #1 din3;	
		4'b1011:		mpx_out <= #1 din4;
		4'b1010:		mpx_out <= #1 din5;
		4'b1001:		mpx_out <= #1 din6;
		4'b1000:		mpx_out <= #1 din7;
		4'b0111:		mpx_out <= #1 din8;
		4'b0110:		mpx_out <= #1 din9;
			
		default:	mpx_out <= #1 8'hFF;
	
	endcase
end



endmodule

