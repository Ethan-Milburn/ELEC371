    .equ    JTAG_UART_BASE,     0x10001000  # Address of first JTAG UART register
    .equ    DATA_OFFSET,        0           # Offset of JTAG UART data register
    .equ    STATUS_OFFSET,      4           # Offset of JTAG UART status register
    .equ    WSPACE_MASK,        0xFFFF      # Used in AND operation to check status
    
    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    call	main
    break

main:
    subi    sp, sp, 4
    stw     ra, 0(sp)

    movia	r2,	NUM
	ldw   	r2, 0(r2)      # Load the actual value from memory
    call    PrintHexByte
    
    ldw     ra, 0(sp)
    addi    sp, sp, 4
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

PrintHexDigit:
    subi    sp, sp, 12
    stw     ra, 0(sp)
	stw     r2, 4(sp)
    stw     r3, 8(sp)

	movi	r3, 9
	ble		r2, r3, phd_if
	br		phd_else
phd_if:
	addi	r2,r2,48
	br 		phd_end
phd_else:
	addi	r2,r2,55
	br 		phd_end
phd_end:

    call    PrintChar         # Print the character
	
    ldw     ra, 0(sp)
	ldw 	r2, 4(sp)
    ldw     r3, 8(sp)         # Restore r3
    addi    sp, sp, 12
    ret
	
PrintHexByte:
    subi    sp, sp, 12
    stw     ra, 0(sp)
    stw     r2, 4(sp)
    stw     r3, 8(sp)

	mov		r3, r2
    srli    r2, r3, 4        # Shift right by 4 to get the high nibble
    call    PrintHexDigit

    andi    r2, r3, 0xF      
    call    PrintHexDigit

    ldw     ra, 0(sp)
    ldw     r2, 4(sp)
    ldw     r3, 8(sp)
    addi    sp, sp, 12
    ret

	
    .org		0x1000
NUM:	.word	206


        
        
        
        
        
        
    