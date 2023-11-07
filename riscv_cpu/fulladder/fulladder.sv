module fulladder
(
  input  logic   carry_i,
  input  logic   a_i,
  input  logic   b_i,
  output logic   sum_o,
  output logic   carry_o
);

assign sum_o = (a_i ^ b_i) ^ carry_i;
assign carry_o = (a_i & b_i) | (a_i & carry_i) | (b_i & carry_i);

endmodule
