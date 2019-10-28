--______________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________
-- File:                            spram.vhd
--______________________________________________________________________________

-- Description: single port ram with byte granularity
--______________________________________________________________________________
-- Authors:                                   
--               Pablo Alvarez Sanchez (Pablo.Alvarez.Sanchez@cern.ch)                             
--               Davide Pedretti       (Davide.Pedretti@cern.ch)  
-- Date         11/2012                                                                           
-- Version      v0.03  
--______________________________________________________________________________
--                               GNU LESSER GENERAL PUBLIC LICENSE                                
--                              ------------------------------------    
-- Copyright (c) 2009 - 2011 CERN                          
-- This source file is free software; you can redistribute it and/or modify it under the terms of 
-- the GNU Lesser General Public License as published by the Free Software Foundation; either     
-- version 2.1 of the License, or (at your option) any later version.                             
-- This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;       
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     
-- See the GNU Lesser General Public License for more details.                                    
-- You should have received a copy of the GNU Lesser General Public License along with this       
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html                     
---------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

library work;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
--===========================================================================
-- Entity declaration
--===========================================================================
entity spram is
generic (
    -- standard parameters
    g_data_width : integer := c_wishbone_data_width;
    g_size       : integer := c_SIZE;
    -- if true, the user can write individual bytes by using bwe_i
    g_with_byte_enable : boolean := true;                 --not used
    -- RAM read-on-write conflict resolution. Can be "read_first" (read-then-write)
    -- or "write_first" (write-then-read)
    g_addr_conflict_resolution : string := "read_first";  -- not used
    g_init_file                : string := ""             -- not used
    );
port (
    clk_i   : in std_logic;             -- clock input
    -- byte write enable
    bwe_i : in std_logic_vector(((g_data_width)/8)-1 downto 0);
    -- address input
    a_i : in std_logic_vector(f_log2_size(g_size)-1 downto 0);
    -- data input
    d_i : in std_logic_vector(g_data_width-1 downto 0);
    -- data output
    q_o : out std_logic_vector(g_data_width-1 downto 0)
    );
end spram;
--===========================================================================
-- Architecture declaration
--===========================================================================
architecture Behavioral of spram is

constant c_num_bytes : integer := (g_data_width)/8;
--===========================================================================
-- Architecture begin
--===========================================================================
begin
  spram: for i in 0 to c_num_bytes-1 generate
        ram8bits : entity work.ram_8bits
             generic map(size => g_size)
             port map(addr  => a_i, 
                      di    => d_i(8*i+7 downto 8*i),
							 do    => q_o(8*i+7 downto 8*i),
                      we    => bwe_i(i),
                      clk_i => clk_i
                      );							 
  end generate;

end Behavioral;
--===========================================================================
-- Architecture end
--===========================================================================
