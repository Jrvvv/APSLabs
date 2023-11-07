`timescale 1ns / 1ps

module alu_simple_tb();

import alu_opcodes_pkg::*;

parameter TEST_VALUES     = 10000;
parameter TIME_OPERATION  = 100;

reg [8*9:1] operator_type;

logic [4:0]  operator_i;
logic [31:0] operand_a_i;
logic [31:0] operand_b_i;

wire logic [31:0] result_o;
logic        comparison_result_o;

alu_riscv DUT
(
  .alu_op_i (operator_i   ),
  .a_i      (operand_a_i  ),
  .b_i      (operand_b_i  ),

  .result_o (result_o     ),
  .flag_o   (comparison_result_o)
);

integer err_count = 0;
logic   [31:0]          result_dump;
logic                   comparison_result_dump;

  task check_op;
    input [4:0]  opcode_i;
    input [31:0] a_i, b_i;
    input [31:0] res_i;
    input        comp_res_i;
    begin
      result_dump               = res_i;
      comparison_result_dump    = comp_res_i;
      operand_a_i               = a_i;
      operand_b_i               = b_i;
      operator_i                = opcode_i;
      #10;
      if( (result_dump !== result_o) || (comparison_result_dump !== comparison_result_o) ) begin
          $display("ERROR Operator: %s", operator_type, " operand_A: %h", operand_a_i, " operand_B: %h", operand_b_i, " your_Result: %h", result_o, " Result_dump: %h", result_dump, " your_Flag: %h", comparison_result_o, " Flag_dump: %h", comparison_result_dump);
          err_count = err_count + 1'b1;
      end
      #10;
    end
  endtask

  initial
    begin
      #10;
//        operator_i = ALU_ADD;
//        operand_a_i = 32'hAABB;
//        operand_b_i = 32'h00AA;
//      #10;
//      if( (32'hab65 !== result_o) || (1'b0 !== comparison_result_o) ) begin
//          $display("ERROR Operator: %s", operator_type, " operand_A: %h", operand_a_i, " operand_B: %h", operand_b_i, " your_Result: %h", result_o, " Result_dump: %h", result_dump, " your_Flag: %h", comparison_result_o, " Flag_dump: %h", comparison_result_dump);
//          err_count = err_count + 1'b1;
//      end else begin
//          $display("SUCCESS");
//      end
//      #10;
//      $finish;
      
      check_op(ALU_ADD,  32'hAABB, 32'h00AA, 32'hAABB + 32'h00AA,            1'b0);
      check_op(ALU_SUB,  32'hAABB, 32'h00AA, 32'hAABB - 32'h00AA,            1'b0);
      check_op(ALU_SUB,  32'h00AA, 32'hAABB, 32'h00AA - 32'hAABB,            1'b0);
      check_op(ALU_XOR,  32'hAABB, 32'h00AA, 32'hAABB ^ 32'h00AA,            1'b0);
      check_op(ALU_AND,  32'hAABB, 32'h00AA, 32'hAABB & 32'h00AA,            1'b0);
      check_op(ALU_OR,   32'hAABB, 32'h00AA, 32'hAABB | 32'h00AA,            1'b0);
      check_op(ALU_SRA,  32'hAABB, 5'b01010, $signed(32'hAABB) >>> 5'b01010, 1'b0);
      check_op(ALU_SRL,  32'hAABB, 5'b01010, 32'hAABB >> 5'b01010,           1'b0);
      check_op(ALU_SLL,  32'hAABB, 5'b01010, 32'hAABB << 5'b01010,           1'b0);
      
      check_op(ALU_SLTS, 32'hAABB,     32'h00AA, {31'b0,($signed(32'hAABB) < $signed(32'h00AA))},      1'b0);
      check_op(ALU_SLTS, 32'hF000AABB, 32'h00AA, {31'b0,($signed(32'hF000AABB) < $signed(32'h00AA))},  1'b0);
      check_op(ALU_SLTU, 32'hAABB,     32'h00AA, {31'b0,(32'hAABB < 32'h00AA)},                        1'b0);
      check_op(ALU_SLTU, 32'hF000AABB, 32'h00AA, {31'b0,(32'hF000AABB < 32'h00AA)},                    1'b0);

      check_op(ALU_LTS, 32'hAABB,     32'h00AA,  1'b0,  ($signed(32'hAABB) < $signed(32'h00AA)));
      check_op(ALU_LTU, 32'hF000AABB, 32'h00AA,  1'b0,  (32'hAABB < 32'h00AA));
      check_op(ALU_GES, 32'hAABB,     32'h00AA,  1'b0,  ($signed(32'hAABB) >= $signed(32'h00AA)));
      check_op(ALU_GEU, 32'hF000AABB, 32'h00AA,  1'b0,  (32'hAABB >= 32'h00AA));
      check_op(ALU_EQ,  32'hAABB,     32'h00AA,  1'b0,  (32'hAABB == 32'h00AA));
      check_op(ALU_EQ,  32'hAABB,     32'hAABB,  1'b0,  (32'hAABB == 32'hAABB));
      check_op(ALU_NE,  32'hAABB,     32'h00AA,  1'b0,  (32'hAABB != 32'h00AA));
      check_op(ALU_NE,  32'hAABB,     32'hAABB,  1'b0,  (32'hAABB != 32'hAABB));
      $finish;

    end

always @(*) begin
 case(operator_i)
   ALU_ADD  : operator_type = "ALU_ADD  ";
   ALU_SUB  : operator_type = "ALU_SUB  ";
   ALU_XOR  : operator_type = "ALU_XOR  ";
   ALU_OR   : operator_type = "ALU_OR   ";
   ALU_AND  : operator_type = "ALU_AND  ";
   ALU_SRA  : operator_type = "ALU_SRA  ";
   ALU_SRL  : operator_type = "ALU_SRL  ";
   ALU_SLL  : operator_type = "ALU_SLL  ";
   ALU_LTS  : operator_type = "ALU_LTS  ";
   ALU_LTU  : operator_type = "ALU_LTU  ";
   ALU_GES  : operator_type = "ALU_GES  ";
   ALU_GEU  : operator_type = "ALU_GEU  ";
   ALU_EQ   : operator_type = "ALU_EQ   ";
   ALU_NE   : operator_type = "ALU_NE   ";
   ALU_SLTS : operator_type = "ALU_SLTS ";
   ALU_SLTU : operator_type = "ALU_SLTU ";
   default   : operator_type = "NOP      ";
 endcase
end


endmodule
