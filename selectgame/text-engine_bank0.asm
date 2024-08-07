
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
	xrl a,#18
	jnz chkpage19
	call initpage18
	ret
chkpage19
	mov a,@r1
	xrl a,#19
	jnz chkpage20
	call initpage19
	ret
chkpage20
	mov a,@r1
	xrl a,#20
	jnz chkpage21
	call initpage20
	ret
chkpage21
	mov a,@r1
	xrl a,#21
	jnz chkpage22
	call initpage21
	ret
chkpage22
	mov a,@r1
	xrl a,#22
	jnz chkpage23
	call initpage22
	ret
chkpage23
	mov a,@r1
	xrl a,#23
	jnz chkpage24
	call initpage23
	ret
chkpage24
	mov a,@r1
	xrl a,#24
	jnz endchkpage
	call initpage24
	ret
endchkpage
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
initpage18
	call extramenable
	mov r1,#0
	mov r7,#pagedata18 & 0ffh
intpage18
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage18
	jmp initend

	align 128

pagedata18:
	db 00Ch, 024h, 00Fh, 028h, 001h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 008h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 009h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 000h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 002h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
 
	align 128
initpage19
	call extramenable
	mov r1,#0
	mov r7,#pagedata19 & 0ffh
intpage19
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage19
	jmp initend

	align 128

pagedata19:
	db 00Ch, 024h, 00Fh, 028h, 002h, 002h, 01Dh, 020h 
	db 023h, 01Fh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 003h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 004h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 004h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 002h, 008h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
	
	align 128
initpage20
	call extramenable
	mov r1,#0
	mov r7,#pagedata20 & 0ffh
intpage20
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage20
	jmp initend

	align 128

pagedata20:
	db 00Ch, 024h, 00Fh, 028h, 002h, 009h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 002h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 003h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 003h, 020h, 00Eh 
	db 014h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 004h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 004h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch
 
	align 128
initpage21
	call extramenable
	mov r1,#0
	mov r7,#pagedata21 & 0ffh
intpage21
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage21
	jmp initend

	align 128

pagedata21:
	db 00Ch, 024h, 00Fh, 028h, 003h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 005h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 008h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 009h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 003h, 009h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
 
	align 128
initpage22
	call extramenable
	mov r1,#0
	mov r7,#pagedata22 & 0ffh
intpage22
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage22
	jmp initend

	align 128

pagedata22:
	db 00Ch, 024h, 00Fh, 028h, 004h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 002h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 003h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 003h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 004h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch

	align 128
initpage23
	call extramenable
	mov r1,#0
	mov r7,#pagedata23 & 0ffh
intpage23
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage23
	jmp initend

	align 128

pagedata23:
	db 00Ch, 024h, 00Fh, 028h, 004h, 008h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 004h, 009h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 001h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 002h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 003h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 003h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 004h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
	
	align 128
initpage24
	call extramenable
	mov r1,#0
	mov r7,#pagedata24 & 0ffh
intpage24
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage24
	jmp initend

	align 128

pagedata24:
	db 00Ch, 024h, 00Fh, 028h, 005h, 004h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 005h, 028h, 001h 
	db 002h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 005h, 028h, 001h 
	db 002h, 01Bh, 016h, 022h, 027h, 025h, 016h, 02Dh 
	db 00Ch, 024h, 00Fh, 028h, 005h, 006h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 008h, 028h, 001h 
	db 002h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 005h, 009h, 028h, 001h 
	db 006h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch