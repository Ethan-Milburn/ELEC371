#-----------------------------------------------------------------------------
# This template source file for ELEC 371 Lab 2 experimentation with interrupts
# also serves as the template for all assembly-language-level coding for
# Nios II interrupt-based programs in this course. *DO NOT USE* the approach
# shown in the vendor documentation for the DE0 Basic (or Media) Computer.
# The approach illustrated in this template file is far simpler for learning.
#
# Dr. N. Manjikian, Dept. of Elec. and Comp. Eng., Queen's University
#	
# (revised Sept. 2025 for startup code calling main routine and updated
#  comments/explanations for the code)	
#-----------------------------------------------------------------------------

	.text		# start a code segment (which will also included data)

	.global	_start	# export _start symbol for linker 

#-----------------------------------------------------------------------------
# Define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

    .equ    JTAG_UART_BASE,     0x10001000  # Address of first JTAG UART register
    .equ    DATA_OFFSET,        0           # Offset of JTAG UART data register
    .equ    STATUS_OFFSET,      4           # Offset of JTAG UART status register
    .equ    WSPACE_MASK,        0xFFFF      # Used in AND operation to check status


# mask/edge registers for pushbutton parallel port

	.equ	BUTTON_MASK, 0x10000058 
	.equ	BUTTON_EDGE, 0x1000005C	

# pattern corresponding to the bit assigned to button1 in the registers above

	.equ	BUTTON1, 0x10000051

# data register for LED parallel port

	.equ	LEDS, 0x10000010

#-----------------------------------------------------------------------------
# Define two branch instructions in specific locations at the start of memory
#-----------------------------------------------------------------------------

	.org	0x0000		# this is the _reset_ address 
_start:
	movia	sp, 0x007FFFFC	# initialize stack pointer
	call	main		# *call* the main() routine
	break			# terminate if there is a return from main()

	# The movia is 2 actual instructions, call is 1 instruction,
	#   and break is 1 instruction. Hence, (2+1+1) * 4 bytes/instruction
	#   is 16 bytes for the code above, or 0x10 in hexadecimal.
	# There is sufficient space without overlap for the code below
	#   that *must* be at the specified address.
	
	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# *branch* to start of interrupt service routine 
			#   (rather than placing all of the service code here) 

#-----------------------------------------------------------------------------
# The actual program code (incl. service routine) can be placed immediately
# after the second branch above, or another .org directive could be used
# to place the program code at a desired address (e.g., 0x0080). It does not
# matter because the _start symbol defines where execution begins, and the
# startup code at that location causes execution to reach the code below.
#-----------------------------------------------------------------------------

main:
	subi sp, sp, 20
	stw ra, 0(sp)
	stw r2, 4(sp)
	stw r3, 8(sp)
	stw r4, 12(sp)
	stw r5, 16(sp)
	
	??????		# save registers as appropriate
	
	??????		# call hw/sw initialization subroutine

	??????		# perform any local initialization of gen.-purpose regs.
			#   before entering main loop 

main_loop:

	??????		# body of main loop (reflecting typical embedded
			#   software organization where execution does not
			#   terminate)

	br main_loop

	# even though we have an infinite loop,
	# complete the remainder of a proper subroutine

	ldw ra, 0(sp)
	ldw r2, 4(sp)
	ldw r3, 8(sp)
	ldw r4, 12(sp)
	ldw r5, 16(sp)
	addi sp, sp, 20
	ret


	
#-----------------------------------------------------------------------------
# This subroutine should encompass preparation of I/O registers as well as
# special processor registers for recognition and processing of interrupt
# requests. Initialization of data variables in memory can also be done here.
#-----------------------------------------------------------------------------

Init:				# make it *modular* -- save/restore registers

	??????			# body of Init() subroutine

	ret

#-----------------------------------------------------------------------------
# The code for the interrupt service routine is below. Note that the branch
# instruction at 0x0020 is executed first upon recognition of interrupts,
# and that branch brings the flow of execution to the code below. Therefore,
# the actual code for this routine can be anywhere in memory for convenience
# (more precisely, anywhere that can be reached by the offset in the branch).
# This template involves only hardware-generated interrupts. Therefore, the
# return-address adjustment on the ea register is performed unconditionally.
# Programs with software-generated interrupts must check for hardware sources
# to conditionally adjust the ea register (no adjustment for s/w interrupts).
#-----------------------------------------------------------------------------

isr:
	??????			# save register values, *except* ea which
				#   must be adjusted for hardware interrupts

	subi	ea, ea, 4	# ea adjustment required for h/w interrupts

	??????			# body of interrupt service routine
				#   (use the proper approach for checking
				#    different interrupt sources,
				#    even when there is a single course)

	??????			# restore register values
	
	eret			# interrupt service routines end _differently_
				#   than subroutines -- execution must return
				#   to point in main program where interrupt
				#   request caused invocation of service routine
	
#-----------------------------------------------------------------------------
# Definitions for program data, usually global variables, but where necessary
# there can also be some variables local to only one subroutine whose values
# must be preserved across calls to that subroutine. Global variables include
# any that are used to convey information between the main program and the
# interrupt code (incl. special subroutines called from interrupt code).	
#-----------------------------------------------------------------------------

	.org	0x1000		# start should be fine for most small programs
				
?????:	???	???		# define/reserve storage for program data

	.end
