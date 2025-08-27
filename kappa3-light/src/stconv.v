
// @file stconv.v
// @breif stconv(ストアデータ変換器)
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// ストア命令用のデータ変換を行う．
// wrbits が1のビットの部分のみ書き込みを行う．
// 具体的には以下の処理を行う．
//
// * B(byte) タイプ
//   in の下位8ビットを4つ複製する．
// * H(half word) タイプ
//   in の下位16ビットを2つ複製する．
// * W(word) タイプ
//   out は in をそのまま．
//
// B, H, W タイプの判別は IR レジスタの内容で行う．
//
// [入出力]
// in:     入力(32ビット)
// ir:     IRレジスタの値
// out:    出力(32ビット)
module stconv(input [31:0] in,
				  input [31:0] ir,
				  output [31:0] out);
	function [31:0] conv(input [2:0] funct3,
								input [31:0] f_in);
		case(funct3)
		3'b000: conv = {4{f_in[7:0]}};  //SB
		3'b001: conv = {2{f_in[15:0]}}; //SH
		3'b010: conv = f_in;            //SW
		endcase
	endfunction
	assign out = conv(ir[14:12], in);
endmodule // stconv
