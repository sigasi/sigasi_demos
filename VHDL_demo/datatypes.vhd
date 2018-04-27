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
	signal b : bit := '1';

begin
	a <= 5;
	b <= '1';
	a <= f('1');
	b <= f(6);
	a <= f(b);

	p_p : process is
		variable v : integer := 5;
		variable w : bit;
	begin
		v := 5;
		w := '0';
	end process p_p;

end architecture RTL;
