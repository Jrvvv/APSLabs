`timescale 1ns / 1ps

module vga_sb_ctrl
(
    input  logic        clk_i,
    input  logic        rst_i,
    input  logic        clk100m_i,
    input  logic        req_i,
    input  logic        write_enable_i,
    input  logic [3:0]  mem_be_i,
    input  logic [31:0] addr_i,
    input  logic [31:0] write_data_i,
    output logic [31:0] read_data_o,

    output logic [3:0]  vga_r_o,
    output logic [3:0]  vga_g_o,
    output logic [3:0]  vga_b_o,
    output logic        vga_hs_o,
    output logic        vga_vs_o
);

    // wires for we/re logic
    logic [9:0]   vga_char_addr;
    logic [1:0]   rw_char_sel;

    // wires to vga module
    logic         char_map_we;
    logic         col_map_we;
    logic         char_tiff_we;

    // wires to vga module
    logic [31:0]  char_map_rdata;
    logic [31:0]  col_map_rdata;
    logic [31:0]  char_tiff_rdata;

    // signals to indicate which req
    logic write_req;
    logic read_req;

    assign write_req = req_i &  write_enable_i;
    assign read_req  = req_i & ~write_enable_i;

    assign vga_char_addr                = addr_i[11:2];
    assign rw_char_sel                  = addr_i[13:12];

    // write enable
    always_comb begin
        if(rst_i) begin
            char_map_we  <= 1'b0;
            col_map_we   <= 1'b0;
            char_tiff_we <= 1'b0;
        end else begin
            case(rw_char_sel)
                2'b00   : char_map_we  <= write_req;
                2'b01   : col_map_we   <= write_req;
                2'b10   : char_tiff_we <= write_req;
                default : begin
                          char_map_we  <= 1'b0;
                          col_map_we   <= 1'b0;
                          char_tiff_we <= 1'b0;
                end
            endcase
        end
    end

    // read enable
    always_ff @(posedge clk_i) begin
        if(rst_i) begin
            read_data_o <= 32'b0;
        end else begin
            if (read_req) begin
                case(rw_char_sel)
                    2'b00   : read_data_o  <= char_map_rdata;
                    2'b01   : read_data_o  <= col_map_rdata;
                    2'b10   : read_data_o  <= char_tiff_rdata;
                    default : read_data_o  <= 32'b0;
                endcase
            end else begin
                read_data_o  <= 32'b0;
            end
        end
    end

    vgachargen vga_char_gen_dev
    (
        .clk_i            (clk_i),                  // system clock
        .clk100m_i        (clk100m_i),              // 100MHz clock
        .rst_i            (rst_i),                  // reset

        // Interface for writing the displayed character
        .char_map_addr_i  (vga_char_addr),          // the address of the position of the displayed character
        .char_map_we_i    (char_map_we),            // code write enable signal
        .char_map_be_i    (mem_be_i),               // byte selection signal for writing
        .char_map_wdata_i (write_data_i),           // ascii-code of displayed character
        .char_map_rdata_o (char_map_rdata),         // the signal for reading the character code

        // Interface for setting the color scheme
        .col_map_addr_i   (vga_char_addr),          // the address of the position of the installed scheme
        .col_map_we_i     (col_map_we),             // The signal for the writing of the scheme
        .col_map_be_i     (mem_be_i),               // byte selection signal for writing
        .col_map_wdata_i  (write_data_i),           // the code of the installed color scheme
        .col_map_rdata_o  (col_map_rdata),          // read scheme code signal

        // Font Set Interface
        .char_tiff_addr_i (vga_char_addr),          // installed font position address
        .char_tiff_we_i   (char_tiff_we),           // font write eneble signal
        .char_tiff_be_i   (mem_be_i),               // byte selection signal for writing
        .char_tiff_wdata_i(write_data_i),           // displayed pixels in the current font position
        .char_tiff_rdata_o(char_tiff_rdata),        // font pixel reading signal

        .vga_r_o          (vga_r_o),                // vga red channel
        .vga_g_o          (vga_g_o),                // vga green channel
        .vga_b_o          (vga_b_o),                // vga blue channel
        .vga_hs_o         (vga_hs_o),               // vga horizontal sync line
        .vga_vs_o         (vga_vs_o)                // vga vertical sync line
    );

endmodule
