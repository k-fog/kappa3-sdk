`define MEMOUT
write_pc(32'h10000000);
write_mem(32'h10000000, 32'hFE208FA3);
write_reg(5'd1, 32'h10000104);
write_reg(5'd2, 32'h0000005A);
write_mem(32'h10000100, 32'h00000000);
