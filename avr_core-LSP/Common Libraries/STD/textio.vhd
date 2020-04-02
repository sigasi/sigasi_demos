package textio is

	-- Type definitions for text I/O:

	type line is access string;         -- A line is a pointer to a string value

	type text is file of string;        -- A file of variable-length ASCII records.

	type side is (RIGHT, LEFT);         -- For justifying output data within fields.

	subtype width is natural;           -- For specifying widths of output fields.

	-- Standard text files:

	file input : text open READ_MODE is "STD_INPUT";

	file output : text open WRITE_MODE is "STD_OUTPUT";

	procedure readline(file f : text; l : out line);

	procedure read(l : inout line; value : out bit; good : out boolean);
	procedure read(l : inout line; value : out bit);

	procedure read(l : inout line; value : out bit_vector; good : out boolean);
	procedure read(l : inout line; value : out bit_vector);

	procedure read(l : inout line; value : out boolean; good : out boolean);
	procedure read(l : inout line; value : out boolean);

	procedure read(l : inout line; value : out character; good : out boolean);
	procedure read(l : inout line; value : out character);

	procedure read(l : inout line; value : out integer; good : out boolean);
	procedure read(l : inout line; value : out integer);

	procedure read(l : inout line; value : out real; good : out boolean);
	procedure read(l : inout line; value : out real);

	procedure read(l : inout line; value : out string; good : out boolean);
	procedure read(l : inout line; value : out string);

	procedure read(l : inout line; value : out time; good : out boolean);
	procedure read(l : inout line; value : out time);

	-- Output routines for standard types:

	procedure writeline(file f : text; l : inout line);

	procedure write(l : inout line; value : in bit; justified : in side := RIGHT; field : in width := 0);

	procedure write(l : inout line; value : in bit_vector; justified : in side := RIGHT; field : in width := 0);

	procedure write(l : inout line; value : in boolean; justified : in side := RIGHT; field : in width := 0);

	procedure write(l : inout line; value : in character; justified : in side := RIGHT; field : in width := 0);

	procedure write(l : inout line; value : in integer; justified : in side := RIGHT; field : in width := 0);

	procedure write(l : inout line; value : in real; justified : in side := RIGHT; field : in width := 0; digits : in natural := 0);

	procedure write(l : inout line; value : in string; justified : in side := RIGHT; field : in width := 0);

	procedure write(l : inout line; value : in time; justified : in side := RIGHT; field : in width := 0; unit : in time := ns);

end package textio;
