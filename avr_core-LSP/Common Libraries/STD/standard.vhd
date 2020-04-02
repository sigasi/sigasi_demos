package standard is

	-- predefined enumeration types:

	type boolean is (FALSE, TRUE);

	-- The predefined operators for this type are as follows:

	function "and"  (l, r: boolean) return boolean;
	function "or"	(l, r: boolean) return boolean;
	function "nand" (l, r: boolean) return boolean;
	function "nor"  (l, r: boolean) return boolean;
	function "xor"  (l, r: boolean) return boolean;
	function "xnor" (l, r: boolean) return boolean;

	function "not" (anonymous: boolean) return boolean;

	-- function "="  (l, r: boolean) return boolean;
	-- function "/=" (l, r: boolean) return boolean;
	-- function "<"  (l, r: boolean) return boolean;
	-- function "<=" (l, r: boolean) return boolean;
	-- function ">"  (l, r: boolean) return boolean;
	-- function ">=" (l, r: boolean) return boolean;

	type bit is ('0', '1');

	-- The predefined operators for this type are as follows:

	function "and"  (l, r: bit) return bit;
	function "or"   (l, r: bit) return bit;
	function "nand" (l, r: bit) return bit;
	function "nor"  (l, r: bit) return bit;
	function "xor"  (l, r: bit) return bit;
	function "xnor" (l, r: bit) return bit;

	function "not" (anonymous: bit) return bit;

	-- function "="  (l, r: bit) return boolean;
	-- function "/=" (l, r: bit) return boolean;
	-- function "<"  (l, r: bit) return boolean;
	-- function "<=" (l, r: bit) return boolean;
	-- function ">"  (l, r: bit) return boolean;
	-- function ">=" (l, r: bit) return boolean;

	type character is (
		NUL,	SOH,	STX,	ETX,	EOT,	ENQ,	ACK,	BEL,
		BS ,	HT ,	LF ,	VT ,	FF ,	CR ,	SO ,	SI ,
		DLE,	DC1,	DC2,	DC3,	DC4,	NAK,	SYN,	ETB,
		CAN,	EM ,	SUB,	ESC,	FSP,	GSP,	RSP,	USP,

		' ',	'!',	'"',	'#',	'$',	'%',	'&',	''',
		'(',	')',	'*',	'+',	',',	'-',	'.',	'/',
		'0',	'1',	'2',	'3',	'4',	'5',	'6',	'7',
		'8',	'9',	':',	';',	'<',	'=',	'>',	'?',

		'@',	'A',	'B',	'C',	'D',	'E',	'F',	'G',
		'H',	'I',	'J',	'K',	'L',	'M',	'N',	'O',
		'P',	'Q',	'R',	'S',	'T',	'U',	'V',	'W',
		'X',	'Y',	'Z',	'[',	'\',	']',	'^',	'_',

		'`',	'a',	'b',	'c',	'd',	'e',	'f',	'g',
		'h',	'i',	'j',	'k',	'l',	'm',	'n',	'o',
		'p',	'q',	'r',	's',	't',	'u',	'v',	'w',
		'x',	'y',	'z',	'{',	'|',	'}',	'~',	DEL,

		C128,	C129,	C130,	C131,	C132,	C133,	C134,	C135,
		C136,	C137,	C138,	C139,	C140,	C141,	C142,	C143,
		C144,	C145,	C146,	C147,	C148,	C149,	C150,	C151,
		C152,	C153,	C154,	C155,	C156,	C157,	C158,	C159,

		' ',	'¡',	'¢',	'£',	'¤',	'¥',	'¦',	'§',
		'¨',	'©',	'ª',	'«',	'¬',	'­' ,	'®',	'¯',
		'°',	'±',	'²',	'³',	'´',	'µ',	'¶',	'·',
		'¸',	'¹',	'º',	'»',	'¼',	'½',	'¾',	'¿',
		'À',	'Á',	'Â',	'Ã',	'Ä',	'Å',	'Æ',	'Ç',
		'È',	'É',	'Ê',	'Ë',	'Ì',	'Í',	'Î',	'Ï',
		'Ð',	'Ñ',	'Ò',	'Ó',	'Ô',	'Õ',	'Ö',	'×',
		'Ø',	'Ù',	'Ú',	'Û',	'Ü',	'Ý',	'Þ',	'ß',
		'à',	'á',	'â',	'ã',	'ä',	'å',	'æ',	'ç',
		'è',	'é',	'ê',	'ë',	'ì',	'í',	'î',	'ï',
		'ð',	'ñ',	'ò',	'ó',	'ô',	'õ',	'ö',	'÷',
		'ø',	'ù',	'ú',	'û',	'ü',	'ý',	'þ',	'ÿ');

	-- The predefined operators for this type are as follows:

	-- function "=" (l, r: character) return boolean;
	-- function "/=" (l, r: character) return boolean;
	-- function "<" (l, r: character) return boolean;
	-- function "<=" (l, r: character) return boolean;
	-- function ">" (l, r: character) return boolean;
	-- function ">=" (l, r:character) return boolean;

	type severity_level is (NOTE, WARNING, ERROR, FAILURE);

	-- The predefined operators for this type are as follows:

	-- function "=" (l, r: severity_level) return boolean;
	-- function "/=" (l, r: severity_level) return boolean;
	-- function "<" (l, r: severity_level) return boolean;
	-- function "<=" (l, r: severity_level) return boolean;
	-- function ">" (l, r: severity_level) return boolean;
	-- function ">=" (l, r:severity_level) return boolean;

	-- predefined numeric types:

	type integer is range -2147483647 to 2147483647;

	-- The predefined operators for this type are as follows:

	-- function "=" (l, r: integer) return boolean;
	-- function "/=" (l, r: integer) return boolean;
	-- function "<" (l, r: integer) return boolean;
	-- function "<=" (l, r: integer) return boolean;
	-- function ">" (l, r: integer) return boolean;
	-- function ">=" (l, r: integer) return boolean;
	--
	-- function "+" (anonymous: integer) return integer;
	-- function "-" (anonymous: integer) return integer;
	-- function "abs" (anonymous: integer) return integer;
	--
	-- function "+" (l, r: integer) return integer;
	-- function "-" (l, r: integer) return integer;
	-- function "*" (l, r: integer) return integer;
	-- function "/" (l, r: integer) return integer;
	-- function "mod" (l, r: integer) return integer;
	-- function "rem" (l, r: integer) return integer;
	--
	-- function "**" (l: integer; r: integer) return integer;

	type real is range -1.7014111e+308 to 1.7014111e+308;

	-- The predefined operators for this type are as follows:

	-- function "=" (l, r: real) return boolean;
	-- function "/=" (l, r: real) return boolean;
	-- function "<" (l, r: real) return boolean;
	-- function "<=" (l, r: real) return boolean;
	-- function ">" (l, r: real) return boolean;
	-- function ">=" (l, r: real) return boolean;
	--
	-- function "+" (anonymous: real) return real;
	-- function "-" (anonymous: real) return real;
	-- function "abs" (anonymous: real) return real;
	--
	-- function "+" (l, r: real) return real;
	-- function "-" (l, r: real) return real;
	-- function "*" (l, r: real) return real;
	-- function "/" (l, r: real) return real;
	--
	-- function "**" (l: real; r: integer) return real;

	-- predefined type TIME:
	type time is range -2147483647 to 2147483647
	units
		fs;             -- femtosecond
		ps  = 1000 fs;  -- picosecond
		ns  = 1000 ps;  -- nanosecond
		us  = 1000 ns;  -- microsecond
		ms  = 1000 us;  -- millisecond
		sec = 1000 ms;  -- second
		min =   60 sec; -- minute
		hr  =   60 min; -- hour
	end units;


	-- The predefined operators for this type are as follows:

	-- function "=" (l, r: time) return boolean;
	-- function "/=" (l, r: time) return boolean;
	-- function "<" (l, r: time) return boolean;
	-- function "<=" (l, r: time) return boolean;
	-- function ">" (l, r: time) return boolean;
	-- function ">=" (l, r: time) return boolean;
	--
	-- function "+" (anonymous: time) return time;
	-- function "-" (anonymous: time) return time;
	-- function "abs" (anonymous: time) return time;
	--
	-- function "+" (l, r: time) return time;
	-- function "-" (l, r: time) return time;
	--
	-- function "*" (l: time; r: integer) return time;
	-- function "*" (l: time; r: real) return time;
	-- function "*" (l: integer; r: time) return time;
	-- function "*" (l: real; r: time) return time;
	--
	-- function "/" (l: time; r: integer) return time;
	-- function "/" (l: time; r: real) return time;
	-- function "/" (l, r: time) return integer;

	subtype delay_length is time range 0 fs to time'high;

	-- function that returns the current simulation time:
	function now return delay_length;

	-- predefined numeric subtypes:

	subtype natural is integer range 0 to integer'high;

	subtype positive is integer range 1 to integer'high;

	-- predefined array types:

	type string is array (positive range <>) of character;

	-- The predefined operators for these types are as follows:

	-- function "=" (l, r: string) return boolean;
	-- function "/=" (l, r: string) return boolean;
	-- function "<" (l, r: string) return boolean;
	-- function "<=" (l, r: string) return boolean;
	-- function ">" (l, r: string) return boolean;
	-- function ">=" (l, r: string) return boolean;
	--
	-- function "&" (l: string; r: string) return string;
	-- function "&" (l: string; r: character) return string;
	-- function "&" (l: character; r: string) return string;
	-- function "&" (l: character; r: character) return string;

	type bit_vector is array (natural range <>) of bit;

	-- The predefined operators for these types are as follows:

	function "and"  (l, r: bit_vector) return bit_vector;
	function "or"   (l, r: bit_vector) return bit_vector;
	function "nand" (l, r: bit_vector) return bit_vector;
	function "nor"  (l, r: bit_vector) return bit_vector;
	function "xor"  (l, r: bit_vector) return bit_vector;
	function "xnor" (l, r: bit_vector) return bit_vector;

	function "not" (anonymous: bit_vector) return bit_vector;

	function "and"  (l: bit_vector; r: boolean) return bit_vector;
	function "and"  (l: boolean; r: bit_vector) return bit_vector;
	function "or"  (l: bit_vector; r: boolean) return bit_vector;
	function "or"  (l: boolean; r: bit_vector) return bit_vector;
	function "nand"  (l: bit_vector; r: boolean) return bit_vector;
	function "nand"  (l: boolean; r: bit_vector) return bit_vector;
	function "nor"  (l: bit_vector; r: boolean) return bit_vector;
	function "nor"  (l: boolean; r: bit_vector) return bit_vector;
	function "xor"  (l: bit_vector; r: boolean) return bit_vector;
	function "xor"  (l: boolean; r: bit_vector) return bit_vector;
	function "xnor"  (l: bit_vector; r: boolean) return bit_vector;
	function "xnor"  (l: boolean; r: bit_vector) return bit_vector;

	function "and"  (anonymous: bit_vector) return boolean;
	function "or"   (anonymous: bit_vector) return boolean;
	function "nand" (anonymous: bit_vector) return boolean;
	function "nor"  (anonymous: bit_vector) return boolean;
	function "xor"  (anonymous: bit_vector) return boolean;
	function "xnor" (anonymous: bit_vector) return boolean;

	function "sll"  (l: bit_vector; r: integer) return bit_vector;
	function "srl"  (l: bit_vector; r: integer) return bit_vector;
	function "sla"  (l: bit_vector; r: integer) return bit_vector;
	function "sra"  (l: bit_vector; r: integer) return bit_vector;
	function "rol"  (l: bit_vector; r: integer) return bit_vector;
	function "ror"  (l: bit_vector; r: integer) return bit_vector;

	-- function "=" (l, r: bit_vector) return boolean;
	-- function "/=" (l, r: bit_vector) return boolean;
	-- function "<" (l, r: bit_vector) return boolean;
	-- function "<=" (l, r: bit_vector) return boolean;
	-- function ">" (l, r: bit_vector) return boolean;
	-- function ">=" (l, r: bit_vector) return boolean;
	--
	-- function "&" (l: bit_vector; r: bit_vector) return bit_vector;
	-- function "&" (l: bit_vector; r: boolean) return bit_vector;
	-- function "&" (l: boolean; r: bit_vector) return bit_vector;
	-- function "&" (l: boolean; r: boolean) return bit_vector;

	-- The predefined types for opening files:

	type file_open_kind is (
		READ_MODE,                      -- Resulting access mode is read-only.
		WRITE_MODE,                     -- Resulting access mode is write-only.
		APPEND_MODE                     -- Resulting access mode is write-only; information is appended to the end of the existing file.
	);

	-- The predefined operators for this type are as follows:

	-- function "=" (l, r: file_open_kind) return boolean;
	-- function "/=" (l, r: file_open_kind) return boolean;
	-- function "<" (l, r: file_open_kind) return boolean;
	-- function "<=" (l, r: file_open_kind) return boolean;
	-- function ">" (l, r: file_open_kind) return boolean;
	-- function ">=" (l, r: file_open_kind) return boolean;

	type file_open_status is (
		OPEN_OK,                        -- File open was successful.
		STATUS_ERROR,                   -- File object was already open.
		NAME_ERROR,                     -- External file not found or inaccessible.
		MODE_ERROR                      -- Could not open file with requested access mode.
	);

	-- The predefined operators for this type are as follows:

	-- function "=" (l, r: file_open_status) return boolean;
	-- function "/=" (l, r: file_open_status) return boolean;
	-- function "<" (l, r: file_open_status) return boolean;
	-- function "<=" (l, r: file_open_status) return boolean;
	-- function ">" (l, r: file_open_status) return boolean;
	-- function ">=" (l, r: file_open_status) return boolean;

	attribute foreign: string;

end package standard;
