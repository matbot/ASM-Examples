TITLE ASM Combinatorics		(combinatorics.asm)

; Author: Mathew McDade
; Description: This program gives users practice combinatorics problems and grades their performance.

INCLUDE Irvine32.inc
INCLUDE Macros.inc

; Displays a string
mDisplayString MACRO stringAddress
	push	edx
	mov		edx, stringAddress
	call	WriteString
	pop		edx
ENDM
; Returns a 32-bit random integer, in the range min to max, in the eax register.
mRandRange MACRO min, max
	mov		eax,max
	sub		eax,min
	inc		eax
	call	RandomRange
	add		eax,min
ENDM

; Global Constants
N_MAX = 12
N_MIN = 3

.data
; Output
; Header Messages
msg_Header				BYTE	"Welcome to Program 6b: Combinatorics Practice Program: nCr			by Mathew McDade",13,10
msg_EC_1				BYTE	"**EC 1: The program keeps score for the player and give a report at exit.",13,10
msg_EC_2				BYTE	"**EC 2: The program computes factorials in the FPU.",13,10,13,10
msg_Description			BYTE	"You will be presented with a series of nCr combinatorics problems.",13,10
						BYTE	"Please calculate and enter your answer for each problem.",13,10,13,10,0
; Problem Messages
msg_ProbPart1			BYTE	") How many combinations of ",0
msg_ProbPart2			BYTE	" items can be made from a set of ",0
msg_ProbPart3			BYTE	" items? ",0
msg_errorNaN			BYTE	"Sorry, your answer contained non-digit characters!",0
; Response Messages
msg_Correct				BYTE	"Correct!!",13,10,0
msg_Incorrect			BYTE	" is incorrect. The correct answer is: ",0
msg_RepeatRequest		BYTE	"Would you like to try another problem? (y/n) ",0
msg_RepeatReqError		BYTE	"You have to enter 'y' or 'n' to continue.",0
; Report Messages
msg_FinalReport			BYTE	"Final Report",13,10
msg_underline			BYTE	"-----------------",13,10
msg_NumQuestions		BYTE	"Total Questions: ",0
msg_NumCorrect			BYTE	"Total Correct: ",0
msg_NumIncorrect		BYTE	"Total Incorrect: ",0
; Farewell Messages
msg_Farewell			BYTE	"I hope you enjoyed this program.",13,10,"Goodbye!",13,10,0

; Memory Variables
questionNumber			DWORD	1
n						DWORD	?
r						DWORD	?
userAnswer				DWORD	0
correctAnswer			DWORD	?
correctCount			DWORD	0
loopFlag				DWORD	0

.code
main PROC
; Set output: green text on a black background--Matrix style.
	mov		eax,green+(black*16)
	call	SetTextColor
; Seed Randomize
	call	Randomize				; Seed the RandomRange function.
; Greet user.
	push	OFFSET msg_Header
	call	introduction
ProblemTop:
; Generate random n [3...12] and r [1...n] and display problem to the user.
	push	OFFSET msg_ProbPart3
	push	OFFSET msg_ProbPart2
	push	OFFSET msg_ProbPart1
	push	OFFSET n
	push	OFFSET r
	push	questionNumber
	call	showProblem
	
; Get user's answer to the current nCr question.
	push	OFFSET msg_errorNan
	push	OFFSET userAnswer
	call	getData
; 
	push	OFFSET correctAnswer
	push	r
	push	n
	call	combinations

; Farewell message to the user.
	push	OFFSET msg_Farewell
	call	farewell
	exit
main ENDP


; PROCEDURES

; introduction
; Procedure to greet the user and describe the program.
; Receives: Introduction message by reference on the stack, [ebp+8].
; Returns: -
; Preconditions: -
; Registers changed: -
introduction PROC
	push	ebp
	mov		ebp,esp
	pushad
	mov		edx,[ebp+8]
	call	WriteString
	call	CrLf
	popad
	pop		ebp
	ret		4
introduction ENDP

; showProblem
showProblem PROC
	push	ebp
	mov		ebp,esp
	pushad
Generate:
	mov		ebx,[ebp+16]
	mRandRange	N_MIN, N_MAX
	mov		[ebx],eax
	mov		ebx,[ebp+12]
	mRandRange	1,eax
	mov		[ebx],eax
Show:
	mGotoXY	0,7
	mWriteSpace 50
	mGotoXY 0,7
	mov		eax,[ebp+8]
	call	WriteDec
	mDisplayString [ebp+20]
	mov		ebx,[ebp+12]
	mov		eax,[ebx]
	call	WriteDec
	mDisplayString [ebp+24]
	mov		ebx,[ebp+16]
	mov		eax,[ebx]
	call	WriteDec
	mDisplayString [ebp+28]
	popad
	pop		ebp
	ret 28
showProblem ENDP

; getData
getData PROC
	LOCAL	sigFactor:DWORD,
			byteArray[50]:BYTE
	pushad
GetDataTop:
	;mov		edi,[ebp+8]
	lea		esi,byteArray
	lea		edx,byteArray
	mov		ecx,51
	mGotoXY	72,7
	call	ReadString
	mov		ecx,eax
	mov		eax,1
	mov		ebx,10
	cmp		ecx,1
	mov		sigFactor,1
	jbe		ConvertData
	push	ecx
	dec		ecx
SetSigFactor:
	mul		ebx
	loop	SetSigFactor
	mov		sigFactor,eax
	pop		ecx
	cld
ConvertData:
	lodsb
	cmp		al,48
	jb		InvalidData
	cmp		al,57
	ja		InvalidData
	movsx	eax,al
	sub		eax,48
	mul		sigFactor
	mov		ebx,[ebp+8]
	add		[ebx],eax
	mov		eax,sigFactor
	mov		ebx,10
	mov		edx,0
	div		ebx
	mov		sigFactor,eax
	loop	ConvertData
GetDataBottom:
	mGotoXY 0,8
	mWriteSpace 50
	popad
	ret	8
InvalidData:
	mGotoXY	0,8
	mDisplayString [ebp+12]
	mGotoXY 72,7
	mWriteSpace 25
	mGotoXY 72,7
	jmp		GetDataTop
getData ENDP

; recursiveFactorial
recursiveFactorial PROC
	LOCAL	nTemp:DWORD
	pushad
	mov		eax,[ebp+8]
	mov		nTemp,eax
	cmp		nTemp,1
	jbe		ExitRecursion
	dec		nTemp
	FILD	nTemp
	FMUL
	push	nTemp
	call	recursiveFactorial
ExitRecursion:
	popad
	ret 4
recursiveFactorial ENDP

; combinations
combinations PROC
	LOCAL	fldTemp:DWORD
	pushad
	FINIT
	mov		eax,[ebp+8]
	mov		fldTemp,eax
	FILD	fldTemp					; load n to FPU.
	push	fldTemp
	call	recursiveFactorial
	mov		eax,[ebp+12]
	mov		fldTemp,eax
	FILD	fldTemp
	push	fldTemp
	call	recursiveFactorial
	mov		eax,[ebp+8]
	mov		ebx,[ebp+12]
	sub		eax,ebx
	mov		fldTemp,eax
	FILD	fldTemp
	push	fldTemp
	call	recursiveFactorial
	FMUL
	FDIV
	mov		edi,[ebp+16]
	FISTTP	fldTemp
	mov		eax,fldTemp
	mov		[edi],eax
	popad
	ret 12
combinations ENDP



; farewell
; Procedure to say goodbye.
; Receives: Stack parameters:
;	msg_Farewell by reference [ebp+8]
; Returns: -
; Preconditions: -
; Registers changed: -
farewell PROC
	push	ebp
	mov		ebp,esp
	pushad
	call	CrLf
	mov		edx,[ebp+8]
	call	WriteString
	popad
	pop		ebp
	ret 4
farewell ENDP


END main
