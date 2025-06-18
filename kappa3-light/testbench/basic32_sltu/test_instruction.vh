write_pc(32'h10000000);
write_mem(32'h10000000, 32'h00F737B3); // SLTU x15, x14, x15
write_reg(5'd14, 32'h00000064);
write_reg(5'd15, 32'hFFFFFFF6);