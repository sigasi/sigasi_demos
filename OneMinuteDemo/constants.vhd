library ieee;
use ieee.std_logic_1164.all;
package constants is
	constant CLK_PERIOD : time := 20 ns;

	constant MAX_COUNT : integer := 2 ** 8 - 1;

	constant ANSWER : integer := 4 * 10 + 2;

	constant MAGIC_NUMNER : std_logic_vector(15 downto 0) := X"da01";

	-- If you got here by using the "declare as enumertion literal" quickfix: 
	-- 
	-- Great! 
	-- 
	-- Now first: you should save this file, since it was edited automatically. 
	-- 
	-- TODO "Go Back": Just like in your webbrowser, you can go back to your previous 
	-- location by pressing *ALT+LEFT* or by clicking the yellow left pointing arrow in the toolbar.

	type state_t is (idle, preparing, running, ready);

	type color_t is (red, orange, yellow, green, blue, indigo, violet);

end package constants;
