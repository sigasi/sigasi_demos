--************************************************************************************************
-- Top entity for AVR microcontroller (for synthesis) with JTAG OCD and DMAs
-- Version 0.5 (Version for Xilinx)
-- Designed by Ruslan Lepetenok 
-- Modified 31.05.2006
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

use WORK.AVRuCPackage.all;
use WORK.AVR_uC_CompPack.all;

use WORK.SynthCtrlPack.all; -- Synthesis control

use WORK.XMemCompPack.all;  -- Xilinx RAM components  

use WORK.MemAccessCtrlPack.all;
use WORK.MemAccessCompPack.all;

entity top_avr_core_v8 is port(
                               nrst   : in    std_logic;
                               clk    : in    std_logic;
                               porta  : inout std_logic_vector(7 downto 0);
                               portb  : inout std_logic_vector(7 downto 0);
	                           -- UART 
	                           rxd    : in    std_logic;
	                           txd    : out   std_logic;
							   -- External interrupts
							   INTx   : in    std_logic_vector(7 downto 0); 
							   -- JTAG related signals
	                           TMS    : in    std_logic;
                               TCK	  : in    std_logic;
                               TDI    : in    std_logic;
                               TDO    : out   std_logic;
	                           TRSTn  : in    std_logic -- Optional JTAG input
							   );

end top_avr_core_v8;

architecture Struct of top_avr_core_v8 is

constant C_OrgMemCfg : boolean := FALSE; -- Memory configuration

-- ############################## Signals connected directly to the core ##########################################

signal core_cpuwait  : std_logic;                    

-- Program memory
signal core_pc   : std_logic_vector (15 downto 0); -- PROM address
signal core_inst : std_logic_vector (15 downto 0); -- PROM data

-- I/O registers
signal core_adr  : std_logic_vector (5 downto 0);
signal core_iore : std_logic;                    
signal core_iowe : std_logic;

-- Data memery
signal core_ramadr : std_logic_vector (15 downto 0);
signal core_ramre  : std_logic;
signal core_ramwe  : std_logic;

signal core_dbusin   : std_logic_vector (7 downto 0);
signal core_dbusout  : std_logic_vector (7 downto 0);

-- Interrupts
signal core_irqlines : std_logic_vector(22 downto 0);
signal core_irqack   : std_logic;
signal core_irqackad : std_logic_vector(4 downto 0);

-- ###############################################################################################################

-- ############################## Signals connected directly to the SRAM controller ###############################

signal ram_din       : std_logic_vector(7 downto 0);

-- ###############################################################################################################


-- ############################## Signals connected directly to the I/O registers ################################
-- PortA
signal porta_dbusout : std_logic_vector (7 downto 0);
signal porta_out_en  : std_logic;

-- PortB
signal portb_dbusout : std_logic_vector (7 downto 0);
signal portb_out_en  : std_logic;

-- Timer/Counter
signal tc_dbusout    : std_logic_vector (7 downto 0);
signal tc_out_en     : std_logic;

-- UART
signal uart_dbusout  : std_logic_vector (7 downto 0);
signal uart_out_en   : std_logic;


-- ###############################################################################################################


-- ####################### Signals connected directly to the external multiplexer ################################
signal   io_port_out     : ext_mux_din_type;
signal   io_port_out_en  : ext_mux_en_type;
signal   ind_irq_ack     : std_logic_vector(core_irqlines'range);
-- ###############################################################################################################

-- ################################## Reset signals #############################################
signal core_ireset        : std_logic;

-- ##############################################################################################

-- Port signals
signal PortAReg : std_logic_vector(porta'range);
signal DDRAReg  : std_logic_vector(porta'range);

signal PortBReg : std_logic_vector(portb'range);
signal DDRBReg  : std_logic_vector(portb'range);

-- Added for Synopsys compatibility
signal gnd   : std_logic;
signal vcc    : std_logic;

-- Sleep support
signal core_cp2  : std_logic; -- Global clock signal after gating(and global primitive)
signal sleep_en  : std_logic;

signal sleepi   : std_logic;
signal irqok    : std_logic;
signal globint  : std_logic;

signal nrst_clksw : std_logic; -- Separate reset for clock gating module 

-- Watchdog related signals
signal wdtmout 	  : std_logic; -- Watchdog overflow
signal core_wdri  : std_logic; -- Watchdog clear

-- **********************  JTAG and memory **********************************************
-- PM address,data and control
signal pm_adr         : std_logic_vector(core_pc'range);
signal pm_h_we        : std_logic;
signal pm_l_we        : std_logic;
signal pm_din         : std_logic_vector(core_inst'range);

signal pm_dout        : std_logic_vector(core_inst'range);

--signal ramdata_in_tmp : std_logic_vector(ram_din'range); -- Data input of DRAM

--signal pm_adr_tmp     : std_logic_vector(core_pc'range);

signal TDO_Out        : std_logic;
signal TDO_OE         : std_logic;

signal JTAG_Rst       : std_logic;

-- **********************  JTAG and memory **********************************************

signal nrst_cp64m_tmp   : std_logic;

signal ram_cp2_n        : std_logic;

signal sleep_mode       : std_logic; 


-- Inverted write enable signals
--signal n_pm_h_we        : std_logic;
--signal n_pm_l_we        : std_logic;
--signal n_core_ramwe     : std_logic;

-- "EEPROM" related signals
signal EEPrgSel : std_logic; 
signal EEAdr    : std_logic_vector(11 downto 0);
signal EEWrData : std_logic_vector(7 downto 0);
signal EERdData : std_logic_vector(7 downto 0);
signal EEWr     : std_logic; 


-- New
signal busmin   : MastersOutBus_Type;                            
signal busmwait : std_logic_vector(CNumOfBusMasters-1 downto 0) := (others => '0'); 

signal slv_outs : SlavesOutBus_Type;

signal ram_sel  : std_logic;

-- UART DMA
signal udma_mack    : std_logic;


signal mem_mux_out   : std_logic_vector (7 downto 0);



-- AES

signal aes_mack         : std_logic;        


-- Address decoder
signal stb_IO        : std_logic;   
signal stb_IOmod     : std_logic_vector (CNumOfSlaves-1 downto 0);

signal ram_ce      	 : std_logic;

signal slv_cpuwait   : std_logic;

-- Memory i/f
signal mem_ramadr       : std_logic_vector (15 downto 0);  
signal mem_ram_dbus_in  : std_logic_vector (7 downto 0);
signal mem_ram_dbus_out : std_logic_vector (7 downto 0);
signal mem_ramwe        : std_logic;
signal mem_ramre        : std_logic;

-- RAM
signal ram_ramwe         : std_logic;

-- Clock generation/distribution
signal clk4M             : std_logic;  

begin

-- Added for Synopsys compatibility
gnd <= '0';
vcc  <= '1';
-- Added for Synopsys compatibility	

--FrqDiv_Inst:component FrqDiv port map(
--                                      clk_in     => clk,
--			                          clk_out    => clk4M
--		                              );

clk4M <= clk;

core_inst <= pm_dout;	

AVR_Core_Inst:component AVR_Core port map(
                                          --Clock and reset
                                          cp2      => core_cp2,
										  cp2en    => vcc,
                                          ireset   => core_ireset,
										  -- JTAG OCD support
					                      valid_instr => open,
						                  insert_nop  => gnd,
						                  block_irq   => gnd,
						                  change_flow => open,
				                          -- Program Memory
                                          pc       => core_pc,
                                          inst     => core_inst,
										  -- I/O control
                                          adr      => core_adr,
                                          iore     => core_iore,
                                          iowe     => core_iowe,
					                      -- Data memory control
                                          ramadr   => core_ramadr,
                                          ramre    => core_ramre,
                                          ramwe    => core_ramwe,
                                          cpuwait  => core_cpuwait,
                      					  -- Data paths
                                          dbusin   => core_dbusin,
                                          dbusout  => core_dbusout,
			                              -- Interrupts
                                          irqlines => core_irqlines, 
                                          irqack   => core_irqack,
                                          irqackad => core_irqackad, 
										  --Sleep Control
                                          sleepi   => sleepi,
                                          irqok	   => irqok,
                                          globint  => globint,
                                          --Watchdog
                                          wdri	   => core_wdri);
										  

RAM_Data_Register:component RAMDataReg port map(	                   
               ireset      => core_ireset,
               cp2	       => clk4M, -- clk,
               cpuwait     => core_cpuwait,
			   RAMDataIn   => core_dbusout,
			   RAMDataOut  => ram_din
	                     );



EXT_MUX:component external_mux port map(
		  ramre              => mem_ramre,		   -- ramre output of the arbiter and multiplexor
		  dbus_out           => core_dbusin,       -- Data input of the core 
		  ram_data_out       => mem_mux_out,       -- Data output of the RAM mux(RAM or memory located I/O)
		  io_port_bus        => io_port_out,       -- Data outputs of the I/O
		  io_port_en_bus     => io_port_out_en,    -- Out enable outputs of I/O
		  irqack             => core_irqack,		  
		  irqackad			 => core_irqackad,
		  ind_irq_ack		 =>	ind_irq_ack		  -- Individual interrupt acknolege for the peripheral
                                            );


-- ******************  PORTA **************************				
PORTA_Impl:if CImplPORTA generate
PORTA_COMP:component pport  
	generic map(PPortNum => 0)
	port map(
	                   -- AVR Control
               ireset     => core_ireset,
               cp2	      => clk4M, -- clk,
               adr        => core_adr,
               dbus_in    => core_dbusout,
               dbus_out   => porta_dbusout,
               iore       => core_iore,
               iowe       => core_iowe,
               out_en     => porta_out_en,
			            -- External connection
			   portx      => PortAReg,
			   ddrx       => DDRAReg,
			   pinx       => porta);

-- PORTA connection to the external multiplexer
io_port_out(0) <= porta_dbusout;
io_port_out_en(0) <= porta_out_en;

-- Tri-state control for PORTA
PortAZCtrl:for i in porta'range generate
porta(i) <= PortAReg(i) when DDRAReg(i)='1' else 'Z'; 	
end generate;

end generate;

PORTA_Not_Impl:if not CImplPORTA generate
 porta <= (others => 'Z');	
end generate; 

-- ******************  PORTB **************************		
PORTB_Impl:if CImplPORTB generate
PORTB_COMP:component pport 
	generic map (PPortNum => 1)
	port map(
	                   -- AVR Control
               ireset     => core_ireset,
               cp2	      => clk4M, -- clk, 
               adr        => core_adr,
               dbus_in    => core_dbusout,
               dbus_out   => portb_dbusout,
               iore       => core_iore,
               iowe       => core_iowe,
               out_en     => portb_out_en,
			            -- External connection
			   portx      => PortBReg,
			   ddrx       => DDRBReg,
			   pinx       => portb);

-- PORTB connection to the external multiplexer
io_port_out(1) <= portb_dbusout;
io_port_out_en(1) <= portb_out_en;

-- Tri-state control for PORTB
PortBZCtrl:for i in portb'range generate
portb(i) <= PortBReg(i) when DDRBReg(i)='1' else 'Z'; 	
end generate;

end generate;

PORTB_Not_Impl:if not CImplPORTB generate
 portb <= (others => 'Z');	
end generate; 
	
-- ************************************************

-- Unused IRQ lines
core_irqlines(7 downto 4) <= ( others => '0');
core_irqlines(3 downto 0) <= ( others => '0');
core_irqlines(13 downto 10) <= ( others => '0');
core_irqlines(16) <= '0';
core_irqlines(22 downto 20) <= ( others => '0');
-- ************************

-- Unused out_en
io_port_out_en(5 to 15) <= (others => '0');
io_port_out(5 to 15) <= (others => (others => '0'));



--****************** Timer/Counter **************************
TmrCnt_Impl:if CImplTmrCnt generate
TmrCnt_Inst:component Timer_Counter port map(
	           -- AVR Control
               ireset     => core_ireset,
               cp2	      => clk4M, -- clk,
			   cp2en	  => vcc,
			   tmr_cp2en  => vcc,
			   stopped_mode   => gnd,
			   tmr_running    => gnd,
               adr        => core_adr,
               dbus_in    => core_dbusout,
               dbus_out   => tc_dbusout, 
               iore       => core_iore,
               iowe       => core_iowe,
               out_en     => tc_out_en,
			   -- External inputs/outputs
               EXT1           => gnd,
               EXT2           => gnd,
			   OC0_PWM0       => open,
			   OC1A_PWM1A     => open,
			   OC1B_PWM1B     => open,
			   OC2_PWM2       => open,
			   -- Interrupt related signals
               TC0OvfIRQ      => core_irqlines(15),  -- Timer/Counter0 overflow ($0020)
			   TC0OvfIRQ_Ack  => ind_irq_ack(15),
			   TC0CmpIRQ      => core_irqlines(14),  -- Timer/Counter0 Compare Match ($001E)
			   TC0CmpIRQ_Ack  => ind_irq_ack(14),
			   TC2OvfIRQ      => core_irqlines(9),	-- Timer/Counter2 overflow ($0014)
			   TC2OvfIRQ_Ack  => ind_irq_ack(9),
			   TC2CmpIRQ      => core_irqlines(8),	-- Timer/Counter2 Compare Match ($0012)
			   TC2CmpIRQ_Ack  => ind_irq_ack(8),
			   TC1OvfIRQ      => open,
			   TC1OvfIRQ_Ack  => gnd,
			   TC1CmpAIRQ     => open,
			   TC1CmpAIRQ_Ack => gnd,
			   TC1CmpBIRQ     => open,
			   TC1CmpBIRQ_Ack => gnd,
			   TC1ICIRQ       => open,
			   TC1ICIRQ_Ack   => gnd);

-- Timer/Counter connection to the external multiplexer							  
io_port_out(4)    <= tc_dbusout;
io_port_out_en(4) <= tc_out_en;
end generate;

-- Watchdog is not implemented
wdtmout <= '0';


-- Reset generator						 
ResetGenerator_Inst:component ResetGenerator port map(
	                            -- Clock inputs
								cp2	       => clk4M, -- clk,
								cp64m	   => gnd,
								-- Reset inputs
	                            nrst       => nrst,
								npwrrst    => vcc,
								wdovf      => wdtmout,
			                    jtagrst    => JTAG_Rst,
      							-- Reset outputs
					            nrst_cp2   => core_ireset,
			                    nrst_cp64m => nrst_cp64m_tmp,
								nrst_clksw => nrst_clksw
								);

						   
ClockGatingDis:if not CImplClockSw generate
 -- core_cp2 <= clk;
 core_cp2 <=  clk4M;
end generate;

-- **********************  JTAG and memory **********************************************

-- ram_cp2_n <= not clk;
ram_cp2_n <= not clk4M;

FirsMemConfig:if C_OrgMemCfg generate
-- The first memory configuration (PM 16Kx16/DM 16Kx8)
-- Data memory(8-bit)					   
DRAM_Inst:component XDM16Kx8 port map(
	                    cp2       => ram_cp2_n,
						ce        => vcc,
	                    address   => mem_ramadr(13 downto 0), 
					    din       => mem_ram_dbus_in, 
					    dout      => mem_ram_dbus_out, 
					    we        => ram_ramwe
					   );
  
					   
-- Program memory					   
PM_Inst:component XPM16Kx16 port map(
	                  cp2     => ram_cp2_n, 
					  ce      => vcc,
	                  address => pm_adr(13 downto 0),
					  din     => pm_din,
					  dout    => pm_dout,
					  weh     => pm_h_we,
					  wel     => pm_l_we
					  );
end generate;


SecondMemConfig:if not C_OrgMemCfg generate
-- The second memory configuration (PM 8Kx16/DM 32Kx8)
-- Data memory(8-bit)					   
DRAM_Inst:component XDM32Kx8 port map(
	                    cp2       => ram_cp2_n,
						ce        => vcc,
	                    address   => mem_ramadr(14 downto 0), 
					    din       => mem_ram_dbus_in, 
					    dout      => mem_ram_dbus_out, 
					    we        => ram_ramwe
					   );
  
					   
-- Program memory					   
PM_Inst:component XPM8Kx16 port map(
	                  cp2     => ram_cp2_n, 
					  ce      => vcc,
	                  address => pm_adr(12 downto 0),
					  din     => pm_din,
					  dout    => pm_dout,
					  weh     => pm_h_we,
					  wel     => pm_l_we
					  );
end generate;
					   
-- **********************  JTAG and memory **********************************************

-- Sleep mode is not implemented
sleep_mode <= '0';


JTAGOCDPrgTop_Inst:component JTAGOCDPrgTop port map(
	                      -- AVR Control
                          ireset       => core_ireset,
                          cp2	       => core_cp2,
						  -- JTAG related inputs/outputs
						  TRSTn        => TRSTn, -- Optional
	                      TMS          => TMS,
                          TCK	       => TCK,
                          TDI          => TDI,
                          TDO          => TDO_Out,
						  TDO_OE       => TDO_OE,
						  -- From the core
                          PC           => core_pc,
						  -- To the PM("Flash")
						  pm_adr       => pm_adr,
						  pm_h_we      => pm_h_we,
						  pm_l_we      => pm_l_we,
						  pm_dout      => pm_dout,
						  pm_din       => pm_din,
						  -- To the "EEPROM" 
						  EEPrgSel     => EEPrgSel,
						  EEAdr        => EEAdr,
						  EEWrData     => EEWrData,
						  EERdData     => EERdData,
						  EEWr         => EEWr,
						  -- CPU reset
						  jtag_rst     => JTAG_Rst
                          );

-- JTAG OCD module connection to the external multiplexer
io_port_out(3) <= (others => '0');
io_port_out_en(3) <= gnd;						  
						  
TDO <= TDO_Out when TDO_OE='1' else 'Z'; 						  

-- *******************************************************************************************************	
-- DMA, Memory decoder, ...
-- *******************************************************************************************************	


uart_Inst:component uart port map(
	                -- AVR Control
                    ireset     => core_ireset,
                    cp2	       => core_cp2,
                    adr        => core_adr,
                    dbus_in    => core_dbusout,
                    dbus_out   => uart_dbusout,
                    iore       => core_iore,
                    iowe       => core_iowe,
                    out_en     => uart_out_en,
                    -- UART
                    rxd        => rxd,
                    rx_en      => open,
                    txd        => txd,
                    tx_en      => open,
                    -- IRQ
                    txcirq     => core_irqlines(19),
                    txc_irqack => ind_irq_ack(19),
                    udreirq    => core_irqlines(18),
			        rxcirq     => core_irqlines(17)
		            );


-- UART connection to the external multiplexer							  
io_port_out(2)    <= uart_dbusout;
io_port_out_en(2) <= uart_out_en;


-- Arbiter and mux
ArbiterAndMux_Inst:component ArbiterAndMux port map(
                        --Clock and reset
						ireset      => core_ireset,
						cp2         => core_cp2,
					    -- Bus masters
                        busmin		=> busmin,
						busmwait	=> busmwait,
						-- Memory Address,Data and Control
						ramadr     => mem_ramadr,
						ramdout    => mem_ram_dbus_in,
                        ramre      => mem_ramre,
                        ramwe      => mem_ramwe,
						cpuwait    => slv_cpuwait
						);

-- cpuwait 
slv_cpuwait <= '0';
						
-- Core connection						
busmin(0).ramadr <= core_ramadr; 						
busmin(0).dout   <=	ram_din; -- !!!
busmin(0).ramre  <=	core_ramre;
busmin(0).ramwe  <=	core_ramwe;				
core_cpuwait     <=	busmwait(0);

-- UART DMA connection						
busmin(1).ramadr <= (others => '0'); 						
busmin(1).dout   <=	(others => '0'); -- !!!
busmin(1).ramre  <=	gnd;
busmin(1).ramwe  <=	gnd;				
udma_mack        <=  not busmwait(1);

-- AES DMA connection
busmin(2).ramadr <= (others => '0');		
busmin(2).dout   <=	(others => '0');
busmin(2).ramre  <=	gnd;
busmin(2).ramwe  <=	gnd;
aes_mack         <=  not busmwait(2);

-- UART DMA slave part
slv_outs(0).dout    <= (others => '0');
slv_outs(0).out_en 	<= gnd;	

-- AES DMA slave part
slv_outs(1).dout    <= (others => '0');
slv_outs(1).out_en 	<= gnd;	


-- Memory read mux
MemRdMux_inst:component MemRdMux port map(
	                    slv_outs  =>  slv_outs,
						ram_sel   =>  ram_sel,    -- Data RAM selection(optional input)
	                    ram_dout  =>  mem_ram_dbus_out,            -- Data memory output (From RAM)
						dout      =>  mem_mux_out -- Data output (To the core and other bus masters)
						);



-- Address decoder
RAMAdrDcd_Inst:component RAMAdrDcd port map(
                         ramadr    => mem_ramadr, 
		                 ramre     => mem_ramre,
		                 ramwe     => mem_ramwe,
		                 -- Memory mapped I/O i/f
		                 stb_IO	   => stb_IO,
		                 stb_IOmod => stb_IOmod,
	                     -- Data memory i/f
		                 ram_we    => ram_ramwe,
		                 ram_ce    => ram_ce,
						 ram_sel   => ram_sel
		                );


-- Given for the purpose of test only
--RAM_Inst:component RAM generic map(RAMSize => CRAMSize)
--	               port map(
--                        cp2     => cp2,
--  	                    ramadr  => mem_ramadr(LOG2(CRAMSize)-1 downto 0),
--		                din     => mem_ram_dbus_in,
--		                dout    => mem_ram_dbus_out,
--						ramwe   => ram_ramwe 
--					    );							   
							   
	
	
end Struct;
