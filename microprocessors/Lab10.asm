; Arnold Chand

; This program reads from the Analog port on the HCS12 microcontroller and
; reads the Voltage from there, using a potentiometer we adjust the voltage
; from the port and display the voltage reading to the LCD. The Voltage ranges
; from 5-0 V.

#include "DP256reg.asm"
#include "LCD_Drive.asm"

        ; Predefined Variables for the analog port
C0F     equ     $01

SCF     equ     $80

out2bsp equ     $FF58

        ; Variables
        org     $4000
        
num0    rmb     2
num1    rmb     2
num2    rmb     2
num3    rmb     2

avg     rmb     2

count   equ     205
        
        ; Main Program
        org     $4100
        
        ; initialise LCD
        jsr     LCD_INIT
        
        ; display Title on line 1 of the LCD
        ldaa    #$80
        jsr     LCD_CMD

        ldx     #volts
        jsr     OUTSTRG
        
        ; Configuring the ATD Control Registers
configureATD:
        movb    #$C0,ATD0CTL2
        jsr     wait20us
        movb    #$20,ATD0CTL3
        movb    #$07,ATD0CTL4
        
loop:
        ; start taking values
        movb    #$80,ATD0CTL5

        ; store the first 4 datas that are taken
        ldx     #$4300
        brclr   ATD0STAT,SCF,*
        
        movw    ADR00H,num0
        
        movw    ADR01H,num1

        movw    ADR02H,num2
        
        movw    ADR03H,num3
        
        ; add all the numbers
        ldd     num0
        addd    num1
        addd    num2
        addd    num3
        
        ; divide by 4 to get the average of the 4 numbers
        ldx     #4
        
        idiv
        
        ; store the average
        stx     avg

        ; display the average to the LCD
        jsr     displayLCD

        bra     loop
        
wait20us:
        movb    #$90,TSCR ; enable TCNT and fast timer flag clear

        bset    TIOS,$01 ; enable OC0

        ldd     TCNT ; start an OC0 operation
        addd    #480
        std     TC0
        brclr   TFLG1,C0F,* ; wait for 20 us

        rts
        
displayLCD:
        
        ; display results on line 3 of the LCD
        ldaa    #$94
        jsr     LCD_CMD
        
        ; divide the average number by the count (205)
        ldd     avg
        ldx     #count
        
        idiv

        ; exchange number to display the remainder as the first digit
        exg     X,D
        addb    #$30
        ; display the first digit
        tba
        
        jsr     LCD_OUT

        ; '.'
        ldaa    #$2E
        jsr     LCD_OUT

        ; exchange the number then multiply the result by 10
        exg     D,X
        ldaa    #10
        mul
        
        ldx     #count
        
        ; divide the number again by the count
        idiv
        
        ; and display the remainder as the second digit
        exg     D,X
        addb    #$30
        tba
        jsr     LCD_OUT
        
        ; exchange again and multiply the result again by 10
        exg     D,X
        ldaa    #10
        mul
        
        ; divide the number by the count
        ldx     #count
        
        idiv
        exg     D,X
        addb    #$30
        
        ; display the remainder as the third digit
        tba
        jsr     LCD_OUT
        
        ; 'V'
        ldaa    #$56
        jsr     LCD_OUT

        rts

        ; subroutine to output a string to the LCD
OUTSTRG
        LDAA    0,X
        CMPA    #$04                ; Done yet?
        BEQ     RTN
        JSR     LCD_OUT
        INX
        BRA     OUTSTRG

RTN     RTS

        ; String Variables
volts:
        fcc     'Voltage Meter'
        fcb     04
        
clear:
        fcc     '     '
        fcb     04
        
        end