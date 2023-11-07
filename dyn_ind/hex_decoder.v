`timescale 1ns / 1ps

module hex_decoder(
input       [3:0]   to_dec,
output  reg [6:0]   to_hex
);

always@* begin
    case(to_dec)
        4'b0000: to_hex = 7'b1000000; 
        4'b0001: to_hex = 7'b1111001;   
        4'b0010: to_hex = 7'b0100100; 
        4'b0011: to_hex = 7'b0110000; 
        4'b0100: to_hex = 7'b0011001;
        4'b0101: to_hex = 7'b0010010;
        4'b0110: to_hex = 7'b0000010;
        4'b0111: to_hex = 7'b1111000;
        4'b1000: to_hex = 7'b0000000;
        4'b1001: to_hex = 7'b0010000;
        default: to_hex = 7'b1111111; 
    endcase
end


endmodule
