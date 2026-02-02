/* ============================================================================
 * FILE       : monitor.c
 * AUTHOR     : LeoChieco
 * DATE       : 01 March 2026
 * VERSION    : 1.0
 * PROJECT    : ZEOS: Z80 SBC Firmware
 * DESCRIPTION: Main monitor routines
 * ============================================================================
 */

#include "serial.h"
#include <stdint.h>
#include <ctype.h>

#define CR 0x0D
#define LF 0x0A
#define CS 0x0C
#define MAX_MEM 0xFFFF

/* ===== STRINGS ===== */

static const char logo[] =
"\x0C"
"\r\n"
"  +-------------------+ \r\n"
"  | ZEOS MONITOR V1.0 | \r\n"
"  +-------------------+ \r\n"
"\r\n";							   
							   

static const char help[] =
"Commands:\r\n"
"D <addr> <len>       : Dump memory in hex + ASCII\r\n"
"P <addr> <v..>       : Poke memory bytes\r\n"
"F <addr> <len> <val> : Fill memory with a value\r\n"
"G <addr>             : Jump to address (go)\r\n"
"M <start> <end> <p..>: Search memory pattern\r\n"
"X                    : Reset system\r\n"
"H                    : Show this help\r\n";

static const char prompt[]           = "Ready\r\n> ";
static const char unknown_cmd[]      = "Unknown command\r\n";
static const char invalid_input[]    = "Invalid input\r\n";
static const char done_msg[]         = "Done\r\n";
static const char memory_overflow[]  = "Memory overflow\r\n";

/* ===== UTILITY ===== */
static void puts(const char *s) {
    while (*s) serial_putc(*s++);
}

static void put_hex(uint8_t b) {
    const char h[] = "0123456789ABCDEF";
    serial_putc(h[b >> 4]);
    serial_putc(h[b & 0x0F]);
}

/* ===== HEX STRING TO UINT16 (returns boolean) ===== */
static int hexstr_to_uint16(const char *s, uint16_t *val) {
    uint16_t result = 0;
    int digits = 0;
    while (*s) {
        char c = toupper(*s);
        uint8_t nibble;
        if (c >= '0' && c <= '9') nibble = c - '0';
        else if (c >= 'A' && c <= 'F') nibble = c - 'A' + 10;
        else break;
        result = (result << 4) | nibble;
        digits++;
        s++;
    }
    if (digits == 0) return 0;  // conversion failed
    *val = result;
    return 1; // OK
}

/* ===== READ LINE ===== */
static void read_line(char *b, int m) {
    int i = 0;
    while (i < m - 1) {
        char c = serial_getc();
        if (c == CR || c == LF) break;
        b[i++] = c;
        serial_putc(c);
    }
    b[i] = 0;
    serial_putc(CR); serial_putc(LF);
}

/* ===== DUMP ===== */
static void cmd_dump(const char *a) {
    uint16_t addr = 0, len = 0;

    while (*a == ' ') a++;
    if (!hexstr_to_uint16(a, &addr)) { puts(invalid_input); return; }

    while (*a && *a != ' ') a++;
    while (*a == ' ') a++;
    if (!hexstr_to_uint16(a, &len)) { puts(invalid_input); return; }

    /* check memory overflow using uint32_t */
    uint32_t end = (uint32_t)addr + (uint32_t)len - 1;
    if (end > MAX_MEM) { puts(memory_overflow); return; }

    for (uint16_t i = 0; i < len; i += 8) {
        char ascii[8];
        for (uint8_t j = 0; j < 8; j++) {
            if (i + j < len) {
                uint8_t v = *((uint8_t *)(addr + i + j));
                put_hex(v); serial_putc(' ');
                ascii[j] = (v >= 0x20 && v <= 0x7E) ? v : '.';
            } else {
                puts("   "); ascii[j] = ' ';
            }
        }
        puts("    ");
        for (uint8_t j = 0; j < 8; j++) serial_putc(ascii[j]);
        puts("\r\n");
    }
}

/* ===== POKE ===== */

static void cmd_poke(const char *a) {
    uint16_t addr = 0;

    // Skip leading spaces
    while (*a == ' ') a++;

    // Parse starting address
    if (!hexstr_to_uint16(a, &addr)) { 
        puts(invalid_input); 
        return; 
    }

    // Move pointer past address
    while (*a && *a != ' ') a++;
    while (*a == ' ') a++;

    // Parse each byte until end of line
    while (*a) {
        uint16_t v = 0;

        // Parse next byte
        if (!hexstr_to_uint16(a, &v) || v > 0xFF) { 
            puts(invalid_input); 
            return; 
        }

        // Check memory overflow BEFORE writing
        if (addr == MAX_MEM) {
            puts(memory_overflow);
            return;
        }
		
		// Write byte
        *((uint8_t *)addr) = (uint8_t)v;
        addr++;

       
        // Skip to next token
        while (*a && *a != ' ') a++;
        while (*a == ' ') a++;
    }

    puts(done_msg);
}



/* ===== FILL ===== */
static void cmd_fill(const char *a) {
    uint16_t addr = 0, len = 0, val = 0;

    while (*a == ' ') a++;
    if (!hexstr_to_uint16(a, &addr)) goto err;
    while (*a && *a != ' ') a++;
    while (*a == ' ') a++;
    if (!hexstr_to_uint16(a, &len)) goto err;
    while (*a && *a != ' ') a++;
    while (*a == ' ') a++;
    if (!hexstr_to_uint16(a, &val) || val > 0xFF) goto err;

    uint32_t end = (uint32_t)addr + (uint32_t)len - 1;
    if (end > MAX_MEM) { puts(memory_overflow); return; }

    for (uint16_t i = 0; i < len; i++)
        *((uint8_t *)(addr + i)) = (uint8_t)val;

    puts(done_msg);
    return;
err:
    puts(invalid_input);
}



/* ===== GO ===== */
static void cmd_go(const char *a) {
    uint16_t addr = 0;
    while (*a == ' ') a++;
    if (!hexstr_to_uint16(a, &addr)) { puts(invalid_input); return; }

    ((void (*)(void))addr)();
	
  //  void (*jmp_ptr)(void) = (void (*)(void))addr;
  //  jmp_ptr();
}



/* ===== FIND ===== */
static void cmd_find(const char *a) {
    uint16_t s = 0, e = 0;

    while (*a == ' ') a++;
    if (!hexstr_to_uint16(a, &s)) goto err;
    while (*a && *a != ' ') a++;
    while (*a == ' ') a++;
    if (!hexstr_to_uint16(a, &e)) goto err;
    while (*a && *a != ' ') a++;
    while (*a == ' ') a++;

    uint8_t pat[8];
    uint8_t plen = 0;
    while (*a && plen < 8) {
        uint16_t v = 0;
        if (!hexstr_to_uint16(a, &v) || v > 0xFF) goto err;
        pat[plen++] = v;
        while (*a && *a != ' ') a++;
        while (*a == ' ') a++;
    }

    for (uint16_t i = s; i <= e - plen + 1; i++) {
        uint8_t ok = 1;
        for (uint8_t j = 0; j < plen; j++)
            if (*((uint8_t *)(i + j)) != pat[j]) ok = 0;
        if (ok) {
            put_hex(i >> 8); put_hex(i & 0xFF);
            puts("\r\n");
        }
    }
    return;
err:
    puts(invalid_input);
}



/* ===== RESET ===== */
static void cmd_reset(void) {
    void (*reset_ptr)(void) = 0;
    reset_ptr();
}




/* ===== MONITOR ===== */
void monitor(void) {
	puts("\n");
    puts(logo);
    for (;;) {
        puts(prompt);
        char line[80];
        read_line(line, 80);

        char *a = line;
        while (*a == ' ') a++;  // skip leading spaces
        char c = toupper(*a++);
        while (*a == ' ') a++;  // skip space between cmd and params

        switch (c) {
            case 'D': cmd_dump(a); break;
            case 'P': cmd_poke(a); break;
            case 'F': cmd_fill(a); break;
            case 'G': cmd_go(a); break;
            case 'M': cmd_find(a); break;
            case 'X': cmd_reset(); break;
            case 'H': puts(help); break;
            default: puts(unknown_cmd);
        }
    }
}