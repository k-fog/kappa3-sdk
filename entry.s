    .section .text
    .globl _start
_start:
    la sp, stack_top      # スタックポインタを初期化
    call main             # main() を呼び出す
    j .

    .section .bss
    .align 4
    .space 1024
stack_top: