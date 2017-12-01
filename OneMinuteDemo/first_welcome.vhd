----------------------------------------------------------------------
-- Congratulations!
-- You made a great choice installing Sigasi, and now you are ready to unlock its power.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity welcome is
	port(
		clk : in std_logic;
		rst : in std_logic
	);
end entity welcome;

architecture RTL of welcome is
	constant SIZE : integer := ANSWER / 2;

	type mytype is (a, b, c);
	signal s    : mytype;
	signal data : unsigned(SIZE - 1 downto 0);
begin
	name : process(clk, rst) is
	begin
		if rst = '0' then
			s    <= a;
			data <= (others => '0');
		elsif rising_edge(clk) then
			case s is
				when a =>
					if data < 2**(SIZE - 2) then
						data <= data + 1;
					else
						s <= b;
					end if;

				when b =>
					if data > 2**(SIZE/2) then
						data <= data - 5;
					else
						s <= c;
					end if;

				when c =>
					if data > 5 then
						data <= data - 1;
					else
						s <= a;
					end if;
			end case;
		end if;
	end process name;

end architecture RTL;
