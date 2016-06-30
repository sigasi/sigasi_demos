library ieee;
use ieee.std_logic_1164.all;

package constants is
	
	constant MAX_COUNT : integer := 2 ** 8 - 1; -- Maximum value

	constant ANSWER : integer := 4 * 10 + 2;

	constant MAGIC_NUMNER : std_logic_vector(15 downto 0) := X"da01";

	type state_t is (idle, preparing, running, ready, waiting); -- FSM State type

end package constants;
