
// @file phasegen.v
// @breif フェーズジェネレータ
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// 命令フェイズを生成する．
//
// cstate = {cs_wb, cs_ex, cs_de, cs_if}
// で，常に1つのビットのみ1になっている．
// cs_wb = cstate[3], cs_if = cstate[0]
// であることに注意．
// 各ビットの意味は以下の通り．
// cs_if: IF フェーズ
// cs_de: DE フェーズ
// cs_ex: EX フェーズ
// cs_wb: WB フェーズ
//
// [入出力]
// clock:      クロック信号(立ち上がりエッジ)
// reset:      リセット信号(0でリセット)
// run:        実行開始
// step_phase: 1フェイズ実行
// step_inst:  1命令実行
// cstate:     命令実行フェーズを表すビットベクタ
// running:    実行中を表す信号
module phasegen(input  	     clock,
		input 	     reset,
		input 	     run,
		input 	     step_phase,
		input 	     step_inst,
		output [3:0] cstate,
		output      running);
	reg cs_wb, cs_ex, cs_de, cs_if;
	reg [1:0] state;
	parameter STOP = 2'b00;
	parameter RUN = 2'b01;
	parameter STEP_INST = 2'b10;
	parameter STEP_PHASE = 2'b11;
		
	always @(posedge clock or negedge reset)
	begin
		if (!reset) begin
			{cs_wb, cs_ex, cs_de, cs_if} <= 4'b0001;
			state <= STOP;
		end
		else begin
			case (state)
			STOP: begin
						if (run) state <= RUN;
						else if (step_inst) state <= STEP_INST;
						else if (step_phase) state <= STEP_PHASE;
					end
			RUN:  begin
						if (run) state <= STOP;
						else {cs_wb, cs_ex, cs_de, cs_if} <= {cs_ex, cs_de, cs_if, cs_wb};
					end
			STEP_INST: begin
						if (cs_wb) begin
							{cs_wb, cs_ex, cs_de, cs_if} <= 4'b0001;
							state <= STOP;
						end
						else {cs_wb, cs_ex, cs_de, cs_if} <= {cs_ex, cs_de, cs_if, cs_wb};
					end
			STEP_PHASE: begin
						{cs_wb, cs_ex, cs_de, cs_if} <= {cs_ex, cs_de, cs_if, cs_wb};
						state <= STOP;
					end
			endcase
		end
	end
	
	assign cstate = {cs_wb, cs_ex, cs_de, cs_if};
	assign running = (state != STOP);
endmodule // phasegen
