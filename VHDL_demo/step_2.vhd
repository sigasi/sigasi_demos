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
	constant CLK_PERIOD : time    := 50 ns;

begin
	----------------------------------------------------------------------
	-- "Open declaration": in the line below, place your cursor on
	-- the word "dut" and press "F3". This takes you to the declaration of 
	-- the entity "dut". 
	----------------------------------------------------------------------
	dut_instance : entity work.dut(RTL)
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

	assert valid = '0' or data_out /= "00000000";

	CLOCK_DRIVER : process is
	begin
		clk <= '0';
		wait for CLK_PERIOD / 2;
		clk <= '1';
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

	DATA_DELAY : process(clk) is
	begin
		if rising_edge(clk) then
			data_in <= data_out;
		end if;
	end process DATA_DELAY;

end architecture STR;
