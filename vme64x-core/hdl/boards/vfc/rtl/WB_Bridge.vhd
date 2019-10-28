--______________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________
-- File:                          WB_Bridge.vhd
--_____________________________________________________________________________
-- Description: Insert this block between the vme64x core and your WB Application 
-- if you want use the Interrupter.
-- Indeed this component acts as a bridge between the vme64x core and your WB 
-- Application, and implements the IRQ Generator that sends the Interrupt request
-- to the IRQ_Controller located in the vme64x core.
-- Remember that:
-- INT_COUNT register  --> 0x00   
-- INT_RATE  register  --> 0x04
-- These two address (byte address) are reserved; don't use these to access 
-- your WB memory!
--
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
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.vme64x_pack.all;
--===========================================================================
-- Entity declaration
--===========================================================================
entity WB_Bridge is
generic(g_wb_data_width : integer := c_width;
	     g_wb_addr_width : integer := c_addr_width
	    );
    Port ( clk_i     : in   std_logic;
           rst_i     : in   std_logic;
           Int_Ack_i : in   std_logic;
           Int_Req_o : out  std_logic;
           cyc_i     : in   std_logic;
           stb_i     : in   std_logic;
           adr_i     : in   std_logic_vector (g_wb_addr_width - 1 downto 0);
           dat_i     : in   std_logic_vector (g_wb_data_width - 1 downto 0);
           sel_i     : in   std_logic_vector (f_div8(g_wb_data_width) - 1 downto 0);
           we_i      : in   std_logic;
           ack_o     : out  std_logic;
           err_o     : out  std_logic;
           rty_o     : out  std_logic;
			  stall_o   : out  std_logic;
           dat_o     : out  std_logic_vector (g_wb_data_width - 1 downto 0);
           m_cyc_o   : out  std_logic;
           m_stb_o   : out  std_logic;
           m_adr_o   : out  std_logic_vector (g_wb_addr_width - 1 downto 0);
           m_dat_o   : out  std_logic_vector (g_wb_data_width - 1 downto 0);
           m_sel_o   : out  std_logic_vector (f_div8(g_wb_data_width) - 1 downto 0);
           m_we_o    : out  std_logic;
           m_ack_i   : in   std_logic;
           m_err_i   : in   std_logic;
			  m_stall_i : in   std_logic;
           m_rty_i   : in   std_logic;
           m_dat_i   : in   std_logic_vector (g_wb_data_width - 1 downto 0));
end WB_Bridge;
--===========================================================================
-- Architecture declaration
--===========================================================================
architecture Behavioral of WB_Bridge is
signal s_cyc        : std_logic;
signal s_m_cyc      : std_logic;
signal s_stb        : std_logic;
signal s_m_stb      : std_logic;
signal s_WbAppl     : std_logic;
signal s_IRQGen     : std_logic;
signal s_ack_gen    : std_logic;
signal s_err_gen    : std_logic;
signal s_rty_gen    : std_logic;
signal s_stall_gen  : std_logic;
signal s_data_o_gen : std_logic_vector(g_wb_data_width - 1 downto 0);

	component IRQ_Generator_Top is
	generic(g_wb_data_width : integer := c_width;
	        g_wb_addr_width : integer := c_addr_width
	    );
	port(
		clk_i     : in  std_logic;
		rst_i     : in  std_logic;
		Int_Ack_i : in  std_logic;
		cyc_i     : in  std_logic;
		stb_i     : in  std_logic;
		adr_i     : in  std_logic_vector(g_wb_addr_width - 1 downto 0);
		sel_i     : in  std_logic_vector(f_div8(g_wb_data_width) - 1 downto 0);
		we_i      : in  std_logic;
		dat_i     : in  std_logic_vector(g_wb_data_width - 1 downto 0);          
		Int_Req_o : out std_logic;
		ack_o     : out std_logic;
		err_o     : out std_logic;
		rty_o     : out std_logic;
		stall_o   : out std_logic;
		dat_o     : out std_logic_vector(g_wb_data_width - 1 downto 0)
		);
	end component IRQ_Generator_Top;
--===========================================================================
-- Architecture begin
--===========================================================================
begin
---------------------------------------------------------------------
-- check if the IRQ Generator is addressed (0x00 or 0x04).
-- if not s_WbAppl is '1' and the component work as a bridge 
-- between the vme64x core and the Wb Application 
genIRQGen64 : if (g_wb_data_width = 64) generate
           s_IRQGen <= '1' when (unsigned(adr_i) = 0) else '0';
end generate genIRQGen64;

genIRQGen32 : if (g_wb_data_width = 32) generate
           s_IRQGen <= '1' when unsigned(adr_i) = 0  or
							           unsigned(adr_i) = 1 else '0';
end generate genIRQGen32;

s_WbAppl <= not s_IRQGen;
---------------------------------------------------------------------
s_cyc   <= cyc_i and s_IRQGen;
s_stb   <= stb_i and s_IRQGen;
s_m_cyc <= cyc_i and s_WbAppl;
s_m_stb <= stb_i and s_WbAppl;
----------------------------------------------------------------------
ack_o <= s_ack_gen xor m_ack_i;
err_o <= s_err_gen xor m_err_i;
rty_o <= s_rty_gen xor m_rty_i;
----------------------------------------------------------------------
stall_o <= m_stall_i when s_WbAppl ='1' else 
            s_stall_gen; 
dat_o	  <= m_dat_i when s_WbAppl ='1' else 
            s_data_o_gen;
----------------------------------------------------------------------
m_cyc_o <= s_m_cyc;
m_stb_o <= s_m_stb;
m_adr_o <= adr_i;
m_dat_o <= dat_i;
m_sel_o <= sel_i;
m_we_o  <= we_i;
----------------------------------------------------------------------
Inst_IRQ_Generator_Top: IRQ_Generator_Top 
generic map(g_wb_data_width => g_wb_data_width,
	         g_wb_addr_width => g_wb_addr_width
	        )
port map(
		clk_i     => clk_i,
		rst_i     => rst_i,
		Int_Ack_i => Int_Ack_i,
		Int_Req_o => Int_Req_o,
		cyc_i     => s_cyc,
		stb_i     => s_stb,
		adr_i     => adr_i,
		sel_i     => sel_i,
		we_i      => we_i,
		dat_i     => dat_i,
		ack_o     => s_ack_gen,
		err_o     => s_err_gen,
		rty_o     => s_rty_gen,
		stall_o   => s_stall_gen,
		dat_o     => s_data_o_gen
	);

end Behavioral;
--===========================================================================
-- Architecture end
--===========================================================================
