
// @file ldconv.v
// @breif ldconv(ロードデータ変換器)
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// ロードのデータタイプに応じてデータを変換する．
// 具体的には以下の処理を行う．
//
// * B(byte) タイプ
//   オフセットに応じたバイトを取り出し，符号拡張を行う．
// * BU(byte unsigned) タイプ
//   オフセットに応じたバイトを取り出し，上位に0を詰める．
// * H(half word) タイプ
//   オフセットに応じたハーフワード(16ビット)を取り出し，符号拡張を行う．
// * HU(half word unsigned) タイプ
//   オフセットに応じたハーフワード(16ビット)を取り出し，上位に0を詰める．
// * W(word) タイプ
//   そのままの値を返す．
//
// B, BU, H, HU, W タイプの判別は IR レジスタの内容で行う．
//
// [入出力]
// in:     入力(32ビット)
// ir:     IRレジスタの値
// offset: アドレスオフセット
// out:    出力(32ビット)
module ldconv(input [31:0] in,
				  input [31:0] ir,
				  input [1:0] offset,
				  output [31:0] out);
	wire [4:0] shamt_byte = offset << 3; // offset * 8
	wire [4:0] shamt_half = offset[1] << 4; // offset[1] * 16
	wire [7:0] byte = in >> shamt_byte;
	wire [15:0] half = in >> shamt_half;
	function [31:0] conv(input [2:0] funct3,
								input [7:0] f_byte,
								input [15:0] f_half,
								input [31:0] f_word);
		case(funct3)
		3'b000: conv = {{24{f_byte[7]}}, f_byte[7:0]};   //LB
		3'b001: conv = {{16{f_half[15]}}, f_half[15:0]}; //LH
		3'b010: conv = f_word; //LW
		3'b100: conv = {24'b0, f_byte}; //LBU
		3'b101: conv = {16'b0, f_half}; //LHU
		endcase
	endfunction
	assign out = conv(ir[14:12], byte, half, in);
endmodule // ldconv
