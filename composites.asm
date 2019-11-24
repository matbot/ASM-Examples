TITLE ASM Composites		(composites.asm)

; Author: Mathew McDade
; Date: 02/18/2018 12:22:26 PM
; Description: This program greets the user, prompts the for a number n, in the range [1...10000], validates that the user has entered 
; a valid number, then displays the first n composite numbers.
; The program displays its output in aligned columns. The program also displays results sequentially in groups of 90
; composite numbers per page with each page displayed in place after prompting the user to continue.

INCLUDE Irvine32.inc
INCLUDE Macros.inc			;for mGotoXY

; Globals
; Constants
LOWER_LIMIT = 1
UPPER_LIMIT = 10000

.data
; Output
; Header Messages
msg_Header				BYTE	"Program 4: Composite Number Lister			by Mathew McDade",13,10,0
msg_EC_1				BYTE	"**EC 1: Output columns are aligned with 10 values per line.",13,10,0
msg_EC_2				BYTE	"**EC 2: User can request up to 10,000 composite numbers, displayed in pages of 90 values.",13,10,0
; Introduction Messages
msg_NameInputPrompt		BYTE	"Please enter user name: ",0
msg_Greeting			BYTE	"Welcome to the program, ",0
; Get User Data Messages
msg_NumInputInstruct	BYTE	"Please enter the number of composite numbers you would like to see, up to 10000.",13,10,0
msg_NumInputGet			BYTE	"Enter number: ",0
msg_NumInputError		BYTE	"Sorry, you must enter a number in the range [1...10000].",13,10,0
; Farewell Messages
msg_Farewell			BYTE	"I hope you enjoyed this program.",13,10,"Goodbye, ",0
; Other Messages
tabSpace				BYTE	"	",0									; Single tab space.
exclamation				BYTE	33,13,10,0								; Output an exlamation point follwed by crlf.
inputOverwrite			BYTE	"        ",08,08,08,08,08,08,08,08,0	; Overwrites eight spaces, then backspaces to its origin.
errorOverwrite			BYTE	"                                                                                                  ",0	; A string of spaces for overwriting msg_NumInputError.


; Memory Variables
userName			BYTE	25 DUP(0)
userNum				DWORD	?
lineReturnCounter	DWORD	0				; Tracks the number of items that have been printed on a given line.
pageReturnCounter	DWORD	0				; Tracks the number of items that have been printed on a given page.
compHolder			DWORD	?				; Stores the current potential composite number.
divisor				DWORD	?

.code
main PROC
; Set output: green text on a black background--Matrix style.
	mov		eax,green+(black*16)
	call	SetTextColor
; Greet user.
	call	introduction
; Get number of composite numbers to calculate from user.
	call	getUserData
; Calculate n composite numbers.
	call	showComposites
; Say farewell.
	call	farewell
	exit
main ENDP



; PROCEDURES

; introduction
; Procedure to greet the user and describe the program.
; Receives: -
; Returns: The user's name input is returned in the global variable userName.
; Preconditions: -
; Registers changed: EDX.
introduction PROC
	mov		edx,OFFSET Msg_Header
	call	WriteString
	mov		edx, OFFSET msg_EC_1
	call	WriteString
	mov		edx, OFFSET msg_EC_2
	call	WriteString
	call	CrLf
; Get user name.
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
	ret
introduction ENDP

; getUserData
; Procedure to get a valid number input from the user.
; Receives: -
; Returns: Returns a valid user input in the global variable userNum.
; Preconditions: -
; Registers changed: EAX, EDX.
getUserData PROC
	mov		edx,OFFSET msg_NumInputInstruct
	call	WriteString
	mov		edx,OFFSET msg_NumInputGet
	call	WriteString
PromptTop:
	call	ReadDec
	call	validate						; validate PROC will return 0 in the EAX register if input is invalid.
	cmp		eax,0
	je		PromptError						; jump to error message if user input is invalid.
	mGotoXY	0,9
	mov		edx,OFFSET errorOverwrite		; if input is valid, clear error message before beginning output.
	call	WriteString
	mGotoXY	0,9
	mov		userNum,eax
	ret
PromptError:
	mov		edx,OFFSET msg_NumInputError
	call	WriteString
	mGotoXY 14,8
	mov		edx,OFFSET inputOverwrite		; clears the previously entered number from the input line.
	call	WriteString
	jmp		PromptTop
getUserData ENDP

; validate
; Procedure to check user input number against an upper and lower limit.
; Receives: user input in EAX.
; Returns: Original value in eax if valid, 0 in eax if invalid.
; Preconditions: eax must contain a user input integer.
; Registers changed: EAX.
validate PROC
	cmp		eax,LOWER_LIMIT
	jb		Invalidate
	cmp		eax,UPPER_LIMIT
	ja		Invalidate	
	ret
Invalidate:
	mov		eax,0
	ret
validate ENDP

; showComposites
; Procedure to loop over possible integer values and print the ones that are composite numbers. The procedure also aligns the output in columns and
;	pages, with 10 numbers per line and 90 numbers per page.
; Receives: Valid user entered integer in global variabel userNum.
; Returns: -
; Preconditions: LOWER_LIMIT < userNum < UPPER_LIMIT
; Registers changed: EAX, ECX, EDX.
showComposites PROC
	mov		ecx,userNum
	mov		compHolder,3					; begin at 3 since first composite number is 4.
ShowCompositesTop:
	inc		compHolder
	call	isComposite
	cmp		eax,0
	je		ShowCompositesTop				; if compHolder isn't composite jump back to top and increment compHolder. Doesn't increment the loop.
	call	WriteDec
	mov		edx,OFFSET tabSpace
	call	WriteString
	inc		lineReturnCounter
	cmp		lineReturnCounter,10
	je		LineReturn
PageReturnCheck:
	inc		pageReturnCounter
	cmp		pageReturnCounter,90
	je		PageReturn
	loop	ShowCompositesTop
	ret
LineReturn:
	call	CrLf
	call	CrLf
	mov		lineReturnCounter,0
	jmp		PageReturnCheck
PageReturn:
	call	WaitMsg							; prompt the user to [ENTER] to display the next page.
	call	clearNums						; clears previous page.
	;mov		edx,OFFSET errorOverwrite
	;call	WriteString
	mGotoXY	0,9
	mov		pageReturnCounter,0
	loop	ShowCompositesTop
showComposites	ENDP

; clearNum procedure helps clear previous page output.
; Registers changed: EAX, ECX, EDX.
clearNums PROC USES EBX ECX
	mov		ecx,9
	mov		dl,0
	mov		dh,9
ClearTop:
	call	GotoXY							; used a loop over gotoxy instead of macro to decrease jump distance.
	push	edx
	mov		edx,OFFSET errorOverwrite
	call	WriteString
	pop		edx
	add		dh,2
	loop	ClearTop
	ret
clearNums ENDP
	

; isComposite
; Procedure to check whether a given integer is a composite number.
; Receives: Integer to test in global variable compHolder.
; Returns: The compHolder returns in eax if value is composite, 0 in eax if value is not composite.
; Preconditions: Valid integer value in compHolder variable.
; Registers changed: EAX, EBX, EDX.
isComposite PROC
	mov		eax,compHolder
	mov		ebx,2
	mov		edx,0
	div		ebx
	mov		divisor,eax						; divisor begins at n/2 and decrements as n/2 is the largest possible whole number factor of n.
IsCompositeTop:
	mov		eax,compHolder
	mov		edx,0
	div		divisor
	cmp		edx,0							; if remainder of division is 0, divisor is a factor, and compHolder is a composite number.
	je		IsCompositeEnd
	jne		IsNotComposite
IsCompositeEnd:
	mov		eax,compHolder
	ret
IsNotComposite:
	dec		divisor
	cmp		divisor,1
	ja		IsCompositeTop
	mov		eax,0
	ret
isComposite ENDP

; farewell
; Procedure to say goodbye to the user.
; Receives: User's name in global variable userName
; Returns: -
; Preconditions: valid user name in userName.
; Registers changed: EDX.
farewell PROC
	mGotoXY	0,27							; Say goodbye at the bottom of the page.
	mov		edx, OFFSET msg_Farewell
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclamation
	call	WriteString
	ret
farewell ENDP


END main
