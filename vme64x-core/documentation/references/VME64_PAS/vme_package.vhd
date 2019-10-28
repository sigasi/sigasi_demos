

--***************************************************************************
-----------------------------------------------------------------------------
-------------- VmePackage.vhdl ----------------------------------------------
-----------------------------------------------------------------------------
--***************************************************************************
-----------------------------------------------------------------------------

------------------------------------------
------------------------------------------
-- Date        : Wed Apr 10 15:07:29 2002
--
-- Author      : David Dominguez
--
-- Company     : CERN
--
-- Description : MTG constants and parameters
--
------------------------------------------
------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


package  vme  is

------------------------
--  START   VME INTERFACE
--
------------------------

    -- selects the interrupt number the VME module
    -- answer when VmeIackNA cycle is going on
subtype VmeAddressType is std_logic_vector(23 downto 1);
subtype VmeDataType is std_logic_vector(31 downto 0);
subtype ModuleAddrType is std_logic_vector(7 downto 0);
subtype ModuleAddrLType is std_logic_vector(23  downto 23 + ModuleAddrType'right - ModuleAddrType'left);--(23 downto 16);
subtype SlaveAddrOutType is std_logic_vector(ModuleAddrLType'right - 1  downto 1);--(15 downto 1);
subtype IntAddrOutType is std_logic_vector(SlaveAddrOutType'left downto 0);--(15 downto 0);
subtype VmeAddresModType is std_logic_vector(4 downto 0);
subtype VmeIntLevelType is std_logic_vector(2 downto 0);

constant MODULE_ADDRESS_C : ModuleAddrLType := X"C6";--(23 => '1', 22 => '1', others => '0');
constant module_am : VmeAddresModType := "11101";
constant ZEROVMEADDRESS : VmeAddressType := (others => '0');
constant ONEVMEADDRESS : VmeAddressType := (ZEROVMEADDRESS'right => '1', others => '0');
constant STDNONPRIVPROGACC : VmeAddresModType := "11101";

type VmeCellType is 
record
Address : VmeAddressType;
Data : VmeDataType;
Am : VmeAddresModType;

end record VmeCellType;

type VmeAddAmType is 
record
Address : VmeAddressType;
Am : VmeAddresModType;
end record VmeAddAmType;


type IntAddDataType is 
record
Address : integer;
Data : VmeDataType;
end record IntAddDataType;

type VmeBusOutRecord is 
record
--		clk :  std_logic;
		VmeAddrA :  VmeAddressType;																																						-- Top level entity for the GPS2TIM module
--
-- This module receive the GPS ppsclk and 1 Mhz + the Date and Time in RS232
-- and send the corresponding Timing Frame.
--
-- PN and BMT le 21 Fevrier 2002
--
-- Version 1.0

		VmeAsNA  :  std_logic;
		VmeAmA : VmeAddresModType;
		VmeDs1NA :  std_logic;
		VmeDs0NA :  std_logic;
		VmeLwordNA: std_logic;
		VmeWriteNA :  std_logic;
		VmeIackNA :  std_logic;
		IackInNA :  std_logic;
--		ModuleAddr :  std_logic_vector(4 downto 0);
--		DataFromMemValid :  std_logic;
--		DataFromMem:  VmeDataType;
--		data_writen_valid :  std_logic;
--		ResetNA :  std_logic;
--		UserIntReqN :  std_logic;
--		UserBlocks :  std_logic;    
		VmeData :  VmeDataType;      
		writeFinished : boolean;
		readFinished : boolean;
		takeControl : boolean;
      ProcessOnControl : integer;
end record VmeBusOutRecord;

type VmeBusOutRecordArray is array (natural range <>) of VmeBusOutRecord;

type VmeBusInRecord is 
record
		VmeData :  VmeDataType;      
		VmeDir :  std_logic;
		VmeBufOeN :  std_logic;
		IackOutNA:  std_logic;
		VmeAsNA  :  std_logic;

   	VmeIntReqN :  std_logic_vector(7 downto 0);

		dtack_n :  std_logic;

end record VmeBusInRecord;

--type StdLogVecArray is array (natural range <>) of Std_logic_vector;




    -- Interrupt vector to be put on data bus during
    -- the VME interrupt cycle
 
 function PullUpStdLogVec(input1, input2 : Std_logic_vector) return Std_logic_vector;
  function PullUpStdLog(input1, input2 :  Std_logic) return Std_logic ;

 function PullUpVmeBusOut(inputs : VmeBusOutRecordArray) return VmeBusOutRecord;
--function PullUpStdLog (inputs : std_logic_vector) return 
 end;



package body vme is 
 function PullUpStdLogVec(input1, input2 :  Std_logic_vector) return Std_logic_vector is
 variable vStdLogVec : Std_logic_vector(31 downto 0);
 begin
 vStdLogVec := (others => 'U');
		 for M in input2'range loop
        case input2(M) is
			when 'U' |'X' | 'W'  => if input1(M) = '0' or input1(M) = 'L' then 
			 						vStdLogVec(M) := '0';
                             end if;
 --			when 'X' => vStdLog := 'U';
			when '0' => vStdLogVec(M) := '0';
			when '1' => vStdLogVec(M) := input1(M);
			when 'Z' => vStdLogVec(M) := input1(M);
--			when 'W' => vStdLogVec(M) := 'U';
			when 'L' => vStdLogVec(M) := '0';
			when 'H' => vStdLogVec(M) := input1(M);
			when others => null;
		  end case;
		 end loop;
		return vStdLogVec(input2'range);
 end;

  function PullUpStdLog(input1, input2 :  Std_logic) return Std_logic is
 variable vStdLog : Std_logic;
 begin
 vStdLog := 'U';
        case input2 is
			when 'U' |'X' | 'W'  => if input1 = '0' or input1 = 'L' then 
			 						vStdLog := '0';
                             end if;
 --			when 'X' => vStdLog := 'U';
			when '0' => vStdLog := '0';
			when '1' => vStdLog := input1;
			when 'Z' => vStdLog := input1;
--			when 'W' => vStdLog := 'U';
			when 'L' => vStdLog := '0';
			when 'H' => vStdLog := input1;
--			when '-' => vStdLog := 'U';
			when others => null;

		  end case;
		return vStdLog;
 end;

	function PullUpVmeBusOut(inputs : VmeBusOutRecordArray) return VmeBusOutRecord is
	variable vVmeBusOut : VmeBusOutRecord;
	begin
		vVmeBusOut.VmeAddrA := (others => '1');
		
		vVmeBusOut.VmeAsNA  := '1';
		vVmeBusOut.VmeAmA := (others => '1');
		vVmeBusOut.VmeDs1NA := '1';
		vVmeBusOut.VmeDs0NA := '1';
		vVmeBusOut.VmeLwordNA:= '1';
		vVmeBusOut.VmeWriteNA := '1';
		vVmeBusOut.VmeIackNA := '1';
		vVmeBusOut.IackInNA := '1';
		vVmeBusOut.VmeData := (others => 'Z');
		vVmeBusOut.writeFinished := false;
		vVmeBusOut.readFinished := false;
		vVmeBusOut.ProcessOnControl := -1;

		for I in inputs'range loop
		if inputs(I).takeControl then
		vVmeBusOut.VmeAddrA := inputs(I).VmeAddrA;
		vVmeBusOut.VmeAsNA  := inputs(I).VmeAsNA  ;
		vVmeBusOut.VmeAmA := inputs(I).VmeAmA;
		vVmeBusOut.VmeDs1NA := inputs(I).VmeDs1NA ;
		vVmeBusOut.VmeDs0NA := inputs(I).VmeDs0NA ;
		vVmeBusOut.VmeLwordNA:= inputs(I).VmeLwordNA;
		vVmeBusOut.VmeWriteNA := inputs(I).VmeWriteNA ;
		vVmeBusOut.VmeIackNA := inputs(I).VmeIackNA ;
		vVmeBusOut.IackInNA := inputs(I).IackInNA ;
		vVmeBusOut.VmeData := inputs(I).VmeData ;
		vVmeBusOut.writeFinished := inputs(I).writeFinished;
		vVmeBusOut.readFinished := inputs(I).readFinished;
		vVmeBusOut.ProcessOnControl := I;

		end if;
		end loop;
		return vVmeBusOut;
	end;
end;




