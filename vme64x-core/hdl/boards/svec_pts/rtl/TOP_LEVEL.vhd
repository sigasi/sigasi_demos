--______________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________
-- Description: 
-- This file would be an example of a WB slave application.
-- It implements a ram memory (1 KB) and some registers to handle the
-- interrupt service request lines called irq_i
--
-- TOP_LEVEL's block diagram
--              _____________________________________________________________________________ 
--    ___      |   _____________________    _____________________________________            |
--   | B |     |  |                     |  | wishbone_port_slave component       |           |
--   | A |     |  |      VME TO WB      |  |    __________________               |           |
--   | C |     |  |      INTERFACE      |  |   |   idr register   | loc. 0x000   |           |
--   | K |     |  | (VME64xCore_Top.vhd)|  |   |------------------|              |           |
--   | P |_____|__|           |         |__|   |   ier register   | loc. 0x001   |           |
--   | L |_____|__|           |         |__|   |------------------|              |           |
--   | A |     |  |   VME     |   WB    |  |   |   isr regiser    | loc. 0x002   |           |
--   | N |     |  |  SLAVE    | MASTER  |  |   |------------------|              |           |
--   | E |     |  |           |         |  |   |   imr register   | loc. 0x003   |           |
--   |   |     |  |           |         |  |   |------------------|              |           |
--   |   |     |  |           |         |  |   |int_count register| loc. 0x004   |           |
--   |   |     |  |           |         |  |   |------------------|              |           |
--   |   |     |  |           |         |  |   |int_rate register | loc. 0x005   |           |
--   |   |     |  |           |         |  |   |------------------|              |           |
--   |   |     |  |           |         |  |   |       RAM        |  ___________ |           |
--   |   |     |  |           |         |  |   | from loc. 0x100  | |    irq    ||           |
--   |   |     |  |           |         |  |   |  to  loc. 0x1ff  | | controller||<---- irq_0|
--   |   |     |  |           |         |  |   |__________________| |           ||<---- irq_1|
--   |   |     |  |           |         |  |                        |___________||           | 
--   |___|     |  |_____________________|  |_____________________________________|           |
--             |_____________________________________________________________________________|
--
--
-- Please note that the addresses indicated in the block diagram are the wb bus addresses.
-- To access these locations the VME Master should left shift these addresses of two or three 
-- bits according with the wb data bus width which can be 32 or 64 bits.
-- for example: we want write 1 in the ier register (irq_0 enabled):
-- if g_wb_data_width = 32 --> A32_S access to the VME address 0x04
-- if g_wb_data_width = 64 --> A32_S access to the VME address 0x0c
-- g_width refers to the wb data bus width and to the memory and registers width.
-- See also the "Data organization in VME and WB bus" section of the vme64x_user_manual
-- The irq lines are drived by two counters. 
-- The irq_0 line is active on the rising edge and the irq_1 on the falling edge.
-- Two pulse generator are used to generate a pulse on the rising/falling edges of the  
-- irq_0/irq_1. These pulses increment the interrupt counter register (loc. 0x004). 
-- The software can enable/disenable these irq lines setting the corresponding bits in the
-- ier/idr register. 
-- ier register = interrupt enable mask register
-- idr register = interrupt disenable mask register
-- The software can check which interrupt request lines are enabled by readind the interrupt 
-- mask register (imr register); the imr register is a read only register.
-- A read operation on the idr/ier register returns 0
-- The software can check which peripheral needs service reading the interrupt source register.
-- If two or more WB applications are requesting service at the same time, two or more bits are 
-- asserted in the isr register.
-- When the VME Master accesses the isr register in a read operation, this register is
-- cleared by the hardware. To avoid to miss interrupts during this read and clear operation,
-- what the hw does is to overwrite the isr register with the current interrupt request pending
-- vector input.
--______________________________________________________________________________
-- Author:                                                                 
--               Davide Pedretti       (Davide.Pedretti@cern.ch)  
-- Date          30/10/2012                                                                             
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
Library UNISIM;
use UNISIM.vcomponents.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.wishbone_pkg.all;
use work.vme64x_pack.all;
--===========================================================================
-- Entity declaration
--===========================================================================
entity TOP_LEVEL is
generic(
        g_clock          : integer := 10;
        --WB data width:
        g_wb_data_width  : integer := 32;  --c_width;
		  -- WB addr width:
	     g_wb_addr_width  : integer := 9;    --c_addr_width;
		  --CRAM size in the CR/CSR space (bytes):
		  g_cram_size      : integer := 1024;    --c_CRAM_SIZE;
		  --My WB slave memory:
		  g_WB_memory_size : integer := 256;      -- c_SIZE
		  g_BoardID        : integer := 408;       -- 0x00000198
		  g_ManufacturerID : integer := 524336;    -- 0x080030
		  g_RevisionID     : integer := 1;         -- 0x00000001
		  g_ProgramID      : integer := 90         -- 0x0000005a 
	     );
port(
    clk_i            : in    std_logic;    	 
    Reset            : in    std_logic;  -- hand reset; button PB1
   	-- VME                            
    VME_AS_n_i       : in    std_logic;
    VME_RST_n_i      : in    std_logic;
    VME_WRITE_n_i    : in    std_logic;
    VME_AM_i         : in    std_logic_vector(5 downto 0);
    VME_DS_n_i       : in    std_logic_vector(1 downto 0);
    VME_GA_i         : in    std_logic_vector(5 downto 0);
    VME_BERR_o       : out   std_logic;
    VME_DTACK_n_o    : out   std_logic;
    VME_RETRY_n_o    : out   std_logic;  
    VME_LWORD_n_b    : inout std_logic;
    VME_ADDR_b       : inout std_logic_vector(31 downto 1);
    VME_DATA_b       : inout std_logic_vector(31 downto 0);
    VME_IRQ_n_o      : out   std_logic_vector(6 downto 0);
    VME_IACKIN_n_i   : in    std_logic;
    VME_IACKOUT_n_o  : out   std_logic;
    VME_IACK_n_i     : in    std_logic;  
    -- VME buffers
	 VME_RETRY_OE_o   : out   std_logic;
    VME_DTACK_OE_o   : out   std_logic;
    VME_DATA_DIR_o   : out   std_logic;
    VME_DATA_OE_N_o  : out   std_logic;
    VME_ADDR_DIR_o   : out   std_logic;
    VME_ADDR_OE_N_o  : out   std_logic;
	 -- for debug:
	 leds             : out   std_logic_vector(7 downto 0)
	 );

end TOP_LEVEL;
--===========================================================================
-- Architecture declaration
--===========================================================================
architecture Behavioral of TOP_LEVEL is

component VME64xCore_Top is
	generic(
	        g_clock          : integer := c_clk_period;
			  g_wb_data_width  : integer := c_width;
	        g_wb_addr_width  : integer := c_addr_width;
			  g_cram_size      : integer := c_CRAM_SIZE;
			  g_BoardID        : integer := c_SVEC_ID;
			  g_ManufacturerID : integer := c_CERN_ID;       -- 0x00080030
			  g_RevisionID     : integer := c_RevisionID;    -- 0x00000001
		     g_ProgramID      : integer := 96               -- 0x00000060 
	        );
	port(
	   -- VME signals:
		clk_i           : in    std_logic;
		VME_AS_n_i      : in    std_logic;
		VME_RST_n_i     : in    std_logic;
		VME_WRITE_n_i   : in    std_logic;
		VME_AM_i        : in    std_logic_vector(5 downto 0);
		VME_DS_n_i      : in    std_logic_vector(1 downto 0);
		VME_GA_i        : in    std_logic_vector(5 downto 0);
		VME_IACKIN_n_i  : in    std_logic;
		VME_IACK_n_i    : in    std_logic;	
		VME_LWORD_n_i   : in    std_logic;
		VME_LWORD_n_o   : out   std_logic;
		VME_ADDR_i      : in    std_logic_vector(31 downto 1);
		VME_ADDR_o      : out   std_logic_vector(31 downto 1);
		VME_DATA_i      : in    std_logic_vector(31 downto 0); 
		VME_DATA_o      : out   std_logic_vector(31 downto 0); 
		VME_BERR_o      : out   std_logic;
		VME_DTACK_n_o   : out   std_logic;
		VME_RETRY_n_o   : out   std_logic;
		VME_RETRY_OE_o  : out   std_logic;
		VME_IRQ_o       : out   std_logic_vector(6 downto 0);
		VME_IACKOUT_n_o : out   std_logic;
		VME_DTACK_OE_o  : out   std_logic;
		VME_DATA_DIR_o  : out   std_logic;
		VME_DATA_OE_N_o : out   std_logic;
		VME_ADDR_DIR_o  : out   std_logic;
		VME_ADDR_OE_N_o : out   std_logic;
		-- WB signals
		DAT_i           : in    std_logic_vector(g_wb_data_width - 1 downto 0);
		ERR_i           : in    std_logic;
		RTY_i           : in    std_logic;
		ACK_i           : in    std_logic;
		STALL_i         : in    std_logic;
		DAT_o           : out   std_logic_vector(g_wb_data_width - 1 downto 0);
		ADR_o           : out   std_logic_vector(g_wb_addr_width - 1 downto 0);
		CYC_o           : out   std_logic;
		SEL_o           : out   std_logic_vector(f_div8(g_wb_data_width) - 1 downto 0);
		STB_o           : out   std_logic;
		WE_o            : out   std_logic;
		-- IRQ Generator
		IRQ_i           : in    std_logic;
		INT_ack_o       : out   std_logic;
		reset_o         : out   std_logic;
		-- for debug:
	   debug           : out   std_logic_vector(7 downto 0)
		);
end component VME64xCore_Top;

component wishbone_port_slave
   generic(g_width          : integer := c_width;
	        g_addr_width     : integer := c_addr_width;
			  g_WB_memory_size : integer := 256;
			  g_num_irq        : integer := 2
	        );
	port(
		rst_n_i : in std_logic;
		clk_sys_i : in std_logic;
		wb_adr_i : in std_logic_vector(g_addr_width - 1 downto 0);
		wb_dat_i : in std_logic_vector(g_width - 1 downto 0);
		wb_cyc_i : in std_logic;
		wb_sel_i : in std_logic_vector(f_div8(g_width) - 1 downto 0);
		wb_stb_i : in std_logic;
		wb_we_i : in std_logic;
		wbslave_reg_int_count_i : in std_logic_vector(g_width - 1 downto 0);
		wbslave_ram_addr_i : in std_logic_vector(g_addr_width - 2 downto 0);
		wbslave_ram_rd_i : in std_logic;
		wbslave_ram_data_i : in std_logic_vector(g_width - 1 downto 0);
		wbslave_ram_wr_i : in std_logic;
		irq_irq0_i : in std_logic;
		irq_irq1_i : in std_logic;          
		wb_dat_o : out std_logic_vector(g_width - 1 downto 0);
		wb_ack_o : out std_logic;
		wb_stall_o : out std_logic;
		wb_int_o : out std_logic;
		wbslave_reg_int_rate_o : out std_logic_vector(g_width - 1 downto 0);
		wbslave_ram_data_o : out std_logic_vector(g_width - 1 downto 0)
		);
	end component;

	
signal WbDat_i                   : std_logic_vector(g_wb_data_width - 1 downto 0);
signal WbDat_o                   : std_logic_vector(g_wb_data_width - 1 downto 0);
signal WbAdr_o                   : std_logic_vector(g_wb_addr_width - 1 downto 0);
signal WbCyc_o                   : std_logic;
signal WbErr_i                   : std_logic;
signal WbRty_i                   : std_logic;
signal WbSel_o                   : std_logic_vector(f_div8(g_wb_data_width) - 1 downto 0);
signal WbStb_o                   : std_logic;
signal WbAck_i                   : std_logic;	
signal WbWe_o                    : std_logic;		
signal WbStall_i                 : std_logic;		
signal WbIrq_i                   : std_logic;
	
signal Rst                       : std_logic;								
signal clk_in_buf                : std_logic;
signal clk_in                    : std_logic;
signal s_locked                  : std_logic;
signal s_fb                      : std_logic;
signal s_INT_ack                 : std_logic;
signal s_rst                     : std_logic;
signal s_rst_n                   : std_logic;
signal s_counter0                 : unsigned(25 downto 0);
signal s_counter1                 : unsigned(25 downto 0);
signal s_1                       : std_logic;
signal s_ris_edge                : std_logic;
signal s_2                       : std_logic;
signal s_fal_edge                : std_logic;
signal s_int_counter             : unsigned(25 downto 0);
signal s_int_counter_slv         : std_logic_vector(g_wb_data_width - 1 downto 0);
--mux
signal s_VME_DATA_b_o            : std_logic_vector(31 downto 0);
signal s_VME_DATA_DIR            : std_logic;
signal s_VME_ADDR_DIR            : std_logic;
signal s_VME_ADDR_b_o            : std_logic_vector(31 downto 1);
signal s_VME_LWORD_n_b_o         : std_logic;
--===========================================================================
-- Architecture begin
--===========================================================================
begin

Inst_VME64xCore_Top: VME64xCore_Top 
generic map(
              g_clock          => g_clock,
              g_wb_data_width  => g_wb_data_width,
				  g_wb_addr_width  => g_wb_addr_width,
				  g_cram_size      => g_cram_size,
			     g_BoardID        => g_BoardID,
				  g_ManufacturerID => g_ManufacturerID,
				  g_RevisionID     => g_RevisionID,
				  g_ProgramID      => g_ProgramID
           )
port map(
      -- VME
		clk_i           => clk_in,
		VME_AS_n_i      => VME_AS_n_i,
		VME_RST_n_i     => Rst,
		VME_WRITE_n_i   => VME_WRITE_n_i,
		VME_AM_i        => VME_AM_i,
		VME_DS_n_i      => VME_DS_n_i,
		VME_GA_i        => VME_GA_i,
		VME_BERR_o      => VME_BERR_o,
		VME_DTACK_n_o   => VME_DTACK_n_o,
		VME_RETRY_n_o   => VME_RETRY_n_o,		
		VME_LWORD_n_i   => VME_LWORD_n_b,
		VME_LWORD_n_o   => s_VME_LWORD_n_b_o,
		VME_ADDR_i      => VME_ADDR_b,
		VME_ADDR_o      => s_VME_ADDR_b_o,
		VME_DATA_i      => VME_DATA_b,
		VME_DATA_o      => s_VME_DATA_b_o,
		VME_IRQ_o       => VME_IRQ_n_o,
		VME_IACKIN_n_i  => VME_IACKIN_n_i,
		VME_IACK_n_i    => VME_IACK_n_i,
		VME_IACKOUT_n_o => VME_IACKOUT_n_o,
		-- buffer
		VME_DTACK_OE_o  => VME_DTACK_OE_o,
		VME_DATA_DIR_o  => s_VME_DATA_DIR,
		VME_DATA_OE_N_o => VME_DATA_OE_N_o,
		VME_ADDR_DIR_o  => s_VME_ADDR_DIR,
		VME_ADDR_OE_N_o => VME_ADDR_OE_N_o,
		VME_RETRY_OE_o  => VME_RETRY_OE_o,
		--WB
		DAT_i           => WbDat_i,  
		DAT_o           => WbDat_o,  
		ADR_o           => WbAdr_o,  
		CYC_o           => WbCyc_o,  
		ERR_i           => WbErr_i,  
		RTY_i           => WbRty_i,  
		SEL_o           => WbSel_o, 
		STB_o           => WbStb_o, 
		ACK_i           => WbAck_i, 
		WE_o            => WbWe_o,  
		STALL_i         => WbStall_i, 
		--IRQ Generator
		IRQ_i           => WbIrq_i,  
		INT_ack_o       => s_INT_ack,
		reset_o         => s_rst,
		-- Add by Davide for debug:
	   debug           => leds
	);

	
Inst_wishbone_port_slave: wishbone_port_slave 
generic map(
              g_width      => g_wb_data_width,
				  g_addr_width => g_wb_addr_width,
				  g_WB_memory_size => g_WB_memory_size,
				  g_num_irq    => 2
           )
port map(
		rst_n_i => s_rst_n,
		clk_sys_i => clk_in,
		wb_adr_i => WbAdr_o,
		wb_dat_i => WbDat_o,
		wb_dat_o => WbDat_i,
		wb_cyc_i => WbCyc_o,
		wb_sel_i => WbSel_o,
		wb_stb_i => WbStb_o,
		wb_we_i => WbWe_o,
		wb_ack_o => WbAck_i,
		wb_stall_o => WbStall_i,
		wb_int_o => WbIrq_i,
		wbslave_reg_int_count_i => s_int_counter_slv,
		wbslave_reg_int_rate_o => open,
		wbslave_ram_addr_i => (others => '0'),
		wbslave_ram_data_o => open,
		wbslave_ram_rd_i => '0',
		wbslave_ram_data_i => (others => '0'),
		wbslave_ram_wr_i => '0',
		irq_irq0_i => s_counter0(23),
		irq_irq1_i => s_counter0(23)
	);	
	
s_int_counter_slv <= std_logic_vector(resize(s_int_counter,s_int_counter_slv'length));
---------------------------------------------------------------------------------
process(clk_i)
  begin
     if rising_edge(clk_i) then
        if Rst = '0' or s_rst_n = '0' then 
           s_counter0 <= (others => '0');
        else 
           s_counter0 <= s_counter0 + 1;
        end if;	
    end if;
  end process;
----------------------------------------------------------------------------------
process(clk_i)
  begin
     if rising_edge(clk_i) then
        if Rst = '0' or s_rst_n = '0' then 
           s_counter1 <= (others => '0');
        else 
           s_counter1 <= s_counter1 + 1;
        end if;	
    end if;
  end process;
----------------------------------------------------------------------------------
-- rising edge detection
process(clk_i)
	begin
		if rising_edge(clk_i) then
			s_1 <= s_counter0(23);
			if s_1 = '0' and s_counter0(23) = '1' then
				s_ris_edge <= '1';
			else
				s_ris_edge <= '0';
			end if;
		end if;
	end process;
----------------------------------------------------------------------------------
-- falling edge detection
process(clk_i)
	begin
		if rising_edge(clk_i) then
			s_2 <= s_counter0(23);
			if s_2 = '1' and s_counter0(23) = '0' then
				s_fal_edge <= '1';
			else
				s_fal_edge <= '0';
			end if;
		end if;
	end process;
--------------------------------------------------------------------------------
-- interrupt counter
process(clk_i)
  begin
     if rising_edge(clk_i) then
        if Rst = '0' then 
           s_int_counter <= (others => '0');
        else 
		     if (s_ris_edge = '1' or s_fal_edge = '1')  then 
              s_int_counter <= s_int_counter + 1;
           end if;
		  end if;	
    end if;
  end process;
----------------------------------------------------------------------------------

  Rst <= VME_RST_n_i and Reset;
  s_rst_n <= not s_rst;
---------------------------------------------------------------------------------  
    -- buffers                                                         
    VME_DATA_b       <= s_VME_DATA_b_o    when s_VME_DATA_DIR = '1' else (others => 'Z');
    VME_ADDR_b       <= s_VME_ADDR_b_o    when s_VME_ADDR_DIR = '1' else (others => 'Z');
    VME_LWORD_n_b    <= s_VME_LWORD_n_b_o when s_VME_ADDR_DIR = '1' else 'Z';
---------------------------------------------------------------------------------	 
	 -- Outputs:
	 VME_ADDR_DIR_o   <= s_VME_ADDR_DIR;
	 VME_DATA_DIR_o   <= s_VME_DATA_DIR;
-----------------------------------------------------------------------------------	 
--
 PLL_BASE_inst : PLL_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",   -- "HIGH", "LOW" or "OPTIMIZED" 
      CLKFBOUT_MULT => 20,        -- Multiply value for all CLKOUT clock outputs (1-64)
      CLKFBOUT_PHASE => 0.000,    -- Phase offset in degrees of the clock feedback output
                                  -- (0.0-360.0).
      CLKIN_PERIOD => 50.000,     -- Input clock period in ns to ps resolution (i.e. 33.333 is 30
                                  -- MHz).
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
      CLKOUT0_DIVIDE => 4,
      CLKOUT1_DIVIDE => 1,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: 
      -- Duty cycle for CLKOUT# clock output (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT1_DUTY_CYCLE => 0.500,
      CLKOUT2_DUTY_CYCLE => 0.500,
      CLKOUT3_DUTY_CYCLE => 0.500,
      CLKOUT4_DUTY_CYCLE => 0.500,
      CLKOUT5_DUTY_CYCLE => 0.500,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: 
      -- Output phase relationship for CLKOUT# clock output (-360.0-360.0).
      CLKOUT0_PHASE         => 0.000,
      CLKOUT1_PHASE         => 0.000,
      CLKOUT2_PHASE         => 0.000,
      CLKOUT3_PHASE         => 0.000,
      CLKOUT4_PHASE         => 0.000,
      CLKOUT5_PHASE         => 0.000,
      CLK_FEEDBACK          => "CLKFBOUT",           
      COMPENSATION          => "SYSTEM_SYNCHRONOUS", 
      DIVCLK_DIVIDE         => 1, -- Division value for all output clocks (1-52)
      REF_JITTER            => 0.016,-- Reference Clock Jitter in UI (0.000-0.999).
      RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
   )
   port map (
      CLKFBOUT => s_fb,     -- 1-bit output: PLL_BASE feedback output
      -- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
      CLKOUT0 => clk_in_buf,    --clk 100 MHz
      CLKOUT1 => open,
      CLKOUT2 => open,
      CLKOUT3 => open,
      CLKOUT4 => open,
      CLKOUT5 => open,
      LOCKED  => s_locked,   -- 1-bit output: PLL_BASE lock status output
      CLKFBIN => s_fb,      -- 1-bit input: Feedback clock input
      CLKIN   => clk_i,       -- 1-bit input: Clock input
      RST     => '0'            -- 1-bit input: Reset input
   );	
cmp_clk_dmtd_buf : BUFG
  port map
    (O => clk_in,
     I => clk_in_buf);
-- comment the next line if the PLL is used:
--	clk_in <= clk_i;
end Behavioral;
--===========================================================================
-- Architecture end
--===========================================================================
