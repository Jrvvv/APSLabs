`timescale 1ns / 1ps

module riscv_unit
(
    input  logic        clk_i,
    input  logic        rst_i
);

    logic           stall_reg;
    logic           stall;

    logic   [31:0]  instr_addr;
    logic           mem_req;
    logic           mem_we;
    // logic   [2: 0]  mem_size;
    logic   [31:0]  mem_wd;
    logic   [31:0]  mem_addr;

    logic   [31:0]  mem_rd;
    logic   [31:0]  instr;

    riscv_core core
    (
        .clk_i          (clk_i),
        .rst_i          (rst_i),

        .stall_i        (stall),
        .instr_i        (instr),
        .mem_rd_i       (mem_rd),

        .instr_addr_o   (instr_addr),
        .mem_addr_o     (mem_addr),
        // .mem_size_o     (),
        .mem_req_o      (mem_req),
        .mem_we_o       (mem_we),
        .mem_wd_o       (mem_wd)
    );

     instr_mem instr_mem_dev
     (
        .addr_i      (instr_addr),
        .read_data_o (instr)
     );

    data_mem data_mem_dev
    (
        .clk_i          (clk_i),
        .mem_req_i      (mem_req),
        .write_enable_i (mem_we),
        .addr_i         (mem_addr),
        .write_data_i   (mem_wd),
        .read_data_o    (mem_rd)
    );

    assign stall = ~(stall_reg) & mem_req;

    always_ff@(posedge clk_i)
        stall_reg <= stall;

endmodule