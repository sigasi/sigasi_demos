library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nor_gate is
	port(
		a, b : in  std_logic;
		c    : out std_logic
	);
end entity nor_gate;

architecture COMB of nor_gate is
	signal sig_or : std_logic;
begin
	c      <= not sig_or;
	sig_or <= (a or b);
end architecture COMB;

architecture PROC of nor_gate is
	--	signal sig_or : std_logic;
begin
	p_nor : process(a, b) is
		variable sig_or : std_logic;
	begin
		sig_or := (a or b);
		c      <= not sig_or;
	end process p_nor;

end architecture PROC;

