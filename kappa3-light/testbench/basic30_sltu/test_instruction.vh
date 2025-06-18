write_pc(32'h10000000);
write_mem(32'h10000000, 32'h00B536B3); // SLTU x13, x10, x11
write_reg(5'd10, 32'hFFFFFFF6);
write_reg(5'd11, 32'h00000064);
write_reg(5'd13, 32'hFFFFFFFF);