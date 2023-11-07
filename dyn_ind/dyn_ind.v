`timescale 1ns / 1ps

module dyn_ind
#(parameter WIDTH = 8) 
(
input                   clk,
input       [3:0]       to_dec0,
input       [3:0]       to_dec1,
input       [3:0]       to_dec2,
input       [3:0]       to_dec3,
output  reg [6:0]       to_hex,
output  reg [WIDTH-1:0] to_hex_ans
);

reg     [2:0] state;
reg     [3:0] to_decoder;
wire    [6:0] hex_dig;

localparam DIG1 = 3'd0;
localparam DIG2 = 3'd1;
localparam DIG3 = 3'd2;
localparam DIG4 = 3'd3;

initial begin
    state = DIG1;
    to_decoder = 4'b0;
end

hex_decoder inst1(
to_decoder,
hex_dig
);

always@(posedge clk) begin
    case(state)
        DIG1:
            begin
               to_decoder = to_dec0;
               to_hex_ans = 8'b11111110;
               to_hex = hex_dig;
               state = DIG2;
            end
            
        DIG2:
            begin
               to_decoder = to_dec1;
               to_hex_ans = 8'b11111101;
               to_hex = hex_dig ;
               state = DIG3;
            end
            
        DIG3:
            begin
               to_decoder = to_dec2;
               to_hex_ans = 8'b11111011;
               to_hex = hex_dig ;
               state = DIG4;
            end
            
        DIG4:
            begin
                to_decoder = to_dec3;
               to_hex_ans = 8'b11110111;
               to_hex = hex_dig ;
               state = DIG1;
            end
     endcase
end

endmodule
