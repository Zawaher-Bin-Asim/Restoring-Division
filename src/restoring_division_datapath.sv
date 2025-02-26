`include "../define/restor_div.svh"

module restoring_division_datapath(
    input logic     clk,reset,
    input logic     [width-1:0]dividend,divisor,
    input logic     dividend_en,divisor_en,
    input logic     counted_max,dividend_mux_sel,
    output logic    [width-1:0]quotient,remainder,
    output logic    counted 
);

// Inputs to the Registers
logic [width:0]accum_in;

// Outputs of the Registers to the datapath
logic [width-1:0]q_out;
logic [width:0]accum_out,divisor_out;

// Accumulator and the Dividend after the left Shift
logic [width:0]Accum,Q;

// Concatination of the Accumulator and the Dividend
logic [(2*width):0]AQ,shifted_AQ;

//twos compliment of the divisor and the Accum_add
logic [width:0]twos_compliment,Accum_add; 

// Selection of muxes for the feedback in the Accuulator and the Dividend Resgister
logic mux_sel;

// Accumulator and the dividend muxes out
logic [width-1:0]dividend_feedback_mux_out;

// Dividend feed mux out
logic [width-1:0]dividend_feed;

mux #(.width(width)) Dividend_Feed_Mux(
    .a(dividend_feedback_mux_out),
    .b(dividend),
    .sel(dividend_mux_sel),
    .out(dividend_feed)
);

pipo #(.width(width)) Dividend(
    .clk(clk),.reset(reset),
    .in(dividend_feed),
    .enable(dividend_en),
    .temp_out(q_out) 
);

mux #(.width(width)) Quotient_Mux(
    .a('h0),
    .b(q_out),
    .sel(counted_max),
    .out(quotient)
);


accum_pipo #(.width(width)) Accumulator(
    .clk(clk),.reset(reset),
    .in(accum_in),
    .temp_out(accum_out) 
);

mux #(.width(width+1)) Remainder_Mux(
    .a('h0),
    .b(accum_out),
    .sel(counted_max),
    .out(remainder)
);


register #(.width(width)) Divisor(
    .clk(clk),.reset(reset),
    .in(divisor),
    .enable(divisor_en),
    .out(divisor_out) 
);

// Two's Complement of the Divisor
always_comb begin 
    if (counted_max)begin
        twos_compliment = 'h0;
        AQ              = 'h0;
        Q               = 'h0;
        shifted_AQ      = 'h0;
        Accum           = 'h0;
        Accum_add       = 'h0;
    end
    else begin

// Two's Complement of the Divisor        

        twos_compliment = (~divisor_out) + 1;


// Concatinating Accuulator and the dividend to shift them as a single unit 
        AQ = {accum_out,q_out};

// Left Shift AQ as single unit
        shifted_AQ = AQ << 1;

// Values of Accumulator and the Dividend after the left shift
        Q = shifted_AQ[width-1:0];
        Accum = shifted_AQ[(2*width):width];

// A = A - M 
        Accum_add = Accum + twos_compliment;

// Mux selection of the accumualtor feedback mux and  the dividend feed_back mux
        mux_sel = Accum_add[width];

    end
    

end


// MUX for the feedback of the Accumulator Register
mux #(.width(width+1)) Accumulator_Feedback_Mux(
    .a(Accum_add),
    .b(Accum),
    .sel(mux_sel),
    .out(accum_in)
);

// MUX for the feedback of the Dividend Register
mux #(.width(width)) Dividend_Feedback_Mux(
    .a({Q[width-1:1],(Q[0] | 1'b1)}),
    .b({Q[width-1:1],(Q[0] & 1'b0)}),
    .sel(mux_sel),
    .out(dividend_feedback_mux_out)
);



 counter #(.width(counter_width)) Counter (
    .clk(clk),
    .reset(reset),
    .start(divisor_en),
    .counted(counted)
);





    
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module pipo #(
    parameter width = 16 // Default width, can be set during instantiation
)(
    input logic     clk,reset,
    input logic     [width-1:0]in,
    input logic     enable,
    output logic    [width-1:0]temp_out 
);



always_ff @( posedge clk or negedge reset ) begin

    if (!reset)begin
        temp_out <= 'h0;
    end
    else begin
        if (enable)begin
            temp_out <= in;
        end
        else begin
            temp_out <= temp_out;
        end
    end

    
end
    
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module accum_pipo #(
    parameter width = 16 // Default width, can be set during instantiation
)(
    input logic     clk, reset,
    input logic     [width:0] in,
    output logic    [width:0]temp_out
);

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        temp_out <= 'h0;
    end else begin
            temp_out <= in; // Keep `temp_out` unchanged.
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// MUX 
module mux #(
    parameter width = 16 // Default width, can be set during instantiation
)(
    input logic     [width-1:0]a,b,
    input logic     sel,
    output logic    [width-1:0]out
);

always_comb begin 

    case (sel)
        
       1'b0 : out = a;
       1'b1 : out = b;

        default: out = 'hx;

    endcase
    
end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module register #(
    parameter width = 16 // Default width, can be set during instantiation
)(
    input logic clk,reset,
    input logic [width-1:0]in,
    input logic enable ,
    output logic [width:0]out
);

always_ff @( posedge clk or negedge reset ) begin

    if(!reset)begin
        out <= 'h0;
    end
    else begin
        if (enable)begin
            out <= in ;
        end
        else begin
            out <= out ;
        end
    end
    
end
    
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module counter #(
    parameter width = 4 // Default width, can be set during instantiation
)(
    input logic     clk,
    input logic     reset,
    input logic     start,
    output logic    counted
);

logic [width-1:0] counter;
logic max;

// Calculate the maximum value based on the width
assign max = (counter == ((2**width)-1)) ? 1'b1 : 1'b0;

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        counter <= 'h0;
        counted <= 1'b0;   
    end else begin
        if (max) begin            
            counter <= 'h0;
            counted <= 1'b1;
        end else begin
            if (start) begin
                counter <= 'h0;
                counted <= 1'b0;
            end else begin
                counter <= counter + 1;
                counted <= 1'b0;
            end
        end
    end
end

endmodule

