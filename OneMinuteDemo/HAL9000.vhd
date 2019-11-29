library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HAL9000 is
	port(
		airlock   : in  std_logic;
		comms_in  : in  std_logic;
		comms_out : out std_logic
	);
end entity HAL9000;

architecture RTL of HAL9000 is
	type crew is (Frank, Dave);
	signal chess_player : crew;
	signal chess        : crw;          -- @suppressError
begin

end architecture RTL;
