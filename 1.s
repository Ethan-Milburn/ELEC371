
.text
.global _start
.org 0x0000

_start:
	movia sp, 0x007FFFFC
	call main
	break
main:
	subi sp, sp, 4
	stw ra, 0(sp)
	
	movia r2, LIST
	ldw r3, N(r0)
	movi r4, 0x67
	call FillList
	
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
FillList: #(LIST,N,VALUE)
	subi sp, sp, 16
	stw ra, 0(sp)
	stw r2, 4(sp) 
	stw r3, 8(sp)
	stw r4, 12(sp)

fl_loop_start:
	stb r4, 0(r2)
	
	subi r3, r3, 1
	addi r2, r2, 1
	bgt r3, r0, fl_loop_start
fl_loop_end:
	ldw ra, 0(sp)
	ldw r2, 4(sp)
	ldw r3, 8(sp)
	ldw r4, 12(sp)
	addi sp, sp, 16
	ret

.org 0x1000
LIST: .byte 0x4A, 0xC9, 0xA8, 0x63
N:    .word 4
