; Arnold Chand
; 2/26/2013

; This program examines the memory locations $FC00 to $FCFF, it examines the
; memory locations in groups of 16. It uses the hardware interupt IRQ as a
; gate, each time the IRQ is grounded(gate = 1) another group of 16 memory
; locations will be examined. For every 16 memory locations we search for
; the number 5 in the higher or lower nibble of a byte , once it is found we
; print out the address and the byte found to have 5. Once it has examined all
; the location the program will simply end.

; addresses to check
startad equ     $FC00
endad   equ     $FCFF

; subroutines to print the address and value in that address
out2bsp equ     $FF58
out1bsp equ     $FF55

; subroutines to print the right half nibble or the left half nibble of a byte
outrhlf equ     $FF4C
outlhlf equ     $FF49

; subroutines to print ASCII string (printStr) and ASCII charater (outa)
printStr equ    $FF5E
outa    equ     $FF4F



; Stack pointer address
pointer equ     $4050

        ; Initialize Variables, Strings and counters
        org     $4000
printL  fcc     "Line #"
        fcb     04

; counters, (mainCount) to count in the (main) subroutine
; (smCount) to count in the (checkMem) subroutine
mainCount rmb   1
smCount rmb     1

; temporary byte for X
tempx   rmb     2

; gate byte for the interupt routine
gate    rmb     1

        ; start the MAIN PROGRAM
        org     $4100
        movw    #intaddr,$3FF2  ; IRQ interupt vector
        movb    #$C0,$001E      ; IRQ enable

        ; clear any interupts
        cli

        ; main counter = 0
        clr     mainCount

        ; initialise stack pointer address
        lds     #pointer
        
        ; load the addresses that needs to be checked
        ldx     #startad
        
        ; start (main) SUBROUTINE
main        movb    #$FF,gate

        ; check for a hardware interupt
again   tst     gate
        bne     again
        
        ; JUMP to subroutine (printLine), once the interupt is set, to print
	; the line #
        jsr     printLine

        ; 16 memory address counter = 0
        clr     smCount
        
        ; load the value from the memory address
sm      ldaa    0,X
        
        ; JUMP to subroutine (checkMem) to check nibbles for 5
        jsr     checkMem
        
        ; go to the next memory address
        inx
        
        ; increment counter
        inc     smCount
        
        ; check for the counter to be <= 16
        ldaa    smCount
        cmpa    #$0F
        bls     sm
        
        ; JUMP to delay subroutine
        jsr     delay
        
        ; increment main counter
        inc     mainCount
        
        ; loop again until memory address = $FCFF
        cpx     #endad
        bls     main
        
        ; once memory address has reach $FCFF then end the program
        swi

; this ROUTINE clears the gate when it is interupted
intaddr:
        clr     gate
        rti


; this SUBROUTINE prints the line number,eg "Line #1: ..."
printLine:
        ; save the value in X
        pshx
        
        ; Print line #
        ldx     #printL
        jsr     printStr

        pulx
        
        ; print #
        ldaa    mainCount
        jsr     outrhlf
        
        ldaa    #$3A
        jsr     outa
        
        ldaa    #$20
        jsr     outa
        
        rts     ; return to (main)

; this SUBROUTINE checks the value in a memory location to see if the value's
; high or low nibble contains the number 5
checkMem:
        psha
        
        ; if the lower nibble has 5 then print address along with the value
        anda    #$0F
        cmpa    #$05
        beq     print

        ; if the higher nibble has 5 then print address along with the value
        pula
        anda    #$F0
        cmpa    #$50
        beq     pprint
        
        rts     ; return to (main)

        ; JUMP to (printAddr) to print the address and the value
print   pula
pprint  jsr     printAddr
        
        rts     ; return to (main)
        
; this SUBROUTINE prints the address and the value that contains the number 5
printAddr:
        pshx

        ; print the address
        stx     tempx
        ldx     #tempx
        jsr     out2bsp

        ; print the value
        ldx     tempx
        jsr     out1bsp
        
        pulx

        rts     ; return to (main)
        
; this SUBROUTINE delays the (main) subroutine for a couple of milliseconds
; so that it doe not let the interupt be called untimely
delay:
        ; save the values in X and Y
        pshy
        pshx
        
        ; load the seconds
        ldy     #50
delay1  ldx     #10000
        ; start the delay countdown
delay2:
        dex
        bne     delay2
        dey
        bne     delay1
        
        ; load back whatever is in X and Y
        pulx
        puly
        
        rts     ; return to (main)

        end