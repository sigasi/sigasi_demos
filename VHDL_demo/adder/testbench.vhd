library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_testbench is
end entity adder_testbench;

architecture RTL of adder_testbench is
	constant width : integer := 32;

	signal input_1 : unsigned(width - 1 downto 0) := (others => '0');
	signal input_2 : unsigned(width - 1 downto 0) := (others => '0');
	signal output  : unsigned(width - 1 downto 0);

	signal output_int : std_logic_vector(width - 1 downto 0);
	
begin
	output <= unsigned(output_int);
	
	adder : entity work.adder
		generic map(
			width => width
		)
		port map(
			a   => std_logic_vector(input_1),
			b   => std_logic_vector(input_2),
			sum => output_int
		);
		
	generate_inputs : process is
	begin
		loop
			wait for 1 ms;
			input_1 <= input_1 + 1;
			if input_1 > 20 then
				input_2 <= input_2 + 1;
				input_1 <= (others => '0');
			end if;
		end loop;
		
		
	end process generate_inputs;
	
end architecture RTL;
