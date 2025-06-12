SECTIONS
{
  . = 0x10000000;
  .text : { *(.text) }
  . = 0x1000F000;
  .data : { *(.data) }
  .bss : { *(.bss) }
}
