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

	.equ	BUTTON1, 0x2

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
    # save registers as appropriate
	subi sp, sp, 20
	stw ra, 0(sp)
	stw r2, 4(sp)
	stw r3, 8(sp)
	stw r4, 12(sp)
	stw r5, 16(sp)
	
    movia	r2,	TEXT
    call    PrintString

	call    Init		# call hw/sw initialization subroutine

			# perform any local initialization of gen.-purpose regs.
			#   before entering main loop 

main_loop:

    		# body of main loop (reflecting typical embedded
			#   software organization where execution does not
			#   terminate)

    movia r3, COUNT   # address of count variable
    ldw r2, 0(r3)     # load count from address in r5
    addi r2, r2, 1    # increment
    stw r2, 0(r3)     # store back

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

PrintChar:
    subi    sp, sp, 8
    stw     r3, 4(sp)
    stw     r4, 0(sp)
    movia   r3, JTAG_UART_BASE
pc_loop:
    ldwio   r4, STATUS_OFFSET(r3)
    andhi   r4, r4, WSPACE_MASK
    beq     r4, r0, pc_loop
    stwio   r2, DATA_OFFSET(r3)
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 8
    ret

PrintString:
    subi    sp, sp, 12
    stw     ra, 0(sp)
	stw     r2, 4(sp)
    stw     r3, 8(sp)

	mov		r3, r2
ps_loop:
    ldb     r2, 0(r3)         # Load one byte (character) from address in r2
    beq     r2, r0, ps_end    # If null terminator, exit loop

    call    PrintChar         # Print the character
    
    addi    r3, r3, 1         # Move to next byte
    br      ps_loop           # Repeat the loop

ps_end:
    ldw     ra, 0(sp)
	ldw 	r2, 4(sp)
    ldw     r3, 8(sp)         # Restore r3
    addi    sp, sp, 12
    ret
	
#-----------------------------------------------------------------------------
# This subroutine should encompass preparation of I/O registers as well as
# special processor registers for recognition and processing of interrupt
# requests. Initialization of data variables in memory can also be done here.
#-----------------------------------------------------------------------------

Init:				# make it *modular* -- save/restore registers
    subi    sp, sp, 12
    stw     ra, 0(sp)
	stw     r2, 4(sp)
    stw     r3, 8(sp)

    # (a) initialize software variables
    movia   r2, COUNT     # address of your counter variable
    stw     r0, 0(r2)     # count = 0

    # (b) initialize I/O interface
    movia   r2, BUTTON_MASK   # base address of button PIO
    movia   r3, 0x2           # mask for button 1
    stwio     r3, 0(r2)         # write to Interrupt Mask register

    # (c) enable interrupt in ienable
    movia   r2, 0x2           # bit for IRQ line of buttons (check system.h or BSP)
    wrctl   ienable, r2

    # (d) enable global interrupt in status
    movi    r2, 0x1           # PIE bit = 1
    wrctl   status, r2

    ldw     ra, 0(sp)
	ldw 	r2, 4(sp)
    ldw     r3, 8(sp)         # Restore r3
    addi    sp, sp, 12
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
    subi    sp, sp, 16
    stw     ra, 0(sp)
	stw     r2, 4(sp)
    stw     r3, 8(sp)
    stw     r4, 12(sp) 
    			# save register values, *except* ea which
				#   must be adjusted for hardware interrupts

	subi	ea, ea, 4	# ea adjustment required for h/w interrupts

			    # body of interrupt service routine
				#   (use the proper approach for checking
				#    different interrupt sources,
				#    even when there is a single course)

    rdctl   r2, ipending  # read ipending into r2

# check_IO:
#     movia   r3, 0x80000000
#     and     r3, r2, r3                # r4 ← r2 & mask
#     beq     r3, r0, check_BUTTON      # if zero, no I/O IRQ

check_BUTTON:
    # --- check for button interrupt ---
    movia   r3, 0x2
    and     r3, r2, r3             
    beq     r3, r0, check_END      # if zero, no button IRQ

handle_BUTTON:
    # handle button interrupt here
    movia     r4, BUTTON_EDGE
    ldwio     r3, 0(r4)               # read edge capture
    stwio     r3, 0(r4)               # write back to clear it

    # increment LED pattern
    movia   r4, LEDS
    ldwio   r3, 0(r4)               # read current LED value
    xori    r3, r3, 1               # keep it within 8 bits
    stwio   r3, 0(r4)               # write back to LEDs


check_END:
    ldw     ra, 0(sp)
	ldw 	r2, 4(sp)
    ldw     r3, 8(sp)         # Restore r3
    ldw     r4, 12(sp)               # read edge capture again to ensure it's cleared
    addi    sp, sp, 16

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
COUNT: .word
TEXT: .asciz "ELEC 371 Lab 2 by Ethan Divine Sebastian\n"

	.end
