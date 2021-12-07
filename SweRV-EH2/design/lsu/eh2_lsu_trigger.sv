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
//
// Owner:
// Function: LSU Trigger logic
// Comments:
//
//********************************************************************************
module eh2_lsu_trigger
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)(
   input logic                    scan_mode,
   input logic                    rst_l,
   input logic                    clk_override,
   input logic                    clk,
   input eh2_trigger_pkt_t [pt.NUM_THREADS-1:0][3:0] trigger_pkt_any, // Trigger info from the decode
   input eh2_lsu_pkt_t           lsu_pkt_dc3,            // lsu packet
   input eh2_lsu_pkt_t           lsu_pkt_dc4,            // lsu packet
   input logic [31:0]             lsu_addr_dc4,           // address
   input logic [31:0]             store_data_dc3,         // store data
   input logic [31:0]             amo_data_dc3,

   output logic [3:0]             lsu_trigger_match_dc4   // match result
);

   eh2_trigger_pkt_t  [3:0]        trigger_tid_pkt_any;
   logic              trigger_enable;             // Trigger enable. Used to bus quiescing
   logic [31:0]       ldst_addr_trigger_dc4;
   logic [31:0]       trigger_store_data_dc3;
   logic [31:0]       store_data_trigger_dc3;
   logic [31:0]       store_data_trigger_dc4;
   logic [3:0][31:0]  lsu_match_data;
   logic [3:0]        lsu_trigger_data_match;

   // Generate the trigger enable
   always_comb begin
      trigger_enable = 1'b0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         for (int j=0; j<4; j++) begin
            trigger_enable |= trigger_pkt_any[i][j].m;
         end
      end
   end

   assign trigger_store_data_dc3[31:0] = (lsu_pkt_dc3.atomic ? amo_data_dc3[31:0] : store_data_dc3[31:0]) & {32{trigger_enable}};
   assign store_data_trigger_dc3[31:0] = { ({16{lsu_pkt_dc3.word | lsu_pkt_dc3.dword}} & trigger_store_data_dc3[31:16]), ({8{(lsu_pkt_dc3.half | lsu_pkt_dc3.word | lsu_pkt_dc3.dword)}} & trigger_store_data_dc3[15:8]), trigger_store_data_dc3[7:0]};

   assign ldst_addr_trigger_dc4[31:0] = lsu_addr_dc4[31:0] & {32{trigger_enable}};

   rvdffe #(32) store_data_trigger_ff   (.*, .din(store_data_trigger_dc3[31:0]),  .dout(store_data_trigger_dc4[31:0]), .en((lsu_pkt_dc3.valid & lsu_pkt_dc3.store & trigger_enable) | clk_override));

   for (genvar i=0; i<4; i++) begin
      assign trigger_tid_pkt_any[i]    = trigger_pkt_any[lsu_pkt_dc4.tid][i];
      assign lsu_match_data[i][31:0]   = ({32{~trigger_tid_pkt_any[i].select                               }} & ldst_addr_trigger_dc4[31:0]) |
                                         ({32{ trigger_tid_pkt_any[i].select & trigger_tid_pkt_any[i].store}} & store_data_trigger_dc4[31:0]);

      rvmaskandmatch trigger_match     (.mask(trigger_tid_pkt_any[i].tdata2[31:0]), .data(lsu_match_data[i][31:0]), .masken(trigger_tid_pkt_any[i].match), .match(lsu_trigger_data_match[i]));

      assign lsu_trigger_match_dc4[i]  = lsu_pkt_dc4.valid & ~lsu_pkt_dc4.dma &
                                         ((trigger_tid_pkt_any[i].store & lsu_pkt_dc4.store) | (trigger_tid_pkt_any[i].load & lsu_pkt_dc4.load & ~lsu_pkt_dc4.store & ~trigger_tid_pkt_any[i].select)) &
                                         lsu_trigger_data_match[i];
   end

endmodule // lsu_trigger
