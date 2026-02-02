;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.3.0 #14184 (MINGW64)
;--------------------------------------------------------
	.module monitor
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _monitor
	.globl _toupper
	.globl _serial_putc
	.globl _serial_getc
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
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
	.area _CODE
;monitor.c:48: static void puts(const char *s) {
;	---------------------------------
; Function puts
; ---------------------------------
_puts:
;monitor.c:49: while (*s) serial_putc(*s++);
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
;monitor.c:50: }
	jr	00101$
_logo:
	.db 0x0c
	.db 0x0d
	.db 0x0a
	.ascii "  +-------------------+ "
	.db 0x0d
	.db 0x0a
	.ascii "  | ZEOS MONITOR V1.0 | "
	.db 0x0d
	.db 0x0a
	.ascii "  +-------------------+ "
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x00
_help:
	.ascii "Commands:"
	.db 0x0d
	.db 0x0a
	.ascii "D <addr> <len>       : Dump memory in hex + ASCII"
	.db 0x0d
	.db 0x0a
	.ascii "P <addr> <v..>       : Poke memory bytes"
	.db 0x0d
	.db 0x0a
	.ascii "F <addr> <len> <val> : Fill memory with a value"
	.db 0x0d
	.db 0x0a
	.ascii "G <addr>             : Jump to address (go)"
	.db 0x0d
	.db 0x0a
	.ascii "M <start> <end> <p..>: Search memory pattern"
	.db 0x0d
	.db 0x0a
	.ascii "X                    : Reset system"
	.db 0x0d
	.db 0x0a
	.ascii "H                    : Show this help"
	.db 0x0d
	.db 0x0a
	.db 0x00
_prompt:
	.ascii "Ready"
	.db 0x0d
	.db 0x0a
	.ascii "> "
	.db 0x00
_unknown_cmd:
	.ascii "Unknown command"
	.db 0x0d
	.db 0x0a
	.db 0x00
_invalid_input:
	.ascii "Invalid input"
	.db 0x0d
	.db 0x0a
	.db 0x00
_done_msg:
	.ascii "Done"
	.db 0x0d
	.db 0x0a
	.db 0x00
_memory_overflow:
	.ascii "Memory overflow"
	.db 0x0d
	.db 0x0a
	.db 0x00
;monitor.c:52: static void put_hex(uint8_t b) {
;	---------------------------------
; Function put_hex
; ---------------------------------
_put_hex:
	call	___sdcc_enter_ix
	ld	hl, #-17
	add	hl, sp
	ld	sp, hl
	ld	c, a
;monitor.c:53: const char h[] = "0123456789ABCDEF";
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	a, #0x30
	ld	(de), a
	ld	-16 (ix), #0x31
	ld	-15 (ix), #0x32
	ld	-14 (ix), #0x33
	ld	-13 (ix), #0x34
	ld	-12 (ix), #0x35
	ld	-11 (ix), #0x36
	ld	-10 (ix), #0x37
	ld	-9 (ix), #0x38
	ld	-8 (ix), #0x39
	ld	-7 (ix), #0x41
	ld	-6 (ix), #0x42
	ld	-5 (ix), #0x43
	ld	-4 (ix), #0x44
	ld	-3 (ix), #0x45
	ld	-2 (ix), #0x46
	ld	-1 (ix), #0x00
;monitor.c:54: serial_putc(h[b >> 4]);
	ld	a, c
	rlca
	rlca
	rlca
	rlca
	and	a, #0x0f
	ld	l, a
	ld	h, #0x00
	add	hl, de
	ld	b, (hl)
	push	bc
	push	de
	ld	a, b
	call	_serial_putc
	pop	de
	pop	bc
;monitor.c:55: serial_putc(h[b & 0x0F]);
	ld	a, c
	and	a, #0x0f
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	hl, de
	ld	a, (hl)
	call	_serial_putc
;monitor.c:56: }
	ld	sp, ix
	pop	ix
	ret
;monitor.c:59: static int hexstr_to_uint16(const char *s, uint16_t *val) {
;	---------------------------------
; Function hexstr_to_uint16
; ---------------------------------
_hexstr_to_uint16:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	hl
	ld	c, e
	ld	b, d
;monitor.c:60: uint16_t result = 0;
	ld	de, #0x0000
;monitor.c:62: while (*s) {
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00109$:
	pop	hl
	push	hl
	ld	a, (hl)
	or	a, a
	jr	Z, 00111$
;monitor.c:63: char c = toupper(*s);
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	push	bc
	push	de
	call	_toupper
	ex	de, hl
	pop	de
	pop	bc
;monitor.c:65: if (c >= '0' && c <= '9') nibble = c - '0';
	ld	h, l
;	spillPairReg hl
;	spillPairReg hl
	ld	a, l
	sub	a, #0x30
	jr	C, 00106$
	ld	a, #0x39
	sub	a, l
	jr	C, 00106$
	ld	a, h
	add	a, #0xd0
	jr	00107$
00106$:
;monitor.c:66: else if (c >= 'A' && c <= 'F') nibble = c - 'A' + 10;
	ld	a, l
	sub	a, #0x41
	jr	C, 00111$
	ld	a, #0x46
	sub	a, l
	jr	C, 00111$
	ld	a, h
	add	a, #0xc9
;monitor.c:67: else break;
00107$:
;monitor.c:68: result = (result << 4) | nibble;
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	l, #0x00
;	spillPairReg hl
;	spillPairReg hl
	or	a, e
	ld	e, a
	ld	a, l
	or	a, d
	ld	d, a
;monitor.c:69: digits++;
	inc	-2 (ix)
	jr	NZ, 00152$
	inc	-1 (ix)
00152$:
;monitor.c:70: s++;
	inc	-4 (ix)
	jr	NZ, 00109$
	inc	-3 (ix)
	jr	00109$
00111$:
;monitor.c:72: if (digits == 0) return 0;  // conversion failed
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00113$
	ld	de, #0x0000
	jr	00114$
00113$:
;monitor.c:73: *val = result;
	ld	a, e
	ld	(bc), a
	inc	bc
	ld	a, d
	ld	(bc), a
;monitor.c:74: return 1; // OK
	ld	de, #0x0001
00114$:
;monitor.c:75: }
	ld	sp, ix
	pop	ix
	ret
;monitor.c:78: static void read_line(char *b, int m) {
;	---------------------------------
; Function read_line
; ---------------------------------
_read_line:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	push	af
	ld	-2 (ix), l
	ld	-1 (ix), h
;monitor.c:80: while (i < m - 1) {
	ld	a, e
	add	a, #0xff
	ld	-6 (ix), a
	ld	a, d
	adc	a, #0xff
	ld	-5 (ix), a
	ld	bc, #0x0000
00104$:
;monitor.c:83: b[i++] = c;
	ld	a, -2 (ix)
	add	a, c
	ld	-4 (ix), a
	ld	a, -1 (ix)
	adc	a, b
	ld	-3 (ix), a
;monitor.c:80: while (i < m - 1) {
	ld	a, c
	sub	a, -6 (ix)
	ld	a, b
	sbc	a, -5 (ix)
	jp	PO, 00130$
	xor	a, #0x80
00130$:
	jp	P, 00106$
;monitor.c:81: char c = serial_getc();
	push	bc
	call	_serial_getc
	pop	bc
;monitor.c:82: if (c == CR || c == LF) break;
	ld	e, a
	sub	a, #0x0d
	jr	Z, 00106$
	ld	a, e
	sub	a, #0x0a
	jr	Z, 00106$
;monitor.c:83: b[i++] = c;
	inc	bc
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	(hl), e
;monitor.c:84: serial_putc(c);
	push	bc
	ld	a, e
	call	_serial_putc
	pop	bc
	jr	00104$
00106$:
;monitor.c:86: b[i] = 0;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	(hl), #0x00
;monitor.c:87: serial_putc(CR); serial_putc(LF);
	ld	a, #0x0d
	call	_serial_putc
	ld	a, #0x0a
	call	_serial_putc
;monitor.c:88: }
	ld	sp, ix
	pop	ix
	ret
;monitor.c:91: static void cmd_dump(const char *a) {
;	---------------------------------
; Function cmd_dump
; ---------------------------------
_cmd_dump:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-20
	add	iy, sp
	ld	sp, iy
	ld	-4 (ix), l
	ld	-3 (ix), h
;monitor.c:92: uint16_t addr = 0, len = 0;
	xor	a, a
	ld	-18 (ix), a
	ld	-17 (ix), a
	xor	a, a
	ld	-16 (ix), a
	ld	-15 (ix), a
;monitor.c:94: while (*a == ' ') a++;
00101$:
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	a, (hl)
	sub	a, #0x20
	jr	NZ, 00157$
	inc	-4 (ix)
	jr	NZ, 00101$
	inc	-3 (ix)
	jr	00101$
00157$:
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
;monitor.c:95: if (!hexstr_to_uint16(a, &addr)) { puts(invalid_input); return; }
	ld	hl, #2
	add	hl, sp
	ex	de, hl
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	-4 (ix), e
	ld	-3 (ix), d
	ld	a, d
	or	a, -4 (ix)
	jr	NZ, 00144$
	ld	hl, #_invalid_input
	call	_puts
	jp	00132$
;monitor.c:97: while (*a && *a != ' ') a++;
00144$:
	ld	c, -2 (ix)
	ld	b, -1 (ix)
00107$:
	ld	a, (bc)
	or	a, a
	jr	Z, 00146$
	sub	a, #0x20
	jr	Z, 00146$
	inc	bc
	jr	00107$
;monitor.c:98: while (*a == ' ') a++;
00146$:
00110$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00112$
	inc	bc
	jr	00110$
00112$:
;monitor.c:99: if (!hexstr_to_uint16(a, &len)) { puts(invalid_input); return; }
	ld	hl, #4
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	a, d
	or	a, e
	jr	NZ, 00114$
	ld	hl, #_invalid_input
	call	_puts
	jp	00132$
00114$:
;monitor.c:102: uint32_t end = (uint32_t)addr + (uint32_t)len - 1;
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	de, #0x0000
	ld	a, -16 (ix)
	push	iy
	ex	(sp), hl
	ld	h, -15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	pop	iy
	ld	hl, #0x0000
	add	a, c
	ld	c, a
	push	iy
	ld	a, -21 (ix)
	pop	iy
	adc	a, b
	ld	b, a
	ld	a, l
	adc	a, e
	ld	e, a
	ld	a, h
	adc	a, d
	ld	d, a
	ld	a, c
	add	a, #0xff
	ld	c, a
	ld	a, b
	adc	a, #0xff
	ld	b, a
	ld	a, e
	adc	a, #0xff
	ld	e, a
	ld	a, d
	adc	a, #0xff
	ld	d, a
;monitor.c:103: if (end > MAX_MEM) { puts(memory_overflow); return; }
	ld	a, #0xff
	cp	a, c
	sbc	a, b
	sbc	hl, de
	jr	NC, 00116$
	ld	hl, #_memory_overflow
	call	_puts
	jp	00132$
00116$:
;monitor.c:105: for (uint16_t i = 0; i < len; i += 8) {
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
00130$:
	ld	a, -4 (ix)
	sub	a, -16 (ix)
	ld	a, -3 (ix)
	sbc	a, -15 (ix)
	jp	NC, 00132$
;monitor.c:107: for (uint8_t j = 0; j < 8; j++) {
	ld	c, #0x00
00124$:
;monitor.c:108: if (i + j < len) {
	ld	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
;monitor.c:107: for (uint8_t j = 0; j < 8; j++) {
;monitor.c:108: if (i + j < len) {
	ld	a,c
	cp	a,#0x08
	jr	NC, 00120$
	ld	b, #0x00
	ld	-20 (ix), a
	ld	-19 (ix), b
	ld	a, -6 (ix)
	add	a, -20 (ix)
	ld	b, a
	ld	a, -5 (ix)
	adc	a, -19 (ix)
	ld	e, a
	ld	a, b
	sub	a, -16 (ix)
	ld	a, e
	sbc	a, -15 (ix)
	jr	NC, 00118$
;monitor.c:109: uint8_t v = *((uint8_t *)(addr + i + j));
	ld	a, -18 (ix)
	add	a, -4 (ix)
	ld	e, a
	ld	a, -17 (ix)
	adc	a, -3 (ix)
	ld	d, a
	pop	hl
	push	hl
	add	hl, de
	ld	a, (hl)
;monitor.c:110: put_hex(v); serial_putc(' ');
	ld	-5 (ix), a
	push	bc
	call	_put_hex
	ld	a, #0x20
	call	_serial_putc
	pop	bc
;monitor.c:111: ascii[j] = (v >= 0x20 && v <= 0x7E) ? v : '.';
	ld	e, c
	ld	d, #0x00
	ld	hl, #6
	add	hl, sp
	add	hl, de
	ex	de, hl
	ld	a, -5 (ix)
	sub	a, #0x20
	jr	C, 00134$
	ld	a, #0x7e
	sub	a, -5 (ix)
	jr	C, 00134$
	ld	a, -5 (ix)
	jr	00135$
00134$:
	ld	a, #0x2e
00135$:
	ld	(de), a
	jr	00125$
00118$:
;monitor.c:113: puts("   "); ascii[j] = ' ';
	push	bc
	ld	hl, #___str_8
	call	_puts
	pop	bc
	ld	e, c
	ld	d, #0x00
	ld	hl, #6
	add	hl, sp
	add	hl, de
	ld	(hl), #0x20
00125$:
;monitor.c:107: for (uint8_t j = 0; j < 8; j++) {
	inc	c
	jp	00124$
00120$:
;monitor.c:116: puts("    ");
	ld	hl, #___str_9
	call	_puts
;monitor.c:117: for (uint8_t j = 0; j < 8; j++) serial_putc(ascii[j]);
	ld	c, #0x00
00127$:
	ld	a, c
	sub	a, #0x08
	jr	NC, 00121$
	ld	e, c
	ld	d, #0x00
	ld	hl, #6
	add	hl, sp
	add	hl, de
	ld	b, (hl)
	push	bc
	ld	a, b
	call	_serial_putc
	pop	bc
	inc	c
	jr	00127$
00121$:
;monitor.c:118: puts("\r\n");
	ld	hl, #___str_10
	call	_puts
;monitor.c:105: for (uint16_t i = 0; i < len; i += 8) {
	ld	a, -6 (ix)
	add	a, #0x08
	ld	-4 (ix), a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	-3 (ix), a
	jp	00130$
00132$:
;monitor.c:120: }
	ld	sp, ix
	pop	ix
	ret
___str_8:
	.ascii "   "
	.db 0x00
___str_9:
	.ascii "    "
	.db 0x00
___str_10:
	.db 0x0d
	.db 0x0a
	.db 0x00
;monitor.c:124: static void cmd_poke(const char *a) {
;	---------------------------------
; Function cmd_poke
; ---------------------------------
_cmd_poke:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-10
	add	iy, sp
	ld	sp, iy
	ld	-2 (ix), l
	ld	-1 (ix), h
;monitor.c:125: uint16_t addr = 0;
	ld	hl, #0x0000
	ex	(sp), hl
;monitor.c:128: while (*a == ' ') a++;
00101$:
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	a, (hl)
	sub	a, #0x20
	jr	NZ, 00147$
	inc	-2 (ix)
	jr	NZ, 00101$
	inc	-1 (ix)
	jr	00101$
00147$:
	ld	a, -2 (ix)
	ld	-6 (ix), a
	ld	a, -1 (ix)
	ld	-5 (ix), a
;monitor.c:131: if (!hexstr_to_uint16(a, &addr)) { 
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, d
	or	a, -2 (ix)
	jr	NZ, 00135$
;monitor.c:132: puts(invalid_input); 
	ld	hl, #_invalid_input
	call	_puts
;monitor.c:133: return; 
	jp	00128$
;monitor.c:137: while (*a && *a != ' ') a++;
00135$:
	ld	c, -6 (ix)
	ld	b, -5 (ix)
00107$:
	ld	a, (bc)
	or	a, a
	jr	Z, 00137$
	sub	a, #0x20
	jr	Z, 00137$
	inc	bc
	jr	00107$
;monitor.c:138: while (*a == ' ') a++;
00137$:
00110$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00149$
	inc	bc
	jr	00110$
;monitor.c:141: while (*a) {
00149$:
	ld	-6 (ix), c
	ld	-5 (ix), b
	ld	a, -10 (ix)
	ld	-2 (ix), a
	ld	a, -9 (ix)
	ld	-1 (ix), a
00125$:
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	or	a, a
	jp	Z, 00127$
;monitor.c:142: uint16_t v = 0;
	xor	a, a
	ld	-8 (ix), a
	ld	-7 (ix), a
;monitor.c:145: if (!hexstr_to_uint16(a, &v) || v > 0xFF) { 
	ld	hl, #2
	add	hl, sp
	ex	de, hl
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	a, d
	or	a, e
	jr	Z, 00113$
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a, #0xff
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jr	NC, 00114$
00113$:
;monitor.c:146: puts(invalid_input); 
	ld	hl, #_invalid_input
	call	_puts
;monitor.c:147: return; 
	jr	00128$
00114$:
;monitor.c:151: if (addr == MAX_MEM) {
	ld	a, -2 (ix)
	ld	b, -1 (ix)
	and	a, b
	inc	a
	jr	NZ, 00117$
;monitor.c:152: puts(memory_overflow);
	ld	hl, #_memory_overflow
	call	_puts
;monitor.c:153: return;
	jr	00128$
00117$:
;monitor.c:157: *((uint8_t *)addr) = (uint8_t)v;
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	ld	a, -8 (ix)
	ld	(bc), a
;monitor.c:158: addr++;
	inc	-2 (ix)
	jr	NZ, 00227$
	inc	-1 (ix)
00227$:
	ld	a, -2 (ix)
	ld	-10 (ix), a
	ld	a, -1 (ix)
	ld	-9 (ix), a
;monitor.c:162: while (*a && *a != ' ') a++;
	ld	c, -6 (ix)
	ld	b, -5 (ix)
00119$:
	ld	a, (bc)
	or	a, a
	jr	Z, 00150$
	sub	a, #0x20
	jr	Z, 00150$
	inc	bc
	jr	00119$
;monitor.c:163: while (*a == ' ') a++;
00150$:
	ld	-6 (ix), c
	ld	-5 (ix), b
	ld	-4 (ix), c
	ld	-3 (ix), b
00122$:
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	a, (hl)
	sub	a, #0x20
	jp	NZ,00125$
	inc	-4 (ix)
	jr	NZ, 00231$
	inc	-3 (ix)
00231$:
	ld	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
	jr	00122$
00127$:
;monitor.c:166: puts(done_msg);
	ld	hl, #_done_msg
	call	_puts
00128$:
;monitor.c:167: }
	ld	sp, ix
	pop	ix
	ret
;monitor.c:172: static void cmd_fill(const char *a) {
;	---------------------------------
; Function cmd_fill
; ---------------------------------
_cmd_fill:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-18
	add	iy, sp
	ld	sp, iy
	ld	c, l
	ld	b, h
;monitor.c:173: uint16_t addr = 0, len = 0, val = 0;
	ld	hl, #0x0000
	ex	(sp), hl
	xor	a, a
	ld	-16 (ix), a
	ld	-15 (ix), a
	xor	a, a
	ld	-14 (ix), a
	ld	-13 (ix), a
;monitor.c:175: while (*a == ' ') a++;
00101$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00151$
	inc	bc
	jr	00101$
00151$:
	ld	-4 (ix), c
	ld	-3 (ix), b
;monitor.c:176: if (!hexstr_to_uint16(a, &addr)) goto err;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, d
	or	a, -2 (ix)
	jp	Z, 00128$
;monitor.c:177: while (*a && *a != ' ') a++;
	ld	c, -4 (ix)
	ld	b, -3 (ix)
00107$:
	ld	a, (bc)
	or	a, a
	jr	Z, 00140$
	sub	a, #0x20
	jr	Z, 00140$
	inc	bc
	jr	00107$
;monitor.c:178: while (*a == ' ') a++;
00140$:
00110$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00153$
	inc	bc
	jr	00110$
00153$:
	ld	-2 (ix), c
	ld	-1 (ix), b
;monitor.c:179: if (!hexstr_to_uint16(a, &len)) goto err;
	ld	hl, #2
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	a, d
	or	a, e
	jp	Z, 00128$
;monitor.c:180: while (*a && *a != ' ') a++;
	ld	c, -2 (ix)
	ld	b, -1 (ix)
00116$:
	ld	a, (bc)
	or	a, a
	jr	Z, 00145$
	sub	a, #0x20
	jr	Z, 00145$
	inc	bc
	jr	00116$
;monitor.c:181: while (*a == ' ') a++;
00145$:
00119$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00121$
	inc	bc
	jr	00119$
00121$:
;monitor.c:182: if (!hexstr_to_uint16(a, &val) || val > 0xFF) goto err;
	ld	hl, #4
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	a, d
	or	a, e
	jp	Z, 00128$
	ld	c, -14 (ix)
	ld	b, -13 (ix)
	ld	a, #0xff
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jp	C, 00128$
;monitor.c:184: uint32_t end = (uint32_t)addr + (uint32_t)len - 1;
	ld	a, -18 (ix)
	ld	-12 (ix), a
	ld	a, -17 (ix)
	ld	-11 (ix), a
	xor	a, a
	ld	-10 (ix), a
	ld	-9 (ix), a
	ld	a, -16 (ix)
	ld	-8 (ix), a
	ld	a, -15 (ix)
	ld	-7 (ix), a
	xor	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
	ld	a, -12 (ix)
	add	a, -8 (ix)
	ld	-4 (ix), a
	ld	a, -11 (ix)
	adc	a, -7 (ix)
	ld	-3 (ix), a
	ld	a, -10 (ix)
	adc	a, -6 (ix)
	ld	-2 (ix), a
	ld	a, -9 (ix)
	adc	a, -5 (ix)
	ld	-1 (ix), a
	ld	a, -4 (ix)
	add	a, #0xff
	ld	-8 (ix), a
	ld	a, -3 (ix)
	adc	a, #0xff
	ld	-7 (ix), a
	ld	a, -2 (ix)
	adc	a, #0xff
	ld	-6 (ix), a
	ld	a, -1 (ix)
	adc	a, #0xff
	ld	-5 (ix), a
;monitor.c:185: if (end > MAX_MEM) { puts(memory_overflow); return; }
	ld	a, #0xff
	cp	a, -8 (ix)
	sbc	a, -7 (ix)
	ld	a, #0x00
	sbc	a, -6 (ix)
	ld	a, #0x00
	sbc	a, -5 (ix)
	jr	NC, 00150$
	ld	hl, #_memory_overflow
	call	_puts
	jr	00132$
;monitor.c:187: for (uint16_t i = 0; i < len; i++)
00150$:
	ld	bc, #0x0000
00130$:
	ld	a, c
	sub	a, -16 (ix)
	ld	a, b
	sbc	a, -15 (ix)
	jr	NC, 00127$
;monitor.c:188: *((uint8_t *)(addr + i)) = (uint8_t)val;
	pop	hl
	push	hl
	add	hl, bc
	ld	a, -14 (ix)
	ld	(hl), a
;monitor.c:187: for (uint16_t i = 0; i < len; i++)
	inc	bc
	jr	00130$
00127$:
;monitor.c:190: puts(done_msg);
	ld	hl, #_done_msg
	call	_puts
;monitor.c:191: return;
	jr	00132$
;monitor.c:192: err:
00128$:
;monitor.c:193: puts(invalid_input);
	ld	hl, #_invalid_input
	call	_puts
00132$:
;monitor.c:194: }
	ld	sp, ix
	pop	ix
	ret
;monitor.c:199: static void cmd_go(const char *a) {
;	---------------------------------
; Function cmd_go
; ---------------------------------
_cmd_go:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	ld	c, l
	ld	b, h
;monitor.c:200: uint16_t addr = 0;
	ld	hl, #0x0000
	ex	(sp), hl
;monitor.c:201: while (*a == ' ') a++;
00101$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00103$
	inc	bc
	jr	00101$
00103$:
;monitor.c:202: if (!hexstr_to_uint16(a, &addr)) { puts(invalid_input); return; }
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	a, d
	or	a, e
	jr	NZ, 00105$
	ld	hl, #_invalid_input
	call	_puts
	jr	00106$
00105$:
;monitor.c:204: ((void (*)(void))addr)();
	pop	hl
	push	hl
	call	___sdcc_call_hl
00106$:
;monitor.c:208: }
	pop	af
	pop	ix
	ret
;monitor.c:213: static void cmd_find(const char *a) {
;	---------------------------------
; Function cmd_find
; ---------------------------------
_cmd_find:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-18
	add	iy, sp
	ld	sp, iy
	ld	c, l
	ld	b, h
;monitor.c:214: uint16_t s = 0, e = 0;
	ld	hl, #0x0000
	ex	(sp), hl
	xor	a, a
	ld	-16 (ix), a
	ld	-15 (ix), a
;monitor.c:216: while (*a == ' ') a++;
00101$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00179$
	inc	bc
	jr	00101$
00179$:
	ld	-2 (ix), c
	ld	-1 (ix), b
;monitor.c:217: if (!hexstr_to_uint16(a, &s)) goto err;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	a, d
	or	a, e
	jp	Z, 00142$
;monitor.c:218: while (*a && *a != ' ') a++;
	ld	c, -2 (ix)
	ld	b, -1 (ix)
00107$:
	ld	a, (bc)
	or	a, a
	jr	Z, 00157$
	sub	a, #0x20
	jr	Z, 00157$
	inc	bc
	jr	00107$
;monitor.c:219: while (*a == ' ') a++;
00157$:
00110$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00181$
	inc	bc
	jr	00110$
00181$:
	ld	-2 (ix), c
	ld	-1 (ix), b
;monitor.c:220: if (!hexstr_to_uint16(a, &e)) goto err;
	ld	hl, #2
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	ld	a, d
	or	a, e
	jp	Z, 00142$
;monitor.c:221: while (*a && *a != ' ') a++;
	ld	c, -2 (ix)
	ld	b, -1 (ix)
00116$:
	ld	a, (bc)
	or	a, a
	jr	Z, 00162$
	sub	a, #0x20
	jr	Z, 00162$
	inc	bc
	jr	00116$
;monitor.c:222: while (*a == ' ') a++;
00162$:
00119$:
	ld	a, (bc)
	sub	a, #0x20
	jr	NZ, 00183$
	inc	bc
	jr	00119$
00183$:
;monitor.c:225: uint8_t plen = 0;
	ld	-4 (ix), #0x00
;monitor.c:226: while (*a && plen < 8) {
	ld	-1 (ix), #0x00
00133$:
	ld	a, (bc)
	or	a, a
	jr	Z, 00135$
	ld	a, -1 (ix)
	sub	a, #0x08
	jr	NC, 00135$
;monitor.c:227: uint16_t v = 0;
	xor	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
;monitor.c:228: if (!hexstr_to_uint16(a, &v) || v > 0xFF) goto err;
	ld	hl, #12
	add	hl, sp
	push	bc
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_hexstr_to_uint16
	pop	bc
	ld	a, d
	or	a, e
	jp	Z, 00142$
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	a, #0xff
	cp	a, e
	ld	a, #0x00
	sbc	a, d
	jp	C, 00142$
;monitor.c:229: pat[plen++] = v;
	ld	e, -1 (ix)
	inc	-1 (ix)
	ld	a, -1 (ix)
	ld	-4 (ix), a
	ld	d, #0x00
	ld	hl, #4
	add	hl, sp
	add	hl, de
	ld	a, -6 (ix)
	ld	(hl), a
;monitor.c:230: while (*a && *a != ' ') a++;
	ld	e, c
	ld	d, b
00126$:
	ld	a, (de)
	or	a, a
	jr	Z, 00184$
	sub	a, #0x20
	jr	Z, 00184$
	inc	de
	jr	00126$
;monitor.c:231: while (*a == ' ') a++;
00184$:
	ld	c, e
	ld	b, d
00129$:
	ld	a, (de)
	sub	a, #0x20
	jr	NZ, 00133$
	inc	de
	ld	c, e
	ld	b, d
	jr	00129$
00135$:
;monitor.c:234: for (uint16_t i = s; i <= e - plen + 1; i++) {
	pop	bc
	push	bc
00147$:
	ld	e, -4 (ix)
	ld	d, #0x00
	ld	l, -16 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	cp	a, a
	sbc	hl, de
	inc	hl
	ld	e, c
	ld	d, b
	xor	a, a
	sbc	hl, de
	jr	C, 00149$
;monitor.c:235: uint8_t ok = 1;
	ld	-3 (ix), #0x01
;monitor.c:236: for (uint8_t j = 0; j < plen; j++)
	ld	-1 (ix), #0x00
00144$:
	ld	a, -1 (ix)
	sub	a, -4 (ix)
	jr	NC, 00138$
;monitor.c:237: if (*((uint8_t *)(i + j)) != pat[j]) ok = 0;
	ld	l, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	hl, de
	ld	a, (hl)
	ld	-2 (ix), a
	push	de
	ld	e, -1 (ix)
	ld	d, #0x00
	ld	hl, #6
	add	hl, sp
	add	hl, de
	pop	de
;	spillPairReg hl
	ld	a,-2 (ix)
	sub	a,(hl)
	jr	Z, 00145$
	ld	-3 (ix), #0x00
00145$:
;monitor.c:236: for (uint8_t j = 0; j < plen; j++)
	inc	-1 (ix)
	jr	00144$
00138$:
;monitor.c:238: if (ok) {
	ld	a, -3 (ix)
	or	a, a
	jr	Z, 00148$
;monitor.c:239: put_hex(i >> 8); put_hex(i & 0xFF);
	ld	e, b
	push	bc
	ld	a, e
	call	_put_hex
	pop	bc
	ld	e, c
	push	bc
	ld	a, e
	call	_put_hex
	ld	hl, #___str_11
	call	_puts
	pop	bc
00148$:
;monitor.c:234: for (uint16_t i = s; i <= e - plen + 1; i++) {
	inc	bc
;monitor.c:243: return;
	jr	00147$
;monitor.c:244: err:
00142$:
;monitor.c:245: puts(invalid_input);
	ld	hl, #_invalid_input
	call	_puts
00149$:
;monitor.c:246: }
	ld	sp, ix
	pop	ix
	ret
___str_11:
	.db 0x0d
	.db 0x0a
	.db 0x00
;monitor.c:251: static void cmd_reset(void) {
;	---------------------------------
; Function cmd_reset
; ---------------------------------
_cmd_reset:
;monitor.c:253: reset_ptr();
;monitor.c:254: }
	jp	0x0000
;monitor.c:260: void monitor(void) {
;	---------------------------------
; Function monitor
; ---------------------------------
_monitor::
	ld	hl, #-82
	add	hl, sp
	ld	sp, hl
;monitor.c:261: puts("\n");
	ld	hl, #___str_12
	call	_puts
;monitor.c:262: puts(logo);
	ld	hl, #_logo
	call	_puts
00117$:
;monitor.c:264: puts(prompt);
	ld	hl, #_prompt
	call	_puts
;monitor.c:266: read_line(line, 80);
	ld	de, #0x0050
	ld	hl, #0
	add	hl, sp
	call	_read_line
;monitor.c:268: char *a = line;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	iy, #80
	add	iy, sp
	ld	0 (iy), e
	ld	1 (iy), d
;monitor.c:269: while (*a == ' ') a++;  // skip leading spaces
00101$:
	ld	iy, #80
	add	iy, sp
	ld	l, 0 (iy)
	ld	h, 1 (iy)
	ld	a, (hl)
	ld	e, 0 (iy)
	ld	d, 1 (iy)
	inc	de
	cp	a, #0x20
	jr	NZ, 00103$
	ld	0 (iy), e
	ld	1 (iy), d
	jr	00101$
00103$:
;monitor.c:270: char c = toupper(*a++);
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	push	de
	call	_toupper
	ld	c, e
	pop	de
;monitor.c:271: while (*a == ' ') a++;  // skip space between cmd and params
00104$:
	ld	a, (de)
	sub	a, #0x20
	jr	NZ, 00106$
	inc	de
	jr	00104$
00106$:
;monitor.c:273: switch (c) {
	ld	a,c
	cp	a,#0x44
	jr	Z, 00107$
	cp	a,#0x46
	jr	Z, 00109$
	cp	a,#0x47
	jr	Z, 00110$
	cp	a,#0x48
	jr	Z, 00113$
	cp	a,#0x4d
	jr	Z, 00111$
	cp	a,#0x50
	jr	Z, 00108$
	sub	a, #0x58
	jr	Z, 00112$
	jr	00114$
;monitor.c:274: case 'D': cmd_dump(a); break;
00107$:
	ex	de, hl
	call	_cmd_dump
	jr	00117$
;monitor.c:275: case 'P': cmd_poke(a); break;
00108$:
	ex	de, hl
	call	_cmd_poke
	jr	00117$
;monitor.c:276: case 'F': cmd_fill(a); break;
00109$:
	ex	de, hl
	call	_cmd_fill
	jp	00117$
;monitor.c:277: case 'G': cmd_go(a); break;
00110$:
	ex	de, hl
	call	_cmd_go
	jp	00117$
;monitor.c:278: case 'M': cmd_find(a); break;
00111$:
	ex	de, hl
	call	_cmd_find
	jp	00117$
;monitor.c:279: case 'X': cmd_reset(); break;
00112$:
	call	_cmd_reset
	jp	00117$
;monitor.c:280: case 'H': puts(help); break;
00113$:
	ld	hl, #_help
	call	_puts
	jp	00117$
;monitor.c:281: default: puts(unknown_cmd);
00114$:
	ld	hl, #_unknown_cmd
	call	_puts
;monitor.c:282: }
	jp	00117$
;monitor.c:284: }
	ld	hl, #82
	add	hl, sp
	ld	sp, hl
	ret
___str_12:
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
