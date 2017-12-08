use work.constants.all;
architecture RTL of dut is
	signal count  : integer range 0 to MAX_COUNT;
	signal result : unsigned(7 downto 0);
begin
	assert iterations <= MAX_COUNT;

	COUNTER : process(clk, rst) is
		variable state : state_t;
	begin
		if rst = '1' then
			state  := idle;
			count  <= 0;
			valid  <= '0';
			result <= (others => '0');
		elsif rising_edge(clk) then
			case state is
				when idle =>
					if start = '1' then
						count <= 0;
						state := preparing;
					end if;
					valid  <= '0';
					result <= (2 => '1', others => '0');
				when preparing =>
					state := running;
				when running =>
					if count = iterations then
						state  := ready;
						result <= resize(result * data_in, result'length);
					end if;
					count <= count + 1;
				when ready =>
					data_out <= result;
					valid    <= '1';
					state    := idle;
			end case;
		end if;
	end process COUNTER;

end architecture RTL;
