-- --------------------------------------------------------------------
--
--   Title     :  std_logic_1164 multi-value logic system
--   Library   :  This package shall be compiled into a library
--             :  symbolically named IEEE.
--             :
--   Developers:  IEEE model standards group (par 1164)
--   Purpose   :  This packages defines a standard for designers
--             :  to use in describing the interconnection data types
--             :  used in vhdl modeling.
--             :
--   Limitation:  The logic system defined in this package may
--             :  be insufficient for modeling switched transistors,
--             :  since such a requirement is out of the scope of this
--             :  effort. Furthermore, mathematics, primitives,
--             :  timing standards, etc. are considered orthogonal
--             :  issues as it relates to this package and are therefore
--             :  beyond the scope of this effort.
--             :
--   Note      :  No declarations or definitions shall be included in,
--             :  or excluded from this package. The "package declaration"
--             :  defines the types, subtypes and declarations of
--             :  std_logic_1164. The std_logic_1164 package body shall be
--             :  considered the formal definition of the semantics of
--             :  this package. Tool developers may choose to implement
--             :  the package body in the most efficient manner available
--             :  to them.
--             :
-- --------------------------------------------------------------------
--   modification history :
-- --------------------------------------------------------------------
--  version | mod. date:|
--   v4.200 | 01/02/92  |
-- --------------------------------------------------------------------

package std_logic_1164 is

    -------------------------------------------------------------------
    -- logic state system  (unresolved)
    -------------------------------------------------------------------
    type std_ulogic is ( 'U',  -- Uninitialized
                         'X',  -- Forcing  Unknown
                         '0',  -- Forcing  0
                         '1',  -- Forcing  1
                         'Z',  -- High Impedance
                         'W',  -- Weak     Unknown
                         'L',  -- Weak     0
                         'H',  -- Weak     1
                         '-'   -- Don't care
                       );
    -------------------------------------------------------------------
    -- unconstrained array of std_ulogic for use with the resolution function
    -------------------------------------------------------------------
    type std_ulogic_vector is array ( natural range <> ) of std_ulogic;

    -------------------------------------------------------------------
    -- resolution function
    -------------------------------------------------------------------
    function resolved ( s : std_ulogic_vector ) return std_ulogic;


    -------------------------------------------------------------------
    -- *** industry standard logic type ***
    -------------------------------------------------------------------
    subtype std_logic is resolved std_ulogic;

    -------------------------------------------------------------------
    -- unconstrained array of std_logic for use in declaring signal arrays
    -------------------------------------------------------------------
    type std_logic_vector is array ( natural range <>) of std_logic;

    -------------------------------------------------------------------
    -- common subtypes
    -------------------------------------------------------------------

    subtype X01     is resolved std_ulogic range 'X' to '1'; -- ('X','0','1')
    subtype X01Z    is resolved std_ulogic range 'X' to 'Z'; -- ('X','0','1','Z')
    subtype UX01    is resolved std_ulogic range 'U' to '1'; -- ('U','X','0','1')
    subtype UX01Z   is resolved std_ulogic range 'U' to 'Z'; -- ('U','X','0','1','Z')

    -------------------------------------------------------------------
    -- overloaded logical operators
    -------------------------------------------------------------------

    function "and"  ( l : std_ulogic; r : std_ulogic ) return UX01;
    function "nand" ( l : std_ulogic; r : std_ulogic ) return UX01;
    function "or"   ( l : std_ulogic; r : std_ulogic ) return UX01;
    function "nor"  ( l : std_ulogic; r : std_ulogic ) return UX01;
    function "xor"  ( l : std_ulogic; r : std_ulogic ) return UX01;
  	function "xnor" ( l : std_ulogic; r : std_ulogic ) return UX01;
    function "not"  ( l : std_ulogic                 ) return UX01;

    -------------------------------------------------------------------
    -- vectorized overloaded logical operators
    -------------------------------------------------------------------

    function "and"  ( l, r : std_logic_vector  ) return std_logic_vector;
    function "and"  ( l, r : std_ulogic_vector ) return std_ulogic_vector;

    function "nand" ( l, r : std_logic_vector  ) return std_logic_vector;
    function "nand" ( l, r : std_ulogic_vector ) return std_ulogic_vector;

    function "or"   ( l, r : std_logic_vector  ) return std_logic_vector;
    function "or"   ( l, r : std_ulogic_vector ) return std_ulogic_vector;

    function "nor"  ( l, r : std_logic_vector  ) return std_logic_vector;
    function "nor"  ( l, r : std_ulogic_vector ) return std_ulogic_vector;

    function "xor"  ( l, r : std_logic_vector  ) return std_logic_vector;
    function "xor"  ( l, r : std_ulogic_vector ) return std_ulogic_vector;

--  -----------------------------------------------------------------------
--  Note : The declaration and implementation of the "xnor" function is
--  specifically commented until at which time the VHDL language has been
--  officially adopted as containing such a function. At such a point,
--  the following comments may be removed along with this notice without
--  further "official" ballotting of this std_logic_1164 package. It is
--  the intent of this effort to provide such a function once it becomes
--  available in the VHDL standard.
--  -----------------------------------------------------------------------
    function "xnor" ( l, r : std_logic_vector  ) return std_logic_vector;
    function "xnor" ( l, r : std_ulogic_vector ) return std_ulogic_vector;

    function "not"  ( l : std_logic_vector  ) return std_logic_vector;
    function "not"  ( l : std_ulogic_vector ) return std_ulogic_vector;

    -------------------------------------------------------------------
    -- conversion functions
    -------------------------------------------------------------------

    function to_bit       ( s : std_ulogic;        xmap : bit := '0') return bit;
    function to_bitvector ( s : std_logic_vector ; xmap : bit := '0') return bit_vector;
    function to_bitvector ( s : std_ulogic_vector; xmap : bit := '0') return bit_vector;

    function to_stdulogic       ( b : bit               ) return std_ulogic;
    function to_stdlogicvector  ( b : bit_vector        ) return std_logic_vector;
    function to_stdlogicvector  ( s : std_ulogic_vector ) return std_logic_vector;
    function to_stdulogicvector ( b : bit_vector        ) return std_ulogic_vector;
    function to_stdulogicvector ( s : std_logic_vector  ) return std_ulogic_vector;

    -------------------------------------------------------------------
    -- strength strippers and type convertors
    -------------------------------------------------------------------

    function to_X01  ( s : std_logic_vector  ) return  std_logic_vector;
    function to_X01  ( s : std_ulogic_vector ) return  std_ulogic_vector;
    function to_X01  ( s : std_ulogic        ) return  X01;
    function to_X01  ( b : bit_vector        ) return  std_logic_vector;
    function to_X01  ( b : bit_vector        ) return  std_ulogic_vector;
    function to_X01  ( b : bit               ) return  X01;

    function to_X01Z ( s : std_logic_vector  ) return  std_logic_vector;
    function to_X01Z ( s : std_ulogic_vector ) return  std_ulogic_vector;
    function to_X01Z ( s : std_ulogic        ) return  X01Z;
    function to_X01Z ( b : bit_vector        ) return  std_logic_vector;
    function to_X01Z ( b : bit_vector        ) return  std_ulogic_vector;
    function to_X01Z ( b : bit               ) return  X01Z;

    function to_UX01  ( s : std_logic_vector  ) return  std_logic_vector;
    function to_UX01  ( s : std_ulogic_vector ) return  std_ulogic_vector;
    function to_UX01  ( s : std_ulogic        ) return  UX01;
    function to_UX01  ( b : bit_vector        ) return  std_logic_vector;
    function to_UX01  ( b : bit_vector        ) return  std_ulogic_vector;
    function to_UX01  ( b : bit               ) return  UX01;

    -------------------------------------------------------------------
    -- edge detection
    -------------------------------------------------------------------

    function rising_edge  (signal s : std_ulogic) return boolean;
    function falling_edge (signal s : std_ulogic) return boolean;

    -------------------------------------------------------------------
    -- object contains an unknown
    -------------------------------------------------------------------

    function is_X ( s : std_ulogic_vector ) return  boolean;
    function is_X ( s : std_logic_vector  ) return  boolean;
    function is_X ( s : std_ulogic        ) return  boolean;

end package std_logic_1164;
