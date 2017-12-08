library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Toplevel of the design under test
entity dut is
	generic(
		iterations : integer := 10
	);
	port(
		data_out : out unsigned(7 downto 0);
		data_in  : in  unsigned(7 downto 0);
		start    : out std_logic;
		clk      : in  std_logic;
		rst      : in  std_logic
	);
end entity dut;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg_component is
	component dut
		generic(iterations : integer := 10);
		port(
			data_out : out unsigned(7 downto 0);
			data_in  : in  unsigned(7 downto 0);
			start    : out std_logic;
			clk      : in  std_logic;
			rst      : in  std_logic
		);
	end component dut;
end package pkg_component;
