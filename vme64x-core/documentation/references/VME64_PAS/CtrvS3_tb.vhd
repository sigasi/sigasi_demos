
-- VHDL Test Bench Created from source file topbic.vhd -- 16:24:27 02/09/2004
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.mddef.all;
use work.headers.all;
use work.vme.all;
use work.vmesim.all;
use work.IntContPackage.all;
use IEEE.math_real.uniform;
use work.ctrpcomponents.all;
use work.CountersPackage.all;

ENTITY CtrvS3_tb IS
END CtrvS3_tb;

ARCHITECTURE behavior OF CtrvS3_tb IS 

component CtrV 
    Generic(
	 	 
				VHDLVERSION : integer :=  1186393929; --defined in DatePackage
				VcxoTICKSLENGTH : integer := 26;

				AddrWidth  : integer :=24;
				BaseAddrWidth   : integer :=8;
				DataWidth       : integer :=32;
				DirSamePolarity  : std_logic :='0';
				UnalignDataWidth : integer := 8;
				InterruptEn      : std_logic :='1'
				);


    Port ( 
				RstNA : in std_logic;
				Vcxo : in std_logic;	            -- 40 MHz iVcxo Clock
				XGClk : in std_logic;				   -- Local Incorrelated Quartz Oscillator
				ExtClk1 : in std_logic;				-- External Clk 1
				ExtClk2 : in std_logic;				-- External Clk 2
				XExtStart : in  std_logic_vector(2 downto 1);
--				LemoOut : out std_logic_vector(7 downto 0);

				Gmt  : in std_logic;
--				GmtDir : out std_logic;
--				GmtOut : out std_logic;

				CalIn  : in std_logic;
				CalDir : out std_logic;
				CalOut : out std_logic;

--				XGpsMhz  : in std_logic;
--				GmtClkDir : out std_logic;
--				GmtClkOut : out std_logic;
            
				CtrvVer : in std_logic_vector(2 downto 0);

			-- HTDC
--			  OutEnable : out std_logic;
           TdchIt : out std_logic_vector(31 downto 0);
           TdcData : in std_logic_vector(31 downto 0);
			  TdcTest : in std_logic;
			  TdcError : in std_logic;

           TdcDRdy : in std_logic;
           TdctRst : out std_logic;
           TdcTck : out std_logic;
           TdcTms : out std_logic;
           TdcTdi : out std_logic;
			  TdcTdo : in std_logic;
			  TdcReset : out std_logic;
			  TdcTrigger : out std_logic;

           TdcBChReset : out std_logic;
           TdcEvReset : out std_logic;
           TdcGetData : out std_logic;

-- VME
        VmeAddrA      : in std_logic_vector(AddrWidth-1 downto 1 );
        VmeAsNA       : in std_logic;
        VmeDs1NA      : in std_logic;
        VmeDs0NA      : in std_logic;
        VmeData       : inout std_logic_vector(DataWidth-1 downto 0 );
 --       VmeDataUnAlign: inout std_logic_vector(UnalignDataWidth-1 downto 0); 
        VmeDir        : out std_logic;
--        VmeDirFloat   : out std_logic;
        VmeBufOeN     : out std_logic_vector(3 downto 0);
        VmeWriteNA    : in std_logic;
        VmeLwordNA    : in std_logic;
        VmeIackNA     : in std_logic;
        IackOutNA     : out std_logic;
        IackInNA      : in std_logic;
--        VmeIntReqN    : out std_logic_vector (7 downto 1);
        VmeIntReqN2    : out std_logic;
        VmeIntReqN3    : out std_logic;
        vmeDtackN     : out std_logic;
        ModuleAddr    : in std_logic_vector(3 downto 0 );
        VmeAmA        : in std_logic_vector(5 downto 0 );

	-- PLL Control
			-- DAC 
           DacClrN : out std_logic;  -- Clear   
           DacData : out std_logic;  -- Data
           DacClk : out std_logic;	 -- DAC Clk
           DacCsN : out std_logic;	 -- Chip Select
         -- iVcxo
           VcxoTtl : out std_logic;  -- TTL/CMOS Selection

   -- DT71V35761/781 synchronous RAM 
--			  RamAdd : out std_logic_vector(16 downto 0); 			-- Address Inputs
--			  -- Synchronous Address inputs. The address register is triggered by a combination of the
--			  -- rising edge of iVcxo and RamADSCN Low or RamADSPN Low and RamCEN Low.
--
--           RamData : inout std_logic_vector(31 downto 0);		-- Synchronous data input/output pins. Both 
--			  -- the data input path and data output path are registered and triggered by the rising edge 
--			  -- of iVcxo
--           RamDataPar : inout std_logic_vector(3 downto 0);        -- Data parity
----           RamZZ : out std_logic;										-- Sleep Mode. 
--			  -- Data Retention is garanteed in Sleep Mode
--
--           RamOEN : out std_logic;		 								-- Asynchronous output enable. When
--			  -- 	RamOEN is LOW the data output drivers are enabled on the RamData pins if the chip is also selected. 
--			  --  When RamOEN is HIGH the RamData pins are in high impedance state.
--           RamLBON : out std_logic;	 									-- Linear Burst Order
--			  -- Asynchronous burst order selection input. When  RamLBON is HIGH, the interleaved burst sequence
--			  -- is selected. When RamLBON is LOW the Linear burst sequence is selected. RamLBON is a static
--			  -- input and must not change state while the device is operating!!!
--
--           RamGWN : out std_logic; 										--Synchronous global write enable. 
--			  -- This input will write all four 9-bit data bytes when LOW on the rising edge of iVcxo. 
--			  -- RamGWN supersedes individual byte write enables.
--
--			  RamCEN : out std_logic; 										-- Synchronous chip enable. 
--			  -- RamCEN is used with RamCS0 and RamCS1N to enable the IDT71V35761/781. RamCEN also gates RamADSPN.
--
----			  RamCS0 : out std_logic; 										-- Synchronous active HIGH chip select.
--			  -- RamCS0 is used with RamCEN and RamCS1N to enable the chip.
--
----			  RamCS1N : out std_logic; 									--Synchronous active LOW chip select.
--			  -- RamCS1N is used with RamCEN and RamCS0 to enable the chip.
--
--			  RamWRN : out std_logic; 									--Synchronous byte write enable
--			  -- gates the byte write inputs BW1-BW4. If BWE is LOW at the
--			  -- rising edge of CLK then BWx inputs are passed to the next stage in the circuit. If BWE is
--			  -- HIGH then the byte write inputs are blocked and only GW can initiate a write cycle.
--
--			  RamBWN : out std_logic_vector(4 downto 1); 				-- Individual Write Enables
--			  -- Synchronous byte write enables. BW1 controls I/O0-7, I/OP1, BW2 controls I/O8-15, I/OP2, etc.
--			  -- Any active byte write causes all outputs to be disabled.
--
--			  RamADVN : out std_logic; 									-- Burst Address Advance	
--			  -- Advance Synchronous Address Advance. RamADVN is an active LOW input that is used to advance the
--			  -- internal burst counter, controlling burst access after the initial address is loaded. When the
--			  -- input is HIGH the burst counter is not incremented; that is, there is no address advance.
--
--			  RamADSPN : out std_logic; 									-- Address Status	(Processor)
--			  -- Synchronous Address Status from Processor. RamADSPN is an active LOW IDT71V35761 input that is used to
--			  -- load the address registers with new addresses. RamADSPN is gated by RamCEN.			  
--			  
--			  RamADSCN : out std_logic; 									-- Address Status (Cache Controller)
--			  -- Synchronous Address Status from Cache Controller. RamADSCN is an active LOW input that is
--			  -- used to load the address registers with new addresses.
--
--
--	        XORamClk40 : out std_logic;
----			  XIRamClk40 : in std_logic;
--



	-- Other Pins

			-- Leds
--				XOutLed : out 	std_logic_vector(4 downto 1);

				XIrqLed : out std_logic;
				XTimingLed : out std_logic;
-- 				XBUSLed : out std_logic;
--				XExtStartLED : out std_logic_vector(1 downto 0);
				XPllLockedLed : out std_logic;
            XUserIO: out std_logic_vector(64 downto 1);
				XOKLed : out std_logic;
            UIOByte: out std_logic_vector(7 downto 0);
				XEnabledLed : out std_logic;
				PwResetN : in std_logic;
				XExtClk1Led : out std_logic;
				XExtClk2Led : out std_logic;
				XMuxCtrl : out std_logic;
				
				FrontPannelOE : out std_logic;
--				Temperature : in std_logic;
				SerialId : inout std_logic;
				KHzOut : out std_logic
--				Init_b : out std_logic;
--				DIN_DO : out std_logic
			   
);
--*******		  

end component CtrV;


------------------------------------------------------
component idt71v35761s183 
port (
	A : in std_logic_vector(16 downto 0);
	D : inout std_logic_vector(31 downto 0);
	DP : inout std_logic_vector(3 downto 0);
	oe_N : in std_logic;
	ce_N : in std_logic;
	cs0 : in std_logic;
	cs1_N : in std_logic;
	lbo_N : in std_logic;
	gw_N: in std_logic; 
	bwe_N : in std_logic; 
	bw4_N : in std_logic;  
	bw3_N : in std_logic;
	bw2_N : in std_logic;
	bw1_N : in std_logic;
	adsp_N : in std_logic;
	adsc_N : in std_logic;
	adv_N : in std_logic;
	clk : in std_logic
);
end component idt71v35761s183;

-----------------------------------------------------
type MESSMEM_type is array (Natural Range <> ) of message_type;

--signal mesTable : mesTableType;
signal refFstMebIndex : integer := 0;
----------------------------------
----------------------------------

signal mesin :  message_type;
signal start :  std_logic;
signal mdo   :  std_logic;
signal done  :  std_logic;

signal frameData : std_logic_vector(15 downto 0) ; 
signal parityType : std_logic_vector(3 downto 0) := X"0";
--signal enableGmt : boolean;
-----------------------------------------------------

	SIGNAL RstNA :  std_logic;
	SIGNAL Vcxo :  std_logic;	            -- 40 MHz iVcxo Clock
	SIGNAL XGClk :  std_logic;				   -- Local Incorrelated Quartz Oscillator
	SIGNAL ExtClk1 :  std_logic;				-- External Clk 1
	SIGNAL ExtClk2 :  std_logic;				-- External Clk 2
	SIGNAL XExtStart :   std_logic_vector(2 downto 1);

	-- HTDC
	SIGNAL TdchIt :  std_logic_vector(31 downto 0);
	SIGNAL TdcData :  std_logic_vector(31 downto 0);
	SIGNAL TdcTest :  std_logic;
	SIGNAL TdcError :  std_logic;

	SIGNAL TdcDRdy :  std_logic;
	SIGNAL TdctRst :  std_logic;
	SIGNAL TdcTck :  std_logic;
	SIGNAL TdcTms :  std_logic;
	SIGNAL TdcTdi :  std_logic;
	SIGNAL TdcTdo :  std_logic;
	SIGNAL TdcReset :  std_logic;
	SIGNAL TdcTrigger :  std_logic;

	SIGNAL TdcBChReset :  std_logic;
	SIGNAL TdcEvReset :  std_logic;
	SIGNAL TdcGetData :  std_logic;

-----------------------------------------------------

	SIGNAL DacClrN :  std_logic;  -- Clear   
	SIGNAL DacData :  std_logic;  -- Data
	SIGNAL DacClk :  std_logic;	 -- DAC Clk
	SIGNAL DacCsN :  std_logic;	 -- Chip Select
         -- iVcxo
	SIGNAL VcxoTtl :  std_logic;  -- TTL/CMOS Selection

   -- DT71V35761/781 synchronous RAM 
	SIGNAL RamAdd :  std_logic_vector(16 downto 0); 			-- Address Inputs
			  -- Synchronous Address inputs. The address register is triggered by a combination of the
			  -- rising edge of iVcxo and RamADSCN Low or RamADSPN Low and RamCEN Low.

	SIGNAL RamData :  std_logic_vector(31 downto 0);		-- Synchronous data input/output pins. Both 
			  -- the data input path and data output path are registered and triggered by the rising edge 
			  -- of iVcxo
	SIGNAL RamPar :  std_logic_vector(4 downto 1);        -- Data parity
--           RamZZ : out std_logic;										-- Sleep Mode. 
			  -- Data Retention is garanteed in Sleep Mode

	SIGNAL RamOEN :  std_logic;		 								-- Asynchronous output enable. When
			  -- 	RamOEN is LOW the data output drivers are enabled on the RamData pins if the chip is also selected. 
			  --  When RamOEN is HIGH the RamData pins are in high impedance state.
	SIGNAL RamLBON :  std_logic;	 									-- Linear Burst Order
			  -- Asynchronous burst order selection input. When  RamLBON is HIGH, the interleaved burst sequence
			  -- is selected. When RamLBON is LOW the Linear burst sequence is selected. RamLBON is a static
			  -- input and must not change state while the device is operating!!!

	SIGNAL RamGWN :  std_logic; 										--Synchronous global write enable. 
			  -- This input will write all four 9-bit data bytes when LOW on the rising edge of iVcxo. 
			  -- RamGWN supersedes individual byte write enables.

	SIGNAL RamCEN :  std_logic; 										-- Synchronous chip enable. 
			  -- RamCEN is used with RamCS0 and RamCS1N to enable the IDT71V35761/781. RamCEN also gates RamADSPN.


	SIGNAL RamBWN :  std_logic_vector(4 downto 1); 				-- Individual Write Enables
			  -- Synchronous byte write enables. BW1 controls I/O0-7, I/OP1, BW2 controls I/O8-15, I/OP2, etc.
			  -- Any active byte write causes all outputs to be disabled.

	SIGNAL RamADVN :  std_logic; 									-- Burst Address Advance	
			  -- Advance Synchronous Address Advance. RamADVN is an active LOW input that is used to advance the
			  -- internal burst counter, controlling burst access after the initial address is loaded. When the
			  -- input is HIGH the burst counter is not incremented; that is, there is no address advance.

	SIGNAL RamADSPN :  std_logic; 									-- Address Status	(Processor)
			  -- Synchronous Address Status from Processor. RamADSPN is an active LOW IDT71V35761 input that is used to
			  -- load the address registers with new addresses. RamADSPN is gated by RamCEN.			  
			  
	SIGNAL  RamADSCN :  std_logic; 									-- Address Status (Cache Controller)
			  -- Synchronous Address Status from Cache Controller. RamADSCN is an active LOW input that is
			  -- used to load the address registers with new addresses.

	SIGNAL RamWRN:  std_logic;
	SIGNAL RamDataPar:  std_logic_vector(3 downto 0);

	SIGNAL XORamClk40 :  std_logic;
--			  XIRamClk40 : in std_logic;




	-- Other Pins

			-- Leds
--				XOutLed : out 	std_logic_vector(4 downto 1);
	SIGNAL XTimingLed :  std_logic;
-- 				XBUSLed : out std_logic;
--				XExtStartLED : out std_logic_vector(1 downto 0);
	SIGNAL XExtClk1Led :  std_logic;
	SIGNAL XExtClk2Led :  std_logic;
	SIGNAL XGPSMHz:  std_logic;
	SIGNAL XEnabledLed:  std_logic;
	SIGNAL XOKLed:  std_logic;
	SIGNAL XIrqLed:  std_logic;
	SIGNAL XPllLockedLed:  std_logic;
	SIGNAL PwResetN:  std_logic;
	SIGNAL XUserIO:  std_logic_vector(64 downto 1);
	SIGNAL UIOByte:  std_logic_vector(7 downto 0);
	SIGNAL XMuxCtrl :  std_logic;
	SIGNAL Gmt :  std_logic;


 ------------------------------
----------------------------------------------
----------------------------------------------
--	SIGNAL RstNA :  std_logic;
	SIGNAL Clk :  std_logic;
	SIGNAL VmeDirTri :  std_logic;
	SIGNAL VmeDtackNTri :  std_logic;
	SIGNAL Clk10Mhz :  std_logic;
	SIGNAL Spare2FO :  std_logic;
	SIGNAL XTEST :  std_logic_vector(3 downto 0);
----------------------------------
----------------------------------
-- Vme signals
----------------------------------
----------------------------------
	signal VmeAddrA :  std_logic_vector(23 downto 1 );
	signal VmeAmA :  std_logic_vector(5 downto 0 );

	signal VmeAsNA  :  std_logic;
	signal VmeDs1NA :  std_logic;
	signal VmeDs0NA  :  std_logic;
	signal VmeDataA : std_logic_vector(31 downto 0 );
	signal VmeDir :  std_logic;
--	signal sVmeBufOeN :  std_logic;
	signal VmeBufOeN :  std_logic_vector(3 downto 0);	
	signal VmeWriteNA :  std_logic;
	signal VmeLwordNA:  std_logic;
	signal VmeIackNA :  std_logic;
	signal IackOutNA:  std_logic;
	signal IackInNA :  std_logic;
	signal VmeIntReqN :  std_logic_vector(7 downto 0 );
	signal VmeIntReqN2 :  std_logic;							   -- VME interrupt request
	signal VmeIntReqN3 :  std_logic;							   -- VME interrupt request

	signal VmeDtackN :  std_logic;
	signal ModuleAddr :   std_logic_vector(3 downto 0);	

	signal vmeBusOutArray :  VmeBusOutRecordArray(2 downto 0);
	signal vmeBusOut : vmeBusOutRecord;
	signal vmeBusIn  : VmeBusInRecord;
	signal writeFinished, readFinished : boolean;
	signal TestVmeAddr : std_logic_vector(23 downto 0 );
	signal enableGmt : boolean := true;

   SIGNAL mask_register :  std_logic_vector(7 downto 0);
	signal addofset : integer range 0 to 100000;
signal onestd : std_logic := '1';
signal zerostd, clke1,rst : std_logic := '0';

BEGIN

trx : me
port map (reset => RstNA,
clk  => vcxo,
clke1  => clke1, -- Enable to have 1 MHz clock. 
 
mesin => mesin, 
--parityType => parityType, 
start => start, 
mdo => mdo, 
done => done);
 gmt <= not mdo;

 process
begin
clke1 <= '0';
--wait for 500 ns;
while true loop
wait until rising_edge(Vcxo);
clke1 <= '1';
wait until rising_edge(Vcxo);
clke1 <= '0';

wait for 1 us - 28 ns;
end loop;
end process;

process
begin

if enableGmt then 
start <= '1';
else 
start <= '0';
end if;
wait for 10 ns;
start <= '0';
wait for 125 us - 10 ns;
end process;





--************************************************************
--************************************************************
--************************************************************
process
variable vFrameData : std_logic_vector(15 downto 0);
variable vSlotNumber : integer :=0;
variable vMili : integer := 900;
variable vUnix : integer := 4;
variable u1 : integer := 3;
variable u2 : integer := 7;
variable vRand : real;
variable vMiliS : integer ;
variable vUnixStd : std_logic_vector(31 downto 0);
begin
uniform(seed1 => u1,seed2 => u2,x => vRand);
vFrameData := (others => '0');

if vSlotNumber  = 0 then
	if (vMili mod 5) /= 2 then 
	mesin(0) <= MILLISECOND_HEADER; 
	vFrameData := CONV_STD_LOGIC_VECTOR(vMiliS, 16);
	  report "milisegundo" severity note;
	else
	mesin(0) <= (others => '0');
	vFrameData := (others => '0');
	end if;
vMili := (vMili + 1) mod 10 ;
vMiliS := vMili + 990;
elsif  (vMili) = 2 then
if vSlotNumber = 1 then
 vUnixStd := CONV_STD_LOGIC_VECTOR(vUnix, vUnixStd'left + 1);
  mesin(0) <= UNIX_HEADER_LOW(31 downto 24);
  mesin(1) <= UNIX_HEADER_LOW(23 downto 16); 
  vFrameData := vUnixStd(15 downto 0);
  report "segundo enviado parte baja" severity note;
 elsif vSlotNumber = 3 then
  mesin(0) <= UNIX_TIME_START(31 downto 24);
  mesin(1) <= UNIX_TIME_START(23 downto 16); 
  vFrameData := vUnixStd(31 downto 16);
   report "segundo enviado parte alta" severity note;
  vUnix := vUnix + 1;

 elsif vSlotNumber = 4 then
  mesin(0) <= x"14";
  mesin(1) <= x"05";
 -- vFrameData := vUnixStd(31 downto 16);
   report "UNIX_TIME_START enviado" severity note;
--  vUnix := vUnix + 1;

  else 
	mesin(0) <= (others => '0');
	vFrameData := (others => '0');
 end if;
else
  mesin(0) <= (others => '0');
  mesin(1) <= (others => '0');
--frame(MILLISECOND_HEADER'right - 1 downto 0) <= CONV_STD_LOGIC_VECTOR(integer(vRand*real(integer'left)), MILLISECOND_HEADER'right);
end if;

mesin(2) <= vFrameData(15 downto 8);
mesin(3) <= vFrameData(7 downto 0);
vSlotNumber := (vSlotNumber + 1) mod 8;
wait until rising_edge(start);
end process;
--************************************************************
--************************************************************
--************************************************************


 paritytype <= "0000";
 
	uut:  CtrV 


    Port map( 
			RstNA => RstNA,
			Vcxo => Vcxo,	            -- 40 MHz iVcxo Clock
           XGClk => XGClk,				   -- Local Incorrelated Quartz Oscillator
           ExtClk1 => ExtClk1,				-- External Clk 1
           ExtClk2 => ExtClk2,				-- External Clk 2
				XExtStart => XExtStart,

	-- HTDC
           TdchIt  => TdchIt,
           TdcData  => TdcData,
			  TdcTest  => TdcTest,
			  TdcError => TdcError,

           TdcDRdy => TdcDRdy,
           TdctRst => TdctRst,
           TdcTck => TdcTck,
           TdcTms => TdcTms,
           TdcTdi => TdcTdi,
			  TdcTdo => TdcTdo,
			  TdcReset => TdcReset,
			  TdcTrigger => TdcTrigger,

           TdcBChReset => TdcBChReset,
           TdcEvReset => TdcEvReset,
           TdcGetData => TdcGetData,
-- VME
        VmeAddrA => VmeAddrA,
        VmeAsNA => VmeAsNA,
        VmeDs1NA => VmeDs1NA,
        VmeDs0NA => VmeDs0NA,
        VmeData => VmeDataA,
--        VmeDataUnAlign => open, 
        VmeDir => VmeDir,
--        VmeDirFloat   : out std_logic;
        VmeBufOeN => VmeBufOeN,
        VmeWriteNA => VmeWriteNA,
        VmeLwordNA => VmeLwordNA,
        VmeIackNA => VmeIackNA,
        IackOutNA => IackOutNA,
        IackInNA => IackInNA,
--        VmeIntReqN    : out std_logic_vector (7 downto 1);
        VmeIntReqN2 => VmeIntReqN2,
        VmeIntReqN3 => VmeIntReqN3,
        vmeDtackN => vmeDtackN,
        ModuleAddr => ModuleAddr,
        VmeAmA => VmeAmA,

	-- PLL Control
			-- DAC 
           DacClrN => DacClrN, -- Clear   
           DacData => DacData,  -- Data
           DacClk => DacClk,	 -- DAC Clk
           DacCsN => DacCsN,	 -- Chip Select
         -- iVcxo
           VcxoTtl => VcxoTtl,  -- TTL/CMOS Selection

   -- DT71V35761/781 synchronous RAM 
--			  RamAdd => RamAdd,			-- Address Inputs
--			  -- Synchronous Address inputs. The address register is triggered by a combination of the
--			  -- rising edge of iVcxo and RamADSCN Low or RamADSPN Low and RamCEN Low.
--
--           RamData => RamData,		-- Synchronous data input/output pins. Both 
--			  -- the data input path and data output path are registered and triggered by the rising edge 
--			  -- of iVcxo
----           RamPar => RamPar,        -- Data parity
----           RamZZ : out std_logic;										-- Sleep Mode. 
--			  -- Data Retention is garanteed in Sleep Mode
--
--           RamOEN => RamOEN,		 								-- Asynchronous output enable. When
--			  -- 	RamOEN is LOW the data output drivers are enabled on the RamData pins if the chip is also selected. 
--			  --  When RamOEN is HIGH the RamData pins are in high impedance state.
--           RamLBON => RamLBON, 									-- Linear Burst Order
--			  -- Asynchronous burst order selection input. When  RamLBON is HIGH, the interleaved burst sequence
--			  -- is selected. When RamLBON is LOW the Linear burst sequence is selected. RamLBON is a static
--			  -- input and must not change state while the device is operating!!!
--
--           RamGWN => RamGWN,										--Synchronous global write enable. 
--			  -- This input will write all four 9-bit data bytes when LOW on the rising edge of iVcxo. 
--			  -- RamGWN supersedes individual byte write enables.
--
--			  RamCEN => RamCEN, 										-- Synchronous chip enable. 
--			  -- RamCEN is used with RamCS0 and RamCS1N to enable the IDT71V35761/781. RamCEN also gates RamADSPN.
--
----			  RamCS0 : out std_logic; 										-- Synchronous active HIGH chip select.
--			  -- RamCS0 is used with RamCEN and RamCS1N to enable the chip.
--
----			  RamCS1N : out std_logic; 									--Synchronous active LOW chip select.
--			  -- RamCS1N is used with RamCEN and RamCS0 to enable the chip.
--
----			  RamBWEN : out std_logic; 									--Synchronous byte write enable
--			  -- gates the byte write inputs BW1-BW4. If BWE is LOW at the
--			  -- rising edge of CLK then BWx inputs are passed to the next stage in the circuit. If BWE is
--			  -- HIGH then the byte write inputs are blocked and only GW can initiate a write cycle.
--
--			  RamBWN => RamBWN, 				-- Individual Write Enables
--			  -- Synchronous byte write enables. BW1 controls I/O0-7, I/OP1, BW2 controls I/O8-15, I/OP2, etc.
--			  -- Any active byte write causes all outputs to be disabled.
--
--			  RamADVN => RamADVN,									-- Burst Address Advance	
--			  -- Advance Synchronous Address Advance. RamADVN is an active LOW input that is used to advance the
--			  -- internal burst counter, controlling burst access after the initial address is loaded. When the
--			  -- input is HIGH the burst counter is not incremented; that is, there is no address advance.
--
--			  RamADSPN => RamADSPN,									-- Address Status	(Processor)
--			  -- Synchronous Address Status from Processor. RamADSPN is an active LOW IDT71V35761 input that is used to
--			  -- load the address registers with new addresses. RamADSPN is gated by RamCEN.			  
--			  
--			  RamADSCN => RamADSCN,									-- Address Status (Cache Controller)
--			  -- Synchronous Address Status from Cache Controller. RamADSCN is an active LOW input that is
--			  -- used to load the address registers with new addresses.
--
--  --         RamWRN => RamWRN,
--  --         RamDataPar => RamDataPar,
--
--	        XORamClk40 => XORamClk40,
----			  XIRamClk40 : in std_logic;
--
--
--

	-- Other Pins

			-- Leds
--				XOutLed : out 	std_logic_vector(4 downto 1);
				XTimingLed => XTimingLed,
-- 				XBUSLed : out std_logic;
--				XExtStartLED : out std_logic_vector(1 downto 0);
				XExtClk1Led => XExtClk1Led,
				XExtClk2Led  => XExtClk2Led,
 --           XGPSMHz => XGPSMHz,
            XEnabledLed => XEnabledLed,
            XOKLed => XOKLed,
            XIrqLed => XIrqLed,
            XPllLockedLed => XPllLockedLed,
            PwResetN => PwResetN,
            XUserIO => XUserIO,
            UIOByte => UIOByte,
				XMuxCtrl => XMuxCtrl,
				Gmt => mdo,
				CalIn => '0',
				CalDir => open,
				CalOut  =>open,

--				XGpsMhz  : in std_logic;
--				GmtClkDir : out std_logic;
--				GmtClkOut : out std_logic;
            
				CtrvVer  => "000"
			   
);


RstNA <= '0', '1' after 1467 ns;
rst <= not RstNA;
--******************************************************************
   PROCESS
   BEGIN
	Vcxo <= '1';
   wait for 25000 ps /2; 
	Vcxo <= '0';
   wait for  25000 ps /2; 
   END PROCESS;
--******************************************************************
   PROCESS
   BEGIN
	XGClk <= '1';
   wait for 22353 ps /2; 
	XGClk <= '0';
   wait for  22353 ps /2; 
   END PROCESS;


 Uidt71v35761s183 :idt71v35761s183 port map(
	A => RamAdd,
	D => RamData,
	DP => RamPar,
	oe_N => RamOEN,
	ce_N => RamCEN,
	cs0 => onestd,
	cs1_N => zerostd,
	lbo_N => RamLBON,
	gw_N => RamGWN,
	bwe_N  => onestd,
	bw4_N  => RamBWN(4),  
	bw3_N => RamBWN(3),
	bw2_N  => RamBWN(2),
	bw1_N  => RamBWN(1),
	adsp_N => RamADSPN,
	adsc_N => RamADSCN,
	adv_N => RamADVN,
	clk  => XORamClk40
);


------------------------------------------------------------------------
-----------------------------------------------------------------------
-- Parte copiada del test bench del VME
------------------------------------------------------------------------
--------------------------------------------
--------------------------------------------
vmeBusOut <= PullUpVmeBusOut(vmeBusOutArray);
		VmeAddrA <= vmeBusOut.VmeAddrA;
		VmeAsNA  <= vmeBusOut.VmeAsNA ;
		VmeAmA <= "111001";--vmeBusOut.VmeAmA ;
		VmeDs1NA <= vmeBusOut.VmeDs1NA;
		VmeDs0NA   <= vmeBusOut.VmeDs0NA;
		VmeLwordNA<= vmeBusOut.VmeLwordNA;
		VmeWriteNA  <= vmeBusOut.VmeWriteNA;
		VmeIackNA  <= vmeBusOut.VmeIackNA ;
		IackInNA  <= vmeBusOut.IackInNA ;
		VmeDataA <= vmeBusOut.VmeData when vmeBusIn.VmeDir = '1' else (others => 'Z');
writeFinished <= vmeBusOut.writeFinished;
readFinished  <= vmeBusOut.readFinished;
TestVmeAddr <= VmeAddrA&'0';
--------------------------------------------
--------------------------------------------
vmeBusIn.VmeData <= VmeDataA; --VmeDataInA;      
vmeBusIn.VmeDir <= VmeDir;
vmeBusIn.VmeBufOeN <= VmeBufOeN(0)  when VmeBufOeN(0) = '0' else '1';
vmeBusIn.IackOutNA<= IackOutNA;
vmeBusIn.VmeAsNA  <= VmeAsNA ;
vmeBusIn.VmeIntReqN <= VmeIntReqN;
vmeBusIn.dtack_n <= vmeDtackN;
VmeIntReqN <= "1111"&(VmeIntReqN3)&(VmeIntReqN2)&"11";

--------------------------------------------
--------------------------------------------
ModuleAddr <= not MODULE_ADDRESS_C(MODULE_ADDRESS_C'right +3 downto MODULE_ADDRESS_C'right);

--------------------------------------------
--------------------------------------------
interrupt_p : process
begin
	wait until RstNA = '1';
		InitVME(VmeBusIn => vmeBusIn, VmeBusOut => vmeBusOutArray(2));
	wait for 10 us;

		while true loop
			TreatInterruptVme(VmeBusIn => vmeBusIn, VmeBusOut => vmeBusOutArray(2));
		end loop;
	wait;
end process;



   statusregvme : process
	variable vIntAdd : integer;
	variable vResult, vVmeCell :  VmeCellType;
	variable vData :  VmeDataType := X"0000AA00";
   variable vIntAddData : IntAddDataType;

   begin
		wait until RstNA = '1';
		InitVME(VmeBusIn => vmeBusIn, VmeBusOut => vmeBusOutArray(1));
		vData := X"00000042";
			wait for 1 us;

		wait for 10 us;
		WriteVMEC(VIntAdd => ADDTABLE(CommandP).AddL*2, VData => vData, VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));

		vData := X"00000302";
		WriteVMEC(VIntAdd => ADDTABLE(PhaseDCMP).AddL*2+4, VData => vData, VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));

--			wait for 10 us;
			vData := X"0000ffff";

		WriteVMEC(VIntAdd => ADDTABLE(InterruptEnableP).AddL*2, VData => vData, VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));

		ReadVMEC(VIntAdd => ADDTABLE(InterruptEnableP).AddL*2, VResult => vResult,
				 VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));


		ReadVMEC(VIntAdd => ADDTABLE(PhaseDCMP).AddL*2+4, VResult => vResult,
				 VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));
		vData(MODE_H_R downto MODE_L_R) := "01";
		vData(ON_ZERO_H_R downto ON_ZERO_L_R) := "01";
		vData(WIDTH_H_R downto WIDTH_L_R) := "00"&x"00008";
		WriteVMEC(VIntAdd => ADDTABLE(ConfigP1).AddL*2, VData => vData, VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));
		vData := X"00000000";
		WriteVMEC(VIntAdd => ADDTABLE(DelayP1).AddL*2, VData => vData, VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));
		wait for 10 ns;
--		f1: for I in  ADDTABLE(CtrDrvrHwTriggerP).AddL to ADDTABLE(SyncRamP).AddH loop
--		vData := conv_std_logic_vector(I, vData'length);
--		wait for 1 ns;
--		WriteVMEC(VIntAdd => (I)*2, VData => vData, VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));
--		end loop; 
--		
--		f2: for I in  ADDTABLE(CtrDrvrHwTriggerP).AddL to ADDTABLE(SyncRamP).AddH loop
--		vIntAddData.Address := I*2;
--		vIntAddData.Data := conv_std_logic_vector(I, vData'length);
--		SetAddress(VIntAddData => vIntAddData, VVmeCell =>vVmeCell);
--      wait for 1 ns;
--		ReadVME(VVmeCell => vVmeCell, VResult => vResult,
--				 VmeBusIn => VmeBusIn, VmeBusOut => vmeBusOutArray(1));
----		if vResult /= conv_std_logic_vector(I, vResult'length) then 
----		report "bad data!!!!!!!!!!!!!!!!!!! Read:"&integer'image(conv_integer(vResult.Data))&"at add"&integer'image(I);
----		end if;
--		end loop;


		wait;
end process;
		


END;
