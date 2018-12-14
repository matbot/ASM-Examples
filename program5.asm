TITLE Program 5		(program5.asm)

; Author: Mathew McDade		mcdadem@oregonstate.edu
; Date: 03/06/2018 12:19:24 AM
; Description: This program generates a user specified number of random integers in the range [100...999].
;	The program prints the unsorted list of random integers, sorts the list, displays the rounded median of 
;	the sorted list, and displays the sorted list.
; Extra Credit:
;	EC#1: The program sorts the list using a recursive bubble sort.

INCLUDE Irvine32.inc
INCLUDE Macros.inc

; Global Constants
LOWER_LIMIT = 10
UPPER_LIMIT = 200
MIN = 100
MAX = 999

.data
; Output
; Header Messages
msg_Header				BYTE	"Welcome to Program 5: Random Integer Sorter			by Mathew McDade",13,10
msg_EC_1				BYTE	"**EC 1: The program sorts the arrray using a recursive bubble sort.",13,10,0
; Get User Data Messages
msg_NumInputInstruct	BYTE	"The program will sort and display an array of random integers with values from 100 to 999,",13,10,"as well as the median of the sorted array.",13,10,13,10
msg_NumInputGet			BYTE	"How many random integers, from 10 to 200, would you like to sort? ",0
msg_NumInputError		BYTE	"Sorry, you must enter a number in the range [10...200].",13,10,0
; Display Messages
msg_Unsorted			BYTE	"Unsorted Array:",13,10,0
msg_Median				BYTE	"Rounded Median Value: ",0
msg_Sorted				BYTE	"Sorted Array:",13,10,0
; Farewell Messages
msg_Farewell			BYTE	"I hope you enjoyed this program.",13,10,"Goodbye!",13,10,0

; Memory Variables
userRequest			DWORD	?
randArray			DWORD	UPPER_LIMIT+1		DUP(?)

.code
main PROC
; Set output: green text on a black background--Matrix style.
	mov		eax,green+(black*16)
	call	SetTextColor
; Greet user.
	push	OFFSET msg_Header
	call	introduction
; Get number of composite numbers to calculate from user.
	push	OFFSET msg_NumInputInstruct
	push	OFFSET msg_NumInputGet
	push	OFFSET msg_NumInputError
	push	OFFSET userRequest
	call	getUserRequest
; Seed Randomize
	call	Randomize				; Seed the RandomRange function.
; Fill array.
	push	OFFSET randArray
	push	userRequest
	call	generateRandInts
; Print unsorted array.
	push	OFFSET randArray	
	push	OFFSET msg_Unsorted	
	push	userRequest
	call	displayList
; Sort the array.
	push	userRequest
	push	OFFSET randArray
	call	arraySort
; Print median.
	push	OFFSET msg_Median
	push	OFFSET randArray
	push	userRequest
	call	displayMedian
; Print sorted array.
	push	OFFSET randArray
	push	OFFSET msg_Sorted
	push	userRequest
	call	displayList
; Say farewell.
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

; getUserData
; Procedure to get a valid number input from the user.
; Receives: Stack parameters:
;	userRequest by reference [ebp+8]
;	msg_NumInputError by reference [ebp+12]
;	msg_NumInputGet by reference [ebp+16]
;	msg_NumInputInstruct by reference [ebp+20]
; Returns: Returns a valid user input to variable userRequest by reference.
; Preconditions: -
; Registers changed: -
getUserRequest PROC
	push	ebp
	mov		ebp,esp
	pushad
	mov		edx,[ebp+20]
	call	WriteString
	jmp		Read
Prompt:
	mov		edx,[ebp+16]
	call	WriteString
Read:
	call	ReadDec
	cmp		eax,LOWER_LIMIT
	jb		InvalidInput
	cmp		eax,UPPER_LIMIT
	ja		InvalidInput
	mov		edi,[ebp+8]
	mov		[edi],eax
	call	CrLf
	popad
	pop		ebp
	ret 12
InvalidInput:
	mov		edx,[ebp+12]
	call	WriteString
	call	CrLf
	jmp		Prompt
getUserRequest ENDP

; generateRandInts
; Procedure fill an array with a user defined number of random integers in the range MIN to MAX.
; Receives: Stack parameters:
;	userRequest by value [ebp+8]
;	randArray by reference [ebp+12]
; Returns: Returns randArray with generated random ints.
; Preconditions: userRequest must be in the range LOWER_LIMIT to UPPER_LIMIT.
; Registers changed: -
generateRandInts PROC
	push	ebp
	mov		ebp,esp
	pushad
	mov		ecx,[ebp+8]
	mov		edi,[ebp+12]
genLoop:	
	mov		eax,MAX
	sub		eax,MIN
	inc		eax
	call	RandomRange
	add		eax,MIN
	mov		[edi],eax
	add		edi,4
	loop	genLoop

	popad
	pop		ebp
	ret 8
generateRandInts ENDP

; displayList
; Procedure to display the array.
; Receives: Stack parameters:
;	userRequest by value [ebp+8]
;	array title by reference [ebp+12]
;	randArray by reference [ebp+16]
; Returns: -
; Preconditions: randArray must contain valid values in the index range specified by userRequest.
; Registers changed: -
displayList	PROC
	push	ebp	
	mov		ebp,esp
	pushad
	mov		ebx,0
	mov		ecx,[ebp+8]
	mov		esi,[ebp+16]
	mov		edx,[ebp+12]
	call	WriteString
DisplayTop:
	mov		eax,[esi]			
	call	WriteDec
	mWriteSpace 5
	add		esi,4
	inc		ebx
	cmp		ebx,10
	jae		LineReturn
DisplayBottom:
	loop	DisplayTop
	call	CrLf
	call	CrLf
	popad
	pop		ebp
	ret 12	
LineReturn:
	call	CrLf
	mov		ebx,0
	jmp		DisplayBottom	
displayList ENDP

; arraySort
; Procedure to sort the array.
; Receives: Stack parameters:
;	userRequest by value [ebp+8]
;	randArray by reference [ebp+12]
; Returns: Returns the sorted array.
; Preconditions: randArray must contain valid values in the index range specified by userRequest.
; Registers changed: -
arraySort PROC
	LOCAL	rCounter:DWORD		; rCounter tracks size of the array in recursion.
	pushad
	mov		esi,[ebp+8]
	mov		edi,[ebp+8]
	mov		ecx,[ebp+12]
	mov		rCounter,ecx
	cmp		ecx,1				; Array size of 1 triggers exit recursion.
	jbe		ExitRecursion
BubbleTop:			
	mov		eax, [esi]
	add		edi,4
	mov		ebx,[edi]
	cmp		eax,ebx
	jge		NoSwap
	mov		[esi],ebx			; If esi<edi, elements are swapped, pushing lowest value to the end of the array.
	mov		[edi],eax
NoSwap:
	mov		esi,edi
	loop	BubbleTop

	dec		rCounter
	push	rCounter
	push	[ebp+8]
	call	arraySort
ExitRecursion:
	popad
	ret 8
arraySort ENDP

; displayMedian
; Procedure to calculate and display the median of the sorted randArray.
; Receives: Stack parameters:
;	userRequest by value [ebp+8]
;	randArray by reference [ebp+12]
;	msg_Median by reference [ebp+16]
; Returns: -
; Preconditions: randArray must contain valid values in the index range specified by userRequest.
; Registers changed: -
displayMedian PROC
	push	ebp
	mov		ebp,esp
	pushad
	mov		edx,[ebp+16]
	call	WriteString
	mov		esi,[ebp+12]
	mov		eax,[ebp+8]
	mov		edx,0
	mov		ebx,2
	div		ebx
	mov		ecx,edx
CalcMedian:
	mov		ebx,4
	mul		ebx
	add		esi,eax
	mov		eax,[esi]
	cmp		ecx,0				; ecx contains edx from previous division on line 272.
	jne		WriteMedian
EvenMedian:						; need to average two middle elements to calculate median for an even number of elements.
	sub		esi,4				
	add		eax,[esi]
	mov		edx,0 
	mov		ebx,2
	div		ebx
	cmp		edx,0
	je		WriteMedian
	inc		eax					; if result is fractional, round up.
WriteMedian:
	call	WriteDec
	call	CrLf
	call	CrLf
	popad
	pop		ebp
	ret 12
displayMedian ENDP

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
