//-- Most inputs are the VME lines, direct connetcion, or trough buffers...

//-- ACK_CYCLE = vme cycle acknoledge, used to finish the VME data cycle, starts the counter delay for the DTACK generation!
//-- CROM- clock of the ROM used only in configuration read cycles...
//-- IRQ1n is not used 
//-- BERRn is not used


module vme_slave (CLOCK, RESETn, BAR, ADDRBUS,
VME_AM, VME_ASn, VME_R_Wn, DS0n, DS1n, LWORDn , ACK_CYCLE, ROM_DATA, DATA_BUS,
DTACKn, BERRn, IRQ1n, LOC_R_Wn, LOC_CS, LOC_DS1n, LOC_DS0n, CR_SPACE, C_ROM, VME_BUF_DIR , VME_BUF_OE,
LOCAL_BUS_IN 
 );

input			CLOCK, RESETn, VME_ASn, VME_R_Wn, DS0n, DS1n, LWORDn , ACK_CYCLE;
input[5:0]		VME_AM;
input[7:0]		BAR, ROM_DATA;
input[31:0]		ADDRBUS, LOCAL_BUS_IN;

inout[31:0]		DATA_BUS;

output			DTACKn, BERRn, IRQ1n, LOC_R_Wn, LOC_CS, LOC_DS1n;
output			LOC_DS0n, C_ROM, VME_BUF_DIR , VME_BUF_OE;
output[10:0]	CR_SPACE;


wire			CLOCK, RESETn, VME_ASn, VME_R_Wn, DS0n, DS1n, LWORDn , ACK_CYCLE;
wire[5:0]		VME_AM;
wire[7:0]		BAR, ROM_DATA, INT_BUS;
wire[7:0]		CR_CSR, CSR_BUS, UDB, FUNC7, FUNC6, FUNC5, FUNC4, FUNC3, FUNC2, FUNC1, FUNC0;
wire[31:0]		ADDRBUS, DATA_BUS, INTBUS_TRI, LOCAL_BUS_IN, LOCAL_BUS;
wire			DTACKn, BERRn, IRQ1n, LOC_R_Wn, LOC_CS, LOC_DS1n, CARD_SEL_DLY_START;
wire			LOC_DS0n, C_ROM_clk, CSR_READ, CSR_WRITE, CLR_ADD, READ;
wire			BIT_SET_EN, BIT_CLR_EN, CRAM_OWNER_REG_EN, UD_BIT_SET_REG_EN, UD_BIT_CLR_REG_EN;
wire			FUNC7_ADER_EN3, FUNC7_ADER_EN2, FUNC7_ADER_EN1, FUNC7_ADER_EN0;
wire			FUNC6_ADER_EN3, FUNC6_ADER_EN2, FUNC6_ADER_EN1, FUNC6_ADER_EN0;
wire			FUNC5_ADER_EN3, FUNC5_ADER_EN2, FUNC5_ADER_EN1, FUNC5_ADER_EN0;
wire			FUNC4_ADER_EN3, FUNC4_ADER_EN2, FUNC4_ADER_EN1, FUNC4_ADER_EN0;
wire			FUNC3_ADER_EN3, FUNC3_ADER_EN2, FUNC3_ADER_EN1, FUNC3_ADER_EN0;
wire			FUNC2_ADER_EN3, FUNC2_ADER_EN2, FUNC2_ADER_EN1, FUNC2_ADER_EN0;
wire			FUNC1_ADER_EN3, FUNC1_ADER_EN2, FUNC1_ADER_EN1, FUNC1_ADER_EN0;
wire			FUNC0_ADER_EN3, FUNC0_ADER_EN2, FUNC0_ADER_EN1, FUNC0_ADER_EN0;
wire			CARD_SEL_DLY_9, CARDSEL, CONF_ACCESS, CR, CSR;


reg				CLOCK_DIV, C_ROM;
reg				FUNC0_SEL0, FUNC1_SEL0, FUNC2_SEL0, FUNC3_SEL0, FUNC4_SEL0, FUNC5_SEL0, FUNC6_SEL0, FUNC7_SEL0;
reg				FUNC0_SEL1, FUNC1_SEL1, FUNC2_SEL1, FUNC3_SEL1, FUNC4_SEL1, FUNC5_SEL1, FUNC6_SEL1, FUNC7_SEL1;
reg				FUNC0_SEL2, FUNC1_SEL2, FUNC2_SEL2, FUNC3_SEL2, FUNC4_SEL2, FUNC5_SEL2, FUNC6_SEL2, FUNC7_SEL2;
reg				FUNC0_SEL3, FUNC1_SEL3, FUNC2_SEL3, FUNC3_SEL3, FUNC4_SEL3, FUNC5_SEL3, FUNC6_SEL3, FUNC7_SEL3;
reg				BAR_SEL, BIT_C_SEL, BIT_S_SEL, UDBS_SEL, UDBC_SEL, CRAM_SEL;
reg				VME_BUF_DIR , VME_BUF_OE, DEC_A0, VME_AS_REG, VME_AS_REG0;

reg[5:0]		V_AM;
reg[7:0]		BIT_SET_REG, BIT_CLR_REG, CRAM_OWNER_REG, UD_BIT_SET_REG, UD_BIT_CLR_REG;
reg[10:0]		CR_SPACE;
reg[11:0]		CARD_SEL_DLY;
reg[18:0]		CSR_SPACE;
reg[31:0]		V_ADD;
reg[31:0]		FUNC7_ADER, FUNC6_ADER, FUNC5_ADER, FUNC4_ADER, FUNC3_ADER, FUNC2_ADER, FUNC1_ADER, FUNC0_ADER;

assign READ 		= (VME_R_Wn & CONF_ACCESS) | (VME_R_Wn & CARDSEL);

assign DATA_BUS = (READ) ? LOCAL_BUS : 32'hz ; //high selects left


assign INT_BUS = (CSR_READ) ? CSR_BUS : ROM_DATA;	//high selects left

assign LOCAL_BUS = (LOC_R_Wn) ? LOCAL_BUS_IN : {24'b0, INT_BUS};	//high selects left

//assign INTBUS_TRI = {24'b0, DATA_BUS[7:0]};
//-----------------------------------------------------------------------------------
//--- VME TO LOCAL BUS INTERFACE DEFINITIONS
//-----------------------------------------------------------------------------------

assign	CSR_WRITE	= (~VME_R_Wn & CSR & CONF_ACCESS);
//CSR write signal, allows write of the CSR registers

assign	CSR_READ	= (VME_R_Wn & CSR & CONF_ACCESS);
//CSR Read signal, allows read of the CSR Registers

assign	CLR_ADD		= (~RESETn | (CARD_SEL_DLY[10] & ~CARD_SEL_DLY[11])); //shorted by adding ~[11]
//CLEAR VME ADDRESS AND AM REGISTERS ...after sending DTACK card_sel_dly[10] arrives
//some clocks later to end the access to the board, clears regsiters and "close" buffers

assign 	LOC_DS1n	= (DS1n & CARDSEL);
assign	LOC_DS0n	= (DS0n & CARDSEL);

assign	LOC_R_Wn	= (VME_R_Wn & CARDSEL);
//Local Rwad Write signal active when card is selected only...

assign	LOC_CS		= CARDSEL;
assign	BERRn		= 1'b0;
assign	IRQ1n		= 1'b0;

assign	DTACKn = !CARD_SEL_DLY[2];
//--dtack duration  (from CARD_SEL_DLY[2] to CARD_SEL_DLY[9] in this case)
//-- IMPORTANT: depending of the logic used externally remove or not the inversion ("!") or the  CARD_SEL_DLY[2] signal !


//--------------------------------------------------------------
//-- COMPARE VME_ADD AND VME_AM 
//--------------------------------------------------------------
//--BIDIR BUS (LOC_DATA AND VMEDATA)
//-- only implemented a one byte access to the CR and CSR regions
//-- databus[31:8] is implemented for future changes_need.

//DATA_BUS = INTBUS_TRI.out;
//INTBUS_TRI[31:8]= 1'b0;
//INTBUS_TRI[31:8].oe= 1'b0;

//----------------------------------
// synchronisation of VME_ASn
always @(posedge CLOCK or negedge RESETn)
begin
	if (~RESETn)		VME_AS_REG0 <= 1'b0;
	else			 	VME_AS_REG0 <= ~VME_ASn;
end		

always @(posedge CLOCK or negedge RESETn)
begin
	if (~RESETn)		VME_AS_REG <= 1'b0;
	else			 	VME_AS_REG <= VME_AS_REG0;
end		

//----------------------------------
always @(negedge VME_ASn or posedge CLR_ADD)
begin
	if (CLR_ADD)	V_ADD[31:0] <= 32'b1;
	else			V_ADD[31:0] <= ADDRBUS[31:0];
end		

always @(negedge VME_ASn or posedge CLR_ADD)
begin
	if (CLR_ADD)		V_AM[5:0] <= 6'b1;
	else				V_AM[5:0] <= VME_AM[5:0];
end	


//---------------------------------------------------
//--- DTACK DELAY and LOCAL_CS Generator 
//---------------------------------------------------
//-- simply a delay counter to send and finish DTACK signal
//--started with some conditions that each user must define 

assign CARD_SEL_DLY_9 = ((CARD_SEL_DLY[9] & ~CARD_SEL_DLY[10])| ~RESETn); //shorted by adding ~[10]

assign CARD_SEL_DLY_START = ( ((CARDSEL | CR | CSR) & VME_AS_REG)  | ACK_CYCLE);

//-- this are the conditions to finish the Cycle 
//-- user can add conditons ..
//-- CARDSEL automaticaly ends the "data" vme cycle if the board is accessed.
//-- CR or CSR ends the configuration cycles
//-- ACK_Cycle is the external signal to end the signal, can be "and" with card_sel...
//-- use of "or CR or CSR" in this condition is mandatory


always @(posedge CLOCK or negedge RESETn)
begin
	if (~RESETn) 	CLOCK_DIV <= 1'b0;
	else 			CLOCK_DIV <= ~CLOCK_DIV;
end
/*
always @(posedge CARD_SEL_DLY_START or posedge CARD_SEL_DLY_9)
begin
	if(CARD_SEL_DLY_9)		CARD_SEL_DLY[0] <= 1'b0;
	else 					CARD_SEL_DLY[0] <= 1'b1;
end
*/
always @(posedge CLOCK_DIV or posedge CARD_SEL_DLY_9)
begin
	if(CARD_SEL_DLY_9)			CARD_SEL_DLY[0] <= 1'b0;
	else if(CARD_SEL_DLY_START)	CARD_SEL_DLY[0] <= 1'b1;
end

always @(posedge CLOCK_DIV or posedge CARD_SEL_DLY_9)
begin
	if(CARD_SEL_DLY_9)		CARD_SEL_DLY[1] <= 1'b0;
	else					CARD_SEL_DLY[1] <= CARD_SEL_DLY[0];
end
always @(posedge CLOCK_DIV or posedge CARD_SEL_DLY_9)
begin
	if(CARD_SEL_DLY_9)		CARD_SEL_DLY[2] <= 1'b0;
	else					CARD_SEL_DLY[2] <= CARD_SEL_DLY[1];
end

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[3] <= 1'b0;
	else					CARD_SEL_DLY[3] <= CARD_SEL_DLY[2];
end

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[4] <= 1'b0;
	else					CARD_SEL_DLY[4] <= CARD_SEL_DLY[3];
end

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[5] <= 1'b0;
	else					CARD_SEL_DLY[5] <= CARD_SEL_DLY[4];
end

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[6] <= 1'b0;
	else					CARD_SEL_DLY[6] <= CARD_SEL_DLY[5];
end

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[7] <= 1'b0;
	else					CARD_SEL_DLY[7] <= CARD_SEL_DLY[6];
end

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[8] <= 1'b0;
	else					CARD_SEL_DLY[8] <= CARD_SEL_DLY[7];
end

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[9] <= 1'b0;
	else					CARD_SEL_DLY[9] <= CARD_SEL_DLY[8];
end
//-- end of DTACKn and clear of delay counters
//-- user can extend the DTACK adding more registers to the CARD_SEL_DLY...

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[10] <= 1'b0;
	else					CARD_SEL_DLY[10] <= CARD_SEL_DLY[9];
end
always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if(~RESETn)				CARD_SEL_DLY[11] <= 1'b0;
	else					CARD_SEL_DLY[11] <= CARD_SEL_DLY[10];
end
//-----------------------------------------------------------
//-- LOCAL BUS BUFFERS CONTROL AND SELECTION
//-----------------------------------------------------------
//--There are 2 lines for data the vme data bus drivers control..
//-- users can use any kind of drivers, and care to change the "default"
//-- state of these lines prior to test the VME access 


always @(VME_R_Wn or CARDSEL or CONF_ACCESS)
begin
if (!VME_R_Wn & (CARDSEL | CONF_ACCESS))
	begin
		VME_BUF_DIR <= 1'b1;	//VME BUS DRIVERS = VME -> LOCAL BUS
		VME_BUF_OE	<= 1'b0;
	end
else if(VME_R_Wn & (CARDSEL | CONF_ACCESS))
	begin
		VME_BUF_DIR <= 1'b0;	//VME BUS DRIVERS =  LOCAL BUS -> VME
		VME_BUF_OE	<= 1'b0;
	end
else
	begin
		VME_BUF_DIR <= 1'b0;	//VME BUS DRIVERS OFF
		VME_BUF_OE	<= 1'b1;
	end
end



//-----------------------------------------------------------
//-- CR_CSR SPACE ADDRESS DECODE REGION
//-----------------------------------------------------------

//-- address decoder for the CR or CSR space
//-- not much to say...
//-- compares the VME address with the crate position and the AM 
//-- and selects from the Address region "18..0" if is an access to the CR or to the CSR"
//-- VME ADDRESS [0] is added here.

assign CONF_ACCESS = ((V_ADD[23:19] == BAR[7:3]) & (V_AM[5:0] == 6'h2F) );

assign CSR = (CONF_ACCESS & (V_ADD[18:0] >= 19'h7FC00));

assign CR = (CONF_ACCESS & (V_ADD[18:0] < 19'h7FC00));

always @(CR or V_ADD)
	begin
		if (CR) CR_SPACE[10:0] <= V_ADD[12:2]; //CR ADDRESS (READ CYCLES ONLY)
		else CR_SPACE[10:0]		<= 11'b0;
	end

always @(CSR or V_ADD)
	begin
		if (CSR) CSR_SPACE[18:0] <= {V_ADD[18:1], 1'b1};	// CSR ADDRESS 
		else CSR_SPACE[18:0] <= 19'b0;
	end
		

assign C_ROM_clk = (CR & VME_R_Wn & CONF_ACCESS & CARD_SEL_DLY[2]);

always @(posedge C_ROM_clk or posedge CLR_ADD)
begin
	if(CLR_ADD) C_ROM <= 1'b0;
	else 		 C_ROM <= 1'b1;
end
 
//CSR.clk = CLOCK;
//-- condition to access the CR_ROM : 
//-- cr decoded, read access, conf_access (just a protection) and DTACK started : data is placed on bus 
//-- to the CPU to get it...

//-- the MAIN address compare (base address of the board and it's access mode as refered on the VME ROM)...
//-- check the ROM definitions for address bit compare and address modifier in use...
//-- 2 examples of the same baord...

//--------------------------------------------------------------------------------
//--1st MAIN ADDRESS COMPARE. select the compare mask (FUNC0_ADER[31 to 24])
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//-- 2nd  MAIN ADDRESS COMPARE. select the compare mask (FUNC1_ADER[31 to 24])
//--------------------------------------------------------------------------------

assign CARDSEL = ( (FUNC0_ADER[31:24] == V_ADD[31:24]) & (V_AM[5:0] == 6'h09)  & ~CONF_ACCESS) | 
					((FUNC1_ADER[31:24] == V_ADD[31:24]) & (V_AM[5:0] == 6'h0B)  & ~CONF_ACCESS);


mpx_4 CR_CSR_MPX(
.sel(CSR_SPACE[3:2]), 
.din0(BAR[7:0]), 
.din1(BIT_SET_REG[7:0]), 
.din2(BIT_CLR_REG[7:0]), 
.din3(CRAM_OWNER_REG[7:0]), 
.dout(CR_CSR)
);

mpx_4 UDB_MPX(
.sel(CSR_SPACE[3:2]), 
.din0(UD_BIT_SET_REG[7:0]), 
.din1(UD_BIT_CLR_REG[7:0]), 
.din2(8'b0), 
.din3(8'b0), 
.dout(UDB)
);

mpx_4 FUNC_7(
.sel(CSR_SPACE[3:2]), 
.din0(FUNC7_ADER[7:0]), 
.din1(FUNC7_ADER[15:8]), 
.din2(FUNC7_ADER[23:16]), 
.din3(FUNC7_ADER[31:24]), 
.dout(FUNC7)
);

mpx_4 FUNC_6(
.sel(CSR_SPACE[3:2]), 
.din0(FUNC6_ADER[7:0]), 
.din1(FUNC6_ADER[15:8]), 
.din2(FUNC6_ADER[23:16]), 
.din3(FUNC6_ADER[31:24]), 
.dout(FUNC6)
);

mpx_4 FUNC_5(
.sel(CSR_SPACE[3:2]), 
.din0(FUNC5_ADER[7:0]), 
.din1(FUNC5_ADER[15:8]), 
.din2(FUNC5_ADER[23:16]), 
.din3(FUNC5_ADER[31:24]), 
.dout(FUNC5)
);
mpx_4 FUNC_4(
.sel(CSR_SPACE[3:2]), 
.din0(FUNC4_ADER[7:0]), 
.din1(FUNC4_ADER[15:8]), 
.din2(FUNC4_ADER[23:16]), 
.din3(FUNC4_ADER[31:24]), 
.dout(FUNC4)
);
mpx_4 FUNC_3(
.sel(CSR_SPACE[3:2]), 
.din0(FUNC3_ADER[7:0]), 
.din1(FUNC3_ADER[15:8]), 
.din2(FUNC3_ADER[23:16]), 
.din3(FUNC3_ADER[31:24]), 
.dout(FUNC3)
);
mpx_4 FUNC_2(
.sel(CSR_SPACE[3:2]), 
.din0(FUNC2_ADER[7:0]), 
.din1(FUNC2_ADER[15:8]), 
.din2(FUNC2_ADER[23:16]), 
.din3(FUNC2_ADER[31:24]), 
.dout(FUNC2)
);
mpx_4 FUNC_1(
.sel(CSR_SPACE[3:2]), 
.din0(FUNC1_ADER[7:0]), 
.din1(FUNC1_ADER[15:8]), 
.din2(FUNC1_ADER[23:16]), 
.din3(FUNC1_ADER[31:24]), 
.dout(FUNC1)
);
mpx_4 FUNC_0(
.sel(CSR_SPACE[3:2]), 
.din0(FUNC0_ADER[7:0]), 
.din1(FUNC0_ADER[15:8]), 
.din2(FUNC0_ADER[23:16]), 
.din3(FUNC0_ADER[31:24]), 
.dout(FUNC0)
);

mpx_10 FUNC(
.sel(CSR_SPACE[7:4]),
.din0(CR_CSR), 
.din1(UDB), 
.din2(FUNC7), 
.din3(FUNC6), 
.din4(FUNC5), 
.din5(FUNC4), 
.din6(FUNC3), 
.din7(FUNC2), 
.din8(FUNC1), 
.din9(FUNC0), 
.dout(CSR_BUS[7:0])
);

 
always @(CSR_SPACE)
begin
case(CSR_SPACE[18:0])
19'h7FFFF:	BAR_SEL	  <= 1'b1;	//-- CR_CSR BAR READ VALUE
19'h7FFFB:	BIT_S_SEL <= 1'b1;	//-- BIT SET REGISTER WRITE
19'h7FFF7:	BIT_C_SEL <= 1'b1;	//-- BIT CLEAR REGISTER WRITE
19'h7FFF3:	CRAM_SEL  <= 1'b1;	//-- CONFIGURATION RAM ACESS -- OPTIONAL WRITE

19'h7FFEF:	UDBS_SEL  <= 1'b1;	//-- OPTIONAL
19'h7FFEB:	UDBC_SEL  <= 1'b1;	//-- OPTIONAL

//-- MANDATORY, MAIN ADDRESS TO COMPARE, ADER7
19'h7FFDF:	FUNC7_SEL3 <= 1'b1;	
19'h7FFDB:	FUNC7_SEL2 <= 1'b1;
19'h7FFD7:	FUNC7_SEL1 <= 1'b1;
19'h7FFD3:	FUNC7_SEL0 <= 1'b1;
	
//-- MANDATORY, MAIN ADDRESS TO COMPARE, ADER6
19'h7FFCF:	FUNC6_SEL3 <= 1'b1;
19'h7FFCB:	FUNC6_SEL2 <= 1'b1;
19'h7FFC7:	FUNC6_SEL1 <= 1'b1;
19'h7FFC3:	FUNC6_SEL0 <= 1'b1;

//-- MANDATORY, MAIN ADDRESS TO COMPARE, ADER5
19'h7FFBF:	FUNC5_SEL3 <= 1'b1;
19'h7FFBB:	FUNC5_SEL2 <= 1'b1;
19'h7FFB7:	FUNC5_SEL1 <= 1'b1;
19'h7FFB3:	FUNC5_SEL0 <= 1'b1;

//-- MANDATORY, MAIN ADDRESS TO COMPARE, ADER4
19'h7FFAF:	FUNC4_SEL3 <= 1'b1;
19'h7FFAB:	FUNC4_SEL2 <= 1'b1;
19'h7FFA7:	FUNC4_SEL1 <= 1'b1;
19'h7FFA3:	FUNC4_SEL0 <= 1'b1;
	
//-- MANDATORY, MAIN ADDRESS TO COMPARE, ADER3
19'h7FF9F:	FUNC3_SEL3 <= 1'b1;
19'h7FF9B:	FUNC3_SEL2 <= 1'b1;
19'h7FF97:	FUNC3_SEL1 <= 1'b1;
19'h7FF93:	FUNC3_SEL0 <= 1'b1;

//-- MANDATORY, MAIN ADDRESS TO COMPARE, ADER2
19'h7FF8F:	FUNC2_SEL3 <= 1'b1;
19'h7FF8B:	FUNC2_SEL2 <= 1'b1;
19'h7FF87:	FUNC2_SEL1 <= 1'b1;
19'h7FF83:	FUNC2_SEL0 <= 1'b1;

//-- MANDATORY, MAIN ADDRESS TO COMPARE, ADER1
19'h7FF7F:	FUNC1_SEL3 <= 1'b1;
19'h7FF7B:	FUNC1_SEL2 <= 1'b1;
19'h7FF77:	FUNC1_SEL1 <= 1'b1;
19'h7FF73:	FUNC1_SEL0 <= 1'b1;

//-- MANDATORY, MAIN ADDRESS TO COMPARE, ADER0
19'h7FF6F:	FUNC0_SEL3 <= 1'b1;
19'h7FF6B:	FUNC0_SEL2 <= 1'b1;
19'h7FF67:	FUNC0_SEL1 <= 1'b1;
19'h7FF63:	FUNC0_SEL0 <= 1'b1;

default:
	begin
	BAR_SEL  <= 1'b0;
	BIT_S_SEL<= 1'b0;
	BIT_C_SEL<= 1'b0;
	CRAM_SEL <= 1'b0;
	UDBS_SEL <= 1'b0;
	UDBC_SEL <= 1'b0;

	FUNC0_SEL0 <= 1'b0;
	FUNC1_SEL0 <= 1'b0;
	FUNC2_SEL0 <= 1'b0;
	FUNC3_SEL0 <= 1'b0;
	FUNC4_SEL0 <= 1'b0;
	FUNC5_SEL0 <= 1'b0;
	FUNC6_SEL0 <= 1'b0;
	FUNC7_SEL0 <= 1'b0;

	FUNC0_SEL1 <= 1'b0;
	FUNC1_SEL1 <= 1'b0;
	FUNC2_SEL1 <= 1'b0;
	FUNC3_SEL1 <= 1'b0;
	FUNC4_SEL1 <= 1'b0;
	FUNC5_SEL1 <= 1'b0;
	FUNC6_SEL1 <= 1'b0;
	FUNC7_SEL1 <= 1'b0;

	FUNC0_SEL2 <= 1'b0;
	FUNC1_SEL2 <= 1'b0;
	FUNC2_SEL2 <= 1'b0;
	FUNC3_SEL2 <= 1'b0;
	FUNC4_SEL2 <= 1'b0;
	FUNC5_SEL2 <= 1'b0;
	FUNC6_SEL2 <= 1'b0;
	FUNC7_SEL2 <= 1'b0;

	FUNC0_SEL3 <= 1'b0;
	FUNC1_SEL3 <= 1'b0;
	FUNC2_SEL3 <= 1'b0;
	FUNC3_SEL3 <= 1'b0;
	FUNC4_SEL3 <= 1'b0;
	FUNC5_SEL3 <= 1'b0;
	FUNC6_SEL3 <= 1'b0;
	FUNC7_SEL3 <= 1'b0;

	end

endcase
end




//-----------------------------------------------------------------
//---- REGISTERS
//-----------------------------------------------------------------

assign FUNC7_ADER_EN3 = (CSR_WRITE & !DS0n & FUNC7_SEL3);
assign FUNC7_ADER_EN2 = (CSR_WRITE & !DS0n & FUNC7_SEL2);
assign FUNC7_ADER_EN1 = (CSR_WRITE & !DS0n & FUNC7_SEL1);
assign FUNC7_ADER_EN0 = (CSR_WRITE & !DS0n & FUNC7_SEL0);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) FUNC7_ADER[31:0] <= 32'b0;
	else if(FUNC7_ADER_EN3) FUNC7_ADER[7:0] 	<= DATA_BUS[7:0];
	else if(FUNC7_ADER_EN2) FUNC7_ADER[15:8] 	<= DATA_BUS[7:0];
	else if(FUNC7_ADER_EN1) FUNC7_ADER[23:16] 	<= DATA_BUS[7:0];
	else if(FUNC7_ADER_EN0) FUNC7_ADER[31:24] 	<= DATA_BUS[7:0];
end


assign FUNC6_ADER_EN3 = (CSR_WRITE & !DS0n & FUNC6_SEL3);
assign FUNC6_ADER_EN2 = (CSR_WRITE & !DS0n & FUNC6_SEL2);
assign FUNC6_ADER_EN1 = (CSR_WRITE & !DS0n & FUNC6_SEL1);
assign FUNC6_ADER_EN0 = (CSR_WRITE & !DS0n & FUNC6_SEL0);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) FUNC6_ADER[31:0] <= 32'b0;
	else if(FUNC6_ADER_EN3) FUNC6_ADER[7:0] 	<= DATA_BUS[7:0];
	else if(FUNC6_ADER_EN2) FUNC6_ADER[15:8] 	<= DATA_BUS[7:0];
	else if(FUNC6_ADER_EN1) FUNC6_ADER[23:16] 	<= DATA_BUS[7:0];
	else if(FUNC6_ADER_EN0) FUNC6_ADER[31:24] 	<= DATA_BUS[7:0];
end

assign FUNC5_ADER_EN3 = (CSR_WRITE & !DS0n & FUNC5_SEL3);
assign FUNC5_ADER_EN2 = (CSR_WRITE & !DS0n & FUNC5_SEL2);
assign FUNC5_ADER_EN1 = (CSR_WRITE & !DS0n & FUNC5_SEL1);
assign FUNC5_ADER_EN0 = (CSR_WRITE & !DS0n & FUNC5_SEL0);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) FUNC5_ADER[31:0] <= 32'b0;
	else if(FUNC5_ADER_EN3) FUNC5_ADER[7:0] 	<= DATA_BUS[7:0];
	else if(FUNC5_ADER_EN2) FUNC5_ADER[15:8] 	<= DATA_BUS[7:0];
	else if(FUNC5_ADER_EN1) FUNC5_ADER[23:16] 	<= DATA_BUS[7:0];
	else if(FUNC5_ADER_EN0) FUNC5_ADER[31:24] 	<= DATA_BUS[7:0];
end

assign FUNC4_ADER_EN3 = (CSR_WRITE & !DS0n & FUNC4_SEL3);
assign FUNC4_ADER_EN2 = (CSR_WRITE & !DS0n & FUNC4_SEL2);
assign FUNC4_ADER_EN1 = (CSR_WRITE & !DS0n & FUNC4_SEL1);
assign FUNC4_ADER_EN0 = (CSR_WRITE & !DS0n & FUNC4_SEL0);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) FUNC4_ADER[31:0] <= 32'b0;
	else if(FUNC4_ADER_EN3) FUNC4_ADER[7:0] 	<= DATA_BUS[7:0];
	else if(FUNC4_ADER_EN2) FUNC4_ADER[15:8] 	<= DATA_BUS[7:0];
	else if(FUNC4_ADER_EN1) FUNC4_ADER[23:16] 	<= DATA_BUS[7:0];
	else if(FUNC4_ADER_EN0) FUNC4_ADER[31:24] 	<= DATA_BUS[7:0];
end

assign FUNC3_ADER_EN3 = (CSR_WRITE & !DS0n & FUNC3_SEL3);
assign FUNC3_ADER_EN2 = (CSR_WRITE & !DS0n & FUNC3_SEL2);
assign FUNC3_ADER_EN1 = (CSR_WRITE & !DS0n & FUNC3_SEL1);
assign FUNC3_ADER_EN0 = (CSR_WRITE & !DS0n & FUNC3_SEL0);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) FUNC3_ADER[31:0] <= 32'b0;
	else if(FUNC3_ADER_EN3) FUNC3_ADER[7:0] 	<= DATA_BUS[7:0];
	else if(FUNC3_ADER_EN2) FUNC3_ADER[15:8] 	<= DATA_BUS[7:0];
	else if(FUNC3_ADER_EN1) FUNC3_ADER[23:16] 	<= DATA_BUS[7:0];
	else if(FUNC3_ADER_EN0) FUNC3_ADER[31:24] 	<= DATA_BUS[7:0];
end

assign FUNC2_ADER_EN3 = (CSR_WRITE & !DS0n & FUNC2_SEL3);
assign FUNC2_ADER_EN2 = (CSR_WRITE & !DS0n & FUNC2_SEL2);
assign FUNC2_ADER_EN1 = (CSR_WRITE & !DS0n & FUNC2_SEL1);
assign FUNC2_ADER_EN0 = (CSR_WRITE & !DS0n & FUNC2_SEL0);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) FUNC2_ADER[31:0] <= 32'b0;
	else if(FUNC2_ADER_EN3) FUNC2_ADER[7:0] 	<= DATA_BUS[7:0];
	else if(FUNC2_ADER_EN2) FUNC2_ADER[15:8] 	<= DATA_BUS[7:0];
	else if(FUNC2_ADER_EN1) FUNC2_ADER[23:16] 	<= DATA_BUS[7:0];
	else if(FUNC2_ADER_EN0) FUNC2_ADER[31:24] 	<= DATA_BUS[7:0];
end

assign FUNC1_ADER_EN3 = (CSR_WRITE & !DS0n & FUNC1_SEL3);
assign FUNC1_ADER_EN2 = (CSR_WRITE & !DS0n & FUNC1_SEL2);
assign FUNC1_ADER_EN1 = (CSR_WRITE & !DS0n & FUNC1_SEL1);
assign FUNC1_ADER_EN0 = (CSR_WRITE & !DS0n & FUNC1_SEL0);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) FUNC1_ADER[31:0] <= 32'b0;
	else if(FUNC1_ADER_EN3) FUNC1_ADER[7:0] 	<= DATA_BUS[7:0];
	else if(FUNC1_ADER_EN2) FUNC1_ADER[15:8] 	<= DATA_BUS[7:0];
	else if(FUNC1_ADER_EN1) FUNC1_ADER[23:16] 	<= DATA_BUS[7:0];
	else if(FUNC1_ADER_EN0) FUNC1_ADER[31:24] 	<= DATA_BUS[7:0];
end

assign FUNC0_ADER_EN3 = (CSR_WRITE & !DS0n & FUNC0_SEL3);
assign FUNC0_ADER_EN2 = (CSR_WRITE & !DS0n & FUNC0_SEL2);
assign FUNC0_ADER_EN1 = (CSR_WRITE & !DS0n & FUNC0_SEL1);
assign FUNC0_ADER_EN0 = (CSR_WRITE & !DS0n & FUNC0_SEL0);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn)FUNC0_ADER[31:0] <= 32'b0;
	else if(FUNC0_ADER_EN3) FUNC0_ADER[7:0] 	<= DATA_BUS[7:0];
	else if(FUNC0_ADER_EN2) FUNC0_ADER[15:8] 	<= DATA_BUS[7:0];
	else if(FUNC0_ADER_EN1) FUNC0_ADER[23:16] 	<= DATA_BUS[7:0];
	else if(FUNC0_ADER_EN0) FUNC0_ADER[31:24] 	<= DATA_BUS[7:0];
end


assign BIT_SET_EN = (!DS0n & BIT_S_SEL);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) BIT_SET_REG[7:0] <= 8'b0;
	else if(BIT_SET_EN) BIT_SET_REG[7:0] <= DATA_BUS[7:0];
end


assign BIT_CLR_EN = (!DS0n & BIT_C_SEL );

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) BIT_CLR_REG[7:0] <= 8'b0;
	else if(BIT_CLR_EN) BIT_CLR_REG[7:0] <= DATA_BUS[7:0];
end

assign CRAM_OWNER_REG_EN = (!DS0n & CRAM_SEL);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) CRAM_OWNER_REG[7:0] <= 8'b0;
	else if(CRAM_OWNER_REG_EN) CRAM_OWNER_REG[7:0] <= DATA_BUS[7:0];
end

assign UD_BIT_SET_REG_EN = (!DS0n & UDBS_SEL);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) UD_BIT_SET_REG[7:0] <= 8'b0;
	else if(UD_BIT_SET_REG_EN) UD_BIT_SET_REG[7:0] <= DATA_BUS[7:0];
end

assign UD_BIT_CLR_REG_EN = (!DS0n & UDBC_SEL);

always @(posedge CLOCK_DIV or negedge RESETn)
begin
	if (~RESETn) UD_BIT_CLR_REG[7:0] <= 8'b0;
	else if(UD_BIT_CLR_REG_EN) UD_BIT_CLR_REG[7:0] <= DATA_BUS[7:0];
end

endmodule
