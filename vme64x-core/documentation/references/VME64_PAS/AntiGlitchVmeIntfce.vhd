
----------------------------------------------------
--  
--  Unit    Name :  Vme_intfce
--  
--
-- This unit provides:
--         *A generic and basic Vme slave interface between the Vme bus and internal logic inside the FPGA
--         *A VME interrupter (ROACK type).
--
-- Supported/Not supported: 
--
--          *Vme Data (read/write) operations (extended/standard/short address mode and  32-, 16- and 8-bit data words)
--          *Vme interrupt cycles (ROACK interrupter)(IRQ level and IRQ statusID to be feed externally (ie. via a register)
--          *No difference is made between supervisory/non privilege mode (AM(2) from VME bus is not used)
--             => Address modifiers are only 5 bits.
--          *Valid AM values are generated inside the entity according to the AddressWidth parameter 
--             (see Note2 below).
--          *Unaligned data are not supported, so address positions must be even
--          *Different Direction polarity for data bus (dir='0' means read from the VME slave or dir='0'
--              means write into the VME slave) 
--
--          *VME Read-Modify-Write cycles are also supported. 
--
--          *Address only cycles are not supported.
--
-- Interface details:
--
--   VME side	:
--            *Bi-directional buffers for Data bus already infered inside this entity
--            *Every line is registered (inputs and outputs)excepts IackOutN (see Vme spec.) =>latency 
--	Internal side:
--             Outputs are registered and inputs are expected to be registered.This interface provides:
--            *ReadMem, AddrMem, DataToMem, WriteMem: 1 clock cycle asserted = 1 valid data/operation
--               to be done.
--            *IntProcessed    : inform internal logic that the requested interrupt has been processed
--               (StatusID has been written in the Vme bus)
--            *UserIntReqN     :internal logic requests an interrupt (any level) with this single line.
--               Has to be asserted low until IntProcessed is asserted by the VME interface.
--            *IrqLevelReg     : The interrupt level to be requested/acknowleged in the Vme bus
--            *IRQStatusIDReg  : StatusID to be fed into the Vme bus during interrupt cycle
--            *OpFinishedOut   : Tells the internal logic the VME operation (read/write/interrupt) has finished
--                              (VmeAsNA='1' and VmeDs0NA ='1' and VmeDs1NA='1'). Active by level
-- 	 Generics :
--            *DataWidth      : The Width of the Data words for Data transfers. Possible values are 32, 16 or 8
--            *AddressWidth   : possible values are 32, 24 or 16
--            *BaseAddrWidth  : any within the correct range (<AddressWidth).
--            *DirSamePolarity : Bidirectional buffers in the board (like ABT16245)need a direction pin and 
--               bidirectional data pins.
--               The direction pin may have the same polarity as the bidirectional buffers in Xilinx Spartan or not.
--               if direction='1' means the VME bus IS WRITING  INTO the SLAVE then SET DirSamePolarity='0'.
--               If direction='1' means the VME bus IS READING  FROM the SLAVE then SET DirSamePolarity='1'.
--
--            *InterruptEn     : Enables/Disables the interrupter functionnality of the VME interface
--                              ('1'=Enabled     '0'=Disabled).
--            
--
--
--	Note2: Address Modifier used in the module:
--
-- 		ModuleAm :std_logic_vector (4 downto 0):= "11110" is generated automaticaly in the VME interface 
--             according to the AddressWidth generic parameter.
-- 		Two moduleAm are generated: for word by word data transfer (ModuleAmNormal) or block data transfer (ModuleAmBlock).
--		Line AM(2) from VME bus is not taken into account, so:
-- 			moduleAm(4): AM (5) from VME bus
--    		moduleAm(3): AM(4) from VME
--    		moduleAm(2): AM(3) from VME
--    		moduleAm(1): AM(1) from VME
--    		moduleAm(0): AM(0) from VME
--
--  Notation : see Notation.vhd
--
--
--
--
--  Author  :     Rev 1 David Dominguez Montejos
--			  			Rev 2 Pablo Alvarez	
--  Division:     AB/CO 
--
--  Revisions:    1.0: No Block transfer in VME side.                      (October 2002)
--
--                1.1: DirSamePolarity generic,Changes in DataWidth, AddrWidth and BaseAddrWidth generics
--                     (instead of DataWidth=31 now is 32, etc. Same for AddrWidth, etc.).
--                     VmeDir and VmeDtackN are never tristated, if this feature is needed
--                     (to connect several VME interfaces to the same lines) a wrapper (VmeWrap.vhd and VmeWrapped.vhd)
--                     must be used. Block transfer are supported both reading and writing. Odd addresses may be read
--                     when using 8-bit data words (Unaligned data for 8bit-data words).
--                     New VmeDataUnAlign port added. Extended address access added. Read-Modify-Write cycles supported.
--                     Metastibility problem in signal VmeAsNA solved.     (January 2003)
--
--						2.0  Antiglitch filter. Every VME signal transition has to be stable during at least 3 clk cycles
--							  before it is validated. Block transfer and data unaligned features not implemented (October 2007). 
--                     
--
--						2.1  Watchdog added. DataFromMemValid replaced by DataReadDone, DataWriteDone (17 oct 2007)
--						2.2  Write out of mem space bug fixed 
--  For any bug or comment, please send an e-mail to pablo.alvarez.sanchez@cern.ch	
------------------------------------------------------

library ieee;
use ieee.STD_LOGIC_1164.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Vme_intfce is

 generic ( AddrWidth  : integer :=32;
	BaseAddrWidth   : integer :=8;
	DataWidth       : integer :=16;
    InterruptEn      : std_logic :='1';
	WatchDogTop 	 : integer := 80
 );

  port (
        RstN       : in std_logic;
        Clk           : in std_logic;
        VmeAddrA      : in std_logic_vector(AddrWidth-1 downto 1 );
        VmeAsNA       : in std_logic;
        VmeDs1NA      : in std_logic;
        VmeDs0NA      : in std_logic;
        VmeData       : inout std_logic_vector(DataWidth-1 downto 0 );
        VmeDir        : out std_logic;
--        VmeDirFloat   : out std_logic;
        VmeBufOeN     : out std_logic;
        VmeWriteNA    : in std_logic;
        VmeLwordNA    : in std_logic;
        VmeIackNA     : in std_logic;
        IackOutNA     : out std_logic;
        IackInNA      : in std_logic;
        VmeIntReqN    : out std_logic_vector (7 downto 1);
        vmeDtackN     : out std_logic;
        ModuleAddr    : in std_logic_vector(BaseAddrWidth-1 downto 0 );
        VmeAmA        : in std_logic_vector(4 downto 0 );

        AddrMem       : out std_logic_vector(AddrWidth-BaseAddrWidth-1 downto 0 );
        ReadMem       : out std_logic;
        WriteMem      : out std_logic;
        DataReadDone : in std_logic;
        DataWriteDone : in std_logic;

        DataFromMem   : in std_logic_vector(DataWidth-1 downto 0 );
        DataToMem     : out std_logic_vector(DataWidth-1 downto 0 );
        IntProcessed  : out std_logic;
        UserIntReqN   : in std_logic;
--       UserBlocks    : in std_logic;
	  IRQLevelReg   : in std_logic_vector (3 downto 1);
	  IRQStatusIDReg: in std_logic_vector (DataWidth-1 downto 0)

---------------------------------------- debugging
--        VmeState      : out std_logic_vector (3 downto 0)

--This signal is intended for debugging purposes and tells
-- the state of the VME interface.
----------------------------------------

				);  
end Vme_intfce;


 architecture beh of Vme_intfce is
 
type VmeContInCellType is 
record
        VmeAddr      :  std_logic_vector(AddrWidth-1 downto 1 );
        VmeAsN      :  std_logic;
        VmeDs      :  std_logic_vector(1 downto 0);
        VmeWriteN    :  std_logic;
        VmeLwordN    :  std_logic;
        VmeIackN     :  std_logic;
        IackInN      :  std_logic;
        ModuleAddr    :  std_logic_vector(BaseAddrWidth-1 downto 0 );
        VmeAm        :  std_logic_vector(4 downto 0 );
end record VmeContInCellType;

signal VMECONTAREF : VmeContInCellType; 
signal vmeContInD1, vmeContInD2, vmeContInD3 : VmeContInCellType;

signal vmeContInStable, vmeDataInStable, vmeAsInStable : std_logic;
signal vmeContInC, vmeDataInC, vmeAsInC : unsigned(3 downto 0);
constant TOPSTABLE : unsigned(3 downto 0) := to_unsigned(3,4);



IMPURE function CheckBus(vmeContIn : VmeContInCellType;
						VMECONTREF 	: VmeContInCellType;
						VmeStable : std_logic;
--						IrqReq : std_logic;
						intLevel  : std_logic_vector(3 downto 1)) return std_logic_vector is
	variable RDWR : std_logic_vector(3 downto 0);
	variable isWrite : std_logic;
	variable isRead : std_logic;
	variable isInte : std_logic;
	variable isAnInt : std_logic;
begin
	isWrite := '0';
	isRead := '0';
	isInte := '0';
	isAnInt := '0' ;
	if vmeContIn.VmeAsN = '0' then
	if vmeContIn.VmeAddr(vmeContIn.VmeAddr'left downto vmeContIn.VmeAddr'left-ModuleAddr'left) = vmeContIn.ModuleAddr then
		if vmeContIn.VmeAm = VMECONTREF.VmeAm then
			if vmeContIn.VmeDs = VMECONTREF.VmeDs then
			 if vmeContIn.VmeLwordN = VMECONTREF.VmeLwordN then
			  if vmeContIn.IackInN = '1'  then
				if vmeContIn.VmeWriteN = '1' then
					isRead := VmeStable;
				else
					isWrite := VmeStable;
				end if;
			  end if;
			 end if;
			end if;
		end if;
	end if;
	end if;
	
	
	
--			if vmeContIn.VmeDs = VMECONTREF.VmeDs then 
			  if vmeContIn.IackInN = '0'  then
				if vmeContIn.VmeAsN = '0' then
					if vmeContIn.VmeAddr(3 downto 1) = intLevel then
						isInte := VmeStable ;
					end if;
					isAnInt := VmeStable ;
				end if;
			  end if;
--			end if;
	RDWR := isAnInt&isInte&isWrite&isRead;
	return RDWR;
end CheckBus;

type states is (idle, rdCycle, putDataOnBus, wrCycle, waitWrDone, waitWrAsEnd, passIack, putIntVector);
  
signal nxst, st : states;

signal nxVmeData, vmeDataInD1, vmeDataInD2, vmeDataInD3, iVmeData     :  std_logic_vector(DataWidth-1 downto 0 );
--signal nxVmeDataUnAlign:  std_logic_vector(UnalignDataWidth-1 downto 0); 
signal nxVmeDir        :  std_logic;
--signal nxVmeDirFloat   :  std_logic;
--signal nxVmeBufOeN     :  std_logic;
signal nxIackOutNA     :  std_logic;
signal nxVmeIntReqN, convMyIntLevel    :  std_logic_vector (7 downto 1);
signal nxvmeDtackN     :  std_logic;
signal isRW : std_logic_vector(3 downto 0);
signal isRd, isInt, isWr, isAnInt: std_logic;
signal nxReadMem, nxWriteMem,  nxIntProcessed, lVmeData, iWriteMem, iVmeDir: std_logic;
--signal watchDogC : unsigned(7 downto 0);
begin

VMECONTAREF.VmeIackN   <= '1';
VMECONTAREF.IackInN    <= '1';
VMECONTAREF.VmeAsN   <= '0';
VMECONTAREF.VmeWriteN  <= '0'; 
VMECONTAREF.VmeAddr  <= (others => '0');
-----------------------------------------------------------
-----------------------------------------------------------
GD32: if DataWidth = 32 generate 
VMECONTAREF.VmeDs   <= "00"; --32 bit Data    
VMECONTAREF.VmeLwordN  <= '0';--32 bit Data 
end generate;
GD16:if DataWidth = 16 generate 
VMECONTAREF.VmeDs   <= "00"; --16 bit Data    
VMECONTAREF.VmeLwordN  <= '1';--16 bit Data 
end generate;
GD8: if DataWidth = 8 generate 
VMECONTAREF.VmeDs   <= "10"; --8 bit Data    
VMECONTAREF.VmeLwordN  <= '1';--8 bit Data 
end generate;
-----------------------------------------------------------
GA32:if AddrWidth = 32  generate 
VMECONTAREF.ModuleAddr   <=  (others => '0');
VMECONTAREF.VmeAm       <=  "00101"; --24 bit ADD
end generate;
GA24: if AddrWidth = 24  generate 
VMECONTAREF.ModuleAddr   <=  (others => '0');
VMECONTAREF.VmeAm       <=  "11101"; --24 bit ADD
end generate;
GA16:if AddrWidth = 16  generate 
VMECONTAREF.ModuleAddr   <=  (others => '0');
VMECONTAREF.VmeAm       <=  "10101"; --16 bit ADD
end generate;
-----------------------------------------------------------
-----------------------------------------------------------

isRW <= CheckBus(vmeContInD3, VMECONTAREF, vmeContInStable, IRQLevelReg);
isRd <= isRW(0);
isWr <= isRW(1);
isInt  <= isRW(2);
isAnInt  <= isRW(3);

process(clk)
begin
if rising_edge(clk) then
vmeContInD1.VmeAddr    	<= VmeAddrA;
vmeContInD1.VmeAsN      <= VmeAsNA;
vmeContInD1.VmeDs(1)      <= VmeDs1NA;
vmeContInD1.VmeDs(0)      <= VmeDs0NA;
vmeContInD1.VmeWriteN    <= VmeWriteNA;
vmeContInD1.VmeLwordN    <= VmeLwordNA;
vmeContInD1.VmeIackN     <= VmeIackNA;
vmeContInD1.IackInN      <= IackInNA;
vmeContInD1.ModuleAddr    <= ModuleAddr;
vmeContInD1.VmeAm         <= VmeAmA;
vmeContInD2 <= vmeContInD1;
vmeContInD3 <= vmeContInD2;

vmeDataInD1 <= vmeData;
vmeDataInD2 <= vmeDataInD1;

vmeDataInD3 <= vmeDataInD2;
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
	if RstN = '0' then
		vmeContInC <= to_unsigned(0, vmeContInC'length);
		vmeContInStable <= '0';

	else
		if vmeContInD3 /= vmeContInD2 then
			vmeContInC <= to_unsigned(0, vmeContInC'length);
		elsif vmeContInC < TOPSTABLE then
			vmeContInC <= vmeContInC + 1;
		elsif vmeContInC > TOPSTABLE then
			vmeContInC <= to_unsigned(0, vmeContInC'length);
		end if;
		
		if vmeContInD3 /= vmeContInD2 then
			vmeContInStable <= '0';
		elsif vmeContInC < TOPSTABLE then
			vmeContInStable <= '0';
		elsif vmeContInC = TOPSTABLE then
			vmeContInStable <= '1';
      else
			vmeContInStable <= '0';
		end if;
	end if;
end if;
end process;
---------------------------------------------------
process(clk)
begin
if rising_edge(clk) then
	if RstN = '0' then
		vmeDataInC <= to_unsigned(0, vmeDataInC'length);
		vmeDataInStable <= '0';
	else
		if vmeDataInD3 /= vmeDataInD2 then
			vmeDataInC <= to_unsigned(0, vmeDataInC'length);
		elsif vmeDataInC < TOPSTABLE then
			vmeDataInC <= vmeDataInC + 1;
		elsif vmeDataInC > TOPSTABLE then
			vmeDataInC <= to_unsigned(0, vmeDataInC'length);
		end if;
		
		if vmeDataInD3 /= vmeDataInD2 then
			vmeDataInStable <= '0';
		elsif vmeDataInC < TOPSTABLE then
			vmeDataInStable <= '0';
		elsif vmeDataInC = TOPSTABLE then
			vmeDataInStable <= '1';
      else
			vmeDataInStable <= '0';
		end if;
	end if;
end if;
end process;
---------------------------------------------------
process(clk)
begin
if rising_edge(clk) then
	if RstN = '0' then
		vmeAsInC <= to_unsigned(0, vmeAsInC'length);
		vmeAsInStable <= '0';
	else
		if vmeContInD3.VmeAsN  /= vmeContInD2.VmeAsN  then
			vmeAsInC <= to_unsigned(0, vmeAsInC'length);
		elsif vmeAsInC < TOPSTABLE then
			vmeAsInC <= vmeAsInC + 1;
		elsif vmeAsInC > TOPSTABLE then
			vmeAsInC <= to_unsigned(0, vmeAsInC'length);
		end if;
		
		if vmeContInD3.VmeAsN  /= vmeContInD2.VmeAsN  then
			vmeAsInStable <= '0';
		elsif vmeAsInC < TOPSTABLE then
			vmeAsInStable <= '0';
		elsif vmeAsInC = TOPSTABLE then
			vmeAsInStable <= '1';
      else
			vmeAsInStable <= '0';
		end if;
	end if;
end if;
end process;



process(St, vmeContInStable, isAnInt, isWr,  isRd, isInt, UserIntReqN, DataReadDone,  DataWriteDone, vmeAsInStable, vmeContInD3, vmeDataInStable)
begin
case St is
when idle   => 
					 if (isInt= '1')  and (UserIntReqN='0')   then
					  nxSt <=  putIntVector;
					 elsif (isAnInt = '1')  then
					  nxSt <=  passIack;				 					  
					  elsif (isWr  = '1') then
					  nxSt <=  wrCycle;
					 elsif (isRd  = '1')  then
					  nxSt <=  rdCycle;
 --         if (vmeAddr_in (3 downto 1)= MyIrqLevel) and (UserIntReqN='0') then
						else
					  nxSt <= idle;
					  end if;
--					end if;
when rdCycle   => 
					  if DataReadDone = '1' then
						nxSt <= putDataOnBus;
--						elsif watchDogC = to_unsigned(0,watchDogC'length) then
					   elsif vmeAsInStable = '1' and vmeContInD3.VmeAsN = '1' then
						nxSt <= idle;
						else
						nxSt <=  rdCycle;
					  end if;
when putDataOnBus   => 
					  if vmeAsInStable = '1' and vmeContInD3.VmeAsN = '1' then
						nxSt <= idle;
					  else
						nxSt <= putDataOnBus;
					  end if;
when wrCycle   => 
					  if vmeDataInStable = '1' then
					  nxSt <= waitWrDone;
					  else
					  nxSt <=  wrCycle;
					  end if;
when waitWrDone =>
						if DataWriteDone = '1' then
						nxSt <= waitWrAsEnd;
--						elsif watchDogC = to_unsigned(0,watchDogC'length) then
--						nxSt <= idle;
					   elsif vmeAsInStable = '1' and vmeContInD3.VmeAsN = '1' then
						nxSt <= idle;
						else
						nxSt <= waitWrDone;
						end if;
when waitWrAsEnd => 
					  if vmeAsInStable = '1' and vmeContInD3.VmeAsN = '1' then
						nxSt <= idle;
					  else
						nxSt <= waitWrAsEnd;
					  end if;
when putIntVector =>
					  if vmeAsInStable = '1' and vmeContInD3.VmeAsN = '1' then
						nxSt <= idle;
					  else
						nxSt <= putIntVector;
					  end if;
when passIack =>
					  if vmeContInD3.IackInN   = '1' and vmeContInD3.VmeAsN = '1' then
						nxSt <= idle;
					  else
						nxSt <= passIack;
					  end if;

when others => 
						nxSt <= idle;

end case;
end process;
--------------------------------------------------------------
process(St, nxSt, IRQStatusIDReg, DataFromMem, DataReadDone, DataWriteDone, vmeDataInStable, IRQStatusIDReg)
begin
	nxVmeData     <= (others => '0');
	nxVmeDir      <= '1';
	nxIackOutNA   <= '1';
	nxVmeIntReqN  <= (others => '1');
	nxvmeDtackN   <= '1';
	nxReadMem     <= '0';
	nxWriteMem    <='0';
--	nxDataToMem      <= '0';
	nxIntProcessed   <= '0';
--	nxOpFinishedOut   <= '0';
	lVmeData 	 <= '0';
   nxIackOutNA <= '1'; 
--	decWatchDog <= '1';

case St is
	when idle   =>

		if nxSt = rdCycle then
			nxReadMem <= '1';
		end if;
		if nxSt = putIntVector then
			 lVmeData 	 <= '1';
	 		 nxVmeData     <= IRQStatusIDReg;
			 nxIntProcessed   <= '1';
      end if;
--	decWatchDog <= '0';
	when rdCycle   => 
	 nxVmeData     <= DataFromMem;
	 nxVmeDir      <= not DataReadDone;
	 lVmeData 	 <= DataReadDone;

	when putDataOnBus   => 
	 nxVmeDir      <= '0';
	 nxVmeIntReqN  <= (others => '1');
	 nxvmeDtackN   <= '0';

	when wrCycle   => 
	 nxVmeDir      <= '1';
	 nxVmeIntReqN  <= (others => '1');
	 nxWriteMem 	<= vmeDataInStable;
	when waitWrDone => 
	 nxvmeDtackN   <= not DataWriteDone;
	when waitWrAsEnd => 
	 nxvmeDtackN   <= '0';
	when putIntVector =>
	 nxVmeData     <= IRQStatusIDReg;
	 nxVmeDir      <= '0';
	 nxvmeDtackN   <= '0';
--	decWatchDog <= '0';
   when passIack =>
    nxIackOutNA <= '0'; 
--	decWatchDog <= '0';
	when others => 

end case;
end process;
--------------------------------------------------------------
process(Clk)
begin
	if rising_edge(Clk) then
		if (RstN = '0') then --or  (watchDogC = to_unsigned(0,watchDogC'length)) then
		st<= idle;
		else
		st <= nxSt;
		end if;
	end if;
end process;
--------------------------------------------------------------
process(Clk)
begin
if rising_edge(Clk) then
if RstN = '0' then
	iVmeDir      <= '0';
	IackOutNA   <= '1';
	VmeIntReqN  <= (others => '1');
	vmeDtackN   <= '1';
	ReadMem     <= '0';
	iWriteMem    <='0';
	IntProcessed   <= '0';
--	watchDogC <= to_unsigned(WatchDogTop, watchDogC'length);
--	arbiterLock <= '0';
else 
	iVmeDir      <= nxVmeDir;
	IackOutNA   <= nxIackOutNA;
	VmeIntReqN  <= nxVmeIntReqN;
	vmeDtackN   <= nxvmeDtackN;
	ReadMem     <= nxReadMem;
	iWriteMem    <=nxWriteMem;
	IntProcessed   <= nxIntProcessed;
	 if nxIntProcessed = '1' then
	    VmeIntReqN <= (others =>'1');
    elsif UserIntReqN ='0' and InterruptEn='1' then 
	    VmeIntReqN <= convMyIntLevel;
	 end if;  
--	 if decWatchDog = '1' then
--		 watchDogC <= watchDogC - 1;
--	 else 
--		 watchDogC <= to_unsigned(WatchDogTop, watchDogC'length);
--	 end if;
--	if DataFromMemValid = '1' then
--		arbiterLock <= '0';
--	elsif iWriteMem = '1' then
--		arbiterLock <= '1';
--	end if;
end if;
	if nxWriteMem = '1' then
		DataToMem <= vmeDataInD3;
	end if;
	if nxWriteMem = '1' or nxReadMem = '1' then
		AddrMem <= vmeContInD2.VmeAddr(AddrMem'left downto 1)&'0';
	end if;
	if lVmeData = '1' then
	 iVmeData <= nxVmeData;
   end if;
end if;	 
  --  IntProcessed <= resetInt;
end process;
WriteMem <= iWriteMem;
VmeDir <= iVmeDir;
--------------------------------------------------------------
process(IRQLevelReg)
begin
    case IRQLevelReg is
		when "001" => convMyIntLevel <= "1111110";
		when "010" => convMyIntLevel <= "1111101";
		when "011" => convMyIntLevel <= "1111011";
		when "100" => convMyIntLevel <= "1110111";
		when "101" => convMyIntLevel <= "1101111";
		when "110" => convMyIntLevel <= "1011111";
		when "111" => convMyIntLevel <= "0111111";
		when others => convMyIntLevel <="1111111";
    end case;
end process;

VmeData <= iVmeData when iVmeDir = '0' else (others => 'Z');
--------------------------------------------------------------
VmeBufOeN <=  '0';


 end beh;

