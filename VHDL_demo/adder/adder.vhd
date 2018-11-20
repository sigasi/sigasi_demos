library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
	generic(
		width : integer := 16
	);
	port(
		a, b : in  std_logic_vector(width - 1 downto 0);
		sum  : out std_logic_vector(width - 1 downto 0)
	);
end entity adder;

architecture RTL of adder is
	signal carry_in  : std_logic_vector(width - 1 downto 0) := (others => '0');
	signal carry_out : std_logic_vector(width - 1 downto 0) := (others => '0');

begin
	carry_in(width - 1 downto 1) <= carry_out(width - 2 downto 0);
	generate_adder : for i in 0 to width - 1 generate
		full_adder_inst : entity work.full_adder
			port map(
				a  => a(i),
				b  => b(i),
				ci => carry_in(i),
				co => carry_out(i),
				s  => sum(i)
			);
	end generate generate_adder;

end architecture RTL;
