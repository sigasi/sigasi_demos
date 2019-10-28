module loc_bus(CLOCK, RESETn, ADDRBUS, DATA_BUS, DTACKn, VME_R_Wn, LOC_CS, LOC_R_Wn, LHOLD, LHOLDA, LAD_BUS, ADSn, LW_Rn, READYn, LOCAL_BUS_IN);

input			CLOCK, RESETn, DTACKn, VME_R_Wn, LOC_CS, LOC_R_Wn, LHOLDA, READYn;
input[31:0]		ADDRBUS; 	
inout[31:0]		DATA_BUS, LAD_BUS;	

output			LHOLD, ADSn, LW_Rn;
output[31:0]	LOCAL_BUS_IN;

wire			CLOCK, RESETn, DTACKn, VME_R_Wn, LOC_CS, LOC_R_Wn, LHOLDA, READYn;
wire			LHOLD, ADSn, LW_Rn, read;

wire[31:0]		ADDRBUS, DATA_BUS, LAD_BUS, INT_BUS, LOCAL_BUS_IN;

reg[6:0]		state, next_state;
reg[31:0]		data_bus_reg;

parameter			L_IDLE		= 0,  //0000
					L_ADS_R		= 1,  //0003
					L_ADS_W		= 2,  //0005
					L_READ		= 3,  //0009
					L_WRITE		= 4,  //0011
					L_END		= 5,  //0021
					L_ILLEGAL	= 6;  //0041

assign LAD_BUS 	= (state[L_READ]) ?  32'hz : INT_BUS; //high selects left

assign INT_BUS 	= ((~state[L_IDLE]) | (state[L_ADS_R]) | (state[L_ADS_W])) ?  ADDRBUS : DATA_BUS; //high selects left

assign ADSn		= ~((state[L_ADS_R]) | (state[L_ADS_W]));

assign LW_Rn	= ~((state[L_ADS_R]) | (state[L_READ]));

assign LHOLD 	= 1'b1;

//assign DATA_BUS  = (LOC_CS & ~DTACKn & VME_R_Wn) ? data_bus_reg : 32'bz ; //high selects left

assign read = (~LW_Rn & ~READYn);

assign LOCAL_BUS_IN = data_bus_reg;

always @(posedge read or negedge RESETn)
begin
	if (~RESETn) data_bus_reg <= 32'b0;
	else if (read) data_bus_reg <= LAD_BUS;
end

/*********************************************************/
//		STATE MACHINE
/*********************************************************/
always @(LHOLDA or LOC_CS or LOC_R_Wn or READYn or state)

begin
next_state = 6'b00_0001;

case(1'b1) 
~state[L_IDLE]: //00
begin
	if (LHOLDA & LOC_CS & LOC_R_Wn) 		next_state[L_ADS_R] = 1'b1;
	else if (LHOLDA & LOC_CS & ~LOC_R_Wn) 	next_state[L_ADS_W] = 1'b1;
	else									next_state[L_IDLE] 	= 1'b0;
end


state[L_ADS_R]: //03
begin
					next_state[L_READ] = 1'b1;
end

state[L_ADS_W]: //05
begin
					next_state[L_WRITE] = 1'b1;
end

state[L_READ]: //09
begin
	if(~READYn)		next_state[L_END]  = 1'b1;
	else			next_state[L_READ] = 1'b1;
end
state[L_WRITE]: //11
begin
	if(~READYn)		next_state[L_END] 	= 1'b1;
	else			next_state[L_WRITE] = 1'b1;
end
state[L_END]: 	//21
begin
	if(~LOC_CS)		next_state[L_IDLE] 	= 1'b0;
	else			next_state[L_END] = 1'b1;
end

default: 		//41
begin
					next_state[L_ILLEGAL] = 1'b1;
end

endcase
end

// build the state flip-flops

always @(posedge CLOCK or negedge RESETn)
begin
if (~RESETn) 
begin
	state 	<= #1 7'b000_0000;
end
else 
	state 	<= #1 next_state;
end


endmodule
/*
task access_local_bus;
input		write_lbus;
input[31:0] address, data_in;
begin
//wait(~lhold)
//wait(~lholda)
lw_r <= #10 1'b1;
dt_r <= #10 1'b1;
data_reg = data_in;
address_reg = address;

	begin 		
		@(posedge clk) 
			begin
				lhold <= #10 1'b1;
				data_from_fec <= #10 32'bx;
			end
		wait(lholda)
			@(posedge clk) 
			begin
				adsz  <= #10 1'b0;
				if(~write_lbus) begin
					lw_r <= #10 1'b0;
					dt_r <= #10 1'b0;
				end

			end
		@(posedge clk); 
			begin
				adsz   <= #10 1'b1;
				d_en  <= #10 1'b0;
			end
		wait(~readyz)
			begin
				blastz <= #10 1'b0;
			end
		@(posedge clk)
			begin
				blastz <= #10 1'b1;
				if(~write_lbus) data_from_fec	<= #10 lad_bus;

			end

		@(posedge clk) 		
			begin
				lw_r  <= #10 1'b1;
				lhold <= #10 1'b1;
				d_en  <= #10 1'b1;
				dt_r  <= #10 1'b1;
			end
		@(posedge clk);
	
	end
end
endtask
*/
