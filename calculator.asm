TITLE ASM Calculator		(calculator.asm)

; Author: Mathew McDade
; Date: 01/17/2018 8:42:26 PM
; Description: The following is an assembly langauge program that takes two integers from user input and returns the sum,
;	difference, product, and quotient with remainder of those two integers.
; Extra Credit: This program also detects and notifies the user if the second integer is larger than the first, return a
;	floating point quotient of the two integers, and loop the program until the user enters the appropriate key command
;	to quit.


INCLUDE Irvine32.inc


.data
; Output Messages
msg_Intro			BYTE	"Program 1: Elementary Arithmetic		by Mathew McDade",0
msg_EC_1			BYTE	"Extra Credit 1: Program will repeat until the user chooses to quit.",0
msg_EC_2			BYTE	"Extra Credit 2: Program verifies that the second number is less than the first.",0
msg_EC_3			BYTE	"Extra Credit 3: Program calculates and displays the quotient as a rounded floating point number.",0
msg_InputPrompt		BYTE	"Please enter two integers, and I'll give you the sum, difference, product, quotient, and floating point quotient of those numbers",0
msg_Num1			BYTE	"First Number: ",0
msg_Num2			BYTE	"Second Number: ",0
msg_EC_2_error		BYTE	"Sorry, the second number must be less than the first! Try again.",0
msg_Sum				BYTE	"Sum: ",0
msg_Difference		BYTE	"Difference: ",0
msg_Product			BYTE	"Product: ",0
msg_Quotient		BYTE	"Integer Quotient: ",0
msg_Remainder		BYTE	"Remainder: ",0
msg_FP_Quotient		BYTE	"Floating-point Quotient: ",0
decimalpoint		BYTE	".",0
msg_LoopOffer		BYTE	"Enter '1' to go again, any other number to exit: ",0
msg_Exit			BYTE	"Thanks for playing!",0

; User Inputs
int1				DWORD	?
int2				DWORD	?

; Result Variables
sum					DWORD	?
difference			DWORD	?
product				DWORD	?
quotient			DWORD	?
remainder			DWORD	?
remainder_decimal	DWORD	?


.code
main PROC

; Introduction
	mov		edx, OFFSET msg_Intro
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET msg_EC_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET msg_EC_2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET msg_EC_3
	call	WriteString
	call	CrLf

; Get two integers from user
Prompt:
	call	CrLf
	mov		edx, OFFSET msg_InputPrompt
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OffSET msg_Num1
	call	WriteString
	call	ReadInt
	mov		int1, eax

	mov		edx, OFFSET msg_Num2
	call	WriteString
	call	ReadInt
	mov		int2, eax

	call	CrLf
	call	CrLf

; Compare int1 and int2 for extra credit #2.
	mov		eax, int1
	cmp		eax, int2
	ja		Calculations				;jumps to the Calculations section if int1 is greater than int2, otherwise prints the error message and returns to Prompt section.

	mov		edx, OFFSET msg_EC_2_error
	call	WriteString
	call	CrLf
	call	CrLf
	jmp		Prompt

; Make calculations
Calculations:
; Calculate Sum
	mov		eax, int1
	add		eax, int2
	mov		sum, eax
; Calculate Difference
	mov		eax, int1
	sub		eax, int2
	mov		difference, eax
; Calculate Product
	mov		eax, int1
	mul		int2
	mov		product, eax
; Calculate Quotient and Remainder
	mov		eax, int1
	div		int2
	mov		quotient, eax
	mov		remainder, edx

; Calculate Floating-point Quotient for Extra Credit 3
	mov		eax, remainder
	mov		ebx, 1000
	mul		ebx
	div		int2
	mov		remainder_decimal, eax

; Output results
	mov		edx, OFFSET msg_Sum
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf

	mov		edx, OFFSET msg_Difference
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLf

	mov		edx, OFFSET msg_Product
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf

	mov		edx, OFFSET msg_Quotient
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	call	CrLf
	mov		edx, OFFSET msg_Remainder
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf

	mov 	edx, OFFSET msg_FP_Quotient
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET decimalpoint
	call	WriteString
	mov		eax, remainder_decimal
	call	WriteDec
	call	CrLf
	call	CrLf

; Offer loop
	mov		edx, OFFSET msg_LoopOffer
	call	WriteString
	call	ReadInt
	cmp		eax, 1
	je		Prompt
	call	CrLf

; Exit program
	mov		edx, OFFSET msg_Exit
	call	WriteString
	call	CrLf
	exit

main ENDP

END main
