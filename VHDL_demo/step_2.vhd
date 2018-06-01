library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

library my_lib;

entity testbench is
end entity testbench;

architecture STR of testbench is
	signal data_out     : unsigned(7 downto 0);
	signal data_in      : unsigned(7 downto 0);
	signal valid        : std_logic;
	signal start        : std_logic;
	signal clk          : std_logic;
	signal rst          : std_logic;
	----------------------------------------------------------------------
	-- "Hover": In the line below, hover your mouse over the word MAX_COUNT
	-- Notice how the data type and value of this constant shows up in a pop-up
	-- Go ahead and hover over other things too!
	----------------------------------------------------------------------
	constant iterations : integer := MAX_COUNT - 4;

begin
	----------------------------------------------------------------------
	-- "Open declaration": in the line below, place your cursor on
	-- the word "bar" and press "F3". This takes you to the declaration of 
	-- the entity "bar". 
	----------------------------------------------------------------------
	bar_instance : entity work.bar(RTL)
		generic map(
			datawidth  => 8,
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

	assert valid = '0' or data_out /= "00000000";

	controller_instance : entity my_lib.test_controller
		port map(
			clk   => clk,
			rst   => rst,
			start => start,
			di    => data_out,
			do    => data_in
		);

end architecture STR;
