entity datatypes is
end entity datatypes;

architecture RTL of datatypes is
	function f(p : integer) return bit is
	begin
		return '1';
	end function f;

	function f(p : bit) return integer is
	begin
		return 1;
	end function f;

	signal a : integer;
	signal b : bit := 6;

begin
	a <= '1';
	b <= 2;
	a <= f(1);
	b <= f('1');
	a <= b;

	p_p : process is
		variable v : integer := '1';
		variable w : bit;
	begin
		v := '1';
		w := 6;
	end process p_p;

end architecture RTL;
