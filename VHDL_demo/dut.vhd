library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dut is
	generic(
		reset_value : std_logic := '1'
	);
	port(
		data_out : out unsigned(3 downto 0);
		valid    : out std_logic;
		start    : in  std_logic;
		clk      : in  std_logic;
		rst      : in  std_logic
	);
end entity dut;

architecture RTL of dut is
	signal a : std_logic;
	signal b : integer;

begin
	process_label : process(clk, rst) is
		variable c : string;
		variable d : std_logic_vector(3 downto 0);
		variable e : string;
	begin
		if rst = reset_value then
			a     <= '0';
			valid <= '0';
		elsif rising_edge(clk) then
			a <= start;
			b <= 5;
			c := "test";
			d := "1001";
			e := "1000" & "test"; -- Sigasi Studio won't figure out this datatype.

			if a = '1' and b = 5 and c = "start" then
				c        := e;
				data_out <= unsigned(d);
			end if;
		end if;

	end process process_label;

end architecture RTL;
