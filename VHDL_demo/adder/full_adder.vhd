library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
	port(
		a, b, ci : in  std_logic;
		co, s    : out std_logic
	);
end entity full_adder;

architecture RTL of full_adder is
	signal sig_s  : std_logic;
	signal sig_c  : std_logic;
	signal sig_c2 : std_logic;
begin
	half_adder_a : entity work.half_adder
		port map(
			a => a,
			b => b,
			s => sig_s,
			c => sig_c
		);

	half_adder_b : entity work.half_adder
		port map(
			a => ci,
			b => sig_s,
			s => s,
			c => sig_c2
		);

	co <= sig_c or sig_c2;

end architecture RTL;
