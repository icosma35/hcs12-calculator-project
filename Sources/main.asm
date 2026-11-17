
;*****************************************************************
;* Lab1.ASM
;* Two-Digit Calculator - HCS12 / CodeWarrior
;* Integrated Team Project
;*****************************************************************

; Export symbols
            XDEF Entry, _Startup
            ABSENTRY Entry

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'

;----------------------------------------------------
; Equates Section
;----------------------------------------------------
ROMStart    EQU $2000

;----------------------------------------------------
; Variable/Data Section (RAM)
;----------------------------------------------------
            ORG RAMStart

NUM1          DS.B 1    ; First number (00-99)
NUM2          DS.B 1    ; Second number (00-99)
OPERATION     DS.B 1    ; Selected operation
RESULT        DS.W 1    ; 16-bit result
QUOTIENT      DS.B 1    ; Division quotient
REMAINDER     DS.B 1    ; Division remainder

TENS1         DS.B 1    ; Tens digit of NUM1
ONES1         DS.B 1    ; Ones digit of NUM1
TENS2         DS.B 1    ; Tens digit of NUM2
ONES2         DS.B 1    ; Ones digit of NUM2

NEGATIVE_FLAG DS.B 1    ; Negative result indicator
TEMP_RESULT   DS.W 1    ; Temporary result
DIGIT_COUNT   DS.B 1    ; Number of digits to print

            INCLUDE 'utilities.inc'
            INCLUDE 'LCD.inc'

;----------------------------------------------------
; Code Section (ROM)
;----------------------------------------------------
            ORG ROMStart

Entry:
_Startup:

 ifdef _HCS12_SERIALMON
            CLR  $11
            LDAB #$39
            STAB $10
            LDAA #$09
            STAA $12
            JSR  PLL_init
 endif

            JMP MAIN

;====================================================
; PROMPTS AND MESSAGES
;====================================================

NUM1_PROMPT:
            DC.B 13,10
            DC.B "Enter first number (00-99): ",0

NUM2_PROMPT:
            DC.B 13,10
            DC.B "Enter second number (00-99): ",0

MENU_MSG:
            DC.B 13,10
            DC.B "===== CALCULATOR =====",13,10
            DC.B "+ Addition",13,10
            DC.B "- Subtraction",13,10
            DC.B "* Multiplication",13,10
            DC.B "/ Division",13,10,0

CHOICE_PROMPT:
            DC.B "Choose an operation (+,-,*,/): ",0

INVALID_NUM_MSG:
            DC.B 13,10
            DC.B "Invalid number! Try again.",13,10,0

INVALID_OP_MSG:
            DC.B 13,10
            DC.B "Invalid operation! Try again.",13,10,0

INVALID_REPEAT_MSG:
            DC.B 13,10
            DC.B "Please enter Y or N.",13,10,0

DIV_ZERO_MSG:
            DC.B 13,10
            DC.B "Error: Division by zero.",13,10,0

RESULT_MSG:
            DC.B 13,10
            DC.B "Result: ",0

REMAINDER_MSG:
            DC.B " Remainder: ",0

REPEAT_PROMPT:
            DC.B 13,10
            DC.B "Another calculation? (Y/N): ",0

EXIT_MSG:
            DC.B 13,10
            DC.B "Calculator closed.",13,10,0

;====================================================
; MAIN PROGRAM
;====================================================

MAIN:
            LDS  #$3FFF
            JSR  TermInit

MAIN_LOOP:
            CLR  NUM1
            CLR  NUM2
            CLR  OPERATION
            CLR  NEGATIVE_FLAG
            CLR  REMAINDER
            LDD  #0
            STD  RESULT

            ; Get first number
            LDD  #NUM1_PROMPT
            JSR  printf
            JSR  GET_NUM1

            ; Get second number
            LDD  #NUM2_PROMPT
            JSR  printf
            JSR  GET_NUM2

;====================================================
; SELECT OPERATION
;====================================================

OPERATION_LOOP:
            JSR  SHOW_MENU
            JSR  GET_OPERATION
            STAB OPERATION

            CMPB #'+'
            BEQ  DO_ADD

            CMPB #'-'
            BEQ  DO_SUB

            CMPB #'*'
            BEQ  DO_MUL

            CMPB #'/'
            BEQ  DO_DIV

            LDD  #INVALID_OP_MSG
            JSR  printf
            BRA  OPERATION_LOOP

;====================================================
; ARITHMETIC ROUTINE CALLS
;====================================================

DO_ADD:
            JSR  ADD_NUM
            JMP  SHOW_RESULT

DO_SUB:
            JSR  SUB_NUM
            JMP  SHOW_RESULT

DO_MUL:
            JSR  MUL_NUM
            JMP  SHOW_RESULT

DO_DIV:
            TST  NUM2
            BEQ  DIV_ERROR
            JSR  DIV_NUM
            JMP  SHOW_RESULT

DIV_ERROR:
            LDD  #DIV_ZERO_MSG
            JSR  printf
            JMP  ASK_AGAIN

;====================================================
; DISPLAY RESULT
;====================================================

SHOW_RESULT:
            JSR  DISPLAY_RESULT

;====================================================
; ASK FOR ANOTHER CALCULATION
;====================================================

ASK_AGAIN:
            LDD  #REPEAT_PROMPT
            JSR  printf
            JSR  getchar

            CMPB #'Y'
            BEQ  RESTART
            CMPB #'y'
            BEQ  RESTART

            CMPB #'N'
            BEQ  EXIT
            CMPB #'n'
            BEQ  EXIT

            LDD  #INVALID_REPEAT_MSG
            JSR  printf
            BRA  ASK_AGAIN

RESTART:
            JMP  MAIN_LOOP

EXIT:
            LDD  #EXIT_MSG
            JSR  printf

STOP:
            BRA  STOP

;====================================================
; SHOW MENU
;====================================================

SHOW_MENU:
            LDD  #MENU_MSG
            JSR  printf

            LDD  #CHOICE_PROMPT
            JSR  printf
            RTS

;====================================================
; GET FIRST NUMBER
;====================================================

GET_NUM1:
READ_FIRST:
            JSR  getchar
            JSR  putchar
            CMPB #'0'
            BLO  FIRST_INVALID
            CMPB #'9'
            BHI  FIRST_INVALID
            SUBB #'0'
            STAB TENS1

            JSR  getchar
            JSR  putchar
            CMPB #'0'
            BLO  FIRST_INVALID
            CMPB #'9'
            BHI  FIRST_INVALID
            SUBB #'0'
            STAB ONES1

            LDAA TENS1
            LDAB #10
            MUL
            ADDB ONES1
            STAB NUM1
            RTS

FIRST_INVALID:
            LDD  #INVALID_NUM_MSG
            JSR  printf
            LDD  #NUM1_PROMPT
            JSR  printf
            BRA  READ_FIRST

;====================================================
; GET SECOND NUMBER
;====================================================

GET_NUM2:
READ_SECOND:
            JSR  getchar
            JSR  putchar
            CMPB #'0'
            BLO  SECOND_INVALID
            CMPB #'9'
            BHI  SECOND_INVALID
            SUBB #'0'
            STAB TENS2

            JSR  getchar
            JSR  putchar
            CMPB #'0'
            BLO  SECOND_INVALID
            CMPB #'9'
            BHI  SECOND_INVALID
            SUBB #'0'
            STAB ONES2

            LDAA TENS2
            LDAB #10
            MUL
            ADDB ONES2
            STAB NUM2
            RTS

SECOND_INVALID:
            LDD  #INVALID_NUM_MSG
            JSR  printf
            LDD  #NUM2_PROMPT
            JSR  printf
            BRA  READ_SECOND

;====================================================
; GET OPERATION
;====================================================

GET_OPERATION:
            JSR  getchar
            RTS

;====================================================
; ADDITION
;====================================================

ADD_NUM:
            CLR  NEGATIVE_FLAG
            CLRA
            LDAB NUM1
            ADDB NUM2
            ADCA #0
            STD  RESULT
            RTS

;====================================================
; SUBTRACTION
;====================================================

SUB_NUM:
            CLR  NEGATIVE_FLAG

            LDAA NUM1
            CMPA NUM2
            BHS  SUB_POSITIVE

            LDAA #1
            STAA NEGATIVE_FLAG

            LDAA NUM2
            SUBA NUM1
            BRA  SUB_STORE

SUB_POSITIVE:
            LDAA NUM1
            SUBA NUM2

SUB_STORE:
            TAB
            CLRA
            STD  RESULT
            RTS

;====================================================
; MULTIPLICATION
;====================================================

MUL_NUM:
            CLR  NEGATIVE_FLAG

            LDAA NUM1
            LDAB NUM2
            MUL

            STD  RESULT
            RTS

;====================================================
; DIVISION
;====================================================

DIV_NUM:
            CLR  NEGATIVE_FLAG

            LDX  #0
            LDAB NUM1
            ABX

            CLRA
            LDAB NUM2
            IDIV

            STAB REMAINDER

            TFR  X,D
            STAB QUOTIENT
            STD  RESULT
            RTS

;====================================================
; DISPLAY RESULT
;====================================================

DISPLAY_RESULT:
            LDD  #RESULT_MSG
            JSR  printf

            TST  NEGATIVE_FLAG
            BEQ  DISPLAY_POSITIVE

            LDAB #'-'
            JSR  putchar

DISPLAY_POSITIVE:
            LDD  RESULT
            STD  TEMP_RESULT

            CLR  DIGIT_COUNT

CONVERT_LOOP:
            LDX  TEMP_RESULT
            LDD  #10
            IDIV

            ADDB #'0'
            PSHB
            INC  DIGIT_COUNT

            STX  TEMP_RESULT
            CPX  #0
            BNE  CONVERT_LOOP

PRINT_LOOP:
            PULB
            JSR  putchar
            DEC  DIGIT_COUNT
            BNE  PRINT_LOOP

            LDAA OPERATION
            CMPA #'/'
            BNE  RESULT_DONE

            LDD  #REMAINDER_MSG
            JSR  printf

            CLRA
            LDAB REMAINDER
            STD  TEMP_RESULT

            CLR  DIGIT_COUNT

REM_CONVERT:
            LDX  TEMP_RESULT
            LDD  #10
            IDIV

            ADDB #'0'
            PSHB
            INC  DIGIT_COUNT

            STX  TEMP_RESULT
            CPX  #0
            BNE  REM_CONVERT

REM_PRINT:
            PULB
            JSR  putchar
            DEC  DIGIT_COUNT
            BNE  REM_PRINT

RESULT_DONE:
            RTS

;====================================================
; INTERRUPT VECTOR
;====================================================
            ORG Vreset
            DC.W Entry

;================ END PROGRAM ======================
