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

NUM1           DS.B  1   ; First number (00-99)
NUM2           DS.B  1   ; Second number (00-99)
OPERATION      DS.B  1   ; Selected arithmetic operation
RESULT         DS.W  1   ;16-bit calculation result
QUOTIENT       DS.B  1   ;Division quotient
REMAINDER      DS.B  1   ; Division remainder

ONES           DS.B  1
TENS:          DS.B  1
HUNDREDS       DS.B  1
THOUSANDS      DS.B  1
NUM1_PROMPT
        DC.B 13,10
        DC.B "Enter first number (00-99): ",0

NUM2_PROMPT
        DC.B 13,10
        DC.B "Enter second number (00-99): ",0

MENU_MSG
        DC.B 13,10
        DC.B "+ Addition",13,10
        DC.B "- Subtraction",13,10
        DC.B "* Multiplication",13,10
        DC.B "/ Division",13,10,0

CHOICE_PROMPT
        DC.B "Choose an operation (+,-,*,/): ",0

INVALID_NUM_MSG
        DC.B 13,10
        DC.B "Invalid number! Try again.",13,10,0

INVALID_OP_MSG
        DC.B 13,10
        DC.B "Invalid operation! Try again.",13,10,0

DIV_ZERO_MSG
        DC.B 13,10
        DC.B "Error: Division by zero.",13,10,0

RESULT_MSG
        DC.B 13,10
        DC.B "Result: ",0

REMAINDER_MSG
        DC.B " Remainder: ",0

REPEAT_PROMPT
        DC.B 13,10
        DC.B "Another calculation? (Y/N): ",0

EXIT_MSG
        DC.B 13,10


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
        ORG   $2000

MAIN:   
        LDS #$2000  ; Initialize the stack pointer
        JSR   TermInit ; Initialize the terminal
        CLRA   ; Initialize variables to zero
        CLRB

        STAA  NUM1
        STAA  NUM2
        STAA  OPERATION
        STD   RESULT
        STAA  QUOTIENT
        STAA  REMAINDER

        STAA  ONES
        STAA  TENS
        STAA  HUNDREDS
        STAA  THOUSANDS

MAIN_LOOP:
        LDD #NUM1_PROMPT
        JSR printf
        JSR   GET_NUM1 ; Read and validate the first number
        LDD #NUM2_PROMPT
        JSR printf
        JSR   GET_NUM2  ; Read and validate the second number

;==================================================
; DISPLAY MENU AND READ OPERATION
;==================================================

OPERATION_LOOP:
        JSR   MENU_MSG ; Display the calculator menu

        JSR   GET_OPERATION   ; Read the selected operation

        STAA  OPERATION   ; Store the selected operation

        CMPA  #'+'  ; Check for addition
        BEQ   DO_ADD
        CMPA  #'-'  ; Check for subtraction
        BEQ   DO_SUB

        CMPA  #'*'   ; Check for multiplication
        BEQ   DO_MUL

        CMPA  #'/' ; Check for division
        BEQ   DO_DIV

        LDD   #INVALID_OP_MSG   ; Display an error for invalid operations
        JSR   printf

        BRA   OPERATION_LOOP   ; Ask the user to select again

;==================================================
; ADDITION
;==================================================
DO_ADD:
        JSR   ADD_NUM ; Call the addition subroutine

        BRA   SHOW_RESULT  ; Display the calculated result

;==================================================
; SUBTRACTION
;==================================================

DO_SUB:
        JSR   SUB_NUM ; Call the subtraction subroutine

       BRA   SHOW_RESULT ; Display the calculated result
;==================================================
; MULTIPLICATION
;==================================================

DO_MUL:
        JSR   MUL_NUM ; Call the multiplication subroutine

        BRA   SHOW_RESULT  ; Display the calculated result

;==================================================
; DIVISION
;==================================================
DO_DIV:
        LDAA  NUM2  ; Check whether the divisor is zero
        BEQ   DIV_ERROR
        JSR   DIV_NUM   ; Call the division subroutine

        BRA   SHOW_RESULT   ; Display the quotient and remainder
;==================================================
; DIVISION BY ZERO ERROR
;==================================================
DIV_ERROR:
        LDD   #DIV_ZERO_MSG  ; Display the division by zero message
        JSR   printf
        BRA   ASK_AGAIN   ; Skip calculation and ask to repeat
;==================================================
; DISPLAY RESULT
;==================================================
SHOW_RESULT:
        JSR   DISPLAY_RESULT
;==================================================
; ASK FOR ANOTHER CALCULATION
;==================================================
ASK_AGAIN:
        JSR   ASK_REPEAT  ; Read the user's Y/N response

        CMPA  #'Y'    ; Repeat if the user enters Y
        BEQ   MAIN_LOOP
        CMPA  #'y'   ; Repeat if the user enters y
        BEQ   MAIN_LOOP
        CMPA  #'N'   ; Exit if the user enters N
        BEQ   EXIT
        CMPA  #'n'  ; Exit if the user enters n
        BEQ   EXIT
        LDD   #INVALID_OP_MSG   ; Reject any other response
        JSR   printf
        BRA   ASK_AGAIN
;==================================================
; SHOW CALCULATOR MENU
;==================================================
SHOW_MENU:
        LDD   #MENU_MSG   ; Print the available operations
        JSR   printf
        LDD   #CHOICE_PROMPT  ; Print the operation prompt
        JSR   printf
        RTS   ; Return to the main program

;==================================================
; EXIT PROGRAM
;==================================================
EXIT:
        LDD   #EXIT_MSG   ; Display the exit message
        JSR   printf
STOP:
        BRA   STOP   ; Stop program execution

;==================================================
; END OF MAIN PROGRAM
;==================================================
    
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
; MULTIPLICATION WILL GO HERE
; DIVISION WILL GO HERE

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
 
