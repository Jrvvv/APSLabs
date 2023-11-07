`timescale 1ns / 1ps

module riscv_core
(
    input   logic        clk_i,
    input   logic        rst_i,

    input   logic        stall_i,
    input   logic [31:0] instr_i,
    input   logic [31:0] mem_rd_i,

    output  logic [31:0] instr_addr_o,
    output  logic [31:0] mem_addr_o,
    output  logic [ 2:0] mem_size_o,
    output  logic        mem_req_o,
    output  logic        mem_we_o,
    output  logic [31:0] mem_wd_o
);
    logic [31:0] wb_data;

    // decoder wires
    logic [4 :0] alu_op;
    logic [1 :0] a_sel;
    logic [2 :0] b_sel;
    logic        wb_sel;
    logic        jal;
    logic        jalr;
    logic        b;
    logic        gpr_we;

    // RF wires
    logic [31:0] RD1;
    logic [31:0] RD2;
    logic        WE;

    // PC and wires
    logic [31:0] PC;
    logic [31:0] to_PC;
    logic [31:0] jalr_op;
    logic [31:0] RD1_I_add;

    // added imm to current
    logic [31:0] addr_jb_res;
    logic [31:0] jb_or_4;
    logic [31:0] j_or_b;

    // ALU wires
    logic [31:0] oper_b;
    logic [31:0] oper_a;
    logic [31:0] alu_res;
    logic        flag;

    // imm extended wires
    logic [31:0] imm_I;
    logic [31:0] imm_U;
    logic [31:0] imm_S;
    logic [31:0] imm_B;
    logic [31:0] imm_J;


    // RF memory module
    rf_riscv rf_dev
    (
        .clk_i            (clk_i),
        .write_addr_i     (instr_i[11:7]),
        .read_addr1_i     (instr_i[19:15]),
        .read_addr2_i     (instr_i[24:20]),
        .write_data_i     (wb_data),
        .write_enable_i   (WE),
        .read_data1_o     (RD1),
        .read_data2_o     (RD2)
    );

    // alu module
    alu_riscv alu_dev
    (
        .alu_op_i (alu_op),
        .a_i      (oper_a),
        .b_i      (oper_b),

        .result_o (alu_res),
        .flag_o   (flag)
    );

    // decoder module
    decoder_riscv decoder_dev
    (
        .fetched_instr_i (instr_i),
        .a_sel_o         (a_sel),
        .b_sel_o         (b_sel),
        .alu_op_o        (alu_op),
        // .csr_op_o        (),
        // .csr_we_o        (),
        .mem_req_o       (mem_req_o),
        .mem_we_o        (mem_we_o),
        .mem_size_o      (mem_size_o),
        .gpr_we_o        (gpr_we),
        .wb_sel_o        (wb_sel),
        // .illegal_instr_o (),
        // .mret_o          (),
        .branch_o        (b),
        .jal_o           (jal),
        .jalr_o          (jalr)
    );

    // sign extension blocks
    assign imm_I        = {{21{instr_i[31]}}, instr_i[30:20]                                      };
    assign imm_U        = { instr_i[31:12],   12'h000                                             };
    assign imm_S        = {{21{instr_i[31]}}, instr_i[30:25], instr_i[11:7]                       };
    assign imm_B        = {{20{instr_i[31]}}, instr_i[7],     instr_i[30:25], instr_i[11:8],  1'b0};
    assign imm_J        = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20],    instr_i[30:21], 1'b0};

    assign mem_wd_o     = RD2;
    assign mem_addr_o   = alu_res;
    assign instr_addr_o = PC;

    assign wb_data      = ( wb_sel           )  ? mem_rd_i                  : alu_res;
    assign j_or_b       = ( b                )  ? imm_B                     : imm_J;
    assign jb_or_4      = ( (flag & b) | jal )  ? j_or_b                    : 32'd4;

    assign addr_jb_res  = PC  + jb_or_4;
    assign RD1_I_add    = RD1 + imm_I;

    assign to_PC        = ( jalr             )  ? {RD1_I_add[31:1], 1'b0}   : addr_jb_res;

    assign WE = gpr_we & (~stall_i);

    always_comb begin
        case(a_sel)
            2'd0    : oper_a <= RD1;
            2'd1    : oper_a <= PC;
            default : oper_a <= 32'd0;
        endcase
    end

    always_comb begin
        case(b_sel)
            2'd0    : oper_b <= RD2;
            2'd1    : oper_b <= imm_I;
            2'd2    : oper_b <= imm_U;
            2'd3    : oper_b <= imm_S;
            default : oper_b <= 32'd4;
        endcase
    end

    // IS RESET BY POS OR NEG??
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i)
            PC <= 32'b0;
        else if (stall_i)
            PC <= PC;
        else
            PC <= to_PC;
    end

endmodule
