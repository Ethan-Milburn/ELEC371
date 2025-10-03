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

    movia   r2, LIST
    ldw     r3, N(r0)

    call    SummarizeList
    
    ldw     ra, 0(sp)
    addi    sp, sp, 4

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

SummarizeList:
    subi    sp, sp, 12
    stw     ra, 8(sp) 
    stw     r2, 4(sp)
    stw     r3, 0(sp)

    mov     r4, r0
LOOPA:
    ldw     r5, 0(r2)
    mov     r6, r2
    beq 	r5, r0, zero_if
    blt     r5, r0, neg_if
    br	    pos_if
zero_if:
    movi    r2, '0'
    call    PrintChar
    br      end_if
neg_if:
    movi	r2, '-'
    call    PrintChar
    br      end_if
pos_if:
    movi	r2, '+'
    call    PrintChar
    br      end_if
end_if:

    mov     r2, r6
    addi    r2, r2, 4
    addi    r4,r4,1
    blt	    r4,r3,LOOPA

    ldw     ra, 8(sp) 
    ldw     r2, 4(sp)
    ldw     r3, 0(sp)
    addi    sp, sp, 12
    ret
    
    .org		0x1000
LIST:   .word   0,-1,5,0
N:      .word   4


        
        
        
        
        
        
    