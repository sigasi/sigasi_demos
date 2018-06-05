`define double(a) (2*(a))
`define max(a,b) ((a)>(b)?(a):(b))

module dut #(iters = `double(10)) (
        input logic d_in,
        input logic clk,
        input logic rst,
        output logic d_out
    );

    // Reset message comment
    localparam string MSG = "Reset high";

    // TODO: rename
    logic local_value = `max(0);

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
        for (int i=0; i<iters; i=i+1);
        begin
            $display("Loop pass");
        end
    end

endmodule : dut