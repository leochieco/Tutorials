@echo on
REM ==============================
REM  Build batch for ZEOS Monitor  
REM ==============================

REM ----- Clean up -----
IF EXIST "../build" (
        rmdir /S /Q "../build"
)
mkdir "../build"

cd src


REM ----- Compile crt0 -----
D:\SDCC\bin\sdasz80 -o ../build/crt0.rel crt0.s

REM ----- Compile driver I/O -----
D:\SDCC\bin\sdcc -mz80 --opt-code-size -c io.c -o ../build/io.rel
D:\SDCC\bin\sdcc -mz80 --opt-code-size -c serial.c -o ../build/serial.rel

REM ----- Compile Monitor -----
D:\SDCC\bin\sdcc -mz80 --opt-code-size -c monitor.c -o ../build/monitor.rel


REM ----- Compile main -----
D:\SDCC\bin\sdcc -mz80 --opt-code-size -c main.c -o ../build/main.rel


REM ----- Compile asm_test -----
D:\SDCC\bin\sdasz80 -plosg ../build/asm_test.rel asm_test.asm 

REM ----- Compile c_test -----
D:\SDCC\bin\sdcc -mz80 --no-std-crt0 -c c_test.c -o ../build/c_test.rel
 


REM ----- Link everything in a single .ihx -----
D:\SDCC\bin\sdcc -mz80 --no-std-crt0 -Wl-b_CSTUB=0x1900 --data-loc 0x2000 --code-loc 0x0200 ../build/crt0.rel ../build/io.rel ../build/serial.rel ../build/monitor.rel ../build/main.rel ../build/asm_test.rel ../build/c_test.rel -o ../build/rom.ihx
REM D:\SDCC\bin\sdcc -mz80 --no-std-crt0 ../build/crt0.rel ../build/io.rel ../build/serial.rel ../build/monitor.rel ../build/main.rel -o ../build/rom.ihx

 
 
REM ----- Convert .ihx to flat binary (ROM) -----
D:\SDCC\bin\sdobjcopy -I ihex -O binary ../build/rom.ihx ../build/rom.bin
 
REM ----- Copy file to emulator -----
if not exist D:\z80-master\roms mkdir D:\z80-master\roms

copy /Y D:\progetti_lse\ZEOS\build\rom.ihx D:\z80-master\roms\rom.hex

cd ..


pause

