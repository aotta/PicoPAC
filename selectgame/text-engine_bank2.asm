
; INTRAM
; 20-2f = char temp space
; 30 = temp exram pointer
; 31 = PAL/NTSC
; 32-35 = line colors

; only alterable during assemble-time: y0, gridfill
; alterable during runtime: x0, backcol

	cpu	8048

	include	"g7000.h"
	
iram_disp_type equ 031h
iram_line_selected equ 37h
iram_mempage equ 36h
iram_timer equ 78h

x0		equ	018h	; between 000h and 024h
y0		equ	01ch	; multiple of 4, between 014h and 038h
gridfill	equ	080h	; 000h or 080h
backcol	equ	002h	; grid and background color

	org	400h

      jmp selectgame
      jmp irq
	retr
	nop
;	jmp	vsyncirq	; VSYNC-interrupt
      jmp vsync
      jmp start
      jmp soundirq

vsync
	clr f1
	cpl f1
	mov r1,#0a2h
	movx a,@r1
	mov r0,#03fh
	jmp 0030h

change_bank
	dis i
	anl p1,#0feh				; change to bank 2
	call startchkpages
	orl p1,#003h				; 
	anl p1,#0fdh				; change to bank 1
	call startchkpages
	anl p1,#0fch				; change to bank 0
	call startchkpages
	orl p1,#003h				; change to bank 3
	en i
	ret


start
startchkpages
	mov r1,#iram_mempage
	mov a,@r1
	xrl a,#4
	jnz chkpage5
	call initpage4
	ret
chkpage5
	mov a,@r1
	xrl a,#5
	jnz chkpage6
	call initpage5
	ret
chkpage6
	mov a,@r1
	xrl a,#6
	jnz chkpage7
	call initpage6
	ret
chkpage7
	mov a,@r1
	xrl a,#7
	jnz chkpage8
	call initpage7
	ret
chkpage8
	mov a,@r1
	xrl a,#8
	jnz chkpage9
	call initpage8
	ret
chkpage9
	mov a,@r1
	xrl a,#9
	jnz chkpage10
	call initpage9
	ret
chkpage10
	mov a,@r1
	xrl a,#10
	jnz chkpage11
	call initpage10
	ret
chkpage11
	ret
	
initend

; --> color data (used for "initchars" and "initpage")

	mov r0,#032h	; set text colors
	mov @r0,#001h
	inc r0
	mov @r0,#023h
	inc r0
	mov @r0,#045h
	inc r0
	mov @r0,#067h
	ret


calcchar
;	call calcY
	mov a,r5
	rl a
	rl a
	mov r5,a
;	mov a,r4
;	rr a
;	rr a
;	cpl a
;	inc a
;	add a,r5
	ret
putchar
	call calcchar
	movx @r1,a
	ret


	align 256
initpage4
	call extramenable
	mov r1,#0
	mov r7,#pagedata4 & 0ffh
intpage4
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage4
	jmp initend

	align 128

pagedata4:
	db 00Ch, 026h, 017h, 01Ah, 028h, 000h, 006h, 00Fh 
	db 00Eh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 001h, 001h, 00Fh 
	db 00Eh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 001h, 004h, 01Bh 
	db 016h, 022h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 001h, 009h, 028h 
	db 01Ch, 007h, 004h, 000h, 000h, 027h, 025h, 016h 
	db 00Ch, 026h, 017h, 01Ah, 028h, 002h, 000h, 00Fh 
	db 00Eh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 002h, 004h, 00Fh 
	db 00Eh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 002h, 008h, 01Bh 
	db 016h, 022h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 003h, 000h, 01Bh 
	db 016h, 022h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch
 
	align 128
initpage5
	call extramenable
	mov r1,#0
	mov r7,#pagedata5 & 0ffh
intpage5
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage5
	jmp initend

	align 128

pagedata5:
	db 00Ch, 026h, 017h, 01Ah, 028h, 003h, 001h, 028h 
	db 01Ch, 007h, 004h, 000h, 000h, 027h, 025h, 016h 
	db 00Ch, 026h, 017h, 01Ah, 028h, 003h, 005h, 00Fh 
	db 00Eh, 028h, 01Bh, 016h, 022h, 027h, 025h, 016h 
	db 00Ch, 026h, 017h, 01Ah, 028h, 003h, 006h, 01Bh 
	db 016h, 022h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 004h, 000h, 028h 
	db 01Ch, 007h, 004h, 000h, 000h, 027h, 025h, 016h 
	db 00Ch, 026h, 017h, 01Ah, 028h, 004h, 003h, 00Fh 
	db 00Eh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 005h, 005h, 00Fh 
	db 00Eh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 025h, 013h, 002h 
	db 001h, 028h, 01Bh, 016h, 022h, 027h, 025h, 016h 
	db 00Ch, 026h, 017h, 01Ah, 028h, 01Ah, 012h, 026h 
	db 017h, 02Dh, 028h, 020h, 014h, 014h, 020h, 023h
 
	align 128
initpage6
	call extramenable
	mov r1,#0
	mov r7,#pagedata6 & 0ffh
intpage6
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage6
	jmp initend

	align 128

pagedata6:
	db 00Ch, 026h, 017h, 01Ah, 028h, 026h, 017h, 014h 
	db 017h, 028h, 023h, 013h, 020h, 019h, 01Dh, 028h 
	db 00Ch, 026h, 017h, 01Ah, 028h, 00Fh, 00Eh, 020h 
	db 02Ch, 014h, 020h, 01Ch, 028h, 01Bh, 016h, 022h 
	db 00Ch, 026h, 017h, 01Ah, 028h, 014h, 015h, 014h 
	db 020h, 02Dh, 01Fh, 01Dh, 020h, 026h, 028h, 01Bh 
	db 00Ch, 026h, 017h, 01Ah, 028h, 024h, 00Fh, 009h 
	db 028h, 012h, 022h, 020h, 026h, 00Fh, 00Eh, 012h 
	db 00Ch, 026h, 017h, 01Ah, 028h, 024h, 00Fh, 003h 
	db 001h, 028h, 012h, 022h, 020h, 026h, 00Fh, 00Eh 
	db 00Ch, 026h, 017h, 015h, 019h, 012h, 023h, 020h 
	db 014h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 02Dh, 012h, 011h, 028h, 020h, 026h, 017h 
	db 01Fh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 02Dh, 012h, 011h, 028h, 020h, 026h, 017h 
	db 01Fh, 028h, 020h, 00Eh, 014h, 027h, 025h, 016h
 
	align 128
initpage7
	call extramenable
	mov r1,#0
	mov r7,#pagedata7 & 0ffh
intpage7
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage7
	jmp initend

	align 128

pagedata7:
	db 00Ch, 02Dh, 012h, 011h, 028h, 023h, 020h, 00Eh 
	db 023h, 015h, 00Eh, 020h, 014h, 017h, 013h, 027h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 01Dh, 012h, 00Eh 
	db 016h, 023h, 017h, 00Fh, 014h, 012h, 013h, 028h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 01Eh, 01Ch, 028h 
	db 026h, 015h, 02Dh, 023h, 01Dh, 01Fh, 016h, 02Dh 
	db 00Ch, 02Dh, 012h, 011h, 028h, 01Fh, 023h, 028h 
	db 00Fh, 020h, 023h, 026h, 020h, 02Dh, 027h, 025h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 01Fh, 023h, 028h 
	db 00Fh, 020h, 023h, 024h, 016h, 01Ah, 027h, 025h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 01Fh, 014h, 020h 
	db 020h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 02Dh, 012h, 011h, 028h, 01Fh, 014h, 020h 
	db 020h, 028h, 01Ah, 012h, 026h, 017h, 001h, 027h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 01Fh, 014h, 020h 
	db 020h, 028h, 01Ah, 012h, 026h, 017h, 002h, 027h
 
	align 128
initpage8
	call extramenable
	mov r1,#0
	mov r7,#pagedata8 & 0ffh
intpage8
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage8
	jmp initend

	align 128

pagedata8:
	db 00Ch, 02Dh, 012h, 011h, 028h, 026h, 013h, 013h 
	db 017h, 025h, 017h, 014h, 017h, 027h, 025h, 016h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 00Fh, 00Eh, 020h 
	db 02Dh, 012h, 014h, 028h, 00Eh, 020h, 02Dh, 01Ah 
	db 00Ch, 02Dh, 012h, 011h, 028h, 00Fh, 017h, 02Dh 
	db 01Ch, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 02Dh, 012h, 011h, 028h, 00Fh, 017h, 02Dh 
	db 01Ch, 028h, 020h, 00Eh, 00Eh, 027h, 025h, 016h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 00Fh, 00Fh, 00Fh 
	db 028h, 017h, 002h, 012h, 026h, 027h, 025h, 016h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 00Fh, 015h, 021h 
	db 021h, 00Eh, 012h, 028h, 00Fh, 016h, 012h, 023h 
	db 00Ch, 02Dh, 012h, 011h, 028h, 013h, 017h, 015h 
	db 014h, 012h, 006h, 006h, 027h, 025h, 016h, 02Dh 
	db 00Ch, 02Dh, 017h, 013h, 019h, 012h, 026h, 020h 
	db 02Dh, 00Ch, 02Eh, 012h, 015h, 013h, 017h, 00Fh

	align 128
initpage9
	call extramenable
	mov r1,#0
	mov r7,#pagedata9 & 0ffh
intpage9
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage9
	jmp initend

	align 128

pagedata9:
	db 00Ch, 02Dh, 014h, 019h, 023h, 028h, 005h, 007h 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 02Dh, 014h, 019h, 023h, 028h, 023h, 01Dh 
	db 012h, 021h, 028h, 026h, 020h, 022h, 016h, 026h 
	db 00Ch, 02Dh, 014h, 019h, 023h, 028h, 012h, 022h 
	db 017h, 01Eh, 012h, 014h, 028h, 00Fh, 00Eh, 027h 
	db 00Ch, 02Dh, 014h, 019h, 023h, 028h, 016h, 02Dh 
	db 014h, 012h, 013h, 00Fh, 017h, 00Eh, 027h, 025h 
	db 00Ch, 02Dh, 014h, 019h, 023h, 028h, 026h, 017h 
	db 014h, 017h, 028h, 023h, 013h, 020h, 019h, 01Dh 
	db 00Ch, 02Dh, 014h, 019h, 023h, 028h, 019h, 01Dh 
	db 020h, 013h, 01Fh, 028h, 01Dh, 015h, 02Dh, 014h 
	db 00Ch, 02Dh, 014h, 019h, 023h, 028h, 014h, 015h 
	db 014h, 020h, 02Dh, 01Fh, 01Dh, 020h, 026h, 027h 
	db 00Ch, 017h, 002h, 028h, 000h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
	
	align 128
initpage10
	call extramenable
	mov r1,#0
	mov r7,#pagedata10 & 0ffh
intpage10
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage10
	jmp initend

	align 128

pagedata10:
	db 00Ch, 017h, 002h, 028h, 000h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 001h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 001h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 001h, 004h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 001h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 001h, 009h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 002h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 003h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
