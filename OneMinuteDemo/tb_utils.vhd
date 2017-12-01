library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_utils is
	port(
		clk   : out std_logic;
		rst   : out std_logic;
		--dataI : in  unsigned := (others => '0');
		--dataO : out unsigned;
		start : out std_logic
	);
end entity tb_utils;

use work.constants.CLK_PERIOD;

architecture RTL of tb_utils is
	constant CLK_PERIOD_INT : natural              := CLK_PERIOD / 1 ns;
	signal clk_int          : std_logic;
	signal count            : unsigned(7 downto 0) := (others => '1');

begin
	clock_inst : entity work.clock_generator
		generic map(PERIOD => CLK_PERIOD_INT)
		port map(clk => clk_int);

	rst <= '0', '1' after CLK_PERIOD / 2, '0' after 3 * CLK_PERIOD;
	clk <= clk_int;

	start <= count(count'high);

	p_startTrigger : process(clk_int) is
	begin
		if rising_edge(clk_int) then
			count <= count + 1;
			if count(count'high) = '1' then
				count <= (others => '0');
			end if;
		end if;
	end process p_startTrigger;

--	p_processData : process(clk) is
--	begin
--		if rising_edge(clk) then
--			dataO <= dataI;
--		end if;
--	end process p_processData;

end architecture RTL;
