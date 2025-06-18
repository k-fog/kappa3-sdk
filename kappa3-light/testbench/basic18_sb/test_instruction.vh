`define MEMOUT
write_pc(32'h10000000);
write_mem(32'h10000000, 32'h01BD0023);
write_reg(5'd26, 32'h10000100);
write_reg(5'd27, 32'h0000005A);
write_mem(32'h10000100, 32'h00000000);
