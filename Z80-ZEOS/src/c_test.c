/* ============================================================================
 * FILE       : c_test.c
 * AUTHOR     : LeoChieco
 * DATE       : 01 March 2026
 * VERSION    : 1.0
 * PROJECT    : ZEOS: Z80 SBC Firmware
 * DESCRIPTION: toolchain SDCC 
 *				How to write a piece of code in C and locate it in a 
 *				specific memory address. 
 * ============================================================================
 */

#include <stdint.h>
#include "serial.h"
 

#pragma codeseg  CSTUB

void tris(void);

void start(void){
	tris();
}

static char board[9];  // 0=empty, 'X' = player, 'O' = CPU

// Wrapper per stampare stringhe costanti
static void puts(const char *s) {
    while (*s) serial_putc(*s++);
}

// ==================== STRINGHE ====================
static const char intro[]      = "TIC-TAC-TOE ASCII\r\n";
static const char instructions[] = "You play X, CPU O\r\nChoose cell 0-8\r\n";
static const char prompt[]     = "Your move: ";
static const char win_user[]   = "You win!\r\n";
static const char win_cpu[]    = "CPU wins!\r\n";
static const char draw_msg[]   = "Draw!\r\n";

// ==================== BOARD ====================
static void draw_board(void) {
    static const char sep[] = "|";
    for (int i = 0; i < 9; i++) {
        char c = board[i] ? board[i] : ('0' + i);
        serial_putc(c);
        if ((i % 3) == 2) puts("\r\n");
        else puts(sep);
    }
    puts("\r\n");
}

// ==================== LOGICA ====================
static char check_win(void) {
    const int lines[8][3] = {
        {0,1,2},{3,4,5},{6,7,8},
        {0,3,6},{1,4,7},{2,5,8},
        {0,4,8},{2,4,6}
    };
    for (int i=0;i<8;i++) {
        char a=board[lines[i][0]];
        char b=board[lines[i][1]];
        char c=board[lines[i][2]];
        if(a && a==b && b==c) return a;
    }
    for(int i=0;i<9;i++) if(!board[i]) return 0;
    return 'D'; // Draw
}

// CPU move: win if possible, block, else first free
static int cpu_move(void) {
    for(int i=0;i<9;i++) {
        if(!board[i]) { board[i]='O'; if(check_win()=='O') return i; board[i]=0; }
    }
    for(int i=0;i<9;i++) {
        if(!board[i]) { board[i]='X'; if(check_win()=='X') { board[i]='O'; return i; } board[i]=0; }
    }
    for(int i=0;i<9;i++) if(!board[i]) { board[i]='O'; return i; }
    return -1;
}

// Legge un numero 0-8 dall'utente
static int get_move(void) {
    while (1) {
        char c = serial_getc();
        if (c >= '0' && c <= '8') {
            serial_putc(c);       // mostra il carattere
            serial_putc('\r');    // ritorno a capo
            serial_putc('\n');    // nuova riga
            return c - '0';
        }
    }
}

// ==================== TRIS GAME ====================

 
void tris(void) {
    // Inizializza board
    for(int i=0;i<9;i++) board[i]=0;

    // Intro
    puts(intro);
    puts(instructions);

    while(1) {
        draw_board();
        puts(prompt);

        // Mossa utente
        int move = get_move();
        if(board[move]) continue;
        board[move]='X';

        char result = check_win();
        if(result) {
            draw_board();
            if(result=='X') puts(win_user);
            else if(result=='O') puts(win_cpu);
            else puts(draw_msg);
            return;
        }

        // Mossa CPU
        cpu_move();

        result = check_win();
        if(result) {
            draw_board();
            if(result=='X') puts(win_user);
            else if(result=='O') puts(win_cpu);
            else puts(draw_msg);
            return;
        }
    }
}

 
/* 
void asm_test(void)
{
    const char *s = "HELLO FROM C AT 1900h\r\n";
	
    while (*s) {
        serial_putc(*s++);
    }
}
*/

 
 

 