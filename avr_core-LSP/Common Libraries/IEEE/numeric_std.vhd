-- --------------------------------------------------------------------
--
-- Copyright © 1997 by IEEE. All rights reserved.
--
-- This source file is an essential part of IEEE Std 1076.3-1997,
-- IEEE Standard VHDL Synthesis Packages. This source file may not be
-- copied, sold, or included with software that is sold without written 
-- permission from the IEEE Standards Department. This source file may
-- be used to implement this standard and may be distributed in compiled
-- form in any manner so long as the compiled form does not allow direct
-- decompilation of the original source file. This source file may be 
-- copied for individual use between licensed users. This source file is
-- provided on an AS IS basis. The IEEE disclaims ANY WARRANTY EXPRESS OR
-- IMPLIED INCLUDING ANY WARRANTY OF MERCHANTABILITY AND FITNESS FOR USE
-- FOR A PARTICULAR PURPOSE. The user of the source file shall indemnify
-- and hold IEEE harmless from any damages or liability arising out of the
-- use thereof.
--
-- This package may be modified to include additional data required by tools,
-- but it must in no way change the external interfaces or simulation behavior
-- of the description. It is permissible to add comments and/or attributes to
-- the package declarations, but not to change or delete any original lines of
-- the package declaration. The package body may be changed only in accordance
-- with the terms of 7.1 and 7.2 of this standard.
--
-- Title      : Standard VHDL Synthesis Packages (IEEE Std 1076.3, NUMERIC_STD)
--
-- Library    : This package shall be compiled into a library symbolically
--            : named IEEE.
--
-- Developers : IEEE DASC Synthesis Working Group.
--
-- Purpose    : This package defines numeric types and arithmetic functions
--            : for use with synthesis tools. Two numeric types are defined:
--            : -- > UNSIGNED: represents UNSIGNED number in vector form
--            : -- > SIGNED: represents a SIGNED number in vector form
--            : The base element type is type STD_LOGIC.
--            : The leftmost bit is treated as the most significant bit.
--            : Signed vectors are represented in two's complement form.
--            : This package contains overloaded arithmetic operators on
--            : the SIGNED and UNSIGNED types. The package also contains
--            : useful type conversions functions.
--            :
--            : If any argument to a function is a null array, a null array is
--            : returned (exceptions, if any, are noted individually).
--
-- Note       : No declarations or definitions shall be included in, or
--            : excluded from, this package. The "package declaration" defines
--            : the types, subtypes, and declarations of NUMERIC_STD. The
--            : NUMERIC_STD package body shall be considered the formal
--            : definition of the semantics of this package. Tool developers
--            : may choose to implement the package body in the most efficient
--            : manner available to them.
--
-- --------------------------------------------------------------------
--   Modification History :
-- --------------------------------------------------------------------
--   Version:  2.4
--   Date   :  12 April 1995
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package numeric_std is
  constant CopyRightNotice: string
      := "Copyright © 1997 IEEE. All rights reserved.";

  --============================================================================
  -- Numeric Array Type Definitions
  --============================================================================

  type unsigned is array (natural range <>) of std_logic;
  type signed is array (natural range <>) of std_logic;

  --============================================================================
  -- Arithmetic Operators:
  --===========================================================================

  --```
  -- Id: A.1
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: Returns the absolute value of a signed vector arg.
  --```
  function "abs" (arg: signed) return signed;

  --```
  -- Id: A.2
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: Returns the value of the unary minus operation on a
  --         signed vector arg.
  --```
  function "-" (arg: signed) return signed;

  --============================================================================

  --```
  -- Id: A.3
  -- Result subtype: unsigned(max(l'length, r'length)-1 downto 0)
  -- Result: Adds two unsigned vectors that may be of different lengths.
  --```
  function "+" (l, r: unsigned) return unsigned;

  --```
  -- Id: A.4
  -- Result subtype: signed(max(l'length, r'length)-1 downto 0)
  -- Result: Adds two signed vectors that may be of different lengths.
  --```
  function "+" (l, r: signed) return signed;

  --```
  -- Id: A.5
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Adds an unsigned vector, l, with a nonnegative integer, r.
  --```
  function "+" (l: unsigned; r: natural) return unsigned;

  --```
  -- Id: A.6
  -- Result subtype: unsigned(r'length-1 downto 0)
  -- Result: Adds a nonnegative integer, l, with an unsigned vector, r.
  --```
  function "+" (l: natural; r: unsigned) return unsigned;

  --```
  -- Id: A.7
  -- Result subtype: signed(r'length-1 downto 0)
  -- Result: Adds an integer, l(may be positive or negative), to a signed
  --         vector, r.
  --```
  function "+" (l: integer; r: signed) return signed;

  --```
  -- Id: A.8
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Adds a signed vector, l, to an integer, r.
  --```
  function "+" (l: signed; r: integer) return signed;

  --============================================================================

  --```
  -- Id: A.9
  -- Result subtype: unsigned(max(l'length, r'length)-1 downto 0)
  -- Result: Subtracts two unsigned vectors that may be of different lengths.
  --```
  function "-" (l, r: unsigned) return unsigned;

  --```
  -- Id: A.10
  -- Result subtype: signed(max(l'length, r'length)-1 downto 0)
  -- Result: Subtracts a signed vector, r, from another signed vector, l,
  --         that may possibly be of different lengths.
  --```
  function "-" (l, r: signed) return signed;

  --```
  -- Id: A.11
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Subtracts a nonnegative integer, r, from an unsigned vector, l.
  --```
  function "-" (l: unsigned;r: natural) return unsigned;

  --```
  -- Id: A.12
  -- Result subtype: unsigned(r'length-1 downto 0)
  -- Result: Subtracts an unsigned vector, r, from a nonnegative integer, l.
  --```
  function "-" (l: natural; r: unsigned) return unsigned;

  --```
  -- Id: A.13
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Subtracts an integer, r, from a signed vector, l.
  --```
  function "-" (l: signed; r: integer) return signed;

  --```
  -- Id: A.14
  -- Result subtype: signed(r'length-1 downto 0)
  -- Result: Subtracts a signed vector, r, from an integer, l.
  --```
  function "-" (l: integer; r: signed) return signed;

  --============================================================================

  --```
  -- Id: A.15
  -- Result subtype: unsigned((l'length+r'length-1) downto 0)
  -- Result: Performs the multiplication operation on two unsigned vectors
  --         that may possibly be of different lengths.
  --```
  function "*" (l, r: unsigned) return unsigned;

  --```
  -- Id: A.16
  -- Result subtype: signed((l'length+r'length-1) downto 0)
  -- Result: Multiplies two signed vectors that may possibly be of
  --         different lengths.
  --```
  function "*" (l, r: signed) return signed;

  --```
  -- Id: A.17
  -- Result subtype: unsigned((l'length+l'length-1) downto 0)
  -- Result: Multiplies an unsigned vector, l, with a nonnegative
  --         integer, r. r is converted to an unsigned vector of
  --         size l'length before multiplication.
  --```
  function "*" (l: unsigned; r: natural) return unsigned;

  --```
  -- Id: A.18
  -- Result subtype: unsigned((r'length+r'length-1) downto 0)
  -- Result: Multiplies an unsigned vector, r, with a nonnegative
  --         integer, l. l is converted to an unsigned vector of
  --         size r'length before multiplication.
  --```
  function "*" (l: natural; r: unsigned) return unsigned;

  --```
  -- Id: A.19
  -- Result subtype: signed((l'length+l'length-1) downto 0)
  -- Result: Multiplies a signed vector, l, with an integer, r. r is
  --         converted to a signed vector of size l'length before
  --         multiplication.
  --```
  function "*" (l: signed; r: integer) return signed;

  --```
  -- Id: A.20
  -- Result subtype: signed((r'length+r'length-1) downto 0)
  -- Result: Multiplies a signed vector, r, with an integer, l. l is
  --         converted to a signed vector of size r'length before
  --         multiplication.
  --```
  function "*" (l: integer; r: signed) return signed;

  --============================================================================
  --
  -- NOTE: If second argument is zero for "/" operator, a severity level
  --       of ERROR is issued.

  --```
  -- Id: A.21
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Divides an unsigned vector, l, by another unsigned vector, r.
  --```
  function "/" (l, r: unsigned) return unsigned;

  --```
  -- Id: A.22
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Divides an signed vector, l, by another signed vector, r.
  --```
  function "/" (L, R: SIGNED) return SIGNED;

  --```
  -- Id: A.23
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Divides an unsigned vector, l, by a nonnegative integer, r.
  --         If no_of_bits(r) > l'length, result is truncated to l'length.
  --```
  function "/" (l: unsigned; r: natural) return unsigned;

  --```
  -- Id: A.24
  -- Result subtype: unsigned(r'length-1 downto 0)
  -- Result: Divides a nonnegative integer, l, by an unsigned vector, r.
  --         If no_of_bits(l) > r'length, result is truncated to r'length.
  --```
  function "/" (l: natural; r: unsigned) return unsigned;

  --```
  -- Id: A.25
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Divides a signed vector, l, by an integer, r.
  --         If no_of_bits(r) > l'length, result is truncated to l'length.
  --```
  function "/" (l: signed; r: integer) return signed;

  --```
  -- Id: A.26
  -- Result subtype: signed(r'length-1 downto 0)
  -- Result: Divides an integer, l, by a signed vector, r.
  --         If no_of_bits(l) > r'length, result is truncated to r'length.
  --```
  function "/" (l: integer; r: signed) return signed;

  --============================================================================
  --
  -- NOTE: If second argument is zero for "rem" operator, a severity level
  --       of ERROR is issued.

  --```
  -- Id: A.27
  -- Result subtype: unsigned(r'length-1 downto 0)
  -- Result: Computes "l rem r" where l and r are unsigned vectors.
  --```
  function "rem" (l, r: unsigned) return unsigned;

  --```
  -- Id: A.28
  -- result subtype: signed(r'length-1 downto 0)
  -- Result: Computes "l rem r" where l and r are signed vectors.
  --```
  function "rem" (l, r: signed) return signed;

  --```
  -- Id: A.29
  -- result subtype: unsigned(l'length-1 downto 0)
  -- Result: Computes "l rem r" where l is an unsigned vector and r is a
  --         nonnegative integer.
  --         If no_of_bits(r) > l'length, result is truncated to l'length.
  --```
  function "rem" (l: unsigned; r: natural) return unsigned;

  --```
  -- Id: A.30
  -- Result subtype: unsigned(r'length-1 downto 0)
  -- Result: Computes "l rem r" where r is an unsigned vector and l is a
  --         nonnegative integer.
  --         If no_of_bits(l) > r'length, result is truncated to r'length.
  --```
  function "rem" (l: natural; r: unsigned) return unsigned;

  --```
  -- Id: A.31
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Computes "l rem r" where l is signed vector and r is an integer.
  --         If no_of_bits(r) > l'length, result is truncated to l'length.
  --```
  function "rem" (l: signed; r: integer) return signed;

  --```
  -- Id: A.32
  -- Result subtype: signed(r'length-1 downto 0)
  -- Result: Computes "l rem r" where r is signed vector and l is an integer.
  --         If no_of_bits(l) > r'length, result is truncated to r'length.
  --```
  function "rem" (l: integer; r: signed) return signed;

  --============================================================================
  --
  -- NOTE: If second argument is zero for "mod" operator, a severity level
  --       of ERROR is issued.

  --```
  -- Id: A.33
  -- Result subtype: unsigned(r'length-1 downto 0)
  -- Result: Computes "l mod r" where l and r are unsigned vectors.
  --```
  function "mod" (l, r: unsigned) return unsigned;

  --```
  -- Id: A.34
  -- Result subtype: signed(r'length-1 downto 0)
  -- Result: Computes "l mod r" where l and r are signed vectors.
  --```
  function "mod" (l, r: signed) return signed;

  --```
  -- Id: A.35
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Computes "l mod r" where l is an unsigned vector and r
  --         is a nonnegative INTEGER.
  --         If no_of_bits(r) > l'length, result is truncated to l'length.
  --```
  function "mod" (l: unsigned; r: natural) return unsigned;

  --```
  -- Id: A.36
  -- Result subtype: unsigned(r'length-1 downto 0)
  -- Result: Computes "l mod r" where r is an unsigned vector and l
  --         is a nonnegative integer.
  --         If no_of_bits(l) > r'length, result is truncated to r'length.
  --```
  function "mod" (l: natural; r: unsigned) return unsigned;

  --```
  -- Id: A.37
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Computes "l mod r" where l is a signed vector and
  --         r is an integer.
  --         If no_of_bits(r) > l'length, result is truncated to l'length.
  --```
  function "mod" (l: signed; r: integer) return signed;

  --```
  -- Id: A.38
  -- Result subtype: signed(r'length-1 downto 0)
  -- Result: Computes "l mod r" where l is an integer and
  --         r is a signed vector.
  --         if no_of_bits(l) > r'length, result is truncated to r'length.
  --```
  function "mod" (l: integer; r: signed) return signed;

  --============================================================================
  -- Comparison Operators
  --============================================================================

  --```
  -- Id: C.1
  -- Result subtype: boolean
  -- Result: Computes "l > r" where l and r are unsigned vectors possibly
  --         of different lengths.
  --```
  function ">" (l, r: unsigned) return boolean;

  --```
  -- Id: C.2
  -- Result subtype: boolean
  -- Result: Computes "l > r" where l and r are signed vectors possibly
  --         of different lengths.
  --```
  function ">" (l, r: signed) return boolean;

  --```
  -- Id: C.3
  -- Result subtype: boolean
  -- Result: Computes "l > r" where l is a nonnegative integer and
  --         r is an unsigned vector.
  --```
  function ">" (l: natural; r: unsigned) return boolean;

  --```
  -- Id: C.4
  -- Result subtype: boolean
  -- Result: Computes "l > r" where l is a integer and
  --         r is a signed vector.
  --```
  function ">" (l: integer; r: signed) return boolean;

  --```
  -- Id: C.5
  -- Result subtype: boolean
  -- Result: Computes "l > r" where l is an unsigned vector and
  --         r is a nonnegative integer.
  --```
  function ">" (l: unsigned; r: natural) return boolean;

  --```
  -- Id: C.6
  -- Result subtype: boolean
  -- Result: Computes "l > r" where l is a signed vector and
  --         r is a integer.
  --```
  function ">" (l: signed; r: integer) return boolean;

  --============================================================================

  --```
  -- Id: C.7
  -- Result subtype: boolean
  -- Result: Computes "l < r" where l and r are unsigned vectors possibly
  --         of different lengths.
  --```
  function "<" (l, r: unsigned) return boolean;

  --```
  -- Id: C.8
  -- Result subtype: boolean
  -- Result: Computes "l < r" where l and r are signed vectors possibly
  --         of different lengths.
  --```
  function "<" (l, r: signed) return boolean;

  --```
  -- Id: C.9
  -- Result subtype: boolean
  -- Result: Computes "l < r" where l is a nonnegative integer and
  --         r is an unsigned vector.
  --```
  function "<" (l: natural; r: unsigned) return boolean;

  --```
  -- Id: C.10
  -- Result subtype: boolean
  -- Result: Computes "l < r" where l is an integer and
  --         r is a signed vector.
  --```
  function "<" (l: integer; r: signed) return boolean;

  --```
  -- Id: C.11
  -- Result subtype: boolean
  -- Result: Computes "l < r" where l is an unsigned vector and
  --         r is a nonnegative integer.
  --```
  function "<" (l: unsigned; r: natural) return boolean;

  --```
  -- Id: C.12
  -- Result subtype: boolean
  -- Result: Computes "l < r" where l is a signed vector and
  --         r is an integer.
  --```
  function "<" (l: signed; r: integer) return boolean;

  --============================================================================

  --```
  -- Id: C.13
  -- Result subtype: boolean
  -- Result: Computes "l <= r" where l and r are unsigned vectors possibly
  --         of different lengths.
  --```
  function "<=" (l, r: unsigned) return boolean;

  --```
  -- Id: C.14
  -- Result subtype: boolean
  -- Result: Computes "l <= r" where l and r are signed vectors possibly
  --         of different lengths.
  --```
  function "<=" (l, r: signed) return boolean;

  --```
  -- Id: C.15
  -- Result subtype: boolean
  -- Result: Computes "l <= r" where l is a nonnegative integer and
  --         r is an unsigned vector.
  --```
  function "<=" (l: natural; r: unsigned) return boolean;

  --```
  -- Id: C.16
  -- Result subtype: boolean
  -- Result: Computes "l <= r" where l is an integer and
  --         r is a signed vector.
  --```
  function "<=" (l: integer; r: signed) return boolean;

  --```
  -- Id: C.17
  -- Result subtype: boolean
  -- Result: Computes "l <= r" where l is an unsigned vector and
  --         r is a nonnegative integer.
  --```
  function "<=" (l: unsigned; r: natural) return boolean;

  --```
  -- Id: C.18
  -- Result subtype: boolean
  -- Result: Computes "l <= r" where l is a signed vector and
  --         r is an integer.
  --```
  function "<=" (l: signed; r: integer) return boolean;

  --============================================================================

  --```
  -- Id: C.19
  -- Result subtype: boolean
  -- Result: Computes "l >= r" where l and r are unsigned vectors possibly
  --         of different lengths.
  --```
  function ">=" (l, r: unsigned) return boolean;

  --```
  -- Id: C.20
  -- Result subtype: boolean
  -- Result: Computes "l >= r" where l and r are signed vectors possibly
  --         of different lengths.
  --```
  function ">=" (l, r: signed) return boolean;

  --```
  -- Id: C.21
  -- Result subtype: boolean
  -- Result: Computes "l >= r" where l is a nonnegative integer and
  --         r is an unsigned vector.
  --```
  function ">=" (l: natural; r: unsigned) return boolean;

  --```
  -- Id: C.22
  -- Result subtype: boolean
  -- Result: Computes "l >= r" where l is an integer and
  --         r is a signed vector.
  --```
  function ">=" (l: integer; r: signed) return boolean;

  --```
  -- Id: C.23
  -- Result subtype: boolean
  -- Result: Computes "l >= r" where l is an unsigned vector and
  --         r is a nonnegative integer.
  --```
  function ">=" (l: unsigned; r: natural) return boolean;

  --```
  -- Id: C.24
  -- Result subtype: boolean
  -- Result: Computes "l >= r" where l is a signed vector and
  --         r is an integer.
  --```
  function ">=" (l: signed; r: integer) return boolean;

  --============================================================================

  --```
  -- Id: C.25
  -- Result subtype: boolean
  -- Result: Computes "l = r" where l and r are unsigned vectors possibly
  --         of different lengths.
  --```
  function "=" (l, r: unsigned) return boolean;

  --```
  -- Id: C.26
  -- Result subtype: boolean
  -- Result: Computes "l = r" where l and r are signed vectors possibly
  --         of different lengths.
  --```
  function "=" (l, r: signed) return boolean;

  --```
  -- Id: C.27
  -- Result subtype: boolean
  -- Result: Computes "l = r" where l is a nonnegative integer and
  --         R is an UNSIGNED vector.
  --```
  function "=" (l: natural; r: unsigned) return boolean;

  --```
  -- Id: C.28
  -- Result subtype: boolean
  -- Result: Computes "l = r" where l is an integer and
  --         R is a SIGNED vector.
  --```
  function "=" (l: integer; r: signed) return boolean;

  --```
  -- Id: C.29
  -- Result subtype: boolean
  -- Result: Computes "l = r" where l is an unsigned vector and
  --         r is a nonnegative integer.
  --```
  function "=" (l: unsigned; r: natural) return boolean;

  --```
  -- Id: C.30
  -- Result subtype: boolean
  -- Result: Computes "l = r" where l is a signed vector and
  --         r is an integer.
  --```
  function "=" (l: signed; r: integer) return boolean;

  --============================================================================

  --```
  -- Id: C.31
  -- Result: Computes "l /= r" where l and r are unsigned vectors possibly
  --         of different lengths.
  -- result subtype: boolean
  --```
  function "/=" (l, r: unsigned) return boolean;

  --```
  -- Id: C.32
  -- Result subtype: boolean
  -- Result: Computes "l /= r" where l and r are signed vectors possibly
  --         of different lengths.
  --```
  function "/=" (l, r: signed) return boolean;

  --```
  -- Id: C.33
  -- Result subtype: boolean
  -- Result: Computes "l /= r" where l is a nonnegative integer and
  --         r is an unsigned vector.
  --```
  function "/=" (l: natural; r: unsigned) return boolean;

  --```
  -- Id: C.34
  -- Result subtype: boolean
  -- Result: Computes "l /= r" where l is an integer and
  --         r is a signed vector.
  --```
  function "/=" (l: integer; r: signed) return boolean;

  --```
  -- Id: C.35
  -- Result subtype: boolean
  -- Result: Computes "l /= r" where l is an unsigned vector and
  --         r is a nonnegative integer.
  --```
  function "/=" (l: unsigned; r: natural) return boolean;

  --```
  -- Id: C.36
  -- Result subtype: boolean
  -- Result: Computes "l /= r" where l is a signed vector and
  --         r is an integer.
  --```
  function "/=" (l: signed; r: integer) return boolean;

  --============================================================================
  -- Shift and Rotate Functions
  --============================================================================

  --```
  -- Id: S.1
  -- Result subtype: unsigned(arg'length-1 downto 0)
  -- Result: Performs a shift-left on an unsigned vector count times.
  --         The vacated positions are filled with '0'.
  --         The count leftmost elements are lost.
  --```
  function shift_left (arg: unsigned; count: natural) return unsigned;

  --```
  -- Id: S.2
  -- Result subtype: unsigned(arg'length-1 downto 0)
  -- Result: Performs a shift-right on an unsigned vector count times.
  --         The vacated positions are filled with '0'.
  --         The count rightmost elements are lost.
  --```
  function shift_right (arg: unsigned; count: natural) return unsigned;

  --```
  -- Id: S.3
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: Performs a shift-left on a signed vector count times.
  --         The vacated positions are filled with '0'.
  --         The count leftmost elements are lost.
  --```
  function shift_left (arg: signed; count: natural) return signed;

  --```
  -- Id: S.4
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: Performs a shift-right on a signed vector count times.
  --         The vacated positions are filled with the leftmost
  --         element, arg'left. the count rightmost elements are lost.
  --```
  function shift_right (arg: signed; count: natural) return signed;

  --============================================================================

  --```
  -- Id: S.5
  -- Result subtype: unsigned(arg'length-1 downto 0)
  -- Result: Performs a rotate-left of an unsigned vector count times.
  --```
  function rotate_left (arg: unsigned; count: natural) return unsigned;

  --```
  -- Id: S.6
  -- Result subtype: unsigned(arg'length-1 downto 0)
  -- Result: Performs a rotate-right of an unsigned vector count times.
  --```
  function rotate_right (arg: unsigned; count: natural) return unsigned;

  --```
  -- Id: S.7
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: Performs a logical rotate-left of a signed
  --         vector count times.
  --```
  function rotate_left (arg: signed; count: natural) return signed;

  --```
  -- Id: S.8
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: Performs a logical rotate-right of a signed
  --         vector count times.
  --```
  function rotate_right (arg: signed; count: natural) return signed;

  --============================================================================

  --============================================================================

  --```
  ------------------------------------------------------------------------------
  --   Note: Function S.9 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.9
  -- Result subtype: unsigned(arg'length-1 downto 0)
  -- Result: shift_left(arg, count)
  --```
  function "sll" (arg: unsigned; count: integer) return unsigned;

  --```
  ------------------------------------------------------------------------------
  -- Note: Function S.10 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.10
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: shift_left(arg, count)
  --```
  function "sll" (arg: signed; count: integer) return signed;

  --```
  ------------------------------------------------------------------------------
  --   Note: Function S.11 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE StdL 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.11
  -- Result subtype: unsigned(arg'length-1 downto 0)
  -- Result: shift_right(arg, count)
  --```
  function "srl" (arg: unsigned; count: integer) return unsigned;

  --```
  ------------------------------------------------------------------------------
  --   Note: Function S.12 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.12
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: signed(shift_right(unsigned(arg), count))
  --```
  function "srl" (arg: signed; count: integer) return signed;

  --```
  ------------------------------------------------------------------------------
  --   Note: Function S.13 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.13
  -- Result subtype: unsigned(arg'length-1 downto 0)
  -- Result: rotate_left(arg, count)
  --```
  function "rol" (arg: unsigned; count: integer) return unsigned;

  --```
  ------------------------------------------------------------------------------
  --   Note: Function S.14 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.14
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: rotate_left(arg, count)
  --```
  function "rol" (arg: signed; count: integer) return signed;

  --```
  ------------------------------------------------------------------------------
  -- Note: Function S.15 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.15
  -- Result subtype: unsigned(arg'length-1 downto 0)
  -- Result: rotate_right(arg, count)
  --```
  function "ror" (arg: unsigned; count: integer) return unsigned;

  --```
  ------------------------------------------------------------------------------
  --   Note: Function S.16 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.16
  -- Result subtype: signed(arg'length-1 downto 0)
  -- Result: rotate_right(arg, count)
  --```
  function "ror" (arg: signed; count: integer) return signed;

  --============================================================================
  --   RESIZE Functions
  --============================================================================

  --```
  -- Id: R.1
  -- Result subtype: signed(new_size-1 downto 0)
  -- Result: Resizes the signed vector arg to the specified size.
  --         To create a larger vector, the new [leftmost] bit positions
  --         are filled with the sign bit (arg'left). When truncating,
  --         the sign bit is retained along with the rightmost part.
  --```
  function resize (arg: signed; new_size: natural) return signed;

  --```
  -- Id: R.2
  -- Result subtype: unsigned(new_size-1 downto 0)
  -- Result: Resizes the signed vector arg to the specified size.
  --         To create a larger vector, the new [leftmost] bit positions
  --         are filled with '0'. When truncating, the leftmost bits
  --         are dropped.
  --```
  function resize (arg: unsigned; new_size: natural) return unsigned;

  --============================================================================
  -- Conversion Functions
  --============================================================================

  --```
  -- Id: D.1
  -- Result subtype: natural. Value cannot be negative since parameter is an
  --             unsigned vector.
  -- result: converts the unsigned vector to an integer.
  --```
  function to_integer (arg: unsigned) return natural;

  --```
  -- Id: D.2
  -- Result subtype: integer
  -- Result: Converts a signed vector to an integer.
  --```
  function to_integer (arg: signed) return integer;

  --```
  -- Id: D.3
  -- Result subtype: unsigned(size-1 downto 0)
  -- Result: Converts a nonnegative integer to an unsigned vector with
  --         the specified size.
  --```
  function to_unsigned (arg, size: natural) return unsigned;

  --```
  -- Id: D.4
  -- Result subtype: signed(size-1 downto 0)
  -- Result: Converts an integer to a signed vector of the specified size.
  --```
  function to_signed (arg: integer; size: natural) return signed;

  --============================================================================
  -- Logical Operators
  --============================================================================

  --```
  -- Id: L.1
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Termwise inversion
  --```
  function "not" (l: unsigned) return unsigned;

  --```
  -- Id: L.2
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Vector and operation
  --```
  function "and" (l, r: unsigned) return unsigned;

  --```
  -- Id: L.3
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Vector or operation
  --```
  function "or" (l, r: unsigned) return unsigned;

  --```
  -- Id: L.4
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Vector nand operation
  --```
  function "nand" (l, r: unsigned) return unsigned;

  --```
  -- Id: L.5
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Vector nor operation
  --```
  function "nor" (l, r: unsigned) return unsigned;

  --```
  -- Id: L.6
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Vector xor operation
  --```
  function "xor" (l, r: unsigned) return unsigned;

  --```
  -- ---------------------------------------------------------------------------
  -- Note: Function L.7 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  -- ---------------------------------------------------------------------------
  -- Id: L.7
  -- Result subtype: unsigned(l'length-1 downto 0)
  -- Result: Vector xnor operation
  --```
  function "xnor" (l, r: unsigned) return unsigned;

  --```
  -- Id: L.8
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Termwise inversion
  --```
  function "not" (l: signed) return signed;

  --```
  -- Id: L.9
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Vector and operation
  --```
  function "and" (l, r: signed) return signed;

  --```
  -- Id: L.10
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Vector or operation
  --```
  function "or" (l, r: signed) return signed;

  --```
  -- Id: L.11
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Vector nand operation
  --```
  function "nand" (l, r: signed) return signed;

  --```
  -- Id: L.12
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Vector nor operation
  --```
  function "nor" (l, r: signed) return signed;

  --```
  -- Id: L.13
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Vector xor operation
  --```
  function "xor" (l, r: signed) return signed;

  --```
  -- ---------------------------------------------------------------------------
  -- Note: Function L.14 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  -- ---------------------------------------------------------------------------
  -- Id: L.14
  -- Result subtype: signed(l'length-1 downto 0)
  -- Result: Vector xnor operation
  --```
  function "xnor" (l, r: signed) return signed;

  --============================================================================
  -- Match Functions
  --============================================================================

  --```
  -- Id: M.1
  -- Result subtype: boolean
  -- Result: terms compared per std_logic_1164 intent
  --```
  function std_match (l, r: std_ulogic) return boolean;

  --```
  -- Id: M.2
  -- Result subtype: boolean
  -- Result: terms compared per std_logic_1164 intent
  --```
  function std_match (l, r: unsigned) return boolean;

  --```
  -- Id: M.3
  -- Result subtype: boolean
  -- Result: terms compared per std_logic_1164 intent
  --```
  function std_match (l, r: signed) return boolean;

  --```
  -- Id: M.4
  -- Result subtype: boolean
  -- Result: terms compared per std_logic_1164 intent
  --```
  function std_match (l, r: std_logic_vector) return boolean;

  --```
  -- Id: M.5
  -- Result subtype: boolean
  -- Result: terms compared per std_logic_1164 intent
  --```
  function std_match (l, r: std_ulogic_vector) return boolean;

  --============================================================================
  -- Translation Functions
  --============================================================================

  --```
  -- Id: T.1
  -- Result subtype: unsigned(s'range)
  -- Result: Termwise, 'h' is translated to '1', and 'l' is translated
  --         to '0'. If a value other than '0'|'1'|'h'|'l' is found,
  --         the array is set to (others => xmap), and a warning is
  --         issued.
  --```
  function to_01 (s: unsigned; xmap: std_logic := '0') return unsigned;

  --```
  -- Id: T.2
  -- Result subtype: signed(s'range)
  -- Result: Termwise, 'h' is translated to '1', and 'l' is translated
  --         to '0'. if a value other than '0'|'1'|'h'|'l' is found,
  --         the array is set to (others => xmap), and a warning is
  --         issued.
  --```
  function to_01 (s: signed; xmap: std_logic := '0') return signed;

end package numeric_std;
