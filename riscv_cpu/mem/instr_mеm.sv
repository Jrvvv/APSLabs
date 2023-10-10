`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 04:33:17 PM
// Design Name: 
// Module Name: instr_mem
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


module instr_mem
(
    input   logic [31:0] addr_i,
    output  logic [31:0] read_data_o 
);

    logic [31:0] RAM [1023:0];
    
    initial
        $readmemh("program.txt", RAM);
        
    assign read_data_o = (addr_i <= 32'd4095) ? RAM[addr_i[31:2]] : 32'd0;
    
endmodule
