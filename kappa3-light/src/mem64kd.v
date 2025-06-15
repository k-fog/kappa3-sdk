module mem64kd (
    input  [13:0] address_a,
    input  [13:0] address_b,
    input  [3:0]  byteena_a,
    input         clock,
    input  [31:0] data_a,
    input  [31:0] data_b,
    input         wren_a,
    input         wren_b,
    output reg [31:0] q_a,
    output reg [31:0] q_b
);

    reg [7:0] mem [0:65535];  // 64KB = 65536 bytes

    // Port A: Read/Write
    always @(posedge clock) begin
        if (wren_a) begin
            if (byteena_a[0]) mem[{address_a, 2'b00} + 0] <= data_a[7:0];
            if (byteena_a[1]) mem[{address_a, 2'b00} + 1] <= data_a[15:8];
            if (byteena_a[2]) mem[{address_a, 2'b00} + 2] <= data_a[23:16];
            if (byteena_a[3]) mem[{address_a, 2'b00} + 3] <= data_a[31:24];
        end
        q_a <= {
            mem[{address_a, 2'b00} + 3],
            mem[{address_a, 2'b00} + 2],
            mem[{address_a, 2'b00} + 1],
            mem[{address_a, 2'b00} + 0]
        };
    end

    // Port B: Read/Write
    always @(posedge clock) begin
        if (wren_b) begin
            // byteena_b
            mem[{address_b, 2'b00} + 0] <= data_b[7:0];
            mem[{address_b, 2'b00} + 1] <= data_b[15:8];
            mem[{address_b, 2'b00} + 2] <= data_b[23:16];
            mem[{address_b, 2'b00} + 3] <= data_b[31:24];
        end
        q_b <= {
            mem[{address_b, 2'b00} + 3],
            mem[{address_b, 2'b00} + 2],
            mem[{address_b, 2'b00} + 1],
            mem[{address_b, 2'b00} + 0]
        };
    end
endmodule