; Arnold Chand
; 3/1/2013
; This program plays a music, by creating a music sheet at location $4000
; and then the program (at $4100) plays the melody. In creating a music sheet
; the hex values are the notes and the decimal values are how long the note
; before it, plays until the next note.

#include "DP256reg.asm"

        ; create the music sheet
        org     $4000
music   db      $1E,30,$1E,30,$1E,10,$1C,20,$1B,30,$1B,20,$1C,20,$1B,20,$1A,20,$19,50,$15,30,$15,10,$19,30,$19,10,$1B,30,$1B,10,$1E,50,$19,30,$1A,30,$1B,30,$1C,30,$1E,30,$80

        ; initialise pointer
pointer equ     $4050
        
        ; start program
        org     $4100
        
        ; set toggle to be the hardware interupt to stop the music
        movw    #toggle,$3FF0
        
        ; enable real time interupt
        movb    #$80,CRGINT
        
        ; clear IRQ interupt
        movb    #$80,CRGFLG
        
        ; set all ports in PTT to be on
        movb    #$FF,DDRT
        
        ; load stack pointer address
        lds     #$4050
        
        cli

startover:
        ; load the music sheet
        ldx     #music
loop:
        ; start getting the notes
        ldaa    1,X+
        
        ; if the notes values are $80 then go to the next notes
        cmpa    #$80
        beq     startover
        
        ;
        staa    RTICTL
        
        ; load the delay time according to the music sheet
        ldaa    1,X+
        jsr     delay   ; start the delay
        bra     loop    ; repeat for the next note and repeat the whole song
        
; this SUBROUTINE toggles the PT0 port
toggle:
        com     PTT
        movb    #$80,CRGFLG  ; clear IRQ interupt
        rti
        
        
; this SUBROUTINE delays how long the next note will play at
delay:
        ; save the value in X to the stack
        pshx
delay1  ldx     #10000
        ; start the delay countdown
delay2:
        dex
        bne     delay2
        deca
        bne     delay1

        ; load back whatever is in X
        pulx
        
        rts