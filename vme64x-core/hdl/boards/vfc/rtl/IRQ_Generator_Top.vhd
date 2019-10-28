--______________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________
-- File:                          IRQ_Generator_Top.vhd
--______________________________________________________________________
-- Description: This block implement a IRQ_Generator both WB 32 or 64 
-- data transfer bus width compatible.
-- Block diagram:
--                          ____________________________________________
--                         |                                            |
--                         |                                            |
--                         |  __________            ______________      |
--                         | |   WB     |          | INT_COUNT    |     |
--                         | | LOGIC    |          |______________|     |
--                    W    | |          |           ______________      |
--                    B    | |          |          |  FREQ        |     |
--                         | |          |          |______________|     |
--                    S    | |          |           ______________      |
--                    I    | |          |          |              |     |
--                    G    | |          |          |              |     |
--                    N    | |          |          |     IRQ      |     |
--                    A    | |          |          |Generator.vhd |     |
--                    L    | |          |          |              |     |
--                    S    | |          |          |              |     |
--                         | |          |          |              |     |
--                         | |__________|          |              |     |
--                         |                       |              |     |
--                         |                       |______________|     |
--                         |                                            |
--                         |                                            |
--                         |____________________________________________|
--
-- INT_COUNT --> address: 0x000
-- FREQ      --> address: 0x004
-- IRQ Generator: this component sends an Interrupt request (pulse) to the 
-- IRQ Controller --> Necessary to test the board.
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
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.numeric_std.all;
  use work.vme64x_pack.all;
--===========================================================================
-- Entity declaration
--=========================================================================== 
entity IRQ_Generator_Top is
generic(g_wb_data_width : integer := c_width;
	     g_wb_addr_width : integer := c_addr_width
	    );
    port ( -- IRQ_Generator 
           clk_i     : in   std_logic;
           rst_i     : in   std_logic;
           Int_Ack_i : in   std_logic;
			  Int_Req_o : out  std_logic;
			  -- wb slave side
           cyc_i     : in   std_logic;
           stb_i     : in   std_logic;
           adr_i     : in   std_logic_vector (g_wb_addr_width - 1 downto 0);
           sel_i     : in   std_logic_vector (f_div8(g_wb_data_width) - 1 downto 0);
           we_i      : in   std_logic;
           dat_i     : in   std_logic_vector (g_wb_data_width - 1 downto 0);
           ack_o     : out  std_logic;
           err_o     : out  std_logic;
           rty_o     : out  std_logic;
           stall_o   : out  std_logic;
           dat_o     : out  std_logic_vector (g_wb_data_width - 1 downto 0)
			  );
end IRQ_Generator_Top;
--===========================================================================
-- Architecture declaration
--===========================================================================
architecture Behavioral of IRQ_Generator_Top is

signal s_rst           : std_logic;
signal s_INT_COUNT     : std_logic_vector(31 downto 0);
signal s_FREQ          : std_logic_vector(31 downto 0); 
signal s_Int_Count_o1  : std_logic_vector(31 downto 0);
signal s_Int_Count_o   : std_logic_vector(31 downto 0);
signal s_Read_IntCount : std_logic;
signal s_data          : std_logic_vector(31 downto 0);
signal s_data_f        : std_logic_vector(31 downto 0);
signal s_data_o        : std_logic_vector(g_wb_data_width - 1 downto 0);
signal s_IntCount_sel  : std_logic;
signal s_Freq_sel      : std_logic;
signal s_wea           : std_logic;
signal s_stall         : std_logic;
signal s_ack           : std_logic;
signal s_en_Freq       : std_logic;

component IRQ_generator is
	port(
		clk_i          : in  std_logic;
		reset          : in  std_logic;
		Freq           : in  std_logic_vector(31 downto 0);
		Int_Count_i    : in  std_logic_vector(31 downto 0);
		Read_Int_Count : in  std_logic;
		INT_ack        : in  std_logic;          
		IRQ_o          : out std_logic;
		Int_Count_o    : out std_logic_vector(31 downto 0)
		);
end component IRQ_generator;
--===========================================================================
-- Architecture begin
--===========================================================================
begin

s_rst <= not(rst_i);

s_wea <= we_i and cyc_i and stb_i and (not s_stall);

s_Int_Count_o1  <= s_data when (s_IntCount_sel = '1' and s_wea = '1') 
					  else s_Int_Count_o;
					  
s_Read_IntCount <= '1' when s_IntCount_sel = '1' and  we_i = '0' and s_ack = '1' 
                 else '0';
					  
s_en_Freq       <= '1' when (s_Freq_sel = '1' and s_wea = '1') else '0';

------------------------------------------------------------------------------------						 
-- The INT_COUNT register and the INT_RATE register should be write/read both when
-- the WB data bus is 32 or 64 bit width, so the following processes have been
-- added: 

gen64 : if (g_wb_data_width = 64) generate
        s_data   <= dat_i(63 downto 32);
		  s_data_f <= dat_i(31 downto 0);
		  s_data_o <= s_INT_COUNT & s_FREQ;
		  s_IntCount_sel <= '1'   when sel_i = "11110000" and unsigned(adr_i) = 0 else	
                          '0'	;
		  s_Freq_sel     <= '1'   when sel_i = "00001111" and unsigned(adr_i) = 0 else
		                    '0';						  				  
end generate gen64;

gen32 : if (g_wb_data_width = 32) generate
        s_data   <= dat_i;
		  s_data_f <= dat_i;
		  s_data_o <= s_INT_COUNT when s_IntCount_sel = '1' else
		              s_FREQ      when s_Freq_sel = '1'     else
						  (others => '0');
		  s_IntCount_sel <= '1'   when unsigned(adr_i) = 0	 else	
                          '0'	;	  
		  s_Freq_sel     <= '1'   when unsigned(adr_i) = 1  else
		                    '0';
end generate gen32;

---------------------------------------------------------------
-- this process generate the ack; PIPELINED mode!
process(clk_i)
  begin
    if(rising_edge(clk_i)) then
      if(s_rst = '0') then
          s_ack <= '0';      
      else
          s_ack <= cyc_i and stb_i and (not s_stall) ;
      end if;
    end if;
end process;
----------------------------------------------------------------
-- stall handler
process(clk_i)
  begin
   if(rising_edge(clk_i)) then
      if(s_rst = '0') or s_ack = '1' then
           s_stall <= '1';
      elsif cyc_i = '1' then
		     s_stall <= '0';  
		end if; 
   end if;       		
end process;
-- Reg INT_COUNT
INT_COUNT : Reg32bit
    port map(
      reset  => s_rst,
		enable => '1',
		di     => s_Int_Count_o1,
      do     => s_INT_COUNT,
      clk_i  => clk_i
      );		
		
-- Reg FREQ
FREQ : Reg32bit
    port map(
      reset  => s_rst,
		enable => s_en_Freq,
		di     => s_data_f,
      do     => s_FREQ,
      clk_i  => clk_i
      );	

-- IRQ Generator		
Inst_IRQ_generator: IRQ_generator port map(
		clk_i          => clk_i,
		reset          => s_rst,
		Freq           => s_FREQ,
		Int_Count_i    => s_INT_COUNT,
		Read_Int_Count => s_Read_IntCount,
		INT_ack        => Int_Ack_i,
		IRQ_o          => Int_Req_o,
		Int_Count_o    => s_Int_Count_o
	   );
------------------------------------------------------------------
stall_o  <= s_stall;
ack_o    <= s_ack;
err_o    <= '0';
rty_o    <= '0';
dat_o    <= s_data_o;

end Behavioral;
--===========================================================================
-- Architecture end
--===========================================================================
