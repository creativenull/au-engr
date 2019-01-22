;Charles, Wei, Bernardo, Arnold, Andrew
;ENGR385 Microprocessor Systems
;Lab Project
;
; Serial Communication - Program that will communicate serially between two
; boards. When a character is entered on one board (master), the same character
; is echoed on the lcd screen of the other board (slave). This is the program
; for master.

#include "hcs12_2.asm"
#include "Keypad.asm"

        ; Master Program
        org     $4100

        ; Configuring the SPI0 module
        movb    #$04,SPI1BR     ; Set the Baud Rate t o be running at 8 MHz
        movb    #$5D,SPI1CR1    ; set the board to master
        movb    #0,SPI1CR2      ; not using any registers in the second one
        
        ; initialize Keypad
        jsr     initkey

        ; gets the key input from the keypad and sends that data over to the
        ; slave where it will display the data to the LCD.
again
        jsr     getkey
        jsr     PUTCSPI1
        bra     again

        ; putcspi1 uses the SPI1 to control board as master
PUTCSPI1
        brclr   SPI1SR,SPTEF,*   ; wait until write operation is permissible
        staa    SP1DR           ; Output the character to SPI0
        brclr   SPI1SR,SPIF,*   ; wait until the byte is shifted out
        ldaa    SP1DR           ; clear the SPIF flag
        rts
RTN     RTS

        end


