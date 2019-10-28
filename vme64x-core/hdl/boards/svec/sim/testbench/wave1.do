onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/clk_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/s_mainFSMstate
add wave -noupdate -expand -group VME_TOP /vme64x_tb/s_dataTransferType
add wave -noupdate -expand -group VME_TOP /vme64x_tb/s_AddressingType
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/Reset
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_AS_n_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_RST_n_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_WRITE_n_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_AM_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_DS_n_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_GA_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_BERR_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_DTACK_n_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_RETRY_n_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_LWORD_n_b
add wave -noupdate -expand -group VME_TOP -radix hexadecimal /vme64x_tb/uut/VME_ADDR_b
add wave -noupdate -expand -group VME_TOP -radix hexadecimal /vme64x_tb/uut/VME_DATA_b
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_IRQ_n_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_IACKIN_n_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_IACKOUT_n_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_IACK_n_i
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_RETRY_OE_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_DTACK_OE_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_DATA_DIR_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_DATA_OE_N_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_ADDR_DIR_o
add wave -noupdate -expand -group VME_TOP /vme64x_tb/uut/VME_ADDR_OE_N_o
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/clk_i
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/ModuleEnable
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/InitInProgress
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Addr
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Ader0
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Ader1
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Ader2
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Ader3
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Ader4
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Ader5
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Ader6
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Ader7
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Adem0
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Adem1
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Adem2
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Adem3
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Adem4
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Adem5
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Adem6
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Adem7
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AmCap0
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AmCap1
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AmCap2
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AmCap3
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AmCap4
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AmCap5
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AmCap6
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AmCap7
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAmCap0
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAmCap1
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAmCap2
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAmCap3
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAmCap4
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAmCap5
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAmCap6
add wave -noupdate -group DecodeAccess -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAmCap7
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Am
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/XAm
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/AddrWidth
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Funct_Sel
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Base_Addr
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/Confaccess
add wave -noupdate -group DecodeAccess /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Access_Decode/CardSel
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/clk_i
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/stall_i
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/rty_i
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/err_i
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/cyc_o
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/memReq_o
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/WBdata_o
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/wbData_i
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/locAddr_o
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/memAckWB_i
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/WbSel_o
add wave -noupdate -group VME_WB /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/Inst_Wb_master/RW_o
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/clk_i
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_IACKIN_n_i
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_AS_n_i
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_DS_n_i
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_LWORD_n_i
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_ADDR_123
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/INT_Level
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/INT_Vector
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/INT_Req
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_IRQ_n_o
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_IACKOUT_n_o
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_DTACK_n_o
add wave -noupdate -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_IRQ_Controller/VME_DATA_o
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_cyc_o
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_stb_o
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_adr_o
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_dat_o
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_sel_o
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_we_o
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_ack_i
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_err_i
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_stall_i
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_rty_i
add wave -noupdate -expand -group WB_Bridge_out /vme64x_tb/uut/Inst_WB_Bridge/m_dat_i
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_VME_bus/s_VMEaddrInput
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8963596 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {7948848 ps} {10676982 ps}
