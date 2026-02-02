; ============================================================================
;  FILE       : asm_test.asm
;  AUTHOR     : LeoChieco
;  DATE       : 01 March 2026
;  VERSION    : 1.0
;  PROJECT    : ZEOS
;  DESCRIPTION: toolchain SDCC 
;				How to write a piece of code in assembler and locate it in a 
;				specific memory address. 	
; ============================================================================

.module asm_test
.globl _serial_putc

.area _STUB (ABS)
.org 0x1800

start:

	push af        
	push hl        

    ld hl,#msg

loop:
    ld a,(hl)
    or a
    jr z,done

    push hl        ; salva puntatore stringa
    ld l,a         ; parametro in L (SDCC ABI)
    call _serial_putc
    pop hl         ; ripristina HL

    inc hl
    jr loop

done:
	pop hl          
	pop af          
    ret

msg:
    .ascii "HELLO FROM 1800h\r\n"
    .db 0
