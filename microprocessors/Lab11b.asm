 ;Lab 11
 ;Group members: Andrew Mejeur,Arnold Chad,Bernardo Martinez.
 ;The purpose of this proyect is to realize how static RAM memory works,
 ; how to deal with it from the microprocessor perspective
 ; The program counts with a write routine, read routine and displays for data
 ; it also uses the lcd screen to print, for more info take a look on the lcd
 ; lab
 ; Things to have in mind when lookin the progam
 ; Remember to set ports in or out before sending any data
 ; Remember that at the time of display the write routine put extra garbage
 ;on b so b has to be clear for futher use

;Register file needed in other to interface the devices
#include "DP256reg.asm"
#include "LCD_Driv.asm"

;This variables are set to initialize ports to inactive
CS      equ     $80
OE      equ     $40
WE      equ     $20


;Memory location elaborated to hold variables
        org $4000
        
count   rmb     1

dataM   rmb    16
        fcb    04


; Main program
        org     $4100

       ;This firts part is just initialization of the LCD screen and setting
       ;of values
        jsr     LCD_INIT

        LDAA    #$80                ; DDRAM address Line 1-LEFT
        JSR     LCD_CMD
        LDX     #LCD_Write          ; Output title on line 1
        JSR     OUTSTRG
        
        LDAA    #$94                ; DDRAM address Line 3-LEFT
        JSR     LCD_CMD
        LDX     #LCD_Read           ; Output title on line 3
        JSR     OUTSTRG

main
        jsr     tstLCD   ;testlcd is a loop to start writing and reading


        swi



;/Development of complementary subroutines
;Main subroutine
tstLCD
        JSR     writeM
        JSR     readM
        
        jsr     displayWrite
        jsr     displayRead
        
        rts


        
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

;Read and write sobroutines from memory locations

readM:
        clrb
        ldx     #dataM
        
loopR
        jsr     READ

        staa    1,X+
        
        andb    #$0F ; this and alow us to thro the garbage put on the firsthalf
                      ;of b by the data M
        incb
        cmpb    #15
        ble     loopR

        rts

        
writeM:
        clrb
        ldx     #char
loopW
        ldaa    1,X+
        jsr     WRITE
        andb    #$0F
        incb
        cmpb    #15
        ble     loopW

        rts


;Displays value capture and set them on line stablish
displayWrite
        ldaa    #$C0    ; line 2
        jsr     LCD_CMD
        
        ldx     #char
        jsr     OUTSTRG
        
        rts
        
displayRead
        ; line 4
        ldaa    #$D4
        jsr     LCD_CMD

        ldx     #dataM
        jsr     OUTSTRG
        
        rts
        
; Subroutine to output string to LCD (X is ptr).  Done
; when EOF character ($04) is encountered.
OUTSTRG
        LDAA    0,X
        CMPA    #$04                ; Done yet?
        BEQ     RTN
        JSR     LCD_OUT
        INX
        BRA     OUTSTRG

RTN     RTS

;Some extra varibles for the values and the lcd titles
        ; Char to Write to memory
char    fcc     '0123456789ABCDEF'
        fcb     04

LCD_Write:
        fcc     'Write'
        fcb         04
        
LCD_Read:
        fcc     'Read'
        fcb     04
        
        end
