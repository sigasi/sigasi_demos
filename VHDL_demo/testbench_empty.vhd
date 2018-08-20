library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

library my_lib;

entity testbench is
end entity testbench;

architecture STR of testbench is
	constant iterations : integer := MAX_COUNT - 4;
	
	-- STEP 2:
	-- type "com" then Ctrl+Space and select component test_controller

begin
	-- STEP 1:
	-- type "ent" then Ctrl+Space and select entity work.bar
	-- apply the Quick Fix to declare all missing signals from the Port Map
	
	-- STEP 3:
	-- type "com" then Ctrl+Space and select component test_controller
	-- after, press Ctr+Shift+F to format the file
end architecture STR;
