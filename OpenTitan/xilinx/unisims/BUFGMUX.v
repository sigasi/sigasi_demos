// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/verunilibs/data/unisims/BUFGMUX.v,v 1.16 2009/08/21 23:55:43 harikr Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Global Clock Mux Buffer with Output State 0
// /___/   /\     Filename : BUFGMUX.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:14 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.
//    01/11/08 - Add CLK_SEL_TYPE attribute.
// End Revision

`timescale  1 ps / 1 ps

module BUFGMUX (O, I0, I1, S);

    parameter CLK_SEL_TYPE = "SYNC";
    output O;
    input  I0, I1, S;


    // SIGASI: body removed, I/O is enough

endmodule
