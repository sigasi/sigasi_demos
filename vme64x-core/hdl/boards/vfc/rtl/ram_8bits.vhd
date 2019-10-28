--______________________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________________
-- File:                          ram_8bits.vhd
--______________________________________________________________________________
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
----------------------------------------------------------------------------------------------               
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
library work;
use work.genram_pkg.all;
--===========================================================================
-- Entity declaration
--===========================================================================
entity ram_8bits is
  generic (
    size         : integer := c_SIZE
	 );
    Port ( addr  : in   std_logic_vector (f_log2_size(size)-1 downto 0);
           di    : in   std_logic_vector (7 downto 0);
           do    : out  std_logic_vector (7 downto 0);
           we    : in   std_logic;
           clk_i : in   std_logic);
end ram_8bits;
--===========================================================================
-- Architecture declaration
--===========================================================================
architecture Behavioral of ram_8bits is
type t_ram_type is array(size-1 downto 0) of std_logic_vector(7 downto 0);
signal sram  : t_ram_type;
--===========================================================================
-- Architecture begin
--===========================================================================
begin
process (clk_i)
    begin
        if (clk_i'event and clk_i = '1') then
            if (we = '1') then
                sram(conv_integer(unsigned(addr))) <= di;
            end if;
				do <= sram(conv_integer(unsigned(addr)));
        end if;
    end process;
end Behavioral;
--===========================================================================
-- Architecture end
--===========================================================================
