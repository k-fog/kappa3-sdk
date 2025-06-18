`define MEMOUT
write_pc(32'h10000000);
write_mem(32'h10000000, 32'hFE41AE23);
write_reg(5'd3, 32'h10000104);
write_reg(5'd4, 32'h5AA500FF);
write_mem(32'h10000100, 32'h00000000);
