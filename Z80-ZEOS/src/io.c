/* ============================================================================
 * FILE       : io.c
 * AUTHOR     : LeoChieco
 * DATE       : 01 March 2026
 * VERSION    : 1.0
 * PROJECT    : ZEOS: Z80 SBC Firmware
 * DESCRIPTION: Z80 port input and output 
 * ============================================================================
 */

#include "io.h"

/*
	EXPLANATION 

	ld c,a: SDCC puts the first parameter of an 8-bit function in register A for __naked. 
	We copy the port number into register C, because the Z80 instruction in a,(c) reads from the port specified by C.

	in a,(c): Reads a byte from I/O port C and puts it in register A.

	ret: Returns to the caller.

	On Z80, the return value of an 8-bit C function is in A, so it's already correct.

*/

uint8_t inb(uint8_t port) __naked {
    port;
    __asm
        ld c,a
        in a,(c)
        ret
    __endasm;
}


/*
	EXPLANATION 

	ld c,a: port is in A (first parameter), we copy it to C
	
	ld a,l: value to write is in register L (second parameter)
	
	out (c),a: writes A to the port indicated by C
	
	ret: returns to the caller
*/

void outb(uint8_t port, uint8_t val) __naked {
    port; val;
    __asm
        ld c,a
        ld a,l
        out (c),a
        ret
    __endasm;
}