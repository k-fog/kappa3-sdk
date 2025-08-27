module keyenc(input [15:0] keys,
				  output key_in,
				  output [3:0] key_val);
	function [3:0] enc(input [15:0] f_keys);
	begin
		casex(f_keys)
		16'b1xxx_xxxx_xxxx_xxxx: enc = 4'hf;
		16'b01xx_xxxx_xxxx_xxxx: enc = 4'he;
		16'b001x_xxxx_xxxx_xxxx: enc = 4'hd;
		16'b0001_xxxx_xxxx_xxxx: enc = 4'hc;
		16'b0000_1xxx_xxxx_xxxx: enc = 4'hb;
		16'b0000_01xx_xxxx_xxxx: enc = 4'ha;
		16'b0000_001x_xxxx_xxxx: enc = 4'h9;
		16'b0000_0001_xxxx_xxxx: enc = 4'h8;
		16'b0000_0000_1xxx_xxxx: enc = 4'h7;
		16'b0000_0000_01xx_xxxx: enc = 4'h6;
		16'b0000_0000_001x_xxxx: enc = 4'h5;
		16'b0000_0000_0001_xxxx: enc = 4'h4;
		16'b0000_0000_0000_1xxx: enc = 4'h3;
		16'b0000_0000_0000_01xx: enc = 4'h2;
		16'b0000_0000_0000_001x: enc = 4'h1;
		16'b0000_0000_0000_0001: enc = 4'h0;
		default                : enc = 4'hx;
		endcase
	end
	endfunction
	
	assign key_in = (keys > 0);
	assign key_val = enc(keys);
endmodule