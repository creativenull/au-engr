


 ; Group members: Andrew Mejeur,Arnold Chad,Bernardo Martinez.
 ; This is a program that keeps writing and reading to the 6116 so we
 ; can observe CS, WE, OE and A1 ports on the oscilloscope.

#include "DP256reg.asm"     ;register used for ope the ports

CS      equ     $80
OE      equ     $40
WE      equ     $20

        org     $4500

; create a inifinte loop to read and write to the 6116 chip
        clr     ADDR
LP3     ldab    ADDR
        tba
        jsr     WRITE
        jsr     READ
        inc     ADDR
        bclr    ADDR,$F0
        bra     LP3
        
READ
; Where to write and what to write have to be delcared first
        movb    #$00,DDRT   ;sets drrt as imput

        movb    #$FF,DDRP

        ; set CS, We and OE to high, then add the address to PTP
        movb    #$E0,PTP
        addb    #$E0
        STAB    PTP

        bclr    PTP,CS
        bclr    PTP,OE

        ldaa    PTT        ;loads the information contion on PTT to a

        bset    PTP,CS+OE   ;it restarts the process so the cycle can continue

        rts

WRITE
        movb    #$FF,DDRT     ;Set to output
        movb    #$FF,DDRP

        ;same instructions as reading until

        ; set CS, We and OE to high, then add the address to PTP
        movb    #$E0,PTP

        addb    #$E0
        STAB    PTP

        bclr    PTP,CS      ;check for ports to be set low
        BCLR    PTP,WE

        STAA    PTT         ;writes the data to PTT location stablish on writem

        BSET    PTP,CS+WE     ;set ports to high si data can be adresed

        rts
        
ADDR    rmb     1

