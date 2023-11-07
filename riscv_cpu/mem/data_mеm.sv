`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 04:33:17 PM
// Design Name: 
// Module Name: data_mem
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


module data_mem
(
    input   logic        clk_i,
    input   logic        mem_req_i,
    input   logic        write_enable_i,
    input   logic [31:0] addr_i,
    input   logic [31:0] write_data_i,
    output  logic [31:0] read_data_o       
);

    logic [31:0] RAM [4095:0];
    logic [31:0] current_data;
    
    // reading
    always_ff @(posedge clk_i) begin
        if (mem_req_i)
            current_data <= RAM[addr_i[31:2]];
        else
            current_data <= current_data; 
    end
    
    // writing
    always_ff @(posedge clk_i) begin
        if (mem_req_i && write_enable_i)
            RAM[addr_i[31:2]] <= write_data_i;
        else
            RAM[addr_i[31:2]] <= RAM[addr_i[31:2]];
    end
    
    always_comb begin
        if (!mem_req_i || write_enable_i)
            read_data_o = 32'hfa11_1eaf;
        else if (mem_req_i && addr_i <= 32'd16383)
            read_data_o = current_data;
        else if (mem_req_i && addr_i > 32'd16383)
            read_data_o = 32'hdead_beef;
        else
            read_data_o = read_data_o;
    end

endmodule
