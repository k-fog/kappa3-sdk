module decode_7seg(input [3:0] in, output [7:0] out);
	function [7:0] decoder;
	input [3:0] f_in;
	begin
		case (f_in) 
			4'b0000: decoder = 8'b1111_1100; // 0
			4'b0001: decoder = 8'b0110_0000; // 1
			4'b0010: decoder = 8'b1101_1010; // 2
			4'b0011: decoder = 8'b1111_0010; // 3
			4'b0100: decoder = 8'b0110_0110; // 4
			4'b0101: decoder = 8'b1011_0110; // 5
			4'b0110: decoder = 8'b1011_1110; // 6
			4'b0111: decoder = 8'b1110_0000; // 7
			4'b1000: decoder = 8'b1111_1110; // 8
			4'b1001: decoder = 8'b1111_0110; // 9
			4'b1010: decoder = 8'b1110_1110; // a
			4'b1011: decoder = 8'b0011_1110; // b
			4'b1100: decoder = 8'b0001_1010; // c
			4'b1101: decoder = 8'b0111_1010; // d
			4'b1110: decoder = 8'b1001_1110; // e
			4'b1111: decoder = 8'b1000_1110; // f
		endcase
	end
	endfunction
	
	assign out = decoder(in);
endmodule