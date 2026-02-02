;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.3.0 #14184 (MINGW64)
;--------------------------------------------------------
	.module c_test
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _start
	.globl _serial_putc
	.globl _serial_getc
	.globl _tris
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_board:
	.ds 9
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CSTUB
;c_test.c:21: void start(void){
;	---------------------------------
; Function start
; ---------------------------------
_start::
;c_test.c:22: tris();
;c_test.c:23: }
	jp	_tris
;c_test.c:28: static void puts(const char *s) {
;	---------------------------------
; Function puts
; ---------------------------------
_puts:
;c_test.c:29: while (*s) serial_putc(*s++);
00101$:
	ld	a, (hl)
	or	a, a
	ret	Z
	inc	hl
	ld	c, a
	push	hl
	ld	a, c
	call	_serial_putc
	pop	hl
;c_test.c:30: }
	jr	00101$
;c_test.c:41: static void draw_board(void) {
;	---------------------------------
; Function draw_board
; ---------------------------------
_draw_board:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;c_test.c:43: for (int i = 0; i < 9; i++) {
	ld	hl, #0x0000
	ex	(sp), hl
00106$:
	ld	a, -2 (ix)
	sub	a, #0x09
	ld	a, -1 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00104$
;c_test.c:44: char c = board[i] ? board[i] : ('0' + i);
	ld	a, #<(_board)
	add	a, -2 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #>(_board)
	adc	a, -1 (ix)
	ld	h, a
	ld	c, (hl)
	ld	a, c
	or	a, a
	jr	NZ, 00111$
	ld	a, -2 (ix)
	add	a, #0x30
	ld	c, a
00111$:
;c_test.c:45: serial_putc(c);
	ld	a, c
	call	_serial_putc
;c_test.c:46: if ((i % 3) == 2) puts("\r\n");
	ld	de, #0x0003
	pop	hl
	push	hl
	call	__modsint
	ld	a, e
	sub	a, #0x02
	or	a, d
	jr	NZ, 00102$
	ld	hl, #___str_1
	call	_puts
	jr	00107$
00102$:
;c_test.c:47: else puts(sep);
	ld	hl, #_draw_board_sep_65536_12
	call	_puts
00107$:
;c_test.c:43: for (int i = 0; i < 9; i++) {
	inc	-2 (ix)
	jr	NZ, 00106$
	inc	-1 (ix)
	jr	00106$
00104$:
;c_test.c:49: puts("\r\n");
	ld	hl, #___str_1
	call	_puts
;c_test.c:50: }
	ld	sp, ix
	pop	ix
	ret
_intro:
	.ascii "TIC-TAC-TOE ASCII"
	.db 0x0d
	.db 0x0a
	.db 0x00
_instructions:
	.ascii "You play X, CPU O"
	.db 0x0d
	.db 0x0a
	.ascii "Choose cell 0-8"
	.db 0x0d
	.db 0x0a
	.db 0x00
_prompt:
	.ascii "Your move: "
	.db 0x00
_win_user:
	.ascii "You win!"
	.db 0x0d
	.db 0x0a
	.db 0x00
_win_cpu:
	.ascii "CPU wins!"
	.db 0x0d
	.db 0x0a
	.db 0x00
_draw_msg:
	.ascii "Draw!"
	.db 0x0d
	.db 0x0a
	.db 0x00
_draw_board_sep_65536_12:
	.ascii "|"
	.db 0x00
___str_1:
	.db 0x0d
	.db 0x0a
	.db 0x00
;c_test.c:53: static char check_win(void) {
;	---------------------------------
; Function check_win
; ---------------------------------
_check_win:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-52
	add	hl, sp
	ld	sp, hl
;c_test.c:54: const int lines[8][3] = {
	xor	a, a
	ld	-52 (ix), a
	ld	-51 (ix), a
	ld	-50 (ix), #0x01
	ld	-49 (ix), #0
	ld	-48 (ix), #0x02
	ld	-47 (ix), #0
	ld	hl, #0
	add	hl, sp
	ld	c, l
	ld	b, h
	ld	-46 (ix), #0x03
	ld	-45 (ix), #0
	ld	-44 (ix), #0x04
	ld	-43 (ix), #0
	ld	-42 (ix), #0x05
	ld	-41 (ix), #0
	ld	-40 (ix), #0x06
	ld	-39 (ix), #0
	ld	-38 (ix), #0x07
	ld	-37 (ix), #0
	ld	-36 (ix), #0x08
	ld	-35 (ix), #0
	xor	a, a
	ld	-34 (ix), a
	ld	-33 (ix), a
	ld	-32 (ix), #0x03
	ld	-31 (ix), #0
	ld	-30 (ix), #0x06
	ld	-29 (ix), #0
	ld	-28 (ix), #0x01
	ld	-27 (ix), #0
	ld	-26 (ix), #0x04
	ld	-25 (ix), #0
	ld	-24 (ix), #0x07
	ld	-23 (ix), #0
	ld	-22 (ix), #0x02
	ld	-21 (ix), #0
	ld	-20 (ix), #0x05
	ld	-19 (ix), #0
	ld	-18 (ix), #0x08
	ld	-17 (ix), #0
	xor	a, a
	ld	-16 (ix), a
	ld	-15 (ix), a
	ld	-14 (ix), #0x04
	ld	-13 (ix), #0
	ld	-12 (ix), #0x08
	ld	-11 (ix), #0
	ld	-10 (ix), #0x02
	ld	-9 (ix), #0
	ld	-8 (ix), #0x04
	ld	-7 (ix), #0
	ld	-6 (ix), #0x06
	ld	-5 (ix), #0
;c_test.c:59: for (int i=0;i<8;i++) {
	ld	de, #_board+0
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00110$:
	ld	a, -2 (ix)
	sub	a, #0x08
	ld	a, -1 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00124$
;c_test.c:60: char a=board[lines[i][0]];
	push	de
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, de
	add	hl, hl
	pop	de
	add	hl, bc
	push	hl
	pop	iy
	ld	l, 0 (iy)
;	spillPairReg hl
	ld	h, 1 (iy)
;	spillPairReg hl
	add	hl, de
	ld	a, (hl)
	ld	-4 (ix), a
;c_test.c:61: char b=board[lines[i][1]];
	push	iy
	pop	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	add	hl, de
	ld	a, (hl)
	ld	-3 (ix), a
;c_test.c:62: char c=board[lines[i][2]];
	push	iy
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	add	hl, de
	ld	l, (hl)
;	spillPairReg hl
;c_test.c:63: if(a && a==b && b==c) return a;
	ld	a, -4 (ix)
	or	a, a
	jr	Z, 00111$
	ld	a, -4 (ix)
	sub	a, -3 (ix)
	jr	NZ, 00111$
	ld	a, -3 (ix)
	sub	a, l
	jr	NZ, 00111$
	ld	a, -4 (ix)
	jr	00115$
00111$:
;c_test.c:59: for (int i=0;i<8;i++) {
	inc	-2 (ix)
	jr	NZ, 00110$
	inc	-1 (ix)
	jr	00110$
;c_test.c:65: for(int i=0;i<9;i++) if(!board[i]) return 0;
00124$:
	ld	bc, #0x0000
00113$:
	ld	a, c
	sub	a, #0x09
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00108$
	ld	l, e
	ld	h, d
	add	hl, bc
	ld	a, (hl)
	or	a,a
	jr	Z, 00115$
	inc	bc
	jr	00113$
00108$:
;c_test.c:66: return 'D'; // Draw
	ld	a, #0x44
00115$:
;c_test.c:67: }
	ld	sp, ix
	pop	ix
	ret
;c_test.c:70: static int cpu_move(void) {
;	---------------------------------
; Function cpu_move
; ---------------------------------
_cpu_move:
;c_test.c:71: for(int i=0;i<9;i++) {
	ld	de, #0x0000
	ld	b, d
	ld	c, e
00115$:
	ld	a, c
	sub	a, #0x09
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00105$
;c_test.c:72: if(!board[i]) { board[i]='O'; if(check_win()=='O') return i; board[i]=0; }
	ld	hl, #_board+0
	add	hl, bc
	ld	a, (hl)
	or	a, a
	jr	NZ, 00116$
	ld	(hl), #0x4f
	push	hl
	push	bc
	push	de
	call	_check_win
	pop	de
	pop	bc
	pop	hl
	sub	a, #0x4f
	ret	Z
	ld	(hl), #0x00
00116$:
;c_test.c:71: for(int i=0;i<9;i++) {
	inc	bc
	ld	e, c
	ld	d, b
	jr	00115$
00105$:
;c_test.c:74: for(int i=0;i<9;i++) {
	ld	de, #0x0000
	ld	b, d
	ld	c, e
00118$:
	ld	a, c
	sub	a, #0x09
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00110$
;c_test.c:75: if(!board[i]) { board[i]='X'; if(check_win()=='X') { board[i]='O'; return i; } board[i]=0; }
	ld	hl, #_board+0
	add	hl, bc
	ld	a, (hl)
	or	a, a
	jr	NZ, 00119$
	ld	(hl), #0x58
	push	hl
	push	bc
	push	de
	call	_check_win
	pop	de
	pop	bc
	pop	hl
	sub	a, #0x58
	jr	NZ, 00107$
	ld	(hl), #0x4f
	ret
00107$:
	ld	(hl), #0x00
00119$:
;c_test.c:74: for(int i=0;i<9;i++) {
	inc	bc
	ld	e, c
	ld	d, b
	jr	00118$
00110$:
;c_test.c:77: for(int i=0;i<9;i++) if(!board[i]) { board[i]='O'; return i; }
	ld	de, #0x0000
	ld	b, d
	ld	c, e
00121$:
	ld	a, c
	sub	a, #0x09
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00113$
	ld	hl, #_board+0
	add	hl, bc
	ld	a, (hl)
	or	a, a
	jr	NZ, 00122$
	ld	(hl), #0x4f
	ret
00122$:
	inc	bc
	ld	e, c
	ld	d, b
	jr	00121$
00113$:
;c_test.c:78: return -1;
	ld	de, #0xffff
;c_test.c:79: }
	ret
;c_test.c:82: static int get_move(void) {
;	---------------------------------
; Function get_move
; ---------------------------------
_get_move:
;c_test.c:83: while (1) {
00105$:
;c_test.c:84: char c = serial_getc();
	call	_serial_getc
;c_test.c:85: if (c >= '0' && c <= '8') {
	ld	c, a
	sub	a, #0x30
	jr	C, 00105$
	ld	a, #0x38
	sub	a, c
	jr	C, 00105$
;c_test.c:86: serial_putc(c);       // mostra il carattere
	push	bc
	ld	a, c
	call	_serial_putc
	ld	a, #0x0d
	call	_serial_putc
	ld	a, #0x0a
	call	_serial_putc
	pop	bc
;c_test.c:89: return c - '0';
	ld	a, c
	ld	c, #0x00
	add	a, #0xd0
	ld	e, a
	ld	a, c
	adc	a, #0xff
	ld	d, a
;c_test.c:92: }
	ret
;c_test.c:97: void tris(void) {
;	---------------------------------
; Function tris
; ---------------------------------
_tris::
;c_test.c:99: for(int i=0;i<9;i++) board[i]=0;
	ld	bc, #0x0000
00124$:
	ld	a, c
	sub	a, #0x09
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00101$
	ld	hl, #_board
	add	hl, bc
	ld	(hl), #0x00
	inc	bc
	jr	00124$
00101$:
;c_test.c:102: puts(intro);
	ld	hl, #_intro
	call	_puts
;c_test.c:103: puts(instructions);
	ld	hl, #_instructions
	call	_puts
;c_test.c:105: while(1) {
00121$:
;c_test.c:106: draw_board();
	call	_draw_board
;c_test.c:107: puts(prompt);
	ld	hl, #_prompt
	call	_puts
;c_test.c:110: int move = get_move();
	call	_get_move
;c_test.c:111: if(board[move]) continue;
	ld	hl, #_board
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	NZ, 00121$
;c_test.c:112: board[move]='X';
	ld	(hl), #0x58
;c_test.c:114: char result = check_win();
	call	_check_win
;c_test.c:115: if(result) {
	ld	e, a
	or	a, a
	jr	Z, 00111$
;c_test.c:116: draw_board();
	push	de
	call	_draw_board
	pop	de
;c_test.c:117: if(result=='X') puts(win_user);
	ld	a, e
	sub	a, #0x58
	jr	NZ, 00108$
	ld	hl, #_win_user
	jp	_puts
00108$:
;c_test.c:118: else if(result=='O') puts(win_cpu);
	ld	a, e
	sub	a, #0x4f
	jr	NZ, 00105$
	ld	hl, #_win_cpu
	jp	_puts
00105$:
;c_test.c:119: else puts(draw_msg);
	ld	hl, #_draw_msg
;c_test.c:120: return;
	jp	_puts
00111$:
;c_test.c:124: cpu_move();
	call	_cpu_move
;c_test.c:126: result = check_win();
	call	_check_win
;c_test.c:127: if(result) {
	ld	c, a
	or	a, a
	jr	Z, 00121$
;c_test.c:128: draw_board();
	push	bc
	call	_draw_board
	pop	bc
;c_test.c:129: if(result=='X') puts(win_user);
	ld	a, c
	sub	a, #0x58
	jr	NZ, 00116$
	ld	hl, #_win_user
	jp	_puts
00116$:
;c_test.c:130: else if(result=='O') puts(win_cpu);
	ld	a, c
	sub	a, #0x4f
	jr	NZ, 00113$
	ld	hl, #_win_cpu
	jp	_puts
00113$:
;c_test.c:131: else puts(draw_msg);
	ld	hl, #_draw_msg
;c_test.c:132: return;
;c_test.c:135: }
	jp	_puts
	.area _CSTUB
	.area _INITIALIZER
	.area _CABS (ABS)
