----------------------------------------------------------------------------
--
-- Copyright (c) 1990, 1991, 1992 by Synopsys, Inc.  All rights reserved.
-- 
-- This source file may be used and distributed without restriction 
-- provided that this copyright statement is not removed from the file 
-- and that any derivative work contains this copyright notice.
--
--      Package name: STD_LOGIC_TEXTIO
--
--      Purpose: This package overloads the standard TEXTIO procedures
--               READ and WRITE.
--
--      Author: CRC, TS
--
----------------------------------------------------------------------------

use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;

package std_logic_textio is
        -- Read and Write procedures for STD_ULOGIC and STD_ULOGIC_VECTOR
        
        procedure READ(L:inout LINE; VALUE:out STD_ULOGIC);
        procedure READ(L:inout LINE; VALUE:out STD_ULOGIC; GOOD: out BOOLEAN);
        procedure READ(L:inout LINE; VALUE:out STD_ULOGIC_VECTOR);
        procedure READ(L:inout LINE; VALUE:out STD_ULOGIC_VECTOR; GOOD: out BOOLEAN);
        procedure WRITE(L:inout LINE; VALUE:in STD_ULOGIC;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);
        procedure WRITE(L:inout LINE; VALUE:in STD_ULOGIC_VECTOR;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);

        -- Read and Write procedures for STD_LOGIC_VECTOR
        
        procedure READ(L:inout LINE; VALUE:out STD_LOGIC_VECTOR);
        procedure READ(L:inout LINE; VALUE:out STD_LOGIC_VECTOR; GOOD: out BOOLEAN);
        procedure WRITE(L:inout LINE; VALUE:in STD_LOGIC_VECTOR;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);

        --
        -- Read and Write procedures for Hex and Octal values.
        -- The values appear in the file as a series of characters
        -- between 0-F (Hex), or 0-7 (Octal) respectively.
        --

        -- Hex
        
        procedure HREAD(L:inout LINE; VALUE:out STD_ULOGIC_VECTOR);
        procedure HREAD(L:inout LINE; VALUE:out STD_ULOGIC_VECTOR; GOOD: out BOOLEAN);
        procedure HWRITE(L:inout LINE; VALUE:in STD_ULOGIC_VECTOR;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);
        procedure HREAD(L:inout LINE; VALUE:out STD_LOGIC_VECTOR);
        procedure HREAD(L:inout LINE; VALUE:out STD_LOGIC_VECTOR; GOOD: out BOOLEAN);
        procedure HWRITE(L:inout LINE; VALUE:in STD_LOGIC_VECTOR;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);

        -- Octal
        
        procedure OREAD(L:inout LINE; VALUE:out STD_ULOGIC_VECTOR);
        procedure OREAD(L:inout LINE; VALUE:out STD_ULOGIC_VECTOR; GOOD: out BOOLEAN);
        procedure OWRITE(L:inout LINE; VALUE:in STD_ULOGIC_VECTOR;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);
        procedure OREAD(L:inout LINE; VALUE:out STD_LOGIC_VECTOR);
        procedure OREAD(L:inout LINE; VALUE:out STD_LOGIC_VECTOR; GOOD: out BOOLEAN);
        procedure OWRITE(L:inout LINE; VALUE:in STD_LOGIC_VECTOR;
                        JUSTIFIED:in SIDE := RIGHT; FIELD:in WIDTH := 0);

        
end std_logic_textio;
