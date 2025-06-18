
module instruction_tester;
    reg clock, clock2;
    reg reset;
    reg run;
    reg step_phase;
    reg step_inst;

    reg [31:0] dbg_in;
    reg        dbg_pc_ld;
    reg        dbg_ir_ld;
    reg        dbg_reg_ld;
    reg [4:0]  dbg_reg_addr;
    reg        dbg_a_ld;
    reg        dbg_b_ld;
    reg        dbg_c_ld;
    reg [31:0] dbg_mem_addr;
    reg        dbg_mem_read;
    reg        dbg_mem_write;

    wire [3:0]  cstate;
    wire        running;
    wire [31:0] dbg_pc_out;
    wire [31:0] dbg_ir_out;
    wire [31:0] dbg_reg_out;
    wire [31:0] dbg_a_out;
    wire [31:0] dbg_b_out;
    wire [31:0] dbg_c_out;
    wire [31:0] dbg_mem_out;

    kappa3_light_core k3l_core (
        .clock(clock),
        .clock2(clock2),
        .reset(reset),
        .run(run),
        .step_phase(step_phase),
        .step_inst(step_inst),
        .cstate(cstate),
        .running(running),
        .dbg_in(dbg_in),
        .dbg_pc_ld(dbg_pc_ld),
        .dbg_ir_ld(dbg_ir_ld),
        .dbg_reg_ld(dbg_reg_ld),
        .dbg_reg_addr(dbg_reg_addr),
        .dbg_a_ld(dbg_a_ld),
        .dbg_b_ld(dbg_b_ld),
        .dbg_c_ld(dbg_c_ld),
        .dbg_mem_addr(dbg_mem_addr),
        .dbg_mem_read(dbg_mem_read),
        .dbg_mem_write(dbg_mem_write),
        .dbg_pc_out(dbg_pc_out),
        .dbg_ir_out(dbg_ir_out),
        .dbg_reg_out(dbg_reg_out),
        .dbg_a_out(dbg_a_out),
        .dbg_b_out(dbg_b_out),
        .dbg_c_out(dbg_c_out),
        .dbg_mem_out(dbg_mem_out)
    );

    initial clock = 0;
    always #5 clock = ~clock;

    initial clock2 = 0;
    always @(posedge clock) clock2 <= ~clock2;

    task read_pc;
        begin
            $display("pc=%h", dbg_pc_out);
        end
    endtask

    task write_pc(input [31:0] addr);
        begin
            dbg_in = addr;
            #10 dbg_pc_ld = 1;
            #10 dbg_pc_ld = 0;
            #20;
        end
    endtask

    task read_mem(input [31:0] addr);
        begin
            dbg_mem_addr = addr;
            #10 dbg_mem_read = 1;
            #10 dbg_mem_read = 0;
            #20;
            $display("M[%h]=%h", addr, dbg_mem_out);
        end
    endtask

    task write_mem(input [31:0] addr, input [31:0] data);
        begin
            dbg_in = data;
            dbg_mem_addr = addr;
            #10 dbg_mem_write = 1;
            #10 dbg_mem_write = 0;
            #20;
        end
    endtask

    task read_reg(input [4:0] reg_addr);
        begin
            dbg_reg_addr = reg_addr;
            #10;
            $display("x%02d=%h", reg_addr, dbg_reg_out);
        end
    endtask

    task write_reg(input [4:0] reg_addr, input [31:0] data);
        begin
            dbg_in = data;
            dbg_reg_addr = reg_addr;
            #10 dbg_reg_ld = 1;
            #10 dbg_reg_ld = 0;
            #20;
        end
    endtask

    task print_state;
        begin
            read_pc();
            read_reg(5'b00000); // x0
            read_reg(5'b00001); // x1
            read_reg(5'b00010); // x2
            read_reg(5'b00011); // x3
            read_reg(5'b00100); // x4
            read_reg(5'b00101); // x5
            read_reg(5'b00110); // x6
            read_reg(5'b00111); // x7
            read_reg(5'b01000); // x8
            read_reg(5'b01001); // x9
            read_reg(5'b01010); // x10
            read_reg(5'b01011); // x11
            read_reg(5'b01100); // x12
            read_reg(5'b01101); // x13
            read_reg(5'b01110); // x14
            read_reg(5'b01111); // x15
            read_reg(5'b10000); // x16
            read_reg(5'b10001); // x17
            read_reg(5'b10010); // x18
            read_reg(5'b10011); // x19
            read_reg(5'b10100); // x20
            read_reg(5'b10101); // x21
            read_reg(5'b10110); // x22
            read_reg(5'b10111); // x23
            read_reg(5'b11000); // x24
            read_reg(5'b11001); // x25
            read_reg(5'b11010); // x26
            read_reg(5'b11011); // x27
            read_reg(5'b11100); // x28
            read_reg(5'b11101); // x29
            read_reg(5'b11110); // x30
            read_reg(5'b11111); // x31
        end
    endtask

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, instruction_tester);

        // initialization
        reset = 1;
        run = 0;
        step_phase = 0;
        step_inst = 0;

        dbg_in = 0;
        dbg_pc_ld = 0;
        dbg_ir_ld = 0;
        dbg_reg_ld = 0;
        dbg_reg_addr = 0;
        dbg_a_ld = 0;
        dbg_b_ld = 0;
        dbg_c_ld = 0;
        dbg_mem_addr = 0;
        dbg_mem_read = 0;
        dbg_mem_write = 0;

        #10 reset = 0;
        #5 reset = 1;

        // load test instruction
        `include "test_instruction.vh"

        // run the test instruction
        #10 step_inst = 1;
        #10 step_inst = 0;

        #200;
        print_state();

        `ifdef MEMOUT
            `include "memout.vh"
        `endif
        $finish;
    end
endmodule