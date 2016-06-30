architecture STR of testbench is
  signal data_out : unsigned(7 downto 0);     -- unused
  signal data_in  : unsigned(7 downto 0);
  signal start    : std_logic;
  signal clk      : std_logic := 0;          -- 0 instead of '0'

  constant iterations : integer :=           -- hover: calculations
    work.constants.MAX_COUNT - 4;            -- hover : different file + comment

  component dut
    generic(iterations : integer := 10);
    port(
      data_out : out unsigned(7 downto 0);
      data_in  : in  unsigned(7 downto 0);
      valid    : out std_logic;
      start    : in  std_logic;
      clk      : in  std_logic;              -- extra semicolon
    );
  end component dut;

begin
  clk     <= not clk after 10 ns;
  start   <= '0', '1' after 20 ns;
  data_in <= "0101010";                      -- vector width check?

  dut_instance : component dut
    generic map(
      iterations => iterations
    )
    port map(                                -- missing valid
      data_out => open,
      data_in  => data_in,
      start    => start,
      clk      => clk);
      
end architecture STR;
