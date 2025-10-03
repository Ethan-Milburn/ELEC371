    .text
    .global _start
    .org    0x0000
_start:
        ldw		r6,	K(r0)
        movi	r7,	5
        sub		r8,	r6,	r7
        muli	r9,	r6,	3
        stw		r9,	S(r0)
        break
        .org		0x1000
J:      .word   10
K:      .word   9
R:      .word   8
S:      .word   7
        
        
        
        
        
        
    