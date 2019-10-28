--______________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________
-- File:                          IRQ_generator.vhd
--_____________________________________________________________________________
-- Description: This block generates an interrupt request; the interrupt request 
-- is a pulse on the WB bus slave1_o.int line. The Interrupt frequency is setted 
-- by the VME Master writing the FREQ register:
--  Values refer to a 20 MHz clock:
--    | FREQ values:  |   Time between 2 consecutive interrupts: | 
--    | 0x00000000    |    NO interrupt (default value)          |
--    | 0x08000000    |    Interrupt any 6,72 s                  |
--    | 0x04000000    |    Interrupt any 3,36 s                  |
--    | 0x02000000    |    Interrupt any 1,67 s                  |
--    | 0x01000000    |    Interrupt any 0,83 s                  |
--    | 0x00800000    |    Interrupt any 0,42 s                  |
--    | 0x00400000    |    Interrupt any 0,20 s                  |
--    | 0x00200000    |    Interrupt any 0,10 s                  |
--    | 0x00100000    |    Interrupt any 0,05 s                  |
--    | 0x00080000    |    Interrupt any 26 ms                   |
--    | 0x00040000    |    Interrupt any 13 ms                   |
--    | 0x00020000    |    Interrupt any 7 ms                    |
--    | 0x00010000    |    Interrupt any 3 ms                    |
--    | 0x00008000    |    Interrupt any 1,6 ms                  |
--    | 0x00004000    |    Interrupt any 0,8 ms                  |
--    | 0x00002000    |    Interrupt any 0,4 ms                  |
--    | 0x00001000    |    Interrupt any 0,2 ms                  |
--    | 0x00000800    |    Interrupt any 102 us                  |
--    | 0x00000400    |    Interrupt any 50 us                   |
--    | 0x00000200    |    Interrupt any 25 us                   |
--    | 0x00000100    |    Interrupt any 13 us                   |
--    | 0x00000080    |    Interrupt any 6,4 us                  |
--    | 0x00000040    |    Interrupt any 3,2 us                  |
--    | 0x00000020    |    Interrupt any 1,6 us                  |
--    | 0x00000010    |    Interrupt any 800 ns                  |
--
-- The IRQ Generator can't generate a new interrupt request before the 
-- VME Master read the INT_COUNT register! This operation should be the 
-- last operation in the Interrupt service routine.
-- The Master reading the INT_COUNT register can check if it is missing some 
-- interrupts; eg if the Master read 0x01, 0x05, 0x09 it means that 
-- the Interrupt frequency should be lowered by writing the FREQ register.
--
-- Finite State Machine:
--  ___________      ___________      ____________      ____________
-- | IDLE      |--->|  CHECK    |--->|  INCR      |--->|    IRQ     |--->
-- |___________|    |___________|    |____________|    |____________|   |
--       |                                                              |
--       |                  ________________       _______________      |
--       |<----------------|    WAIT_RD     |<----|  WAIT_INT_ACK |<----
--                         |________________|     |_______________|
--
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
use IEEE.NUMERIC_STD.ALL;
use work.vme64x_pack.all;
--===========================================================================
-- Entity declaration
--===========================================================================
entity IRQ_generator is
    port ( clk_i          : in   std_logic;
           reset          : in   std_logic;
           Freq           : in   std_logic_vector (31 downto 0);
           Int_Count_i    : in   std_logic_vector (31 downto 0);
           Read_Int_Count : in   std_logic;
			  INT_ack        : in   std_logic;
           IRQ_o          : out  std_logic;
           Int_Count_o    : out  std_logic_vector (31 downto 0));
end IRQ_generator;
--===========================================================================
-- Architecture declaration
--===========================================================================
architecture Behavioral of IRQ_generator is

type t_FSM is (IDLE, CHECK, INCR, IRQ, WAIT_INT_ACK, WAIT_RD);
signal s_en_int               : std_logic;
signal currs, nexts           : t_FSM;
signal s_IRQ_o                : std_logic;
signal s_count                : unsigned(31 downto 0);
signal s_Rd_Int_Count_delayed : std_logic;
signal s_pulse                : std_logic;
signal s_count_int            : unsigned(31 downto 0);
signal s_count_req            : unsigned(31 downto 0);
signal s_incr                 : std_logic;
signal s_gen_irq              : std_logic;
signal s_count0               : std_logic;
signal s_Freq                 : std_logic_vector(31 downto 0);
--===========================================================================
-- Architecture begin
--===========================================================================
begin
-- In/Out sample	
RDinputSample : DoubleSigInputSample
    port map(
      sig_i => Read_Int_Count,
      sig_o => s_Rd_Int_Count_delayed,
      clk_i => clk_i
      );			
IRQOutputSample : FlipFlopD
    port map(
      sig_i => s_IRQ_o,
      sig_o => IRQ_o,
      clk_i => clk_i,
		reset => '0',
		enable => '1'
      );		
-- Upload s_Freq signal; this operation should be done when the
-- internal count is 0 because the VME Master can change the FREQ
-- register at any time. 		
process(clk_i)
  begin
    if rising_edge(clk_i) then
	    if reset = '0' then s_Freq <= (others => '0');
	    elsif s_count0 = '1' then
		       s_Freq <= Freq; 
       end if;
			 
	 end if;	 
  end process;			
  
-- check if s_count is 0	
process(clk_i)
  begin
    if rising_edge(clk_i) then
	   if s_count = 0 then
		   s_count0 <= '1';
		else 
         s_count0 <= '0';
      end if;			
    end if;
end process;			

--if FREQ = 0x00000000 --> No interrupt 		
process(clk_i)
  begin
    if rising_edge(clk_i) then
	   if reset = '0' then s_en_int <= '0';
	   elsif unsigned(s_Freq) = 0 then
		      s_en_int <= '0';
		else 
            s_en_int <= '1';
      end if;			
    end if;
end process;	
	
--Counter 
process(clk_i)
	begin
	if rising_edge(clk_i) then
      if reset = '0' or s_pulse = '1' then 
		   s_count <= (others => '0');
      elsif s_en_int = '1' then
         s_count <= s_count + 1;
		end if;	
	end if;
end process;

-- Interrupt pulse generator
process(clk_i)
	begin
	if rising_edge(clk_i) then
      if s_en_int = '1' and unsigned(s_Freq) = s_count then 
         s_pulse <= '1';
		else
         s_pulse <= '0';			
		end if;	
	end if;
end process;

--Counter interrupt pulse --> to INT_COUNT register
process(clk_i)
	begin
	if rising_edge(clk_i) then
      if reset = '0' then 
		   s_count_int <= (others => '0');
      elsif s_en_int = '1' and s_pulse = '1' then
         s_count_int <= s_count_int + 1;
		end if;	
	end if;
end process;

--Counter interrupt requests
process(clk_i)
	begin
	if rising_edge(clk_i) then
      if reset = '0' then 
		   s_count_req <= (others => '0');
      elsif s_incr = '1' then
         s_count_req <= s_count_req + 1;
		end if;	
	end if;
end process;

-- if INT_COUNT  > Interrupt requests than generate an interrupt request
process(clk_i)
	begin
	if rising_edge(clk_i) then
      if unsigned(Int_Count_i) > s_count_req then
         s_gen_irq <= '1';
      else
         s_gen_irq <= '0';
      end if;			
	end if;
end process;

-- Update current state
process(clk_i)
begin
  if rising_edge(clk_i) then
      if reset = '0' then currs <= IDLE;
      else currs <= nexts;
      end if;	
  end if;
end process;		
-- generate next state
process(currs,s_gen_irq,INT_ack,s_Rd_Int_Count_delayed)
begin
   case currs is 
	    when IDLE =>
		     nexts <= CHECK;
			  
		 when CHECK =>
		     if s_gen_irq = '1' then
		        nexts <= INCR;	  
			  else
			     nexts <= CHECK;
			  end if;
		
        when INCR =>
		     nexts <= IRQ;	

		  when IRQ =>
		     nexts <= WAIT_INT_ACK;
			    
		  when WAIT_INT_ACK =>
		     if INT_ack = '0' then
		        nexts <= WAIT_RD;	  
			  else
			     nexts <= WAIT_INT_ACK;
			  end if;
			
		  when WAIT_RD =>
		     if s_Rd_Int_Count_delayed = '1' then
		        nexts <= IDLE;	  
			  else
			     nexts <= WAIT_RD;
			  end if;
   end case;
end process;

-- Update outputs
-- Moore FSM
process(currs)
begin
   case currs is 
	    when IDLE =>
		   s_incr   <= '0';
			s_IRQ_o  <= '0';
		 
		 when CHECK =>
		   s_incr   <= '0';
			s_IRQ_o  <= '0';
		 
		 when INCR =>
		   s_incr   <= '1';
			s_IRQ_o  <= '0';
			
		 when IRQ =>
		   s_incr   <= '0';
			s_IRQ_o  <= '1';
		 
		 when WAIT_INT_ACK =>
		   s_incr   <= '0';
			s_IRQ_o  <= '0';
		 
		 when WAIT_RD =>
		   s_incr   <= '0';
			s_IRQ_o  <= '0';
	end case;	 
end process;

Int_Count_o <= std_logic_vector(s_count_int);
end Behavioral;
--===========================================================================
-- Architecture end
--===========================================================================
