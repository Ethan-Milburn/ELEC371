    # .equ    JTAG_UART_BASE,     0x10001000  # Address of first JTAG UART register
    # .equ    DATA_OFFSET,        0           # Offset of JTAG UART data register
    # .equ    STATUS_OFFSET,      4           # Offset of JTAG UART status register
    # .equ    WSPACE_MASK,        0xFFFF      # Used in AND operation to check status
    
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

    movia	r2, X
    movia	r3, Y
    ldw     r4, N(r0)
    ldw     r5, LIMIT(r0)
    ldw     r6, K(r0)

    call ListCompute

    stw     r2, COUNT(r0)
    
    ldw     ra, 0(sp)
    addi    sp, sp, 4
    ret
    
#################################
ListCompute:
    subi    sp, sp, 16
    stw     r3, 12(sp) #Y pointer
    stw     r4, 8(sp)  #N
    stw     r5, 4(sp)  #LIMIT
    stw     r6, 0(sp)  #K

    mov     r7, r0 #COUNT
    mov     r8, r0 #I
LOOPA:
    ldw     r9, 0(r2) #X val
    ble 	r9, r5 , limt_if
    # El 
    stw     r0, 0(r3)
    stw     r5, 0(r2)
    addi    r7,r7,1
    br limit_end
limt_if:
    # If part
    mul		r9,	r6, r9
    subi    r9, r9, 6
    stw     r9, 0(r3)
    br      limit_end
limit_end:
     
    addi    r2, r2, 4
    addi    r3, r3, 4
    addi    r8,r8,1
    blt	    r8,r4,LOOPA

    mov     r2,r7
    ldw     r3, 12(sp) #Y pointer
    ldw     r4, 8(sp)  #N
    ldw     r5, 4(sp)  #LIMIT
    ldw     r6, 0(sp)  #K
    addi    sp, sp, 16

    ret

    

        


#################################
        .org		0x1000
X:      .word   2,4,6

        .org		0x1010
Y:      .word   -1,-1,1

        .org		0x1020
N:      .word   3
LIMIT:  .word   5
K:	    .word   2
COUNT:  .skip   4



        
        
        
        
        
        
    