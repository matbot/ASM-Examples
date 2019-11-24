TITLE ASM Fibonacci		(fibonacci.asm)

; Author: Mathew McDade
; Date: 01/26/2018 9:10:07 AM
; An assembly langauge program that takes a user defined integer, with an upper limit of 46, 
; ensured by post-test loop validation, and returns the sequence of second-order Fibonacci numbers to the nth term.
; This program displays its output in two aligned colums, and it also does something incredible by testing user 
; defined integers, up to 6,000,000, and stating whether or not they are Fibonacci numbers.

INCLUDE Irvine32.inc

; Globals
UPPER_LIMIT = 46			; Results in highest possible Fib for 32-bit unsigned integer, 47th Fib, 2,971,215,073, would fit into DWORD, 
							; but 48th, 4,807,526,976,would overflow.

.data
; Output Messages
msg_Intro			BYTE	"Program 2: Fibonacci Sequence			by Mathew McDade",13,10,0
msg_EC_1			BYTE	"**EC 1: Fibonacci sequence output will be aligned in two columns.",13,10,0
msg_EC_2			BYTE	"**EC 2: The program will now do something incredible by identifying Fibonacci numbers.",13,10,0
msg_IncrediPrompt	BYTE	"Press [Enter] for something incredible... ",0
msg_Incredible		BYTE	"Enter a positive integer and I'll tell you if it's a Fibonacci number, or enter 0 to continue to the main program: ",13,10,0
msg_tooLow			BYTE	"Sorry, you have to enter a positive integer!",13,10,0
msg_tooLarge		BYTE	"Sorry, I don't have that many fingers...Try entering an integer below 6,000,000.",13,10,0
msg_isFib			BYTE	" is a Fibonacci number!",07,13,10,0	; BEL tone for successfully finding a Fib.
msg_notFib			BYTE	" is not a Fibonacci number.",13,10,0
msg_NameInputPrompt	BYTE	"What's your name? ",0
msg_Greeting		BYTE	"Welcome to the program, ",0
msg_NumInputPrompt	BYTE	"Please enter the number of Fibonacci terms, in the range [1 ... 46], you would like to see.",13,10,0
msg_NumInputGet		BYTE	"How many Fibonacci terms do you want to see? ",0
msg_NumInputError	BYTE	"Sorry, the number must be in the range [1 ... 46]. Try again.",13,10,0
msg_Exit			BYTE	"I hope you enjoyed this program.",13,10,"Goodbye ",0
exclamation			BYTE	33,13,10,0		; Output an exlamation point follwed by crlf.
twoTabs				BYTE	"		",0
threeTabs			BYTE	"			",0

; User Inputs
userName			BYTE	25 DUP(0)
userNum				DWORD	?				; Number of Fib terms to display, range [1...UPPER_LIMIT].
userInt				DWORD	?				; Integer to test for Fibonacci-ness.
userInt2			DWORD	?
four				DWORD	4				; For FPU calc.
five				DWORD	5				; For FPU calc.

.code
main PROC
	mov		eax,green+(black*16)			; Set output: green text on a black background--Matrix style.
	call	SetTextColor
; Introduction
	mov		edx, OFFSET msg_Intro
	call	WriteString
	mov		edx, OFFSET msg_EC_1
	call	WriteString
	mov		edx, OFFSET msg_EC_2
	call	WriteString
	call	CrLf

; Call to somethingIncredible PROC.
	mov		edx, OFFSET msg_IncrediPrompt
	call	WriteString
	call	ReadInt
	call	somethingIncredible

; Get user's name.
	mov		edx, OFFSET msg_NameInputPrompt
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, SIZEOF userName
	call	ReadString
; Greeting.
	mov		edx, OFFSET msg_Greeting
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclamation
	call	WriteString
	call	CrLf

; User Instructions
	mov		edx, OFFSET msg_NumInputPrompt
	call	WriteString
	call	CrLf
; Get User Input with call to getUserNum PROC--includes input validation.
	call	getUserNum

; Calculate and Display Fibonacci Terms with call to fibonacci PROC.
	mov 	ecx,eax
	call	fibonacci

; Exit program
	mov		edx, OFFSET msg_Exit
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclamation
	call	WriteString
	call	CrLf
	exit
	
main ENDP

; Procedures!

; getUserNum prompts the user for the number of Fib terms they want to see, then reads an integers and validates that it is within range [1...UPPER_LIMIT].
getUserNum PROC
Prompt:
	mov		edx, OFFSET	msg_NumInputGet
	call	WriteString
	call	ReadInt
	cmp		eax,0
	jbe		Retry
	cmp		eax,UPPER_LIMIT
	ja		Retry
	mov		userNum, eax
	jmp		Finish_getUserNum
Retry:
	call	CrLf
	mov		edx, OFFSET msg_NumInputError
	call	WriteString
	call	CrLf
	jmp		Prompt
Finish_getUserNum:
	ret
getUserNum ENDP

; fibonacci PROC iteratively calculates Fib terms and prints them to output in two aligned columns.
fibonacci PROC
	mov		eax,1
	mov		ebx,0
FibLoop:
	call	WriteDec
	dec		ecx						; ecx decremented by 1 here because each loop will print two terms.
	push	eax
	add		eax,ebx
	pop		ebx
	cmp		ecx,0					; check for end of loop to prevent decrementing past 0.
	jle		Finish_fibonacci
	cmp		eax,15000000			; 15000000 chosen for column alignment due to large integers shifting output.
	jle		ThreeTabInsert
	jmp		TwoTabInsert
FibLoop2:
	call	WriteDec
	call	CrLf
	push	eax
	add		eax,ebx
	pop		ebx
	loop	FibLoop
Finish_fibonacci:
	call	CrLf
	call	CrLf
	ret
TwoTabInsert:
	mov		edx, OFFSET twoTabs
	call	WriteString
	jmp		FibLoop2
ThreeTabInsert:
	mov		edx, OFFSET threeTabs
	call	WriteString
	jmp		FibLoop2
fibonacci ENDP

; somethingIncredible PROC gets an integer from the user and checks whether it is a Fibonacci number.
; This is achieved using the rearranged Binet's formula found on Wikipedia's Fibonacci Number entry 
;	(wikipedia.org/wiki/Fibonacci_number#Recognizing_Fibonacci_numbers).
; Sadly, I haven't been able to get Fibonacci numbers above 6,000,000 to work due to loss of matissa precision after the square.
somethingIncredible PROC
IncrediLoop:
	call	CrLf
	mov		edx, OFFSET msg_Incredible
	call	WriteString
	call	ReadInt
	mov		userInt,eax
	cmp		eax,0
	je		Finish_IncrediLoop
	jle		TooLow
	cmp		eax,6000000
	jg		TooLarge
	
; using the fpu for large integer calculations.
	fild	userInt
	fimul	userInt
	fimul	five						; 5n^2
	fiadd	four						; 5n^2+4
	fst		ST(1)
	fsqrt	
	fstp	userInt2
	fld		userInt2
	fmul	st(0),st(0)					; Check for perfect square.
	fcomi	st(0),st(1)					; Note: try to implement FCOMI, sets Zero, Parity, and Carry directly.
	;fnstsw	ax							; Irvine 531: move fpu word to AX, 
	;sahf								; copy AH to Eflags.
	je		IsFib

	fstp	st(0)
	fisub	four						; 5n^2
	fisub	four						; 5n^2-4
	fst		st(1)
	fsqrt
	fstp	userInt2
	fld		userInt2
	fmul	st(0),st(0)
	fcomi	st(0),st(1)
	;fnstsw	ax				
	;sahf
	je		IsFib
	jmp		NotFib

TooLow:
	mov		edx, OFFSET msg_tooLow
	call	WriteString
	jmp		IncrediLoop
TooLarge:
	mov		edx, OFFSET msg_tooLarge
	call	WriteString
	jmp		IncrediLoop

IsFib:
	mov		eax,userInt
	call	WriteDec
	mov		edx, OFFSET msg_isFib
	call	WriteString
	call	CrLf
	jmp		IncrediLoop

NotFib:
	mov		eax,userInt
	call	WriteDec
	mov		edx, OFFSET msg_notFib
	call	WriteString
	call	CrLf
	jmp		IncrediLoop

Finish_IncrediLoop:
	call	ClrScr
	ret
somethingIncredible ENDP

END main
