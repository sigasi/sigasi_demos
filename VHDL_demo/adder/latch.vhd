library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity latch is
	port(
		s, r  : in  std_logic;
		q, nq : out std_logic
	);
end entity latch;

architecture RTL of latch is
	component nor_gate
		port(
			a, b : in  std_logic;
			c    : out std_logic
		);
	end component nor_gate;
	signal sig_q, sig_nq : std_logic;

begin
	nor_gate_r : component nor_gate
		port map(
			a => r,
			b => sig_nq,
			c => sig_q
		);
	nor_gate_s : component nor_gate
		port map(
			a => sig_q,
			b => s,
			c => sig_nq
		);
	--	sig_q  <= q;
	--	sig_nq <= nq;
	q  <= sig_q;
	nq <= sig_nq;
end architecture RTL;
