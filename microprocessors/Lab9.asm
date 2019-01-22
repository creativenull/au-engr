; Arnold Chand
; 3/27/2013

; This PWM Program controls the servo motor that are used to controlling small
; robots or remotely controlled toys. The half-way duty cycle of a servo motor
; is 7.5%. The program uses the keypad and a LCD to enter and display the
; duty cycles in percentages, the main purpose of this program is to control
; how fast or how slow should a servo motor go when the duty cycle value is
; added to through the keypad.

#include "DP256reg.asm"
#include "Keypad.asm"
#include "LCD_Drive.asm"

        ; variables stored at $4000
        org     $4000
        
outa    equ     $FF4F
        
num1    rmb     1
num2    rmb     1
num3    rmb     1
result   rmb     2
        
        ; Start Program at $4100
        org         $4100
        
        ; Initialize the keypad interface and the LCD display
        JSR     INITKEY
        JSR     LCD_INIT
        
        ; Enable Timer
        movb    #%10000000,TSCR

        ; set the E Clock to divide by 16 to allow the Period to run at 10,000
        ; cycles
        movb    #%00000100,PWMPRCLK
        
        ; Select Clock A
        movb    #%00000000,PWMCLK
        
        ; set the channel to output when it is the start of the period and go
        ; low when the duty count is reached
        movb    #%00000010,PWMPOL
        
        ; the channel output is left aligned
        movb    #%00000000,PWMCAE
        
        ; Concatenate two 8-bit PWM channels to one 16-bit PWM channel
        ; first 8 bits are high order byte and last 8 bits are low order byte
        movb    #%00010000,PWMCTL

        ; add 10,000 cycles to the period cycle
        movw    #10000,PWMPER0
        
        ; enable the PWM Channel
        ; enabling PWM ch1
        movb    #%00000010,PWME
        
main
        ; output 'Enter Duty Cycles:' to the LCD
        LDAA    #$80                ; DDRAM address Line 1-LEFT
        JSR     LCD_CMD
        LDX     #TITLE                ; Output title on line 1
        JSR     OUTSTRG

MLOOP
        LDAA    #$94                ; DDRAM address Line 3-LEFT
        JSR     LCD_CMD
        
loopme
        ; get first num and display to LCD
        JSR     GETKEY
        staa    num1
        JSR     LCD_OUT
        
        ; clear out any letters before the first num
        ldx     #BLANK
        jsr     OUTSTRG
        
        ; point cursor to next line
        ldaa    #$95
        jsr     LCD_CMD
        
        ; output '.' to the LCD
        ldx     #POINT
        jsr     OUTSTRG

        ; get the second num and display to LCD
        jsr     GETKEY
        staa    num2
        jsr     LCD_OUT
        
        ; get the third num and display to LCD
        jsr     GETKEY
        staa    num3
        jsr     LCD_OUT
        
        ; output '%' to the LCD
        ldx     #PERCENT
        jsr     OUTSTRG
        
        ; Convert the ASCII numbers to one whole number
        ; to do this we multiply first num by 100
        ldaa    num1
        suba    #$30
        ldab    #100
        mul
        std     result  ; store it in out result

        ; then multiply second num by 10
        ldaa    num2
        suba    #$30
        ldab    #10
        mul
        
        ; add and then store to result
        addd    result
        std     result
        
        ; and then finally adding the thrid num with the result
        ldab    num3
        subb    #$30
        clra
        addd    result
        
        ; send duty cycles to the PWM channel
        std     PWMDTY0
        
        ; loop back for different duty cycles
        bra     MLOOP
        
        
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

        ; STRING VARIABLES
TITLE   fcc     'Enter Duty Cycles:'
        fcb     $04

BLANK   fcc     '    '
        fcb     $04
        
POINT   fcc     '.'
        fcb     $04
        
PERCENT fcc     '%'
        fcb     $04
        
        end
