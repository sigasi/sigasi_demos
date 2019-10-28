--______________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________
-- File:                          xwb_ram.vhd
--______________________________________________________________________
-- Description: This block acts as WB Slave to test the vme64x interface
-- Block diagram:
--                          ______________________
--                         |                      |
--                         |                      |
--                         |     __________       |
--                         |    |   WB     |      |
--                         |    | LOGIC    |      |
--                    W    |    |          |      |
--                    B    |    |          |      |
--                         |    |__________|      |
--                    S    |   ______________     |
--                    I    |  |              |    |
--                    G    |  |              |    |
--                    N    |  |     RAM      |    |
--                    A    |  | 64-bit port  |    |
--                    L    |  |     Byte     |    |
--                    S    |  | Granularity  |    |
--                         |  |              |    |
--                         |  |              |    |
--                         |  |              |    |
--                         |  |______________|    |
--                         |                      |
--                         |                      |
--                         |______________________|
--
-- The RAM is a single port ram, 64 bit wide with byte granularity.
-- WB LOGIC: some processes add to generate the acknowledge and 
-- the enable signals.
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
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
--===========================================================================
-- Entity declaration
--===========================================================================
entity xwb_ram is
  generic(
    g_size                  : integer := c_SIZE;  
    g_init_file             : string  := "";
    g_must_have_init_file   : boolean := false;
    g_slave1_interface_mode : t_wishbone_interface_mode;
    g_slave1_granularity    : t_wishbone_address_granularity
    );
  port(
    clk_sys_i               : in  std_logic;
    slave1_i                : in  t_wishbone_slave_in;
    slave1_o                : out t_wishbone_slave_out
    );
end xwb_ram;
--===========================================================================
-- Architecture declaration
--===========================================================================
architecture struct of xwb_ram is

  function f_zeros(size : integer)
    return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(0, size));
  end f_zeros;


  signal s_wea      : std_logic;
  signal s_bwea     : std_logic_vector(c_wishbone_data_width/8-1 downto 0);    
  signal slave1_out : t_wishbone_slave_out;
  signal s_cyc      : std_logic;
  signal s_stb      : std_logic;
  signal s_rst      : std_logic;
  signal s_stall    : std_logic;
--===========================================================================
-- Architecture begin
--===========================================================================
begin

-- RAM memory
  U_DPRAM : entity work.spram
    generic map(
      -- standard parameters
      g_data_width               => c_wishbone_data_width,
      g_size                     => g_size,
      g_with_byte_enable         =>  true,
      g_init_file                => "",
      g_addr_conflict_resolution => "read_first"
      )
    port map(
      clk_i   => clk_sys_i,
      bwe_i   => s_bwea,
      a_i     => slave1_i.adr(f_log2_size(g_size)-1 downto 0),                                 
      d_i     => slave1_i.dat,                                  
      q_o     => slave1_o.dat	                                 
	 );

-- WB Logic:	 
  s_bwea <= slave1_i.sel when s_wea = '1' else f_zeros(c_wishbone_data_width/8);    
  s_wea  <= slave1_i.we and slave1_i.cyc and slave1_i.stb and (not s_stall);               
  
  process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
        if(slave1_out.ack = '1' and g_slave1_interface_mode = CLASSIC) then
          slave1_out.ack <= '0';
        else
          slave1_out.ack <= slave1_i.cyc and slave1_i.stb and (not s_stall) ;
        end if;
    end if;
  end process;
  
  s_stall        <= '0';
  slave1_o.stall <= s_stall;
  slave1_o.err   <= '0';   --slave1_out.ack;
  slave1_o.rty   <= '0';       -- '0'; 
  slave1_o.ack   <= slave1_out.ack;
  
end struct;
--===========================================================================
-- Architecture end
--===========================================================================
