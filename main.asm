	; Joey Hardester - XD32736
	; Thomas Moran - AE10376
	; CMSC 313, Section 02
	; This file is to be the main directory to help the user accomplish their intended goal with the program.
	
	extern printf
	extern scanf		
	extern printArr
	extern caesar
	extern validate
	extern stringDecrypt
	extern freeUp
	extern easterEggC

	section .data
msg:		db	"This is the original message.", 10, 0

msg1:		db	"This is the original message.", 10, 0

msg2:		db	"This is the original message.", 10, 0

msg3:		db	"This is the original message.", 10, 0

msg4:		db	"This is the original message.", 10, 0

msg5:		db	"This is the original message.", 10, 0

msg6:		db	"This is the original message.", 10, 0

msg7:		db	"This is the original message.", 10, 0

msg8:		db	"This is the original message.", 10, 0

msg9:		db	"This is the original message.", 10, 0

enc_menu:	db	"Encryption menu options:", 10, 0

op_s:		db	"s - show current messages", 10, 0

op_r:		db	"r - read new message", 10, 0

op_c:		db	"c - caesar cipher", 10, 0

op_f:		db	"f - frequency decrypt", 10, 0

op_q:		db	"q - quit program", 10, 0

ent_let:	db	"enter option letter -> ", 0

fmt:		db	" %s", 0

fmtChar:	db	" %c", 0

fmtNum:		db	" %d", 0

inv_c:		db	"invalid option, try again", 10, 0

str_loc:	db	"Enter string location: ", 0

shf_val:	db	"Enter shift value: ", 0

new_msg:	db	"Enter new message: ", 0

new_line:	db	10, 0

	section .bss
char_buff:	resb	1
int_buff:	resb	2
temp:		resq	1
stringarr:	resq	10
pos_track:	resd	1
ca_buff:	resq	1
del_track:	resd	1
ee_track:	resd	1

	section .text

	global main
main:
	xor	rax, rax
	mov	[pos_track], rax
	xor	r15, r15
init:
	; initializes array with different memory addresses for original message
	mov	qword[stringarr+0], msg	
	mov	qword[stringarr+8], msg1
	mov	qword[stringarr+16], msg2
	mov	qword[stringarr+24], msg3
	mov	qword[stringarr+32], msg4
	mov	qword[stringarr+40], msg5
	mov	qword[stringarr+48], msg6
	mov	qword[stringarr+56], msg7
	mov	qword[stringarr+64], msg8
	mov	qword[stringarr+72], msg9
menu:
	xor	rax, rax
	xor	rdi, rdi
	xor	rsi, rsi

	mov	rdi, new_line	; prints a new line
	mov	rax, 0
	call	printf
	
	mov	rdi, fmt	; prints "Encryption menu options: "
	mov	rsi, enc_menu
	mov	rax, 0
	call	printf

	mov	rdi, fmt	; prints "s - show current messages"
	mov	rsi, op_s
	mov	rax, 0
	call 	printf

	mov	rdi, fmt	; prints "r - read new message
	mov	rsi, op_r
	mov	rax, 0
	call 	printf

	mov	rdi, fmt	; prints "c - caesar cipher"
	mov	rsi, op_c
	mov	rax, 0
	call 	printf

	mov	rdi, fmt	; prints "f - frequency decrypt"
	mov	rsi, op_f
	mov	rax, 0
	call 	printf

	mov	rdi, fmt	; prints "q - quit program"
	mov	rsi, op_q
	mov	rax, 0
	call	printf

	mov	rdi, fmt	; prints "enter option letter -> "
	mov	rsi, ent_let
	mov	rax, 0
	call	printf

readIn:
	push	rbp		; reads in letter input from the user
	mov	rdi, fmtChar
	mov	rsi, temp	; value is stored in temp
	mov	rax, 0
	call 	scanf
	pop	rbp


selectOption:
	mov	r14, [temp]	; user input is stored in r14

	cmp	r14, 115	; if the letter value is s or S, displays messages
	je	show
	cmp	r14, 83
	je	show

	cmp	r14, 114	; if the letter value is r or R, reads new message
	je	readFunc
	cmp	r14, 82
	je	readFunc

	cmp	r14, 99		; if the letter value is c or C, performs caesar cipher
	je	cipher
	cmp	r14, 67
	je	cipher

	cmp	r14, 102	; if the letter value is f or F, performs frequency decrypt
	je	decrypt
	cmp	r14, 70
	je	decrypt

	cmp	r14, 113	; if the letter value is q or Q, ends program
	je	exit
	cmp	r14, 81
	je	exit

	jmp	invalid		; if the letter is none of the correct options

show:
	mov	rdi, stringarr	; moves the array into first paramter slot
	mov	rax, 0
	push 	rbp
	call	printArr	; calls C function to print array
	pop	rbp
	jmp 	checkEasterEgg	; used to update easter egg value

readFunc:
	mov	rdi, fmt	; prints "Enter new message: "
	mov	rsi, new_msg
	mov	rax, 0
	call	printf
	
	mov	rdi, stringarr	; moves the array into first parameter slot
	mov	rsi, [pos_track] ; pos_track is used to track position in array that is replaced
	mov	rdx, [del_track] ; del_track is used to track how many user inputs there are in total(for dynamic memory deletion)
	mov	rax, 0
	call	validate	; calls C function to potentially update string value
	
	mov	rsi, [pos_track] ; value of pos_track is stored in rsi
	mov	r8, [del_track]	 ; value of del_track is stored in r8
	add	rsi, rax	 ; rax holds 1 or 0 (1 for updated string, 0 for invalid message)
	add	r8, rax		 
	mov	[pos_track], rsi ; pos_track is updated to new value
	mov	[del_track], r8	 ; del_track is updated to new value
	cmp	rsi, 10		 ; if position is at 10, reset position to 0 for new messages
	jz	resetPos	 ; resets pos_track to 0
	
	jmp	checkEasterEgg	; used to update easter egg value

cipher:
	mov	rdi, fmt	; prints "Enter string location: "
	mov	rsi, str_loc
	mov	rax, 0
	call	printf
	
	push	rbp		; reads in user input for string location
	mov	rdi, fmtNum
	mov	rsi, temp	; user input is stored in temp
	mov	rax, 0
	call	scanf
	pop	rbp

	mov	r9, [temp]	; r9 holds value of user input
	mov	[int_buff], r9  ; string location is stored in int_buff

	mov	rdi, fmt	; "prints "Enter shift value: "
	mov	rsi, shf_val
	mov	rax, 0
	call	printf

	push	rbp
	mov	rdi, fmtNum	; reads in user input for shift value
	mov	rsi, temp	; shift value is stord in temp
	mov	rax, 0
	call	scanf
	pop	rbp

	mov	r11, [temp]	; shift value is stored in r11

	xor	rax, rax
	mov	al, [int_buff]	; string location is moved into al(for multiplication)
	mov	rcx, 8		
	mul	rcx		; rax*rcx, is stored in rax  

	mov	rdi, [stringarr+rax] ; string address for location is moved into rdi
	mov	rsi, r11	     ; shift value is moved into rsi
	mov	rax, 0
	call	caesar		

	xor	r8, r8
	mov	r8, rax		; r8 stores new encrypted string address
	xor	rax, rax
	mov	al, [int_buff]	; string location is moved into al
	mov	rcx, 8		
	mul	rcx		; rax*rcx, is stored in rax
	
	mov	qword[stringarr+rax], r8 ; string at location is updated to new encrypted string
		
	jmp 	checkEasterEgg	; used to update easter egg value
	
decrypt:
	mov	rdi, fmt	; prints "Enter string location: "
	mov	rsi, str_loc
	mov	rax, 0
	call	printf

	push	rbp		; reads in user input for string location
	mov	rdi, fmtNum
	mov	rsi, temp	; user input is stored in temp
	mov	rax, 0
	call	scanf
	pop	rbp

	mov	rdi, stringarr	; array is moved to first parameter slot
	mov	rsi, [temp]	; value of string location is moved to second parameter slot
	mov	rax, 0
	call	stringDecrypt	; calls c Function to do frequency decrypt
	
	jmp	checkEasterEgg	; used to update easter egg value

invalid:
	mov	rdi, fmt	; prints "invalid option, try again"
	mov	rsi, inv_c
	mov	rax, 0
	call	printf

	jmp	checkEasterEgg 	; used to update easter egg value
resetPos:
	mov	rsi, 0
	mov	[pos_track], rsi ; pos_track is updated to 0(new spot in array for user input)

	mov	rsi, 0
	mov	rsi, [del_track] ; once del_track = 10, it stays because the max amount of dynamic memory allocation has happened
	cmp	rsi, 11
	jz 	delCheck	; used to maintain that del_track = 10
	
	jmp	checkEasterEgg	; used to update easter egg value

delCheck:
	mov	rsi, 0
	mov	rsi, [del_track] ; rsi will equal 11
	sub	rsi, 1		 ; rsi = 10
	mov	[del_track], rsi ; del_track stays equal to 10
	
	jmp 	checkEasterEgg	; used to update easter egg value

checkEasterEgg:
	cmp	r14, 122	; if the user enters z or Z four times in a row, easter egg occurs
	je	incEasterEgg
	cmp	r14, 90
	je	incEasterEgg

	jmp	resEasterEgg	; resets if user input is not z or Z

incEasterEgg:
	xor	r15, r15
	mov	r15, [ee_track]
	add	r15, 1	

	cmp	r15, 4		; fourth time, easter egg occurs
	je	easterEgg

	mov	[ee_track], r15 ; value is stored into ee_track
	
	jmp	menu

resEasterEgg:
	xor	r15, r15
	mov	[ee_track], r15 ; 0 is stored in ee_track
	
	jmp	menu

easterEgg:
	call	easterEggC 	; calls C function for easter egg

	jmp	resEasterEgg	; resets for next cycle
	
exit:
	xor	rsi, rsi	
	mov	rdi, stringarr	; array is moved into first parameter slot
	mov	rsi, [del_track] ; del_track is moved into second parameter slot
	call	freeUp		 ; frees any dynamically allocated memory
	
	mov	rax, 60		; exits the program
	xor	rdi, rdi
	syscall
