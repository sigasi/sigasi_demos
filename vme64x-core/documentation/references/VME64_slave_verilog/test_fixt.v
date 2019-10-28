`include "glbl.v"
`timescale 1ns /1ps
module test_fixt();



wire		DTACKn, BERRn, IRQ1n, LOC_R_Wn, LOC_CS, LOC_DS1n, LOC_DS0n;
wire		C_ROM, VME_BUF_DIR, VME_BUF_OE, LHOLD, ADSn, LW_Rn;

tri[31:0]	DATA_BUS, LAD_BUS;

reg			CLOCK, 	RESETn, VME_ASn, VME_R_Wn, DS0n, DS1n, LWORDn, ACK_CYCLE, IACKn;
reg			LHOLDA, READYn;
reg[4:0]	GA;
reg[5:0]	VME_AM;
reg[7:0]	LINTIn;
reg[31:0]	ADDRBUS, data_from_vme, address_reg, data_reg;
integer		vme_address;

parameter	READ  = 1'b1,
			WRITE = 1'b0;

parameter	FUNC0_0 = 19'h7FF63,
			FUNC0_1 = 19'h7FF67,
			FUNC0_2 = 19'h7FF6B,
			FUNC0_3 = 19'h7FF6F;



initial
begin
`ifdef xilinx
	$sdf_annotate( `xilinx, vme_test_fixt.vme_xil_top1,,,, );
`endif

	CLOCK 		<= 1'b0;
	RESETn 		<= 1'b0;
	VME_ASn 	<= 1'b1;
	VME_R_Wn 	<= 1'b1;
	DS0n 		<= 1'b1;
	DS1n 		<= 1'b1;
	LWORDn 		<= 1'b1;
	ACK_CYCLE 	<= 1'b0;
	IACKn		<= 1'b1;
	READYn 		<= 1'b0;
	LHOLDA		<= 1'b1;
	LINTIn		<= 8'hFF;
	GA			<= 5'h1C;	// slot 3
	VME_AM 		<= 6'h2F;

	ADDRBUS 	<= 32'h00_18_00_50;

	repeat(5) @(posedge CLOCK);
	RESETn 		<= 1'b1;

	repeat(10) @(posedge CLOCK);
	wait (DTACKn);
	@(posedge CLOCK) VME_ASn <= 1'b0;
	wait (~DTACKn);
	@(posedge DTACKn) #5 VME_ASn <= 1'b1;

	ADDRBUS 	<= 32'h00_1F_FC_50;

	repeat(10) @(posedge CLOCK);
	wait (DTACKn);
	@(posedge CLOCK) VME_ASn <= 1'b0;
	wait (~DTACKn);
	@(posedge DTACKn) #5 VME_ASn <= 1'b1;
	repeat(10) @(posedge CLOCK);

	vme_address 	<= 32'h00_1F_FC_00;

@(posedge CLOCK);
	repeat(10)
	begin
		vme_access(READ, vme_address, 32'hz, 6'h2F);
		vme_address <= vme_address + 4;
		repeat(10) @(posedge CLOCK);
	end
	vme_address 	<= 32'h00_18_00_00;
@(posedge CLOCK);
	repeat(10)
	begin
		vme_access(READ, vme_address, 32'hz, 6'h2F);
		vme_address <= vme_address + 4;
		repeat(10) @(posedge CLOCK);
	end
//write 
	vme_access(WRITE, {11'b0,2'b11,FUNC0_0}, 32'h00000055, 6'h2F);

	repeat(10) @(posedge CLOCK);
	vme_access(WRITE, 32'h55000004, 32'h00000055, 6'h09);

	repeat(10) @(posedge CLOCK);
	vme_access(READ, 32'h55000008, 32'hz, 6'h09);

	repeat(100) @(posedge CLOCK);
	$stop;
	
end

assign DATA_BUS = (~VME_R_Wn) ? data_reg : 32'hz ; //high selects left



always #12 CLOCK 	<= ~CLOCK;

 vme_xil_top vme_xil_top1(
.CLOCK(CLOCK), 
.RESETn(RESETn), 
.ADDRBUS(ADDRBUS),
.VME_AM(VME_AM), 
.VME_ASn(VME_ASn), 
.VME_R_Wn(VME_R_Wn), 
.DS0n(DS0n), 
.DS1n(DS1n), 
.LWORDn(LWORDn),
.GA(GA), 
.ACK_CYCLE(ACK_CYCLE), 
.DATA_BUS(DATA_BUS), 
.DTACKn(DTACKn), 
.BERRn(BERRn), 
.IRQ1n(IRQ1n), 
.LOC_R_Wn(LOC_R_Wn), 
.LOC_CS(LOC_CS), 
.LOC_DS1n(LOC_DS1n), 
.LOC_DS0n(LOC_DS0n), 
.C_ROM(C_ROM), 
.VME_BUF_DIR(VME_BUF_DIR), 
.VME_BUF_OE(VME_BUF_OE),
.LHOLD(LHOLD),
.LHOLDA(LHOLDA),
.LAD_BUS(LAD_BUS), 
.ADSn(ADSn), 
.LW_Rn(LW_Rn), 
.READYn(READYn), 
.LINTIn(LINTIn)  
 );

task vme_access;
input		read;
input[31:0] address, data_in;
input[5:0]	am;
begin
	data_reg = data_in;
	address_reg = address;	
	ADDRBUS <= address_reg;
	VME_AM <= am;
	LWORDn <= 1'b1;
	IACKn	<= 1'b1;
	#35 VME_ASn <= 1'b0;
	if(~read) VME_R_Wn <= 1'b0;


	wait (DTACKn & ~BERRn);
	DS0n	<= 1'b0;
	DS1n	<= 1'b0;
	wait (~DTACKn);
	if (read) data_from_vme <= DATA_BUS;
	#40	VME_ASn <= 1'b1;
	DS0n	<= 1'b1;
	DS1n	<= 1'b1;
	#10 VME_R_Wn <= 1'b1;
//just to finish the cycle in Jose's slave wait wait
	wait (DTACKn);


end
endtask






endmodule

