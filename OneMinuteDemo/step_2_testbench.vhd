library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity testbench is
	generic(half_iterations : integer := 50);
end entity testbench;

architecture STR of testbench is
	signal data_out : unsigned(7 downto 0);
	signal data_in  : unsigned(7 downto 0) := (1 => '1', others => '0');
	signal valid    : std_logic;
	signal start    : std_logic;
	signal clk      : std_logic;
	signal rst      : std_logic;

begin
	
	tb_utils_instance : entity work.tb_utils
		port map(
			clk   => clk,
			rst   => rst,
			start => start
		);

	----------------------------------------------------------------------
	-- Instantiation of the Device Under Test 
	----------------------------------------------------------------------
	dut_instance : entity work.dut(RTL)
		generic map(
			iterations => 40
		)
		port map(
			data_out => data_out,
			data_in  => data_in,
			valid    => valid,
			start    => start,
			clk      => clk,
			rst      => rst
		);
		
		assert valid = '0' or data_out = 0;

end architecture STR;
