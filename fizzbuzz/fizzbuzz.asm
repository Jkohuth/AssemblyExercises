global _start

section .data
	fizz db "fizz"
	fizzlen equ $ - fizz
	buzz db "buzz"
	buzzlen equ $ - buzz
	nline db 0xa
	nlinelen equ $ - nline

section .bss
	result resb 1
	
section .text
_start:
	mov rax, 1        ; Count up from 1
loop:
	mov rbx, 1        ; Need this for iteration to not skip outputnum
			          ; Essentially need a flag to see if number was divisible by 3

; This doesn't need to be its own section but I like it for the organization
cmpthree:
	push rax          ; Store the current value of the iteration
	
	mov rcx, 3
	mov rdx, 0        ; Clear the remainder spot, all the 'write' functions need to populate this value
			          ; Which has thrown off my numbers 
	div rcx
	cmp rdx, 0        ; Ensure the remainder is 0, ie was divisible by 3
	je writefizz      ; Was divisible so output fizz and set rbx to zero
				      ; rbx to zero will be explained later

	pop rax           ; Did not jump, so populate rax with the loop iteration and continue
	
; Call does not do conditionals so I made sections in my code to jump around to
; Would be more interesting to see if I could set ebi/rbi for ret, but I am not doing any
; more reading at this point in time 
cmpfive:
	push rax          ; Put it back on the stack for later
	mov rcx, 5
	mov rdx, 0        ; Clear out rdx in case any writes took place
	div rcx 
	cmp rdx, 0        ; Ensure remainder is zero, ie divisible by 5
	je writebuzz      ; If equal output buzz

	pop rax           ; Did not jump, clear the stack prior to continuing
	jmp skipnum       ; Getting to this point implies the number was not divisible by 5
				      ; Check to see if the number was divisible by 3 based on a value stored
				      ; By writefizz function, essentially a flag

; This will output any number up to 999, however it writes 0s across the board instead
; of 1 it's 001. Any further cleanup would be considered an optimization so this is good enough
outputnum:
	push rax          ; Store the iteration on the stack
	mov rdx, 0        ; Clear out rdx in case any writes took place
	mov rcx, 100      ; A bit of cheating here since we know it will only get to 3 digits
				      ; theres probably some sort of function i can make that will work with
				      ; n digits but I know the parameters in advance and thats an optimization
	div rcx

	push rdx          ; Push remainder on the stack

	call writedigit   ; Output the digit in the hundreds place, call is simpler than jump
					  ; and we will always write the digit if we made it here

	pop rax           ; Get the remainder pushed to the stack earlier
	mov rdx, 0        ; Clear rdx, it was populated with the write and led to weirdness if not cleared
					  ; Assuming the weird came from how division pushes a value into rdx, some kind of bit addition taking place?
	mov rcx, 10       ; Get the value for the 10s place
	div rcx
	push rdx          ; Push the remainder (ones place) onto the stack
	call writedigit   ; Write the 10s place

	pop rax           ; Get the remainder (ones place)
	mov rdx, 0        ; Clear out rdx for the division
	call writedigit   ; We are at single digit values here so no need to divide
	pop rax           ; Get the iteration count back in rax

; Every loop/iteration this function is always called
newline:
	push rax          ; Store the iteration count on the stack
	jmp writeline     ; Write a newline
	
; Finally check to see if we've iterated the loop enough times
; Increment or Terminate
incorterm:
	pop rax           ; Get the iteration count, pushed on the stack by newline
	inc rax           ; Increment the value
	cmp rax, 100      ; Compare if we are at limit
	jg term           ; If we are greater than 100 than jump to the terminate function
	jmp loop          ; We have not reached the limit jump to start and begin the whole process again


writefizz:
	mov rax, 4        ; syscall write
	mov rbx, 1        ; stdout file description
	mov rcx, fizz     ; Fizz output string
	mov rdx, fizzlen  ; Fizz output string length
	int 0x80          ; Interrupt to output the string
	pop rax           ; Get the iteration count back into rax

	mov rbx, 0        ; rbx here is used as a flag, if the number was divisible by 3 then this is set such that
					  ; skipnum can not output the current value after checking if the value was divisible by 5
	jmp cmpfive       ; Check to see if the number was divisible by 5

writebuzz:
	mov rax, 4        ; syscall write
	mov rbx, 1        ; stdout file description
	mov rcx, buzz     ; Buzz output string
	mov rdx, buzzlen  ; Buzz output string length
	int 0x80          ; Interrupt to output the string
	pop rax           ; Get the iteration count back into rax
	
	jmp newline       ; Since we are done checking division if we made it here it was divisible by at least one
					  ; of the two numbers (3 or 5) so skip outputnum and go straight to newline

; Write each individual digit, outputnum handles feeding in the numbers
writedigit:
	add rax, '0'      ; Adding the ascii value of '0' offset the digit enough to output the digit on the Ascii table
	mov [result], rax ; Store the value in memory

; Output the digit
	mov rax, 4
	mov rbx, 1
	mov rcx, result   ; Output the address which will be the hex value of the digit
	mov rdx, 1
	int 0x80
	ret				  ; ret instead of jump since we will always circle back here

; Function is self explanitory like all good code is XD
writeline:
	mov rax, 4
	mov rbx, 1
	mov rcx, nline
	mov rdx, nlinelen
	int 0x80
	jmp incorterm

skipnum:
	cmp rbx, 0        ; At the end of writefizz we write 0 into rbx, at the beginning of the loop
					  ; or if we output anything it will set this value to 1, so this will only be
					  ; 0 if the number is divisible by 3 and not 5 (if the number was divisible by
					  ; 5 you wouldn't even reach this code)
	je newline		  ; Number is divisible by 3 and not 5 so jump to newline
	jmp outputnum     ; Number is not divisible by 3 or 5 so output the number to console

term:
	mov rax, 1        ; Terminate the program
	mov rbx, 0        ; Return code 0
	int 0x80
