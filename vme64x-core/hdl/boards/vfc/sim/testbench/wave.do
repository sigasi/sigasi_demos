onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vme64x_tb/clk_i
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_mainFSMstate
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_AS_n_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_RST_n_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_WRITE_n_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_typeOfDataTransfer
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_AM_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_DS_n_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_GA_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_BBSY_n_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_IACK_n_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_IACKOUT_n_o
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_IACKIN_n_i
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_LWORD_n_b
add wave -noupdate -expand -group VME_signals -radix hexadecimal /vme64x_tb/VME_ADDR_b
add wave -noupdate -expand -group VME_signals -radix hexadecimal /vme64x_tb/VME_DATA_b
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_BERR_o
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_DTACK_n_o
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_RETRY_n_o
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_DATA_DIR_o
add wave -noupdate -expand -group VME_signals /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_sel
add wave -noupdate -expand -group VME_signals /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_beatCount
add wave -noupdate -expand -group VME_signals /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_addrOffset
add wave -noupdate -expand -group VME_signals /vme64x_tb/VME_ADDR_DIR_o
add wave -noupdate /vme64x_tb/RST_i
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_BERRcondition
add wave -noupdate /vme64x_tb/s_dataTransferType
add wave -noupdate /vme64x_tb/s_AddressingType
add wave -noupdate /vme64x_tb/s_dataToSend
add wave -noupdate -radix hexadecimal /vme64x_tb/s_dataToReceive
add wave -noupdate /vme64x_tb/s_address
add wave -noupdate -group VME_MASTER_IN_OUT /vme64x_tb/VME64xBus_out
add wave -noupdate -group VME_MASTER_IN_OUT /vme64x_tb/VME64xBus_in
add wave -noupdate -group {Don't care} /vme64x_tb/VME_IRQ_n_o
add wave -noupdate -group {Don't care} /vme64x_tb/VME_IACKOUT_n_o
add wave -noupdate -group {Don't care} /vme64x_tb/VME_DTACK_OE_o
add wave -noupdate -group {Don't care} /vme64x_tb/ReadInProgress
add wave -noupdate -group {Don't care} /vme64x_tb/WriteInProgress
add wave -noupdate -group {Don't care} /vme64x_tb/rst_n_i
add wave -noupdate -group {Don't care} /vme64x_tb/localAddress
add wave -noupdate -group {Don't care} /vme64x_tb/s_dataToSendOut
add wave -noupdate -expand -group WB_SLAVE_IN_OUT -childformat {{/vme64x_tb/uut/Inst_xwb_dpram/slave1_i.adr -radix hexadecimal} {/vme64x_tb/uut/Inst_xwb_dpram/slave1_i.dat -radix hexadecimal}} -expand -subitemconfig {/vme64x_tb/uut/Inst_xwb_dpram/slave1_i.adr {-height 16 -radix hexadecimal} /vme64x_tb/uut/Inst_xwb_dpram/slave1_i.dat {-height 16 -radix hexadecimal}} /vme64x_tb/uut/Inst_xwb_dpram/slave1_i
add wave -noupdate -expand -group WB_SLAVE_IN_OUT -childformat {{/vme64x_tb/uut/Inst_xwb_dpram/slave1_o.dat -radix hexadecimal}} -expand -subitemconfig {/vme64x_tb/uut/Inst_xwb_dpram/slave1_o.dat {-height 16 -radix hexadecimal}} /vme64x_tb/uut/Inst_xwb_dpram/slave1_o
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_CSRarray
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/currs
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_cyc_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_stb_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_ack_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_err_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_lock_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_rty_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_sel_i
add wave -noupdate -group FIFO -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_adr_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_we_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_stall_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_psize_i
add wave -noupdate -group FIFO -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_dat_o
add wave -noupdate -group FIFO -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/sl_dat_i
add wave -noupdate -group FIFO -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_dat_i
add wave -noupdate -group FIFO -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_dat_o
add wave -noupdate -group FIFO -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_adr_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_cyc_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_stb_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_ack_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_err_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_lock_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_rty_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_sel_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_we_o
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/m_stall_i
add wave -noupdate -group FIFO /vme64x_tb/uut/Inst_VME64xCore_Top/Fifo/transfer_done_i
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_IACKIN_n_i
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_AS_n_i
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_DS_n_i
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_LWORD_n_i
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_ADDR_123
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/INT_Level
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/INT_Vector
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/INT_Req
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_IRQ_n_o
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_IACKOUT_n_o
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_DTACK_n_o
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/VME_DATA_o
add wave -noupdate -expand -group IRQ_Controller /vme64x_tb/uut/Inst_VME64xCore_Top/Inst_IRQ_Controller/currs
add wave -noupdate -expand -group IRQ_Generator /vme64x_tb/uut/Inst_xwb_dpram/Inst_IRQ_generator/Freq
add wave -noupdate -expand -group IRQ_Generator -radix decimal /vme64x_tb/uut/Inst_xwb_dpram/Inst_IRQ_generator/Int_Count_i
add wave -noupdate -expand -group IRQ_Generator /vme64x_tb/uut/Inst_xwb_dpram/Inst_IRQ_generator/Read_Int_Count
add wave -noupdate -expand -group IRQ_Generator /vme64x_tb/uut/Inst_xwb_dpram/Inst_IRQ_generator/INT_ack
add wave -noupdate -expand -group IRQ_Generator /vme64x_tb/uut/Inst_xwb_dpram/Inst_IRQ_generator/IRQ_o
add wave -noupdate -expand -group IRQ_Generator -radix decimal /vme64x_tb/uut/Inst_xwb_dpram/Inst_IRQ_generator/Int_Count_o
add wave -noupdate -expand -group IRQ_Generator /vme64x_tb/uut/Inst_xwb_dpram/Inst_IRQ_generator/currs
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_cardSel
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_funcMatch
add wave -noupdate -radix hexadecimal /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_phase1addr
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_XAMtype
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_addrWidth
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_AMmatch
add wave -noupdate /vme64x_tb/uut/Inst_VME64xCore_Top/VME_bus_1/s_FUNC_ADER
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {91591032 ps} 0}
configure wave -namecolwidth 184
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
WaveRestoreZoom {89690733 ps} {95279436 ps}
