TITLE ASM Negative Integer Accumulator		(accumulator.asm)

; Author: Mathew McDade
; Date: 02/09/2018 9:20:25 PM
; Description: This program prompts the user to enter negative integers in the range [-100...-1] and returns
; the total count of integers entered, the sum of those integers, and the average of those integers rounded to the closest integer.
; User input lines are numbered in place. Line numbers are incremented after each successful integer is entered.
; The program also shows the average as a floating point number rounded to three decimal places.

INCLUDE Irvine32.inc
INCLUDE Macros.inc			;for mGotoXY

; Globals
LOWER_LIMIT = -100			; Lowest allowed user input value per program requirements.
UPPER_LIMIT = -1			; Highest allowed user input value per program requrements.

.data
; Output Messages
msg_Header				BYTE	"Program 3: Integer Accumulator			by Mathew McDade",13,10,0
msg_EC_1				BYTE	"**EC 1: Lines are numbered in place during user input.",13,10,0
msg_EC_2				BYTE	"**EC 2: The average is also displayed as a floating point number.",13,10,0
msg_EC_3				BYTE	"**EC 3: The program astoundingly displays ongoing program statistics after each entered number.",13,10,0

msg_NameInputPrompt		BYTE	"What's your name? ",0
msg_Greeting			BYTE	"Welcome to the program, ",0
exclamation				BYTE	33,13,10,0								; Output an exlamation point follwed by crlf.
inputOverwrite			BYTE	"        ",08,08,08,08,08,08,08,08,0	; Overwrites eight spaces, then backspaces to its origin.
decimal					BYTE	".",0

msg_NumInputInstruct	BYTE	"Please enter negative integers in the range [-100 ... -1] or a positive integer to finish.",13,10,0
msg_NumInputGet			BYTE	") Enter number: ",0
msg_NumInputError		BYTE	"Sorry, you have to enter an integer in the range [-100 ... -1] or a positive integer to finish!",13,10,0
errorOverwrite			BYTE	"                                                                                                  ",0	; A string of spaces for overwriting msg_NumInputError.

; Output messages for ongoing program output.
msg_RunningTotal		BYTE	"Numbers entered: ",0
msg_RunningSum			BYTE	"Sum: ",0
msg_RunningAvgRound		BYTE	"Rounded Average: ",0
msg_RunningAvgFloat		BYTE	"Floating Point Average: ",0
msg_RunningPrevNum		BYTE	"Previously entered: ",0			; Last valid integer entered by the user.
; Output messages for final program output.
msg_FinalNumsEntered1	BYTE	"You entered ",0
msg_FinalNumsEntered2	BYTE	" valid numbers.",13,10,0
msg_FinalSum			BYTE	"The sum of your numbers is: ",0	
msg_FinalAvgRound		BYTE	"The final rounded average is: ",0	
msg_FinalAvgFloat		BYTE	"The final floating point average is: ",0
msg_NoInputs			BYTE	"No negative integers were entered.",13,10,0
msg_Exit				BYTE	"I hope you enjoyed this program.",13,10,"Goodbye ",0

; Memory Variables
userName		BYTE	25 DUP(0)
count			SDWORD	0
sum				SDWORD	0
average_rnd		SDWORD	?
remainder		SDWORD	?
average_flt		SDWORD	?
prev			SDWORD	?


.code
main PROC
	mov		eax,green+(black*16)			; Set output: green text on a black background--Matrix style.
	call	SetTextColor
; Introduction
	mov		edx, OFFSET msg_Header
	call	WriteString
	mov		edx, OFFSET msg_EC_1
	call	WriteString
	mov		edx, OFFSET msg_EC_2
	call	WriteString
	mov		edx, OFFSET msg_EC_3
	call	WriteString
	call	CrLf
; Get user name
	mov		edx, OFFSET msg_NameInputPrompt
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, SIZEOF	userName
	call	ReadString
; Greeting
	mov		edx, OFFSET msg_Greeting
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclamation
	call	WriteString
	call	CrLf

; User Instructions
	mov		edx, OFFSET msg_NumInputInstruct
	call	WriteString
	call	CrLf
; Top: Get user input, validate input, calculate and display running values.
	mov		ecx,0
Top:
	call	getUserNum
	cmp		eax,0
	jge		FinishProgram			; Jump to end of program for any positive user value.
	inc		count
	call	calculate
	call	displayRunning
	inc		ecx
	jmp		Top
; Exit program
FinishProgram:
	cmp		count,0
	je		NoNums					; Jump to a special message if no negative integers were entered.
	call	displayFinal
	jmp		ExitMessage
NoNums:
	call	CrLf
	mov		edx,OFFSET msg_NoInputs
	call	WriteString
ExitMessage:
	mGotoXY	0,20
	mov		edx, OFFSET msg_Exit
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclamation
	call	WriteString
	call	CrLf
	exit
	
main ENDP

; PROCEDURES

; getUserNum
; Procedure to get a valid integer input from the user.
; Receives: 
; Returns: User input value > -100 in EAX register.
; Preconditions: None.
; Registers changed: EAX, EDX
getUserNum PROC
Prompt:
	mGotoXY 0,10
	mov		eax,ecx
	add		eax,1
	call	WriteDec
	mov		edx,OFFSET msg_NumInputGet
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	call	ReadInt
	cmp		eax,LOWER_LIMIT
	jge		EndgetUserNum
	mov		edx,OFFSET msg_NumInputError		; Error message if integer is below the LOWER_LIMIT.
	call	WriteString
	jmp		Prompt
EndGetUserNum:
	mGotoXY	0,11
	mov		edx,OFFSET errorOverwrite
	call	WriteString
	ret
getUserNum ENDP

; calculate
; Procedure to calculate the sum and average of an accumulation of negative integers.
; Receives: current count of integers in count, user integer in EAX.
; Returns: original EAX value in prev, accumulator sum in sum, rounded average in average_rnd, floating point average in average_flt with franctional part in remainder.
; Preconditions: count>0 and valid integer in eax.
; Registers changed: EAX, EBX, EDX.
calculate PROC
	;mov		edx,0
	mov		prev,eax
	add		sum,eax
	mov		eax,sum				
	cdq								; Sign extend EAX into EDX by convert double to quad.
	idiv	count
	neg		edx						; Take the two's complement to make remainder part positive.
	mov		average_rnd,eax
	mov		average_flt,eax
	mov		remainder,edx
	mov		eax,remainder
	mov		ebx,1000
	imul	ebx
	cdq
	idiv	count
	mov		remainder,eax
	
	cmp		remainder,500
	jg		RoundAvg				; Round the integer down if the fraction part is .5 or greater.
FinishCalculate:
	ret
RoundAvg:
	dec		average_rnd				; Round down.
calculate ENDP

; displayRunning
; Procedure to display ongoing program output. Displays output in a fixed location on the buffer.
; Receives: prev, count, sum, average_rnd, average_flt, and remainder are globals.
; Returns: 
; Preconditions: 
; Registers changed: EAX, EDX.
displayRunning PROC
	mGotoXY	0,13
	mov		edx,OFFSET msg_RunningTotal
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,count
	call	WriteDec
	call	CrLf
	mov		edx,OFFSET msg_RunningSum
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,sum
	call	WriteInt
	call	CrLf
	mov		edx,OFFSET msg_RunningAvgRound
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,average_rnd
	call	WriteInt
	call	CrLf
	mov		edx,OFFSET msg_RunningAvgFloat
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,average_flt
	call	WriteInt
	mov		edx,OFFSET decimal
	call	WriteString
	mov		eax,remainder
	call	WriteDec
	mGotoXY	0,11
	mov		edx,OFFSET msg_RunningPrevNum
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,prev
	call	WriteInt
	ret
displayRunning ENDP

; displayFinal
; Procedure to display final program output. Displays output in a fixed location on the buffer.
; Receives: prev, count, sum, average_rnd, average_flt, and remainder are globals.
; Returns: 
; Preconditions: 
; Registers changed: EAX, EDX.
displayFinal PROC
	mGotoXY	0,11
	mov		edx,OFFSET errorOverwrite
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx,OFFSET msg_FinalNumsEntered1
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,count
	call	WriteDec
	mov		edx,OFFSET msg_FinalNumsEntered2
	call	WriteString
	call	CrLf
	mov		edx,OFFSET msg_FinalSum
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,sum
	call	WriteInt
	call	CrLf
	mov		edx,OFFSET msg_FinalAvgRound
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,average_rnd
	call	WriteInt
	call	CrLf
	mov		edx,OFFSET msg_FinalAvgFloat
	call	WriteString
	mov		edx,OFFSET inputOverwrite
	call	WriteString
	mov		eax,average_flt
	call	WriteInt
	mov		edx,OFFSET decimal
	call	WriteString
	mov		eax,remainder
	call	WriteDec
	ret
displayFinal ENDP

END main
