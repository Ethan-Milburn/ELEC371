    .equ    JTAG_UART_BASE,     0x10001000  # Address of first JTAG UART register
    .equ    DATA_OFFSET,        0           # Offset of JTAG UART data register
    .equ    STATUS_OFFSET,      4           # Offset of JTAG UART status register
    .equ    WSPACE_MASK,        0xFFFF      # Used in AND operation to check status

	.equ 	SWITCH, 			0x10000040 	# Switch is in bit 9
.text
.global _start
.org 0x0000

_start:
	movia sp, 0x007FFFFC
	call main
	break
	
	
# r2 = input, r3 = current, r4 = new
main:

	subi sp, sp, 20
	stw ra, 0(sp)
	stw r2, 4(sp)
	stw r3, 8(sp)
	stw r4, 12(sp)
	stw r5, 16(sp)
	
	movi r2, '.'
	call PrintChar
	
	mov r3, r0
	mov r2, r3
	call PrintSwitchStatus

main_loop_start:
	movia r5, SWITCH
	ldwio r4, 0(r5)
	srli r4, r4, 9
	andi r4, r4, 0x0001

main_if:
	beq r3, r4, main_endif
	mov r3, r4
	mov r2, r3
	call PrintSwitchStatus
	
main_endif:

	br main_loop_start

#main_loop_end:

	ldw ra, 0(sp)
	ldw r2, 4(sp)
	ldw r3, 8(sp)
	ldw r4, 12(sp)
	ldw r5, 16(sp)
	addi sp, sp, 20
	ret


PrintChar:
	subi 	sp, sp, 8
	stw 	r3, 4(sp)
	stw 	r4, 0(sp)
	movia 	r3, JTAG_UART_BASE
pc_loop:
	ldwio 	r4, STATUS_OFFSET(r3)
	andhi 	r4, r4, WSPACE_MASK
	beq 	r4, r0, pc_loop
	stwio 	r2, (r3)DATA_OFFSET
    ldw 	r3, 4(sp)
	ldw 	r4, 0(sp)
	addi 	sp, sp, 8
	ret

PrintSwitchStatus:
	subi 	sp, sp, 16
	stw 	ra, 0(sp)
	stw 	r2, 4(sp)
	stw 	r3, 8(sp)
	stw 	r4, 12(sp)
	movi 	r4, 1
	mov 	r3, r2
	movi 	r2, '\b'
	call 	PrintChar
pss_if:
	bne 	r3, r4, pss_else
 
pss_then:
	movi 	r2, '^'
	call 	PrintChar
	br 		pss_end_if
 
pss_else:
	movi 	r2, '.'
	call 	PrintChar
pss_end_if:
	ldw		ra, 0(sp)
	ldw 	r2, 4(sp)
	ldw 	r3, 8(sp)
	ldw 	r4, 12(sp)
	addi 	sp, sp, 16
	ret


.org 0x1000
LIST: .byte 0x4A, 0xC9, 0xA8, 0x63
N:    .word 4

.end