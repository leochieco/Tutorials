/* ============================================================================
 * FILE       : serial.h
 * AUTHOR     : LeoChieco
 * DATE       : 01 March 2026
 * VERSION    : 1.0
 * PROJECT    : ZEOS: Z80 SBC Firmware
 * DESCRIPTION: Serial management based on ACIA 68B50 or eqiovalent
 * ============================================================================
 */

#ifndef SERIAL_H
#define SERIAL_H

#include <stdint.h>

void serial_init(void);
void serial_isr(void) __interrupt;

uint8_t serial_getc(void);
void serial_putc(uint8_t c);
uint8_t serial_char_available(void);

#endif