module testbench;

    logic clk, rst, d_in, d_out;

    dut #(20) dut_instance (
        .d_out(d_out),
        .d_in(d_in),
        .clk(clk),
        .rst(rst)
    );
    
    initial
    begin
        d_in <= 0;
    end

    initial forever // Start at time 0 and repeat the begin/end forever
        begin
            clk = 0; // Set clk to 0
            #1; // Wait for 1 time unit
            clk = 1; // Set clk to 1
            #1; // Wait 1 time unit
        end
        
    initial forever // Start at time 0 and repeat the begin/end forever
        begin
            rst = 1;
            #100;
            d_in = 0;
            #50;
            d_in = 1;
            #50;
            rst = 0;
            #100;
            d_in = 0;
            #50;
            d_in = 1;
            #50;
        end

endmodule
