module eh2_btb_tag_hash #(
`include "eh2_param.vh"
 ) (
                       input logic [pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE+pt.BTB_BTAG_SIZE+pt.BTB_BTAG_SIZE:pt.BTB_ADDR_HI+1] pc,
                       output logic [pt.BTB_BTAG_SIZE-1:0] hash
                       );

    assign hash = {(pc[pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE+pt.BTB_BTAG_SIZE+pt.BTB_BTAG_SIZE:pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE+pt.BTB_BTAG_SIZE+1] ^
                   pc[pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE+pt.BTB_BTAG_SIZE:pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE+1] ^
                   pc[pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE:pt.BTB_ADDR_HI+1])};
endmodule

module eh2_btb_tag_hash_fold  #(
`include "eh2_param.vh"
 )(
                       input logic [pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE+pt.BTB_BTAG_SIZE:pt.BTB_ADDR_HI+1] pc,
                       output logic [pt.BTB_BTAG_SIZE-1:0] hash
                       );

    assign hash = {(
                   pc[pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE+pt.BTB_BTAG_SIZE:pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE+1] ^
                   pc[pt.BTB_ADDR_HI+pt.BTB_BTAG_SIZE:pt.BTB_ADDR_HI+1])};

endmodule

module eh2_btb_addr_hash  #(
`include "eh2_param.vh"
 )(
                        input logic [pt.BTB_INDEX3_HI:pt.BTB_INDEX1_LO] pc,
                        output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] hash
                        );


if(pt.BTB_FOLD2_INDEX_HASH) begin : fold2
   assign hash[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] = pc[pt.BTB_INDEX1_HI:pt.BTB_INDEX1_LO] ^
                                                pc[pt.BTB_INDEX3_HI:pt.BTB_INDEX3_LO];
end
   else begin

      // overload bit pc[3] onto last bit of hash for sram case
      if(pt.BTB_USE_SRAM) begin
        assign hash[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO+1] = pc[pt.BTB_INDEX1_HI:pt.BTB_INDEX1_LO+1] ^
                                                       pc[pt.BTB_INDEX2_HI:pt.BTB_INDEX2_LO] ^
                                                       pc[pt.BTB_INDEX3_HI:pt.BTB_INDEX3_LO];
         assign hash[3] = pc[3];
      end

      else

        assign hash[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] = pc[pt.BTB_INDEX1_HI:pt.BTB_INDEX1_LO] ^
                                                     pc[pt.BTB_INDEX2_HI:pt.BTB_INDEX2_LO] ^
                                                     pc[pt.BTB_INDEX3_HI:pt.BTB_INDEX3_LO];
end

endmodule


module eh2_btb_ghr_hash  #(
`include "eh2_param.vh"
 )(
                       input logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] hashin,
                       input logic [pt.BHT_GHR_SIZE-1:0] ghr,
                       output logic [pt.BHT_ADDR_HI:pt.BHT_ADDR_LO] hash
                       );

   if(pt.BHT_GHR_HASH_1) begin : ghrhash_cfg1
     assign hash[pt.BHT_ADDR_HI:pt.BHT_ADDR_LO] = { ghr[pt.BHT_GHR_SIZE-1:pt.BTB_INDEX1_HI-2], hashin[pt.BTB_INDEX1_HI:3]^ghr[pt.BTB_INDEX1_HI-3:0]};
//     assign hash[pt.BHT_ADDR_HI:pt.BHT_ADDR_LO] = {ghr[8:7], hashin[pt.BTB_INDEX1_HI:3]^ghr[6:0]};
   end
   else begin : ghrhash_cfg2
// this makes more sense but is lower perf on dhrystone
//     assign hash[pt.BHT_ADDR_HI:pt.BHT_ADDR_LO] = { hashin[pt.BHT_GHR_SIZE+2:3]^ghr[pt.BHT_GHR_SIZE-1:0]};
     assign hash[pt.BHT_ADDR_HI:pt.BHT_ADDR_LO] = { hashin[pt.BHT_GHR_SIZE+2:5]^ghr[pt.BHT_GHR_SIZE-1:2], ghr[1:0]};
   end


endmodule

