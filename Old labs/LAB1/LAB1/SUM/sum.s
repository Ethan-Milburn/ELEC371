.text
.global _start
.org    0x0000

_start:
        ldw     r2, N(r0) #Load the value of N into register r2.
        movi    r3, LIST #Loads the memory address of LIST into register r3
        movi    r4, 0 #initializes r4 to 0, doesnt load 0 from somewhere else
        movi	r6,0
LOOPA:
    
        addi    r7,r6,1
        stw     r7,0(r3)
        addi    r3, r3, 4
        addi    r6,r6,1
        blt	r6,r2,LOOPA

        
        movi    r3, LIST #Loads the memory address of LIST into register r3
        movi    r4, 0 #initializes r4 to 0, doesnt load 0 from somewhere else
LOOP:

        ldw     r5, 0(r3)


        bgt     r5, r0, list_if
        beq     r5, r0, list_if
        sub     r4, r4, r5
        br	list_endif
list_if:
        add     r4, r4, r5
list_endif:
        addi    r3, r3, 4
        subi    r2, r2, 1
        
        bgt     r2, r0, LOOP

        stw r4, SUM(r0)
        break

        .org    0x1000
SUM:    .skip   4
N:      .word   5
LIST:   .skip   20

        .end
