`include "../define/restor_div.svh"

module restoring_division (
    input logic     clk,reset,
    input logic     [width-1:0]dividend,divisor,
    input logic     valid_in,
    output logic    valid_out,
    output logic    [width-1:0]quotient,remainder
    
);

logic counted,counted_max,dividend_en,dividend_mux_sel,divisor_en;

restoring_division_datapath DP(
    .clk(clk),.reset(reset),
    .dividend(dividend),
    .divisor(divisor),
    .dividend_en(dividend_en),
    .divisor_en(divisor_en),
    .counted_max(counted_max),
    .dividend_mux_sel(dividend_mux_sel),
    .quotient(quotient),
    .remainder(remainder),
    .counted(counted) 
);


restoring_division_controller CT(

    .clk(clk),.reset(reset),
    .valid_in(valid_in),
    .counted(counted),
    .dividend_en(dividend_en),
    .divisor_en(divisor_en),
    .dividend_mux_sel(dividend_mux_sel),
    .counted_max(counted_max),
    .valid_out(valid_out)

    );
    
endmodule