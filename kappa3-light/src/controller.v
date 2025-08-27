
// @file controller.v
// @breif controller(コントローラ)
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// データパスを制御する信号を生成する．
// フェイズは phasegen が生成するので
// このモジュールは完全な組み合わせ回路となる．
//
// [入力]
// cstate:     動作フェイズを表す4ビットの信号
// ir:         IRレジスタの値
// addr:       メモリアドレス(mem_wrbitsの生成に用いる)
// alu_out:    ALUの出力(分岐命令の条件判断に用いる)
//
// [出力]
// pc_sel:     PCの入力選択
// pc_ld:      PCの書き込み制御
// mem_sel:    メモリアドレスの入力選択
// mem_read:   メモリの読み込み制御
// mem_write:  メモリの書き込み制御
// mem_wrbits: メモリの書き込みビットマスク
// ir_ld:      IRレジスタの書き込み制御
// rs1_addr:   RS1アドレス
// rs2_addr:   RS2アドレス
// rd_addr:    RDアドレス
// rd_sel:     RDの入力選択
// rd_ld:      RDの書き込み制御
// a_ld:       Aレジスタの書き込み制御
// b_ld:       Bレジスタの書き込み制御
// a_sel:      ALUの入力1の入力選択
// b_sel:      ALUの入力2の入力選択
// imm:        即値
// alu_ctl:    ALUの機能コード
// c_ld:       Cレジスタの書き込み制御
module controller(input [3:0]   cstate,
		  input [31:0] 	ir,
		  input [31:0]  addr,
		  input [31:0] 	alu_out,
		  output 	pc_sel,
		  output 	pc_ld,
		  output 	mem_sel,
		  output 	mem_read,
		  output 	mem_write,
		  output [3:0] 	mem_wrbits,
		  output 	ir_ld,
		  output [4:0] 	rs1_addr,
		  output [4:0] 	rs2_addr,
		  output [4:0] 	rd_addr,
		  output [1:0] 	rd_sel,
		  output 	rd_ld,
		  output 	a_ld,
		  output 	b_ld,
		  output 	a_sel,
		  output 	b_sel,
		  output [31:0] imm,
		  output [3:0] 	alu_ctl,
		  output 	c_ld);
		  
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	assign opcode = ir[6:0];
	assign funct3 = ir[14:12];
	assign funct7 = ir[31:25];
	wire cs_wb, cs_ex, cs_de, cs_if;
	assign {cs_wb, cs_ex, cs_de, cs_if} = cstate;
	
	// PC
	function handle_pc_sel(input [6:0] op, input alu);
		casex(op)
		7'b110X111: handle_pc_sel = 1;
		7'b1100011: handle_pc_sel = alu;
		default:    handle_pc_sel = 0;
		endcase
	endfunction
	assign pc_sel = handle_pc_sel(opcode, alu_out[0]);
	assign pc_ld = cs_wb;
	
	// MEMORY
	function handle_mem_sel(input is_cs_if, is_cs_wb, is_ls);
		if (is_cs_if) handle_mem_sel = 0;
		else if (is_cs_wb && is_ls) handle_mem_sel = 1;
	endfunction
	
	function [3:0] handle_mem_wrbits(input [2:0] f3, input [1:0] mem_l2b);
		case (f3)
		3'b000: handle_mem_wrbits = 4'b0001 << mem_l2b;// sb
		3'b001: handle_mem_wrbits = 4'b0011 << mem_l2b;// sh
		3'b010: handle_mem_wrbits = 4'b1111; // sw
		endcase
	endfunction
	
	assign mem_sel = handle_mem_sel(cs_if, cs_wb, (opcode == 7'b0000011 || opcode == 7'b0100011));
	assign mem_read = cs_if || (cs_wb && opcode == 7'b0000011);
	assign mem_write = cs_wb && opcode == 7'b0100011;
	assign mem_wrbits = handle_mem_wrbits(funct3, addr[1:0]);
	
	// IR
	assign ir_ld = cs_if;
	
	// A,B
	assign {a_ld, b_ld} = {cs_de, cs_de};
	
	// REGISTER
	function [2:0] handle_rd_ld_sel(input is_cs_wb, input [6:0] op);
		if (is_cs_wb) 
			casex (op)
			7'b0X10X11: handle_rd_ld_sel = {1'b1, 2'b10}; // calc, lui, auipc: C
			7'b0000011: handle_rd_ld_sel = {1'b1, 2'b00}; // load: MEM
			7'b110X111: handle_rd_ld_sel = {1'b1, 2'b01}; // jump: PC
			default:    handle_rd_ld_sel = {1'b0, 2'bXX};
			endcase
		else handle_rd_ld_sel = {1'b0, 2'bXX};
	endfunction
	
	assign rs1_addr = ir[19:15];
	assign rs2_addr = ir[24:20];
	assign rd_addr = ir[11:7];
	assign {rd_ld, rd_sel} = handle_rd_ld_sel(cs_wb, opcode);
	
	// IMMIDIATE
	function [31:0] handle_imm(input [31:0] f_ir);
		casex(f_ir[6:0]) // opcode
		7'b0010011: if (funct3 == 3'b001 || funct3 == 3'b101) handle_imm = f_ir[31:20] & 5'b11111;// I
						else handle_imm = {{20{f_ir[31]}}, f_ir[31:20]};
		7'b0000011: handle_imm = {{20{f_ir[31]}}, f_ir[31:20]}; // I
		7'b1100111: handle_imm = {{20{f_ir[31]}}, f_ir[31:20]}; // I
		7'b1110011: handle_imm = {{20{f_ir[31]}}, f_ir[31:20]}; // I
		7'b0100011: handle_imm = {{20{f_ir[31]}}, f_ir[31:25], f_ir[11:7]}; // S
		7'b1100011: handle_imm = {{20{f_ir[31]}}, f_ir[31], f_ir[7], f_ir[30:25], f_ir[11:8], 1'b0}; // B
		7'b0X10111: handle_imm = f_ir[31:12] << 12; // U
		7'b1101111: handle_imm = {{11{f_ir[31]}}, f_ir[31], f_ir[19:12], f_ir[20], f_ir[30:21], 1'b0}; // J
		endcase
	endfunction
	
	assign imm = handle_imm(ir);
						
	// ALU
	function [5:0] handle_alu(input is_cs_ex, is_cs_wb, input [6:0] op, input [2:0] f3, input [6:0] f7);
		if (is_cs_ex)
			casex (op)
				// calc (register)
				7'b0110011: case (f3)
								3'b000: handle_alu = {1'b0, 1'b0, 4'b1000 | f7[5]}; // add, sub
								3'b100: handle_alu = {1'b0, 1'b0, 4'b1010}; // xor
								3'b110: handle_alu = {1'b0, 1'b0, 4'b1011}; // or
								3'b111: handle_alu = {1'b0, 1'b0, 4'b1100}; // and
								3'b001: handle_alu = {1'b0, 1'b0, 4'b1101}; // sll
								3'b101: handle_alu = {1'b0, 1'b0, 4'b1110 | f7[5]}; // srl, sra
								3'b010: handle_alu = {1'b0, 1'b0, 4'b0100}; // slt
								3'b011: handle_alu = {1'b0, 1'b0, 4'b0110}; // sltu
								endcase
				// calc (immidiate)
				7'b0010011: case (f3)
								3'b000: handle_alu = {1'b0, 1'b1, 4'b1000}; // add
								3'b100: handle_alu = {1'b0, 1'b1, 4'b1010}; // xor
								3'b110: handle_alu = {1'b0, 1'b1, 4'b1011}; // or
								3'b111: handle_alu = {1'b0, 1'b1, 4'b1100}; // and
								3'b001: handle_alu = {1'b0, 1'b1, 4'b1101}; // sll
								3'b101: handle_alu = {1'b0, 1'b1, 4'b1110 | f7[5]}; // srl, sra
								3'b010: handle_alu = {1'b0, 1'b1, 4'b0100}; // slt
								3'b011: handle_alu = {1'b0, 1'b1, 4'b0110}; // sltu
								endcase
				// load, store
				7'b0X00011: handle_alu = {1'b0, 1'b1, 4'b1000};
				
				// branch
				7'b1100011: handle_alu = {1'b1, 1'b1, 4'b1000};
								
				// jal, jalr
				7'b110X111: handle_alu = {op[3], 1'b1, 4'b1000};
				
				// lui
				7'b0110111: handle_alu = {1'bX, 1'b1, 4'b0000};
				
				// auipc
				7'b0010111: handle_alu = {1'b1, 1'b1, 4'b1000};
			endcase
		else if (is_cs_wb)
			case (f3)
			3'b000: handle_alu = {1'b0, 1'b0, 4'b0010}; // beq
			3'b001: handle_alu = {1'b0, 1'b0, 4'b0011}; // bne
			3'b100: handle_alu = {1'b0, 1'b0, 4'b0100}; // blt
			3'b101: handle_alu = {1'b0, 1'b0, 4'b0101}; // bge
			3'b110: handle_alu = {1'b0, 1'b0, 4'b0110}; // bltu
			3'b111: handle_alu = {1'b0, 1'b0, 4'b0111}; // bgeu
			endcase;
	endfunction
	
	assign {a_sel, b_sel, alu_ctl} = handle_alu(cs_ex, cs_wb, opcode, funct3, funct7);
	
	// C
	assign c_ld = cs_ex;
	
endmodule // controller
