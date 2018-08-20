library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

library my_lib;

entity testbench is
end entity testbench;

architecture STR of testbench is
	constant iterations : integer := MAX_COUNT - 4;
	signal data_out     : unsigned(7 downto 0);
	signal data_in      : unsigned(7 downto 0);
	signal valid        : std_logic;
	signal start        : std_logic;
	signal clk          : std_logic;
	signal rst          : std_logic;

	component test_controller
		port(
			clk      : out std_logic;
			rst      : out std_logic;
			start    : out std_logic;
			data_out : in  unsigned;
			data_in  : out unsigned
		);
	end component test_controller;

begin
	bar_inst : entity work.bar
		generic map(
			iterations => iterations
		)
		port map(
			data_out => data_out,
			data_in  => data_in,
			valid    => valid,
			start    => start,
			clk      => clk,
			rst      => rst
		);

	test_controller_inst : component test_controller
		port map(
			clk      => clk,
			rst      => rst,
			start    => start,
			data_out => data_out,
			data_in  => data_in
		);

end architecture STR;
