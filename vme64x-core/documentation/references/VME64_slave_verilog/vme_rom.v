
module vme_rom (
	addr,
	clk,
	dout,
	sinit);

input [10 : 0] addr;
input clk;
output [7 : 0] dout;
input sinit;

// synopsys translate_off

	BLKMEMSP_V5_0 #(
		11,	// c_addr_width
		"0",	// c_default_data
		2048,	// c_depth
		0,	// c_enable_rlocs
		0,	// c_has_default_data
		0,	// c_has_din
		0,	// c_has_en
		0,	// c_has_limit_data_pitch
		0,	// c_has_nd
		0,	// c_has_rdy
		0,	// c_has_rfd
		1,	// c_has_sinit
		0,	// c_has_we
		8,	// c_limit_data_pitch
		"vme_rom.mif",	// c_mem_init_file
		0,	// c_pipe_stages
		0,	// c_reg_inputs
		"0",	// c_sinit_value
		8,	// c_width
		0,	// c_write_mode
		"0",	// c_ybottom_addr
		1,	// c_yclk_is_rising
		1,	// c_yen_is_high
		"hierarchy1",	// c_yhierarchy
		0,	// c_ymake_bmm
		"4kx1",	// c_yprimitive_type
		1,	// c_ysinit_is_high
		"1024",	// c_ytop_addr
		0,	// c_yuse_single_primitive
		1)	// c_ywe_is_high
	inst (
		.ADDR(addr),
		.CLK(clk),
		.DOUT(dout),
		.SINIT(sinit),
		.DIN(),
		.EN(),
		.ND(),
		.RFD(),
		.RDY(),
		.WE());


// synopsys translate_on

endmodule

