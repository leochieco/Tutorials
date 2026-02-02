;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.3.0 #14184 (MINGW64)
;--------------------------------------------------------
	.module serial
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _outb
	.globl _inb
	.globl _serial_init
	.globl _serial_isr
	.globl _serial_char_available
	.globl _serial_getc
	.globl _serial_putc
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_buf:
	.ds 64
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_inPtr:
	.ds 1
_rdPtr:
	.ds 1
_used:
	.ds 1
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
	.area _CODE
;serial.c:34: void serial_init(void)
;	---------------------------------
; Function serial_init
; ---------------------------------
_serial_init::
;serial.c:36: outb(ACIA_CTRL, RTS_LOW);
	ld	l, #0x96
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x80
;serial.c:37: }
	jp	_outb
;serial.c:43: void serial_isr(void) __interrupt
;	---------------------------------
; Function serial_isr
; ---------------------------------
_serial_isr::
	ei
	push	af
	push	bc
	push	de
	push	hl
	push	iy
;serial.c:45: uint8_t status = inb(ACIA_CTRL);
	ld	a, #0x80
	call	_inb
;serial.c:47: if (status & 0x01) {
	rrca
	jr	NC, 00107$
;serial.c:48: uint8_t c = inb(ACIA_DATA);
	ld	a, #0x81
	call	_inb
	ld	c, a
;serial.c:50: if (used < SER_BUFSIZE) {
	ld	a, (_used+0)
	sub	a, #0x3f
	jr	NC, 00107$
;serial.c:51: buf[inPtr++] = c;
	ld	a, (_inPtr+0)
	ld	e, a
	inc	a
	ld	(_inPtr+0), a
	ld	hl, #_buf
	ld	d, #0x00
	add	hl, de
	ld	(hl), c
;serial.c:52: inPtr &= SER_BUFSIZE;
	ld	a, (_inPtr+0)
	and	a, #0x3f
	ld	(_inPtr+0), a
;serial.c:53: used++;
	ld	a, (_used+0)
	inc	a
	ld	(_used+0), a
;serial.c:55: if (used >= SER_FULLSIZE)
	ld	a, (_used+0)
	sub	a, #0x30
	jr	C, 00107$
;serial.c:56: outb(ACIA_CTRL, RTS_HIGH);
	ld	l, #0xd6
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x80
	call	_outb
00107$:
;serial.c:59: }
	pop	iy
	pop	hl
	pop	de
	pop	bc
	pop	af
	reti
;serial.c:66: uint8_t serial_char_available(void)
;	---------------------------------
; Function serial_char_available
; ---------------------------------
_serial_char_available::
;serial.c:68: return used;
	ld	a, (_used+0)
;serial.c:69: }
	ret
;serial.c:75: uint8_t serial_getc(void)
;	---------------------------------
; Function serial_getc
; ---------------------------------
_serial_getc::
;serial.c:77: while (!used);
00101$:
	ld	a, (_used+0)
	or	a, a
	jr	Z, 00101$
;serial.c:79: uint8_t c = buf[rdPtr++];
	ld	a, (_rdPtr+0)
	ld	c, a
	inc	a
	ld	(_rdPtr+0), a
	ld	hl, #_buf
	ld	b, #0x00
	add	hl, bc
	ld	c, (hl)
;serial.c:80: rdPtr &= SER_BUFSIZE;
	ld	a, (_rdPtr+0)
	and	a, #0x3f
	ld	(_rdPtr+0), a
;serial.c:82: __asm di __endasm;
	di	
;serial.c:83: used--;
	ld	a, (_used+0)
	ld	hl, #_used
	dec	a
	ld	(hl), a
;serial.c:84: if (used < SER_EMPTYSIZE)
	ld	a, (_used+0)
	sub	a, #0x05
	jr	NC, 00105$
;serial.c:85: outb(ACIA_CTRL, RTS_LOW);
	push	bc
	ld	l, #0x96
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x80
	call	_outb
	pop	bc
00105$:
;serial.c:86: __asm ei __endasm;
	ei	
;serial.c:88: return c;
	ld	a, c
;serial.c:89: }
	ret
;serial.c:96: void serial_putc(uint8_t c)
;	---------------------------------
; Function serial_putc
; ---------------------------------
_serial_putc::
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
;serial.c:98: while (!(inb(ACIA_CTRL) & 0x02));
00101$:
	push	hl
	ld	a, #0x80
	call	_inb
	pop	hl
	bit	1, a
	jr	Z, 00101$
;serial.c:99: outb(ACIA_DATA, c);
	ld	a, #0x81
;serial.c:100: }
	jp	_outb
	.area _CODE
	.area _INITIALIZER
__xinit__inPtr:
	.db #0x00	; 0
__xinit__rdPtr:
	.db #0x00	; 0
__xinit__used:
	.db #0x00	; 0
	.area _CABS (ABS)
