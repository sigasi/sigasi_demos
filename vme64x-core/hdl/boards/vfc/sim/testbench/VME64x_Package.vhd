
--------------------------------------------------------------------------------------
---------------------------VME64x_Package-----------------------------------------
--------------------------------------------------------------------------------------

-- Date        : Fri Mar 03 2012
--
-- Author      : Davide Pedretti
--
-- Company     : CERN
--
-- Description : VME64x constants, records, type...



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;
use work.vme64x_pack.all;


package VME64x is

  subtype Vme64xAddressType is std_logic_vector(31 downto 1);  --  (31 downto 0)
  subtype Vme64xDataType is std_logic_vector(31 downto 0);	
  subtype Vme64xAddressModType is std_logic_vector(5 downto 0);
  
  type VME64xBusOut_Record is             -- This is an output for the VME64x master
    record
			Vme64xAsN			: std_logic;
			Vme64xDs1N			: std_logic;
			Vme64xDs0N			: std_logic;
			Vme64xLWORDN		: std_logic;
			Vme64xIACK		   : std_logic;
			Vme64xIACKIN		: std_logic;
			Vme64xWRITEN		: std_logic;
			Vme64xAM				: Vme64xAddressModType;
			Vme64xADDR			: Vme64xAddressType;
			Vme64xDATA			: Vme64xDataType;
			
			
			
    end record;
	 
	type VME64xBusIn_Record is				  -- This is an input for the VME64x master
    record
         Vme64xDtackN      : std_logic;
			Vme64xBerrN       : std_logic;
			Vme64xRetryN      : std_logic;
			Vme64xADDR			: Vme64xAddressType;
			Vme64xDATA			: Vme64xDataType;
			Vme64xLWORDN		: std_logic;
			Vme64xIACKOUT		: std_logic;
			Vme64xIRQ		: std_logic_vector(6 downto 0);
    end record; 
	 
	 
-- Types

type t_Buffer_BLT is array (0 to 66) of std_logic_vector(31 downto 0);      -- for BLT transfer
--The buffer has 65 positions, not 64; the last position is for test the error if i transfer more of 256 bytes.
type t_Buffer_MBLT is array (0 to 258) of std_logic_vector(63 downto 0);      -- for MBLT transfer
--The buffer has 258 positions, not 256; the last position is for test the error if i transfer more of 256 bytes.

type t_dataTransferType is  (D08Byte0, D08Byte1, D08Byte2, D08Byte3, D16Byte01, D16Byte23, D32);	-- for D64 use dataTransferType D32!
type t_Addressing_Type is  (A24, A24_BLT, A24_MBLT, A24_LCK, CR_CSR, A16, A16_LCK, A32, A32_BLT, A32_MBLT, A32_LCK,
      A64, A64_BLT, A64_MBLT, A64_LCK, A32_2eVME, A64_2eVME, A32_2eSST, A64_2eSST, error);	

	

-- Declare constants

 -- constant <constant_name>		: time := <time_unit> ns;
constant BA : std_logic_vector(7 downto 0) := "11110000";        
constant VME_GA		: std_logic_vector(5 downto 0) := "110111";    -- GA parity match '1' & slot number
constant ID_Master   : std_logic_vector(7 downto 0) := "00001111";   -- max 31
constant ADER0_A16_S : std_logic_vector(31 downto 0) := "0000000000000000" & BA(7 downto 3) & "000" & c_A16 &"00";
constant ADER0_A24_S : std_logic_vector(31 downto 0) := "00000000" & BA(7 downto 3) & "00000000000" & c_A24_S &"00";
constant ADER0_A24_BLT : std_logic_vector(31 downto 0) := "00000000" & BA(7 downto 3) & "00000000000" & c_A24_BLT &"00";
constant ADER0_A24_MBLT : std_logic_vector(31 downto 0) := "00000000" & BA(7 downto 3) & "00000000000" & c_A24_MBLT &"00";
constant ADER0_A32 : std_logic_vector(31 downto 0) := BA(7 downto 3) & "0000000000000000000" & c_A32 &"00";
constant ADER0_A32_BLT : std_logic_vector(31 downto 0) := BA(7 downto 3) & "0000000000000000000" & c_A32_BLT &"00";
constant ADER0_A32_MBLT : std_logic_vector(31 downto 0) := BA(7 downto 3) & "0000000000000000000" & c_A32_MBLT &"00";
constant ADER1_A64 : std_logic_vector(31 downto 0) := "000000000000000000000000" & c_A64 &"00";
constant ADER1_A64_BLT : std_logic_vector(31 downto 0) := "000000000000000000000000" & c_A64_BLT &"00";
constant ADER1_A64_MBLT : std_logic_vector(31 downto 0) := "000000000000000000000000" & c_A64_MBLT &"00";
constant ADER1_A64_b : std_logic_vector(31 downto 0) := BA(7 downto 3) & "000000000000000000000000000";
constant ADER2_A32_2eVME : std_logic_vector(31 downto 0) := BA(7 downto 3) & "00000000000000000" & x"01" &"01";
constant ADER2_A64_2eVME : std_logic_vector(31 downto 0) := "0000000000000000000000" & x"02" &"01";
constant ADER2_A32_2eSST : std_logic_vector(31 downto 0) := "0000000000000000000000" & x"11" &"01";
constant ADER2_A64_2eSST : std_logic_vector(31 downto 0) := "0000000000000000000000" & x"12" &"01";
constant ADER2_2e_b : std_logic_vector(31 downto 0) := BA(7 downto 3) & "000000000000000000000000000";
 -- CSR constants

  constant c_BAR             : std_logic_vector := x"7FFFF";
  constant c_BIT_SET_REG     : std_logic_vector := x"7FFFB";
  constant c_BIT_CLR_REG     : std_logic_vector := x"7FFF7";
  constant c_CRAM_OWNER      : std_logic_vector := x"7FFF3";
  constant c_USR_BIT_SET_REG : std_logic_vector := x"7FFEF";
  constant c_USR_BIT_CLR_REG : std_logic_vector := x"7FFEB";

  constant c_FUNC7_ADER_0 : std_logic_vector := x"7FFDF";
  constant c_FUNC7_ADER_1 : std_logic_vector := x"7FFDB";
  constant c_FUNC7_ADER_2 : std_logic_vector := x"7FFD7";
  constant c_FUNC7_ADER_3 : std_logic_vector := x"7FFD3";

  constant c_FUNC6_ADER_0 : std_logic_vector := x"7FFCF";
  constant c_FUNC6_ADER_1 : std_logic_vector := x"7FFCB";
  constant c_FUNC6_ADER_2 : std_logic_vector := x"7FFC7";
  constant c_FUNC6_ADER_3 : std_logic_vector := x"7FFC3";

  constant c_FUNC5_ADER_0 : std_logic_vector := x"7FFBF";
  constant c_FUNC5_ADER_1 : std_logic_vector := x"7FFBB";
  constant c_FUNC5_ADER_2 : std_logic_vector := x"7FFB7";
  constant c_FUNC5_ADER_3 : std_logic_vector := x"7FFB3";

  constant c_FUNC4_ADER_0 : std_logic_vector := x"7FFAF";
  constant c_FUNC4_ADER_1 : std_logic_vector := x"7FFAB";
  constant c_FUNC4_ADER_2 : std_logic_vector := x"7FFA7";
  constant c_FUNC4_ADER_3 : std_logic_vector := x"7FFA3";

  constant c_FUNC3_ADER_0 : std_logic_vector := x"7FF9F";
  constant c_FUNC3_ADER_1 : std_logic_vector := x"7FF9B";
  constant c_FUNC3_ADER_2 : std_logic_vector := x"7FF97";
  constant c_FUNC3_ADER_3 : std_logic_vector := x"7FF93";

  constant c_FUNC2_ADER_0 : std_logic_vector := x"7FF8F";
  constant c_FUNC2_ADER_1 : std_logic_vector := x"7FF8B";
  constant c_FUNC2_ADER_2 : std_logic_vector := x"7FF87";
  constant c_FUNC2_ADER_3 : std_logic_vector := x"7FF83";

  constant c_FUNC1_ADER_0 : std_logic_vector := x"7FF7F";
  constant c_FUNC1_ADER_1 : std_logic_vector := x"7FF7B";
  constant c_FUNC1_ADER_2 : std_logic_vector := x"7FF77";
  constant c_FUNC1_ADER_3 : std_logic_vector := x"7FF73";

  constant c_FUNC0_ADER_0 : std_logic_vector := x"7FF6F";
  constant c_FUNC0_ADER_1 : std_logic_vector := x"7FF6B";
  constant c_FUNC0_ADER_2 : std_logic_vector := x"7FF67";
  constant c_FUNC0_ADER_3 : std_logic_vector := x"7FF63"; 
  constant c_BYTES0    : std_logic_vector := x"7FF3b";
  constant c_MBLT_Endian : std_logic_vector := x"7Ff53";
  constant c_IRQ_Vector : std_logic_vector := x"7FF5F";
  constant c_IRQ_level : std_logic_vector := x"7FF5B";
  constant c_WB32or64 : std_logic_vector := x"7FF33";
  -- CR constant
  constant c_StartDefinedCR : std_logic_vector := x"00000";
  constant c_EndDefinedCR : std_logic_vector := x"00FFF";

end VME64x;


package body VME64x is


 
end VME64x;
