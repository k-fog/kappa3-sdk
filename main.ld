ENTRY(_start)

SECTIONS
{
  . = 0x10000000;
  .text : { 
      KEEP(*(.text._start))
      *(.text)
  }
  . = 0x1000F000;
  .data : { *(.data) }
  .bss : { *(.bss) }
}
