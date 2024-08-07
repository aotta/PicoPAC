
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
	xrl a,#11
	jnz chkpage12
	call initpage11
	ret
chkpage12
	mov a,@r1
	xrl a,#12
	jnz chkpage13
	call initpage12
	ret
chkpage13
	mov a,@r1
	xrl a,#13
	jnz chkpage14
	call initpage13
	ret
chkpage14
	mov a,@r1
	xrl a,#14
	jnz chkpage15
	call initpage14
	ret
chkpage15
	mov a,@r1
	xrl a,#15
	jnz chkpage16
	call initpage15
	ret
chkpage16
	mov a,@r1
	xrl a,#16
	jnz chkpage17
	call initpage16
	ret
chkpage17
	mov a,@r1
	xrl a,#17
	jnz chkpage18
	call initpage17
	ret
chkpage18
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
initpage11
	call extramenable
	mov r1,#0
	mov r7,#pagedata11 & 0ffh
intpage11
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage11
	jmp initend

	align 128

pagedata11:
	db 00Ch, 017h, 002h, 028h, 003h, 003h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 003h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 003h, 008h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 003h, 009h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 004h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 004h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 004h, 003h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 004h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
 
	align 128
initpage12
	call extramenable
	mov r1,#0
	mov r7,#pagedata12 & 0ffh
intpage12
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage12
	jmp initend

	align 128

pagedata12:
	db 00Ch, 017h, 002h, 028h, 004h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 004h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 004h, 008h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 017h, 002h, 028h, 004h, 008h, 020h, 00Eh 
	db 014h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 00Fh, 020h, 00Eh, 028h, 020h, 023h, 013h 
	db 017h, 025h, 020h, 014h, 019h, 027h, 025h, 016h 
	db 00Ch, 00Fh, 020h, 00Eh, 028h, 01Bh, 00Eh, 020h 
	db 019h, 01Dh, 00Fh, 017h, 016h, 02Dh, 014h, 027h 
	db 00Ch, 00Fh, 020h, 00Eh, 028h, 02Dh, 016h, 026h 
	db 025h, 00Eh, 012h, 028h, 02Dh, 015h, 026h, 025h 
	db 00Ch, 00Fh, 020h, 00Eh, 028h, 014h, 02Ch, 00Fh 
	db 012h, 028h, 020h, 02Dh, 01Ah, 028h, 014h, 012h
 
	align 128
initpage13
	call extramenable
	mov r1,#0
	mov r7,#pagedata13 & 0ffh
intpage13
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage13
	jmp initend

	align 128

pagedata13:
	db 00Ch, 00Fh, 025h, 028h, 01Bh, 013h, 017h, 01Ch 
	db 01Ch, 012h, 013h, 027h, 025h, 016h, 02Dh, 00Ch 
	db 00Ch, 00Fh, 025h, 028h, 00Fh, 017h, 00Fh, 012h 
	db 02Ch, 012h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch 
	db 00Ch, 00Fh, 025h, 028h, 018h, 028h, 025h, 012h 
	db 013h, 014h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch 
	db 00Ch, 00Fh, 025h, 028h, 019h, 015h, 00Fh, 012h 
	db 013h, 028h, 023h, 017h, 025h, 013h, 020h, 027h 
	db 00Ch, 00Fh, 013h, 028h, 023h, 00Eh, 020h, 02Ch 
	db 028h, 00Fh, 016h, 01Ch, 012h, 017h, 02Dh, 028h 
	db 00Ch, 00Fh, 013h, 028h, 023h, 00Eh, 020h, 02Ch 
	db 028h, 00Fh, 016h, 01Ch, 012h, 017h, 02Dh, 028h 
	db 00Ch, 00Fh, 013h, 028h, 016h, 02Dh, 014h, 012h 
	db 013h, 00Fh, 017h, 00Eh, 027h, 025h, 016h, 02Dh 
	db 00Ch, 00Fh, 013h, 028h, 026h, 020h, 013h, 014h 
	db 016h, 020h, 02Dh, 028h, 014h, 01Dh, 013h, 012h
 
	align 128
initpage14
	call extramenable
	mov r1,#0
	mov r7,#pagedata14 & 0ffh
intpage14	
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage14
	jmp initend

	align 128

pagedata14:
	db 00Ch, 00Fh, 013h, 028h, 026h, 020h, 013h, 014h 
	db 016h, 020h, 02Dh, 028h, 014h, 01Dh, 013h, 012h 
	db 00Ch, 00Fh, 013h, 028h, 026h, 016h, 019h, 019h 
	db 016h, 017h, 02Dh, 028h, 016h, 026h, 00Fh, 017h 
	db 00Ch, 00Fh, 013h, 028h, 02Dh, 016h, 01Ch, 01Dh 
	db 014h, 01Bh, 016h, 01Ch, 01Dh, 014h, 012h, 013h 
	db 00Ch, 00Fh, 013h, 028h, 00Fh, 016h, 02Dh, 025h 
	db 020h, 00Eh, 00Eh, 027h, 025h, 016h, 02Dh, 00Ch 
	db 00Ch, 00Fh, 013h, 028h, 00Fh, 00Eh, 020h, 02Ch 
	db 014h, 020h, 01Ch, 027h, 025h, 016h, 02Dh, 00Ch 
	db 00Ch, 00Fh, 013h, 028h, 013h, 012h, 01Ah, 028h 
	db 025h, 020h, 013h, 017h, 02Dh, 027h, 025h, 016h 
	db 00Ch, 00Fh, 013h, 028h, 013h, 012h, 01Ah, 028h 
	db 025h, 020h, 013h, 017h, 02Dh, 028h, 020h, 00Eh 
	db 00Ch, 00Fh, 013h, 028h, 013h, 017h, 025h, 017h 
	db 014h, 028h, 023h, 016h, 014h, 02Ch, 027h, 025h
 
	align 128
initpage15
	call extramenable
	mov r1,#0
	mov r7,#pagedata15 & 0ffh
intpage15
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage15
	jmp initend

	align 128

pagedata15:
	db 00Ch, 00Fh, 013h, 028h, 019h, 01Dh, 020h, 013h 
	db 01Fh, 028h, 01Dh, 015h, 02Dh, 014h, 012h, 013h 
	db 00Ch, 00Fh, 013h, 028h, 019h, 00Fh, 016h, 01Ah 
	db 012h, 013h, 026h, 020h, 02Dh, 027h, 025h, 016h 
	db 00Ch, 00Fh, 013h, 028h, 019h, 00Fh, 016h, 01Ah 
	db 012h, 013h, 026h, 020h, 02Dh, 028h, 020h, 00Eh 
	db 00Ch, 00Fh, 013h, 028h, 014h, 015h, 014h, 020h 
	db 02Dh, 01Fh, 01Dh, 020h, 026h, 027h, 025h, 016h 
	db 00Ch, 024h, 00Fh, 028h, 000h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 001h, 01Dh, 020h 
	db 023h, 01Fh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 001h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 002h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch

	align 128
initpage16
	call extramenable
	mov r1,#0
	mov r7,#pagedata16 & 0ffh
intpage16
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage16
	jmp initend

	align 128

pagedata16:
	db 00Ch, 024h, 00Fh, 028h, 000h, 003h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 004h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 006h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 008h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 000h, 009h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
	
	align 128
initpage17
	call extramenable
	mov r1,#0
	mov r7,#pagedata17 & 0ffh
intpage17
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage17
	jmp initend

	align 128

pagedata17:
	db 00Ch, 024h, 00Fh, 028h, 001h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 001h, 020h, 00Eh 
	db 014h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 001h, 00Fh, 00Eh 
	db 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 002h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 003h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 004h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 024h, 00Fh, 028h, 001h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
