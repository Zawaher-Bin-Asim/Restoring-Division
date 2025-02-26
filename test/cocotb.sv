module cocotb();

reg clk;
reg reset;
reg [width-1:0] dividend, divisor;
reg valid_in;
wire [width-1:0] quotient, remainder;
wire valid_out;

// Instantiation of the Restoring Division module
restoring_division DUT(
    .clk(clk),
    .reset(reset),
    .dividend(dividend),
    .divisor(divisor),
    .valid_in(valid_in),
    .valid_out(valid_out),
    .quotient(quotient),
    .remainder(remainder)
);

initial begin
        // Open a VCD file to write the simulation results
        $dumpfile("restoring_division.vcd");
        $dumpvars(0,cocotb); // Dump all variables in the array_multiplier_tb module
    end


endmodule