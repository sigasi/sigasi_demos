// SPDX-License-Identifier: Apache-2.0
// Copyright 2020 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//********************************************************************************
// $Id$
//
// Function: Top level SWERV core file
// Comments:
//
//********************************************************************************
module eh2_swerv
import eh2_pkg::*;
#(
`include "eh2_param.vh"
) (
   input logic                  clk,
   input logic                  rst_l,
   input logic                  dbg_rst_l,  // DM reset
   input logic [31:1]           rst_vec,
   input logic                  nmi_int,
   input logic [31:1]           nmi_vec,

   output logic                 core_rst_l,   // This is "rst_l | dbg_rst_l"
   output logic                 active_l2clk,
   output logic                 free_l2clk,

   output logic [pt.NUM_THREADS-1:0] [63:0] trace_rv_i_insn_ip,
   output logic [pt.NUM_THREADS-1:0] [63:0] trace_rv_i_address_ip,
   output logic [pt.NUM_THREADS-1:0] [1:0]  trace_rv_i_valid_ip,
   output logic [pt.NUM_THREADS-1:0] [1:0]  trace_rv_i_exception_ip,
   output logic [pt.NUM_THREADS-1:0] [4:0]  trace_rv_i_ecause_ip,
   output logic [pt.NUM_THREADS-1:0] [1:0]  trace_rv_i_interrupt_ip,
   output logic [pt.NUM_THREADS-1:0] [31:0] trace_rv_i_tval_ip,

   output logic                 dccm_clk_override,
   output logic                 icm_clk_override,
   output logic                 dec_tlu_core_ecc_disable,
   output logic                 btb_clk_override,

   output logic [pt.NUM_THREADS-1:0] dec_tlu_mhartstart, // running harts

   // external halt/run interface
   input logic  [pt.NUM_THREADS-1:0] i_cpu_halt_req,    // Asynchronous Halt request to CPU
   input logic  [pt.NUM_THREADS-1:0] i_cpu_run_req,     // Asynchronous Restart request to CPU
   output logic [pt.NUM_THREADS-1:0] o_cpu_halt_status, // PMU interface, halted
   output logic [pt.NUM_THREADS-1:0] o_cpu_halt_ack,    // Core Acknowledge to Halt request
   output logic [pt.NUM_THREADS-1:0] o_cpu_run_ack,     // Core Acknowledge to run request
   output logic [pt.NUM_THREADS-1:0] o_debug_mode_status, // Core to the PMU that core is in debug mode. When core is in debug mode, the PMU should refrain from sendng a halt or run request

   input logic [31:4]     core_id, // Core ID

   // external MPC halt/run interface
   input logic  [pt.NUM_THREADS-1:0] mpc_debug_halt_req, // Async halt request
   input logic  [pt.NUM_THREADS-1:0] mpc_debug_run_req, // Async run request
   input logic  [pt.NUM_THREADS-1:0] mpc_reset_run_req, // Run/halt after reset
   output logic [pt.NUM_THREADS-1:0] mpc_debug_halt_ack, // Halt ack
   output logic [pt.NUM_THREADS-1:0] mpc_debug_run_ack, // Run ack
   output logic [pt.NUM_THREADS-1:0] debug_brkpt_status, // debug breakpoint

   output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt0, // toggles when pipe0 perf counter 0 has an event inc
   output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt1, // toggles when pipe0 perf counter 1 has an event inc
   output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt2, // toggles when pipe0 perf counter 2 has an event inc
   output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt3, // toggles when pipe0 perf counter 3 has an event inc

   // DCCM ports
   output logic                           dccm_wren,
   output logic                           dccm_rden,
   output logic [pt.DCCM_BITS-1:0]        dccm_wr_addr_lo,
   output logic [pt.DCCM_BITS-1:0]        dccm_wr_addr_hi,
   output logic [pt.DCCM_BITS-1:0]        dccm_rd_addr_lo,
   output logic [pt.DCCM_BITS-1:0]        dccm_rd_addr_hi,
   output logic [pt.DCCM_FDATA_WIDTH-1:0] dccm_wr_data_lo,
   output logic [pt.DCCM_FDATA_WIDTH-1:0] dccm_wr_data_hi,

   input logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_lo,
   input logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_hi,

   // ICCM ports
   output logic [pt.ICCM_BITS-1:1]  iccm_rw_addr,
   output logic [pt.NUM_THREADS-1:0]iccm_buf_correct_ecc_thr,            // ICCM is doing a single bit error correct cycle
   output logic                     iccm_correction_state,               // We are under a correction - This is needed to guard replacements when hit
   output logic                     iccm_stop_fetch,                     // The fetch needs to be ignored for replacement hit purposes
   output logic                     iccm_corr_scnd_fetch,                // dont match on middle bank when under correction
   output logic                  ifc_select_tid_f1,
   output logic                  iccm_wren,
   output logic                  iccm_rden,
   output logic [2:0]            iccm_wr_size,
   output logic [77:0]           iccm_wr_data,

   input  logic [63:0]           iccm_rd_data,
   input  logic [116:0]          iccm_rd_data_ecc,

   // ICache , ITAG  ports
   output logic [31:1]           ic_rw_addr,
   output logic [pt.ICACHE_NUM_WAYS-1:0]            ic_tag_valid,
   output logic [pt.ICACHE_NUM_WAYS-1:0]          ic_wr_en  ,         // Which way to write
   output logic                  ic_rd_en,

   output logic [pt.ICACHE_BANKS_WAY-1:0] [70:0]               ic_wr_data,           // Data to fill to the Icache. With ECC
   input  logic [63:0]               ic_rd_data ,          // Data read from Icache. 2x64bits + parity bits. F2 stage. With ECC
   input  logic [70:0]               ic_debug_rd_data ,    // Data read from Icache. 2x64bits + parity bits. F2 stage. With ECC
   input  logic [25:0]               ictag_debug_rd_data,  // Debug icache tag.
   output logic [70:0]               ic_debug_wr_data,     // Debug wr cache.

   input  logic [pt.ICACHE_BANKS_WAY-1:0] ic_eccerr,    //
   input  logic [pt.ICACHE_BANKS_WAY-1:0] ic_parerr,


   output logic [63:0]               ic_premux_data,     // Premux data to be muxed with each way of the Icache.
   output logic                      ic_sel_premux_data, // Select premux data


   output logic [pt.ICACHE_INDEX_HI:3]            ic_debug_addr,      // Read/Write addresss to the Icache.
   output logic                      ic_debug_rd_en,     // Icache debug rd
   output logic                      ic_debug_wr_en,     // Icache debug wr
   output logic                      ic_debug_tag_array, // Debug tag array
   output logic [pt.ICACHE_NUM_WAYS-1:0]          ic_debug_way,       // Debug way. Rd or Wr.


   input  logic [pt.ICACHE_NUM_WAYS-1:0]            ic_rd_hit,
   input  logic                  ic_tag_perr,        // Icache Tag parity error

// BTB ports
   input eh2_btb_sram_pkt btb_sram_pkt,

   input logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0]      btb_vbank0_rd_data_f1,
   input logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0]      btb_vbank1_rd_data_f1,
   input logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0]      btb_vbank2_rd_data_f1,
   input logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0]      btb_vbank3_rd_data_f1,

   output logic                         btb_wren,
   output logic                         btb_rden,
   output logic [1:0] [pt.BTB_ADDR_HI:1] btb_rw_addr,  // per bank
   output logic [1:0] [pt.BTB_ADDR_HI:1] btb_rw_addr_f1,  // per bank
   output logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0]         btb_sram_wr_data,
   output logic [1:0] [pt.BTB_BTAG_SIZE-1:0] btb_sram_rd_tag_f1,


   //-------------------------- LSU AXI signals--------------------------
   // AXI Write Channels
   output logic                            lsu_axi_awvalid,
   input  logic                            lsu_axi_awready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_awid,
   output logic [31:0]                     lsu_axi_awaddr,
   output logic [3:0]                      lsu_axi_awregion,
   output logic [7:0]                      lsu_axi_awlen,
   output logic [2:0]                      lsu_axi_awsize,
   output logic [1:0]                      lsu_axi_awburst,
   output logic                            lsu_axi_awlock,
   output logic [3:0]                      lsu_axi_awcache,
   output logic [2:0]                      lsu_axi_awprot,
   output logic [3:0]                      lsu_axi_awqos,

   output logic                            lsu_axi_wvalid,
   input  logic                            lsu_axi_wready,
   output logic [63:0]                     lsu_axi_wdata,
   output logic [7:0]                      lsu_axi_wstrb,
   output logic                            lsu_axi_wlast,

   input  logic                            lsu_axi_bvalid,
   output logic                            lsu_axi_bready,
   input  logic [1:0]                      lsu_axi_bresp,
   input  logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_bid,

   // AXI Read Channels
   output logic                            lsu_axi_arvalid,
   input  logic                            lsu_axi_arready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_arid,
   output logic [31:0]                     lsu_axi_araddr,
   output logic [3:0]                      lsu_axi_arregion,
   output logic [7:0]                      lsu_axi_arlen,
   output logic [2:0]                      lsu_axi_arsize,
   output logic [1:0]                      lsu_axi_arburst,
   output logic                            lsu_axi_arlock,
   output logic [3:0]                      lsu_axi_arcache,
   output logic [2:0]                      lsu_axi_arprot,
   output logic [3:0]                      lsu_axi_arqos,

   input  logic                            lsu_axi_rvalid,
   output logic                            lsu_axi_rready,
   input  logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_rid,
   input  logic [63:0]                     lsu_axi_rdata,
   input  logic [1:0]                      lsu_axi_rresp,
   input  logic                            lsu_axi_rlast,

   //-------------------------- IFU AXI signals--------------------------
   // AXI Write Channels
   output logic                            ifu_axi_awvalid,
   input  logic                            ifu_axi_awready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_awid,
   output logic [31:0]                     ifu_axi_awaddr,
   output logic [3:0]                      ifu_axi_awregion,
   output logic [7:0]                      ifu_axi_awlen,
   output logic [2:0]                      ifu_axi_awsize,
   output logic [1:0]                      ifu_axi_awburst,
   output logic                            ifu_axi_awlock,
   output logic [3:0]                      ifu_axi_awcache,
   output logic [2:0]                      ifu_axi_awprot,
   output logic [3:0]                      ifu_axi_awqos,

   output logic                            ifu_axi_wvalid,
   input  logic                            ifu_axi_wready,
   output logic [63:0]                     ifu_axi_wdata,
   output logic [7:0]                      ifu_axi_wstrb,
   output logic                            ifu_axi_wlast,

   input  logic                            ifu_axi_bvalid,
   output logic                            ifu_axi_bready,
   input  logic [1:0]                      ifu_axi_bresp,
   input  logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_bid,

   // AXI Read Channels
   output logic                            ifu_axi_arvalid,
   input  logic                            ifu_axi_arready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_arid,
   output logic [31:0]                     ifu_axi_araddr,
   output logic [3:0]                      ifu_axi_arregion,
   output logic [7:0]                      ifu_axi_arlen,
   output logic [2:0]                      ifu_axi_arsize,
   output logic [1:0]                      ifu_axi_arburst,
   output logic                            ifu_axi_arlock,
   output logic [3:0]                      ifu_axi_arcache,
   output logic [2:0]                      ifu_axi_arprot,
   output logic [3:0]                      ifu_axi_arqos,

   input  logic                            ifu_axi_rvalid,
   output logic                            ifu_axi_rready,
   input  logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_rid,
   input  logic [63:0]                     ifu_axi_rdata,
   input  logic [1:0]                      ifu_axi_rresp,
   input  logic                            ifu_axi_rlast,

   //-------------------------- SB AXI signals--------------------------
   // AXI Write Channels
   output logic                            sb_axi_awvalid,
   input  logic                            sb_axi_awready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_awid,
   output logic [31:0]                     sb_axi_awaddr,
   output logic [3:0]                      sb_axi_awregion,
   output logic [7:0]                      sb_axi_awlen,
   output logic [2:0]                      sb_axi_awsize,
   output logic [1:0]                      sb_axi_awburst,
   output logic                            sb_axi_awlock,
   output logic [3:0]                      sb_axi_awcache,
   output logic [2:0]                      sb_axi_awprot,
   output logic [3:0]                      sb_axi_awqos,

   output logic                            sb_axi_wvalid,
   input  logic                            sb_axi_wready,
   output logic [63:0]                     sb_axi_wdata,
   output logic [7:0]                      sb_axi_wstrb,
   output logic                            sb_axi_wlast,

   input  logic                            sb_axi_bvalid,
   output logic                            sb_axi_bready,
   input  logic [1:0]                      sb_axi_bresp,
   input  logic [pt.SB_BUS_TAG-1:0]        sb_axi_bid,

   // AXI Read Channels
   output logic                            sb_axi_arvalid,
   input  logic                            sb_axi_arready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_arid,
   output logic [31:0]                     sb_axi_araddr,
   output logic [3:0]                      sb_axi_arregion,
   output logic [7:0]                      sb_axi_arlen,
   output logic [2:0]                      sb_axi_arsize,
   output logic [1:0]                      sb_axi_arburst,
   output logic                            sb_axi_arlock,
   output logic [3:0]                      sb_axi_arcache,
   output logic [2:0]                      sb_axi_arprot,
   output logic [3:0]                      sb_axi_arqos,

   input  logic                            sb_axi_rvalid,
   output logic                            sb_axi_rready,
   input  logic [pt.SB_BUS_TAG-1:0]        sb_axi_rid,
   input  logic [63:0]                     sb_axi_rdata,
   input  logic [1:0]                      sb_axi_rresp,
   input  logic                            sb_axi_rlast,

   //-------------------------- DMA AXI signals--------------------------
   // AXI Write Channels
   input  logic                         dma_axi_awvalid,
   output logic                         dma_axi_awready,
   input  logic [pt.DMA_BUS_TAG-1:0]    dma_axi_awid,
   input  logic [31:0]                  dma_axi_awaddr,
   input  logic [2:0]                   dma_axi_awsize,
   input  logic [2:0]                   dma_axi_awprot,
   input  logic [7:0]                   dma_axi_awlen,
   input  logic [1:0]                   dma_axi_awburst,


   input  logic                         dma_axi_wvalid,
   output logic                         dma_axi_wready,
   input  logic [63:0]                  dma_axi_wdata,
   input  logic [7:0]                   dma_axi_wstrb,
   input  logic                         dma_axi_wlast,

   output logic                         dma_axi_bvalid,
   input  logic                         dma_axi_bready,
   output logic [1:0]                   dma_axi_bresp,
   output logic [pt.DMA_BUS_TAG-1:0]    dma_axi_bid,

   // AXI Read Channels
   input  logic                         dma_axi_arvalid,
   output logic                         dma_axi_arready,
   input  logic [pt.DMA_BUS_TAG-1:0]    dma_axi_arid,
   input  logic [31:0]                  dma_axi_araddr,
   input  logic [2:0]                   dma_axi_arsize,
   input  logic [2:0]                   dma_axi_arprot,
   input  logic [7:0]                   dma_axi_arlen,
   input  logic [1:0]                   dma_axi_arburst,

   output logic                         dma_axi_rvalid,
   input  logic                         dma_axi_rready,
   output logic [pt.DMA_BUS_TAG-1:0]    dma_axi_rid,
   output logic [63:0]                  dma_axi_rdata,
   output logic [1:0]                   dma_axi_rresp,
   output logic                         dma_axi_rlast,

    //// AHB LITE BUS
   output logic [31:0]           haddr,
   output logic [2:0]            hburst,
   output logic                  hmastlock,
   output logic [3:0]            hprot,
   output logic [2:0]            hsize,
   output logic [1:0]            htrans,
   output logic                  hwrite,

   input  logic [63:0]           hrdata,
   input  logic                  hready,
   input  logic                  hresp,

   // LSU AHB Master
   output logic [31:0]          lsu_haddr,
   output logic [2:0]           lsu_hburst,
   output logic                 lsu_hmastlock,
   output logic [3:0]           lsu_hprot,
   output logic [2:0]           lsu_hsize,
   output logic [1:0]           lsu_htrans,
   output logic                 lsu_hwrite,
   output logic [63:0]          lsu_hwdata,

   input  logic [63:0]          lsu_hrdata,
   input  logic                 lsu_hready,
   input  logic                 lsu_hresp,

   //System Bus Debug Master
   output logic [31:0]          sb_haddr,
   output logic [2:0]           sb_hburst,
   output logic                 sb_hmastlock,
   output logic [3:0]           sb_hprot,
   output logic [2:0]           sb_hsize,
   output logic [1:0]           sb_htrans,
   output logic                 sb_hwrite,
   output logic [63:0]          sb_hwdata,

   input  logic [63:0]          sb_hrdata,
   input  logic                 sb_hready,
   input  logic                 sb_hresp,

   // DMA Slave
   input logic [31:0]            dma_haddr,
   input logic [2:0]             dma_hburst,
   input logic                   dma_hmastlock,
   input logic [3:0]             dma_hprot,
   input logic [2:0]             dma_hsize,
   input logic [1:0]             dma_htrans,
   input logic                   dma_hwrite,
   input logic [63:0]            dma_hwdata,
   input logic                   dma_hreadyin,
   input logic                   dma_hsel,

   output  logic [63:0]          dma_hrdata,
   output  logic                 dma_hreadyout,
   output  logic                 dma_hresp,

   input   logic                 lsu_bus_clk_en,
   input   logic                 ifu_bus_clk_en,
   input   logic                 dbg_bus_clk_en,
   input   logic                 dma_bus_clk_en,

   //DMI signals
   input logic                   dmi_reg_en,                // access enable
   input logic [6:0]             dmi_reg_addr,              // DM register address
   input logic                   dmi_reg_wr_en,             // write enable
   input logic [31:0]            dmi_reg_wdata,             // write data
   output logic [31:0]           dmi_reg_rdata,             // read data

   input logic [pt.PIC_TOTAL_INT:1] extintsrc_req,
   input logic [pt.NUM_THREADS-1:0] timer_int,              // Timer interrupt pending (from pin)
   input logic [pt.NUM_THREADS-1:0] soft_int,               // Software interrupt pending (from pin)
   input logic                      scan_mode
);



   logic [63:0]                  hwdata_nc;

   logic                         lsu_axi_awready_ahb;
   logic                         lsu_axi_wready_ahb;
   logic                         lsu_axi_bvalid_ahb;
   logic                         lsu_axi_bready_ahb;
   logic [1:0]                   lsu_axi_bresp_ahb;
   logic [pt.LSU_BUS_TAG-1:0]    lsu_axi_bid_ahb;
   logic                         lsu_axi_arready_ahb;
   logic                         lsu_axi_rvalid_ahb;
   logic [pt.LSU_BUS_TAG-1:0]    lsu_axi_rid_ahb;
   logic [63:0]                  lsu_axi_rdata_ahb;
   logic [1:0]                   lsu_axi_rresp_ahb;
   logic                         lsu_axi_rlast_ahb;

   logic                         lsu_axi_awready_int;
   logic                         lsu_axi_wready_int;
   logic                         lsu_axi_bvalid_int;
   logic                         lsu_axi_bready_int;
   logic [1:0]                   lsu_axi_bresp_int;
   logic [pt.LSU_BUS_TAG-1:0]    lsu_axi_bid_int;
   logic                         lsu_axi_arready_int;
   logic                         lsu_axi_rvalid_int;
   logic [pt.LSU_BUS_TAG-1:0]    lsu_axi_rid_int;
   logic [63:0]                  lsu_axi_rdata_int;
   logic [1:0]                   lsu_axi_rresp_int;
   logic                         lsu_axi_rlast_int;

   logic                         ifu_axi_awready_ahb;
   logic                         ifu_axi_wready_ahb;
   logic                         ifu_axi_bvalid_ahb;
   logic                         ifu_axi_bready_ahb;
   logic [1:0]                   ifu_axi_bresp_ahb;
   logic [pt.IFU_BUS_TAG-1:0]    ifu_axi_bid_ahb;
   logic                         ifu_axi_arready_ahb;
   logic                         ifu_axi_rvalid_ahb;
   logic [pt.IFU_BUS_TAG-1:0]    ifu_axi_rid_ahb;
   logic [63:0]                  ifu_axi_rdata_ahb;
   logic [1:0]                   ifu_axi_rresp_ahb;
   logic                         ifu_axi_rlast_ahb;

   logic                         ifu_axi_awready_int;
   logic                         ifu_axi_wready_int;
   logic                         ifu_axi_bvalid_int;
   logic                         ifu_axi_bready_int;
   logic [1:0]                   ifu_axi_bresp_int;
   logic [pt.IFU_BUS_TAG-1:0]    ifu_axi_bid_int;
   logic                         ifu_axi_arready_int;
   logic                         ifu_axi_rvalid_int;
   logic [pt.IFU_BUS_TAG-1:0]    ifu_axi_rid_int;
   logic [63:0]                  ifu_axi_rdata_int;
   logic [1:0]                   ifu_axi_rresp_int;
   logic                         ifu_axi_rlast_int;

   logic                         sb_axi_awready_ahb;
   logic                         sb_axi_wready_ahb;
   logic                         sb_axi_bvalid_ahb;
   logic                         sb_axi_bready_ahb;
   logic [1:0]                   sb_axi_bresp_ahb;
   logic [pt.SB_BUS_TAG-1:0]     sb_axi_bid_ahb;
   logic                         sb_axi_arready_ahb;
   logic                         sb_axi_rvalid_ahb;
   logic [pt.SB_BUS_TAG-1:0]     sb_axi_rid_ahb;
   logic [63:0]                  sb_axi_rdata_ahb;
   logic [1:0]                   sb_axi_rresp_ahb;
   logic                         sb_axi_rlast_ahb;

   logic                         sb_axi_awready_int;
   logic                         sb_axi_wready_int;
   logic                         sb_axi_bvalid_int;
   logic                         sb_axi_bready_int;
   logic [1:0]                   sb_axi_bresp_int;
   logic [pt.SB_BUS_TAG-1:0]     sb_axi_bid_int;
   logic                         sb_axi_arready_int;
   logic                         sb_axi_rvalid_int;
   logic [pt.SB_BUS_TAG-1:0]     sb_axi_rid_int;
   logic [63:0]                  sb_axi_rdata_int;
   logic [1:0]                   sb_axi_rresp_int;
   logic                         sb_axi_rlast_int;

   logic                         dma_axi_awvalid_ahb;
   logic [pt.DMA_BUS_TAG-1:0]    dma_axi_awid_ahb;
   logic [31:0]                  dma_axi_awaddr_ahb;
   logic [2:0]                   dma_axi_awsize_ahb;
   logic [2:0]                   dma_axi_awprot_ahb;
   logic [7:0]                   dma_axi_awlen_ahb;
   logic [1:0]                   dma_axi_awburst_ahb;
   logic                         dma_axi_wvalid_ahb;
   logic [63:0]                  dma_axi_wdata_ahb;
   logic [7:0]                   dma_axi_wstrb_ahb;
   logic                         dma_axi_wlast_ahb;
   logic                         dma_axi_bready_ahb;
   logic                         dma_axi_arvalid_ahb;
   logic [pt.DMA_BUS_TAG-1:0]    dma_axi_arid_ahb;
   logic [31:0]                  dma_axi_araddr_ahb;
   logic [2:0]                   dma_axi_arsize_ahb;
   logic [2:0]                   dma_axi_arprot_ahb;
   logic [7:0]                   dma_axi_arlen_ahb;
   logic [1:0]                   dma_axi_arburst_ahb;
   logic                         dma_axi_rready_ahb;

   logic                         dma_axi_awvalid_int;
   logic [pt.DMA_BUS_TAG-1:0]    dma_axi_awid_int;
   logic [31:0]                  dma_axi_awaddr_int;
   logic [2:0]                   dma_axi_awsize_int;
   logic [2:0]                   dma_axi_awprot_int;
   logic [7:0]                   dma_axi_awlen_int;
   logic [1:0]                   dma_axi_awburst_int;
   logic                         dma_axi_wvalid_int;
   logic [63:0]                  dma_axi_wdata_int;
   logic [7:0]                   dma_axi_wstrb_int;
   logic                         dma_axi_wlast_int;
   logic                         dma_axi_bready_int;
   logic                         dma_axi_arvalid_int;
   logic [pt.DMA_BUS_TAG-1:0]    dma_axi_arid_int;
   logic [31:0]                  dma_axi_araddr_int;
   logic [2:0]                   dma_axi_arsize_int;
   logic [2:0]                   dma_axi_arprot_int;
   logic [7:0]                   dma_axi_arlen_int;
   logic [1:0]                   dma_axi_arburst_int;
   logic                         dma_axi_rready_int;

   //----------------------------------------------------------------------
   //
   //----------------------------------------------------------------------

   logic [pt.NUM_THREADS-1:0][1:0] ifu_pmu_instr_aligned;
   logic [pt.NUM_THREADS-1:0]      ifu_pmu_align_stall;

   logic [pt.NUM_THREADS-1:0]  ifu_miss_state_idle;          // I-side miss buffer empty
   logic [pt.NUM_THREADS-1:0]  ifu_ic_error_start;           // IC single bit error
   logic [pt.NUM_THREADS-1:0]  ifu_iccm_rd_ecc_single_err;   // ICCM single bit error

// Icache debug
   logic [70:0]                  ifu_ic_debug_rd_data;

   logic ifu_ic_debug_rd_data_valid; // diagnostic icache read data valid
   eh2_cache_debug_pkt_t dec_tlu_ic_diag_pkt; // packet of DICAWICS, DICAD0/1, DICAGO info for icache diagnostics
   logic [pt.NUM_THREADS-1:0] dec_tlu_i0_commit_cmt;

   logic  [31:0] gpr_i0_rs1_d;
   logic  [31:0] gpr_i0_rs2_d;
   logic  [31:0] gpr_i1_rs1_d;
   logic  [31:0] gpr_i1_rs2_d;

   logic [31:0] i0_rs1_bypass_data_d;
   logic [31:0] i0_rs2_bypass_data_d;
   logic [31:0] i1_rs1_bypass_data_d;
   logic [31:0] i1_rs2_bypass_data_d;
   logic [31:0] exu_i0_result_e1, exu_i1_result_e1;
   logic [31:1] exu_i0_pc_e1;
   logic [31:1] exu_i1_pc_e1;  // from the primary alu's
   logic [pt.NUM_THREADS-1:0] [31:1] exu_npc_e4;

   eh2_alu_pkt_t  i0_ap, i1_ap;

   // Trigger signals
   eh2_trigger_pkt_t [pt.NUM_THREADS-1:0][3:0]     trigger_pkt_any;
   logic [3:0]             lsu_trigger_match_dc4;
   logic [pt.NUM_THREADS-1:0] dec_ib3_valid_d, dec_ib2_valid_d;

   logic [31:0] dec_i0_immed_d;
   logic [31:0] dec_i1_immed_d;

   logic [pt.BTB_TOFFSET_SIZE:1] dec_i0_br_immed_d;
   logic [pt.BTB_TOFFSET_SIZE:1] dec_i1_br_immed_d;

   logic         dec_i0_select_pc_d;
   logic         dec_i1_select_pc_d;

   logic [31:1] dec_i0_pc_d, dec_i1_pc_d;
   logic        dec_i0_rs1_bypass_en_d;
   logic        dec_i0_rs2_bypass_en_d;
   logic        dec_i1_rs1_bypass_en_d;
   logic        dec_i1_rs2_bypass_en_d;


   logic         dec_i0_alu_decode_d;
   logic         dec_i1_alu_decode_d;

   logic [pt.NUM_THREADS-1:0]         ifu_i0_valid, ifu_i1_valid;
   logic [pt.NUM_THREADS-1:0] [31:0]  ifu_i0_instr, ifu_i1_instr;
   logic [pt.NUM_THREADS-1:0] [31:1]  ifu_i0_pc, ifu_i1_pc;
   logic [31:2]  dec_tlu_meihap; // Fast ext int base

   logic [pt.NUM_THREADS-1:0]   flush_final_e3;             // final flush
   logic [pt.NUM_THREADS-1:0]   i0_flush_final_e3;          // final flush from i0

   logic [pt.NUM_THREADS-1:0]   exu_flush_final_early;              // Pipe is being flushed this cycle
   logic [pt.NUM_THREADS-1:0][31:1] exu_flush_path_final_early;         // Target for the oldest flush source

   logic [pt.NUM_THREADS-1:0] [31:1] exu_flush_path_final;

   logic [31:0] exu_lsu_rs1_d;
   logic [31:0] exu_lsu_rs2_d;


   eh2_lsu_pkt_t    lsu_p;

   logic [11:0] dec_lsu_offset_d;
   logic        dec_i0_lsu_d;       // chose which gpr value to use
   logic        dec_i1_lsu_d;

   logic [pt.NUM_THREADS-1:0] dec_tlu_force_halt;

   logic [31:0]  lsu_result_dc3;
   logic [31:0]  lsu_result_corr_dc4;
   logic         lsu_sc_success_dc5;
   logic         lsu_single_ecc_error_incr;     // Increment the ecc error counter
   eh2_lsu_error_pkt_t lsu_error_pkt_dc3;
   logic [pt.NUM_THREADS-1:0]        lsu_imprecise_error_load_any;
   logic [pt.NUM_THREADS-1:0]        lsu_imprecise_error_store_any;
   logic [pt.NUM_THREADS-1:0][31:0]  lsu_imprecise_error_addr_any;
   logic         lsu_fastint_stall_any;     // Stall fast interrupts at decode-1

   logic [pt.NUM_THREADS-1:0] lsu_amo_stall_any;         // This is for blocking amo
   logic [pt.NUM_THREADS-1:0] lsu_load_stall_any;        // This is for blocking loads
   logic [pt.NUM_THREADS-1:0] lsu_store_stall_any;       // This is for blocking stores
   logic [pt.NUM_THREADS-1:0] lsu_idle_any;              // This is used to enter halt mode. Exclude DMA

   logic [31:1]  lsu_fir_addr;              // fast interrupt address
   logic [1:0]   lsu_fir_error;             // Error during fast interrupt lookup

   // Non-blocking loads
   logic                                  lsu_nonblock_load_valid_dc1;
   logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0]    lsu_nonblock_load_tag_dc1;
   logic                                  lsu_nonblock_load_inv_dc2;
   logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0]    lsu_nonblock_load_inv_tag_dc2;
   logic                                  lsu_nonblock_load_inv_dc5;
   logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0]    lsu_nonblock_load_inv_tag_dc5;
   logic                                  lsu_nonblock_load_data_valid;
   logic                                  lsu_nonblock_load_data_error;
   logic                                  lsu_nonblock_load_data_tid;
   logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0]    lsu_nonblock_load_data_tag;
   logic [31:0]                           lsu_nonblock_load_data;


   logic [pt.NUM_THREADS-1:0] [31:1]      dec_tlu_flush_path_wb;  // flush pc
   logic [pt.NUM_THREADS-1:0]             dec_tlu_flush_mp_wb; // commit has a flush (mispredict at e4)
   logic [pt.NUM_THREADS-1:0]             dec_tlu_flush_lower_wb; // commit has a flush (exception; int; mispredict at e4)
   logic [pt.NUM_THREADS-1:0]             dec_tlu_flush_lower_wb1; // commit has a flush (exception; int; mispredict at e4)
   logic [pt.NUM_THREADS-1:0]             dec_tlu_flush_noredir_wb ; // Tell fetch to idle on this flush
   logic [pt.NUM_THREADS-1:0]             dec_tlu_flush_leak_one_wb; // single step
   logic [pt.NUM_THREADS-1:0]             dec_tlu_flush_err_wb; // iside perr/ecc rfpc
   logic [pt.NUM_THREADS-1:0]             dec_tlu_fence_i_wb;     // flush is a fence_i rfnpc, flush icache


   logic        dec_i0_csr_ren_d;

   logic [31:0] exu_i0_csr_rs1_e1;

   logic        dec_tlu_i0_kill_writeb_wb;    // I0 is flushed, don't writeback any results to arch state
   logic        dec_tlu_i1_kill_writeb_wb;    // I1 is flushed, don't writeback any results to arch state

   logic dec_tlu_i0_valid_e4;
   logic dec_tlu_i1_valid_e4;
   logic [31:0] dec_tlu_mrac_ff;        // CSR for memory region control
   logic [pt.NUM_THREADS-1:0] dec_tlu_lr_reset_wb; // Reset the reservation on certain events


   logic [pt.NUM_THREADS-1:0] ifu_i0_pc4, ifu_i1_pc4;

   eh2_predecode_pkt_t  [pt.NUM_THREADS-1:0] ifu_i0_predecode;
   eh2_predecode_pkt_t  [pt.NUM_THREADS-1:0] ifu_i1_predecode;



   eh2_mul_pkt_t  mul_p;

   logic [31:0] exu_mul_result_e3;

   logic dec_i0_mul_d;
   logic dec_i1_mul_d;

   eh2_div_pkt_t  div_p;

   logic        exu_div_wren;
   logic [31:0] exu_div_result;

   logic dec_i0_div_d;

   logic        dec_i1_valid_e1;

   logic [pt.NUM_THREADS-1:0][31:1] pred_correct_npc_e2; // npc e2 if the prediction is correct

   logic [31:0] exu_i0_result_e4;
   logic [31:0] exu_i1_result_e4;

   logic        dec_i0_rs1_bypass_en_e3;
   logic        dec_i0_rs2_bypass_en_e3;
   logic        dec_i1_rs1_bypass_en_e3;
   logic        dec_i1_rs2_bypass_en_e3;
   logic [31:0] i0_rs1_bypass_data_e3;
   logic [31:0] i0_rs2_bypass_data_e3;
   logic [31:0] i1_rs1_bypass_data_e3;
   logic [31:0] i1_rs2_bypass_data_e3;
   logic        dec_i0_sec_decode_e3;
   logic        dec_i1_sec_decode_e3;
   logic [31:1] dec_i0_pc_e3;
   logic [31:1] dec_i1_pc_e3;

   logic        dec_i0_rs1_bypass_en_e2;
   logic        dec_i0_rs2_bypass_en_e2;
   logic        dec_i1_rs1_bypass_en_e2;
   logic        dec_i1_rs2_bypass_en_e2;
   logic [31:0] i0_rs1_bypass_data_e2;
   logic [31:0] i0_rs2_bypass_data_e2;
   logic [31:0] i1_rs1_bypass_data_e2;
   logic [31:0] i1_rs2_bypass_data_e2;

   logic [31:1] exu_i0_flush_path_e4;
   logic [31:1] exu_i1_flush_path_e4;

   eh2_br_tlu_pkt_t dec_tlu_br0_wb_pkt;
   eh2_br_tlu_pkt_t dec_tlu_br1_wb_pkt;

   eh2_predict_pkt_t [pt.NUM_THREADS-1:0]                    exu_mp_pkt;
   logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           exu_mp_eghr;
   logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           exu_mp_fghr;
   logic [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_mp_index;
   logic [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          exu_mp_btag;
   logic [pt.NUM_THREADS-1:0] [pt.BTB_TOFFSET_SIZE-1:0]       exu_mp_toffset;

   logic [pt.BHT_GHR_SIZE-1:0]  exu_i0_br_fghr_e4;
   logic [1:0]  exu_i0_br_hist_e4;
   logic        exu_i0_br_bank_e4;
   logic        exu_i0_br_error_e4;
   logic        exu_i0_br_start_error_e4;
   logic        exu_i0_br_valid_e4;
   logic        exu_i0_br_mp_e4;
   logic        exu_i0_br_ret_e4;
   logic        exu_i0_br_call_e4;
   logic        exu_i0_br_middle_e4;
   logic [pt.BHT_GHR_SIZE-1:0]  exu_i1_br_fghr_e4;
   logic dec_i0_tid_e4;
   logic dec_i1_tid_e4;

   logic [1:0]  exu_i1_br_hist_e4;
   logic        exu_i1_br_bank_e4;
   logic        exu_i1_br_error_e4;
   logic        exu_i1_br_start_error_e4;
   logic        exu_i1_br_valid_e4;
   logic        exu_i1_br_mp_e4;
   logic        exu_i1_br_ret_e4;
   logic        exu_i1_br_call_e4;
   logic        exu_i1_br_middle_e4;
   logic        exu_i0_br_way_e4;
   logic        exu_i1_br_way_e4;

   logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_i0_br_index_e4;
   logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_i1_br_index_e4;

   logic        dma_dccm_req;
   logic        dma_dccm_spec_req;
   logic        dma_iccm_req;
   logic        dma_mem_addr_in_dccm;
   logic [2:0]  dma_mem_tag;
   logic [31:0] dma_mem_addr;
   logic [2:0]  dma_mem_sz;
   logic        dma_mem_write;
   logic [63:0] dma_mem_wdata;

   logic        dccm_dma_rvalid;
   logic        dccm_dma_ecc_error;
   logic [2:0]  dccm_dma_rtag;
   logic [63:0] dccm_dma_rdata;
   logic        iccm_dma_rvalid;
   logic        iccm_dma_ecc_error;
   logic [2:0]  iccm_dma_rtag;
   logic [63:0] iccm_dma_rdata;

   logic        dma_dccm_stall_any;       // Stall the ld/st in decode if asserted
   logic        dma_iccm_stall_any;       // Stall the fetch
   logic        dccm_ready;
   logic        iccm_ready;

   logic        dma_pmu_dccm_read;
   logic        dma_pmu_dccm_write;
   logic        dma_pmu_any_read;
   logic        dma_pmu_any_write;

   logic [31:0] i0_result_e4_eff;
   logic [31:0] i1_result_e4_eff;

   logic [31:0] i0_result_e2;

   logic [pt.NUM_THREADS-1:0] [1:0]  ifu_i0_icaf_type;
   logic [pt.NUM_THREADS-1:0]        ifu_i0_icaf;
   logic [pt.NUM_THREADS-1:0]        ifu_i0_icaf_second;
   logic [pt.NUM_THREADS-1:0]        ifu_i0_dbecc;
   logic                           iccm_dma_sb_error;

   logic [pt.NUM_THREADS-1:0] dec_i1_cancel_e1;

   eh2_br_pkt_t [pt.NUM_THREADS-1:0] i0_brp;
   eh2_br_pkt_t [pt.NUM_THREADS-1:0] i1_brp;
   logic [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i0_bp_index, ifu_i1_bp_index;
   logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           ifu_i0_bp_fghr, ifu_i1_bp_fghr;
   logic [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          ifu_i0_bp_btag, ifu_i1_bp_btag;
   logic [pt.NUM_THREADS-1:0] [pt.BTB_TOFFSET_SIZE-1:0]       ifu_i0_bp_toffset, ifu_i1_bp_toffset;

   logic [pt.NUM_THREADS-1:0] [$clog2(pt.BTB_SIZE)-1:0] ifu_i0_bp_fa_index, ifu_i1_bp_fa_index;
   logic [$clog2(pt.BTB_SIZE)-1:0] dec_fa_error_index; // Fully associt btb error index

   eh2_predict_pkt_t  i0_predict_p_d;
   eh2_predict_pkt_t  i1_predict_p_d;

   logic [pt.BHT_GHR_SIZE-1:0]           i0_predict_fghr_d, i1_predict_fghr_d;       // DEC predict fghr
   logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i0_predict_index_d, i1_predict_index_d;     // DEC predict index
   logic [pt.BTB_BTAG_SIZE-1:0]          i0_predict_btag_d, i1_predict_btag_d;       // DEC predict branch tag
   logic [pt.BTB_TOFFSET_SIZE-1:0]          i0_predict_toffset_d, i1_predict_toffset_d;       // DEC predict branch tag

   logic [pt.BHT_GHR_SIZE-1:0]           dec_tlu_br0_fghr_wb;  // fghr to bp
   logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_tlu_br0_index_wb; // bp index
   logic [pt.BHT_GHR_SIZE-1:0]           dec_tlu_br1_fghr_wb;  // fghr to bp
   logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_tlu_br1_index_wb; // bp index

      // PIC ports
   logic                  picm_rd_thr;
   logic                  picm_wren;
   logic                  picm_rden;
   logic                  picm_mken;
   logic [31:0]           picm_rdaddr;
   logic [31:0]           picm_wraddr;
   logic [31:0]           picm_wr_data;
   logic [31:0]           picm_rd_data;

   logic [pt.NUM_THREADS-1:0]  dec_tlu_btb_write_kill;

   logic  dec_tlu_external_ldfwd_disable;
   logic  dec_tlu_bpred_disable;
   logic  dec_tlu_wb_coalescing_disable;
   logic  dec_tlu_sideeffect_posted_disable;
   logic [2:0] dec_tlu_dma_qos_prty;

   // clock gating overrides from mcgc
   logic  dec_tlu_misc_clk_override;
   logic  dec_tlu_exu_clk_override;
   logic  dec_tlu_ifu_clk_override;
   logic  dec_tlu_lsu_clk_override;
   logic  dec_tlu_bus_clk_override;
   logic  dec_tlu_pic_clk_override;
   logic  dec_tlu_picio_clk_override;
   logic  dec_tlu_dccm_clk_override;
   logic  dec_tlu_icm_clk_override;

   // -----------------------DEBUG  START -------------------------------

   logic [31:0]            dbg_cmd_addr;              // the address of the debug command to used by the core
   logic [31:0]            dbg_cmd_wrdata;            // If the debug command is a write command, this has the data to be written to the CSR/GPR
   logic                   dbg_cmd_valid;             // commad is being driven by the dbg module. One pulse. Only dirven when core_halted has been seen
   logic                   dbg_cmd_tid;               // thread for debug register read
   logic                   dbg_cmd_write;             // 1: write command; 0: read_command
   logic [1:0]             dbg_cmd_type;              // 0:gpr 1:csr 2: memory
   logic [1:0]             dbg_cmd_size;              // size of the abstract mem access debug command
   logic [pt.NUM_THREADS-1:0] dbg_halt_req;           // Sticky signal indicating that the debug module wants to start the entering of debug mode ( start the halting sequence )
   logic [pt.NUM_THREADS-1:0] dbg_resume_req;         // Sticky signal indicating that the debug module wants to resume from debug mode
   logic                   dbg_core_rst_l;            // Core reset from DM

   logic                   core_dbg_cmd_done;         // Final muxed cmd done to debug
   logic                   core_dbg_cmd_fail;         // Final muxed cmd done to debug
   logic [31:0]            core_dbg_rddata;           // Final muxed cmd done to debug

   logic                   dma_dbg_cmd_done;          // Abstarct memory command sent to dma is done
   logic                   dma_dbg_cmd_fail;          // Abstarct memory command sent to dma failed
   logic [31:0]            dma_dbg_rddata;            // Read data for abstract memory access

   logic                   dbg_dma_bubble;            // Debug needs a bubble to send a valid
   logic                   dma_dbg_ready;             // DMA is ready to accept debug request

   logic [31:0]            dec_dbg_rddata;            // The core drives this data ( intercepts the pipe and sends it here )
   logic                   dec_dbg_cmd_done;          // This will be treated like a valid signal
   logic                   dec_dbg_cmd_fail;          // Abstract command failed
   logic                   dec_dbg_cmd_tid;           // Tid of abstract command response
   logic [pt.NUM_THREADS-1:0] dec_tlu_mpc_halted_only;   // Only halted due to MPC
   logic [pt.NUM_THREADS-1:0] dec_tlu_dbg_halted;        // The core has finished the queiscing sequence. Sticks this signal high
   logic [pt.NUM_THREADS-1:0] dec_tlu_resume_ack;
   logic [pt.NUM_THREADS-1:0] dec_tlu_debug_mode;        // Core is in debug mode
   logic                   dec_debug_wdata_rs1_d;

   logic [4:1]             dec_i0_data_en;
   logic [4:1]             dec_i0_ctl_en;
   logic [4:1]             dec_i1_data_en;
   logic [4:1]             dec_i1_ctl_en;

   // PMU Signals
   logic                   exu_pmu_i0_br_misp;
   logic                   exu_pmu_i0_br_ataken;
   logic                   exu_pmu_i0_pc4;
   logic                   exu_pmu_i1_br_misp;
   logic                   exu_pmu_i1_br_ataken;
   logic                   exu_pmu_i1_pc4;

   logic [pt.NUM_THREADS-1:0]  lsu_pmu_load_external_dc3;
   logic [pt.NUM_THREADS-1:0]  lsu_pmu_store_external_dc3;
   logic [pt.NUM_THREADS-1:0]  lsu_pmu_misaligned_dc3;
   logic [pt.NUM_THREADS-1:0]  lsu_pmu_bus_trxn;
   logic [pt.NUM_THREADS-1:0]  lsu_pmu_bus_misaligned;
   logic [pt.NUM_THREADS-1:0]  lsu_pmu_bus_error;
   logic [pt.NUM_THREADS-1:0]  lsu_pmu_bus_busy;

   logic [pt.NUM_THREADS-1:0] ifu_pmu_fetch_stall;

   logic [pt.NUM_THREADS-1:0] ifu_pmu_ic_miss;               // IC miss event
   logic [pt.NUM_THREADS-1:0] ifu_pmu_ic_hit;                // IC hit event
   logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_error;             // Bus error event
   logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_busy;              // Bus busy event
   logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_trxn;              // Bus transaction

   logic                      active_state;
   logic                      free_clk, active_clk;
   logic [pt.NUM_THREADS-1:0] dec_pause_state_cg;


   logic [pt.NUM_THREADS-1:0] [15:0]            ifu_i0_cinst;
   logic [pt.NUM_THREADS-1:0] [15:0]            ifu_i1_cinst;

   logic [31:0]                  lsu_rs1_dc1;

   logic                         dec_extint_stall;

   eh2_trace_pkt_t  [pt.NUM_THREADS-1:0] trace_rv_trace_pkt;

   logic [pt.NUM_THREADS-1:0]    exu_flush_final;            // Pipe is being flushed this cycle
   logic [pt.NUM_THREADS-1:0]    exu_i0_flush_final;         // I0 flush to DEC
   logic [pt.NUM_THREADS-1:0]    exu_i1_flush_final;         // I1 flush to DEC

   logic [pt.NUM_THREADS-1:0]    exu_i0_flush_lower_e4;        // to TLU - lower branch flush
   logic [pt.NUM_THREADS-1:0]    exu_i1_flush_lower_e4;        // to TLU - lower branch flush

   logic                         dec_div_cancel;             // cancel divide operation

   logic [pt.NUM_THREADS-1:0] [7:0]  pic_claimid;
   logic [pt.NUM_THREADS-1:0] [3:0]  pic_pl, dec_tlu_meicurpl, dec_tlu_meipt;
   logic [pt.NUM_THREADS-1:0]        mexintpend;
   logic [pt.NUM_THREADS-1:0]        mhwakeup;


   logic        dma_active;


// 2nd level clock headers

   logic [pt.NUM_THREADS-1:0] pause_state;
   logic [pt.NUM_THREADS-1:0] halt_state;
   logic [pt.NUM_THREADS-1:0] active_thread;
   logic [pt.NUM_THREADS-1:0] active_thread_l2clk;

   logic        dec_tlu_core_empty;

   logic        active_raw_state;
   logic        active_raw_l2clk;

   logic        lsu_active;

   logic        dec_i0_secondary_d;
   logic        dec_i0_secondary_e1;
   logic        dec_i0_secondary_e2;

   logic        dec_i1_secondary_d;
   logic        dec_i1_secondary_e1;
   logic        dec_i1_secondary_e2;

   logic        dec_i0_branch_d;
   logic        dec_i0_branch_e1;
   logic        dec_i0_branch_e2;
   logic        dec_i0_branch_e3;

   logic        dec_i1_branch_d;
   logic        dec_i1_branch_e1;
   logic        dec_i1_branch_e2;
   logic        dec_i1_branch_e3;

   logic        dec_i0_pc4_e4;
   logic        dec_i1_pc4_e4;



   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign pause_state[i] = dec_pause_state_cg[i] & ~(dma_active | lsu_active) & dec_tlu_core_empty;
      assign halt_state[i] = o_cpu_halt_status[i] & ~(dma_active | lsu_active);

      assign active_thread[i] = (~(halt_state[i] | pause_state[i]) | dec_tlu_flush_lower_wb[i] | dec_tlu_flush_lower_wb1[i])  | dec_tlu_misc_clk_override;

      rvoclkhdr act_cg   ( .clk(clk), .en(active_thread[i]),         .l1clk(active_thread_l2clk[i]), .* );
   end

   if (pt.NUM_THREADS == 1) begin

      assign active_state = (~(halt_state[0] | pause_state[0]) | (|dec_tlu_flush_lower_wb) | (|dec_tlu_flush_lower_wb1))  | dec_tlu_misc_clk_override;

   end else begin

      assign active_state = (~( (halt_state[1] | pause_state[1]) & (halt_state[0] | pause_state[0])) | (|dec_tlu_flush_lower_wb) | (|dec_tlu_flush_lower_wb1))  | dec_tlu_misc_clk_override;
   end


   rvoclkhdr free_cg2   ( .clk(clk), .en(1'b1),         .l1clk(free_l2clk), .* );
   rvoclkhdr active_cg2 ( .clk(clk), .en(active_state), .l1clk(active_l2clk), .* );

   rvoclkhdr free_cg1     ( .clk(free_l2clk),     .en(1'b1), .l1clk(free_clk), .* );
   rvoclkhdr active_cg1   ( .clk(active_l2clk),   .en(1'b1), .l1clk(active_clk), .* );


   assign        dccm_clk_override = dec_tlu_dccm_clk_override;   // dccm memory
   assign        icm_clk_override = dec_tlu_icm_clk_override;     // icache/iccm memory
   assign        btb_clk_override = dec_tlu_ifu_clk_override;


   assign core_dbg_cmd_done = dma_dbg_cmd_done | dec_dbg_cmd_done;
   assign core_dbg_cmd_fail = dma_dbg_cmd_fail | dec_dbg_cmd_fail;
   assign core_dbg_rddata[31:0] = dma_dbg_cmd_done ? dma_dbg_rddata[31:0] : dec_dbg_rddata[31:0];

   eh2_dbg #(.pt(pt)) dbg (
                            .rst_l(core_rst_l),
                            .clk(free_l2clk),
                            .clk_override(dec_tlu_misc_clk_override),

                            // AXI signals
                            .sb_axi_awready(sb_axi_awready_int),
                            .sb_axi_wready(sb_axi_wready_int),
                            .sb_axi_bvalid(sb_axi_bvalid_int),
                            .sb_axi_bresp(sb_axi_bresp_int[1:0]),

                            .sb_axi_arready(sb_axi_arready_int),
                            .sb_axi_rvalid(sb_axi_rvalid_int),
                            .sb_axi_rdata(sb_axi_rdata_int[63:0]),
                            .sb_axi_rresp(sb_axi_rresp_int[1:0]),

                            .*
                            );


   // -----------------   DEBUG END -----------------------------

   assign core_rst_l = rst_l & (dbg_core_rst_l | scan_mode);

   // fetch
   eh2_ifu #(.pt(pt)) ifu (
                            .clk(active_l2clk),
                            .clk_override(dec_tlu_ifu_clk_override),
                            .rst_l(core_rst_l),

                            // AXI signals
                            .ifu_axi_arready(ifu_axi_arready_int),
                            .ifu_axi_rvalid(ifu_axi_rvalid_int),
                            .ifu_axi_rid(ifu_axi_rid_int[pt.IFU_BUS_TAG-1:0]),
                            .ifu_axi_rdata(ifu_axi_rdata_int[63:0]),
                            .ifu_axi_rresp(ifu_axi_rresp_int[1:0]),

                            .*
                            );



   eh2_dec #(.pt(pt)) dec (
                            .clk(active_l2clk),
                            .dbg_cmd_wrdata(dbg_cmd_wrdata[1:0]),
                            .rst_l(core_rst_l),
                            .*
                            );

   eh2_exu #(.pt(pt)) exu (
                            .clk(active_l2clk),
                            .clk_override(dec_tlu_exu_clk_override),
                            .rst_l(core_rst_l),
                            .*
                            );

   eh2_lsu #(.pt(pt)) lsu (
                            .clk(active_l2clk),
                            .clk_override(dec_tlu_lsu_clk_override),
                            .rst_l(core_rst_l),

                            // AXI signals
                            .lsu_axi_awready(lsu_axi_awready_int),
                            .lsu_axi_wready(lsu_axi_wready_int),
                            .lsu_axi_bvalid(lsu_axi_bvalid_int),
                            .lsu_axi_bid(lsu_axi_bid_int[pt.LSU_BUS_TAG-1:0]),
                            .lsu_axi_bresp(lsu_axi_bresp_int[1:0]),

                            .lsu_axi_arready(lsu_axi_arready_int),
                            .lsu_axi_rvalid(lsu_axi_rvalid_int),
                            .lsu_axi_rid(lsu_axi_rid_int[pt.LSU_BUS_TAG-1:0]),
                            .lsu_axi_rdata(lsu_axi_rdata_int[63:0]),
                            .lsu_axi_rresp(lsu_axi_rresp_int[1:0]),
                            .lsu_axi_rlast(lsu_axi_rlast_int),

                            .*
                            );

   eh2_pic_ctrl #(.pt(pt))  pic_ctrl_inst (
                                            .clk(free_l2clk),
                                            .clk_override(dec_tlu_pic_clk_override),
                                            .io_clk_override(dec_tlu_picio_clk_override),
                                            .picm_mken (picm_mken),
                                            .extintsrc_req({extintsrc_req[pt.PIC_TOTAL_INT:1],1'b0}),
                                            .pl_out(pic_pl),
                                            .claimid_out(pic_claimid),
                                            .mexintpend_out(mexintpend),
                                            .mhwakeup_out(mhwakeup),
                                            .rst_l(core_rst_l),
                                            .*);

   eh2_dma_ctrl #(.pt(pt)) dma_ctrl (
                                      .clk(free_l2clk),
                                      .rst_l(core_rst_l),
                                      .clk_override(dec_tlu_misc_clk_override),

                                      // AXI signals
                                      .dma_axi_awvalid(dma_axi_awvalid_int),
                                      .dma_axi_awid(dma_axi_awid_int[pt.DMA_BUS_TAG-1:0]),
                                      .dma_axi_awaddr(dma_axi_awaddr_int[31:0]),
                                      .dma_axi_awsize(dma_axi_awsize_int[2:0]),
                                      .dma_axi_wvalid(dma_axi_wvalid_int),
                                      .dma_axi_wdata(dma_axi_wdata_int[63:0]),
                                      .dma_axi_wstrb(dma_axi_wstrb_int[7:0]),
                                      .dma_axi_bready(dma_axi_bready_int),

                                      .dma_axi_arvalid(dma_axi_arvalid_int),
                                      .dma_axi_arid(dma_axi_arid_int[pt.DMA_BUS_TAG-1:0]),
                                      .dma_axi_araddr(dma_axi_araddr_int[31:0]),
                                      .dma_axi_arsize(dma_axi_arsize_int[2:0]),
                                      .dma_axi_rready(dma_axi_rready_int),

                                      .*
   );

   if (pt.BUILD_AHB_LITE == 1) begin: Gen_AXI_To_AHB

      // AXI4 -> AHB Gasket for LSU
      axi4_to_ahb #(.NUM_THREADS(pt.NUM_THREADS),
                    .TAG(pt.LSU_BUS_TAG)) lsu_axi4_to_ahb (
         .clk(free_l2clk),
         .free_clk(free_clk),
         .rst_l(core_rst_l),
         .clk_override(dec_tlu_bus_clk_override),
         .bus_clk_en(lsu_bus_clk_en),
         .dec_tlu_force_halt(dec_tlu_force_halt),

         // AXI Write Channels
         .axi_awvalid(lsu_axi_awvalid),
         .axi_awready(lsu_axi_awready_ahb),
         .axi_awid(lsu_axi_awid[pt.LSU_BUS_TAG-1:0]),
         .axi_awaddr(lsu_axi_awaddr[31:0]),
         .axi_awsize(lsu_axi_awsize[2:0]),
         .axi_awprot(lsu_axi_awprot[2:0]),

         .axi_wvalid(lsu_axi_wvalid),
         .axi_wready(lsu_axi_wready_ahb),
         .axi_wdata(lsu_axi_wdata[63:0]),
         .axi_wstrb(lsu_axi_wstrb[7:0]),
         .axi_wlast(lsu_axi_wlast),

         .axi_bvalid(lsu_axi_bvalid_ahb),
         .axi_bready(lsu_axi_bready),
         .axi_bresp(lsu_axi_bresp_ahb[1:0]),
         .axi_bid(lsu_axi_bid_ahb[pt.LSU_BUS_TAG-1:0]),

         // AXI Read Channels
         .axi_arvalid(lsu_axi_arvalid),
         .axi_arready(lsu_axi_arready_ahb),
         .axi_arid(lsu_axi_arid[pt.LSU_BUS_TAG-1:0]),
         .axi_araddr(lsu_axi_araddr[31:0]),
         .axi_arsize(lsu_axi_arsize[2:0]),
         .axi_arprot(lsu_axi_arprot[2:0]),

         .axi_rvalid(lsu_axi_rvalid_ahb),
         .axi_rready(lsu_axi_rready),
         .axi_rid(lsu_axi_rid_ahb[pt.LSU_BUS_TAG-1:0]),
         .axi_rdata(lsu_axi_rdata_ahb[63:0]),
         .axi_rresp(lsu_axi_rresp_ahb[1:0]),
         .axi_rlast(lsu_axi_rlast_ahb),

         // AHB-LITE signals
         .ahb_haddr(lsu_haddr[31:0]),
         .ahb_hburst(lsu_hburst),
         .ahb_hmastlock(lsu_hmastlock),
         .ahb_hprot(lsu_hprot[3:0]),
         .ahb_hsize(lsu_hsize[2:0]),
         .ahb_htrans(lsu_htrans[1:0]),
         .ahb_hwrite(lsu_hwrite),
         .ahb_hwdata(lsu_hwdata[63:0]),

         .ahb_hrdata(lsu_hrdata[63:0]),
         .ahb_hready(lsu_hready),
         .ahb_hresp(lsu_hresp),

         .*
      );

      axi4_to_ahb #(.NUM_THREADS(pt.NUM_THREADS),
                    .TAG(pt.IFU_BUS_TAG)) ifu_axi4_to_ahb (
         .clk(free_l2clk),
         .free_clk(free_clk),
         .rst_l(core_rst_l),
         .clk_override(dec_tlu_bus_clk_override),
         .bus_clk_en(ifu_bus_clk_en),
         .dec_tlu_force_halt(dec_tlu_force_halt),

          // AHB-Lite signals
         .ahb_haddr(haddr[31:0]),
         .ahb_hburst(hburst),
         .ahb_hmastlock(hmastlock),
         .ahb_hprot(hprot[3:0]),
         .ahb_hsize(hsize[2:0]),
         .ahb_htrans(htrans[1:0]),
         .ahb_hwrite(hwrite),
         .ahb_hwdata(hwdata_nc[63:0]),

         .ahb_hrdata(hrdata[63:0]),
         .ahb_hready(hready),
         .ahb_hresp(hresp),

         // AXI Write Channels
         .axi_awvalid(ifu_axi_awvalid),
         .axi_awready(ifu_axi_awready_ahb),
         .axi_awid(ifu_axi_awid[pt.IFU_BUS_TAG-1:0]),
         .axi_awaddr(ifu_axi_awaddr[31:0]),
         .axi_awsize(ifu_axi_awsize[2:0]),
         .axi_awprot(ifu_axi_awprot[2:0]),

         .axi_wvalid(ifu_axi_wvalid),
         .axi_wready(ifu_axi_wready_ahb),
         .axi_wdata(ifu_axi_wdata[63:0]),
         .axi_wstrb(ifu_axi_wstrb[7:0]),
         .axi_wlast(ifu_axi_wlast),

         .axi_bvalid(ifu_axi_bvalid_ahb),
         .axi_bready(1'b1),
         .axi_bresp(ifu_axi_bresp_ahb[1:0]),
         .axi_bid(ifu_axi_bid_ahb[pt.IFU_BUS_TAG-1:0]),

         // AXI Read Channels
         .axi_arvalid(ifu_axi_arvalid),
         .axi_arready(ifu_axi_arready_ahb),
         .axi_arid(ifu_axi_arid[pt.IFU_BUS_TAG-1:0]),
         .axi_araddr(ifu_axi_araddr[31:0]),
         .axi_arsize(ifu_axi_arsize[2:0]),
         .axi_arprot(ifu_axi_arprot[2:0]),

         .axi_rvalid(ifu_axi_rvalid_ahb),
         .axi_rready(ifu_axi_rready),
         .axi_rid(ifu_axi_rid_ahb[pt.IFU_BUS_TAG-1:0]),
         .axi_rdata(ifu_axi_rdata_ahb[63:0]),
         .axi_rresp(ifu_axi_rresp_ahb[1:0]),
         .axi_rlast(ifu_axi_rlast_ahb),
         .*
      );

      // AXI4 -> AHB Gasket for System Bus
      axi4_to_ahb #(.NUM_THREADS(pt.NUM_THREADS),
                    .TAG(pt.SB_BUS_TAG)) sb_axi4_to_ahb (
         .clk_override(dec_tlu_bus_clk_override),
         .rst_l(dbg_rst_l),
         .clk(free_l2clk),
         .free_clk(free_clk),
         .bus_clk_en(dbg_bus_clk_en),
         .dec_tlu_force_halt({pt.NUM_THREADS{1'b0}}),

         // AXI Write Channels
         .axi_awvalid(sb_axi_awvalid),
         .axi_awready(sb_axi_awready_ahb),
         .axi_awid(sb_axi_awid[pt.SB_BUS_TAG-1:0]),
         .axi_awaddr(sb_axi_awaddr[31:0]),
         .axi_awsize(sb_axi_awsize[2:0]),
         .axi_awprot(sb_axi_awprot[2:0]),

         .axi_wvalid(sb_axi_wvalid),
         .axi_wready(sb_axi_wready_ahb),
         .axi_wdata(sb_axi_wdata[63:0]),
         .axi_wstrb(sb_axi_wstrb[7:0]),
         .axi_wlast(sb_axi_wlast),

         .axi_bvalid(sb_axi_bvalid_ahb),
         .axi_bready(sb_axi_bready),
         .axi_bresp(sb_axi_bresp_ahb[1:0]),
         .axi_bid(sb_axi_bid_ahb[pt.SB_BUS_TAG-1:0]),

         // AXI Read Channels
         .axi_arvalid(sb_axi_arvalid),
         .axi_arready(sb_axi_arready_ahb),
         .axi_arid(sb_axi_arid[pt.SB_BUS_TAG-1:0]),
         .axi_araddr(sb_axi_araddr[31:0]),
         .axi_arsize(sb_axi_arsize[2:0]),
         .axi_arprot(sb_axi_arprot[2:0]),

         .axi_rvalid(sb_axi_rvalid_ahb),
         .axi_rready(sb_axi_rready),
         .axi_rid(sb_axi_rid_ahb[pt.SB_BUS_TAG-1:0]),
         .axi_rdata(sb_axi_rdata_ahb[63:0]),
         .axi_rresp(sb_axi_rresp_ahb[1:0]),
         .axi_rlast(sb_axi_rlast_ahb),

         // AHB-LITE signals
         .ahb_haddr(sb_haddr[31:0]),
         .ahb_hburst(sb_hburst),
         .ahb_hmastlock(sb_hmastlock),
         .ahb_hprot(sb_hprot[3:0]),
         .ahb_hsize(sb_hsize[2:0]),
         .ahb_htrans(sb_htrans[1:0]),
         .ahb_hwrite(sb_hwrite),
         .ahb_hwdata(sb_hwdata[63:0]),

         .ahb_hrdata(sb_hrdata[63:0]),
         .ahb_hready(sb_hready),
         .ahb_hresp(sb_hresp),

         .*
      );

      //AHB -> AXI4 Gasket for DMA
      ahb_to_axi4 #(.pt(pt),
                    .TAG(pt.DMA_BUS_TAG)) dma_ahb_to_axi4 (
         .clk_override(dec_tlu_bus_clk_override),
         .rst_l(core_rst_l),
         .clk(free_l2clk),
         .bus_clk_en(dma_bus_clk_en),

         // AXI Write Channels
         .axi_awvalid(dma_axi_awvalid_ahb),
         .axi_awready(dma_axi_awready),
         .axi_awid(dma_axi_awid_ahb[pt.DMA_BUS_TAG-1:0]),
         .axi_awaddr(dma_axi_awaddr_ahb[31:0]),
         .axi_awsize(dma_axi_awsize_ahb[2:0]),
         .axi_awprot(dma_axi_awprot_ahb[2:0]),
         .axi_awlen(dma_axi_awlen_ahb[7:0]),
         .axi_awburst(dma_axi_awburst_ahb[1:0]),

         .axi_wvalid(dma_axi_wvalid_ahb),
         .axi_wready(dma_axi_wready),
         .axi_wdata(dma_axi_wdata_ahb[63:0]),
         .axi_wstrb(dma_axi_wstrb_ahb[7:0]),
         .axi_wlast(dma_axi_wlast_ahb),

         .axi_bvalid(dma_axi_bvalid),
         .axi_bready(dma_axi_bready_ahb),
         .axi_bresp(dma_axi_bresp[1:0]),
         .axi_bid(dma_axi_bid[pt.DMA_BUS_TAG-1:0]),

         // AXI Read Channels
         .axi_arvalid(dma_axi_arvalid_ahb),
         .axi_arready(dma_axi_arready),
         .axi_arid(dma_axi_arid_ahb[pt.DMA_BUS_TAG-1:0]),
         .axi_araddr(dma_axi_araddr_ahb[31:0]),
         .axi_arsize(dma_axi_arsize_ahb[2:0]),
         .axi_arprot(dma_axi_arprot_ahb[2:0]),
         .axi_arlen(dma_axi_arlen_ahb[7:0]),
         .axi_arburst(dma_axi_arburst_ahb[1:0]),

         .axi_rvalid(dma_axi_rvalid),
         .axi_rready(dma_axi_rready_ahb),
         .axi_rid(dma_axi_rid[pt.DMA_BUS_TAG-1:0]),
         .axi_rdata(dma_axi_rdata[63:0]),
         .axi_rresp(dma_axi_rresp[1:0]),

          // AHB signals
         .ahb_haddr(dma_haddr[31:0]),
         .ahb_hburst(dma_hburst),
         .ahb_hmastlock(dma_hmastlock),
         .ahb_hprot(dma_hprot[3:0]),
         .ahb_hsize(dma_hsize[2:0]),
         .ahb_htrans(dma_htrans[1:0]),
         .ahb_hwrite(dma_hwrite),
         .ahb_hwdata(dma_hwdata[63:0]),

         .ahb_hrdata(dma_hrdata[63:0]),
         .ahb_hreadyout(dma_hreadyout),
         .ahb_hresp(dma_hresp),
         .ahb_hreadyin(dma_hreadyin),
         .ahb_hsel(dma_hsel),
         .*
      );

   end

   // Drive the final AXI inputs
   assign lsu_axi_awready_int                 = pt.BUILD_AHB_LITE ? lsu_axi_awready_ahb : lsu_axi_awready;
   assign lsu_axi_wready_int                  = pt.BUILD_AHB_LITE ? lsu_axi_wready_ahb : lsu_axi_wready;
   assign lsu_axi_bvalid_int                  = pt.BUILD_AHB_LITE ? lsu_axi_bvalid_ahb : lsu_axi_bvalid;
   assign lsu_axi_bready_int                  = pt.BUILD_AHB_LITE ? lsu_axi_bready_ahb : lsu_axi_bready;
   assign lsu_axi_bresp_int[1:0]              = pt.BUILD_AHB_LITE ? lsu_axi_bresp_ahb[1:0] : lsu_axi_bresp[1:0];
   assign lsu_axi_bid_int[pt.LSU_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? lsu_axi_bid_ahb[pt.LSU_BUS_TAG-1:0] : lsu_axi_bid[pt.LSU_BUS_TAG-1:0];
   assign lsu_axi_arready_int                 = pt.BUILD_AHB_LITE ? lsu_axi_arready_ahb : lsu_axi_arready;
   assign lsu_axi_rvalid_int                  = pt.BUILD_AHB_LITE ? lsu_axi_rvalid_ahb : lsu_axi_rvalid;
   assign lsu_axi_rid_int[pt.LSU_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? lsu_axi_rid_ahb[pt.LSU_BUS_TAG-1:0] : lsu_axi_rid[pt.LSU_BUS_TAG-1:0];
   assign lsu_axi_rdata_int[63:0]             = pt.BUILD_AHB_LITE ? lsu_axi_rdata_ahb[63:0] : lsu_axi_rdata[63:0];
   assign lsu_axi_rresp_int[1:0]              = pt.BUILD_AHB_LITE ? lsu_axi_rresp_ahb[1:0] : lsu_axi_rresp[1:0];
   assign lsu_axi_rlast_int                   = pt.BUILD_AHB_LITE ? lsu_axi_rlast_ahb : lsu_axi_rlast;

   assign ifu_axi_awready_int                 = pt.BUILD_AHB_LITE ? ifu_axi_awready_ahb : ifu_axi_awready;
   assign ifu_axi_wready_int                  = pt.BUILD_AHB_LITE ? ifu_axi_wready_ahb : ifu_axi_wready;
   assign ifu_axi_bvalid_int                  = pt.BUILD_AHB_LITE ? ifu_axi_bvalid_ahb : ifu_axi_bvalid;
   assign ifu_axi_bready_int                  = pt.BUILD_AHB_LITE ? ifu_axi_bready_ahb : ifu_axi_bready;
   assign ifu_axi_bresp_int[1:0]              = pt.BUILD_AHB_LITE ? ifu_axi_bresp_ahb[1:0] : ifu_axi_bresp[1:0];
   assign ifu_axi_bid_int[pt.IFU_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? ifu_axi_bid_ahb[pt.IFU_BUS_TAG-1:0] : ifu_axi_bid[pt.IFU_BUS_TAG-1:0];
   assign ifu_axi_arready_int                 = pt.BUILD_AHB_LITE ? ifu_axi_arready_ahb : ifu_axi_arready;
   assign ifu_axi_rvalid_int                  = pt.BUILD_AHB_LITE ? ifu_axi_rvalid_ahb : ifu_axi_rvalid;
   assign ifu_axi_rid_int[pt.IFU_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? ifu_axi_rid_ahb[pt.IFU_BUS_TAG-1:0] : ifu_axi_rid[pt.IFU_BUS_TAG-1:0];
   assign ifu_axi_rdata_int[63:0]             = pt.BUILD_AHB_LITE ? ifu_axi_rdata_ahb[63:0] : ifu_axi_rdata[63:0];
   assign ifu_axi_rresp_int[1:0]              = pt.BUILD_AHB_LITE ? ifu_axi_rresp_ahb[1:0] : ifu_axi_rresp[1:0];
   assign ifu_axi_rlast_int                   = pt.BUILD_AHB_LITE ? ifu_axi_rlast_ahb : ifu_axi_rlast;

   assign sb_axi_awready_int                  = pt.BUILD_AHB_LITE ? sb_axi_awready_ahb : sb_axi_awready;
   assign sb_axi_wready_int                   = pt.BUILD_AHB_LITE ? sb_axi_wready_ahb : sb_axi_wready;
   assign sb_axi_bvalid_int                   = pt.BUILD_AHB_LITE ? sb_axi_bvalid_ahb : sb_axi_bvalid;
   assign sb_axi_bready_int                   = pt.BUILD_AHB_LITE ? sb_axi_bready_ahb : sb_axi_bready;
   assign sb_axi_bresp_int[1:0]               = pt.BUILD_AHB_LITE ? sb_axi_bresp_ahb[1:0] : sb_axi_bresp[1:0];
   assign sb_axi_bid_int[pt.SB_BUS_TAG-1:0]   = pt.BUILD_AHB_LITE ? sb_axi_bid_ahb[pt.SB_BUS_TAG-1:0] : sb_axi_bid[pt.SB_BUS_TAG-1:0];
   assign sb_axi_arready_int                  = pt.BUILD_AHB_LITE ? sb_axi_arready_ahb : sb_axi_arready;
   assign sb_axi_rvalid_int                   = pt.BUILD_AHB_LITE ? sb_axi_rvalid_ahb : sb_axi_rvalid;
   assign sb_axi_rid_int[pt.SB_BUS_TAG-1:0]   = pt.BUILD_AHB_LITE ? sb_axi_rid_ahb[pt.SB_BUS_TAG-1:0] : sb_axi_rid[pt.SB_BUS_TAG-1:0];
   assign sb_axi_rdata_int[63:0]              = pt.BUILD_AHB_LITE ? sb_axi_rdata_ahb[63:0] : sb_axi_rdata[63:0];
   assign sb_axi_rresp_int[1:0]               = pt.BUILD_AHB_LITE ? sb_axi_rresp_ahb[1:0] : sb_axi_rresp[1:0];
   assign sb_axi_rlast_int                    = pt.BUILD_AHB_LITE ? sb_axi_rlast_ahb : sb_axi_rlast;

   assign dma_axi_awvalid_int                  = pt.BUILD_AHB_LITE ? dma_axi_awvalid_ahb : dma_axi_awvalid;
   assign dma_axi_awid_int[pt.DMA_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? dma_axi_awid_ahb[pt.DMA_BUS_TAG-1:0] : dma_axi_awid[pt.DMA_BUS_TAG-1:0];
   assign dma_axi_awaddr_int[31:0]             = pt.BUILD_AHB_LITE ? dma_axi_awaddr_ahb[31:0] : dma_axi_awaddr[31:0];
   assign dma_axi_awsize_int[2:0]              = pt.BUILD_AHB_LITE ? dma_axi_awsize_ahb[2:0] : dma_axi_awsize[2:0];
   assign dma_axi_awprot_int[2:0]              = pt.BUILD_AHB_LITE ? dma_axi_awprot_ahb[2:0] : dma_axi_awprot[2:0];
   assign dma_axi_awlen_int[7:0]               = pt.BUILD_AHB_LITE ? dma_axi_awlen_ahb[7:0] : dma_axi_awlen[7:0];
   assign dma_axi_awburst_int[1:0]             = pt.BUILD_AHB_LITE ? dma_axi_awburst_ahb[1:0] : dma_axi_awburst[1:0];
   assign dma_axi_wvalid_int                   = pt.BUILD_AHB_LITE ? dma_axi_wvalid_ahb : dma_axi_wvalid;
   assign dma_axi_wdata_int[63:0]              = pt.BUILD_AHB_LITE ? dma_axi_wdata_ahb[63:0] : dma_axi_wdata;
   assign dma_axi_wstrb_int[7:0]               = pt.BUILD_AHB_LITE ? dma_axi_wstrb_ahb[7:0] : dma_axi_wstrb[7:0];
   assign dma_axi_wlast_int                    = pt.BUILD_AHB_LITE ? dma_axi_wlast_ahb : dma_axi_wlast;
   assign dma_axi_bready_int                   = pt.BUILD_AHB_LITE ? dma_axi_bready_ahb : dma_axi_bready;
   assign dma_axi_arvalid_int                  = pt.BUILD_AHB_LITE ? dma_axi_arvalid_ahb : dma_axi_arvalid;
   assign dma_axi_arid_int[pt.DMA_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? dma_axi_arid_ahb[pt.DMA_BUS_TAG-1:0] : dma_axi_arid[pt.DMA_BUS_TAG-1:0];
   assign dma_axi_araddr_int[31:0]             = pt.BUILD_AHB_LITE ? dma_axi_araddr_ahb[31:0] : dma_axi_araddr[31:0];
   assign dma_axi_arsize_int[2:0]              = pt.BUILD_AHB_LITE ? dma_axi_arsize_ahb[2:0] : dma_axi_arsize[2:0];
   assign dma_axi_arprot_int[2:0]              = pt.BUILD_AHB_LITE ? dma_axi_arprot_ahb[2:0] : dma_axi_arprot[2:0];
   assign dma_axi_arlen_int[7:0]               = pt.BUILD_AHB_LITE ? dma_axi_arlen_ahb[7:0] : dma_axi_arlen[7:0];
   assign dma_axi_arburst_int[1:0]             = pt.BUILD_AHB_LITE ? dma_axi_arburst_ahb[1:0] : dma_axi_arburst[1:0];
   assign dma_axi_rready_int                   = pt.BUILD_AHB_LITE ? dma_axi_rready_ahb : dma_axi_rready;

   if  (pt.BUILD_AHB_LITE == 1) begin
   `ifdef RV_ASSERT_ON
      property ahb_trxn_aligned;
        @(posedge clk) disable iff(~rst_l) (lsu_htrans[1:0] != 2'b0)  |-> ((lsu_hsize[2:0] == 3'h0)                              |
                                                                           ((lsu_hsize[2:0] == 3'h1) & (lsu_haddr[0] == 1'b0))   |
                                                                           ((lsu_hsize[2:0] == 3'h2) & (lsu_haddr[1:0] == 2'b0)) |
                                                                           ((lsu_hsize[2:0] == 3'h3) & (lsu_haddr[2:0] == 3'b0)));
      endproperty
      assert_ahb_trxn_aligned: assert property (ahb_trxn_aligned) else
        $display("Assertion ahb_trxn_aligned failed: lsu_htrans=2'h%h, lsu_hsize=3'h%h, lsu_haddr=32'h%h",lsu_htrans[1:0], lsu_hsize[2:0], lsu_haddr[31:0]);

      property dma_trxn_aligned;
        @(posedge clk) disable iff(~rst_l) (dma_htrans[1:0] != 2'b0)  |-> ((dma_hsize[2:0] == 3'h0)                              |
                                                                           ((dma_hsize[2:0] == 3'h1) & (dma_haddr[0] == 1'b0))   |
                                                                           ((dma_hsize[2:0] == 3'h2) & (dma_haddr[1:0] == 2'b0)) |
                                                                           ((dma_hsize[2:0] == 3'h3) & (dma_haddr[2:0] == 3'b0)));
      endproperty

`endif
   end // if (pt.BUILD_AHB_LITE == 1)



      // unpack packet
      // also need retires_p==3

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin : trace_rewire

      assign trace_rv_i_insn_ip[i][63:0]     = trace_rv_trace_pkt[i].trace_rv_i_insn_ip[63:0];
      assign trace_rv_i_address_ip[i][63:0]  = trace_rv_trace_pkt[i].trace_rv_i_address_ip[63:0];
      assign trace_rv_i_valid_ip[i][1:0]     = trace_rv_trace_pkt[i].trace_rv_i_valid_ip[1:0];
      assign trace_rv_i_exception_ip[i][1:0] = trace_rv_trace_pkt[i].trace_rv_i_exception_ip[1:0];
      assign trace_rv_i_ecause_ip[i][4:0]    = trace_rv_trace_pkt[i].trace_rv_i_ecause_ip[4:0];
      assign trace_rv_i_interrupt_ip[i][1:0] = trace_rv_trace_pkt[i].trace_rv_i_interrupt_ip[1:0];
      assign trace_rv_i_tval_ip[i][31:0]     = trace_rv_trace_pkt[i].trace_rv_i_tval_ip[31:0];
   end


endmodule // eh2_swerv

