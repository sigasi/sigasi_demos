/*
 NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
 This is an automatically generated file by titouanvervack on Mon Dec  6 20:49:22 PST 2021

 cmd:    swerv  

*/

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text.init .  : { *(.text.init) }
   . = 0xee000000 ;
  .text . : { *(.text) }
  _end = .;
  . = 0xd0580000;
  .data.io .  : { *(.data.io) }
    . = 0xf0040000 ;
  .data  :  ALIGN(0x800) { *(.*data) *(.rodata*) STACK = ALIGN(16) + 0x8000; }
  .bss : { *(.bss) }
    . = 0xfffffff0; .iccm.ctl . : { LONG(0xee000000); LONG(0xee00ffff) }
    . = 0xfffffff8; .data.ctl : { LONG(0xf0040000); LONG(STACK) }
}

