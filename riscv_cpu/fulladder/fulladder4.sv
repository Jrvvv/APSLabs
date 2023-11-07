module fulladder4
(
  input  logic         carry_i,
  input  logic  [3:0]  a_i,
  input  logic  [3:0]  b_i,
  output logic  [3:0]  sum_o,
  output logic         carry_o
);

logic [4:0] carry_wires;

assign carry_wires[0] = carry_i;
assign carry_o = carry_wires[4];

genvar i;

generate
  for (i = 0; i < 4; i = i + 1) begin : newgen    
    fulladder adder (
      .carry_i(carry_wires[i]),
      .a_i(a_i[i]),
      .b_i(b_i[i]),
      .sum_o(sum_o[i]),
      .carry_o(carry_wires[i+1])
    );
  end    
endgenerate

endmodule
