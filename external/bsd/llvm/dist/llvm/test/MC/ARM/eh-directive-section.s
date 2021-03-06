@ RUN: llvm-mc %s -triple=armv7-unknown-linux-gnueabi -filetype=obj -o - \
@ RUN:   | llvm-readobj -s -sd -sr -t | FileCheck %s

@ Check the combination of .section, .fnstart, and .fnend directives.

@ For the functions in .text section, the exception handling index (EXIDX)
@ should be generated in .ARM.exidx, and the exception handling table (EXTAB)
@ should be generated in .ARM.extab.

@ For the functions in custom section specified by .section directives,
@ the EXIDX should be generated in ".ARM.exidx[[SECTION_NAME]]", and the EXTAB
@ should be generated in ".ARM.extab[[SECTION_NAME]]".

	.syntax	unified

@-------------------------------------------------------------------------------
@ .TEST1 section
@-------------------------------------------------------------------------------
	.section	.TEST1
	.globl	func1
	.align	2
	.type	func1,%function
	.fnstart
func1:
	bx	lr
	.personality	__gxx_personality_v0
	.handlerdata
	.fnend


@-------------------------------------------------------------------------------
@ TEST2 section (without the dot in the beginning)
@-------------------------------------------------------------------------------
	.section	TEST2
	.globl	func2
	.align	2
	.type	func2,%function
	.fnstart
func2:
	bx	lr
	.personality	__gxx_personality_v0
	.handlerdata
	.fnend


@-------------------------------------------------------------------------------
@ Check the .TEST1 section.
@-------------------------------------------------------------------------------
@ CHECK: Sections [
@ CHECK:   Section {
@ CHECK:     Index: 4
@ CHECK:     Name: .TEST1
@ CHECK:     SectionData (
@ CHECK:       0000: 1EFF2FE1                             |../.|
@ CHECK:     )
@ CHECK:   }

@-------------------------------------------------------------------------------
@ Check the .ARM.extab.TEST1 section, the EXTAB of .TEST1 section.
@-------------------------------------------------------------------------------
@ CHECK:   Section {
@ CHECK:     Name: .ARM.extab.TEST1
@ CHECK:     SectionData (
@ CHECK:       0000: 00000000 B0B0B000                    |........|
@ CHECK:     )
@ CHECK:   }
@ CHECK:     Relocations [
@ CHECK:       0x0 R_ARM_PREL31 __gxx_personality_v0 0x0
@ CHECK:     ]


@-------------------------------------------------------------------------------
@ Check the.ARM.exidx.TEST1 section, the EXIDX of .TEST1 section.
@-------------------------------------------------------------------------------
@ CHECK:   Section {
@ CHECK:     Name: .ARM.exidx.TEST1

@-------------------------------------------------------------------------------
@ This section should linked with .TEST1 section.
@-------------------------------------------------------------------------------
@ CHECK:     Link: 4

@-------------------------------------------------------------------------------
@ The first word should be relocated to the code address in .TEST1 section.
@ The second word should be relocated to the EHTAB entry in .ARM.extab.TEST1
@ section.
@-------------------------------------------------------------------------------
@ CHECK:     SectionData (
@ CHECK:       0000: 00000000 00000000                    |........|
@ CHECK:     )
@ CHECK:   }
@ CHECK:     Relocations [
@ CHECK:       0x0 R_ARM_PREL31 .TEST1 0x0
@ CHECK:       0x4 R_ARM_PREL31 .ARM.extab.TEST1 0x0
@ CHECK:     ]


@-------------------------------------------------------------------------------
@ Check the TEST2 section (without the dot in the beginning)
@-------------------------------------------------------------------------------
@ CHECK:   Section {
@ CHECK:     Index: 9
@ CHECK:     Name: TEST2
@ CHECK:     SectionData (
@ CHECK:       0000: 1EFF2FE1                             |../.|
@ CHECK:     )
@ CHECK:   }

@-------------------------------------------------------------------------------
@ Check the .ARM.extabTEST2 section, the EXTAB of TEST2 section.
@-------------------------------------------------------------------------------
@ CHECK:   Section {
@ CHECK:     Name: .ARM.extabTEST2
@ CHECK:     SectionData (
@ CHECK:       0000: 00000000 B0B0B000                    |........|
@ CHECK:     )
@ CHECK:   }
@ CHECK:     Relocations [
@ CHECK:       0x0 R_ARM_PREL31 __gxx_personality_v0 0x0
@ CHECK:     ]


@-------------------------------------------------------------------------------
@ Check the .ARM.exidxTEST2 section, the EXIDX of TEST2 section.
@-------------------------------------------------------------------------------
@ CHECK:   Section {
@ CHECK:     Name: .ARM.exidxTEST2

@-------------------------------------------------------------------------------
@ This section should linked with TEST2 section.
@-------------------------------------------------------------------------------
@ CHECK:     Link: 9

@-------------------------------------------------------------------------------
@ The first word should be relocated to the code address in TEST2 section.
@ The second word should be relocated to the EHTAB entry in .ARM.extabTEST2
@ section.
@-------------------------------------------------------------------------------
@ CHECK:     SectionData (
@ CHECK:       0000: 00000000 00000000                    |........|
@ CHECK:     )
@ CHECK:   }
@ CHECK: ]
@ CHECK:     Relocations [
@ CHECK:       0x0 R_ARM_PREL31 TEST2 0x0
@ CHECK:       0x4 R_ARM_PREL31 .ARM.extabTEST2 0x0
@ CHECK:     ]



@-------------------------------------------------------------------------------
@ Check the symbols and the sections they belong to
@-------------------------------------------------------------------------------
@ CHECK: Symbols [
@ CHECK:   Symbol {
@ CHECK:     Name: func1
@ CHECK:     Section: .TEST1 (0x4)
@ CHECK:   }
@ CHECK:   Symbol {
@ CHECK:     Name: func2
@ CHECK:     Section: TEST2 (0x9)
@ CHECK:   }
@ CHECK: ]
