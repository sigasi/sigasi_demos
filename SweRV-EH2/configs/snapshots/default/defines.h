// NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
// This is an automatically generated file by titouanvervack on Mon Dec  6 20:49:22 PST 2021
//
// cmd:    swerv  
//
#define RV_XLEN 32
#define RV_DATA_ACCESS_ENABLE2 1
#define RV_DATA_ACCESS_MASK4 0xffffffff
#define RV_INST_ACCESS_MASK1 0x3fffffff
#define RV_INST_ACCESS_MASK7 0xffffffff
#define RV_DATA_ACCESS_MASK6 0xffffffff
#define RV_INST_ACCESS_MASK4 0xffffffff
#define RV_INST_ACCESS_ENABLE2 1
#define RV_DATA_ACCESS_MASK7 0xffffffff
#define RV_INST_ACCESS_MASK6 0xffffffff
#define RV_DATA_ACCESS_MASK1 0x3fffffff
#define RV_INST_ACCESS_ENABLE1 1
#define RV_INST_ACCESS_ADDR0 0x0
#define RV_DATA_ACCESS_ENABLE1 1
#define RV_DATA_ACCESS_ADDR0 0x0
#define RV_INST_ACCESS_MASK5 0xffffffff
#define RV_DATA_ACCESS_MASK5 0xffffffff
#define RV_INST_ACCESS_ADDR2 0xa0000000
#define RV_INST_ACCESS_ENABLE6 0x0
#define RV_DATA_ACCESS_ENABLE4 0x0
#define RV_DATA_ACCESS_ADDR3 0x80000000
#define RV_DATA_ACCESS_ENABLE6 0x0
#define RV_DATA_ACCESS_ADDR2 0xa0000000
#define RV_INST_ACCESS_ENABLE4 0x0
#define RV_INST_ACCESS_ADDR3 0x80000000
#define RV_DATA_ACCESS_ADDR4 0x00000000
#define RV_INST_ACCESS_ENABLE5 0x0
#define RV_INST_ACCESS_ADDR1 0xc0000000
#define RV_DATA_ACCESS_ADDR6 0x00000000
#define RV_INST_ACCESS_ADDR7 0x00000000
#define RV_DATA_ACCESS_ENABLE5 0x0
#define RV_INST_ACCESS_ADDR4 0x00000000
#define RV_INST_ACCESS_ADDR6 0x00000000
#define RV_DATA_ACCESS_ADDR7 0x00000000
#define RV_DATA_ACCESS_ADDR1 0xc0000000
#define RV_INST_ACCESS_ENABLE3 1
#define RV_INST_ACCESS_MASK0 0x7fffffff
#define RV_DATA_ACCESS_ENABLE3 1
#define RV_DATA_ACCESS_MASK0 0x7fffffff
#define RV_DATA_ACCESS_ENABLE7 0x0
#define RV_INST_ACCESS_ADDR5 0x00000000
#define RV_DATA_ACCESS_ADDR5 0x00000000
#define RV_INST_ACCESS_ENABLE7 0x0
#define RV_INST_ACCESS_MASK2 0x1fffffff
#define RV_DATA_ACCESS_MASK3 0x0fffffff
#define RV_DATA_ACCESS_ENABLE0 1
#define RV_DATA_ACCESS_MASK2 0x1fffffff
#define RV_INST_ACCESS_MASK3 0x0fffffff
#define RV_INST_ACCESS_ENABLE0 1
#define RV_UNUSED_REGION0 0x70000000
#define RV_UNUSED_REGION7 0x00000000
#define RV_UNUSED_REGION2 0x50000000
#define RV_EXTERNAL_DATA_1 0xb0000000
#define RV_SERIALIO 0xd0580000
#define RV_EXTERNAL_MEM_HOLE 0x90000000
#define RV_UNUSED_REGION3 0x40000000
#define RV_EXTERNAL_DATA 0xc0580000
#define RV_UNUSED_REGION5 0x20000000
#define RV_UNUSED_REGION4 0x30000000
#define RV_UNUSED_REGION6 0x10000000
#define RV_UNUSED_REGION1 0x60000000
#define RV_DEBUG_SB_MEM 0xa0580000
#define RV_DCCM_NUM_BANKS 8
#define RV_DCCM_EADR 0xf004ffff
#define RV_DCCM_REGION 0xf
#define RV_DCCM_FDATA_WIDTH 39
#define RV_DCCM_INDEX_BITS 11
#define RV_DCCM_WIDTH_BITS 2
#define RV_DCCM_ECC_WIDTH 7
#define RV_DCCM_OFFSET 0x40000
#define RV_DCCM_DATA_CELL ram_2048x39
#define RV_LSU_SB_BITS 16
#define RV_DCCM_ENABLE 1
#define RV_DCCM_DATA_WIDTH 32
#define RV_DCCM_BITS 16
#define RV_DCCM_RESERVED 0x2004
#define RV_DCCM_SIZE_64 
#define RV_DCCM_BANK_BITS 3
#define RV_DCCM_BYTE_WIDTH 4
#define RV_DCCM_SIZE 64
#define RV_DCCM_SADR 0xf0040000
#define RV_DCCM_ROWS 2048
#define RV_DCCM_NUM_BANKS_8 
#define RV_PIC_MEIGWCLR_OFFSET 0x5000
#define RV_PIC_MEIGWCTRL_OFFSET 0x4000
#define RV_PIC_MEIP_MASK 0x0
#define RV_PIC_BITS 15
#define RV_PIC_MEIP_COUNT 4
#define RV_PIC_MEIGWCTRL_COUNT 127
#define RV_PIC_MPICCFG_COUNT 1
#define RV_PIC_BASE_ADDR 0xf00c0000
#define RV_PIC_MEIP_OFFSET 0x1000
#define RV_PIC_MEITP_OFFSET 0x1800
#define RV_PIC_2CYCLE 1
#define RV_PIC_MEIPL_MASK 0xf
#define RV_PIC_REGION 0xf
#define RV_PIC_TOTAL_INT 127
#define RV_PIC_MPICCFG_MASK 0x1
#define RV_PIC_MEIGWCTRL_MASK 0x3
#define RV_PIC_TOTAL_INT_PLUS1 128
#define RV_PIC_MEIPL_COUNT 127
#define RV_PIC_MPICCFG_OFFSET 0x3000
#define RV_PIC_OFFSET 0xc0000
#define RV_PIC_MEIGWCLR_COUNT 127
#define RV_PIC_MEIDELS_COUNT 127
#define RV_PIC_MEIGWCLR_MASK 0x0
#define RV_PIC_MEITP_COUNT 4
#define RV_PIC_MEIDELS_MASK 0x1
#define RV_PIC_MEIE_MASK 0x1
#define RV_PIC_MEITP_MASK 0x0
#define RV_PIC_SIZE 32
#define RV_PIC_MEIE_COUNT 127
#define RV_PIC_MEIPL_OFFSET 0x0000
#define RV_PIC_MEIE_OFFSET 0x2000
#define RV_PIC_INT_WORDS 4
#ifndef RV_NMI_VEC
#define RV_NMI_VEC 0x11110000
#endif
#define RV_EXT_DATAWIDTH 64
#define SDVT_AHB 1
#define RV_TOP `TOP.rvtop
#define RV_STERR_ROLLBACK 0
#define RV_EXT_ADDRWIDTH 32
#define CLOCK_PERIOD 100
#define CPU_TOP `RV_TOP.swerv
#define RV_BUILD_AXI_NATIVE 1
#define RV_ASSERT_ON 
#define DATAWIDTH 64
#define RV_LDERR_ROLLBACK 1
#define TOP tb_top
#define RV_BUILD_AXI4 1
#define RV_TARGET_DEFAULT 1
#ifndef RV_RESET_VEC
#define RV_RESET_VEC 0x80000000
#endif
#define RV_ICCM_EADR 0xee00ffff
#define RV_ICCM_NUM_BANKS 4
#define RV_ICCM_BANK_INDEX_LO 4
#define RV_ICCM_INDEX_BITS 12
#define RV_ICCM_REGION 0xe
#define RV_ICCM_ENABLE 1
#define RV_ICCM_DATA_CELL ram_4096x39
#define RV_ICCM_BANK_HI 3
#define RV_ICCM_OFFSET 0xe000000
#define RV_ICCM_NUM_BANKS_4 
#define RV_ICCM_ROWS 4096
#define RV_ICCM_SADR 0xee000000
#define RV_ICCM_SIZE 64
#define RV_ICCM_RESERVED 0x1000
#define RV_ICCM_SIZE_64 
#define RV_ICCM_BANK_BITS 2
#define RV_ICCM_BITS 16
#define RV_IFU_BUS_PRTY 2
#define RV_LSU_BUS_PRTY 2
#define RV_LSU_BUS_TAG 4
#define RV_DMA_BUS_ID 1
#define RV_IFU_BUS_TAG 4
#define RV_SB_BUS_ID 1
#define RV_IFU_BUS_ID 1
#define RV_SB_BUS_TAG 1
#define RV_LSU_BUS_ID 1
#define RV_DMA_BUS_TAG 1
#define RV_BUS_PRTY_DEFAULT 3
#define RV_DMA_BUS_PRTY 2
#define RV_SB_BUS_PRTY 2
#define RV_BITMANIP_ZBE 0
#define RV_LSU_STBUF_DEPTH 10
#define RV_DIV_BIT 4
#define RV_DIV_NEW 1
#define RV_BITMANIP_ZBS 1
#define RV_ATOMIC_ENABLE 1
#define RV_BITMANIP_ZBC 1
#define RV_NUM_THREADS 1
#define RV_DMA_BUF_DEPTH 5
#define RV_LSU_NUM_NBLOAD_WIDTH 3
#define RV_BITMANIP_ZBB 1
#define RV_LSU_NUM_NBLOAD 8
#define RV_BITMANIP_ZBF 0
#define RV_BITMANIP_ZBP 0
#define RV_TIMER_LEGAL_EN 1
#define RV_BITMANIP_ZBA 1
#define RV_BITMANIP_ZBR 0
#define RV_ICCM_ICACHE 1
#define RV_FPGA_OPTIMIZE 1
#define RV_FAST_INTERRUPT_REDIRECT 1
#define RV_TARGET default
