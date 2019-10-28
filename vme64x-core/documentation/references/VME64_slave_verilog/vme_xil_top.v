module vme_xil_top(CLOCK, RESETn, ADDRBUS,
VME_AM, VME_ASn, VME_R_Wn, DS0n, DS1n, LWORDn, GA, ACK_CYCLE, DATA_BUS,
DTACKn, BERRn, IRQ1n, LOC_R_Wn, LOC_CS, LOC_DS1n, LOC_DS0n, C_ROM, VME_BUF_DIR, VME_BUF_OE,
LHOLD, LHOLDA, LAD_BUS, ADSn, LW_Rn, READYn, LINTIn
 );


input			CLOCK, RESETn, VME_ASn, VME_R_Wn, DS0n, DS1n, LWORDn , ACK_CYCLE;
input			READYn, LHOLDA;
input[4:0]		GA;
input[5:0]		VME_AM;
input[7:0]		LINTIn;
input[31:0]		ADDRBUS;

inout[31:0]		DATA_BUS, LAD_BUS;

output			DTACKn, BERRn, IRQ1n, LOC_R_Wn, LOC_CS, LOC_DS1n;
output			LOC_DS0n, C_ROM, VME_BUF_DIR , VME_BUF_OE;
output			LHOLD, ADSn, LW_Rn;

wire			CLOCK, RESETn, VME_ASn, VME_R_Wn, DS0n, DS1n, LWORDn , ACK_CYCLE;
wire			DTACKn, BERRn, IRQ1n, LOC_R_Wn, LOC_CS, LOC_DS1n;
wire			LOC_DS0n, C_ROM, VME_BUF_DIR , VME_BUF_OE;
wire			LHOLD, LHOLDA, ADSn, LW_Rn, READYn;

wire[4:0]		GA;
wire[5:0]		VME_AM;
wire[7:0]		BAR, ROM_DATA, LINTIn;
wire[10:0]		CR_SPACE;
wire[31:0]		ADDRBUS, DATA_BUS, LOCAL_BUS_IN;



vme_slave vme_slave1(
.CLOCK(CLOCK), 
.RESETn(RESETn), 
.BAR(BAR[7:0]), 
.ADDRBUS(ADDRBUS),
.VME_AM(VME_AM), 
.VME_ASn(VME_ASn), 
.VME_R_Wn(VME_R_Wn), 
.DS0n(DS0n), 
.DS1n(DS1n), 
.LWORDn(LWORDn), 
.ACK_CYCLE(ACK_CYCLE), 
.ROM_DATA(ROM_DATA), 
.DATA_BUS(DATA_BUS), 
.DTACKn(DTACKn), 
.BERRn(BERRn), 
.IRQ1n(IRQ1n), 
.LOC_R_Wn(LOC_R_Wn), 
.LOC_CS(LOC_CS), 
.LOC_DS1n(LOC_DS1n), 
.LOC_DS0n(LOC_DS0n), 
.CR_SPACE(CR_SPACE[10:0]), 
.C_ROM(C_ROM), 
.VME_BUF_DIR(VME_BUF_DIR), 
.VME_BUF_OE(VME_BUF_OE),
.LOCAL_BUS_IN(LOCAL_BUS_IN)  
 );

loc_bus loc_bus1(
.CLOCK(CLOCK), 
.RESETn(RESETn), 
.ADDRBUS(ADDRBUS), 
.DATA_BUS(DATA_BUS),
.DTACKn(DTACKn), 
.VME_R_Wn(VME_R_Wn),  
.LOC_CS(LOC_CS), 
.LOC_R_Wn(VME_R_Wn), 
.LHOLD(LHOLD), 
.LHOLDA(LHOLDA), 
.LAD_BUS(LAD_BUS), 
.ADSn(ADSn), 
.LW_Rn(LW_Rn), 
.READYn(READYn),
.LOCAL_BUS_IN(LOCAL_BUS_IN)  
);

vme_rom vme_rom1 (
.addr(CR_SPACE[10:0]),
.clk(C_ROM),
.dout(ROM_DATA),
.sinit(RESETn)
);

ga_decoder ga_decoder1(
.GA(GA), 
.BAR(BAR)
);


endmodule
