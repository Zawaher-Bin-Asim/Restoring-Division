module restoring_division_controller (

    input logic     clk,reset,
    input logic     valid_in,counted,
    output logic    dividend_en,divisor_en,dividend_mux_sel,counted_max,valid_out

    );
    
    logic [1:0]c_state,n_state;
    parameter S0 = 2'b00 , S1 = 2'b01;

    //State Register
    always_ff @( posedge clk or negedge reset  ) begin 
        
        if (!reset)begin
            c_state <= S0;
        end
        else begin
            c_state <= n_state;
        end
    end

    //Next State always block
    always_comb begin  

        case (c_state)
           S0 : begin
            if (valid_in) n_state = S1;
            else n_state = S0;
           end 

           S1 : begin
            if (counted) n_state = S0;
            else n_state = S1;
           end 

            default: n_state = S0;

        endcase
        
    end


    //Output always block
    always_comb begin 

        case (c_state)
           
           S0 : begin
            if (valid_in) begin
                dividend_en      = 1'b1;
                dividend_mux_sel = 1'b1;
                divisor_en       = 1'b1;
                counted_max      = 1'b0;
                valid_out        = 1'b0;

           end
           else begin
                dividend_en      = 1'b0;
                dividend_mux_sel = 1'b0;
                divisor_en       = 1'b0;
                counted_max      = 1'b0;
                valid_out        = 1'b0;

 
           end
           end

           S1 : begin
            if (counted) begin
                dividend_en      = 1'b0;
                dividend_mux_sel = 1'b0;
                divisor_en       = 1'b0;
                counted_max      = 1'b1;
                valid_out        = 1'b1;

           end
           else begin
                dividend_en      = 1'b1;
                dividend_mux_sel = 1'b0;
                divisor_en       = 1'b0;
                counted_max      = 1'b0;
                valid_out        = 1'b0;
 
           end
           end


            default: begin
                dividend_en      = 1'b0;
                dividend_mux_sel = 1'b0;
                divisor_en       = 1'b0;
                counted_max      = 1'b0;
                valid_out        = 1'b0;
 
            end 

        endcase
        
    end

    
endmodule