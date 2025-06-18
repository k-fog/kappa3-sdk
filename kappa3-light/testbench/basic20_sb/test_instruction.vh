`define MEMOUT
write_pc(32'h10000000);
write_mem(32'h10000000, 32'h01FF0323);
write_reg(5'd30, 32'h100000FC);
write_reg(5'd31, 32'h0000005A);
write_mem(32'h10000100, 32'h00000000);
