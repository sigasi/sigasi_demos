// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define HP 1'b1
`define LP 1'b0

module axi_mem_if_MP_Hybrid_multi_bank
#(
    parameter AXI4_ADDRESS_WIDTH = 32,
    parameter AXI4_RDATA_WIDTH   = 64,
    parameter AXI4_WDATA_WIDTH   = 64,
    parameter AXI4_ID_WIDTH      = 16,
    parameter AXI4_USER_WIDTH    = 10,
    parameter AXI_NUMBYTES       = AXI4_WDATA_WIDTH/8,

    parameter MEM_ADDR_WIDTH     = 13,
    parameter BUFF_DEPTH_SLAVE   = 4,
    parameter NB_L2_BANKS        = 4,

    parameter N_CH0              = 1,
    parameter N_CH1              = 3
)
(
    input logic                                     ACLK,
    input logic                                     ARESETn,
    input logic                                     test_en_i,


    //  ██████╗██╗  ██╗ ██████╗ 
    // ██╔════╝██║  ██║██╔═████╗
    // ██║     ███████║██║██╔██║
    // ██║     ██╔══██║████╔╝██║
    // ╚██████╗██║  ██║╚██████╔╝
    //  ╚═════╝╚═╝  ╚═╝ ╚═════╝ 
    // ---------------------------------------------------------
    // AXI TARG Port Declarations ------------------------------
    // ---------------------------------------------------------
    //AXI write address bus -------------- // USED// -----------
    input  logic [N_CH0-1:0][AXI4_ID_WIDTH-1:0]                CH0_AWID_i     ,
    input  logic [N_CH0-1:0][AXI4_ADDRESS_WIDTH-1:0]           CH0_AWADDR_i   ,
    input  logic [N_CH0-1:0][ 7:0]                             CH0_AWLEN_i    ,
    input  logic [N_CH0-1:0][ 2:0]                             CH0_AWSIZE_i   ,
    input  logic [N_CH0-1:0][ 1:0]                             CH0_AWBURST_i  ,
    input  logic [N_CH0-1:0]                                   CH0_AWLOCK_i   ,
    input  logic [N_CH0-1:0][ 3:0]                             CH0_AWCACHE_i  ,
    input  logic [N_CH0-1:0][ 2:0]                             CH0_AWPROT_i   ,
    input  logic [N_CH0-1:0][ 3:0]                             CH0_AWREGION_i ,
    input  logic [N_CH0-1:0][ AXI4_USER_WIDTH-1:0]             CH0_AWUSER_i   ,
    input  logic [N_CH0-1:0][ 3:0]                             CH0_AWQOS_i    ,
    input  logic [N_CH0-1:0]                                   CH0_AWVALID_i  ,
    output logic [N_CH0-1:0]                                   CH0_AWREADY_o  ,
    // ---------------------------------------------------------

    //AXI write data bus -------------- // USED// --------------
    input  logic [N_CH0-1:0][AXI_NUMBYTES-1:0][7:0]            CH0_WDATA_i    ,
    input  logic [N_CH0-1:0][AXI_NUMBYTES-1:0]                 CH0_WSTRB_i    ,
    input  logic [N_CH0-1:0]                                   CH0_WLAST_i    ,
    input  logic [N_CH0-1:0][AXI4_USER_WIDTH-1:0]              CH0_WUSER_i    ,
    input  logic [N_CH0-1:0]                                   CH0_WVALID_i   ,
    output logic [N_CH0-1:0]                                   CH0_WREADY_o   ,
    // ---------------------------------------------------------

    //AXI write response bus -------------- // USED// ----------
    output logic [N_CH0-1:0][AXI4_ID_WIDTH-1:0]                CH0_BID_o      ,
    output logic [N_CH0-1:0][ 1:0]                             CH0_BRESP_o    ,
    output logic [N_CH0-1:0]                                   CH0_BVALID_o   ,
    output logic [N_CH0-1:0][AXI4_USER_WIDTH-1:0]              CH0_BUSER_o    ,
    input  logic [N_CH0-1:0]                                   CH0_BREADY_i   ,
    // ---------------------------------------------------------

    //AXI read address bus -------------------------------------
    input  logic [N_CH0-1:0][AXI4_ID_WIDTH-1:0]                CH0_ARID_i     ,
    input  logic [N_CH0-1:0][AXI4_ADDRESS_WIDTH-1:0]           CH0_ARADDR_i   ,
    input  logic [N_CH0-1:0][ 7:0]                             CH0_ARLEN_i    ,
    input  logic [N_CH0-1:0][ 2:0]                             CH0_ARSIZE_i   ,
    input  logic [N_CH0-1:0][ 1:0]                             CH0_ARBURST_i  ,
    input  logic [N_CH0-1:0]                                   CH0_ARLOCK_i   ,
    input  logic [N_CH0-1:0][ 3:0]                             CH0_ARCACHE_i  ,
    input  logic [N_CH0-1:0][ 2:0]                             CH0_ARPROT_i   ,
    input  logic [N_CH0-1:0][ 3:0]                             CH0_ARREGION_i ,
    input  logic [N_CH0-1:0][ AXI4_USER_WIDTH-1:0]             CH0_ARUSER_i   ,
    input  logic [N_CH0-1:0][ 3:0]                             CH0_ARQOS_i    ,
    input  logic [N_CH0-1:0]                                   CH0_ARVALID_i  ,
    output logic [N_CH0-1:0]                                   CH0_ARREADY_o  ,
    // ---------------------------------------------------------

    //AXI read data bus ----------------------------------------
    output logic [N_CH0-1:0][AXI4_ID_WIDTH-1:0]                CH0_RID_o      ,
    output logic [N_CH0-1:0][AXI4_RDATA_WIDTH-1:0]             CH0_RDATA_o    ,
    output logic [N_CH0-1:0][ 1:0]                             CH0_RRESP_o    ,
    output logic [N_CH0-1:0]                                   CH0_RLAST_o    ,
    output logic [N_CH0-1:0][AXI4_USER_WIDTH-1:0]              CH0_RUSER_o    ,
    output logic [N_CH0-1:0]                                   CH0_RVALID_o   ,
    input  logic [N_CH0-1:0]                                   CH0_RREADY_i   ,
    // ---------------------------------------------------------

    //  ██████╗██╗  ██╗ ██╗
    // ██╔════╝██║  ██║███║
    // ██║     ███████║╚██║
    // ██║     ██╔══██║ ██║
    // ╚██████╗██║  ██║ ██║
    //  ╚═════╝╚═╝  ╚═╝ ╚═╝
    input  logic [N_CH1-1:0]                                             CH1_req_i    ,
    output logic [N_CH1-1:0]                                             CH1_gnt_o    ,
    input  logic [N_CH1-1:0]                                             CH1_wen_i    ,
    input  logic [N_CH1-1:0] [MEM_ADDR_WIDTH+$clog2(NB_L2_BANKS)-1:0]    CH1_addr_i   ,
    input  logic [N_CH1-1:0] [AXI4_WDATA_WIDTH-1:0]                      CH1_wdata_i  ,
    input  logic [N_CH1-1:0] [AXI_NUMBYTES-1:0]                          CH1_be_i     ,
    output logic [N_CH1-1:0] [AXI4_RDATA_WIDTH-1:0]                      CH1_rdata_o  ,
    output logic [N_CH1-1:0]                                             CH1_rvalid_o ,


    output logic [NB_L2_BANKS-1:0]                                       CEN,
    output logic [NB_L2_BANKS-1:0]                                       WEN,
    output logic [NB_L2_BANKS-1:0][MEM_ADDR_WIDTH-1:0]                   A  ,
    output logic [NB_L2_BANKS-1:0][AXI4_WDATA_WIDTH-1:0]                 D  ,
    output logic [NB_L2_BANKS-1:0][AXI_NUMBYTES-1:0]                     BE ,
    input  logic [NB_L2_BANKS-1:0][AXI4_RDATA_WIDTH-1:0]                 Q
);


   localparam OFFSET_BIT = ( $clog2(AXI4_WDATA_WIDTH) - 3 );


   // -----------------------------------------------------------
   // AXI TARG Port Declarations --------------------------------
   // -----------------------------------------------------------
   //AXI write address bus --------------------------------------
   logic [N_CH0-1:0][AXI4_ID_WIDTH-1:0]                         CH0_AWID     ;
   logic [N_CH0-1:0][AXI4_ADDRESS_WIDTH-1:0]                    CH0_AWADDR   ;
   logic [N_CH0-1:0][ 7:0]                                      CH0_AWLEN    ;
   logic [N_CH0-1:0][ 2:0]                                      CH0_AWSIZE   ;
   logic [N_CH0-1:0][ 1:0]                                      CH0_AWBURST  ;
   logic [N_CH0-1:0]                                            CH0_AWLOCK   ;
   logic [N_CH0-1:0][ 3:0]                                      CH0_AWCACHE  ;
   logic [N_CH0-1:0][ 2:0]                                      CH0_AWPROT   ;
   logic [N_CH0-1:0][ 3:0]                                      CH0_AWREGION ;
   logic [N_CH0-1:0][ AXI4_USER_WIDTH-1:0]                      CH0_AWUSER   ;
   logic [N_CH0-1:0][ 3:0]                                      CH0_AWQOS    ;
   logic [N_CH0-1:0]                                            CH0_AWVALID  ;
   logic [N_CH0-1:0]                                            CH0_AWREADY  ;
   // -----------------------------------------------------------

   //AXI write data bus ------------------------ ----------------
   logic [N_CH0-1:0][AXI_NUMBYTES-1:0][7:0]                     CH0_WDATA    ;
   logic [N_CH0-1:0][AXI_NUMBYTES-1:0]                          CH0_WSTRB    ;
   logic [N_CH0-1:0]                                            CH0_WLAST    ;
   logic [N_CH0-1:0][AXI4_USER_WIDTH-1:0]                       CH0_WUSER    ;
   logic [N_CH0-1:0]                                            CH0_WVALID   ;
   logic [N_CH0-1:0]                                            CH0_WREADY   ;
   // -----------------------------------------------------------

   //AXI write response bus -------------------------------------
   logic [N_CH0-1:0][AXI4_ID_WIDTH-1:0]                         CH0_BID      ;
   logic [N_CH0-1:0][ 1:0]                                      CH0_BRESP    ;
   logic [N_CH0-1:0]                                            CH0_BVALID   ;
   logic [N_CH0-1:0][AXI4_USER_WIDTH-1:0]                       CH0_BUSER    ;
   logic [N_CH0-1:0]                                            CH0_BREADY   ;
   // -----------------------------------------------------------

   //AXI read address bus ---------------------------------------
   logic [N_CH0-1:0][AXI4_ID_WIDTH-1:0]                         CH0_ARID     ;
   logic [N_CH0-1:0][AXI4_ADDRESS_WIDTH-1:0]                    CH0_ARADDR   ;
   logic [N_CH0-1:0][ 7:0]                                      CH0_ARLEN    ;
   logic [N_CH0-1:0][ 2:0]                                      CH0_ARSIZE   ;
   logic [N_CH0-1:0][ 1:0]                                      CH0_ARBURST  ;
   logic [N_CH0-1:0]                                            CH0_ARLOCK   ;
   logic [N_CH0-1:0][ 3:0]                                      CH0_ARCACHE  ;
   logic [N_CH0-1:0][ 2:0]                                      CH0_ARPROT   ;
   logic [N_CH0-1:0][ 3:0]                                      CH0_ARREGION ;
   logic [N_CH0-1:0][ AXI4_USER_WIDTH-1:0]                      CH0_ARUSER   ;
   logic [N_CH0-1:0][ 3:0]                                      CH0_ARQOS    ;
   logic [N_CH0-1:0]                                            CH0_ARVALID  ;
   logic [N_CH0-1:0]                                            CH0_ARREADY  ;
   // -----------------------------------------------------------

   //AXI read data bus ------------------------------------------
   logic [N_CH0-1:0][AXI4_ID_WIDTH-1:0]                         CH0_RID     ;
   logic [N_CH0-1:0][AXI4_RDATA_WIDTH-1:0]                      CH0_RDATA   ;
   logic [N_CH0-1:0][ 1:0]                                      CH0_RRESP   ;
   logic [N_CH0-1:0]                                            CH0_RLAST   ;
   logic [N_CH0-1:0][AXI4_USER_WIDTH-1:0]                       CH0_RUSER   ;
   logic [N_CH0-1:0]                                            CH0_RVALID  ;
   logic [N_CH0-1:0]                                            CH0_RREADY  ;
   // -----------------------------------------------------------


   logic [N_CH0-1:0] valid_R_CH0, valid_W_CH0;
   logic [N_CH0-1:0] grant_R_CH0, grant_W_CH0;

   logic [N_CH1-1:0] valid_CH1;

   logic [N_CH0-1:0]                                            CH0_W_cen    , CH0_R_cen  ;
   logic [N_CH0-1:0]                                            CH0_W_wen    , CH0_R_wen  ;
   logic [N_CH0-1:0][MEM_ADDR_WIDTH+$clog2(NB_L2_BANKS)-1:0]    CH0_W_addr   , CH0_R_addr ;
   logic [N_CH0-1:0][AXI4_WDATA_WIDTH-1:0]                      CH0_W_wdata  , CH0_R_wdata;
   logic [N_CH0-1:0][AXI_NUMBYTES-1:0]                          CH0_W_be     , CH0_R_be   ;
   logic [N_CH0-1:0][AXI4_WDATA_WIDTH-1:0]                      CH0_W_rdata  , CH0_R_rdata;

   //Internal signals : --> IF BINDING to FC_TCDM_LINT
   logic [2*N_CH0+N_CH1-1:0]                                                   req_int;
   logic [2*N_CH0+N_CH1-1:0] [MEM_ADDR_WIDTH+3+$clog2(NB_L2_BANKS)-1:0]        add_int;
   logic [2*N_CH0+N_CH1-1:0]                                                   wen_int;
   logic [2*N_CH0+N_CH1-1:0] [AXI4_WDATA_WIDTH-1:0]                            wdata_int;
   logic [2*N_CH0+N_CH1-1:0] [AXI4_WDATA_WIDTH/8-1:0]                          be_int;
   logic [2*N_CH0+N_CH1-1:0]                                                   gnt_int;
   // RESPONSE CHANNEL
   logic [2*N_CH0+N_CH1-1:0] [AXI4_WDATA_WIDTH-1:0]                            r_rdata_int;
   logic [2*N_CH0+N_CH1-1:0]                                                   r_valid_int;


   logic [NB_L2_BANKS-1:0][AXI4_WDATA_WIDTH-1:0]    mem_wdata;
   logic [NB_L2_BANKS-1:0][MEM_ADDR_WIDTH-1:0]      mem_add;
   logic [NB_L2_BANKS-1:0]                          mem_req;
   logic [NB_L2_BANKS-1:0]                          mem_wen;
   logic [NB_L2_BANKS-1:0][AXI4_WDATA_WIDTH/8-1:0]  mem_be;
   logic [NB_L2_BANKS-1:0][AXI4_WDATA_WIDTH-1:0]    mem_rdata;

   genvar i;
   generate
      for(i=0;i<N_CH0;i++)
      begin : AW_BUF
         // AXI WRITE ADDRESS CHANNEL BUFFER
         axi_aw_buffer
         #(
            .ID_WIDTH     ( AXI4_ID_WIDTH      ),
            .ADDR_WIDTH   ( AXI4_ADDRESS_WIDTH ),
            .USER_WIDTH   ( AXI4_USER_WIDTH    ),
            .BUFFER_DEPTH ( BUFF_DEPTH_SLAVE   )
         )
         Slave_aw_buffer_LP
         (
            .clk_i           ( ACLK        ),
            .rst_ni          ( ARESETn     ),
            .test_en_i       ( test_en_i   ),

            .slave_valid_i   ( CH0_AWVALID_i  [i]  ),
            .slave_addr_i    ( CH0_AWADDR_i   [i]  ),
            .slave_prot_i    ( CH0_AWPROT_i   [i]  ),
            .slave_region_i  ( CH0_AWREGION_i [i]  ),
            .slave_len_i     ( CH0_AWLEN_i    [i]  ),
            .slave_size_i    ( CH0_AWSIZE_i   [i]  ),
            .slave_burst_i   ( CH0_AWBURST_i  [i]  ),
            .slave_lock_i    ( CH0_AWLOCK_i   [i]  ),
            .slave_cache_i   ( CH0_AWCACHE_i  [i]  ),
            .slave_qos_i     ( CH0_AWQOS_i    [i]  ),
            .slave_id_i      ( CH0_AWID_i     [i]  ),
            .slave_user_i    ( CH0_AWUSER_i   [i]  ),
            .slave_ready_o   ( CH0_AWREADY_o  [i]  ),

            .master_valid_o  ( CH0_AWVALID    [i]  ),
            .master_addr_o   ( CH0_AWADDR     [i]  ),
            .master_prot_o   ( CH0_AWPROT     [i]  ),
            .master_region_o ( CH0_AWREGION   [i]  ),
            .master_len_o    ( CH0_AWLEN      [i]  ),
            .master_size_o   ( CH0_AWSIZE     [i]  ),
            .master_burst_o  ( CH0_AWBURST    [i]  ),
            .master_lock_o   ( CH0_AWLOCK     [i]  ),
            .master_cache_o  ( CH0_AWCACHE    [i]  ),
            .master_qos_o    ( CH0_AWQOS      [i]  ),
            .master_id_o     ( CH0_AWID       [i]  ),
            .master_user_o   ( CH0_AWUSER     [i]  ),
            .master_ready_i  ( CH0_AWREADY    [i]  )
         );
      end

      for(i=0;i<N_CH0;i++)
      begin : AR_BUF
         // AXI WRITE ADDRESS CHANNEL BUFFER
         axi_ar_buffer
         #(
             .ID_WIDTH     ( AXI4_ID_WIDTH      ),
             .ADDR_WIDTH   ( AXI4_ADDRESS_WIDTH ),
             .USER_WIDTH   ( AXI4_USER_WIDTH    ),
             .BUFFER_DEPTH ( BUFF_DEPTH_SLAVE   )
         )
         Slave_ar_buffer_LP
         (
            .clk_i           ( ACLK          ),
            .rst_ni          ( ARESETn       ),
            .test_en_i       ( test_en_i     ),

            .slave_valid_i   ( CH0_ARVALID_i  [i] ),
            .slave_addr_i    ( CH0_ARADDR_i   [i] ),
            .slave_prot_i    ( CH0_ARPROT_i   [i] ),
            .slave_region_i  ( CH0_ARREGION_i [i] ),
            .slave_len_i     ( CH0_ARLEN_i    [i] ),
            .slave_size_i    ( CH0_ARSIZE_i   [i] ),
            .slave_burst_i   ( CH0_ARBURST_i  [i] ),
            .slave_lock_i    ( CH0_ARLOCK_i   [i] ),
            .slave_cache_i   ( CH0_ARCACHE_i  [i] ),
            .slave_qos_i     ( CH0_ARQOS_i    [i] ),
            .slave_id_i      ( CH0_ARID_i     [i] ),
            .slave_user_i    ( CH0_ARUSER_i   [i] ),
            .slave_ready_o   ( CH0_ARREADY_o  [i] ),

            .master_valid_o  ( CH0_ARVALID    [i] ),
            .master_addr_o   ( CH0_ARADDR     [i] ),
            .master_prot_o   ( CH0_ARPROT     [i] ),
            .master_region_o ( CH0_ARREGION   [i] ),
            .master_len_o    ( CH0_ARLEN      [i] ),
            .master_size_o   ( CH0_ARSIZE     [i] ),
            .master_burst_o  ( CH0_ARBURST    [i] ),
            .master_lock_o   ( CH0_ARLOCK     [i] ),
            .master_cache_o  ( CH0_ARCACHE    [i] ),
            .master_qos_o    ( CH0_ARQOS      [i] ),
            .master_id_o     ( CH0_ARID       [i] ),
            .master_user_o   ( CH0_ARUSER     [i] ),
            .master_ready_i  ( CH0_ARREADY    [i] )
         );
      end

      for(i=0;i<N_CH0;i++)
      begin : W_BUF
         axi_w_buffer
         #(
             .DATA_WIDTH(AXI4_WDATA_WIDTH),
             .USER_WIDTH(AXI4_USER_WIDTH),
             .BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
         )
         Slave_w_buffer_LP
         (
              .clk_i          ( ACLK        ),
              .rst_ni         ( ARESETn     ),
              .test_en_i      ( test_en_i   ),

              .slave_valid_i  ( CH0_WVALID_i [i] ),
              .slave_data_i   ( CH0_WDATA_i  [i] ),
              .slave_strb_i   ( CH0_WSTRB_i  [i] ),
              .slave_user_i   ( CH0_WUSER_i  [i] ),
              .slave_last_i   ( CH0_WLAST_i  [i] ),
              .slave_ready_o  ( CH0_WREADY_o [i] ),

              .master_valid_o ( CH0_WVALID   [i] ),
              .master_data_o  ( CH0_WDATA    [i] ),
              .master_strb_o  ( CH0_WSTRB    [i] ),
              .master_user_o  ( CH0_WUSER    [i] ),
              .master_last_o  ( CH0_WLAST    [i] ),
              .master_ready_i ( CH0_WREADY   [i] )
          );
      end

      for(i=0;i<N_CH0;i++)
      begin : R_BUF
         axi_r_buffer
         #(
              .ID_WIDTH(AXI4_ID_WIDTH),
              .DATA_WIDTH(AXI4_RDATA_WIDTH),
              .USER_WIDTH(AXI4_USER_WIDTH),
              .BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
         )
         Slave_r_buffer_LP
         (
              .clk_i          ( ACLK          ),
              .rst_ni         ( ARESETn       ),
              .test_en_i      ( test_en_i     ),

              .slave_valid_i  ( CH0_RVALID  [i]   ),
              .slave_data_i   ( CH0_RDATA   [i]   ),
              .slave_resp_i   ( CH0_RRESP   [i]   ),
              .slave_user_i   ( CH0_RUSER   [i]   ),
              .slave_id_i     ( CH0_RID     [i]   ),
              .slave_last_i   ( CH0_RLAST   [i]   ),
              .slave_ready_o  ( CH0_RREADY  [i]   ),

              .master_valid_o ( CH0_RVALID_o [i]  ),
              .master_data_o  ( CH0_RDATA_o  [i]  ),
              .master_resp_o  ( CH0_RRESP_o  [i]  ),
              .master_user_o  ( CH0_RUSER_o  [i]  ),
              .master_id_o    ( CH0_RID_o    [i]  ),
              .master_last_o  ( CH0_RLAST_o  [i]  ),
              .master_ready_i ( CH0_RREADY_i [i]  )
         );
      end

      for(i=0;i<N_CH0;i++)
      begin : B_BUF 
         axi_b_buffer
         #(
              .ID_WIDTH(AXI4_ID_WIDTH),
              .USER_WIDTH(AXI4_USER_WIDTH),
              .BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
         )
         Slave_b_buffer_LP
         (
              .clk_i          ( ACLK         ),
              .rst_ni         ( ARESETn      ),
              .test_en_i      ( test_en_i    ),

              .slave_valid_i  ( CH0_BVALID   [i] ),
              .slave_resp_i   ( CH0_BRESP    [i] ),
              .slave_id_i     ( CH0_BID      [i] ),
              .slave_user_i   ( CH0_BUSER    [i] ),
              .slave_ready_o  ( CH0_BREADY   [i] ),

              .master_valid_o ( CH0_BVALID_o [i] ),
              .master_resp_o  ( CH0_BRESP_o  [i] ),
              .master_id_o    ( CH0_BID_o    [i] ),
              .master_user_o  ( CH0_BUSER_o  [i] ),
              .master_ready_i ( CH0_BREADY_i [i] )
         );
      end

      for(i=0;i<N_CH0;i++)
      begin : WO_CTRL
         // Low Priority Write FSM
         axi_write_only_ctrl
         #(
             .AXI4_ADDRESS_WIDTH ( AXI4_ADDRESS_WIDTH  ),
             .AXI4_RDATA_WIDTH   ( AXI4_RDATA_WIDTH    ),
             .AXI4_WDATA_WIDTH   ( AXI4_WDATA_WIDTH    ),
             .AXI4_ID_WIDTH      ( AXI4_ID_WIDTH       ),
             .AXI4_USER_WIDTH    ( AXI4_USER_WIDTH     ),
             .AXI_NUMBYTES       ( AXI_NUMBYTES        ),
             .MEM_ADDR_WIDTH     ( MEM_ADDR_WIDTH+$clog2(NB_L2_BANKS)     )
         )
         W_CTRL
         (
             .clk            (  ACLK         ),
             .rst_n          (  ARESETn      ),

             .AWID_i         (  CH0_AWID     [i] ),
             .AWADDR_i       (  CH0_AWADDR   [i] ),
             .AWLEN_i        (  CH0_AWLEN    [i] ),
             .AWSIZE_i       (  CH0_AWSIZE   [i] ),
             .AWBURST_i      (  CH0_AWBURST  [i] ),
             .AWLOCK_i       (  CH0_AWLOCK   [i] ),
             .AWCACHE_i      (  CH0_AWCACHE  [i] ),
             .AWPROT_i       (  CH0_AWPROT   [i] ),
             .AWREGION_i     (  CH0_AWREGION [i] ),
             .AWUSER_i       (  CH0_AWUSER   [i] ),
             .AWQOS_i        (  CH0_AWQOS    [i] ),
             .AWVALID_i      (  CH0_AWVALID  [i] ),
             .AWREADY_o      (  CH0_AWREADY  [i] ),

             //AXI write data buLP_s -------------- // USED// -------------
             .WDATA_i        (  CH0_WDATA    [i] ),
             .WSTRB_i        (  CH0_WSTRB    [i] ),
             .WLAST_i        (  CH0_WLAST    [i] ),
             .WUSER_i        (  CH0_WUSER    [i] ),
             .WVALID_i       (  CH0_WVALID   [i] ),
             .WREADY_o       (  CH0_WREADY   [i] ),

             //AXI write responsCH0_e bus ------------- // USED// ----------
             .BID_o          (  CH0_BID      [i] ),
             .BRESP_o        (  CH0_BRESP    [i] ),
             .BVALID_o       (  CH0_BVALID   [i] ),
             .BUSER_o        (  CH0_BUSER    [i] ),
             .BREADY_i       (  CH0_BREADY   [i] ),

             .MEM_CEN_o      (  CH0_W_cen    [i] ),
             .MEM_WEN_o      (  CH0_W_wen    [i] ),
             .MEM_A_o        (  CH0_W_addr   [i] ),
             .MEM_D_o        (  CH0_W_wdata  [i] ),
             .MEM_BE_o       (  CH0_W_be     [i] ),
             .MEM_Q_i        (  '0               ),

             .grant_i        (  grant_W_CH0   [i] ),
             .valid_o        (  valid_W_CH0   [i] )
         );
      end


      for(i=0;i<N_CH0;i++)
      begin : RO_CTRL
         axi_read_only_ctrl
         #(
             .AXI4_ADDRESS_WIDTH ( AXI4_ADDRESS_WIDTH  ),
             .AXI4_RDATA_WIDTH   ( AXI4_RDATA_WIDTH    ),
             .AXI4_WDATA_WIDTH   ( AXI4_WDATA_WIDTH    ),
             .AXI4_ID_WIDTH      ( AXI4_ID_WIDTH       ),
             .AXI4_USER_WIDTH    ( AXI4_USER_WIDTH     ),
             .AXI_NUMBYTES       ( AXI_NUMBYTES        ),
             .MEM_ADDR_WIDTH     ( MEM_ADDR_WIDTH+$clog2(NB_L2_BANKS)      )
         )
         R_CTRL_LP
         (
             .clk            (  ACLK       ),
             .rst_n          (  ARESETn     ),

             .ARID_i         (  CH0_ARID     [i] ),
             .ARADDR_i       (  CH0_ARADDR   [i] ),
             .ARLEN_i        (  CH0_ARLEN    [i] ),
             .ARSIZE_i       (  CH0_ARSIZE   [i] ),
             .ARBURST_i      (  CH0_ARBURST  [i] ),
             .ARLOCK_i       (  CH0_ARLOCK   [i] ),
             .ARCACHE_i      (  CH0_ARCACHE  [i] ),
             .ARPROT_i       (  CH0_ARPROT   [i] ),
             .ARREGION_i     (  CH0_ARREGION [i] ),
             .ARUSER_i       (  CH0_ARUSER   [i] ),
             .ARQOS_i        (  CH0_ARQOS    [i] ),
             .ARVALID_i      (  CH0_ARVALID  [i] ),
             .ARREADY_o      (  CH0_ARREADY  [i] ),

             .RID_o          (  CH0_RID      [i] ),
             .RDATA_o        (  CH0_RDATA    [i] ),
             .RRESP_o        (  CH0_RRESP    [i] ),
             .RLAST_o        (  CH0_RLAST    [i] ),
             .RUSER_o        (  CH0_RUSER    [i] ),
             .RVALID_o       (  CH0_RVALID   [i] ),
             .RREADY_i       (  CH0_RREADY   [i] ),

             .MEM_CEN_o      (  CH0_R_cen    [i] ),
             .MEM_WEN_o      (  CH0_R_wen    [i] ),
             .MEM_A_o        (  CH0_R_addr   [i] ),
             .MEM_D_o        (                   ),
             .MEM_BE_o       (                   ),
             .MEM_Q_i        (  CH0_R_rdata  [i] ),

             .grant_i        (  grant_R_CH0  [i] ),
             .valid_o        (  valid_R_CH0  [i] )
         );
      end



   // Interface bindings to internal signals
   for(i=0;i<N_CH0;i++)
   begin : BINDING_AXI_IF
      assign req_int[2*i]     = valid_W_CH0[i];
      assign req_int[2*i+1]   = valid_R_CH0[i];
      
      assign grant_W_CH0[i]   = gnt_int[2*i];
      assign grant_R_CH0[i]   = gnt_int[2*i+1];

      assign add_int[2*i]     = {CH0_W_addr[i],3'b000};
      assign add_int[2*i+1]   = {CH0_R_addr[i],3'b000};

      assign wen_int[2*i]     = 1'b0;
      assign wen_int[2*i+1]   = 1'b1;

      assign wdata_int[2*i]   = CH0_W_wdata[i];
      assign wdata_int[2*i+1] = '0;

      assign be_int[2*i]      = CH0_W_be[i];
      assign be_int[2*i+1]    = '0;

      assign CH0_W_rdata[i]   = r_rdata_int[2*i];
      assign CH0_R_rdata[i]   = r_rdata_int[2*i+1];
   end

   for(i=0;i<N_CH1;i++)
   begin : BINDING_TCDM_IF
      assign req_int[2*N_CH0+i]    =  CH1_req_i[i];
      assign CH1_gnt_o[i]          =  gnt_int[2*N_CH0+i];
      assign add_int[2*N_CH0+i]    = {CH1_addr_i[i],3'b000};
      assign wen_int[2*N_CH0+i]    =  CH1_wen_i[i];
      assign wdata_int[2*N_CH0+i]  =  CH1_wdata_i[i];
      assign be_int[2*N_CH0+i]     =  CH1_be_i[i];

      assign CH1_rdata_o[i]        = r_rdata_int[2*N_CH0+i];
      assign CH1_rvalid_o[i]       = r_valid_int[2*N_CH0+i];
   end

   //assign {r_valid_HP,   r_valid_W_LP,  r_valid_R_LP }  = r_valid_int;
   //assign {HP_Q_o, LP_R_rdata, LP_W_rdata} = r_rdata_int;

 endgenerate



   //               [1]           [0]
   // CH0 --> { Read signals, Write signals} --> 
   // CH1 --> {  Icache     , UDMA         } --> 
   XBAR_TCDM_FC
   #(
      .N_CH0          ( 2*N_CH0                              ),  //-->  AXI PORTS (sx beacuse we separate W and R channels)
      .N_CH1          ( N_CH1                                ),  //--> no channel connected
      .N_SLAVE        ( NB_L2_BANKS                          ),
      .ADDR_WIDTH     ( MEM_ADDR_WIDTH+3+$clog2(NB_L2_BANKS) ), // MEM_ADDR+OFFSET+INTERLEAVING ROUTING bits
      .DATA_WIDTH     ( AXI4_WDATA_WIDTH                     ),
      .ADDR_MEM_WIDTH ( MEM_ADDR_WIDTH                       ),
      .CH0_CH1_POLICY ( "RR"                                 )      
   )
   L2_MB_INTERCO
   (
      .data_req_i      ( req_int           ),   
      .data_add_i      ( add_int           ),     
      .data_wen_i      ( wen_int           ),   
      .data_wdata_i    ( wdata_int         ),   
      .data_be_i       ( be_int            ),     
      .data_gnt_o      ( gnt_int           ),   
      .data_r_valid_o  ( r_valid_int       ),
      .data_r_rdata_o  ( r_rdata_int       ),   
      // ---------------- MM_SIDE (Bank 0)------------------------- 
      .data_req_o      ( mem_req           ),  
      .data_add_o      ( mem_add           ), 
      .data_wen_o      ( mem_wen           ), 
      .data_wdata_o    ( mem_wdata         ), 
      .data_be_o       ( mem_be            ), 
      .data_r_rdata_i  ( mem_rdata         ), 
      .clk             ( ACLK              ),
      .rst_n           ( ARESETn           )
   );

   assign CEN = ~mem_req;
   assign WEN =  mem_wen;
   assign A   =  mem_add;
   assign D   =  mem_wdata;
   assign BE  =  mem_be;
   assign mem_rdata = Q;

endmodule // axi_mem_if_DP

