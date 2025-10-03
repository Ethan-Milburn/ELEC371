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

    movia	r2,	LIST
    ldw     r3, N(r0)
    ldw     r4, VAL(r0)
    call    ShowByteList

    call    LimitByteList

    call    ShowByteList
    
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

ShowByteList:
    subi    sp, sp, 20
    stw     ra, 0(sp)
	stw     r2, 4(sp) #LIST pointer
    stw     r3, 8(sp) #N
	stw     r4, 12(sp)
    stw     r5, 16(sp) 
	
    mov     r4, r2  #Move list pointr into r4
sbl_loop:
    movi    r2, '('
    call    PrintChar

    ldbu    r2, 0(r4)
    call    PrintHexByte

    movi    r2, ')'
    call    PrintChar

    movi    r5, 1
    bgt     r3, r5, sbl_if
    br      sbl_else
sbl_if:
    movi    r2, ','
    call    PrintChar
    br      sbl_end_if
sbl_else:
    movi    r2, '\n'
    call    PrintChar
    br      sbl_end_if
sbl_end_if:

    subi    r3, r3, 1
    addi    r4, r4, 1
    bgt     r3, r0, sbl_loop

sbl_loop_end:    

    ldw     ra, 0(sp)
	ldw 	r2, 4(sp)
    ldw     r3, 8(sp)         # Restore r3
	ldw     r4, 12(sp)        
	ldw     r5, 16(sp)
    addi    sp, sp, 20
    ret

LimitByteList:
    subi    sp, sp, 20
    stw     ra, 0(sp)
	stw     r2, 4(sp) #LIST pointer
    stw     r3, 8(sp) #N
	stw     r4, 12(sp)
    stw     r5, 16(sp) 

lbl_loop:
    ldbu    r5, 0(r2)
    bgt     r5, r4, lbl_if
    br      lbl_end_if
lbl_if:
    stb     r4, 0(r2)
    br      lbl_end_if
lbl_end_if:

    subi    r3, r3, 1
    addi    r2, r2, 1
    bgt     r3, r0, lbl_loop

lbl_loop_end:    


    ldw     ra, 0(sp)
	ldw 	r2, 4(sp)
    ldw     r3, 8(sp)         # Restore r3
	ldw     r4, 12(sp)        
	ldw     r5, 16(sp)
    addi    sp, sp, 20
    ret



    .org		0x1000
N:	    .word 4
LIST:   .byte 0x4A, 0xC9, 0xA8, 0x63

        
        
        
        
        
        
    
	