`define double(a) (2*(a))
`define max(a,b) ((a)>(b)?(a):(b))

module dut (d_out, d_in, clk, rst);
	output logic d_out;
	input logic d_in, clk, rst;
	parameter iters = `double(10);

	// Reset message comment
	localparam string MSG = "Reset high";

	logic local_value = `max(0,1);
	int i; //TODO: rename

	always @(posedge clk) begin
		if (rst)
			local_value <= 0;
		else begin
			local_value <= d_in;
		end
		d_out <= local_value;
	end
	
	always @(posedge rst) begin
		$display(MSG);
		for (int i=0; i<iters; i=i+1);           //warning here
			begin
				$display("Loop pass %d", i);
		end
	end
endmodule : dut



