`include "../define/restor_div.svh"

module restoring_division_tb(

`ifdef Verilator 
    input logic clk
`endif
);

`ifndef Verilator
    reg clk;
`endif

reg reset;
reg [width-1:0] dividend, divisor;
reg valid_in;
wire [width-1:0] quotient, remainder;
wire valid_out;
reg [width-1:0] expected_quotient, expected_remainder;

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

`ifndef Verilator
    // Clock Generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
`endif


initial begin
    // Applying Reset
    reset_sequence();

    // Run 10 random test cases
    repeat(10) begin
        fork
            driver();
    
            monitor();
         
        join
    end

    $display("Finished all test cases.");
    $finish; // Stop the simulation after 10 tests
end

task reset_sequence();
    begin
        $display("Applying reset...");
        reset <= 1;
        @(posedge clk);
        reset <= 0;
        @(posedge clk);
        reset <= 1;
    end
endtask

task driver();
    begin
        apply_inputs();
        @(posedge clk);
        valid_in <= 1'b1;
        @(posedge clk);
        valid_in <= 1'b0;
    end
endtask

task monitor();
    begin
        // Wait for the valid_out signal to be asserted
        @(posedge valid_out);
        $display("Valid_out asserted!");

        // Calculate the expected quotient and remainder
        expected_quotient = dividend / divisor;
        expected_remainder = dividend % divisor;

        // Compare the expected and actual outputs
        if (quotient !== expected_quotient || remainder !== expected_remainder) begin
            $display("ERROR: Test failed!");
            $display("  Inputs: dividend = %d, divisor = %d", dividend, divisor);
            $display("  Expected: quotient = %d, remainder = %d", expected_quotient, expected_remainder);
            $display("  Actual: quotient = %d, remainder = %d", quotient, remainder);
            $finish;
        end
        else begin
            $display("SUCCESS: Test passed!");
            $display("  Inputs: dividend = %d, divisor = %d", dividend, divisor);
            $display("  Output: quotient = %d, remainder = %d", quotient, remainder);
        end        

        @(negedge valid_out);
    end
endtask

task apply_inputs();
    begin
        dividend <= $random;
        divisor <= $random;
    end
endtask

endmodule
