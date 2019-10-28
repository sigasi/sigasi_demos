--------------------------------------------------------------------------------


LIBRARY ieee;
library std;
library work;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std.unsigned;
use work.VME_CR_pack.all;
use work.VME_CSR_pack.all; 
use work.VME64xSim.all;
use work.VME64x.all;
use work.wishbone_pkg.all;
use std.textio.all; 
use work.vme64x_pack.all; 

ENTITY VME64x_TB IS
   END VME64x_TB;

ARCHITECTURE behavior OF VME64x_TB IS 

    -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT TOP_LEVEL
	PORT(
		clk_i : IN std_logic;
		Reset : IN std_logic;
		VME_AS_n_i : IN std_logic;
		VME_RST_n_i : IN std_logic;
		VME_WRITE_n_i : IN std_logic;
		VME_AM_i : IN std_logic_vector(5 downto 0);
		VME_DS_n_i : IN std_logic_vector(1 downto 0);
		VME_GA_i : IN std_logic_vector(5 downto 0);
		VME_IACKIN_n_i : IN std_logic;
		VME_IACK_n_i : IN std_logic;    
		VME_LWORD_n_b : INOUT std_logic;
		VME_ADDR_b : INOUT std_logic_vector(31 downto 1);
		VME_DATA_b : INOUT std_logic_vector(31 downto 0);      
		VME_BERR_o : OUT std_logic;
		VME_DTACK_n_o : OUT std_logic;
		VME_RETRY_n_o : OUT std_logic;
		VME_IRQ_n_o : OUT std_logic_vector(6 downto 0);
		VME_IACKOUT_n_o : OUT std_logic;
		VME_RETRY_OE_o : OUT std_logic;
		VME_DTACK_OE_o : OUT std_logic;
		VME_DATA_DIR_o : OUT std_logic;
		VME_DATA_OE_N_o : OUT std_logic;
		VME_ADDR_DIR_o : OUT std_logic;
		VME_ADDR_OE_N_o : OUT std_logic;
		leds : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;


   --Inputs
   signal clk_i          : std_logic := '0';
   signal VME_AS_n_i     : std_logic := '0';
   signal VME_RST_n_i    : std_logic := '0';
   signal VME_WRITE_n_i  : std_logic := '0';
   signal VME_AM_i       : std_logic_vector(5 downto 0) := (others => '0');
   signal VME_DS_n_i     : std_logic_vector(1 downto 0) := (others => '0');
   signal VME_GA_i       : std_logic_vector(5 downto 0) := (others => '0');
   signal VME_BBSY_n_i   : std_logic := '0';
   signal VME_IACKIN_n_i : std_logic := '1';
   signal VME_IACK_n_i  : std_logic := '1';
   signal Reset         : std_logic := '1';

   --BiDirs
   signal VME_LWORD_n_b : std_logic;
   signal VME_ADDR_b : std_logic_vector(31 downto 1);
   signal VME_DATA_b : std_logic_vector(31 downto 0);

   --Outputs
   signal VME_BERR_o : std_logic;
   signal VME_DTACK_n_o : std_logic;
   signal VME_RETRY_n_o : std_logic;
   signal VME_RETRY_OE_o : std_logic;
   signal VME_IRQ_n_o : std_logic_vector(6 downto 0);
   signal VME_IACKOUT_n_o : std_logic;
   signal VME_DTACK_OE_o : std_logic;
   signal VME_DATA_DIR_o : std_logic;
   signal VME_DATA_OE_N_o : std_logic;
   signal VME_ADDR_DIR_o : std_logic;
   signal VME_ADDR_OE_N_o : std_logic;

   -- Flags
   signal ReadInProgress : std_logic := '0';	
   signal WriteInProgress : std_logic := '0';
   
   signal s_Buffer_BLT : t_Buffer_BLT;
   signal s_Buffer_MBLT : t_Buffer_MBLT;
   signal s_dataTransferType : t_dataTransferType;
   signal s_AddressingType : t_Addressing_Type;
   
   -- Control signals
   signal s_dataToSendOut : std_logic_vector(31 downto 0);
   signal s_dataToSend 	: std_logic_vector(31 downto 0);
   signal s_dataToReceive 	: std_logic_vector(31 downto 0);
   signal s_address 	: std_logic_vector(63 downto 0);
   signal localAddress : std_logic_vector(19 downto 0);
   signal s_num : std_logic_vector(8 downto 0);
   signal s_temp : std_logic_vector(31 downto 0);
   signal s_beat_count : std_logic_vector(7 downto 0);
   -- Records
   signal VME64xBus_out	: VME64xBusOut_Record;
   signal VME64xBus_in	: VME64xBusIn_Record;

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;

BEGIN
-- Instantiate the Unit Under Test (UUT)
   uut: TOP_LEVEL PORT MAP(
		clk_i => clk_i,
		Reset => Reset,
		VME_AS_n_i => VME_AS_n_i,
		VME_RST_n_i => VME_RST_n_i,
		VME_WRITE_n_i => VME_WRITE_n_i,
		VME_AM_i => VME_AM_i,
		VME_DS_n_i => VME_DS_n_i,
		VME_GA_i => VME_GA_i,
		VME_BERR_o => VME_BERR_o,
		VME_DTACK_n_o => VME_DTACK_n_o,
		VME_RETRY_n_o => VME_RETRY_n_o,
		VME_LWORD_n_b => VME_LWORD_n_b,
		VME_ADDR_b => VME_ADDR_b,
		VME_DATA_b => VME_DATA_b,
		VME_IRQ_n_o => VME_IRQ_n_o,
		VME_IACKIN_n_i => VME_IACKIN_n_i,
		VME_IACKOUT_n_o => VME_IACKOUT_n_o,
		VME_IACK_n_i => VME_IACK_n_i,
		VME_RETRY_OE_o => VME_RETRY_OE_o,
		VME_DTACK_OE_o => VME_DTACK_OE_o,
		VME_DATA_DIR_o => VME_DATA_DIR_o,
		VME_DATA_OE_N_o => VME_DATA_OE_N_o,
		VME_ADDR_DIR_o => VME_ADDR_DIR_o,
		VME_ADDR_OE_N_o => VME_ADDR_OE_N_o,
		leds => open
		);


   VME_IACKIN_n_i <=  VME64xBus_out.Vme64xIACKIN;		
   VME_IACK_n_i   <=  VME64xBus_out.Vme64xIACK;
   VME_AS_n_i     <=  VME64xBus_out.Vme64xAsN;
   VME_WRITE_n_i	<=  VME64xBus_out.Vme64xWRITEN;
   VME_AM_i			<=  VME64xBus_out.Vme64xAM;
   VME_DS_n_i(1)	<=  VME64xBus_out.Vme64xDs1N;
   VME_DS_n_i(0)	<=  VME64xBus_out.Vme64xDs0N;
   VME_LWORD_n_b	<=  VME64xBus_out.Vme64xLWORDN when VME_ADDR_DIR_o = '0' else 'Z';
   VME64xBus_in.Vme64xLWORDN  <= VME_LWORD_n_b;
   VME_ADDR_b		<=  VME64xBus_out.Vme64xADDR when VME_ADDR_DIR_o = '0'  else (others => 'Z');
   VME64xBus_in.Vme64xADDR <= VME_ADDR_b;
   VME_DATA_b <= VME64xBus_out.Vme64xDATA  when VME_DATA_DIR_o = '0'  else (others => 'Z');		 
   VME64xBus_in.Vme64xDATA  <=  VME_DATA_b;
   VME64xBus_in.Vme64xDtackN <= VME_DTACK_n_o;
   VME64xBus_in.Vme64xBerrN <= VME_BERR_o;
   VME64xBus_in.Vme64xRetryN <= VME_RETRY_n_o;
   VME64xBus_in.Vme64xIRQ <= VME_IRQ_n_o;
   VME64xBus_in.Vme64xIACKOUT <= VME_IACKOUT_n_o;

   -- Clock process definitions
   clk_i_process :process
   begin
      clk_i <= '0';
      wait for clk_i_period/2;
      clk_i <= '1';
      wait for clk_i_period/2;
   end process;

   test_VME64x : process
      
   begin

      wait for 8800 ns;  -- wait until the initialization finish (wait more than 8705 ns)
                         -- Write in CSR:
      VME64xBus_Out.Vme64xIACK <= '1';
      VME64xBus_Out.Vme64xIACKIN <= '1';
      report "START READ CSR";

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

         -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
      s_dataToReceive <= x"00000040";
      ReadCR_CSR(c_address	=> c_BAR, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);

                        --	wait for 30 ns;	
                        --		s_dataTransferType <= D32;
                        --      s_AddressingType   <= CR_CSR;

                        -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
                        --     s_dataToReceive <= x"00000002";
                        --     ReadCR_CSR(c_address	=> c_MBLT_Endian, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
                        --     s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
                        --     VME64xBus_Out => VME64xBus_Out);


                        --     wait for 30 ns;	
                        --			s_dataTransferType <= D32;
                        --         s_AddressingType   <= CR_CSR;

                        -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
                        --         s_dataToReceive <= x"00000052";
                        --         ReadCR_CSR(c_address	=> std_logic_vector(to_unsigned((8*4) , 20)), s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
                        --         VME64xBus_Out => VME64xBus_Out);

                        --
                        --         wait for 30 ns;	
                        --			
                        --			s_dataTransferType <= D08Byte3;
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --        -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
                        --         s_dataToReceive <= x"00000024";
                        --         ReadCR_CSR(c_address	=> c_FUNC0_ADER_0, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
                        --         VME64xBus_Out => VME64xBus_Out);
                        --			
                        --			wait for 30 ns;
                        --			
                        --			--read ADER0:
                        --			
                        --			s_dataTransferType <= D08Byte3;
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --        -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
                        --         s_dataToReceive <= x"000000c0";
                        --         ReadCR_CSR(c_address	=> c_FUNC0_ADER_3, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
                        --         VME64xBus_Out => VME64xBus_Out);
                        --			
                        --			wait for 30 ns;
                        --			
                        --			s_dataTransferType <= D08Byte3;
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --        -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
                        --         s_dataToReceive <= x"00000000";
                        --         ReadCR_CSR(c_address	=> c_FUNC0_ADER_2, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
                        --         VME64xBus_Out => VME64xBus_Out);
                        --			
                        --			wait for 30 ns;
                        --			
                        --			s_dataTransferType <= D08Byte3;
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --        -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
                        --         s_dataToReceive <= x"00000000";
                        --         ReadCR_CSR(c_address	=> c_FUNC0_ADER_1, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
                        --         VME64xBus_Out => VME64xBus_Out);
                        --			
                        --			wait for 30 ns;
                        --			

      report "START WRITE CSR";

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"00000000";  -- Put the data to send in the 8 lsb.
      WriteCSR(c_address	=> c_BIT_CLR_REG , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);
      report "END WRITE CSR";	
      wait for 0 ns;
      report "START READ CSR";

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

         -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
      s_dataToReceive <= x"00000000";
      ReadCR_CSR(c_address	=> c_USR_BIT_SET_REG, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);


      report "END READ CSR";		
      wait for 10 ns;
      s_dataToReceive <= (others => '0');
      wait for 10 ns;

            --   	report "PROVA READ CR============================================================================================================================================";
            --      s_dataTransferType <= D08Byte3;
            --     s_AddressingType   <= CR_CSR;
            --   	  s_dataToReceive(7 downto 0) <= c_cr_array(7);
            --   	  wait for 10 ns;
            --   	  assert (s_dataToReceive = x"00000043")report "FERMA" severity failure;
            --     ReadCR_CSR(c_address	=> std_logic_vector(to_unsigned((7*4) +3, 20)), s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
            --   				s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
            --   				VME64xBus_Out => VME64xBus_Out);
            --   	report "END PROVA READ CR";
--      report "PROVA ERROR ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????";
--
--      s_dataTransferType <= D08Byte3;
--      s_AddressingType   <= CR_CSR;
--
--            -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
--      s_dataToReceive <= x"00000000";
--      ReadCR_CSR(c_address	=> c_BIT_SET_REG, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
--      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
--      VME64xBus_Out => VME64xBus_Out);
--
--      wait for 30 ns; 
--
--      s_dataTransferType <= D08Byte3;
--      s_AddressingType   <= CR_CSR;
--
--            -- Put the data to receive in the 8 lsb also if you are using D08Byte1 or D08Byte2 ecc..
--      s_dataToReceive <= x"00000010";
--      ReadCR_CSR(c_address	=> c_BIT_SET_REG, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
--      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
--      VME64xBus_Out => VME64xBus_Out);
--
--
--      report "FINE PROVA ERROR????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????";
--

      wait for 50 ns;
        --	report "START READ CR";
        --	     s_dataTransferType <= D08Byte3;
        --        s_AddressingType   <= CR_CSR;
        --	     s_dataToReceive    <= (others => '0');
        --	     ControlCR (s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType,VME64xBus_In => VME64xBus_In,s_dataToReceive => s_dataToReceive, VME64xBus_Out => VME64xBus_Out);
        --	report  "END READ CR";
        -- The read in the CR work correctly!
        --	wait for 50ns;
        -- Test CRAM
      report "START TEST CRAM **************************************************************************************************************";
      -- The master read the CRAM_ACCESS_WIDTH
      wait for 30 ns;
      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;
      s_dataToReceive <= x"00000084";
      ReadCR_CSR(c_address	=> std_logic_vector(to_unsigned((63*4) +3, 20)), s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 30 ns;

        --The Master writes CRAM_OWNER
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ID_Master;  -- Put the data to send in the 8 lsb.
      WriteCSR(c_address	=> c_CRAM_OWNER  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);
      report "Master has written the CRAM_OWNER *************************************************************************************************";			
      --The Master read the CRAM_OWNER for check his ownership	
      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToReceive <= x"000000" & ID_Master;
      ReadCR_CSR(c_address	=> c_CRAM_OWNER, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);
      report "Master has the ownership of the CRAM memory ******************************************************************************************";			
        --if I'm here the Master has the ownership of the CRAM memory
        -- Check if the BIT_SET_REG's bit 2 is set
      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToReceive <= x"000000" & b"00000100";
      ReadCR_CSR(c_address	=> c_BIT_SET_REG, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);
      report "BIT_SET_REG's bit 2 is set ***************************************************************************************************************";			
        -- The Master writes one register in the CRAM space	

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;
      s_dataToSend <= x"000000AA";
      localAddress <= x"01007";
      WriteCSR(c_address	=> localAddress , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);
      report "End write in CRAM ************************************************************************************************************************";			
      wait for 50 ns;
      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;
      s_dataToReceive    <= x"000000AA";
             -- Check the CRAM's lower limit: 
             --localAddress <= x"00FFF";  -- CR addressed !!!
             --ReadCR_CSR(c_address	=> localAddress, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
             --	    s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
             --	    VME64xBus_Out => VME64xBus_Out);
             -- Failure; received wrong data!!
             --	wait for 50 ns;
             -- Check the CRAM's upper limit:
             --localAddress <= x"7FFEB";  -- CSR addressed!!
             --ReadCR_CSR(c_address	=> localAddress, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
             --	     s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
             --	     VME64xBus_Out => VME64xBus_Out);
             -- Failure; received wrong data!!
             -- La CRAM non è indirizzata ma comunque la Main FSM percorre tutti gli stadi della lettura
             -- e il dato che leggo è un dato della CR o CSR quindi leggo il dato errato.				

             --	wait for 50 ns;
             -- read x"000000AA":
      localAddress <= x"01007";
      ReadCR_CSR(c_address	=> localAddress, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);
      report "READ CRAM CORRECT **********************************************************************************************************************************************";			 
      wait for 50 ns; 

        -- If i'm here without severity failure the CRAM work correctly.
        --	report "CRAM access fixed correctly";
        -- The Master can release the CRAM writing '0' in the BIT_SET_REG's bit 2 (or writing '1'in the BIT_CLR_REG's bit 2):
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & b"00000100";  
      WriteCSR(c_address	=> c_BIT_CLR_REG  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);
      report "Master released the CRAM **********************************************************************************************************************************************";			
      -- Check if the CRAM_OWNER is x"00":

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToReceive <= x"00000000";
      ReadCR_CSR(c_address	=> c_CRAM_OWNER, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);
      report "END TEST CRAM *************************************************************************************************************************************************************";			
         --	wait for 50 ns;
         --	report "START TEST Berr";
         --	s_dataTransferType <= D08Byte3;

         -- s_AddressingType   <= error;

         --	s_dataToSend <= x"000000" & b"00000100";  
         --	WriteCSR(c_address	=> c_BIT_CLR_REG  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --				s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --				VME64xBus_Out => VME64xBus_Out);

         -- I have inserted here a read procedure for test if the slave go out of the Berr status correctly
         -- and check if the master can read a new data immediately, without wait.	
         --	s_dataTransferType <= D08Byte3;
         --  s_AddressingType   <= CR_CSR;

         --	s_dataToReceive <= x"00000000";
         --   ReadCR_CSR(c_address	=> c_CRAM_OWNER, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
         --				s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --				VME64xBus_Out => VME64xBus_Out);			
         --	report "END TEST Berr";
      wait for 50 ns;
      report "START TEST TRANSFER DATA FROM VME TO WB";
         -- Before the Master has to write the ADERs.


         -- start write ADER0
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A16_S(31 downto 24);  
      WriteCSR(c_address	=> c_FUNC2_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A16_S(23 downto 16);  
      WriteCSR(c_address	=> c_FUNC2_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A16_S(15 downto 8);  
      WriteCSR(c_address	=> c_FUNC2_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A16_S(7 downto 0);  
      WriteCSR(c_address	=> c_FUNC2_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);		

      wait for 20 ns;
         -- start write ADER1
         --         s_dataTransferType <= D08Byte3;

         --        s_AddressingType   <= CR_CSR;

         --        s_dataToSend <= x"000000" & ADER1_A64(31 downto 24);  
         --         WriteCSR(c_address	=> c_FUNC1_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER1_A64(23 downto 16);  
         --         WriteCSR(c_address	=> c_FUNC1_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER1_A64(15 downto 8);  
         --         WriteCSR(c_address	=> c_FUNC1_ADER_1 , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER1_A64(7 downto 0);  
         --         WriteCSR(c_address	=> c_FUNC1_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
         --         VME64xBus_Out => VME64xBus_Out);		
         --
         --        -- start write ADER2 (ADER1_b)
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER1_A64_b(31 downto 24);  
         --         WriteCSR(c_address	=> c_FUNC2_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER1_A64_b(23 downto 16);  
         --         WriteCSR(c_address	=> c_FUNC2_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER1_A64_b(15 downto 8);  
         --         WriteCSR(c_address	=> c_FUNC2_ADER_1 , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER1_A64_b(7 downto 0);  
         --         WriteCSR(c_address	=> c_FUNC2_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);	
         --   -- start write ADER3
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER2_A32_2eVME(31 downto 24);  
         --         WriteCSR(c_address	=> c_FUNC3_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER2_A32_2eVME(23 downto 16);  
         --         WriteCSR(c_address	=> c_FUNC3_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER2_A32_2eVME(15 downto 8);  
         --         WriteCSR(c_address	=> c_FUNC3_ADER_1 , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER2_A32_2eVME(7 downto 0);  
         --         WriteCSR(c_address	=> c_FUNC3_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);		
         --        -- start write ADER4 (ADER2_b)
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER2_2e_b(31 downto 24);  
         --         WriteCSR(c_address	=> c_FUNC4_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER2_2e_b(23 downto 16);  
         --         WriteCSR(c_address	=> c_FUNC4_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER2_2e_b(15 downto 8);  
         --         WriteCSR(c_address	=> c_FUNC4_ADER_1 , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);
         --
         --         wait for 20 ns;
         --
         --         s_dataTransferType <= D08Byte3;
         --
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToSend <= x"000000" & ADER2_2e_b(7 downto 0);  
         --         WriteCSR(c_address	=> c_FUNC4_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);		

         -- check some ADER byte :

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToReceive <= x"000000" & c_A16 &"00";
      ReadCR_CSR(c_address	=> c_FUNC2_ADER_0, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);
      report "FUNC0_ADER_0 Correct!!!!";			

      wait for 20 ns;

         --         s_dataTransferType <= D08Byte3;
         --         s_AddressingType   <= CR_CSR;
         --
         --         s_dataToReceive <= x"000000" & c_A64 &"00";
         --         ReadCR_CSR(c_address	=> c_FUNC1_ADER_0, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
         --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --         VME64xBus_Out => VME64xBus_Out);
         --         report "FUNC1_ADER_0 Correct!!!!";		
      report "THE MASTER HAS WRITTEN CORRECTLY ALL THE ADERs $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$";

         -- start write BAR
         --s_dataTransferType <= D08Byte3;

         --s_AddressingType   <= CR_CSR;

         --s_dataToSend <= x"000000" & BA_MyMemory;  
         --WriteCSR(c_address	=> c_BAR  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
         --s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         --VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;
                        -- Now also for read and write the CR/

                        -- START WRITE IN THE WB MEMORY
      report "START WRITE AND READ WB MEMORY YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY";
         -- The Master check if the WB data bus as 64 bit
	
--		s_dataTransferType <= D08Byte3;
--      s_AddressingType   <= CR_CSR;
--
--      s_dataToReceive <= x"00000001";
--      ReadCR_CSR(c_address	=> c_WB32or64, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
--      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
--      VME64xBus_Out => VME64xBus_Out);
--		
		-- Module Enabled:

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"00000010";  
      WriteCSR(c_address	=> c_BIT_SET_REG  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);	
		
      wait for 20 ns;

      s_dataTransferType <= D08Byte0;

      s_AddressingType   <= A16;

      s_dataToSend <= x"000000AB";  
      s_address  <= x"0000000000000008";

      S_Write(v_address	=> s_address  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	

      wait for 10 ns;			

      s_dataTransferType <= D08Byte1;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00000011";  
      s_address  <= x"0000000000000009";

      S_Write(v_address	=> s_address  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;			

      s_dataTransferType <= D08Byte2;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00000000";  
      s_address  <= x"000000000000000a";

      S_Write(v_address	=> s_address  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	

      wait for 10 ns;			

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00000022";  
      s_address  <= x"000000000000000b";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	

      wait for 10 ns;			

      s_dataTransferType <= D08Byte0;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00000002";  
      s_address  <= x"000000000000000c";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;			

      s_dataTransferType <= D08Byte1;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00000018";  
      s_address  <= x"000000000000000d";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;			

      s_dataTransferType <= D08Byte2;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00000032";  
      s_address  <= x"000000000000000e";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;			

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00000082";  
      s_address  <= x"000000000000000f";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);


      report "THE MASTER HAS WRITTEN 8 byte £££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££££";		

      s_dataTransferType <= D32;
      s_AddressingType   <= A16;
      s_address <= x"0000000000000008";
      s_dataToReceive <= x"AB110022";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

                        --wait for 10 ns;
                        -- s_dataTransferType <= D32;
                        -- s_AddressingType   <= A16;
                        -- s_address <= x"0000000000000002";
                        --s_dataToReceive <= x"AB";
                        --S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
                        -- s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D32;
      s_AddressingType   <= A16;
      s_address <= x"000000000000000c";
      s_dataToReceive <= x"02183282";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D16Byte01;
      s_AddressingType   <= A16;
      s_address <= x"0000000000000008";
      s_dataToReceive <= x"0000AB11";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D16Byte23;
      s_AddressingType   <= A16;
      s_address <= x"000000000000000a";
      s_dataToReceive <= x"00000022";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D16Byte01;
      s_AddressingType   <= A16;
      s_address <= x"000000000000000c";
      s_dataToReceive <= x"00000218";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D16Byte23;
      s_AddressingType   <= A16;
      s_address <= x"000000000000000e";
      s_dataToReceive <= x"00003282";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

                        --	wait for 10 ns;
                        --  s_dataTransferType <= D08Byte2;
                        --   s_AddressingType   <= A16;
                        --   s_address <= x"0000000000000004";
                        --   s_dataToReceive <= x"00000032";
                        --   S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
                        --   s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --    VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D08Byte0;
      s_AddressingType   <= A16;
      s_address <= x"000000000000000c";
      s_dataToReceive <= x"00000002";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D08Byte1;
      s_AddressingType   <= A16;
      s_address <= x"0000000000000008";
      s_dataToReceive <= x"00000011";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D08Byte1;
      s_AddressingType   <= A16;
      s_address <= x"0000000000000009";
      s_dataToReceive <= x"00000011";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      report "THE MASTER HAS RED CORRECTLY ALL THE BYTES PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP";		
         --  wait for 10 ns;
         -- s_dataTransferType <= D08Byte3;
         --  s_AddressingType   <= A16;
         -- s_address <= x"0000000000000002";
         -- s_dataToReceive <= x"00000022";  
         --  S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
         -- s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
         -- VME64xBus_Out => VME64xBus_Out);
         -- The Byte x"22" is put in the DTB's bits 7-0 			
      wait for 10 ns;			


         --  wait for 10 ns;			

      s_dataTransferType <= D16Byte01;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00001308";  
      s_address  <= x"0000000000000008";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;			

      s_dataTransferType <= D16Byte23;

      s_AddressingType   <= A16;

      s_dataToSend <= x"00001987";  
      s_address  <= x"000000000000000A";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);


      wait for 10 ns;			

      s_dataTransferType <= D32;

      s_AddressingType   <= A16;

      s_dataToSend <= x"56781234";  
      s_address  <= x"0000000000000014";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D16Byte01;
      s_AddressingType   <= A16;
      s_address <= x"0000000000000008";
      s_dataToReceive <= x"00001308";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D32;
      s_AddressingType   <= A16;
      s_address <= x"0000000000000014";
      s_dataToReceive <= x"56781234";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

                         --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                         --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                         -- The Master write again the ADER 1 for access with A24 mode!
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A24_S(31 downto 24);  
      WriteCSR(c_address	=> c_FUNC1_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A24_S(23 downto 16);  
      WriteCSR(c_address	=> c_FUNC1_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A24_S(15 downto 8);  
      WriteCSR(c_address	=> c_FUNC1_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A24_S(7 downto 0);  
      WriteCSR(c_address	=> c_FUNC1_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);		

      wait for 10 ns;
         -- write a new value for test A24 mode 

      s_dataTransferType <= D32;

      s_AddressingType   <= A24;

      s_dataToSend <= x"33221100";  
      s_address  <= x"0000000000000018";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	

      wait for 10 ns;
      s_dataTransferType <= D32;

      s_AddressingType   <= A24;

      s_dataToSend <= x"08080808";  
      s_address  <= x"000000000000001c";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	

      wait for 10 ns;
      s_dataTransferType <= D32;
      s_AddressingType   <= A24;
      s_address <= x"0000000000000018";
      s_dataToReceive <= x"33221100";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D16Byte01;
      s_AddressingType   <= A24;
      s_address <= x"000000000000001c";
      s_dataToReceive <= x"00000808";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D08Byte0;
      s_AddressingType   <= A24;
      s_address <= x"000000000000001c";
      s_dataToReceive <= x"00000008";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D08Byte2;
      s_AddressingType   <= A24;
      s_address <= x"000000000000001a";
      s_dataToReceive <= x"00000011";
      S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

         -- A32 mode tested on board
         --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         --		  START TEST BLT TRANSFER



      for i in 64 downto 1 loop
         s_Buffer_BLT(i) <= (others => '0');
      end loop;
      s_Buffer_BLT(0) <= x"12345678";
      s_Buffer_BLT(1) <= x"23456781";
      s_Buffer_BLT(2) <= x"34567812";
      s_Buffer_BLT(3) <= x"45678123";
      s_Buffer_BLT(4) <= x"56781234";
      s_Buffer_BLT(5) <= x"67812345";
      s_Buffer_BLT(6) <= x"78123456";
      s_Buffer_BLT(7) <= x"81234567";
      s_Buffer_BLT(8) <= x"12345678";
      s_Buffer_BLT(9) <= x"23456781";
      s_Buffer_BLT(10) <= x"34567812";
      s_Buffer_BLT(11) <= x"45678123";
      s_Buffer_BLT(12) <= x"56781234";
      s_Buffer_BLT(13) <= x"67812345";
      s_Buffer_BLT(14) <= x"78123456";
      s_Buffer_BLT(15) <= x"81234567";
      s_Buffer_BLT(16) <= x"12345678";
      s_Buffer_BLT(17) <= x"23456781";
      s_Buffer_BLT(18) <= x"34567812";
      s_Buffer_BLT(19) <= x"45678123";
      s_Buffer_BLT(20) <= x"56781234";
      s_Buffer_BLT(21) <= x"67812345";
      s_Buffer_BLT(22) <= x"78123456";
      s_Buffer_BLT(23) <= x"81234567";

      s_Buffer_BLT(24) <= x"12345678";
      s_Buffer_BLT(25) <= x"23456781";
      s_Buffer_BLT(26) <= x"34567812";
      s_Buffer_BLT(27) <= x"45678123";
      s_Buffer_BLT(28) <= x"56781234";
      s_Buffer_BLT(29) <= x"67812345";
      s_Buffer_BLT(30) <= x"78123456";
      s_Buffer_BLT(31) <= x"81234567";
      s_Buffer_BLT(32) <= x"12345678";
      s_Buffer_BLT(33) <= x"23456781";
      s_Buffer_BLT(34) <= x"34567812";
      s_Buffer_BLT(35) <= x"45678123";
      s_Buffer_BLT(36) <= x"56781234";
      s_Buffer_BLT(37) <= x"67812345";
      s_Buffer_BLT(38) <= x"78123456";
      s_Buffer_BLT(39) <= x"81234567";
      s_Buffer_BLT(40) <= x"12345678";
      s_Buffer_BLT(41) <= x"23456781";
      s_Buffer_BLT(42) <= x"34567812";
      s_Buffer_BLT(43) <= x"45678123";
      s_Buffer_BLT(44) <= x"56781234";
      s_Buffer_BLT(45) <= x"67812345";
      s_Buffer_BLT(46) <= x"78123456";
      s_Buffer_BLT(47) <= x"81234567";
      s_Buffer_BLT(48) <= x"23456781";
      s_Buffer_BLT(49) <= x"34567812";
      s_Buffer_BLT(50) <= x"45678123";
      s_Buffer_BLT(51) <= x"56781234";
      s_Buffer_BLT(52) <= x"67812345";
      s_Buffer_BLT(53) <= x"78123456";
      s_Buffer_BLT(54) <= x"81234567";
      s_Buffer_BLT(55) <= x"12345678";
      s_Buffer_BLT(56) <= x"23456781";
      s_Buffer_BLT(57) <= x"34567812";
      s_Buffer_BLT(58) <= x"45678123";
      s_Buffer_BLT(59) <= x"56781234";
      s_Buffer_BLT(60) <= x"67812345";
      s_Buffer_BLT(61) <= x"78123456";
      s_Buffer_BLT(62) <= x"81234567";
      s_Buffer_BLT(63) <= x"56781234";
      s_Buffer_BLT(64) <= x"67812345";
      s_Buffer_BLT(65) <= x"78123456";





                        ---the master write the ADER 0:
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32_BLT(31 downto 24);  
      WriteCSR(c_address	=> c_FUNC0_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32_BLT(23 downto 16);  
      WriteCSR(c_address	=> c_FUNC0_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32_BLT(15 downto 8);  
      WriteCSR(c_address	=> c_FUNC0_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32_BLT(7 downto 0);  
      WriteCSR(c_address	=> c_FUNC0_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);		


      s_dataTransferType <= D32; --only D32 is possible with BLT transfer 
      s_AddressingType   <= A32_BLT;
      s_address <= x"0000000000000010";
      s_num <= "100000001"; --Number of access; (max 64)
      Blt_write(v_address	=> s_address, s_Buffer_BLT => s_Buffer_BLT,
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType,
      num => s_num, VME64xBus_In => VME64xBus_In, VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_address <= x"0000000000000010"; -- use n+1 inside the function if I start to read from the second D32 word written
      s_num <= "000000100";

      Blt_Read(v_address	=> s_address, s_Buffer_BLT => s_Buffer_BLT,
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType,
      num => s_num, VME64xBus_In => VME64xBus_In, VME64xBus_Out => VME64xBus_Out);
                        -- Check error condition:
      wait for 10 ns;
      s_dataTransferType <= D08Byte3; --only D32 is possible with BLT transfer 
      s_AddressingType   <= A32_BLT;
      s_address <= x"0000000000000010";
      s_num <= "000000100";

      Blt_Read(v_address	=> s_address, s_Buffer_BLT => s_Buffer_BLT,
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType,
      num => s_num, VME64xBus_In => VME64xBus_In, VME64xBus_Out => VME64xBus_Out);

                        -- START TEST MBLT:
                        ---the master write the ADER 0:
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32_MBLT(31 downto 24);  
      WriteCSR(c_address	=> c_FUNC0_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32_MBLT(23 downto 16);  
      WriteCSR(c_address	=> c_FUNC0_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32_MBLT(15 downto 8);  
      WriteCSR(c_address	=> c_FUNC0_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32_MBLT(7 downto 0);  
      WriteCSR(c_address	=> c_FUNC0_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);		
                  -- ADER0 written
      wait for 20 ns;

      for i in 256 downto 0 loop
         s_Buffer_MBLT(i) <= (others => '0');
      end loop;

      s_Buffer_MBLT(0) <= x"0123456789ABCDEF";
      s_Buffer_MBLT(1) <= x"123456789ABCDEF0";
      s_Buffer_MBLT(2) <= x"23456789ABCDEF01";
      s_Buffer_MBLT(3) <= x"3456789ABCDEF012";
      s_Buffer_MBLT(4) <= x"456789ABCDEF0123";
      s_Buffer_MBLT(5) <= x"56789ABCDEF01234";
      s_Buffer_MBLT(6) <= x"6789ABCDEF012345";
      s_Buffer_MBLT(7) <= x"789ABCDEF0123456";


      s_dataTransferType <= D32;  -- Data transfer type is D32 also if the data width is 64!!
      s_AddressingType   <= A32_MBLT;
      s_address <= x"0000000000000010"; --Put here a multiple of 8!!!
      s_num <= "000001000";   -- max 256;

      Mblt_write(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,  -- this procedure is for A16, A24, A32 address type
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType, num => s_num, 
      VME64xBus_In => VME64xBus_in, VME64xBus_Out => VME64xBus_Out);
      wait for 20 ns;

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;
      s_dataToReceive <= x"00000040";
      ReadCR_CSR(c_address	=> c_BYTES0, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);

      s_dataTransferType <= D32;  -- Data transfer type is D32 also if the data width is 64!!
      s_AddressingType   <= A32_MBLT;
      s_address <= x"0000000000000010"; --Put here a multiple of 8!!!
      s_num <= "000000011";   -- max 256;

      Mblt_Read(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,  -- this procedure is for A16, A24, A32 address type
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType, num => s_num, 
      VME64xBus_In => VME64xBus_in, VME64xBus_Out => VME64xBus_Out);

      for i in 1 downto 0 loop
         Mblt_Read(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,  -- this procedure is for A16, A24, A32 address type
         s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType, num => s_num, 
         VME64xBus_In => VME64xBus_in, VME64xBus_Out => VME64xBus_Out);
      end loop;





                        -- Test Error condition: The Master can't access with s_AddressingType <= MBLT and Data transfer type /= D32
      wait for 20 ns;

      s_dataTransferType <= D16Byte01;  -- Data transfer type is D32 also if the data width is 64!!
      s_AddressingType   <= A32_MBLT;
      s_address <= x"0000000000000010"; --Put here a multiple of 8!!!
      s_num <= "000000100";   -- max 256;

      Mblt_Read(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,  -- this procedure is for A16, A24, A32 address type
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType, num => s_num, 
      VME64xBus_In => VME64xBus_in, VME64xBus_Out => VME64xBus_Out);
                        -- The master can't access at more than 256 locations (2048 Bytes)
      wait for 20 ns;

      s_dataTransferType <= D32;  -- Data transfer type is D32 also if the data width is 64!!
      s_AddressingType   <= A32_MBLT;
      s_address <= x"0000000000000000"; --Put here a multiple of 8!!!
      s_num <= "100000001";   -- max 256;

      Mblt_write(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,  -- this procedure is for A16, A24, A32 address type
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType, num => s_num, 
      VME64xBus_In => VME64xBus_in, VME64xBus_Out => VME64xBus_Out);

                        --A24 MBLT
                        --the master write the ADER 0:
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A24_MBLT(31 downto 24);  
      WriteCSR(c_address	=> c_FUNC1_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A24_MBLT(23 downto 16);  
      WriteCSR(c_address	=> c_FUNC1_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A24_MBLT(15 downto 8);  
      WriteCSR(c_address	=> c_FUNC1_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A24_MBLT(7 downto 0);  
      WriteCSR(c_address	=> c_FUNC1_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);		
                        -- ADER0 written

      s_dataTransferType <= D32;  -- Data transfer type is D32 also if the data width is 64!!
      s_AddressingType   <= A24_MBLT;
      s_address <= x"0000000000000008"; --Put here a multiple of 8!!!
      s_num <= "000000100";   -- max 256;

      Mblt_Read(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,  -- this procedure is for A16, A24, A32 address type
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType, num => s_num, 
      VME64xBus_In => VME64xBus_in, VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;
      report "Start Test Interrupter";
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32(31 downto 24);  
      WriteCSR(c_address	=> c_FUNC0_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32(23 downto 16);  
      WriteCSR(c_address	=> c_FUNC0_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;
      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32(15 downto 8);  
      WriteCSR(c_address	=> c_FUNC0_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 20 ns;

      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000" & ADER0_A32(7 downto 0);  
      WriteCSR(c_address	=> c_FUNC0_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);		
         -- The master write IRQ_Level register
      wait for 10 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"00000002";  

      WriteCSR(c_address	=> c_IRQ_level , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
         -- The master write IRQ_Vector register
      wait for 10 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"000000b4";  
         --s_address  <= x"0000000000000000";

      WriteCSR(c_address	=> c_IRQ_Vector , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      wait for 10 ns;
                        --Test if the daisy chaine is working; 

                        --			s_dataTransferType <= D32;
                        --         s_AddressingType   <= A32;
                        --         s_dataToReceive <= x"00000003";
                        --			Interrupt_Handler(VME64xBus_In => VME64xBus_In,VME64xBus_Out => VME64xBus_Out,s_dataToReceive => s_dataToReceive,
                        --	                        s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType);
                        --			
                        --The master write FREQ register in the RAM
      wait for 10 ns;
      s_dataTransferType <= D32;

      s_AddressingType   <= A32;

      s_dataToSend <= x"00000010";  
      s_address  <= x"0000000000000004";

      S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      s_dataTransferType <= D32;
      s_AddressingType   <= A32;
      s_dataToReceive <= x"00000003";
      Interrupt_Handler(VME64xBus_In => VME64xBus_In,VME64xBus_Out => VME64xBus_Out,s_dataToReceive => s_dataToReceive,
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType);

      wait for 10 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"00000090";  
         --s_address  <= x"0000000000000000";

      WriteCSR(c_address	=> c_BIT_SET_REG , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);
      wait for 8800 ns;

                        --			s_dataTransferType <= D08Byte3;
                        --
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --        s_dataToSend <= x"000000" & ADER0_A32(31 downto 24);  
                        --         WriteCSR(c_address	=> c_FUNC0_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --         VME64xBus_Out => VME64xBus_Out);
                        --
                        --         wait for 20 ns;
                        --
                        --         s_dataTransferType <= D08Byte3;
                        --
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --         s_dataToSend <= x"000000" & ADER0_A32(23 downto 16);  
                        --         WriteCSR(c_address	=> c_FUNC0_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --         VME64xBus_Out => VME64xBus_Out);
                        --
                        --         wait for 20 ns;
                        --
                        --        s_dataTransferType <= D08Byte3;
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --         s_dataToSend <= x"000000" & ADER0_A32(15 downto 8);  
                        --         WriteCSR(c_address	=> c_FUNC0_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --         VME64xBus_Out => VME64xBus_Out);
                        --
                        --         wait for 20 ns;
                        --
                        --         s_dataTransferType <= D08Byte3;
                        --
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --         s_dataToSend <= x"000000" & ADER0_A32(7 downto 0);  
                        --         WriteCSR(c_address	=> c_FUNC0_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --         VME64xBus_Out => VME64xBus_Out);		
                        --			
                        --			
                        --			wait for 100 ns;
                        --			s_dataTransferType <= D32;
                        --
                        --         s_AddressingType   <= A32;
                        --
                        --         s_dataToSend <= x"00000010";  
                        --         s_address  <= x"0000000000000004";
                        --
                        --         S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --         VME64xBus_Out => VME64xBus_Out);	
                        --			
                        --			
                        --			-- The Master change the Int Level
                        --			wait for 1000 ns;
                        --			s_dataTransferType <= D08Byte3;
                        --
                        --         s_AddressingType   <= CR_CSR;
                        --
                        --         s_dataToSend <= x"00000003";  
                        --         --s_address  <= x"0000000000000000";
                        --
                        --         WriteCSR(c_address	=> c_IRQ_level , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
                        --         s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --         VME64xBus_Out => VME64xBus_Out);
                        --Check if the falling edge is passed on the IACKOUT daisy chain			
                        --_____________________________________________________________________________________________________________________________________			
                        --TEST A64
		s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <= x"00000010";  
      WriteCSR(c_address	=> c_BIT_SET_REG  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_in, 
      VME64xBus_Out => VME64xBus_Out);	
		
      wait for 20 ns;
		
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <=  x"000000"  & BA;
      WriteCSR(c_address	=> c_FUNC4_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);		
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <=  x"00000000";
      WriteCSR(c_address	=> c_FUNC4_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <=  x"00000000";
      WriteCSR(c_address	=> c_FUNC4_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <=  x"00000000";
      WriteCSR(c_address	=> c_FUNC4_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <=  x"00000000";
      WriteCSR(c_address	=> c_FUNC3_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <=  x"00000000";
      WriteCSR(c_address	=> c_FUNC3_ADER_2  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <=  x"00000000";
      WriteCSR(c_address	=> c_FUNC3_ADER_1  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      wait for 20 ns;
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= CR_CSR;

      s_dataToSend <=  x"00000004";
      WriteCSR(c_address	=> c_FUNC3_ADER_0  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	


      s_dataTransferType <= D32;

      s_AddressingType   <= A64;

      s_dataToSend <= x"00000003";  

      s_address  <= x"0000000000000008";

      A64S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      wait for 10 ns;			
      s_dataTransferType <= D08Byte0;

      s_AddressingType   <= A64;

      s_dataToSend <= x"00000005";  

      s_address  <= x"000000000000000c";

      A64S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	

      wait for 10 ns;			
      s_dataTransferType <= D08Byte1;

      s_AddressingType   <= A64;

      s_dataToSend <= x"00000006";  

      s_address  <= x"000000000000000d";

      A64S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);
      wait for 10 ns;			
      s_dataTransferType <= D08Byte2;

      s_AddressingType   <= A64;

      s_dataToSend <= x"00000007";  

      s_address  <= x"000000000000000e";

      A64S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);				

      wait for 10 ns;			
      s_dataTransferType <= D08Byte3;

      s_AddressingType   <= A64;

      s_dataToSend <= x"00000008";  

      s_address  <= x"000000000000000f";

      A64S_Write(v_address	=> s_address , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);	
      wait for 10 ns;

      s_dataTransferType <= D32;

      s_AddressingType   <= A64;

      s_address  <= x"0000000000000008";

      s_dataToReceive <= x"00000003";

      A64S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D16Byte01;

      s_AddressingType   <= A64;

      s_address  <= x"000000000000000c";

      s_dataToReceive <= x"00000506";

      A64S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;
      s_dataTransferType <= D16Byte23;

      s_AddressingType   <= A64;

      s_address  <= x"000000000000000e";

      s_dataToReceive <= x"00000708";

      A64S_Read(v_address	=> s_address, s_dataToReceive => s_dataToReceive, s_dataTransferType => s_dataTransferType,
      s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
      VME64xBus_Out => VME64xBus_Out);

                        -- Test A64 BLT
      s_dataTransferType <= D32; --only D32 is possible with BLT transfer 
      s_AddressingType   <= A64_BLT;
      s_address <= x"0000000000000010";
      s_num <= "000000011"; --Number of access; (max 64)
      A64Blt_write(v_address	=> s_address, s_Buffer_BLT => s_Buffer_BLT,
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType,
      num => s_num, VME64xBus_In => VME64xBus_In, VME64xBus_Out => VME64xBus_Out);

      wait for 10 ns;						 
      s_dataTransferType <= D32; --only D32 is possible with BLT transfer 
      s_AddressingType   <= A64_BLT;
      s_address <= x"0000000000000010";
      s_num <= "000000011"; --Number of access; (max 64)
      A64Blt_Read(v_address	=> s_address, s_Buffer_BLT => s_Buffer_BLT,
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType,
      num => s_num, VME64xBus_In => VME64xBus_In, VME64xBus_Out => VME64xBus_Out);						 

      wait for 30 ns;

      s_dataTransferType <= D32;  -- Data transfer type is D32 also if the data width is 64!!
      s_AddressingType   <= A64_MBLT;
      s_address <= x"0000000000000020"; --Put here a multiple of 8!!!
      s_num <= "000000011";   -- max 256;

      A64Mblt_write(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,  -- this procedure is for A16, A24, A32 address type
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType, num => s_num, 
      VME64xBus_In => VME64xBus_in, VME64xBus_Out => VME64xBus_Out);

      wait for 30 ns;

      s_dataTransferType <= D32;  -- Data transfer type is D32 also if the data width is 64!!
      s_AddressingType   <= A64_MBLT;
      s_address <= x"0000000000000020"; --Put here a multiple of 8!!!
      s_num <= "000000011";   -- max 256;

      A64Mblt_Read(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,  -- this procedure is for A16, A24, A32 address type
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType, num => s_num, 
      VME64xBus_In => VME64xBus_in, VME64xBus_Out => VME64xBus_Out);

      wait for 30 ns;		  
      s_dataTransferType <= D16Byte01; --only D32 is possible with BLT transfer 
      s_AddressingType   <= A64_BLT;
      s_address <= x"0000000000000010";
      s_num <= "000000011"; --Number of access; (max 64)
      A64Blt_write(v_address	=> s_address, s_Buffer_BLT => s_Buffer_BLT,
      s_dataTransferType => s_dataTransferType, s_AddressingType => s_AddressingType,
      num => s_num, VME64xBus_In => VME64xBus_In, VME64xBus_Out => VME64xBus_Out);		
                        --__________________________________________________________________________________________________________________________________________
                        --
                        --        s_dataTransferType <= D08Byte3;
                        --
                        --        s_AddressingType   <= CR_CSR;
                        --
                        --        s_dataToSend <= x"000000" & ADER2_A32_2eVME(31 downto 24);  
                        --        WriteCSR(c_address	=> c_FUNC5_ADER_3  , s_dataToSend => s_dataToSend, s_dataTransferType => s_dataTransferType,
                        --        s_AddressingType => s_AddressingType, VME64xBus_In => VME64xBus_In, 
                        --        VME64xBus_Out => VME64xBus_Out);
                        --
                        --
                        --         s_AddressingType   <= A32_2eVME;
                        --         s_beat_count <= "00001000";
                        --			s_address <= x"0000000000000010";						 
                        --			TWOeVME_write(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,
                        --                       s_AddressingType => s_AddressingType,
                        --                       v_beat_count => s_beat_count, VME64xBus_In => VME64xBus_In, VME64xBus_Out => VME64xBus_Out);
                        --							  
                        --			wait for 30 ns;				  
                        --			s_AddressingType   <= A64_2eVME;
                        --         s_beat_count <= "00001000";
                        --			s_address <= x"0000000000000010";						 
                        --			TWOeVME_read(v_address	=> s_address, s_Buffer_MBLT => s_Buffer_MBLT,
                        --                       s_AddressingType => s_AddressingType,
                        --                       v_beat_count => s_beat_count, VME64xBus_In => VME64xBus_In, VME64xBus_Out => VME64xBus_Out);
                        --							  

      report "FINE///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////";



         -- VME_BBSY_n_i not used in the VME Slave core...however in the reset process I drive low the VME_BBSY_n_i.
         -- Inded when a master access the DTB he drives low the BBSY signals.   	


         -- The VME_CSR_pack define an array of constants used during the initialized.
         -- The two procedure above mentioned are be made for test a simple read and write in the csr.
         -- I have red all the rule for a simple read and write in the VME bus specifications book and 
         -- the slave is working correctly and respect the timing rule.
         -- Oversampled the AS, DS ecc.. signals is necessary for respect these timing rules.
         -- The master can terminate the single cycle driving AS and DS high at the same time and between two 
         -- call to procedures it is not necessary insert a wait statement.
         -- Single read and write cycles duration is: 175 ns --> about 5,7 MB/s.
         -- The CSR memory is accessible by Single read and write with data type D08Byte1, D08Byte0,
         -- D08Byte2, D08Byte3.


         -- ControlCR --> This procedure reads the CR memory and check if the Master reads correctly
         -- the values located in the VME_CR_package.
         -- The CR memory is internal at the FPGA; In the VME_CR_pack are defined 
         -- the values of the CR's registers, and at the start up the VME slave core reads some of 
         -- these registers and save them in local signals; during the initialization the slave has to 
         -- save in the local registers only the BEG_USER_CR, END_USER_CR, BEG_CRAM, END_CRAM, BEG_USER_CSR, END_USER_CSR,
         -- FUNC_AMCAP, FUNC_XAMCAP, FUNC_ADEM that are used in the decode phase.
         -- The ROM is implemented by the package above mentioned and it is internal at the VME_bus
         -- component; if will be used an IP core external at the VME_bus component the code has to be reported
         -- at the original form, as well as before of my modifies 

         -- Nella CR i dati sono salvati in notazione LITTLE ENDIAN cioè i bit più significativi sono nelle locazioni di memoria più basse!!
      
                        -- 
                        -- CRAM_owner --> il master prende la ownership scrivendo il suo ID nel CRAM_OWNER e la rilascia scrivendo 0 nel bit 2 del BIT_SET_REG!!
                        -- Prima di scrivere nella CRAM fare scrittura ID nel CRAM_OWNER, poi leggerlo e confrontare  l'ID per check ownership.
                        -- creare costante con ID del Master.
                        -- TEST CRAM ESEGUITO CORRETTAMENTE.

                        -- If the slave is not correct address and s_confAccess remain '0' the slave can't assert the VME_Berr line
                        -- becouse others slaves can be addressed!!
                        -- modified the assertion of VME_Berr;is important to be sure that the main fsm don't arrive at the MEMORY_REQ
                        -- state if there is an error; in this way the possibility of a wrong write is excluded.
                        -- A read in a wrong address is not dangerous for the slave and the master receiving a Berr signals don't will latch the data.

                        -- Transfer data from VME to WB fixed correctly for the Single mode transfer. 
                        -- I have add some mux because he single read and write don't need of the FIFO memory.
                        -- So I have add a register in the DAT_i for to be sure that the pipelined modality is supported by
                        -- the core.  

                        -- The BITSETREGISTER's "enable module" bit (bit 4) work correctly; with this bit not asserted the access at the wb bus is impossible.

                        -- In the BLT the VME_bus transfer the datas in/from the FIFO with the pipelined single write/read mode
                        -- (see the cyc_o signal). the transfer data from the FIFO to wb slave will be done in block read/write pipelined mode.
                        -- In single read and write mode if the FIFO is not initialized you can seen 'U' values in slave1_i.adr, slave1_i.sel, slave1_i.dat.


      wait;
         --inserire qui tutte le chiamate a procedure
      
   end process;





   


      -- Stimulus process------------RESET, BBSY, IACKIN, VME_GA
   reset_proc: process
   begin		
      -- hold reset state for 100 ns.
      VME_RST_n_i <= '1';
      VME_GA_i <= VME_GA;

      wait for 50 ns;	
      VME_RST_n_i <= '0';
      
      wait for 50 ns;
      VME_RST_n_i <= '1';

      wait;
   end process;

   END;
