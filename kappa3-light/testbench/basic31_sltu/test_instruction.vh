write_pc(32'h10000000);
write_mem(32'h10000000, 32'h00D63733); // SLTU x14, x12, x13
write_reg(5'd12, 32'h00000064);
write_reg(5'd13, 32'h0000000A);
write_reg(5'd14, 32'hFFFFFFFF);