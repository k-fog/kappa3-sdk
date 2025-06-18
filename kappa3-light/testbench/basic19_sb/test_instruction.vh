`define MEMOUT
write_pc(32'h10000000);
write_mem(32'h10000000, 32'h01DE04A3);
write_reg(5'd28, 32'h100000F8);
write_reg(5'd29, 32'h0000005A);
write_mem(32'h10000100, 32'h00000000);
