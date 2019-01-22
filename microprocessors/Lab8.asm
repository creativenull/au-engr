; Lab 8; Andrew Mejeur and Arnold Chand
; Key-LCD.asm  - Simple program that prints "Hello' on line 1 and
; then echos characters from the keypad to the LCD display starting
; on line 3. Keypad.asm is used to input characters from the keypad
; and the LCD_Driver.asm program is useed to control the displpay.
;

#include 	"LCD_Driv.asm"
#include 	"Keypad.asm"

        ; reserve memory for first num, second num and answer
        ORG     $4000
        
fnum    rmb     1
snum    rmb     1
answer  rmb     1

        ; Main Program
        org 	$4100
; Initialize the keypad interface and the LCD display
        JSR     INITKEY
        JSR     LCD_INIT

; Output the title 'Hello' to the LCD display
        LDAA    #$80                ; DDRAM address Line 1-LEFT
        JSR     LCD_CMD
        LDX     #TITLE                ; Output title on line 1
        JSR     OUTSTRG

        ; Get the numbers and output them to the LCD
displayLCD:
        ldaa    #$94
        jsr     LCD_CMD

        ; get first num and output to LCD
        jsr     getkey
        staa    fnum
        JSR     LCD_OUT
        
        ; clear any numbers after the first num
        ldx     #BLANK
        jsr     OUTSTRG
        
        ; start the LCD cursor on the second space in line 3
        ldaa    #$95
        jsr     LCD_CMD
        
        ; output ' + ' after the first num
        jsr     ADD

        ; get second num and output to LCD
	jsr     getkey
        staa    snum
        JSR     LCD_OUT

        ; output ' = ' after the second num
        jsr     EQUAL

        ; perform the add operation
        ldaa    fnum
        suba    #$30
        staa    fnum

        ldaa    snum
        suba    #$30
        staa    snum

        ; add the numbers
        ldaa    fnum
        adda    snum
        daa
        staa    answer
        
        ; logical shift the number four times
        ldaa    answer
        lsra
        lsra
        lsra
	lsra
	
        ; if the number on the left nibble is zero then skip
        ; else add $30 to the number and display the number
        ; back to the LCD
        beq     skip
        adda    #$30
        jsr     LCD_OUT
        ; Displays the answer if it is less then 10
skip
        ldaa    answer
        anda    #$0F
        adda    #$30
        jsr     LCD_OUT
        
        bra     displayLCD

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

        ; displays the word addition at the beginning of the email
TITLE   FCC     'Addition'

        FCB     04
        ; clears the spaces
BLANK:
        fcc     '         '
        fcb     04

ADD:
        ; space
	ldaa    #$20
        JSR     LCD_OUT

        ; plus
        ldaa    #$2B
        JSR     LCD_OUT

        ; space
        ldaa    #$20
        JSR     LCD_OUT
        
        rts

EQUAL:
        ; space
        ldaa    #$20
        JSR     LCD_OUT

        ; equal
        ldaa    #$3D
        JSR     LCD_OUT

        ; space
        ldaa    #$20
        JSR     LCD_OUT
        
        rts
        
        
        
        END



