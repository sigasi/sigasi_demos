--______________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________
-- Description: 
-- The aim of this top level is to debug the vme64x interface so in the
-- WB side a RAM memory WB capable has been inserted as show in the following 
-- block diagram.
--
-- TOP_LEVEL's block diagram
--              __________________________________________________________________ 
--    ___      |   _____________________    ______________     __________________ |
--   | B |     |  |                     |  |WB_Bridge.vhd |   |                  ||
--   | A |     |  |      VME TO WB      |  |              |   |                  ||
--   | C |     |  |      INTERFACE      |  |   _________  |   |                  ||
--   | K |     |  | (VME64xCore_Top.vhd)|  |  |INT_COUNT| |   |     SPRAM        ||
--   | P |_____|__|           |         |__|   ________   |___|       WB         ||
--   | L |_____|__|           |         |__|  |INT_RATE|  |___|     SLAVE        ||
--   | A |     |  |   VME     |   WB    |  |   ________   |   |(or your WB appl.)||
--   | N |     |  |  SLAVE    | MASTER  |  |  |IRQ_Gen.|  |   |   64-bit port    ||
--   | E |     |  |           |         |  |  |        |  |   | Byte Granularity ||
--   |   |     |  |           |         |  |  |        |  |   |                  ||
--   |   |     |  |           |         |  |  |________|  |   |                  ||
--   |___|     |  |_____________________|  |______________|   |__________________|| 
--             |__________________________________________________________________|       
--
--
-- The wb slave supports the PIPELINED mode.  
-- A little about the clk:
-- The VME  is an asynchronous and handshake protocol so the vme64x interface 
-- has to work at any clock frequency but since all the asynchronous signals
-- are sampled and the core work around the main FSM that of course is a synchronous
-- machine and the VME standards provide a set of timing rules, not all the 
-- clock frequency ensure proper operation of the core.
--
-- 1)   Fig. 25 pag. 107----"VMEbus Specification" ANSI/IEEE STD1014-1987 
--                        min 30ns
--                       <------->
--                       _________
--             AS*______/         \______
-- As show in the figure, to be sure that the slave detects the rising edge
-- and the following falling edge on the AS* signal the clk_i's period must be 
-- maximum 30 ns.
-- 2)  Fig. 20 pag. 99----"VMEbus Specification" ANSI/IEEE STD1014-1987
--         max 20ns
--         <--->
--  ______
--        \__________DSA*
--  ___________
--             \_____DSB*
-- The Master may not assert the data strobe lines at the same time; the 
-- maximum delay between the two falling edge is 20 ns --> in the MFS 
-- machine in the VME_bus.vhd file the LATCH_DS state has been inserted and the 
-- minimum clk_i's period must be of 10 ns.
-- 
-- VME to WB interface:
-- See the VME64xCore_Top.vhd component
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

-- uncomment to use the PLL 
Library UNISIM;
use UNISIM.vcomponents.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.wishbone_pkg.all;
use work.vme64x_pack.all;
use work.genram_pkg.all;
use work.VME_CR_pack.all;
--===========================================================================
-- Entity declaration
--===========================================================================
entity TOP_LEVEL is
generic(
        g_clock          : integer := 10;
        --WB data width:
        g_wb_data_width  : integer := 64;  --c_width;
		  -- WB addr width:
	     g_wb_addr_width  : integer := 11;    --c_addr_width;
		  --CRAM size in the CR/CSR space (bytes):
		  g_cram_size      : integer := 1024;    --c_CRAM_SIZE;
		  --My WB slave memory:
		  g_WB_memory_size : integer := 1024;      -- c_SIZE
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

component xwb_ram is
        generic(
                g_size                  : integer := 256;
                g_init_file             : string  := "";
                g_must_have_init_file   : boolean := true;
                g_slave1_interface_mode : t_wishbone_interface_mode;
                g_slave1_granularity    : t_wishbone_address_granularity
       );
	port(
		          clk_sys_i : in std_logic;
		          slave1_i  : in t_wishbone_slave_in;          
		          slave1_o  : out t_wishbone_slave_out
		);
end component xwb_ram;

component WB_Bridge is
generic(
        g_wb_data_width : integer := c_width;
	     g_wb_addr_width : integer := c_addr_width
	    );
	port(
		clk_i     : in  std_logic;
		rst_i     : in  std_logic;
		Int_Ack_i : in  std_logic;
		cyc_i     : in  std_logic;
		stb_i     : in  std_logic;
		adr_i     : in  std_logic_vector(g_wb_addr_width - 1 downto 0);
		dat_i     : in  std_logic_vector(g_wb_data_width - 1 downto 0);
		sel_i     : in  std_logic_vector(f_div8(g_wb_data_width) - 1 downto 0);
		we_i      : in  std_logic;
		m_ack_i   : in  std_logic;
		m_err_i   : in  std_logic;
		m_stall_i : in  std_logic;
		m_rty_i   : in  std_logic;
		m_dat_i   : in  std_logic_vector(g_wb_data_width - 1 downto 0);          
		Int_Req_o : out std_logic;
		ack_o     : out std_logic;
		err_o     : out std_logic;
		rty_o     : out std_logic;
		stall_o   : out std_logic;
		dat_o     : out std_logic_vector(g_wb_data_width - 1 downto 0);
		m_cyc_o   : out std_logic;
		m_stb_o   : out std_logic;
		m_adr_o   : out std_logic_vector(g_wb_addr_width - 1 downto 0);
		m_dat_o   : out std_logic_vector(g_wb_data_width - 1 downto 0);
		m_sel_o   : out std_logic_vector(f_div8(g_wb_data_width) - 1 downto 0);
		m_we_o    : out std_logic
		);
end component WB_Bridge;
	
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
	
signal WbMemDat_i                : std_logic_vector(g_wb_data_width - 1 downto 0);
signal WbMemDat_o                : std_logic_vector(g_wb_data_width - 1 downto 0);
signal WbMemAdr_i                : std_logic_vector(g_wb_addr_width - 1 downto 0);
signal WbMemCyc_i                : std_logic;
signal WbMemErr_o                : std_logic;
signal WbMemRty_o                : std_logic;
signal WbMemSel_i                : std_logic_vector(f_div8(g_wb_data_width) - 1 downto 0);
signal WbMemStb_i                : std_logic;
signal WbMemAck_o                : std_logic;	
signal WbMemWe_i                 : std_logic;		
signal WbMemStall_o              : std_logic;	
	
signal Rst                       : std_logic;								
signal clk_in_buf                : std_logic;
signal clk_in                    : std_logic;
signal s_locked                  : std_logic;
signal s_fb                      : std_logic;
signal s_INT_ack                 : std_logic;
signal s_rst                     : std_logic;

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

Inst_xwb_ram: xwb_ram 
      generic map(g_size                   => g_WB_memory_size,
                  g_init_file              => "",
                  g_must_have_init_file    => false,
                  g_slave1_interface_mode  => PIPELINED,
                  g_slave1_granularity     => BYTE
						)
    		port map(
		            clk_sys_i                => clk_in,
						slave1_i.cyc             => WbMemCyc_i,
                  slave1_i.stb             => WbMemStb_i,
                  slave1_i.adr             => WbMemAdr_i,
                  slave1_i.sel             => WbMemSel_i,
                  slave1_i.we              => WbMemWe_i,
                  slave1_i.dat             => WbMemDat_i,
		            slave1_o.ack             => WbMemAck_o,
                  slave1_o.err             => WbMemErr_o,
                  slave1_o.rty             => WbMemRty_o,
                  slave1_o.stall           => WbMemStall_o,
                  slave1_o.dat             => WbMemDat_o
	);
	
Inst_WB_Bridge: WB_Bridge 
generic map(
              g_wb_data_width => g_wb_data_width,
				  g_wb_addr_width => g_wb_addr_width 
           )
port map(
		clk_i     => clk_in,
		rst_i     => s_rst,
		Int_Ack_i => s_INT_ack,
		Int_Req_o => WbIrq_i,
		cyc_i     => WbCyc_o,
		stb_i     => WbStb_o,
		adr_i     => WbAdr_o,
		dat_i     => WbDat_o,
		sel_i     => WbSel_o,
		we_i      => WbWe_o,
		ack_o     => WbAck_i,
		err_o     => WbErr_i,
		rty_o     => WbRty_i,
		stall_o   => WbStall_i,
		dat_o     => WbDat_i,
		m_cyc_o   => WbMemCyc_i,
		m_stb_o   => WbMemStb_i,
		m_adr_o   => WbMemAdr_i,
		m_dat_o   => WbMemDat_i,
		m_sel_o   => WbMemSel_i,
		m_we_o    => WbMemWe_i,
		m_ack_i   => WbMemAck_o,
		m_err_i   => WbMemErr_o,
		m_stall_i => WbMemStall_o,
		m_rty_i   => WbMemRty_o,
		m_dat_i   => WbMemDat_o
	);
	
  Rst <= VME_RST_n_i and Reset;
---------------------------------------------------------------------------------  
    -- buffers                                                         
    VME_DATA_b       <= s_VME_DATA_b_o    when s_VME_DATA_DIR = '1' else (others => 'Z');
    VME_ADDR_b       <= s_VME_ADDR_b_o    when s_VME_ADDR_DIR = '1' else (others => 'Z');
    VME_LWORD_n_b    <= s_VME_LWORD_n_b_o when s_VME_ADDR_DIR = '1' else 'Z';
---------------------------------------------------------------------------------	 
	 -- Outputs:
	 VME_ADDR_DIR_o   <= s_VME_ADDR_DIR;
	 VME_DATA_DIR_o   <= s_VME_DATA_DIR;
---------------------------------------------------------------------------------	 

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
