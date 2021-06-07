///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2010 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 13.i (O.58)
//  \   \         Description : Xilinx Timing Simulation Library Component
//  /   /                  Phase Lock Loop Clock
// /___/   /\     Filename : PLLE2_ADV.v
// \   \  /  \    Timestamp : 
//  \___\/\___\
//
// Revision:
//    12/09/09 - Initial version.
//    03/24/10 - Change CLKFBOUT_MULT defaut to 5, CLKIN_PERIOD range.
//    04/28/10 - Fix CLKIN1_PERIOD check (CR557962)
//    06/03/10 - Change DIVCLK_DIVIDE range to 56 according yaml.
//    07/12/10 - Add RST to LOCKED iopath (CR567807)
//    07/28/10 - Change ref parameter values (CR569262)
//    08/06/10 - Remove CASCADE from COMPENSATION (CR571190)
//    08/17/10 - Add Decay output clocks when input clock stopped (CR555324)
//    09/03/10 - Change to bus timing.
//    09/26/10 - Add RST to LOCKED timing path (CR567807)
//    02/22/11 - reduce clkin period check resolution to 0.001 (CR594003)
//   03/03/11 - Keep 100ps dealy only on RST to LOCKED for unisim (CR595354)
//    05/05/11 - Update cp_res table (CR609232)
//    12/13/11 - Added `celldefine and `endcelldefine (CR 524859).
//    10/26/11 - Add DRC check for samples CLKIN period with parameter setting (CR631150)
//    02/22/12 - Modify DRC (638094).
//    03/07/12 - added vcoflag (CR 638088, CR 636493)
//   04/19/12 - 654951 - rounding issue with clk_out_para_cal
//   05/03/12 - jittery clock (CR 652401)
//   05/03/12 - incorrect period (CR 654951)
//   06/11/12 - update cp and res settings (CR 664278)
//   06/20/12 - modify reset drc (CR 643540)
//   04/04/13 - change error to warning (CR 708090)
//   04/09/13 - Added DRP monitor (CR 695630).
// End Revision


`timescale  1 ps / 1 ps

`celldefine

module PLLE2_ADV #(
  `ifdef XIL_TIMING //Simprim 
  parameter real VCOCLK_FREQ_MAX = 2133.000,
  parameter real VCOCLK_FREQ_MIN = 800.000,
  parameter real CLKIN_FREQ_MAX = 1066.000,
  parameter real CLKIN_FREQ_MIN = 19.000,
  parameter real CLKPFD_FREQ_MAX = 550.0,
  parameter real CLKPFD_FREQ_MIN = 19.0,
  parameter LOC = "UNPLACED",  
  `endif
  parameter BANDWIDTH = "OPTIMIZED",
  parameter integer CLKFBOUT_MULT = 5,
  parameter real CLKFBOUT_PHASE = 0.000,
  parameter real CLKIN1_PERIOD = 0.000,
  parameter real CLKIN2_PERIOD = 0.000,
  parameter integer CLKOUT0_DIVIDE = 1,
  parameter real CLKOUT0_DUTY_CYCLE = 0.500,
  parameter real CLKOUT0_PHASE = 0.000,
  parameter integer CLKOUT1_DIVIDE = 1,
  parameter real CLKOUT1_DUTY_CYCLE = 0.500,
  parameter real CLKOUT1_PHASE = 0.000,
  parameter integer CLKOUT2_DIVIDE = 1,
  parameter real CLKOUT2_DUTY_CYCLE = 0.500,
  parameter real CLKOUT2_PHASE = 0.000,
  parameter integer CLKOUT3_DIVIDE = 1,
  parameter real CLKOUT3_DUTY_CYCLE = 0.500,
  parameter real CLKOUT3_PHASE = 0.000,
  parameter integer CLKOUT4_DIVIDE = 1,
  parameter real CLKOUT4_DUTY_CYCLE = 0.500,
  parameter real CLKOUT4_PHASE = 0.000,
  parameter integer CLKOUT5_DIVIDE = 1,
  parameter real CLKOUT5_DUTY_CYCLE = 0.500,
  parameter real CLKOUT5_PHASE = 0.000,
  parameter COMPENSATION = "ZHOLD",
  parameter integer DIVCLK_DIVIDE = 1,
  parameter [0:0] IS_CLKINSEL_INVERTED = 1'b0,
  parameter [0:0] IS_PWRDWN_INVERTED = 1'b0,
  parameter [0:0] IS_RST_INVERTED = 1'b0,
  parameter real REF_JITTER1 = 0.010,
  parameter real REF_JITTER2 = 0.010,
  parameter STARTUP_WAIT = "FALSE"
)(
  output CLKFBOUT,
  output CLKOUT0,
  output CLKOUT1,
  output CLKOUT2,
  output CLKOUT3,
  output CLKOUT4,
  output CLKOUT5,
  output [15:0] DO,
  output DRDY,
  output LOCKED,

  input CLKFBIN,
  input CLKIN1,
  input CLKIN2,
  input CLKINSEL,
  input [6:0] DADDR,
  input DCLK,
  input DEN,
  input [15:0] DI,
  input DWE,
  input PWRDWN,
  input RST
);

    // SIGASI: body removed, I/O is enough

endmodule

`endcelldefine
