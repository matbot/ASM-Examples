TITLE Template		(template.asm)

; Author: Mathew McDade
; Description: 

INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096


.data									; this is the data area
sum DWORD 0								; create variable named sum

.code
main PROC
	mov	eax,5				
	add	eax,6				
	mov sum, eax

main ENDP


END main
