`timescale 1ns / 1ps

module decoder_riscv
(
    input  logic [31:0] fetched_instr_i,
    output logic [1:0]  a_sel_o,
    output logic [2:0]  b_sel_o,
    output logic [4:0]  alu_op_o,
    output logic [2:0]  csr_op_o,
    output logic        csr_we_o,
    output logic        mem_req_o,
    output logic        mem_we_o,
    output logic [2:0]  mem_size_o,
    output logic        gpr_we_o,
    output logic [1:0]  wb_sel_o,
    output logic        illegal_instr_o,
    output logic        branch_o,
    output logic        jal_o,
    output logic        jalr_o,
    output logic        mret_o    
);

    import riscv_pkg::*;

    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;

    assign opcode = fetched_instr_i[6 : 0];
    assign func3  = fetched_instr_i[14:12];
    assign func7  = fetched_instr_i[31:25];
    
    always_comb begin
        // output values by-default (not case's default!!)
        a_sel_o         <= OP_A_RS1;
        b_sel_o         <= OP_B_IMM_I;
        alu_op_o        <= ALU_ADD;

        csr_op_o        <= CSR_RW;
        csr_we_o        <= 1'b0;

        mem_req_o       <= 1'b0;
        mem_we_o        <= 1'b0;
        mem_size_o      <= LDST_W;

        gpr_we_o        <= 1'b1;
        wb_sel_o        <= WB_EX_RESULT;

        illegal_instr_o <= 1'b0;
        branch_o        <= 1'b0;
        jal_o           <= 1'b0;
        jalr_o          <= 1'b0;
        mret_o          <= 1'b0;

        case(opcode)
            // REG-REG OPERS
            {OP_OPCODE,       2'b11}: begin
                b_sel_o <= OP_B_RS2;

                case(func3)
                    // ADD and SUB
                    3'h0: begin
                        case(func7)
                            // ADD
                            7'h0:   alu_op_o <= ALU_ADD;
                            // SUB
                            7'h20:  alu_op_o <= ALU_SUB;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase 
                    end

                    // XOR
                    3'h4: begin
                        case(func7)
                            7'h0: alu_op_o <= ALU_XOR;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase 
                    end

                    // OR
                    3'h6: begin
                        case(func7)
                            7'h0: alu_op_o <= ALU_OR;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase 
                    end

                    // AND
                    3'h7: begin
                        case(func7)
                            7'h0: alu_op_o <= ALU_AND;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase 
                    end

                    // SHIFT LEFT LOGICAL
                    3'h1: begin
                        case(func7)
                            7'h0: alu_op_o <= ALU_SLL;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase 
                    end

                    // SHIFT RIGHT LOGICAL/ARITHMETIC
                    3'h5: begin
                        case(func7)
                            // SHIFT RIGHT LOGICAL
                            7'h0:  alu_op_o <= ALU_SRL;
                            // SHIFT RIGHT ARITHMETIC
                            7'h20: alu_op_o <= ALU_SRA;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase
                    end

                    // SET LESS THEN (rs1 < rs2)
                    3'h2: begin
                        case(func7)
                            7'h0: alu_op_o <= ALU_SLTS;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase
                    end

                    // SET LESS THEN UNSIGNED (rs1 < rs2)
                    3'h3: begin
                        case(func7)
                            7'h0: alu_op_o <= ALU_SLTU;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase
                    end
                    default: begin
                        illegal_instr_o <= 1'b1;
                        gpr_we_o        <= 1'b0;
                    end
                endcase
            end

            // REG-IMM OPERS
            {OP_IMM_OPCODE,   2'b11}: begin
                case(func3)
                    // ADD I
                    3'h0: alu_op_o <= ALU_ADD;
                    // XOR I
                    3'h4: alu_op_o <= ALU_XOR;
                    // OR I
                    3'h6: alu_op_o <= ALU_OR;
                    // AND I
                    3'h7: alu_op_o <= ALU_AND;

                    // SHIFT LEFT LOGICAL I
                    3'h1: begin
                        case(func7)
                            7'h0: alu_op_o <= ALU_SLL;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase
                    end

                    // SHIFT RIGHT L/A I
                    3'h5: begin
                        case(func7)
                            // SHIFT RIGHT LOGICAL I
                            7'h0:  alu_op_o <= ALU_SRL;
                            // SHIFT RIGHT ARITHMETIC I
                            7'h20: alu_op_o <= ALU_SRA;

                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                            end
                        endcase
                    end

                    // SET LESS THEN I (rs1 < imm)
                    3'h2: alu_op_o <= ALU_SLTS;
                    // SET LESS THEN I UNSIGNED (rs1 < imm)
                    3'h3: alu_op_o <= ALU_SLTU;

                    default: begin
                        illegal_instr_o <= 1'b1;
                        gpr_we_o        <= 1'b0;
                    end
                endcase
            end

            // LOAD OPERS
            {LOAD_OPCODE,     2'b11}: begin
                wb_sel_o  <= WB_LSU_DATA;
                mem_req_o <= 1'b1;

                case(func3)
                    // LOAD BYTE
                    3'h0: mem_size_o <= LDST_B;
                    // LOAD HALF
                    3'h1: mem_size_o <= LDST_H;
                    // LOAD WORD
                    3'h2: mem_size_o <= LDST_W;
                    // LOAD BYTE INSIGNED
                    3'h4: mem_size_o <= LDST_BU;
                    // LOAD HALF INSIGNED
                    3'h5: mem_size_o <= LDST_HU;

                    default: begin
                        illegal_instr_o <= 1'b1;
                        mem_req_o       <= 1'b0;
                        gpr_we_o        <= 1'b0;
                    end
                endcase
            end

            // STORE OPERS
            {STORE_OPCODE,    2'b11}: begin
                gpr_we_o  <= 1'b0;
                mem_req_o <= 1'b1;
                mem_we_o  <= 1'b1;
                b_sel_o   <= OP_B_IMM_S;
                case(func3)
                    // STORE BYTE
                    3'h0: mem_size_o <= LDST_B;
                    // STORE HALF
                    3'h1: mem_size_o <= LDST_H;
                    // STORE WORD
                    3'h2: mem_size_o <= LDST_W;

                    default: begin
                        illegal_instr_o <= 1'b1;
                        mem_req_o       <= 1'b0;
                        mem_we_o        <= 1'b0;
                    end
                endcase
            end

            // BRANCH OPERS
            {BRANCH_OPCODE,   2'b11}: begin
                b_sel_o     <= OP_B_RS2;
                gpr_we_o    <= 1'b0;
                branch_o    <= 1'b1;

                case(func3)
                    // IF EQUAL (rs1 == rs2) pc += imm
                    3'h0: alu_op_o <= ALU_EQ;
                    // IF NOT EQUAL (rs1 != rs2) pc += imm
                    3'h1: alu_op_o <= ALU_NE;
                    // IF LESS THEN (rs1 < rs2) pc += imm
                    3'h4: alu_op_o <= ALU_LTS;
                    // IF GREATER OR EQ (rs1 >= rs2) pc += imm
                    3'h5: alu_op_o <= ALU_GES;
                    // IF LESS THEN UNSIGNED (rs1 < rs2) pc += imm
                    3'h6: alu_op_o <= ALU_LTU;
                    // IF GREATER OR EQ UNSIGNED (rs1 >= rs2) pc += imm
                    3'h7: alu_op_o <= ALU_GEU;

                    default: begin
                        illegal_instr_o <= 1'b1;
                        branch_o    <= 1'b0;
                    end
                endcase
            end

            // JAL OPER (rd = pc + 4, pc += imm)
            {JAL_OPCODE,      2'b11}: begin
                a_sel_o     <= OP_A_CURR_PC;
                b_sel_o     <= OP_B_INCR;
                jal_o       <= 1'b1;
            end

            // JALR OPER (rd = pc + 4, pc = rs1 + imm)
            {JALR_OPCODE,     2'b11}: begin
                a_sel_o     <= OP_A_CURR_PC;
                b_sel_o     <= OP_B_INCR;
                case(func3)
                    3'h0: jalr_o       <= 1'b1;

                    default: begin
                        illegal_instr_o <= 1'b1;
                        gpr_we_o        <= 1'b0;
                    end
                endcase
            end

            // LOAD UPPER IMM OPER (rd = imm << 12)
            {LUI_OPCODE,      2'b11}: begin
                a_sel_o <= OP_A_ZERO;
                b_sel_o <= OP_B_IMM_U;
            end

            // ADD UPPER IMM TO PC OPER (rd = pc + (imm << 12))
            {AUIPC_OPCODE,    2'b11}: begin
                a_sel_o <= OP_A_CURR_PC;
                b_sel_o <= OP_B_IMM_U;
            end

            // FENCE OPER (in current cpu ~ nop oper)
            {MISC_MEM_OPCODE, 2'b11}: begin
                gpr_we_o <= 1'b0;
                case(func3)
                    3'h0: begin end
                    default: begin
                        illegal_instr_o <= 1'b1;
                    end
                endcase
            end

            // CALL/BREAK OPERS (csr = csr_op(rs1); rd = csr)
            {SYSTEM_OPCODE,   2'b11}: begin
                csr_we_o        <= 1'b1;
                gpr_we_o        <= 1'b1;
                wb_sel_o        <= WB_CSR_DATA;
                case(func3)
                    3'h0: begin
                        case(func7)
                            // CALL
                            7'h0:    begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                                csr_we_o        <= 1'b0;
                            end
                            // BREAK
                            7'h1:    begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                                csr_we_o        <= 1'b0;
                            end
                            // MRET
                            7'h18:    begin
                                gpr_we_o        <= 1'b0;
                                csr_we_o        <= 1'b0;
                                mret_o          <= 1'b1;
                            end
                            default: begin
                                illegal_instr_o <= 1'b1;
                                gpr_we_o        <= 1'b0;
                                csr_we_o        <= 1'b0;
                            end
                        endcase
                    end

                    CSR_RW:  csr_op_o <= CSR_RW;
                    CSR_RS:  csr_op_o <= CSR_RS;
                    CSR_RC:  csr_op_o <= CSR_RC;
                    CSR_RWI: csr_op_o <= CSR_RWI;
                    CSR_RSI: csr_op_o <= CSR_RSI;
                    CSR_RCI: csr_op_o <= CSR_RCI;

                    default: begin
                        illegal_instr_o <= 1'b1;
                        gpr_we_o        <= 1'b0;
                        csr_we_o        <= 1'b0;
                    end
                endcase
            end

            default: begin
                illegal_instr_o <= 1'b1;
                gpr_we_o        <= 1'b0;
            end
        endcase
    
    end

endmodule
