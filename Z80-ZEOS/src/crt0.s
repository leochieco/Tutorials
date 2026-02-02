; ============================================================================
; 
;  FILE       : crt0.s
;  AUTHOR     : LeoChieco
;  DATE       : 01 March 2026
;  VERSION    : 1.0
;  PROJECT    : ZEOS
;  DESCRIPTION: toolchain SDCC
; 
; ============================================================================


        .module crt0

        .globl  _main
        .globl  _serial_isr

        .globl  _serial_putc
        .globl  _serial_getc
        .globl  _serial_char_available

; ------------------------------------------------------------
; Reset + RST vectors (absolute)
; ------------------------------------------------------------
        .area   _HEADER (ABS)

; ---- RST 00 : Reset ----------------------------------------
        .org    0x0000
        di
        jp      start

; ---- RST 08 : Console output (char in A) -------------------
        .org    0x0008
        jp      rst_putc

; ---- RST 10 : Console input (blocking, char returned in A) -
        .org    0x0010
        jp      rst_getc

; ---- RST 18 : Console status (A=0 no char, !=0 char avail) -
        .org    0x0018
        jp      rst_kbhit

; ---- IM 1 interrupt vector ---------------------------------
        .org    0x0038
        jp      _serial_isr

; ------------------------------------------------------------
; Code section
; ------------------------------------------------------------
        .area   _CODE

; ------------------------------------------------------------
; Program start (C runtime entry)
; ------------------------------------------------------------
start:
        ld      sp, #0xFFFF      ; STACK  

        call    gsinit           ; initialize .data / .bss

        call    _main            ; enter C world

; ------------------------------------------------------------
; Halt forever (monitor never returns)
; ------------------------------------------------------------
halt:
        di
halt_loop:
        halt
        jr      halt_loop

; ------------------------------------------------------------
; RST 08 – output character
; in:  A = character
; out: none
; ------------------------------------------------------------
rst_putc:
        push    af
        call    _serial_putc
        pop     af
        ret

; ------------------------------------------------------------
; RST 10 – input character (blocking)
; out: A = character
; ------------------------------------------------------------
rst_getc:
        call    _serial_getc
        ret

; ------------------------------------------------------------
; RST 18 – check character available
; out: A = 0 if none, !=0 if available
; ------------------------------------------------------------
rst_kbhit:
        call    _serial_char_available
        ret

; ------------------------------------------------------------
; Required SDCC stubs
; ------------------------------------------------------------
__clock::
        xor     a
        ret

_exit::
        jr      halt_loop

; ------------------------------------------------------------
; Linker segment ordering  
; ------------------------------------------------------------
        .area   _HOME
        .area   _CODE
        .area   _GSINIT
        .area   _GSFINAL
        .area   _DATA
        .area   _BSS
        .area   _HEAP

; ------------------------------------------------------------
; Global/static initialization (filled by SDCC)
; ------------------------------------------------------------
        .area   _GSINIT
gsinit::

        .area   _GSFINAL
        ret