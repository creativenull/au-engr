;Charles, Wei, Bernardo, Arnold, Andrew
;ENGR385 Microprocessor Systems
;Lab Project
;
; Serial Communication - Program that will communicate serially between two
; boards. When a character is entered on one board (master), the same character
; is echoed on the lcd screen of the other board (slave). This is the program
; for slave.


#include "hcs12_2.asm"
#include "LCD_Driv.asm"


        org $4100
        
        movb    #$04,SPI1BR     ; Set the Baud Rate t o be running at 8 MHz
        movb    #$4D,SPI1CR1    ; set the board to slave with control register 1
        movb    #$00,SPI1CR2    ; In both for second control register

        jsr    lcd_init         ; Initializes the lcd screen and starts
        ldaa   #$80             ; Characters on the first line
        jsr    lcd_cmd

Again   jsr getcspi1            ; Recieves and displays the characters from the
        jsr lcd_out             ; master to the lcd
        bra Again
        

getcspi1 brclr SPI1SR,SPTEF,*    ; wait until write operation is permissible
         staa  SP1DR             ; Trigger clock pulses for spi transfer
         brclr SPI1SR,SPIF,*     ; Wait until the byte is shifted out
         ldaa  SP1DR             ; Return the byte in A and clear the SPIF flag
         rts
         
