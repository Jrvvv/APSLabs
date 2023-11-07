`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2023 12:48:57 AM
// Design Name: 
// Module Name: cybercobra
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CYBERcobra
(
    input  logic            clk_i,
    input  logic            rst_i,
    input  logic    [15:0]  sw_i,
    output logic    [31:0]  out_o
);
// ----------------- wires and regs -----------------

    // programm counter
    logic [31:0]    PC;

    // basic ALU wires
    logic [31:0]    ALU_res;
    logic           ALU_flag;
    logic [4:0]     opcode;
    
    // basic instr mem wires
    logic [31:0]    instr_mem_out;
    
    // basic RF wires
    logic           WE;
    logic [4:0]     RA1;
    logic [4:0]     RA2;
    logic [4:0]     WA;
    logic [31:0]    WD;
    logic [31:0]    RD1;
    logic [31:0]    RD2;
    
    // select WD reg file input
    logic [1:0]   WS;
    
    // const to RF from sw (extended)
    logic [31:0]    sw_out_SE;
    
    // const to RF from instruction
    logic [22:0]    RF_const;
    logic [31:0]    RF_const_SE;
    
    // PC offset wires
    logic [9:0]     offset;
    logic [31:0]    offset_SE;
    logic           PC_SS;      // source selector
    // -------------------------------------------------

     instr_mem instr_mem_dev 
     (
        .addr_i(PC),
        .read_data_o(instr_mem_out)
     );
    
    always_ff @(posedge clk_i or posedge rst_i) begin
            if (rst_i) begin
                PC <= 32'd0;
            end else begin
                if (PC_SS)
                    PC <= PC + offset_SE;
                else
                    PC <= PC + 32'd4; 
            end
    end
    
    // ----------------- wires from instr mem -----------------
        // PC logic
    assign offset       = {instr_mem_out[12:5], 2'd0};
    assign offset_SE    = {{22{offset[9]}}, offset[9:0]};
    assign PC_SS        = (instr_mem_out[30] & ALU_flag) | instr_mem_out[31];
    
        // ALU
    assign opcode       = instr_mem_out[27:23];
    
        // RF
    assign WE           = ~(instr_mem_out[30] | instr_mem_out[31]);
    assign RA1          = instr_mem_out[22:18];
    assign RA2          = instr_mem_out[17:13];
    assign WA           = instr_mem_out[4:0];
    assign WS           = instr_mem_out[29:28];
    
        // RF const from instr
    assign RF_const     = instr_mem_out[27:5];
    assign RF_const_SE  = {{9{RF_const[22]}}, RF_const[22:0]};
    
        // RF const from switch
    assign sw_out_SE    = {{16{sw_i[15]}}, sw_i[15:0]};
    
        //MUX4_1 selection of WD in RF
    always_comb begin
        case(WS)
            2'd0 : WD = RF_const_SE;
            2'd1 : WD = ALU_res;
            2'd2 : WD = sw_out_SE;
            2'd3 : WD = 32'd0;
         endcase
     end
     // -------------------------------------------------
    
    rf_riscv rf_dev
    (
        .clk_i            (clk_i),
        .write_addr_i     (WA),
        .read_addr1_i     (RA1),
        .read_addr2_i     (RA2),
        .write_data_i     (WD),
        .write_enable_i   (WE),
        .read_data1_o     (RD1),
        .read_data2_o     (RD2)
    );
    
    alu_riscv alu_dev
    (
        .alu_op_i (opcode),
        .a_i      (RD1),
        .b_i      (RD2),

        .result_o (ALU_res),
        .flag_o   (ALU_flag)
    );
    
    assign out_o = RD1;
    
endmodule
