--_________________________________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--_________________________________________________________________________________________
-- File:                      VME_IRQ_Controller.vhd
--_________________________________________________________________________________________
-- Description:
-- This block acts as Interrupter. Phases of an interrupt cycle:
-- 1) The Interrupt Controller receives an interrupt request by the WB bus; 
--    this request is a pulse on the INT_Req input 
-- 2) The Interrupt Controller asserts ('0') one of the 7 VME_IRQ lines; --> request of a service.
--    The Interrupt priority is specificated by the Master writing the INT_Level register 
--    in the CR/CSR space
-- 3) The Interrupter Controller wait for the falling edge on the VME_IACKIN line.
-- 4) When detects VME_IACKIN_n_i = '0' and the Interrupt Handler initiates the Interrupt 
--    cycle by asserting AS,the Interrupt Controller check if it is the responding interrupter.
--    Indeed before responding to an interrupt acknowledge cycle the interrupter shall have 
--    an interrupt request pending, shall check if the level of that request match the level 
--    indicated on the address lines A1, A2 and A3,the data transfer width during the interrupt 
--    acknowledge cycle should be equal or greater than the size the it can respond with, and 
--    it shall receive a falling edge on its IACKIN*.
-- 5) If it is the responding interrupter should send the source/ID on the VME_DATA lines 
--    (in our case the source/ID is the INT_Vector that the Master can write in the corresponding 
--    register in the CR/CSR space) and it terminates the interrupt cycle with an acknowledge before 
--    releasing the IRQ lines. If it isn't the responding interrupter, it should pass a falling edge on 
--    down the daisy-chain so other interrupters can respond.
--     
-- All the output signals are registered   
-- To implement the 5 phases before mentioned the follow FSM has been implemented:

--      __________
--  |--| IACKOUT2 |<-|
--  |  |__________|  |
--  |                |
--  |    _________   |  _________     _________     _________              
--  |-->|  IDLE   |--->|  IRQ    |-->| WAIT_AS |-->| WAIT_DS |---------------->|        
--      |_________|    |_________|   |_________|   |_________|                 | 
--         |             |                                                     |
--         |             |                       _________      _________      |
--         |             |---------<------------| IACKOUT1| <--| CHECK   |<----|
--         |                                    |_________|    |_________|     
--         |                     __________     __________         |
--         |--<-----------------|  DTACK   |<--| DATA_OUT |---<----|
--                              |__________|   |__________|   
--
-- The interrupter wait the IACKIN falling edge in the IRQ state, so if the interrupter
-- don't have interrupt pending for sure it will not respond because it is in IDLE.
-- If the slave module does not have an interrupt pending (IDLE state) and it receives
-- a falling edge on the IACKIN, it shall pass the falling edge through the daisy chain.
-- To obtain this the IACKOUT2 state has been added.
-- Time constraint:
--                      
--  Time constraint n° 35:
--       Clk   _____       _____       _____       _____       _____       _____      
--       _____|     |_____|     |_____|     |_____|     |_____|     |_____|     |_____     
--  VME_AS1_n_i   ____________________________________________________________________
--       ________|
--       VME_AS_n_i                                ___________________________________
--       _________________________________________|
--       s_AS_RisingEdge                                       ___________
--       _____________________________________________________|           |___________
--      s_IACKOUT ____________________________________________________________________
--       ________|          
-- VME_IACKOUT_o  ____________________________________________________________________
--       ________|
--
--       _________________________________________________________________  __________
--                                             IACKOUT 1/2                \/ IDLE/IRQ
--       -----------------------------------------------------------------/\----------
--
--  To respect the time constraint indicated with the number 35 fig. 55 pag. 183 in the
--  "VMEbus Specification" ANSI/IEEE STD1014-1987, is necessary to generate the VME_AS1_n_i 
--  signal which is the AS signal not sampled, and assign this signal to the s_IACKOUT 
--  signal when the fsm is in the IACKOUTx state.
--
--  The LWORD* input is not used now, since this is a D08(O) Interrupter (see Table 31
--  page 157 VMEbus specification).
--  Since this is a D08 interrupter we do not need to monitor the LWORD* and DS1* lines
--  and the Vector (1 byte) is outputted in the D00-D07 data lines. 
--____________________________________________________________________________________
-- Authors:       
--               Pablo Alvarez Sanchez (Pablo.Alvarez.Sanchez@cern.ch)                                                          
--               Davide Pedretti       (Davide.Pedretti@cern.ch)  
-- Date          11/2012                                                                           
-- Version       v0.03  
--_____________________________________________________________________________________
--                               GNU LESSER GENERAL PUBLIC LICENSE                                
--                              ------------------------------------    
-- Copyright (c) 2009 - 2011 CERN                           
-- This source file is free software; you can redistribute it and/or modify it 
-- under the terms of the GNU Lesser General Public License as published by the 
-- Free Software Foundation; either version 2.1 of the License, or (at your option) 
-- any later version. This source is distributed in the hope that it will be useful, 
-- but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for 
-- more details. You should have received a copy of the GNU Lesser General Public 
-- License along with this source; if not, download it from 
-- http://www.gnu.org/licenses/lgpl-2.1.html                     
---------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.vme64x_pack.all;
--===========================================================================
-- Entity declaration
--===========================================================================
entity VME_IRQ_Controller is
  generic (
    g_retry_timeout : integer range 1024 to 16777215 := 62500);
  port (
    clk_i           : in  std_logic;
    reset_n_i       : in  std_logic;
    VME_IACKIN_n_i  : in  std_logic;
    VME_AS_n_i      : in  std_logic;
    VME_DS_n_i      : in  std_logic_vector (1 downto 0);
    VME_ADDR_123_i  : in  std_logic_vector (2 downto 0);
    INT_Level_i     : in  std_logic_vector (7 downto 0);
    INT_Vector_i    : in  std_logic_vector (7 downto 0);
    INT_Req_i       : in  std_logic;
    VME_IRQ_n_o     : out std_logic_vector (6 downto 0);
    VME_IACKOUT_n_o : out std_logic;
    VME_DTACK_n_o   : out std_logic;
    VME_DTACK_OE_o  : out std_logic;
    VME_DATA_o      : out std_logic_vector (31 downto 0);
    VME_DATA_DIR_o  : out std_logic);
end VME_IRQ_Controller;
--===========================================================================
-- Architecture declaration
--===========================================================================
architecture Behavioral of VME_IRQ_Controller is

  function f_select_irq_line (level : std_logic_vector) return std_logic_vector is
  begin
    case level(7 downto 0) is
      when x"01"  => return "1111110";
      when x"02"  => return "1111101";
      when x"03"  => return "1111011";
      when x"04"  => return "1110111";
      when x"05"  => return "1101111";
      when x"06"  => return "1011111";
      when x"07"  => return "0111111";
      when others => return "1111111";
    end case;
  end f_select_irq_Line;

--input signals

  type t_retry_state is (WAIT_IRQ, WAIT_RETRY);
  type t_main_state is (IDLE, IRQ, WAIT_AS, WAIT_DS, CHECK, DATA_OUT, DTACK, IACKOUT1, IACKOUT2, SCHEDULE_IRQ);

  signal as_n_d0                   : std_logic;
  signal as_rising_p, as_falling_p : std_logic;
  signal vme_addr_latched          : std_logic_vector(2 downto 0);

  signal state : t_main_state;

  signal retry_state : t_retry_state;
  signal retry_count : unsigned(23 downto 0);
  signal retry_mask  : std_logic;

--===========================================================================
-- Architecture begin
--===========================================================================
begin

-- Input sampling and edge detection

  p_detect_as_edges : process(clk_i)
  begin
    if rising_edge(clk_i) then
      as_n_d0      <= VME_AS_n_i;
      as_rising_p  <= not as_n_d0 and VME_AS_n_i;
      as_falling_p <= as_n_d0 and not VME_AS_n_i;
    end if;
  end process;

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if as_falling_p = '1' then
        vme_addr_latched <= VME_ADDR_123_i;
      end if;
    end if;
  end process;

  p_retry_fsm : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then
        retry_mask  <= '1';
        retry_state <= WAIT_IRQ;
      else
        case retry_state is
          when WAIT_IRQ =>

            if(state = IRQ and INT_Req_i = '1') then
              retry_state <= WAIT_RETRY;
              retry_count <= (others => '0');
              retry_mask  <= '0';
            else
              retry_mask <= '1';
            end if;

          when WAIT_RETRY =>
            if(INT_Req_i = '0') then
              retry_state <= WAIT_IRQ;
            else
              retry_count <= retry_count + 1;
              if(retry_count = g_retry_timeout) then
                retry_state <= WAIT_IRQ;
              end if;
            end if;
            
        end case;
      end if;
    end if;
  end process;

  p_main_fsm : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then
        state           <= IDLE;
        VME_IACKOUT_n_o <= '1';
        VME_DATA_DIR_o  <= '0';
        VME_DTACK_n_o   <= '1';
        VME_DTACK_OE_o  <= '0';
      else
        case state is
          when IDLE =>

            VME_IACKOUT_n_o <= '1';
            VME_DATA_DIR_o  <= '0';
            VME_DTACK_n_o   <= '1';
            VME_DTACK_OE_o  <= '0';
            VME_IRQ_n_o     <= (others => '1');

            if INT_Req_i = '1' and retry_mask = '1' then
              if VME_IACKIN_n_i /= '0' then
                state       <= IRQ;
                VME_IRQ_n_o <= f_select_irq_line(INT_Level_i);
              else
                -- IACK in progress, wait until idle
                state <= SCHEDULE_IRQ;
              end if;
              -- just forward IACK to the next card in the daisy chain.              
            elsif VME_IACKIN_n_i = '0' and VME_DS_n_i /= "11" then
              VME_IACKOUT_n_o <= '0';
              state           <= IACKOUT2;
            end if;

          when SCHEDULE_IRQ =>
            if(VME_IACKIN_n_i /= '0') then
              VME_IRQ_n_o <= f_select_irq_line(INT_Level_i);
              state       <= IRQ;
            end if;
            
          when IRQ =>
            if VME_IACKIN_n_i = '0' then
              -- Each Interrupter who is driving an interrupt request line
              -- low waits for a falling edge on IACKIN input -->
              -- the IRQ_Controller have to detect a falling edge on the IACKIN.
              state <= WAIT_AS;
            end if;

          when WAIT_AS =>
            if VME_AS_n_i = '0' then
              state <= WAIT_DS;
            end if;

          when WAIT_DS =>

            if VME_DS_n_i /= "11" then
              state <= CHECK;
            end if;

          when CHECK =>

            if vme_addr_latched = INT_Level_i(2 downto 0) then
              state          <= DATA_OUT;  -- The Interrupter send the INT_Vector
              VME_DATA_DIR_o <= '1';
              VME_DTACK_OE_o <= '1';
              VME_DTACK_n_o  <= '1';
            else
              state           <= IACKOUT1;  -- the Interrupter must pass a falling edge on the IACKOUT output
              VME_IACKOUT_n_o <= '0';
            end if;

          when IACKOUT1 =>
            if as_rising_p = '1' then
              VME_IACKOUT_n_o <= '1';
              state           <= IRQ;
            end if;

          when IACKOUT2 =>
            if VME_AS_n_i = '1' then
              VME_IACKOUT_n_o <= '1';
              state           <= IDLE;
            end if;
            
          when DATA_OUT =>
            VME_DTACK_n_o <= '0';
            VME_IRQ_n_o   <= (others => '1');
            state         <= DTACK;
            
          when DTACK =>
            if as_rising_p = '1' then
              VME_DTACK_OE_o <= '0';
              VME_DATA_DIR_o <= '0';
              state          <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;


  VME_DATA_o <= x"000000" & INT_Vector_i;
end Behavioral;
--===========================================================================
-- Architecture end
--===========================================================================

