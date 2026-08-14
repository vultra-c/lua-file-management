/****************************************************************************
 * payload/gnu-elf.ld
 *
 * NuttX 10.3.0 binfmt/libelf/gnu-elf.ld（Apache-2.0，原样收录）。
 * 模块（ET_REL）链接脚本：把 .text/.rodata/.data/.ctors/.dtors/.bss
 * 排成 modlib 期望的顺序。本仓库用它 + arm-none-eabi-ld -r 构建 module.ko。
 ****************************************************************************/

SECTIONS
{
  .text 0x00000000 :
    {
      _stext = . ;
      *(.text)
      *(.text.*)
      *(.gnu.warning)
      *(.stub)
      *(.glue_7)
      *(.glue_7t)
      *(.jcr)

      /* C++ support:  The .init and .fini sections contain specific logic
       * to manage static constructors and destructors.
       */

      *(.gnu.linkonce.t.*)
      *(.init)             /* Old ABI */
      *(.fini)             /* Old ABI */
      _etext = . ;
    }

  .rodata :
    {
      _srodata = . ;
      *(.rodata)
      *(.rodata1)
      *(.rodata.*)
      *(.gnu.linkonce.r*)
      _erodata = . ;
    }

  .data :
    {
      _sdata = . ;
      *(.data)
      *(.data1)
      *(.data.*)
      *(.gnu.linkonce.d*)
      . = ALIGN(4);
      _edata = . ;
    }

  /* C++ support. For each global and static local C++ object,
   * GCC creates a small subroutine to construct the object. Pointers
   * to these routines (not the routines themselves) are stored as
   * simple, linear arrays in the .ctors section of the object file.
   * Similarly, pointers to global/static destructor routines are
   * stored in .dtors.
   */

  .ctors :
    {
      _sctors = . ;
      *(.ctors)       /* Old ABI:  Unallocated */
      *(.init_array)  /* New ABI:  Allocated */
      _ectors = . ;
    }

  .dtors :
    {
      _sdtors = . ;
      *(.dtors)       /* Old ABI:  Unallocated */
      *(.fini_array)  /* New ABI:  Allocated */
      _edtors = . ;
    }

  .bss :
    {
      _sbss = . ;
      *(.bss)
      *(.bss.*)
      *(.sbss)
      *(.sbss.*)
      *(.gnu.linkonce.b*)
      *(COMMON)
      _ebss = . ;
    }

    /* Stabs debugging sections.    */

    .stab 0 : { *(.stab) }
    .stabstr 0 : { *(.stabstr) }
    .stab.excl 0 : { *(.stab.excl) }
    .stab.exclstr 0 : { *(.stab.exclstr) }
    .stab.index 0 : { *(.stab.index) }
    .stab.indexstr 0 : { *(.stab.indexstr) }
    .comment 0 : { *(.comment) }
    .debug_abbrev 0 : { *(.debug_abbrev) }
    .debug_info 0 : { *(.debug_info) }
    .debug_line 0 : { *(.debug_line) }
    .debug_pubnames 0 : { *(.debug_pubnames) }
    .debug_aranges 0 : { *(.debug_aranges) }
}
