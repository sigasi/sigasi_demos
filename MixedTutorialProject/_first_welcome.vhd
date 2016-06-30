----------------------------------------------------------------------
-- Congratulations!
-- You made a great choice installing Sigasi, and now you are ready to unlock its power.
--
--
-- TODO: follow the instructions below, that are marked 'TODO'.
--

library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity welcome is
    port(
        clk : in std_logic;
        rst : in std_logic
    );
end entity welcome;

architecture RTL of welcome is
    -- TODO: place your mouse over the word 'MY_CONSTANT' and watch the
    -- pop-up show you the value. Do the same with 'ANSWER' 
    constant SIZE : integer := ANSWER / 2;

    type mytype is (a, b, c);
    signal s    : mytype;
    signal data : std_logic_vector(SIZE - 1 downto 0);
begin
    -- TODO: fix this sensitivy list by clicking on the lightbulb to the left of the line
    name : process(clk) is
    begin
        if rst = '0' then
            s    <= a;
            data <= (others => '0');
        elsif rising_edge(clk) then
        -- TODO "Autocomplete": on the line below, type "case" and then press CTRL+Space
            
        end if;
    end process name;

end architecture RTL;

-- TODO "Open your own file":
-- ->  Drag your file into this editor,
-- ->  or click *File > Open File ...*
