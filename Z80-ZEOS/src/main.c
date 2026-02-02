/* ============================================================================
 * FILE       : main.c
 * AUTHOR     : LeoChieco
 * DATE       : 01 March 2026
 * VERSION    : 1.0
 * PROJECT    : ZEOS: Z80 SBC Firmware
 * DESCRIPTION: Main function. 
 *				Enable interrupt mode 1 and call "Monitor"
 * ============================================================================
 */

#include "serial.h"

void monitor(void);

void main(void)
{
    serial_init();
    __asm
        im 1
        ei
    __endasm;

    monitor();
}