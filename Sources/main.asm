;*****************************************************************
;* Lab1.ASM
;
;Code Entry, Assembly, and Execution 
;(Put your name and date here) 
;--------------------------------------- 
;* -this is the sample code for Lab1
;* -for Full Chip Simulation or Board -- select your target
;* DO NOT DELETE ANY LINES IN THIS TEMPLATE
;* --ONLY FILL IN SECTIONS
;*****************************************************************
; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 
		
;-------------------------------------------------- 
; Equates Section  
;----------------------------------------------------  
ROMStart    EQU  $2000  ; absolute address to place my code

;---------------------------------------------------- 
; Variable/Data Section
;----------------------------------------------------  
            ORG RAMStart   ; loc $1000  (RAMEnd = $3FFF)
; Insert here your data definitions here

sum dc.b 0 ;Sum byte stored here 

       INCLUDE 'utilities.inc'
       INCLUDE 'LCD.inc'

;---------------------------------------------------- 
; Code Section
;---------------------------------------------------- 
            ORG   ROMStart  ; loc $2000
Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9
            JSR   PLL_init      ; initialize PLL  
  endif

;---------------------------------------------------- 
; Insert your code here
;---------------------------------------------------- 
        
;--------------------------------
; Two Digit Calculator
; HCS12 / CodeWarrior
;--------------------------------

        JSR TermInit

;--------------------------------
; Get User Input
;--------------------------------

        LDD #Prompt
        JSR printf

; First number (two digits)

        JSR getchar
        SUBA #$30
        STAA Tens1

        JSR getchar
        SUBA #$30
        STAA Ones1

; Second number (two digits)

        JSR getchar
        SUBA #$30
        STAA Tens2

        JSR getchar
        SUBA #$30
        STAA Ones2

;--------------------------------
; Convert First Number to Decimal
;--------------------------------

        LDAA Tens1
        LDAB #10
        MUL
        ADDB Ones1
        STD Num1

;--------------------------------
; Convert Second Number to Decimal
;--------------------------------

        LDAA Tens2
        LDAB #10
        MUL
        ADDB Ones2
        STD Num2

;--------------------------------
; Calculator Operations
;--------------------------------

; Num1 and Num2 now contain
; the two decimal numbers.

; ADDITION WILL GO HERE
; SUBTRACTION WILL GO HERE
;--------------------------------
; Multiplication: Num1 x Num2
;--------------------------------
Multiply: 
      LDX #Num1
      LDAA 1,x
      LDX #Num2
      LDAB 1,x
      MUL
      STD Result
      RTS
;--------------------------------
; Divide: Num1 x Num2
;--------------------------------
Divide: 
     LDX Num2
     CPX #0
     BEQ error_zero

Done:
        BRA Done

;--------------------------------
; Variables (place in RAM section)
;--------------------------------

Tens1   RMB 1
Ones1   RMB 1
Tens2   RMB 1
Ones2   RMB 1

Num1    RMB 2
Num2    RMB 2

;--------------------------------
; Prompt (place in ROM section)
;--------------------------------

Prompt  DC.B 'Enter four digits: ',0
 
 
;-------End Program Lab#1------------- 

                         
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   Vreset
            DC.W  Entry         ; Reset Vector
 
