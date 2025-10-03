    .text
    .global _start
    .org    0x0000
_start:
    ldw		r2,	Q(r0)
    ldw		r3,	R(r0)
    ldw     r4, S(r0)
    mul		r5,	r2,	r3
    addi	r5,	r5,	6
    stw		r5,	A(r0)
    divu	r5, r5,	r4
    stw     r5, B(r0)
    add		r5,	r5,	r4
    sub		r5,	r5,	r2
    stw     r5, C(r0)
    break
    .org		0x1000
Q:  .word   3
R:  .word   5
S:  .word   7
A:  .skip   4
B:	.skip   4
C:	.skip   4


        
        
        
        
        
        
    