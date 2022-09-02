	; Joey Hardester - XD32736
	; Thomas Moran - AE10376
	; CMSC 313, Section 02
	; This file is to help the main assembly file by doing the caesar encryption.
	
	extern printf
	
	section .data
curr_msg:	db	"Current message: ", 0

fmt:		db	"%s", 0

c_msg:		db	"Caesar encryption: ", 0
	
	section .text

	global caesar
caesar:
	xor	r14, r14
	xor	r15, r15
	mov	r14, rdi	; r14 = string
	mov	r15, rsi	; r15 = shift value

	mov	rdi, fmt	; print the message for the current message
	mov	rsi, curr_msg
	mov	rax, 0
	call	printf

	mov	rdi, fmt	; print the current message
	mov	rsi, r14
	mov	rax, 0
	call	printf

	xor	r11, r11
	mov	r11, r14	; r11 = placeholder for string address(r14 will be used to get individual char)
	
startLoop:
	xor	r8, r8		; clear registers for future use
	xor	r9, r9
	xor	r12, r12
	xor	r13, r13
	mov	r12b, [r14]	; r12b holds the value for the character
checkLowerCase:
	xor	r8, r8
	xor	r9, r9
	mov	r8, 96		; lower bound for lowercase letters
	mov	r9, 122		; upper bound for uppercase letters
	cmp	r12, r8		; to check if the value is below the lower bound
	js	checkUpperCase	; jump to check if the letter is uppercase
	cmp	r9, r12		; to check if the value is above the upper bound
	js	endLoop		; value is neither uppercase or lowercase
	jmp	shiftLowerCase	; value is a lowercase letter

checkUpperCase:
	xor	r8, r8
	xor	r9, r9
	mov	r8, 64		; lower bound for uppercase letters
	mov	r9, 90		; upper bound for uppercase letters
	cmp	r12, r8		
	js	endLoop		; value is neither uppercase or lowercase
	cmp	r9, r12
	js	endLoop		; value is neither uppercase or lowercase
	jmp	shiftUpperCase	; value is a uppercase letter

shiftLowerCase:
	xor	r8, r8
	xor 	r9, r9
	xor	r10, r10
	mov	r8, 122		; r8 = overflow check value
	mov	r9, r15		; r9 = shift value
	mov	r10, r12	; r10 = current letter
	add	r10, r9		; shift value is applies to letter
	cmp	r8, r10		; checks if the value is above the overflow check value
	js	shiftOver	; if it is, special case where letters wrap around
	add	r12, r9		; normal case
	jmp	endLoop

shiftOver:
	xor	r8, r8
	xor	r9, r9
	mov	r8, 26		; for overshift, shift value = 26 - shift value
	mov	r9, r15		
	sub	r8, r9		; 26 - shift value, value is stored in r8
	sub	r12, r8		; shift is applied to current letter
	jmp	endLoop

shiftUpperCase:
	xor	r8, r8
	xor	r9, r9
	xor	r10, r10
	mov	r8, 90		; r8 = overflow check value
	mov	r9, r15		; r9 = shift value
	mov	r10, r12	; r10 = current letter
	add	r10, r9		; shift value is applied
	cmp	r8, r10		; checks if the value is above the overflow check value
	js	shiftOver	; if it is, special case where letters wrap around
	add	r12, r9		; normal case
	jmp	endLoop

endLoop:
	mov	byte[r11+rcx], r12b ; new char value is updated in string
	add	rcx, 1		    ; used to keep track of current byte to update
	
	add	r14, 1		; next character is top 
	xor	r12, r12
	mov	r12b, [r14]	; new character is stored in r12b
	cmp	r12b, 0		; if the character is 0, reached end of string
	jz	afterEnc	; jumps if character is 0
	jmp	startLoop


afterEnc:
	mov	r14, r11	; new string is put back into r14
	
	mov	rdi, fmt	; prints "Caesar encryption: "
	mov	rsi, c_msg
	mov	rax, 0
	call	printf
	
	mov	rdi, fmt	; prints the new encrypted string
	mov	rsi, r14
	mov	rax, 0
	call	printf

	mov	rax, r14	; string is stored in rax(return value)

	ret			; return back to main
