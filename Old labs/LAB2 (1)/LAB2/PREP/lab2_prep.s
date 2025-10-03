    .equ    JTAG_UART_BASE,     0x10001000  # Address of first JTAG UART register
    .equ    DATA_OFFSET,        0           # Offset of JTAG UART data register
    .equ    STATUS_OFFSET,      4           # Offset of JTAG UART status register
    .equ    WSPACE_MASK,        0xFFFF      # Used in AND operation to check status
    
    .text
    .global _start
    .org    0x0000

_start:
    movia   sp, 0x007FFFFC
    call		main
    break

main:
    subi    sp, sp, 4
    stw     ra, 0(sp)

    movi		r2,	'H'
    call    PrintChar
    
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
    ldw     r4, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 8
    ret

    .org		0x1000
Q:  .word   3
R:  .word   5
S:  .word   7
A:  .skip   4
B:	.skip   4
C:	.skip   4


        
        
        
        
        
        
    