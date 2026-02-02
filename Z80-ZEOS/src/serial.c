/* ============================================================================
 * FILE       : serial.c
 * AUTHOR     : LeoChieco
 * DATE       : 01 March 2026
 * VERSION    : 1.0
 * PROJECT    : ZEOS: Z80 SBC Firmware
 * DESCRIPTION: Serial management based on ACIA 68B50 or eqiovalent
 * ============================================================================
 */

#include "serial.h"
#include "io.h"

#define ACIA_CTRL 0x80
#define ACIA_DATA 0x81

#define SER_BUFSIZE   0x3F
#define SER_FULLSIZE  0x30
#define SER_EMPTYSIZE 5

#define RTS_HIGH 0xD6
#define RTS_LOW  0x96

static volatile uint8_t buf[0x40];
static volatile uint8_t inPtr = 0;
static volatile uint8_t rdPtr = 0;
static volatile uint8_t used  = 0;

/* ----------------------------------- 
 * serial_init
 * -----------------------------------
 */

void serial_init(void)
{
    outb(ACIA_CTRL, RTS_LOW);
}

/* ----------------------------------- 
 * serial_isr (interrupt serial routine)
 * -----------------------------------
 */
void serial_isr(void) __interrupt
{
    uint8_t status = inb(ACIA_CTRL);

    if (status & 0x01) {
        uint8_t c = inb(ACIA_DATA);

        if (used < SER_BUFSIZE) {
            buf[inPtr++] = c;
            inPtr &= SER_BUFSIZE;
            used++;

            if (used >= SER_FULLSIZE)
                outb(ACIA_CTRL, RTS_HIGH);
        }
    }
}

/* ----------------------------------- 
 * serial_char_available
 * -----------------------------------
 */

uint8_t serial_char_available(void)
{
    return used;
}

/* ----------------------------------- 
 * serial_getc
 * -----------------------------------
 */
uint8_t serial_getc(void)
{
    while (!used);

    uint8_t c = buf[rdPtr++];
    rdPtr &= SER_BUFSIZE;

    __asm di __endasm;
    used--;
    if (used < SER_EMPTYSIZE)
        outb(ACIA_CTRL, RTS_LOW);
    __asm ei __endasm;

    return c;
}

/* ----------------------------------- 
 * serial_putc
 * -----------------------------------
 */

void serial_putc(uint8_t c)
{
    while (!(inb(ACIA_CTRL) & 0x02));
    outb(ACIA_DATA, c);
}