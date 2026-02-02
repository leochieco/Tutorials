/* ============================================================================
 * FILE       : io.h
 * AUTHOR     : LeoChieco
 * DATE       : 01 March 2026
 * VERSION    : 1.0
 * PROJECT    : ZEOS: Z80 SBC Firmware
 * DESCRIPTION: Z80 port input and output 
 * ============================================================================
 */

#ifndef IO_H
#define IO_H

#include <stdint.h>

uint8_t inb(uint8_t port);
void outb(uint8_t port, uint8_t val);

#endif