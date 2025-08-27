module keybuf(input clock,
				  input reset,
				  input key_in,
				  input [3:0] key_val,
				  input clear,
				  output reg [31:0] out);
	always @(posedge clock or negedge reset)
	begin
		if (!reset) out <= 32'b0;
		else begin
			if (clear == 1) out <= 32'b0;
			else if (key_in == 1) out <= (out << 4) | key_val;
		end
	end
endmodule