
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
--          *Vme Block transfer is supported for 32-,16- and 8-bit data words and 32-, 24- bit addresses. A maximum
--             of 256 data bytes are allowed in a blk transfer (see VME spec).
--          *Vme interrupt cycles (ROACK interrupter)(IRQ level and IRQ statusID to be feed externally (ie. via a register)
--          *No difference is made between supervisory/non privilege mode (AM(2) from VME bus is not used)
--             => Address modifiers are only 5 bits.
--          *Valid AM values are generated inside the entity according to the AddressWidth parameter 
--             (see Note2 below).
--          *Unaligned data are not supported, so address positions must be even, except when using 8-bit
--             data words. In that case odd memory positions are processed both in normal and block transfers.
--            
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
--            *VmeDataUnAlign : this port is provided to support Unaligned data (only for 8-bits data words)
--
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
--            *UserBlocks      : internal logic may be interested in preventing the device from doing any
--               Read/write transaction. Active high.
--            *OpFinishedOut   : Tells the internal logic the VME operation (read/write/interrupt) has finished
--                              (VmeAsNA='1' and VmeDs0NA ='1' and VmeDs1NA='1'). Active by level
-- 	 Generics :
--            *DataWidth      : The Width of the Data words for Data transfers. Possible values are 32, 16 or 8
--            *UnalignDataWidth: When doing 8-bits data transfers the VME spec. states that byte0 
--                              (memory address 0) will be put in the lines Data8 to Data15, wereas byte1
--                              (memory address 1) will be put in the lines Data0 to Data7. Therefore, even
--                              if you are using 8-bits data words, the minimum size of the bus to be used is
--                              16 bits. Set this parameter to 8 if you use 8-bits data words and you need
--                              the DataBus to be 16-bits wide. Only valid for 8-bits data words.
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
--  Author  :     David Dominguez Montejos
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
--
--  For any bug or comment, please send an e-mail to David.Dominguez@cern.ch	
------------------------------------------------------

library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_ARITH.all;
use ieee.STD_LOGIC_UNSIGNED.all;


entity Vme_intfce is

 generic ( AddrWidth  : integer :=16;
	BaseAddrWidth   : integer :=8;
	DataWidth       : integer :=8;
    DirSamePolarity  : std_logic :='0';
    UnalignDataWidth : integer := 8;
    InterruptEn      : std_logic :='1'
 );

  port (
        RstN       : in std_logic;
        Clk           : in std_logic;
        VmeAddrA      : in std_logic_vector(AddrWidth-1 downto 1 );
        VmeAsNA       : in std_logic;
        VmeDs1NA      : in std_logic;
        VmeDs0NA      : in std_logic;
        VmeData       : inout std_logic_vector(DataWidth-1 downto 0 );
        VmeDataUnAlign: inout std_logic_vector(UnalignDataWidth-1 downto 0); 
        VmeDir        : out std_logic;
        VmeDirFloat   : out std_logic;
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
        DataFromMemValid : in std_logic;
        DataFromMem   : in std_logic_vector(DataWidth-1 downto 0 );
        DataToMem     : out std_logic_vector(DataWidth-1 downto 0 );
        IntProcessed  : out std_logic;
        UserIntReqN   : in std_logic;
        UserBlocks    : in std_logic;
        OpFinishedOut : out std_logic;
	  IRQLevelReg   : in std_logic_vector (3 downto 1);
	  IRQStatusIDReg: in std_logic_vector (DataWidth-1 downto 0);

---------------------------------------- debugging
        VmeState      : out std_logic_vector (3 downto 0)

--This signal is intended for debugging purposes and tells
-- the state of the VME interface.
----------------------------------------

				);  
end Vme_intfce;



 architecture Vme_intfce of Vme_intfce is
 
  signal ds0N_in1  :std_logic;
  signal ds1N_in1 :std_logic;
  signal VmeAddr_in1 : std_logic_vector(AddrWidth -1 downto 1 );
  signal am_in1 : std_logic_vector(4 downto 0 ); 
  signal iackN_in1  :std_logic;
  signal iackInN_in1  :std_logic;
  signal asN_in1  :std_logic;
  signal writeN_in1  :std_logic;
  signal lwordN_in1  :std_logic;
--  signal vmeDataIn1:std_logic_vector(DataWidth-1 downto 0 );

  signal vmeDataIn1               :std_logic_vector(DataWidth-1 downto 0 );
  signal vmeDataOut               :std_logic_vector(DataWidth-1 downto 0 );
  signal vmeDataUnAlignIn         :std_logic_vector(UnAlignDataWidth-1 downto 0 );
  signal vmeDir_in                :std_logic;
  signal vmeDirN_in               :std_logic;
  signal odd                      : std_logic;                    
 -- says if the address is even or odd

  signal moduleSelected           : std_logic;
  signal moduleAmBlock            : std_logic_vector (4 downto 0);
  signal moduleAmNormal           : std_logic_vector (4 downto 0);
  signal intForMe                 : std_logic;             
  signal daisy                    : std_logic;                     
-- the token has arrived in the iackInN daisychain

  signal writeN_in                : std_logic;
  signal lwordN_in                : std_logic;
  signal VmeAddr_in               : std_logic_vector(AddrWidth -1 downto 1 );
  signal dataFromMem_in           : std_logic_vector (DataWidth-1 downto 0);
  signal asN_in                   : std_logic;
  signal ds0N_in                  : std_logic;
  signal ds1N_in                  : std_logic;
  signal am_in                    : std_logic_vector(4 downto 0 );  --  AM2 is not used

  signal readGo                   : std_logic;		
--The read cycle starts

  signal writeGo                  : std_logic;		
--The write cycle starts
 
  signal iackN_in                 : std_logic;
  signal IackInN_in               : std_logic;
  signal addr_in                  : std_logic_vector((AddrWidth-BaseAddrWidth -1) downto 0 );

  signal intGo                    : std_logic;		 
 --the Interrupt cycle starts (VmeIackN has been activated)

  signal opFinished               : std_logic;       
--activates when a cycle is finished (asN_in,ds0N_in...='1')
  signal goBlk                    : std_logic;

  signal blkOp                    : std_logic;       
--Address Modifier says it is a block operation

  signal blkAddrInc               : std_logic_vector (2 downto 0);   
--depending on the data size, address may be incremented by 1,2 or 4

  signal nextBlkData              : std_logic;                        
--allow incrementing the address and fetch/store the next data

  signal blkMax                   : std_logic_vector (7  downto 0);   
-- VME spec does not allow BLK transf >256 Bytes or 128 words or 64 Dwords

  signal blkCounter               : std_logic_vector (7  downto 0);  
 --Number of data words in the blk transfer

  signal dsNVectorOld,dsNVectorNew :std_logic_vector (1 downto 0);    
--In blk transfer and Data=8 bits, DsN0 and DsN1 MUST alternate.

  signal startOp, startInt        : std_logic;    
--check data Width before a Read/write or Int cycle starts 

  signal startRWM                 : std_logic;
--check the CPU has started the second part of the Read-Mod_write cycle 

  signal readModifWrite           : std_logic;
-- it activates when a "Read-Modify-Write cycle is detected

  signal myIrqLevel               : std_logic_vector (3 downto 1);
  signal statusID                 : std_logic_vector (DataWidth-1 downto 0);
  signal convMyIntLevel           : std_logic_vector (7 downto 1);
  signal strobeSignals1, strobeSignals2 : std_logic_vector(30 downto 0);
  signal strobeSignalsStable, dataSignalsStable: std_logic;
  type states is (idle, IntCycle, Read, WaitRd, DtackNRead, DtackNInt, BlkWr, blkRd, DaisyArrived, DataOnVme,
      DataWritten, WaitWr, NextRd, NextWr,RdModWr);
  
signal current, nexts : states;

begin


 -- Assignments

  OpFinishedOut <=opFinished;

DirPolarity0:  if DirSamePolarity='0' generate        
                 VmeDir <= vmeDirN_in;
end generate DirPolarity0;

DirPolarity1:  if DirSamePolarity /='0' generate
                 VmeDir <= vmeDir_in;
end generate DirPolarity1;


UnalignedDataLines: if (UnalignDataWidth=8 and DataWidth=8)generate

  VmeDataUnAlign <= vmeDataOut when vmeDir_in='1' else (others =>'Z');
  vmeDataUnAlignIn <=VmeDataUnAlign;

end generate UnalignedDataLines;

IackOutgen0: if (InterruptEn='1') generate
    IackOutNA <= VmeAsNA when (intForMe='0' and daisy='1') else '1';

  --Do not use asN_in: maximum time required to deassert iack_out
  --after asN goes up is 40ns
end generate IackOutgen0;

IackOutgen1: if (InterruptEn='0') generate
   IackOutNA <= IackInNA;   --Avoid any logic implementation for interrupts
end generate IackOutgen1;   --if they are not used


  VmeData <=vmeDataOut when vmeDir_in='1' else(others =>'Z');
--  vmeDataInA <=VmeData;
  VmeBufOeN <='0';
  myIrqlevel <=IRQLevelReg;
  statusID  <=IRQStatusIDReg;



 
  AddrMem <=addr_in;
  opfinished <='1' when (ds0N_in='1' and ds1N_in='1' and asN_in='1') else '0';
  goBlk <= '1' when (ds0N_in ='1' and ds1N_in ='1' and asN_in='0' and blkOp ='1') else '0';
  readModifWrite <= '1' when (ds0N_in ='1' and ds1N_in ='1' and asN_in='0' and blkOp ='0'
     and current /= idle) else '0';

----------------------------
-- Start of generics section
----------------------------


moduleA1: if AddrWidth= 32 generate
--Bit AM(2) to choose between superv/non privilege is not
-- taken into account. Extended access
			ModuleAmNormal <= "00101";  
			ModuleAmBlock  <= "00111";			
end generate moduleA1;	

moduleA2: if AddrWidth= 24 generate
 --Bit AM(2) to choose between superv/non privilege is not
-- taken into account. Standard access
			ModuleAmNormal <= "11101"; 
			ModuleAmBlock  <= "11111";			
end generate moduleA2;	
			
moduleA3: if AddrWidth= 16 generate
-- Short access
 --In short mode there is no block transfert. Using a
 -- User defined range Am the block transfert is unavailable.
			ModuleAmNormal <="10101";			
			ModuleAmBlock <= "01000" ; 
end generate moduleA3;

moduleA4:if (AddrWidth /=32 and AddrWidth /=24 and AddrWidth /=16) generate
			ModuleAmNormal <="01000";  --User defined range for Address Modifiers 
			ModuleAmBlock  <="01000";		--No use in this interface
end generate moduleA4;


dataL1: if DataWidth= 32 generate

      startOp <='1' when (ds0N_in='0' and ds1N_in='0' and asN_in='0' 
  	and lwordN_in='0' and current= idle and iackN_in='1') else '0';
      odd <='0';
      startRWM <='1' when (ds0N_in='0' and ds1N_in='0' and asN_in='0' 
  	and lwordN_in='0' and writeN_in='0') else '0';

      nextBlkData <='1' when (asN_in ='0' and ds0N_in='0' and ds1N_in='0') else '0';
      blkAddrInc <="100";
      blkMax <= X"3F" ;    --255 bytes/4= 63 longWords  


-- When activating interrupts some DSC's may only activate ds0N regardless
-- of the real DataWidth 
--	startInt <='1' when (ds0N_in='0' and ds1N_in='0' and asN_in='0' 
--  	and lwordN_in='0' and current= idle and iackN_in='0') else '0';

      startInt <='1' when (ds0N_in='0' and asN_in='0'  and current= idle
      and iackN_in='0') else '0'; 

end generate dataL1;


dataL2: if DataWidth= 16 generate

      startOp <='1' when (ds0N_in='0' and ds1N_in='0' and asN_in='0' 
      and lwordN_in='1' and current= idle and iackN_in='1') else '0';
      odd <='0';
      startRWM <='1' when (ds0N_in='0' and ds1N_in='0' and asN_in='0' 
  	and lwordN_in='1' and writeN_in='0') else '0';

      nextBlkData <='1' when (asN_in ='0' and ds0N_in='0' and ds1N_in='0') else '0';
      blkAddrInc <="010";
      blkMax <= X"7F";    --255 bytes/2= 127 Words  

-- When activating interrupts some DSC's may only activate ds0N regardless
-- of the real DataWidth 
--    startInt <='1' when (ds0N_in='0' and ds1N_in='0' and asN_in='0' 
--    and current= idle and iackN_in='0') else '0';

      startInt <='1' when (ds0N_in='0' and asN_in='0' 
      and current= idle and iackN_in='0') else '0';

end generate dataL2;

dataL3: if DataWidth=8  generate
				
      startOp <='1' when (((ds0N_in='0' and ds1N_in='1')or (ds1N_in='0' and ds0N_in='1')) and asN_in='0' 
      and lwordN_in='1' and current= idle and iackN_in='1') else '0';
      odd <= '1' when (ds0N_in='0' and ds1N_in ='1' and asN_in ='0'
      and lwordN_in ='1' and iackN_in ='1') else '0';
      startRWM <='1' when (((ds0N_in='0' and ds1N_in='1')or (ds1N_in='0' and ds0N_in='1')) and asN_in='0' 
      and lwordN_in='1'and writeN_in='0') else '0';

      nextBlkData <='1' when ((ds0N_in='0' or ds1N_in='0') and asN_in ='0' 
         and (dsNVectorNew = not(dsNVectorOld))) else '0';
      blkAddrInc <= "001";
      blkMax <= X"FF" ;    --255 bytes

      startInt <='1' when (ds0N_in='0' and asN_in='0' 
      and current= idle and iackN_in='0') else '0';

end generate dataL3;

datal4: if (DataWidth /=32 and DataWidth /=16 and DataWidth /=8) generate
	 startOp <='0';
	 startInt <='0';
       NextBlkData <='0';
       odd <='0';
       startRWM  <='0';
       blkAddrInc <= (others =>'0');
       blkMax <= (others =>'0');
end generate dataL4;

----------------------------
-- End of generics section
----------------------------



	--IRQ level to generate in the VME BUS

process (RstN, MyIrqLevel)
begin
    convMyIntlevel <= (others =>'1');

  if RstN ='0' then
    convMyIntlevel <= (others =>'1');
  else
    case MyIrqLevel is
	when "001" => convMyIntLevel <= "1111110";
	when "010" => convMyIntLevel <= "1111101";
	when "011" => convMyIntLevel <= "1111011";
	when "100" => convMyIntLevel <= "1110111";
	when "101" => convMyIntLevel <= "1101111";
	when "110" => convMyIntLevel <= "1011111";
	when "111" => convMyIntLevel <= "0111111";
	when others => convMyIntLevel <="1111111";
    end case;
  end if;
end process;


--Process to assigne next state to current state

process (RstN,Clk,nexts)
begin
if rising_edge(Clk) then
	if RstN='0' then
		current <=idle;
	else
		current <= nexts ;
	end if;
end if;
end process;




 -- process to change the state signal and initialize
 --internal signals

defineState: process (current,readGo,intGo,writeGo,DataFromMemValid,opFinished,
asN_in, iackInN_in,ds1N_in, ds0N_in, nextBlkData, goBlk,blkCounter,blkMax,
readModifWrite,startRWM )

begin

  case current is

	when idle =>
	  if readGo = '1' then nexts <=read;
	  elsif intGo= '1' then nexts <=intCycle;
	  elsif (writeGo = '1') then nexts <=dataWritten;
	  else nexts <=idle;
	  end if;

	when read =>
	  if DataFromMemValid= '1' then nexts <= dataOnVme;
	  else nexts <= waitRd;
	  end if;

	when dataOnVme =>
	  if opFinished = '1' then
           nexts <=idle;  
    else
           nexts <= DtackNRead;
 	  end if;

      when DtackNRead =>
	  if opFinished = '1' then
          nexts <=idle;  
        elsif goBlk= '1' then
          nexts <=blkRd;
        elsif readModifWrite ='1' then
          nexts <= RdModWr;
        else
           nexts <= DtackNRead; 
        --just wait for the DSC to set VmeASN ='1' and VmeDs0N='1'
        --and VmeDs1N='1' or enter the next block data word

 	  end if;

      when RdModWr =>
        if  startRWM ='1' then
          nexts <= DataWritten;
        elsif opfinished='1' then
          nexts <=idle;
        else
          nexts <= RdModWr;
        end if; 

	when waitRd =>
	  if opfinished ='1' then
          nexts <= idle;
	  elsif dataFromMemValid = '1' then
          nexts <=dataOnVme;
	  else
          nexts <=waitRd;
	  end if;

	when blkRd =>
	  if opFinished='1' then
          nexts <=idle;
	  elsif (nextBlkData ='1' and blkCounter < blkMax) then
          nexts <= NextRd;
        --If the maximum number of data in a block (see VME spec) has been
        --reached, the slave will not process any extra word
        --and will just wait forcing the VME Timer to generate a
        -- bus error and avoid blocking the bus indefinitely 

        else
          nexts <= blkRd;
        end if;

      when NextRd =>
        if opfinished ='1' then
          nexts <=idle;
	  elsif DataFromMemValid= '1' then
          nexts <= dataOnVme;
	  else
          nexts <= waitRd;
	  end if;

	when dataWritten =>
	  if opFinished='1' then
          nexts <=idle;
	  else
          nexts <=waitWr;
	  end if;

	when waitWr =>
	  if opFinished='1' then
           nexts <=idle;
	  elsif goBlk= '1' then
           nexts <=blkWr;
        else 
           nexts <=waitWr;
	  end if;


	when blkWr =>
	  if opFinished='1' then
           nexts <=idle;
	  elsif (nextBlkData ='1' and blkCounter < blkMax) then
           nexts <= NextWr;
      else
	       nexts <=blkWr;
	  end if;

      when NextWr =>
        nexts <=WaitWr;

	when IntCycle =>
	  if (asN_in ='1' and ds1N_in ='1' and ds0N_in='1')  then
          nexts <=idle;
              --a different device with same
              --irq level and before in the daisy
              -- chain also wanted the irq

	  elsif (iackInN_in='0' and asN_in='0') then
	    nexts <=daisyArrived;
	  else nexts <=IntCycle;
	  end if;

	when daisyArrived =>
      if (asN_in ='1' and ds1N_in ='1' and ds0N_in='1') then 
           nexts <= idle;
	  else
           nexts <= DtackNInt;
	  end if;

      when DtackNInt =>
      if (asN_in ='1' and ds1N_in ='1' and ds0N_in='1') then 
           nexts <= idle;
	  else
           nexts <= DtackNInt;
	  end if;

	when others => nexts <= idle;
   end case;


end process defineState;


 --Assigning the outputs according to the state signal

  signal strobeSignals1, strobeSignals2 : std_logic_vector(30 downto 0);
  signal strobeSignalsStable, dataSignalsStable: std_logic;
strobeSignals1 <= ds0N_in1&ds1N_in1&VmeAddr_in1&iackN_in1&iackInN_in1&asN_in1&writeN_in1&lwordN_in1;
strobeSignals2 <= ds0N_in&ds1N_in&VmeAddr_in&iackN_in&iackInN_in&asN_in&writeN_in&lwordN_in;

strobeSignalsStable <= '1' when strobeSignals1 = strobeSignals2;
dataSignalsStable <= '1' when vmeDataIn1 = vmeDataIn;


inputs: process (RstN,clk)

begin
if rising_edge(clk) then
      ds0N_in1 <= VmeDs0NA;
      ds1N_in1<=VmeDs1NA;
      VmeAddr_in1 <= VmeAddrA;
      am_in1 <= VmeAmA;
      iackN_in1 <= VmeIackNA;
      iackInN_in1 <=IackInNA;
      asN_in1 <= VmeAsNA;
      writeN_in1 <= VmeWriteNA;
      lwordN_in1 <= VmeLwordNA;
		vmeDataIn1 <= VmeData;
end if;
end process;

outputs: process (clk)

begin
if rising_edge(clk) then
 if RstN='0' then
     VmeDirFloat <='1';
     VmeIntReqN <= (others =>'1');
     moduleSelected <='0';
     readGo <= '0';
     writeGo <= '0';
     intGo <= '0';
     blkOp <='0';
     blkCounter <= (others =>'0');
     dsNVectorOld <="11";
     dsNvectorNew <="11";
     intForMe <='0';
     ds0N_in <= '1';
     ds1N_in <= '1';
     asN_in <= '1';
     addr_in <= (others  => '0');
     writeN_in <= '1';
     lwordN_in <= '1';
     am_in <=(others=>'0');
     daisy <='0';
--     vmeDataOut <=(others =>'0');
--     DataToMem <=(others =>'0');
--     dataFromMem_in <= (others =>'0');
     writeMem <='0';
     readMem <='0';
     vmeDir_in <='0';
     vmeDirN_in <='1';
     vmeDtackN <='1';
     IntProcessed <='0';
     iackn_in <='1';
     iackinn_in <='1';
     vmeaddr_in <=(others =>'0');
--     VMEstate <= (others =>'0');

  else
  

      ds0N_in <= ds0N_in1;
      ds1N_in <=ds1N_in1;
      VmeAddr_in <= VmeAddr_in1;
      am_in <= am_in1 ;
      iackN_in <= iackN_in1;
      iackInN_in <=iackInN_in1;
      asN_in <= asN_in1;
      writeN_in <= writeN_in1;
      lwordN_in <= lwordN_in1;
		vmeDataIn <= vmeDataIn1;

      if startOp='1' and moduleSelected='1' and UserBlocks='0' then
         if  writeN_in='1' then
           readGo <='1';
           writeGo <='0';
           intGo <='0';
         else
           readGo <='0';
           writeGo <='1';
           intGo <='0';
         end if;
      elsif startInt='1' and InterruptEn='1' then
        readGo <='0';
        WriteGo <='0';
        intGo <='1';
      else
        readGo <='0';
        writeGo <='0';
        intGo <='0';   
      end if;


   case current is

	when idle =>
         VmeDirFloat <='1';
         if ( VmeAddr_in(AddrWidth -1 downto (AddrWidth-BaseAddrWidth)) = ModuleAddr)
            and (am_in = ModuleAmNormal or am_in =ModuleAmBlock)
            and (asN_in ='0') then  

              moduleSelected <='1';
              if am_in = ModuleAmBlock then
                 blkOp <='1';
              else
                 blkOp <='0';
              end if;
          else
              moduleSelected <='0';
          end if;
          vmeDtackN<='1';
          blkCounter <= (others =>'0');
          ReadMem <='0';
          vmeDir_in <='0';
          vmeDirN_in <='1';
          intForMe <='0';
          IntProcessed <='0';
          WriteMem <='0';
          --DataToMem <=(others =>'0');
          daisy <='0';
          VmeDataOut <=(others =>'0');
          VMEstate <= (others =>'0');
          if UserIntReqN ='0' and InterruptEn='1' then 
            VmeIntReqN <= convMyIntLevel;
          else
            VmeIntReqN <= (others =>'1');
          end if;


	when read =>
          dsNvectorOld <= Ds1N_in & Ds0N_in;
          dsNvectorNew <= Ds1N_in & Ds0N_in;
          VmeDirFloat <='1';
          vmeDir_in <='0';
          vmeDirN_in <='1';
          addr_in <= vmeAddr_in ((AddrWidth-BaseAddrWidth-1) downto 1)& odd;
          ReadMem <= '1';
          VMEstate <= "0001";
          if UserIntReqN ='0' and InterruptEn='1' then 
            VmeIntReqN <= convMyIntLevel;
          else
            VmeIntReqN <= (others =>'1');
          end if;

	when intCycle =>
          VmeDirFloat <='1';
          if (vmeAddr_in (3 downto 1)= MyIrqLevel) and (UserIntReqN='0') then
            intForMe <='1';
          else
            intForMe <='0';
          end if;
          VMEstate <= "1011";
          if UserIntReqN ='0' and InterruptEn='1' then 
            VmeIntReqN <= convMyIntLevel;
          else
            VmeIntReqN <= (others =>'1');
          end if;

	when daisyArrived =>
           if intForMe='1' then
              VmeDirFloat <='0';
              vmeDir_in <='1';
              vmeDirN_in <='0';
              VmeDataOut <=StatusId;
              vmeDtackN <='1';
              VmeIntReqN <=(others =>'1');
              IntProcessed <='1';
           elsif UserIntReqN ='0' and InterruptEn='1' then 
              VmeIntReqN <= convMyIntLevel;
           else
              VmeIntReqN <= (others =>'1');
           end if;
           daisy <='1';
           VMEstate <= "1100";

      when DtackNInt =>
           if intForMe='1' then
              VmeDirFloat <='0';
              vmeDir_in <='1';
              vmeDirN_in <='0';
              VmeDataOut <=StatusId;
              vmeDtackN <='0'; 
              VmeIntReqN <=(others =>'1');
              IntProcessed <='1';
           else           
              if UserIntReqN ='0' and InterruptEn='1' then 
                VmeIntReqN <= convMyIntLevel;
              else
                VmeIntReqN <= (others =>'1');
              end if;            
              VmeDirFloat <='1';        
              VmeDir_in <='0';     
              vmeDirN_in <='1';     
              VmeDtackN <='1';          
           end if;
          daisy <='1';
          VMEstate <= "1101";


	when dataOnVme =>
          VmeDirFloat <='0';
          vmeDir_in <='1';
          vmeDirN_in <='0';
          VmeDataOut <=dataFromMem_in;                    
          vmeDtackN <='1';
          ReadMem <='0';
          VMEstate <= "0011";
          if UserIntReqN ='0' and InterruptEn='1' then 
            VmeIntReqN <= convMyIntLevel;
          else
            VmeIntReqN <= (others =>'1');
          end if;

      when DtackNRead =>
          VmeDirFloat <='0';
          vmeDir_in <='1';
          vmeDirN_in <='0';
          VmeDataOut <=dataFromMem_in;                
          vmeDtackN <='0';
          ReadMem <='0';
          VMEstate <= "0100";
          if UserIntReqN ='0' and InterruptEn='1' then 
            VmeIntReqN <= convMyIntLevel;
          else
            VmeIntReqN <= (others =>'1');
          end if;

      when RdModWr =>
          VmeDirFloat <= '0';
          vmeDir_in <= '0';
          vmeDirN_in <= '1';
          vmeDtackN <= '1';
          VmeState <= X"e";
          if UserIntReqN ='0' and InterruptEn='1' then 
            VmeIntReqN <= convMyIntLevel;
          else
            VmeIntReqN <= (others =>'1');
          end if;

	when waitRd =>
          ReadMem <='0';
          dataFromMem_in <=DataFromMem;
          VMEstate <= "0010";
          if UserIntReqN ='0' and InterruptEn='1' then 
            VmeIntReqN <= convMyIntLevel;
          else
            VmeIntReqN <= (others =>'1');
          end if;


	when dataWritten =>
        dsNvectorOld <= Ds1N_in & Ds0N_in;
        dsNvectorNew <= Ds1N_in & Ds0N_in;
        VmeDirFloat <='0';
        vmeDir_in <='0';
        vmeDirN_in <='1';
     	  addr_in <= vmeAddr_in ((AddrWidth-BaseAddrWidth-1) downto 1) & odd;
        if (UnalignDataWidth=8 and DataWidth=8 and odd='0')  then 
          DataToMem <= vmeDataUnAlignIn (UnAlignDataWidth-1 downto 0) ;
        else         
          DataToMem <= vmeDataIn (DataWidth-1 downto 0);
        end if;
        WriteMem <='1';
        intForMe <='0';
        vmeDtackN <='1';
        VMEstate <= "0111";
        if UserIntReqN ='0' and InterruptEn='1' then 
          VmeIntReqN <= convMyIntLevel;
        else
          VmeIntReqN <= (others =>'1');
        end if;

	when waitWr =>
        VmeDirFloat <='0';
        vmeDir_in <='0'; 
        vmeDirN_in <='1';
	  WriteMem <='0';
        VmeDtackN <='0';
        VMEstate <= "1000";
        if UserIntReqN ='0' and InterruptEn='1' then 
          VmeIntReqN <= convMyIntLevel;
        else
          VmeIntReqN <= (others =>'1');
        end if;

	when blkWr =>
        dsNvectorNew <= Ds1N_in & Ds0N_in;
        VmeDirFloat <= '0';
        vmeDir_in <='0'; 
        vmeDirN_in <='1';
        WriteMem <='0';
        VmeDtackN <='1';
        VmeState <="1001";
        if UserIntReqN ='0' and InterruptEn='1' then 
          VmeIntReqN <= convMyIntLevel;
        else
          VmeIntReqN <= (others =>'1');
        end if;

      when NextWr =>
        dsNvectorOld <=dsNvectorNew;
        VmeDirFloat <='0';
        vmeDir_in <='0';
        vmeDirN_in <='1';
        blkCounter <=blkCounter +'1';
        DataToMem <= vmeDataIn1 (DataWidth-1 downto 0);
        addr_in <= addr_in + blkAddrInc;
        WriteMem <='1';
        VmeDtackN <='1';
        VmeState <="1010";
        if UserIntReqN ='0' and InterruptEn='1' then 
          VmeIntReqN <= convMyIntLevel;
        else
          VmeIntReqN <= (others =>'1');
        end if;

	when blkRd =>
        dsNvectorNew <= Ds1N_in & Ds0N_in;
        VmeDirFloat <='1';
        vmeDir_in <='0';
        vmeDirN_in <='1';
        VmeDtackN <='1';
        ReadMem <='0';
        VmeState <= "0101";
        if UserIntReqN ='0' and InterruptEn='1' then 
          VmeIntReqN <= convMyIntLevel;
        else
          VmeIntReqN <= (others =>'1');
        end if;

      when NextRd =>
        dsNvectorOld <=dsNvectorNew;
        VmeDirFloat <='1';
        vmeDir_in <='0';
        vmeDirN_in <='1';
        addr_in <= addr_in + blkAddrInc;
        blkCounter <=blkCounter +'1';
        ReadMem <= '1';
        VMEstate <= "0110";
        if UserIntReqN ='0' and InterruptEn='1' then 
          VmeIntReqN <= convMyIntLevel;
        else
          VmeIntReqN <= (others =>'1');
        end if;
        
      when others =>
        VmeDirFloat <='1';
        moduleSelected <='0';
        vmeDtackN<='1';
        ReadMem <='0';
        vmeDir_in <='0';
        vmeDirN_in <='1';
        intForMe <='0';
        IntProcessed <='0';
        WriteMem <='0';
        --DataToMem <=(others =>'0');
        daisy <='0';
        VmeDataOut <=(others =>'0');
        VMEstate <= (others =>'0');
        VmeIntReqN <= (others =>'1');


 end case;
end if;
end if;

 end process outputs;


 end Vme_intfce;

