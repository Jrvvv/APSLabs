module fulladder32
(
  input  logic          carry_i,
  input  logic  [31:0]  a_i,
  input  logic  [31:0]  b_i,
  output logic  [31:0]  sum_o,
  output logic          carry_o
);

logic [8:0] carry_wires;

assign carry_wires[0] = carry_i;
assign carry_o = carry_wires[8];

genvar i;

generate
  for (i = 0; i < 8; i = i + 1) begin : newgen
    localparam from = i * 4;
    localparam to = (i + 1) * 4 - 1;
      
    fulladder4 adder (
      .carry_i(carry_wires[i]),
      .a_i(a_i[to:from]),
      .b_i(b_i[to:from]),
      .sum_o(sum_o[to:from]),
      .carry_o(carry_wires[i+1])
    );
  end    
endgenerate

endmodule
