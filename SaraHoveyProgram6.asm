TITLE Program Template     (template.asm)

; Author: Sara Hovey
; 
; 
; Date: 06/11/17

; Description: 
;Implement and test your own ReadVal and WriteVal procedures for unsigned integers. 
;• Implement macros getString and displayString. 
; The macros may use Irvine’s ReadString to get input from the user, and WriteString to display output.   
; o getString should display a prompt, then get the user’s keyboard input into a memory location 
; o displayString should the string stored in a specified memory location.  
; o readVal should invoke the getString macro to get the user’s string of digits.  
;  It should then convert the digit string to numeric, while validating the user’s input. 
; o writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to produce the output.   
;• Write a small test program that gets 10 valid integers from the user and stores the numeric values in an array.  
;The program then displays the integers, their sum, and their average.

;This lab uses global variables
INCLUDE Irvine32.inc

;;Boundaries for range-checking
;LOWER = 1
;UPPER = 200

;;Bounds for random
;LO = 100
;HI = 999

.data

;Values from the user
input		BYTE	21 DUP(0)
buffer		BYTE	21 DUP(0)

;Other
inputCount	DWORD   ?
list		DWORD	10	DUP(0)
count		DWORD	10
num			DWORD	0

;Calculated values
newStr		BYTE	" ",0


;Text output
space		BYTE	"   ",0
intro_1		BYTE	"Name: Sara Hovey, CS271 Program 6", 0
ask			BYTE	"Please input an integer" , 0
showList	BYTE	"Here is the array: ", 0
showSum		BYTE	"The sum is: ", 0
showAvg		BYTE	"The average is: ",0

bye			BYTE	"Goodbye, ", 0
error_1		BYTE	"Try again, please enter an integer this time" , 0
quit		BYTE	"Press any key to quit. See you next time!", 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getString MACRO ask, input, inputCount
	push	edx
	push	ecx
	push	eax
	push	ebx

	mov		edx, OFFSET ask
	call	WriteString
	call	CrLf

	;Get input string and size of input string
	mov		edx, OFFSET input
	mov		ecx, SIZEOF input
	call	ReadString
	mov		inputCount, eax		;eax holds SIZEOF

	pop		ebx
	pop		eax
	pop		ecx
	pop		edx

ENDM

DisplayString MACRO		newStr
	push	edx

	mov		edx, newStr
	call	WriteString

	pop edx
ENDM
.code
main PROC
;Program intro
	mov		edx, OFFSET intro_1
	call	WriteString		;replace with displayString
	call	CrLf

	mov		ecx, 10
	mov     edi, OFFSET list
	;this loop gets the data
	;need to stash the value returned by readVal in list
	;does the return val land in eax?
	;what holds the address of the array in the main proc?
rvLoop:
	call	ReadVal
	mov		[edi], eax
	add		edi, 4	
	loop	rvLoop		;increment to next element, loop again

	;Print the array
	push	OFFSET list
	push	count
	push	OFFSET showList
	call	print
	call	CrLf
	
	;Get the sum and average
	mov		edx, OFFSET showSum
	call	WriteString
	push	OFFSET list
	call	sum

;Goodbye
	call	goodbye

main ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reads value
;Returns value in EDX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readVal PROC
	;the thing that calls this will be in a loop that loops 10 times
	;each call represents a new number being converted
	push edx
	push ebx
	push ecx
	push esi

loop1:
	;invoke getString
	getString ask, input, inputCount

	mov		edx, 0
	mov		esi, OFFSET input
	mov		ecx, inputCount
	cld
loop2:
	lodsb
	;examines loaded string
	;compares it against ascii values
	cmp		al, 48
	jl		error

	cmp		al, 57
	jg		error

	sub		al, 48
	movzx	ebx, al
	mov		eax, 10

	mul		edx

	cmp		edx, 0

	jne		error		;overflow detection

	mov		edx, eax
	add		edx, ebx
	loop	loop2
	jmp		endRead

error:	
	mov		edx, OFFSET error_1
	call	WriteString
	call	CrLf
	jmp		loop1

;edx contains value I need to return,

endRead:
	mov eax, edx
	pop esi
	pop ecx
	pop ebx
	pop edx
	ret

readVal ENDP

writeVal PROC
;Setup
    push   eax
	push   ebx
	push   ecx
	push   edx
	push   edi
	mov    ecx, eax

	;does this need to be offset?
	mov		edi, OFFSET input
	add		edi, SIZEOF input	;adds the max sie of buffer to edi
	;this is bc we don't know how big the int is
	dec		edi
	mov		al, 0	;clear al, to be populated by stosb
	std				;set direction flag to backwards, we fill the buffer from back to front
	stosb			;all by itself, no rep since we're not relying on ecx as a counter
	
	;performs the calculation
	loop1:
	mov     eax, ecx
	mov		edx, 0
	mov		ebx, 10
	div		ebx
	add		edx, 48		;get remainder and add 48 to get ascii val
	mov		ecx, eax	;eax holds quo, we want to hang on to this
						;stashing it in ecx so that it's not overwritten
	mov		eax, edx	;stashing the remainder in eax to be stosb'ed
	stosb
	cmp		ecx, 0		;loop until the quotient is 0
						;this represents when we've
						;"run out" of digits, and have
						;converted the enttirey of the 
						;int to string
	jne		loop1			
	inc     edi
	displayString		edi		;invoke macro with new string

	pop     edi
	pop     edx
	pop     ecx
	pop     ebx
	pop     eax
	ret

writeVal ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Prints the array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print PROC
	mov		esi, [esp+12]	;addr of list
	mov		ecx, [esp+8]	;ecx is the loop counter
	mov		edx, [esp+4]

	call	CrLf
	call	WriteString
	call	CrLf
	mov		ebx, 0

	more:
		mov		eax, [esi]
	;	call	WriteDec	;REPLACE
	;value to be written is in eax currently
	;WritVal takes in stack param
	;does this mean i should put it in esi?
		
		;is this correct?
		call	WriteVal
		add		esi, 4

	spacing:
		mov		edx, OFFSET space
		call	WriteString

		loop	more
		jmp		endPrint

	endPrint:
		call	CrLf
		ret		12
print ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sums the array
;Recieves list as param
;performs calc and printing of sum here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sum PROC
	;get list
	mov		ecx, [esp + 8]
	mov		edi, [esp+4]	;@ of list in edi
	mov		ebx, 0
	mov		eax, 0

	mov		ecx, 10			;set up loop counter

	;move i into ebx
	;add ebx
	;add to eax
	;print eax

	addLoop:
		mov		ebx, [edi]	;grab list[i]
		add		eax, ebx	;stick [i] in ebx
		add		edi, 4
		loop	addLoop

	;print sum
	mov		edx, OFFSET showSum
	call	CrLf
	;call	writeDec		;CHANGE TO DISPLAYVAL
	;eax holds the val that needs to be written,
	;do i need to move it to esi before calling WriteVal?
	; I know I set up WriteVal to take a param in a certain way
	;but im still confused
	call	WriteVal
	call	CrLf

	;Get average
	avg:
		mov		edx,0	;prep for div
		mov		ebx, 10
		div		ebx

		call	CrLf
		mov		edx, OFFSET showAvg
		call	WriteString
		call	CrLf
		;call	WriteDec		;CHANGE TO DISPLAYVAL
		call	writeVal

	ret 8

sum ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Goodbye procedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
goodbye PROC
	call	CrLf
	mov		edx, OFFSET bye
	call	WriteString
	call	CrLf
	mov		edx, OFFSET quit
	call	WriteString
	call	ReadInt
	exit

goodbye ENDP

END main