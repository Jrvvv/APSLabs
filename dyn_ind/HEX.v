`timescale 1ns / 1ps

module HEX(
input   CLK100MHZ,
input   [15:0]  SW, 
output  [7:0]   AN,
output  [6:0]   HEX
);

reg [9:0]   cntr;
wire        isMax;

initial begin
    cntr = 10'b0;
end

always@(posedge CLK100MHZ) begin
    cntr = cntr + 1'b1;
end

assign isMax = (cntr[9] == 1'b1);

dyn_ind(
isMax,
SW[3:0],
SW[7:4],
SW[11:8],
SW[15:12],
HEX[6:0],
AN[7:0]
);

endmodule
