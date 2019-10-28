

--***************************************************************************
-----------------------------------------------------------------------------
-------------- VmeSimPackage.vhdl ----------------------------------------------
-----------------------------------------------------------------------------
--***************************************************************************
-----------------------------------------------------------------------------
------------------------------------------
------------------------------------------
-- Date        : Wed Apr 10 15:07:29 2002
--
-- Author      : Pablo Alvarez
--
-- Company     : CERN
--
-- Description : VME procedures
--
------------------------------------------
------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
 use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.vme.all;

package  vmesim  is
    function stdvec_to_str(inp: std_logic_vector) return string;


 constant INTHANDLERPOS : integer := 0;
 constant SLAVEPOS : integer := 1;

   procedure InitVME(
--				 signal clk     : in std_logic;
--				 signal ResetNA : out std_logic;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord
--				 signal VmeSlaveIn : out VmeSlaveInRecord				 
				 ); 
   procedure TreatInterruptVme(
--				 signal clk     : in std_logic;
--				 signal ResetNA : out std_logic;
--   			 variable VIntLevel : in VmeIntLevelType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord
--				 signal VmeSlaveIn : out VmeSlaveInRecord				 
				 ); 

   procedure GenerateInterruptVme(
				 signal clk     : in std_logic;
				 signal GenInterr :  out std_logic;
				 signal InterrDone : in std_logic
				 );
	function  FindInterrupt(
				 signal IrqN : in std_logic_vector) return integer;
   procedure ReadVME (
				 constant VVmeCell :  VmeCellType;
				 variable VResult :  out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
--				 signal VmeSlaveOut : in VmeSlaveOutRecord;
				 signal VmeBusOut : out VmeBusOutRecord);
--				 signal VmeSlaveIn : out VmeSlaveInRecord);

   procedure ReadVME (
				 variable VVmeAddAm : in VmeAddAmType;
				 variable VResult : out VmeCellType;
--				 signal VmeSlaveOut : in VmeSlaveOutRecord;
				 signal VmeBusIn :  in VmeBusInRecord;
--				 signal VmeSlaveIn : out VmeSlaveInRecord;
				 signal VmeBusOut : out VmeBusOutRecord); 



  procedure WriteVME (
				 variable VVmeCell : in VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord); 


procedure SetAddress(variable VIntAddData: in IntAddDataType;
							variable VVmeCell : out VmeCellType);

procedure SetAddressC(constant VIntAdd : in integer;
							variable VVmeAddAm : out VmeAddAmType);

procedure SetAddressV(variable VIntAdd : in integer;
							variable VVmeAddAm : out VmeAddAmType);


procedure ReadVMEC (
				 constant VIntAdd : in integer;
				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord);

procedure ReadVMEV (
				 variable VIntAdd : in integer;
				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord);

procedure ReadVME (
				 variable VIntAddData : in IntAddDataType;
				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord);


procedure WriteVMEC (
				 constant VIntAdd: in integer;
				 variable VData : in VmeDataType;
--				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord);

procedure WriteVMEV (
				 variable VIntAdd: in integer;
				 variable VData : in VmeDataType;
--				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord);
------------------------
--  END   VME INTERFACE
--
------------------------
end;

package body vmesim is 

    function stdvec_to_str(inp: std_logic_vector) return string is
        variable temp: string(inp'left+1 downto 1) := (others => 'X');
    begin
        for i in inp'reverse_range loop
            if (inp(i) = '1') then
                temp(i+1) := '1';
            elsif (inp(i) = '0') then
                temp(i+1) := '0';
            end if;
        end loop;
        return temp;
    end function stdvec_to_str;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

   procedure InitVME(
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord
				 ) is

begin
VmeBusOut.VmeAddrA <=  (others =>'1');
VmeBusOut.VmeAsNA <='1';
VmeBusOut.IackInNA<= '1';
VmeBusOut.VmeIackNA<= '1';
VmeBusOut.VmeWriteNA <='1';
VmeBusOut.VmeDs0NA <='1';
VmeBusOut.VmeDs1NA <='1';
VmeBusOut.VmeData<= (others =>'Z');
VmeBusOut.VmeLwordNA<='1';
VmeBusOut.VmeAmA <= (others => '1');

end;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
	function  FindInterrupt(
				 signal IrqN : in std_logic_vector) return integer is
variable vLevel : integer;
begin
vLevel := -1;
L1:for I in  IrqN'range loop
	if IrqN(I) = '0' then
		vLevel := I;
		exit L1;
	end if;
end loop;
return vLevel;
end;
---------------------------------------------------------------------------
---------------------------------------------------------------------------

   procedure TreatInterruptVme(
--				 signal clk     : in std_logic;
--				 signal ResetNA : out std_logic;
--   			 variable VIntLevel : in VmeIntLevelType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord
--				 signal VmeSlaveIn : out VmeSlaveInRecord				 
				 ) is
variable interruptLevel : integer;
begin
VmeBusOut.takeControl <= false;
if FindInterrupt(VmeBusIn.VmeIntReqN) = -1 then
wait until  FindInterrupt(VmeBusIn.VmeIntReqN) /= -1;
end if;
interruptLevel := FindInterrupt(VmeBusIn.VmeIntReqN); 

if VmeBusIn.VmeAsNA  /= '1' then 
wait until  VmeBusIn.VmeAsNA  = '1';
end if;

VmeBusOut.takeControl <= true;
VmeBusOut.IackInNA <= '1';
VmeBusOut.VmeIackNA <= '1';

wait for 20 ns;  -- cut and paste of the read code
                 --in the simulation file after an
VmeBusOut.VmeAddrA <= (others => '0');
VmeBusOut.VmeAddrA(VmeIntLevelType'left + VmeBusOut.VmeAddrA'right downto VmeBusOut.VmeAddrA'right) <= CONV_STD_LOGIC_VECTOR(interruptLevel, VmeIntLevelType'length);
VmeBusOut.VmeAmA <= STDNONPRIVPROGACC;

VmeBusOut.VmeAsNA  <='0';   -- int cycle
VmeBusOut.VmeDs0NA <='0';
VmeBusOut.VmeDs1NA<='0';
VmeBusOut.VmeLwordNA<='0';
VmeBusOut.IackInNA <= '0';
VmeBusOut.VmeIackNA <= '0';

wait until VmeBusIn.dtack_n='0';
VmeBusOut.VmeAddrA <= (others => '1');
VmeBusOut.VmeAddrA(VmeIntLevelType'left + VmeBusOut.VmeAddrA'right downto VmeBusOut.VmeAddrA'right) <= (others => '1');
VmeBusOut.VmeAmA <= (others => '1');

VmeBusOut.VmeAsNA  <='1';   -- int cycle
VmeBusOut.VmeDs0NA <='1';
VmeBusOut.VmeDs1NA<='1';
VmeBusOut.VmeLwordNA<='1';
VmeBusOut.takeControl <= false;
VmeBusOut.IackInNA <= '1';
VmeBusOut.VmeIackNA <= '1';
wait until VmeBusIn.dtack_n='1';

report "Interrupt vector: "&stdvec_to_str(VmeBusIn.VmeData)  severity Note;
end;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

   procedure GenerateInterruptVme(
				 signal clk     : in std_logic;
				 signal GenInterr :  out std_logic;
				 signal InterrDone : in std_logic
				 ) is
variable vInterrDuration : time;
begin
wait until falling_edge(clk);
GenInterr <= '0';
vInterrDuration := now;
wait until falling_edge(InterrDone);
GenInterr <= '1';
vInterrDuration := now - vInterrDuration;
report "Interrupt finished. Interrupt duration: " & Time'image(vInterrDuration) severity Note;
end;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
   procedure ReadVME (
				 constant VVmeCell :  VmeCellType;
				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
--				 signal VmeSlaveOut : in VmeSlaveOutRecord;
				 signal VmeBusOut : out VmeBusOutRecord
--				 signal VmeSlaveIn : out VmeSlaveInRecord
				 ) is
                      --<class>: signal | variable | constant
                      --<mode>: in | inout | out
--variable vVmeBusOut : VmeBusOutRecord;
variable ti : time;
variable doloop : boolean;
begin
--VmeSlaveIn.DataFromMemValid <= '0';
--VmeSlaveIn.DataFromMem<= (others => 'U');
-----------
-- start Read cycle
-----------
VmeBusOut.takeControl <= false;

if VmeBusIn.dtack_n /='1' then 
wait until VmeBusIn.dtack_n='1';
end if;
VmeBusOut.takeControl <= true;

VmeBusOut.readFinished <=false;
VmeBusOut.VmeIackNA <= '1';   -- to prevent intack if we do
wait for 20 ns;  -- cut and paste of the read code
                 --in the simulation file after an
VmeBusOut.VmeAddrA <= VVmeCell.Address;
VmeBusOut.VmeAmA <= VVmeCell.Am;

VmeBusOut.VmeAsNA  <='0';   -- int cycle
VmeBusOut.VmeDs0NA <='0';
VmeBusOut.VmeDs1NA<='0';
VmeBusOut.VmeLwordNA<='0';

--waiting_memo<= true;
ti := now;
doloop := true;

while doloop loop
wait for 25ns;
if VmeBusIn.dtack_n = '0' then
doloop := false;
end if;
if (now > (ti + 4 us)) then 
doloop := false;
end if;
end loop;

--wait until ((VmeBusIn.dtack_n = '0') or (now > (ti + 10 us)));
wait for 25 ns;
VResult.Data := VmeBusIn.VmeData;
VResult.Address := VVmeCell.Address;
assert (VVmeCell.Data = VmeBusIn.VmeData)
report "VmeData differ from expected data" severity Error;

--waiting_memo<= false;
wait for 10 ns;                                 
VmeBusOut.VmeAsNA  <='1';
VmeBusOut.takeControl <= false;
wait for 10 ns;
VmeBusOut.VmeDs0NA <='1';
VmeBusOut.VmeDs1NA <='1';
VmeBusOut.VmeLwordNA<='1';
VmeBusOut.VmeAddrA <=(others =>'1');
VmeBusOut.VmeAmA <= (others =>'1');

VmeBusOut.VmeData <=(others=>'1');       
wait for 10 ns;
VmeBusOut.readFinished <=true;
wait for 10 ns;
VmeBusOut.takeControl <= false;

VmeBusOut.readFinished <=false;
end;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
   procedure ReadVME (
				 variable VVmeAddAm : in VmeAddAmType;
				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
--				 signal VmeSlaveIn : out VmeSlaveInRecord;
				 signal VmeBusOut : out VmeBusOutRecord) is
                      --<class>: signal | variable | constant
                      --<mode>: in | inout | out
--variable vVmeBusOut : VmeBusOutRecord;
variable ti : time;
variable doloop : boolean;

begin
-----------
-- start Read cycle
-----------
--VmeSlaveIn.DataFromMemValid <= '0';
--VmeSlaveIn.DataFromMem<= (others => 'U');
VmeBusOut.takeControl <= false;

if VmeBusIn.dtack_n /='1' then 
wait until VmeBusIn.dtack_n='1';
end if;
VmeBusOut.takeControl <= true;

VmeBusOut.readFinished <=false;
VmeBusOut.VmeIackNA <= '1';   -- to prevent intack if we do
wait for 20 ns;  -- cut and paste of the read code
                 --in the simulation file after an
VmeBusOut.VmeAddrA <= VVmeAddAm.Address;
VmeBusOut.VmeAmA <= VVmeAddAm.Am;
VmeBusOut.VmeAsNA  <='0';   -- int cycle
VmeBusOut.VmeDs0NA <='0';
VmeBusOut.VmeDs1NA<='0';
VmeBusOut.VmeLwordNA<='0';
report "antes del wait unitl read_mem";
--wait  until VmeSlaveOut.ReadMem= '1';
--waiting_memo<= true;
--report "despues del wait unitl read_mem";
--VmeSlaveIn.DataFromMemValid <= '1';
--VmeSlaveIn.DataFromMem<= X"00110033";
ti := now;
doloop := true;

while doloop loop
wait for 25ns;
if VmeBusIn.dtack_n = '0' then
doloop := false;
end if;
if (now > (ti + 4 us)) then 
doloop := false;
end if;
end loop;
--waiting_memo<= false;
wait for 10 ns;
VResult.Data := VmeBusIn.VmeData;
VResult.Address := VVmeAddAm.Address; 
VResult.Am := VVmeAddAm.Am; 
                      
VmeBusOut.VmeAsNA  <='1';
VmeBusOut.takeControl <= false;

wait for 10 ns;

VmeBusOut.VmeDs0NA <='1';
VmeBusOut.VmeDs1NA <='1';
VmeBusOut.VmeLwordNA<='1';
--VmeBusOut.VmeAddrA <=(others =>'Z');
--VmeBusOut.VmeData <=(others=>'Z');       
wait for 10 ns;

VmeBusOut.readFinished <=true;
wait for 10 ns;
VmeBusOut.readFinished <=false;
end;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

   procedure WriteVME (
				 variable VVmeCell : in VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord) is
                      --<class>: signal | variable | constant
                      --<mode>: in | inout | out
--variable vVmeBusOut : VmeBusOutRecord;
variable ti : time;
variable doloop : boolean;

begin
-----------
-- start Write cycle
-----------
VmeBusOut.takeControl <= false;

if VmeBusIn.dtack_n /='1' then 
wait until VmeBusIn.dtack_n='1';
end if;
VmeBusOut.takeControl <= true;

VmeBusOut.writeFinished <=false;
VmeBusOut.VmeAsNA <='1';   --initialisation

VmeBusOut.IackInNA<= '1';

VmeBusOut.VmeWriteNA <='1';
VmeBusOut.VmeDs0NA <='1';
VmeBusOut.VmeDs1NA <='1';
VmeBusOut.VmeLwordNA<='1';
VmeBusOut.VmeIackNA <= '1';   -- to prevent intack if we do
wait for 20 ns;  -- cut and paste of the read code
                 --in the simulation file after an  
                 -- int cycle

VmeBusOut.VmeAddrA<=  VVmeCell.Address;
VmeBusOut.VmeAmA <= VVmeCell.Am;

VmeBusOut.VmeWriteNA <='0';
wait for 20 ns;   
VmeBusOut.VmeAsNA  <='0';   
VmeBusOut.VmeData <= VVmeCell.Data;
VmeBusOut.VmeDs0NA <='0';
VmeBusOut.VmeDs1NA<='0';
VmeBusOut.VmeLwordNA<='0';
ti := now;
doloop := true;
while doloop loop
wait for 25ns;
if VmeBusIn.dtack_n = '0' then
doloop := false;
end if;
if (now > (ti + 4 us)) then 
doloop := false;
end if;
end loop;

wait for 5 ns;
VmeBusOut.takeControl <= true;
VmeBusOut.VmeAsNA  <='1';
VmeBusOut.VmeWriteNA <='1';
VmeBusOut.VmeData <=(others =>'Z');
VmeBusOut.VmeAddrA<=  (others =>'1');
VmeBusOut.VmeAmA <= (others =>'1');
wait for 20 ns;
VmeBusOut.VmeDs1NA <='1';
VmeBusOut.VmeDs0NA <='1';
VmeBusOut.VmeLwordNA<='1';
wait for 10 ns;
VmeBusOut.writeFinished <=true;

wait for 10 ns;
VmeBusOut.takeControl <= false;
VmeBusOut.writeFinished <=false;
-----------
-- END Write cycle
-----------
end;


-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
procedure SetAddress(variable VIntAddData: in IntAddDataType;
							variable VVmeCell : out VmeCellType) is 
begin
	vVmeCell.Address(MODULE_ADDRESS_C'range) := MODULE_ADDRESS_C;
	vVmeCell.Address(SlaveAddrOutType'range) := CONV_STD_LOGIC_VECTOR(VIntAddData.Address,MODULE_ADDRESS_C'right - 1);
   vVmeCell.Am := STDNONPRIVPROGACC;
	vVmeCell.Data := VIntAddData.Data;
end;
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
procedure SetAddressC(constant VIntAdd : in integer;
							variable VVmeAddAm : out VmeAddAmType) is 
begin
	VVmeAddAm.Address(MODULE_ADDRESS_C'range) := MODULE_ADDRESS_C;
	VVmeAddAm.Address(SlaveAddrOutType'range) := CONV_STD_LOGIC_VECTOR(VIntAdd,MODULE_ADDRESS_C'right - 1);
	VVmeAddAm.Am  := STDNONPRIVPROGACC;
end;
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
procedure SetAddressV(variable VIntAdd : in integer;
							variable VVmeAddAm : out VmeAddAmType) is 
begin
	VVmeAddAm.Address(MODULE_ADDRESS_C'range) := MODULE_ADDRESS_C;
	VVmeAddAm.Address(SlaveAddrOutType'range) := CONV_STD_LOGIC_VECTOR(VIntAdd,MODULE_ADDRESS_C'right - 1);
	VVmeAddAm.Am  := STDNONPRIVPROGACC;
end;
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
procedure ReadVMEC (
				 constant VIntAdd : in integer;
				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord) is
variable vVmeAddAm : VmeAddAmType;
begin
SetAddressC(VIntAdd => VIntAdd, VVmeAddAm => vVmeAddAm);
ReadVME (VVmeAddAm => vVmeAddAm, VResult => VResult,
				 VmeBusIn => VmeBusIn, VmeBusOut => VmeBusOut);
end;
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
procedure ReadVMEV (
				 variable VIntAdd : in integer;
				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord) is
variable vVmeAddAm : VmeAddAmType;
begin
SetAddressV(VIntAdd => VIntAdd, VVmeAddAm => vVmeAddAm);
ReadVME (VVmeAddAm => vVmeAddAm, VResult => VResult,
				 VmeBusIn => VmeBusIn, VmeBusOut => VmeBusOut);
end;
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
procedure ReadVME (
				 variable VIntAddData : in IntAddDataType;
				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord) is
variable vVmeCell : VmeCellType;
begin
SetAddress(VIntAddData => VIntAddData, VVmeCell =>vVmeCell);
ReadVME (VVmeCell => vVmeCell, VResult => VResult,
				 VmeBusIn => VmeBusIn, VmeBusOut => VmeBusOut);
end;
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
procedure WriteVMEC (
				 constant VIntAdd: in integer;
				 variable VData : in VmeDataType;
--				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord) is 
variable vVmeCell : VmeCellType;
variable vIntAddData : IntAddDataType;
begin
vIntAddData.Address := VIntAdd;
vIntAddData.Data := VData;
SetAddress(VIntAddData => vIntAddData, VVmeCell =>vVmeCell);
WriteVME (VVmeCell => vVmeCell, VmeBusIn => VmeBusIn, VmeBusOut => VmeBusOut);
end;

procedure WriteVMEV (
				 variable VIntAdd: in integer;
				 variable VData : in VmeDataType;
--				 variable VResult : out VmeCellType;
				 signal VmeBusIn :  in VmeBusInRecord;
				 signal VmeBusOut : out VmeBusOutRecord) is 
variable vVmeCell : VmeCellType;
variable vIntAddData : IntAddDataType;
begin
vIntAddData.Address := VIntAdd;
vIntAddData.Data := VData;
SetAddress(VIntAddData => vIntAddData, VVmeCell =>vVmeCell);
WriteVME (VVmeCell => vVmeCell, VmeBusIn => VmeBusIn, VmeBusOut => VmeBusOut);
end;

end vmesim;


