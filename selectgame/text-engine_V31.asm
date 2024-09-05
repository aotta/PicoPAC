
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

;	jmp selectgame
	jmp reset
	  
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
	mov r0,#iram_line_selected
	mov @r0,#0
	mov r0,#iram_mempage
	mov @r0,#0
	mov r0,#iram_timer
	mov @r0,#0
	


	call waitvsync
	clr a
testloop inc a
	nop
	nop
	nop
	nop
	jt1 testloop
	mov r0,#iram_disp_type
	jb7 pal
	mov @r0,#0ffh ; NTSC????
pal
	call intro
	call waitvsync
;	call clearscreen
;	call initchars

; --> insert code for page and intram initialization
	call initpage
	call init_background

; xpos quad's
	mov a,#x0
	mov r0,#041h
	movx @r0,a
	mov a,#x0 + 008h
	mov r0,#051h
	movx @r0,a
	mov a,#x0 + 040h
	mov r0,#061h
	movx @r0,a
	mov a,#x0 + 048h
	mov r0,#071h
	movx @r0,a

; --> insert code for VDC initialization


mainloop
	mov r0,#iram_timer
	mov a,@r0
	inc a
	anl a,#007h
	mov @r0, a
	call joystick_ctrl
	call waitvsync

; --> insert code for main loop

	mov r5,#02ah | gridfill
	call startdisplay
	
;	mov a,#col_bck_blue
;	call chgbkcolor
	jmp mainloop


startdisplay
	; R2: first: counter for exram to intram copy, then: line delay counter
	; R3: line counter
	; R4: Ypos
	; R5: A0 value for display ON
	; R6: first: start-line number, then: -(y/4), then: char color

	call vdcenable
	mov r4,#y0		; y0
	mov r3,#8		; 8 lines
;	mov r6,#113h - y0	; NTSC
	mov r6,#113h - y0	; O2em
	mov r0,#iram_disp_type
	mov a,@r0
	jnz notpal1
	mov r6,#111h - y0	; PAL , 111h or 112h
notpal1

endvblank
	jt1 endvblank
	mov r0,#0a4h
	mov r1,#0a5h
chky	movx a,@r1 ; Why??? a is overwrited before any use
	movx a,@r0
	add a,r6
	jnc chky

;	mov r2,#1
	clr f0
	cpl f0		; skip delay for first line
ln0	jnt1 ln0

	mov r1,#000h	; exram pointer
	orl p1,#07ch	; P2=P3=P4=P5=P6=1 disable keyboard, VDC, extram, VPP, extram write
	anl p1,#0e7h	; P3=P4=0 enable VDC for write and extram for read

doupdate

	mov a,r4
	rr a
	rr a
 	cpl a
;	inc a		; test (remove to shift 2 scanlines down)

	mov r6,a		; r6 = -(y/4)

;	mov r0,#iram_line_selected
;	mov a,@r0
;	xrl a,r3
		
	mov r0,#020h	; intram pointer
	mov r2,#010h	; 16 characters
;	jnz copyram
;	mov a,#0d8h		; exram value should be: char * 4
;	add a,r6		; subtract y/4
;	mov @r0,a
;	inc r0
;	inc r1
;	dec r2

copyram
	movx a,@r1		; exram value should be: char * 4
	add a,r6		; subtract y/4
	mov @r0,a
	inc r0
	inc r1
	djnz r2,copyram
	mov a,r1
	mov @r0,a		; save exram pointer in intram 30

; set char color
	mov a,r3
	cpl a
	add a,#06dh
	clr c
	rrc a
	mov r0,a
	mov a,@r0
	jc colswap
	swap a
colswap
	anl a,#007h
	orl a,#080h	; test (shift 2 scanlines down)
	mov r6,a

	mov r2,#1
	jf0 jdelay
	mov r0,#iram_disp_type
	mov a,@r0
	mov r2,#006h	; NTSC
;	mov r2,#005h	; O2em
	jnz notpal2
	mov r2,#008h	; PAL
notpal2
jdelay

ln1	jnt1 ln1
l1	jt1 l1
	djnz r2,ln1

	clr f0
	clr c
	cpl c		;test (shift 2 scanlines down)
	mov r1,#020h	; intram pointer
	mov r0,#0a0h	; VDC control
	mov a,r5
	anl a,#0dfh		; turn of chars, sprites & quads
;	mov a,#00ah	| gridfill	; char display off

ln2	jnt1 ln2

	movx @r0,a		; do VDC control
;	anl p1,#07fh	; test

	mov a,r4		; update Ypos quad's
	mov r0,#040h	
	movx @r0,a		; quad0.Y = current Y
	mov r0,#050h	
	movx @r0,a		; quad1.Y = current Y
	mov r0,#060h
	movx @r0,a		; quad2.Y = current Y
	mov r0,#070h
	movx @r0,a		; quad3.Y = current Y

	mov a,@r1    
	mov r0,#042h	
	rlc a
;	mov a,#0f1h		
	movx @r0,a		; quad0.char0 = (line[0])*8-Y/2
	mov a,r6
	rlc a
	inc r0
;	mov a,#001h
	movx @r0,a     ; quad0.color0
	inc r1

	mov a,@r1
	mov r0,#052h   
	rlc a
	movx @r0,a	   ; quad1.char0 = (line[1])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad1.color0
	inc r1

	mov a,@r1
	mov r0,#046h
	rlc a
	movx @r0,a	   ; quad0.char1 = (line[2])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad1.color1
	inc r1

	mov a,@r1
	mov r0,#056h
	rlc a
	movx @r0,a	   ; quad1.char1 = (line[3])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad1.color1
	inc r1

	mov a,@r1
	mov r0,#04ah
	rlc a
	movx @r0,a     ; quad0.char2 = (line[4])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad0.color2
	inc r1

	mov a,@r1
	mov r0,#05ah
	rlc a
	movx @r0,a	   ; quad1.char2 = (line[5])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad1.color2
	inc r1

	mov a,@r1
	mov r0,#04eh
	rlc a
	movx @r0,a     ; quad0.char3 = (line[6])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad0.color3
	inc r1

	mov a,@r1
	mov r0,#05eh
	rlc a
	movx @r0,a     ; quad1.char3 = (line[7])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad1.color3
	inc r1

	mov a,@r1
	mov r0,#062h
	rlc a
	movx @r0,a     ; quad2.char0 = (line[8])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad2.color0
	inc r1

	mov a,@r1
	mov r0,#072h
	rlc a
	movx @r0,a     ; quad3.char0 = (line[9])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad3.color0
	inc r1

	mov a,@r1
	mov r0,#066h
	rlc a
	movx @r0,a     ; quad2.char1 = (line[10])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad2.color1
	inc r1

	mov a,@r1
	mov r0,#076h
	rlc a
	movx @r0,a     ; quad3.char1 = (line[11])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad3.color1
	inc r1

	mov a,@r1
	mov r0,#06ah
	rlc a
	movx @r0,a     ; quad2.char2 = (line[12])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad2.color2
	inc r1

	mov a,@r1
	mov r0,#07ah
	rlc a
	movx @r0,a     ; quad3.char2 = (line[13])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad3.color2
	inc r1

	mov a,@r1
	mov r0,#06eh
	rlc a
	movx @r0,a     ; quad2.char3 = (line[14])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad2.color3
	inc r1

	mov a,@r1
	mov r0,#07eh
	rlc a
	movx @r0,a     ; quad3.char3 = (line[15])*8-Y/2
	mov a,r6
	rlc a
	inc r0
	movx @r0,a     ; quad3.color3

	mov r0,#0a0h
	mov a,r5
;	mov a,#02ah	| gridfill	; char display on
	movx @r0,a
;	orl p1,#080h	;  test

	mov a,r4
	add a,#018h		; inc Ypos
	mov r4,a

	mov r0,#030h	; restore exram pointer
	mov a,@r0
	mov r1,a

	djnz r3,to_doupdate
	ret

to_doupdate
	jmp doupdate

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

clearline
	mov r5,#00ch
fillline
	mov a,r1
	anl a,#070h
	mov r0,a
	call calcchar
	mov r2,#010h
clrline
	movx @r0,a
	inc r0
	djnz r2,clrline
	ret

clearscreen
	call extramenable
	mov r1,#0
	mov r7,#8
clrscreen
	call clearline
	mov a,r1
	add a,#010h
	mov r1,a
	djnz r7,clrscreen
	ret

putchar
	call calcchar
	movx @r1,a
	ret

readchar
;	call calcY
;	mov a,r4
;	rr a
;	rr a
;	mov r4,a
	movx a,@r1
;	add a,r4
	rr a
	rr a
	ret

calcY
	mov a,r1
	anl a,#070h
	swap a
	mov r2,a
	mov r3,#018h
	call divide
	add a,#y0
	mov r4,a
	ret

	align 256

; --> character data (option)

textdata:
	db 000h,020h,012h,012h,024h,013h,036h,02ch
	db 048h,00fh,05ah,008h,06ch,02fh,07fh,010h,080h

inits
	mov r7,#textdata & 0ffh
intchars
	mov a,r7
	movp a,@a
	jb7 initend
	mov r1,a
	inc r7
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	jmp intchars
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
	
	nop

; --> grid data

griddata:
	db 001h,001h,001h,001h,001h,001h,001h,001h,001h
	db 001h,001h,001h,001h,001h,001h,001h,001h,001h
	db 0ffh,000h,000h,000h,000h,000h,000h,000h,000h,0ffh

copygrid
	mov a,r1
	movp a,@a
	movx @r0,a
	inc r0
	inc r1
	djnz r2,copygrid
	ret

init_background
	call vdcenable

	mov r0,#0a0h
	movx a,@r0
	orl a,#002h | gridfill	; enable A4/A5 registers
	movx @r0,a

; set background and grid color
	mov r0,#vdc_color
	mov a,#backcol
	movx @r0,a

	call gfxoff
	mov r0,#0c0h
	mov r1,#griddata & 0ffh
	mov r2,#9
	call copygrid

	mov r0,#0d0h
	mov r2,#9
	call copygrid

	mov r0,#0e0h
	mov r2,#00ah
	call copygrid
	ret
	
chgbkcolor
	mov r0,#vdc_color
	movx @r0,a
	ret
	
joystick_ctrl
; --> insert code for main loop
	call extramenable
;	mov a,#iram_line_selected
;	rl a
;	rl a
;	rl a
;	rl a

;	mov r1,a
;	mov a,#0d8h
;	movx @r1,a
	
	mov r0,#iram_timer
	mov a,@r0
	jz readj
	jmp update_arrow

readj
;	call getkey
	mov	r1,#0		; joystick 0
	
	call	getjoystick	; get offsets 
						; r2 eje x   FF= left, 0=center, 1=right
						; r3 eje y   FF= down, 0=center, 1=up
	; test, if fire
	jf0	firepressed1	; fire ?
	mov a,r2
	call ejex
	mov	a,r3		; y-offset
	jmp cont1
firepressed1
	jmp firepressed
cont1
	jnz	up_down		; up/down
	
	jmp update_arrow
up_down
	mov a,r3
	xrl a,#1
	jnz up
	mov r1,#iram_line_selected		; down
	mov a,@r1
	inc a
	mov @r1,a		; update line_selected

	xrl a,#8		; check page down
	jnz endchkpage
 
page_down
	mov a,#0		
	mov @r1,a				; line selected = 0
	mov r1,#iram_mempage
	call get_maxpages
	xrl a,@r1
	jz	in_lastpage
	mov a,@r1
	inc a
update_dn
	mov @r1,a				; update mempage
	call update_mem_page
	jmp endchkpage
in_lastpage
	mov a,#0
	jmp update_dn
up
	mov r1,#iram_line_selected
	mov a,@r1
	dec a
	mov @r1,a		; update line_selected
	xrl a,#255		; check page up
	jnz endchkpage
page_up
	mov a,#7
	mov @r1,a				; line selected = 7
	mov r1,#iram_mempage
	mov a,@r1
	jz inpage0
	dec a
	jmp update_up
inpage0
	call	get_maxpages
update_up
	mov @r1,a				; update mempage
	call update_mem_page

endchkpage	
	call sound

update_arrow	
	mov r1,#iram_line_selected
	mov r3,#8
	mov r0,#070h
s1
	mov a,@r1
	inc a
	xrl a,r3
	jnz space
	mov a,#0d8h
	jmp ends1
space
	mov a,#030h
ends1
	movx @r0,a
	mov a,r0
	add a,#-16
	mov r0,a
	djnz r3,s1
	ret

get_maxfiles
	mov a,#maxfiles & 0ffh
	movp a,@a
	ret
maxfiles
	db 25*8

get_maxpages
	mov a,#maxpages & 0ffh
	movp a,@a
	ret
maxpages
	db 24
sound	
	mov     a,#tune_keyclick
	call    playsound	
	ret
	align 128
update_mem_page
	mov r1,#iram_mempage
	mov a,@r1
	jnz chkpage1
	call initpage
	ret
startchkpages
chkpage1
	xrl a,#1
	jnz chkpage2
	call initpage1
	ret
chkpage2
	mov a,@r1
	xrl a,#2
	jnz chkpage3
	call initpage2
	ret
chkpage3
	mov a,@r1
	xrl a,#3
	jnz nextbank
	call initpage3
	ret
nextbank
;	call init_background
	call change_bank
	ret
	
setpointer
	ret
	
firepressed
	mov     a,#tune_explode
	call    playsound	

;--------------------------------------------------------------------
; decode filenumber and send it to databus
	call extramenable
	mov r1,#iram_line_selected
	mov a,@r1
	mov r2,a
	
	mov r1,#iram_mempage
	mov a,@r1
	
	rl a
	rl a
	rl a
	
	orl a,r2
	
	add a,#1
	
	mov r1,#0feh
	movx @r1,a
	
	mov r1,#0ffh
	mov a,#0aah ; ":" char for selected
	movx @r1,a 
	
	
;--------------------------------------------------------------------
	ret
	
	
initpage
	call initpage0
;	call update_mem_page
	ret
	


wait
	call waitvsync
	call waitvsync
	djnz r0,wait
	ret
	
intro
	call	gfxoff
	call 	videopac

	call 	sdcart

	call	gfxon		; lets see what is written
	mov r0,#10h
	call 	wait
	
	call	gfxoff

	mov r3,#0fch
	mov r4,#0fch
;	mov r2,#5
	mov r5,#0ch
	mov	r0,#vdc_char0
clr_text
	call printchar
	djnz r2,clr_text
	
	call	gfxon		; lets see what is written
	mov     a,#tune_select2
	call    playsound	

	call extramenable
	mov r1,#0ffh
	mov a,#254
	movx @r1,a
	
	ret
	
videopac
	mov	r0,#vdc_char0
	mov	r3,#30h		; x-position
	mov	r4,#40h		; y-position
	mov	r5,#24h		; V
	mov r6,#col_chr_green
	call	printchar
	mov	r5,#16h		; I
	mov r6,#col_chr_yellow
	call	printchar
	mov	r5,#1ah		; D
	mov r6,#col_chr_blue
	call	printchar
	mov	r5,#12h		; E
	mov r6,#col_chr_violet
	call	printchar
	mov	r5,#17h		; O
	mov r6,#col_chr_cyan
	call	printchar
	mov	r5,#0Fh		; P
	mov r6,#col_chr_white
	call	printchar
	mov	r5,#20h		; A
	mov r6,#col_chr_red
	call	printchar
	mov	r5,#23h		; C
	mov r6,#col_chr_green
	call	printchar
	ret

sdcart
	mov	r0,#vdc_chara
	mov	r3,#28h		; x-position
	mov	r4,#70h		; y-position
	mov	r5,#0Fh		; S
	mov r6,#col_chr_white
	call	printchar
	mov	r3,#38h		; x-position
	mov	r5,#16h		; D
	call	printchar

	mov	r0,#vdc_quad0
	mov	r3,#50h		; x-position
	mov r6,#col_chr_blue
	mov	r5,#23h		; C
	call	printchar
	mov	r5,#20h		; A
	call	printchar
	mov	r5,#13h		; R
	call	printchar
	mov	r5,#14h		; T
	call	printchar


	ret
	
ejex
	jnz	left_right		; left/right
	ret
left_right
	xrl a,#1
	jnz right
	
left
	mov     a,#tune_keyclick
	call    playsound	
	mov a,#220
	call extramenable
	mov r1,#0ffh
	movx @r1,a
	jmp page_down
	ret

right
	mov     a,#tune_keyclick
	call    playsound	
	mov a,#221
	call extramenable
	mov r1,#0ffh
	movx @r1,a
	jmp page_up
	ret



reset
;	mov r7,#0ffh                      ; R7 = FF
;	sel rb1                        ; Select High Registers
	call	00f1h
	jmp start
	
	org 0800h
; --> page data (option)

initpage0
	call extramenable
	mov r1,#0
	mov r7,#pagedata0 & 0ffh
intpage0
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage0
	jmp initend
	

	align 128

pagedata0:
	db 00Ch, 006h, 000h, 00Ch, 00Fh, 00Eh, 015h, 019h 
	db 00Ch, 028h, 00Ch, 014h, 013h, 020h, 02Dh, 019h 
	db 00Ch, 025h, 013h, 028h, 001h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 001h, 007h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 001h, 009h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 002h, 001h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 004h, 006h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 005h, 000h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 005h, 004h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch

	align 128
initpage1
	call extramenable
	mov r1,#0
	mov r7,#pagedata1 & 0ffh
intpage1
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage1
	jmp initend


	align 128
pagedata1:	
	db 00Ch, 025h, 013h, 028h, 005h, 005h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 005h, 008h, 027h, 025h 
	db 016h, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 023h, 00Eh, 020h, 02Ch 
	db 028h, 00Fh, 016h, 01Ch, 012h, 017h, 02Dh, 027h 
	db 00Ch, 025h, 013h, 028h, 023h, 017h, 026h, 020h 
	db 02Dh, 01Ah, 017h, 028h, 02Dh, 017h, 014h, 015h 
	db 00Ch, 025h, 013h, 028h, 01Bh, 013h, 017h, 01Ch 
	db 01Ch, 012h, 013h, 027h, 025h, 016h, 02Dh, 00Ch 
	db 00Ch, 025h, 013h, 028h, 00Fh, 017h, 00Fh, 012h 
	db 02Ch, 012h, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch 
	db 00Ch, 025h, 013h, 028h, 019h, 015h, 00Fh, 012h 
	db 013h, 028h, 023h, 017h, 025h, 013h, 020h, 027h 
	db 00Ch, 023h, 019h, 024h, 001h, 027h, 025h, 016h 
	db 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
	
	align 128
initpage2
	call extramenable
	mov r1,#0
	mov r7,#pagedata2 & 0ffh
intpage2
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage2
	jmp initend

	align 128
pagedata2:
	db 00Ch, 023h, 019h, 024h, 002h, 027h, 025h, 016h 
	db 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch 
	db 00Ch, 01Ah, 012h, 020h, 014h, 01Dh, 00Ch, 013h 
	db 020h, 023h, 012h, 00Ch, 013h, 023h, 000h, 004h 
	db 00Ch, 01Dh, 012h, 00Eh, 016h, 023h, 017h, 00Fh 
	db 014h, 012h, 013h, 00Ch, 013h, 012h, 019h, 023h 
	db 00Ch, 016h, 026h, 028h, 020h, 014h, 00Eh, 020h 
	db 02Dh, 014h, 016h, 019h, 027h, 025h, 016h, 02Dh 
	db 00Ch, 016h, 026h, 028h, 01Ah, 012h, 026h, 017h 
	db 02Dh, 028h, 020h, 014h, 014h, 020h, 023h, 01Fh 
	db 00Ch, 01Eh, 017h, 028h, 025h, 020h, 019h, 01Fh 
	db 012h, 014h, 028h, 025h, 017h, 011h, 00Eh, 016h 
	db 00Ch, 01Eh, 017h, 028h, 025h, 016h, 00Eh, 00Eh 
	db 020h, 013h, 01Ah, 028h, 00Fh, 00Eh, 027h, 025h 
	db 00Ch, 01Eh, 017h, 028h, 023h, 01Dh, 012h, 021h 
	db 028h, 026h, 020h, 022h, 016h, 026h, 012h, 027h

	align 128
initpage3
	call extramenable
	mov r1,#0
	mov r7,#pagedata3 & 0ffh
intpage3
	mov a,r7
	movp a,@a
	mov r5,a
	call putchar
	inc r7
	inc r1
	mov a,r1
	cpl a
	jb7 intpage3
	jmp initend

	align 128
pagedata3:
	db 00Ch, 01Eh, 017h, 028h, 01Ah, 012h, 026h, 017h 
	db 02Dh, 028h, 020h, 014h, 014h, 020h, 023h, 01Fh 
	db 00Ch, 01Eh, 017h, 028h, 012h, 022h, 017h, 01Eh 
	db 012h, 014h, 028h, 00Fh, 00Eh, 027h, 025h, 016h 
	db 00Ch, 01Eh, 017h, 028h, 01Bh, 00Eh, 016h, 00Fh 
	db 00Fh, 012h, 013h, 028h, 00Fh, 00Eh, 027h, 025h 
	db 00Ch, 01Eh, 017h, 028h, 00Eh, 012h, 028h, 014h 
	db 013h, 012h, 019h, 017h, 013h, 028h, 012h, 02Dh 
	db 00Ch, 01Eh, 017h, 028h, 026h, 017h, 014h, 017h 
	db 028h, 023h, 013h, 020h, 019h, 01Dh, 028h, 00Fh 
	db 00Ch, 01Eh, 017h, 028h, 019h, 02Ch, 013h, 020h 
	db 023h, 015h, 019h, 012h, 027h, 025h, 016h, 02Dh 
	db 00Ch, 026h, 017h, 01Ah, 028h, 000h, 001h, 00Fh 
	db 00Eh, 027h, 025h, 016h, 02Dh, 00Ch, 00Ch, 00Ch 
	db 00Ch, 026h, 017h, 01Ah, 028h, 000h, 005h, 028h 
	db 01Ch, 007h, 004h, 000h, 000h, 027h, 025h, 016h
 
 

