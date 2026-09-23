
* = $8000                      ; Cartridge origin address ($8000)

; ------------------------------------------------------------
; CONDITIONAL COMPILATION FLAGS
; ------------------------------------------------------------
HEAVY_HMI       = 0             ; 1 = Enable simulated HMI workload (> 30ms)
                                ; 0 = Standard fast HMI rendering loop

; ------------------------------------------------------------
; COMMODORE 64 CARTRIDGE HEADER ($8000-$8008)
; ------------------------------------------------------------
        .word START             ; Cold start vector (RESET button/Power-on)
        .word START             ; Warm start vector (NMI / RESTORE key)
        .byte $C3,$C2,$CD,$38,$30 ; Magic signature "CBM80" in Screen Codes

; ------------------------------------------------------------
; HARDWARE REGISTERS & SYSTEM CONSTANTS
; ------------------------------------------------------------
BORDER          = $D020         ; VIC-II Border color register
BG              = $D021         ; VIC-II Background color register

VIC_D018        = $D018         ; VIC-II Memory control (Screen/Char base)
VIC_IRQ_ENABLE  = $D01A         ; VIC-II Raster Interrupt mask register
VIC_IRQ_FLAGS   = $D019         ; VIC-II Interrupt request/acknowledge register

CIA1_TA_LO      = $DC04         ; CIA 1 Timer A Counter LSB
CIA1_TA_HI      = $DC05         ; CIA 1 Timer A Counter MSB
CIA1_ICR        = $DC0D         ; CIA 1 Interrupt Control Register
CIA1_CRA        = $DC0E         ; CIA 1 Control Register A (Timer A control)

CIA2_PRA        = $DD00         ; CIA 2 Data Port A (VIC-II RAM Bank selection)

USER_PORT       = $DD01         ; C64 User Port Data Register (PB0-PB7)
USER_DDR        = $DD03         ; C64 User Port Data Direction Register

IRQ_VECTOR      = $0314         ; KERNAL System Hardware IRQ Vector Pointer ($0314/$0315)

SCREEN          = $0400         ; Default Video RAM Base Address (1024 bytes)
COLOR           = $D800         ; Color RAM Base Address (4-bit nibbles per char)

; VIC-II Color Palette Codes
BLACK           = $00
WHITE           = $01
RED             = $02
CYAN            = $03
GREEN           = $05
YELLOW          = $07
GRAY            = $0B

; Screen Codes for Display Rendering
CODE_0          = $30           ; Screen Code for ASCII '0'
CODE_DOT        = $2E           ; Screen Code for ASCII '.'
CODE_SPACE      = $20           ; Screen Code for ASCII Space ' '

CHAR_ON         = $51           ; Solid block glyph (PETSCII 'Q')
CHAR_OFF        = $57           ; Empty block glyph (PETSCII 'W')

; Frame Border Graphics Characters
CHAR_CORNER_TL  = $70           ; Top-Left Corner
CHAR_CORNER_TR  = $6E           ; Top-Right Corner
CHAR_CORNER_BL  = $6D           ; Bottom-Left Corner
CHAR_CORNER_BR  = $7D           ; Bottom-Right Corner
CHAR_HORIZ      = $40           ; Horizontal Frame Line
CHAR_VERT       = $5D           ; Vertical Frame Line

; Timer Initialization for Deterministic Real-Time PLC Scan Cycle
; System: PAL C64 (CPU Clock = 0.985248 MHz -> 1 cycle ≈ 1.015 μs)
; Desired PLC Scan Time = 10.0 ms = 10,000 μs
; Timer Cycles = 10,000 μs * 0.985248 MHz = 9852.48 cycles
TIMER_LOAD_VAL  = 9852          ; Reload value loaded into CIA1 Timer A

; ------------------------------------------------------------
; SCREEN LAYOUT CELL OFFSETS (Relative to $0400)
; ------------------------------------------------------------
TITLE_POS       = 57            ; Line 1, Col 17 ("PLC=64")
PLC_TEXT_POS    = 122           ; Line 3, Col 2  ("PLC RUN")
PLC_HEART_POS   = 130           ; Line 3, Col 10 (Heartbeat Indicator)
INPUT_TEXT_POS  = 202           ; Line 5, Col 2  ("INPUT")
INPUT0_POS      = 242           ; Line 6, Col 2-5 (Inputs 0..3)
INPUT1_POS      = 243
INPUT2_POS      = 244
INPUT3_POS      = 245
OUTPUT_TEXT_POS = 322           ; Line 8, Col 2  ("OUTPUT")
OUTPUT0_POS     = 362           ; Line 9, Col 2-5 (Outputs 0..3)
OUTPUT1_POS     = 363
OUTPUT2_POS     = 364
OUTPUT3_POS     = 365
USAGE_TEXT_POS  = 442           ; Line 11, Col 2 ("PLC USAGE")
USAGE_TENS_POS  = 453           ; Line 11, Col 13 (CPU Usage MS)
USAGE_MS_POS    = 454
USAGE_DOT_POS   = 455
USAGE_TENTH_POS = 456
USAGE_M_POS     = 458           ; "MS" Suffix
USAGE_S_POS     = 459
OVER_TEXT_POS   = 482           ; Line 12, Col 2 ("OVERHEAD BIT")
OVER_VALUE_POS  = 496           ; Line 12, Col 16 (Overrun Flag 0/1)
TRAFFIC_TEXT_POS= 562           ; Line 14, Col 2 ("TRAFFIC LIGHT")
RED_POS         = 604           ; Line 15, Col 4 (Red Light)
YELLOW_POS      = 644           ; Line 16, Col 4 (Yellow Light)
GREEN_POS       = 684           ; Line 17, Col 4 (Green Light)
TR_TIME_TEXT_POS= 722           ; Line 18, Col 2 ("TR TIME")
TR_TIME_VAL_POS = 731           ; Line 18, Col 11 (Timer String X.X S)

; ------------------------------------------------------------
; ZERO PAGE POINTERS
; ------------------------------------------------------------
LINE_PTR        = $FB           ; 16-bit Zero-Page Indirect Pointer ($FB/$FC)

; =====================================================================
; RAM MAP ($C000+) - DUAL-BUFFER SYSTEM ARCHITECTURE
; =====================================================================

; --- 1. REAL-TIME PROCESS DATA BLOCK (MODIFIED EXCLUSIVELY BY PLC IRQ) ---
PROCESS_VARS_START = $C000

PLC_INPUT       = $C000         ; Input Image Table (PB0..PB3 sampled from User Port)
PLC_OUTPUT      = $C001         ; Output Image Table (PB4..PB7 driven to User Port)
HEARTBEAT       = $C002         ; PLC Executive Heartbeat Flag (Toggles at 2 Hz)
TRAFFIC_STATE   = $C003         ; FSM State Index (0 = RED, 1 = GREEN, 2 = YELLOW)
TRAFFIC_LO      = $C004         ; FSM State Cycle Counter Low Byte (10ms steps)
TRAFFIC_HI      = $C005         ; FSM State Cycle Counter High Byte
ELAPSED_LO      = $C006         ; Measured Execution Time Low Byte (Cycles)
ELAPSED_HI      = $C007         ; Measured Execution Time High Byte
OVERHEAD_BIT    = $C008         ; Real-Time Overrun Flag (1 = Execution > 10ms)

PROCESS_VARS_END   = $C009
PROCESS_VARS_SIZE  = PROCESS_VARS_END - PROCESS_VARS_START

; --- 2. SHADOW RAM BUFFER (READ EXCLUSIVELY BY BACKGROUND HMI MAIN LOOP) ---
HMI_BUF_START   = $C100

HMI_PLC_INPUT   = $C100         ; Atomic Snapshot of PLC_INPUT
HMI_PLC_OUTPUT  = $C101         ; Atomic Snapshot of PLC_OUTPUT
HMI_HEARTBEAT   = $C102         ; Atomic Snapshot of HEARTBEAT
HMI_TRAFFIC_STATE = $C103       ; Atomic Snapshot of TRAFFIC_STATE
HMI_TRAFFIC_LO  = $C104         ; Atomic Snapshot of TRAFFIC_LO
HMI_TRAFFIC_HI  = $C105         ; Atomic Snapshot of TRAFFIC_HI
HMI_ELAPSED_LO  = $C106         ; Atomic Snapshot of ELAPSED_LO
HMI_ELAPSED_HI  = $C107         ; Atomic Snapshot of ELAPSED_HI
HMI_OVERHEAD_BIT= $C108         ; Atomic Snapshot of OVERHEAD_BIT

; --- 3. HMI SCRATCHPAD & DISPLAY CALCULATION VARIABLES ---
REM_LO          = $C200         ; Division/Modulo Remainder Low Byte
REM_HI          = $C201         ; Division/Modulo Remainder High Byte
USAGE_THOU      = $C202         ; Intermediate Milliseconds Digit
USAGE_HUND      = $C203         ; Intermediate Tenths of Millisecond Digit
USAGE_TENS_DIG  = $C204         ; Display Character - CPU Usage Tens Digit
USAGE_UNITS_DIG = $C205         ; Display Character - CPU Usage Units Digit
HMI_FLAG        = $C206         ; Synchronization Semaphore (1 = New Snapshot Ready)
HB_COUNTER      = $C207         ; Heartbeat Prescaler (25 cycles = 250ms half-period)
ROW_COUNTER     = $C208         ; Screen Drawing Loop Counter
TR_SEC_DIG      = $C209         ; Traffic Timer Display - Seconds Digit
TR_TENTH_DIG    = $C20A         ; Traffic Timer Display - Tenths of a Second Digit

; ------------------------------------------------------------
; SYSTEM HARDWARE INITIALIZATION
; ------------------------------------------------------------
START:
        sei                     ; Disable Interrupts during critical hardware setup
        cld                     ; Clear Decimal Mode (Enforce pure Binary Arithmetic)
        ldx #$FF                ; Reset CPU Stack Pointer
        txs                     ; SP = $01FF

        ; Configure CIA2 Port A to select VIC-II Bank 0 ($0000-$3FFF)
        lda CIA2_PRA
        and #$FC                ; Clear bits 0-1
        ora #$03                ; Set bits 0-1 = Bank 0
        sta CIA2_PRA

        ; Configure Memory Control Register $D018
        ; Bits 4-7: Video Matrix Base @ $0400 ($1x)
        ; Bits 1-3: Character Generator Base @ $1000 (ROM Uppercase/Graphics)
        lda #$14
        sta VIC_D018

        ; Set Border and Background to Black
        lda #BLACK
        sta BORDER
        sta BG

        ; Disable VIC-II Raster Interrupts (Using CIA1 Timer A instead)
        lda #$00
        sta VIC_IRQ_ENABLE
        sta VIC_IRQ_FLAGS

        ; Clear Video RAM Memory Space ($0400 - $07E7) with Spaces
        lda #CODE_SPACE
        ldx #$00
CLR_SCR:
        sta SCREEN,x
        sta SCREEN+$0100,x
        sta SCREEN+$0200,x
        sta SCREEN+$0300,x
        inx
        bne CLR_SCR

        ; Initialize Color RAM ($D800 - $DBE7) with White Text Attribute
        lda #WHITE
        ldx #$00
CLR_COL:
        sta COLOR,x
        sta COLOR+$0100,x
        sta COLOR+$0200,x
        sta COLOR+$0300,x
        inx
        bne CLR_COL

        jsr DRAW_BORDER         ; Render full screen outer border (40x25 characters)
        jsr DRAW_STATIC_TEXT    ; Render static HMI text labels

        ; Zero-out Process and System RAM Blocks ($C000-$C2FF)
        ldx #$00
        lda #$00
CLR_RAM:
        sta $C000,x
        sta $C100,x
        sta $C200,x
        inx
        bne CLR_RAM

        lda #25                 ; Initialize Heartbeat Prescaler (25 * 10ms = 250ms)
        sta HB_COUNTER

        ; Configure User Port (CIA2 Port B) Direction
        ; PB0..PB3 = Inputs  (%0000)
        ; PB4..PB7 = Outputs (%1111) -> DDR Mask = %11110000 ($F0)
        lda #%11110000
        sta USER_DDR

        ; Configure CIA1 Timer A for Deterministic 10ms Real-Time Interrupts
        lda #$7F                ; Clear all interrupt source masks in CIA1
        sta CIA1_ICR
        lda CIA1_ICR            ; Read ICR to clear pending flags

        ; Load 16-bit Period Reload Value into CIA1 Timer A Registers
        lda #<TIMER_LOAD_VAL
        sta CIA1_TA_LO
        lda #>TIMER_LOAD_VAL
        sta CIA1_TA_HI

        ; Vector KERNAL IRQ Handler ($0314/$0315) to PLC Interrupt Core
        lda #<PLC_IRQ
        sta IRQ_VECTOR
        lda #>PLC_IRQ
        sta IRQ_VECTOR+1

        ; Enable CIA1 Timer A Underflow Interrupt Request
        lda #%10000001          ; Bit 7 = Set, Bit 0 = Timer A Interrupt
        sta CIA1_ICR

        ; Start CIA1 Timer A in Continuous Auto-Reload Mode
        ; Bit 0 = Start, Bit 4 = Force Load, Bit 3 = Continuous
        lda #%00000001
        sta CIA1_CRA

        cli                     ; Re-enable Global Interrupts (PLC Core active)
        jmp MAIN                ; Jump into Background HMI Loop

; =====================================================================
; GRAPHICS ROUTINE: DRAW FULL-SCREEN BORDER (40x25)
; =====================================================================
DRAW_BORDER:
        ; Plot Border Corners
        lda #CHAR_CORNER_TL
        sta SCREEN
        lda #CHAR_CORNER_TR
        sta SCREEN + 39
        lda #CHAR_CORNER_BL
        sta SCREEN + 960
        lda #CHAR_CORNER_BR
        sta SCREEN + 999

        ; Plot Top and Bottom Horizontal Lines
        ldy #1
HORIZ_LOOP:
        lda #CHAR_HORIZ
        sta SCREEN,y
        sta SCREEN + 960,y
        iny
        cpy #39
        bne HORIZ_LOOP

        ; Plot Left and Right Vertical Lines across Rows 1..23
        lda #1
        sta ROW_COUNTER

VERT_LOOP:
        ldy ROW_COUNTER
        lda SCREEN_ROW_LO,y     ; Fetch Row Low Address Pointer
        sta LINE_PTR
        lda SCREEN_ROW_HI,y     ; Fetch Row High Address Pointer
        sta LINE_PTR+1

        lda #CHAR_VERT
        ldy #0
        sta (LINE_PTR),y        ; Left Border Glyph
        ldy #39
        sta (LINE_PTR),y        ; Right Border Glyph

        inc ROW_COUNTER
        lda ROW_COUNTER
        cmp #24
        bne VERT_LOOP

        rts

; =====================================================================
; BACKGROUND MAIN LOOP (NON-REAL-TIME HMI TASK)
; Processes rendering using snapshot buffer ($C100+) without blocking PLC
; =====================================================================
MAIN:
        lda HMI_FLAG            ; Wait for atomic snapshot update flag from PLC IRQ
        beq MAIN
        lda #0
        sta HMI_FLAG            ; Reset sync flag

        lda #CYAN
        sta BORDER              ; Visual Indicator: CYAN border = HMI Task active

        ; Execute HMI Display Subroutines
        jsr HMI_UPDATE_INPUTS
        jsr HMI_UPDATE_OUTPUTS
        jsr HMI_UPDATE_HEARTBEAT
        jsr HMI_UPDATE_TRAFFIC
        jsr DISPLAY_TRAFFIC_TIMER
        jsr COMPUTE_USAGE
        jsr DISPLAY_USAGE
        jsr DISPLAY_OVERHEAD

.if HEAVY_HMI == 1
        ; Insert conditional artificial delay simulating a massive HMI load (>30ms)
        jsr HMI_HEAVY_WORKLOAD
.endif

        lda #BLACK
        sta BORDER              ; Visual Indicator: BLACK border = Idle CPU
        jmp MAIN

.if HEAVY_HMI == 1
; Subroutine to simulate high computation load (~35.5ms CPU execution time)
; Consumes ~35,000 CPU cycles (35,000 * 1.015 μs = 35.52 ms)
HMI_HEAVY_WORKLOAD:
        ldx #70                 ; Outer loop iteration count
HW_LOOP_OUTER:
        ldy #0                  ; Inner loop iterates 256 times
HW_LOOP_INNER:
        dey
        bne HW_LOOP_INNER
        dex
        bne HW_LOOP_OUTER
        rts
.endif

; =====================================================================
; REAL-TIME PLC INTERRUPT CORE (EXECUTES EVERY 10.0 MS EXACTLY)
; Interrupt-driven engine preempts HMI background execution
; =====================================================================
PLC_IRQ:
        lda CIA1_ICR            ; Read and acknowledge CIA1 Interrupt Flag

        lda #RED
        sta BORDER              ; Visual Indicator: RED border = Real-Time PLC Scan

        ; Execute Synchronous Industrial Task Sequence (IEC 61131-3 Cycle)
        jsr INPUT               ; 1. Read Inputs (Process Input Image Table)
        jsr CYCLE               ; 2. Execute Logic Control Code (FSM, Timers)
        jsr OUTPUT              ; 3. Write Outputs (Process Output Image Table)
        jsr TIMER               ; 4. Advance Timers
        jsr CTRL_OVERHEAD       ; 5. Perform Real-Time Execution Diagnostics

        ; -------------------------------------------------------------
        ; ATOMIC DOUBLE-BUFFER SNAPSHOT COPY (Process -> Shadow RAM)
        ; Prevents HMI display tearing and race conditions
        ; -------------------------------------------------------------
        ldx #0
COPY_PROCESS_TO_HMI:
        lda PROCESS_VARS_START,x
        sta HMI_BUF_START,x
        inx
        cpx #PROCESS_VARS_SIZE
        bne COPY_PROCESS_TO_HMI

        ; Notify background loop that a fresh, consistent snapshot is available
        lda #1
        sta HMI_FLAG

.if HEAVY_HMI == 1
        lda #CYAN               ; Restore CYAN border if returning to preempted Heavy HMI
        sta BORDER
.else
        lda #BLACK              ; Restore BLACK border for idle state
        sta BORDER
.endif
        jmp $EA81               ; Exit IRQ via standard KERNAL handler (restores registers)


; =====================================================================
; 1. PLC SCAN STEP: INPUT READING
; =====================================================================
INPUT:
        lda USER_PORT
        and #$0F                ; Mask PB0..PB3 (User Port Inputs)
        sta PLC_INPUT           ; Store in Input Image Register
        rts


; =====================================================================
; 2. PLC SCAN STEP: CONTROL LOGIC & FINITE STATE MACHINE (FSM)
; Timing Targets: RED = 5.0s, GREEN = 6.0s, YELLOW = 2.0s
; =====================================================================
CYCLE:
        ; Prescaler logic for System Heartbeat Flag (2 Hz toggle)
        dec HB_COUNTER
        bne HB_SKIP
        lda #25                 ; Reload prescaler (25 * 10ms = 250ms)
        sta HB_COUNTER
        lda HEARTBEAT
        eor #1                  ; Toggle state bit
        sta HEARTBEAT
HB_SKIP:

        ; Traffic Light Finite State Machine
        lda TRAFFIC_STATE
        beq P_RED               ; State 0: RED
        cmp #1
        be_GREEN:               ; (Handled by branch below)
        cmp #1
        beq P_GREEN             ; State 1: GREEN
        jmp P_YELLOW            ; State 2: YELLOW

P_RED:
        ; Target: 5.0 Seconds = 500 Interrupt Cycles = $01F4
        lda TRAFFIC_HI
        cmp #$01
        bne P_END
        lda TRAFFIC_LO
        cmp #$F4
        bne P_END
        lda #1                  ; Transition state to GREEN (1)
        sta TRAFFIC_STATE
        lda #0                  ; Reset State Timer
        sta TRAFFIC_LO
        sta TRAFFIC_HI
        jmp P_END

P_GREEN:
        ; Target: 6.0 Seconds = 600 Interrupt Cycles = $0258
        lda TRAFFIC_HI
        cmp #$02
        bne P_END
        lda TRAFFIC_LO
        cmp #$58
        bne P_END
        lda #2                  ; Transition state to YELLOW (2)
        sta TRAFFIC_STATE
        lda #0                  ; Reset State Timer
        sta TRAFFIC_LO
        sta TRAFFIC_HI
        jmp P_END

P_YELLOW:
        ; Target: 2.0 Seconds = 200 Interrupt Cycles = $00C8
        lda TRAFFIC_HI
        bne P_END
        lda TRAFFIC_LO
        cmp #$C8
        bne P_END
        lda #0                  ; Transition state back to RED (0)
        sta TRAFFIC_STATE
        lda #0                  ; Reset State Timer
        sta TRAFFIC_LO
        sta TRAFFIC_HI

P_END:
        rts


; =====================================================================
; 3. PLC SCAN STEP: OUTPUT WRITING
; =====================================================================
OUTPUT:
        ; Example logic: Invert Inputs PB0..PB3 and map to PB4..PB7
        lda PLC_INPUT
        eor #$0F                ; Invert bit logic
        asl
        asl
        asl
        asl                     ; Shift to high nibble (PB4..PB7)
        sta PLC_OUTPUT          ; Store in Output Image Register

        ; Write combined I/O state to User Port hardware register
        lda PLC_INPUT
        ora PLC_OUTPUT
        sta USER_PORT
        rts


; =====================================================================
; 4. PLC SCAN STEP: STATE TIMER TICK
; =====================================================================
TIMER:
        inc TRAFFIC_LO          ; Increment LSB of current state timer
        bne TIMER_DONE
        inc TRAFFIC_HI          ; Increment MSB on overflow
TIMER_DONE:
        rts


; =====================================================================
; 5. PLC SCAN STEP: REAL-TIME EXECUTION DIAGNOSTICS & OVERRUN CHECK
; Reads remaining hardware timer cycles to calculate scan duration
; =====================================================================
CTRL_OVERHEAD:
        ; Snapshot remaining cycles in CIA1 Timer A down-counter
        lda CIA1_TA_LO
        sta REM_LO
        lda CIA1_TA_HI
        sta REM_HI

        ; Compute Elapsed Cycles = TIMER_LOAD_VAL - Remaining Counter
        sec
        lda #<TIMER_LOAD_VAL
        sbc REM_LO
        sta ELAPSED_LO
        lda #>TIMER_LOAD_VAL
        sbc REM_HI
        sta ELAPSED_HI

        ; Deduct fixed interrupt response and compensation offset (~35 cycles)
        sec
        lda ELAPSED_LO
        sbc #35
        sta ELAPSED_LO
        lda ELAPSED_HI
        sbc #0
        sta ELAPSED_HI

        ; Check if Elapsed Cycles >= TIMER_LOAD_VAL (Overrun Detection)
        lda ELAPSED_HI
        cmp #>TIMER_LOAD_VAL
        bne CHECK_HI_OK
        lda ELAPSED_LO
        cmp #<TIMER_LOAD_VAL
CHECK_HI_OK:
        bcc NO_OVERLOAD

        lda #1                  ; Set Real-Time Overrun Flag
        sta OVERHEAD_BIT
        rts

NO_OVERLOAD:
        lda #0                  ; Clear Overrun Flag
        sta OVERHEAD_BIT
        rts


; =====================================================================
; HMI RENDERING SUBROUTINES (OPERATE EXCLUSIVELY ON SHADOW RAM)
; =====================================================================
HMI_UPDATE_INPUTS:
        ; Input 0 Display Update
        lda HMI_PLC_INPUT
        and #$01
        beq IN0_OFF
        lda #CHAR_ON
        sta SCREEN + INPUT0_POS
        lda #GREEN
        sta COLOR + INPUT0_POS
        jmp IN1
IN0_OFF:
        lda #CHAR_OFF
        sta SCREEN + INPUT0_POS
        lda #GRAY
        sta COLOR + INPUT0_POS

IN1:    ; Input 1 Display Update
        lda HMI_PLC_INPUT
        and #$02
        beq IN1_OFF
        lda #CHAR_ON
        sta SCREEN + INPUT1_POS
        lda #GREEN
        sta COLOR + INPUT1_POS
        jmp IN2
IN1_OFF:
        lda #CHAR_OFF
        sta SCREEN + INPUT1_POS
        lda #GRAY
        sta COLOR + INPUT1_POS

IN2:    ; Input 2 Display Update
        lda HMI_PLC_INPUT
        and #$04
        beq IN2_OFF
        lda #CHAR_ON
        sta SCREEN + INPUT2_POS
        lda #GREEN
        sta COLOR + INPUT2_POS
        jmp IN3
IN2_OFF:
        lda #CHAR_OFF
        sta SCREEN + INPUT2_POS
        lda #GRAY
        sta COLOR + INPUT2_POS

IN3:    ; Input 3 Display Update
        lda HMI_PLC_INPUT
        and #$08
        beq IN3_OFF
        lda #CHAR_ON
        sta SCREEN + INPUT3_POS
        lda #GREEN
        sta COLOR + INPUT3_POS
        rts
IN3_OFF:
        lda #CHAR_OFF
        sta SCREEN + INPUT3_POS
        lda #GRAY
        sta COLOR + INPUT3_POS
        rts

HMI_UPDATE_OUTPUTS:
        ; Output 0 Display Update
        lda HMI_PLC_OUTPUT
        and #$10
        beq OUT0_OFF
        lda #CHAR_ON
        sta SCREEN + OUTPUT0_POS
        lda #GREEN
        sta COLOR + OUTPUT0_POS
        jmp OUT1
OUT0_OFF:
        lda #CHAR_OFF
        sta SCREEN + OUTPUT0_POS
        lda #GRAY
        sta COLOR + OUTPUT0_POS

OUT1:   ; Output 1 Display Update
        lda HMI_PLC_OUTPUT
        and #$20
        beq OUT1_OFF
        lda #CHAR_ON
        sta SCREEN + OUTPUT1_POS
        lda #GREEN
        sta COLOR + OUTPUT1_POS
        jmp OUT2
OUT1_OFF:
        lda #CHAR_OFF
        sta SCREEN + OUTPUT1_POS
        lda #GRAY
        sta COLOR + OUTPUT1_POS

OUT2:   ; Output 2 Display Update
        lda HMI_PLC_OUTPUT
        and #$40
        beq OUT2_OFF
        lda #CHAR_ON
        sta SCREEN + OUTPUT2_POS
        lda #GREEN
        sta COLOR + OUTPUT2_POS
        jmp OUT3
OUT2_OFF:
        lda #CHAR_OFF
        sta SCREEN + OUTPUT2_POS
        lda #GRAY
        sta COLOR + OUTPUT2_POS

OUT3:   ; Output 3 Display Update
        lda HMI_PLC_OUTPUT
        and #$80
        beq OUT3_OFF
        lda #CHAR_ON
        sta SCREEN + OUTPUT3_POS
        lda #GREEN
        sta COLOR + OUTPUT3_POS
        rts
OUT3_OFF:
        lda #CHAR_OFF
        sta SCREEN + OUTPUT3_POS
        lda #GRAY
        sta COLOR + OUTPUT3_POS
        rts

HMI_UPDATE_HEARTBEAT:
        ; PLC Running Indicator Update
        lda HMI_HEARTBEAT
        beq HB_OFF
        lda #CHAR_ON
        sta SCREEN + PLC_HEART_POS
        lda #GREEN
        sta COLOR + PLC_HEART_POS
        rts
HB_OFF:
        lda #CHAR_OFF
        sta SCREEN + PLC_HEART_POS
        lda #GRAY
        sta COLOR + PLC_HEART_POS
        rts

HMI_UPDATE_TRAFFIC:
        ; Clear all Traffic Lights to inactive status
        lda #CHAR_OFF
        sta SCREEN + RED_POS
        sta SCREEN + YELLOW_POS
        sta SCREEN + GREEN_POS
        lda #GRAY
        sta COLOR + RED_POS
        sta COLOR + YELLOW_POS
        sta COLOR + GREEN_POS

        ; Render active light according to snapshot FSM state
        lda HMI_TRAFFIC_STATE
        beq TR_SHOW_RED
        cmp #1
        beq TR_SHOW_GREEN
        jmp TR_SHOW_YELLOW

TR_SHOW_RED:
        lda #CHAR_ON
        sta SCREEN + RED_POS
        lda #RED
        sta COLOR + RED_POS
        rts

TR_SHOW_GREEN:
        lda #CHAR_ON
        sta SCREEN + GREEN_POS
        lda #GREEN
        sta COLOR + GREEN_POS
        rts

TR_SHOW_YELLOW:
        lda #CHAR_ON
        sta SCREEN + YELLOW_POS
        lda #YELLOW
        sta COLOR + YELLOW_POS
        rts

; Format and plot state timer in "X.X S" format (Seconds and Tenths)
DISPLAY_TRAFFIC_TIMER:
        lda HMI_TRAFFIC_LO
        sta REM_LO
        lda HMI_TRAFFIC_HI
        sta REM_HI

        lda #0
        sta TR_SEC_DIG

; Repeated Subtraction Loop: Subtract 100 cycles per iteration (100 * 10ms = 1.0 second)
TR_SEC_LOOP:
        lda REM_HI
        bne TR_SUB_100
        lda REM_LO
        cmp #100
        bcc TR_SEC_DONE
TR_SUB_100:
        sec
        lda REM_LO
        sbc #100
        sta REM_LO
        lda REM_HI
        sbc #0
        sta REM_HI
        inc TR_SEC_DIG
        jmp TR_SEC_LOOP

TR_SEC_DONE:
        lda #0
        sta TR_TENTH_DIG

; Repeated Subtraction Loop: Subtract 10 cycles per iteration (10 * 10ms = 0.1 seconds)
TR_TENTH_LOOP:
        lda REM_LO
        cmp #10
        bcc TR_CONV_DONE
        sec
        sbc #10
        sta REM_LO
        inc TR_TENTH_DIG
        jmp TR_TENTH_LOOP

TR_CONV_DONE:
        ; Convert Digits to Screen Codes and render "X.X S" string
        lda TR_SEC_DIG
        clc
        adc #CODE_0
        sta SCREEN + TR_TIME_VAL_POS        ; Integer Seconds Digit

        lda #CODE_DOT
        sta SCREEN + TR_TIME_VAL_POS + 1    ; Decimal Point '.'

        lda TR_TENTH_DIG
        clc
        adc #CODE_0
        sta SCREEN + TR_TIME_VAL_POS + 2    ; Tenths of a Second Digit

        lda #$13                            ; PETSCII character 'S'
        sta SCREEN + TR_TIME_VAL_POS + 4
        rts

; =====================================================================
; MATH CONVERSION & DISPLAY RENDERING
; Converts execution cycles to Milliseconds (XX.X ms format)
; =====================================================================
COMPUTE_USAGE:
        lda HMI_ELAPSED_LO
        sta REM_LO
        lda HMI_ELAPSED_HI
        sta REM_HI

        lda #0
        sta USAGE_THOU

; Convert CPU Cycles to integer Milliseconds (1 ms ≈ 985 PAL cycles)
CYCLES_TO_MS_LOOP:
        lda REM_HI
        cmp #>1023
        bne C_CHECK_HI
        lda REM_LO
        cmp #<1023
        bcc CYCLES_TO_MS_DONE
C_CHECK_HI:
        bcc CYCLES_TO_MS_DONE

        sec
        lda REM_LO
        sbc #<1023
        sta REM_LO
        lda REM_HI
        sbc #>1023
        sta REM_HI
        inc USAGE_THOU
        jmp CYCLES_TO_MS_LOOP

CYCLES_TO_MS_DONE:
        lda #0
        sta USAGE_HUND

; Convert remainder cycles to tenths of a millisecond
FRACTION_LOOP:
        lda REM_HI
        bne F_SUB
        lda REM_LO
        cmp #102
        bcc FRACTION_DONE
F_SUB:
        sec
        lda REM_LO
        sbc #102
        sta REM_LO
        lda REM_HI
        sbc #0
        sta REM_HI
        inc USAGE_HUND
        jmp FRACTION_LOOP

FRACTION_DONE:
        ; Separate Tens and Units digits for display
        lda USAGE_THOU
        ldx #0
THOU_TENS_LOOP:
        cmp #10
        bcc THOU_TENS_DONE
        sbc #10
        inx
        jmp THOU_TENS_LOOP
THOU_TENS_DONE:
        sta USAGE_UNITS_DIG
        stx USAGE_TENS_DIG
        rts

DISPLAY_USAGE:
        ; Plot CPU Execution Time string ("XX.X MS")
        lda USAGE_TENS_DIG
        clc
        adc #CODE_0
        sta SCREEN + USAGE_TENS_POS

        lda USAGE_UNITS_DIG
        clc
        adc #CODE_0
        sta SCREEN + USAGE_MS_POS

        lda #CODE_DOT
        sta SCREEN + USAGE_DOT_POS

        lda USAGE_HUND
        clc
        adc #CODE_0
        sta SCREEN + USAGE_TENTH_POS

        lda #$0D                    ; PETSCII 'M'
        sta SCREEN + USAGE_M_POS
        lda #$13                    ; PETSCII 'S'
        sta SCREEN + USAGE_S_POS
        rts

DISPLAY_OVERHEAD:
        ; Plot Overrun Flag State (0 or 1)
        lda HMI_OVERHEAD_BIT
        clc
        adc #CODE_0
        sta SCREEN + OVER_VALUE_POS
        rts

DRAW_STATIC_TEXT:
        ; Plot static UI labels on the screen
        ldx #$00
T_TITLE:
        lda TITLE_TEXT,x
        sta SCREEN + TITLE_POS,x
        inx
        cpx #6
        bne T_TITLE

        ldx #$00
T_PLC:
        lda PLC_TEXT,x
        sta SCREEN + PLC_TEXT_POS,x
        inx
        cpx #7
        bne T_PLC

        ldx #$00
T_IN:
        lda INPUT_TEXT,x
        sta SCREEN + INPUT_TEXT_POS,x
        inx
        cpx #5
        bne T_IN

        ldx #$00
T_OUT:
        lda OUTPUT_TEXT,x
        sta SCREEN + OUTPUT_TEXT_POS,x
        inx
        cpx #6
        bne T_OUT

        ldx #$00
T_USE:
        lda USAGE_TEXT,x
        sta SCREEN + USAGE_TEXT_POS,x
        inx
        cpx #9
        bne T_USE

        ldx #$00
T_OV:
        lda OVER_TEXT,x
        sta SCREEN + OVER_TEXT_POS,x
        inx
        cpx #12
        bne T_OV

        ldx #$00
T_TR:
        lda TRAFFIC_TEXT,x
        sta SCREEN + TRAFFIC_TEXT_POS,x
        inx
        cpx #13
        bne T_TR

        ldx #$00
T_TRT:
        lda TR_TIME_TEXT,x
        sta SCREEN + TR_TIME_TEXT_POS,x
        inx
        cpx #7
        bne T_TRT
        rts

; ------------------------------------------------------------
; SCREEN ROW POINTER LOOKUP TABLES ($0400 BASE)
; ------------------------------------------------------------
SCREEN_ROW_LO:
        .byte <$0400, <$0428, <$0450, <$0478, <$04A0
        .byte <$04C8, <$04F0, <$0518, <$0540, <$0568
        .byte <$0590, <$05B8, <$05E0, <$0608, <$0630
        .byte <$0658, <$0680, <$06A8, <$06D0, <$06F8
        .byte <$0720, <$0748, <$0770, <$0798, <$07C0

SCREEN_ROW_HI:
        .byte >$0400, >$0428, >$0450, >$0478, >$04A0
        .byte >$04C8, >$04F0, >$0518, >$0540, >$0568
        .byte >$0590, >$05B8, >$05E0, >$0608, >$0630
        .byte >$0658, >$0680, >$06A8, >$06D0, >$06F8
        .byte >$0720, >$0748, >$0770, >$0798, >$07C0

; ------------------------------------------------------------
; SCREEN CODE STRING CONSTANTS
; ------------------------------------------------------------
TITLE_TEXT:    .byte $10,$0C,$03,$3D,$36,$34     ; "PLC=64"
PLC_TEXT:      .byte $10,$0C,$03,$20,$12,$15,$0E ; "PLC RUN"
INPUT_TEXT:    .byte $09,$0E,$10,$15,$14         ; "INPUT"
OUTPUT_TEXT:   .byte $0F,$15,$14,$10,$15,$14     ; "OUTPUT"
USAGE_TEXT:    .byte $10,$0C,$03,$20,$15,$13,$01,$07,$05 ; "PLC USAGE"
OVER_TEXT:     .byte $0F,$16,$05,$12,$08,$05,$01,$04,$20,$02,$09,$14 ; "OVERHEAD BIT"
TRAFFIC_TEXT:  .byte $14,$12,$01,$06,$06,$09,$03,$20,$0C,$09,$07,$08,$14 ; "TRAFFIC LIGHT"
TR_TIME_TEXT:  .byte $14,$12,$20,$14,$09,$0D,$05 ; "TR TIME"

; ------------------------------------------------------------
; CARTRIDGE_PADDING (Fills up to 8KB cartridge boundary $A000)
; ------------------------------------------------------------
.fill $A000 - *, $00