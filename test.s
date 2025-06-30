    .section .text
    .globl _start
_start:
    lui   x5, 0x4000        # x5 = 0x4000000
    addi  x10, x0, 0x60      # x10 = 0x60
loop:
    sb    x5, 0(x10)         # store byte (x5) to mem[x10]
    jal   x0, loop

    .section .bss
    .align 4
    .space 1024
stack_top:
