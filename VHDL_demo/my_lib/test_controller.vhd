library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_controller is
	port(
		clk      : out std_logic;
		rst      : out std_logic;
		start    : out std_logic;
		data_out : in  unsigned;
		data_in  : out unsigned
	);
end entity test_controller;

architecture RTL of test_controller is
	constant CLK_PERIOD : time := 50 ns;
	signal clk_int      : std_logic;
begin

	CLOCK_DRIVER : process is
	begin
		clk_int <= '0';
		wait for CLK_PERIOD / 2;
		clk_int <= '1';
		wait for CLK_PERIOD / 2;
	end process CLOCK_DRIVER;

	RST_CTRL : process is
	begin
		rst <= '0';
		wait for CLK_PERIOD * 2;
		rst <= '1';
		wait for CLK_PERIOD * 8;
		rst <= '0';
	end process RST_CTRL;

	START_CTRL : process is
	begin
		start <= '0';
		wait for CLK_PERIOD * 128;
		start <= '1';
		wait for CLK_PERIOD * 5;
		start <= '0';
	end process START_CTRL;

	DATA_DELAY : process(clk_int) is
	begin
		if rising_edge(clk_int) then
			data_in <= data_out;
		end if;
	end process DATA_DELAY;

	clk <= clk_int;

end architecture RTL;
