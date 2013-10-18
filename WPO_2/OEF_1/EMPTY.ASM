; ==============================================================================
; Empty example assembly file.
; ==============================================================================
.MODEL small ; one data and one code segment, stack and data segment are grouped
.STACK 1024  ; stack, 1024 bytes
.DATA        ; data segment, global variables

.CODE        ; code segment

; ----------------------------- CODE STARTS HERE -------------------------------
main:
	mov	ax, @DATA
	mov	ds, ax
	
	mov dx, 54783 ;number to print
	mov bx, 10 ;base 10
	mov ch, 0  ;counter
	mov ax, dx ;division happens in ax
	
decimal:
	mov dx, 0 ;set dx to 0 for next division
	inc ch ;increment counter
	div bx
	add dx, 48
	push dx ;push on stack (rest of division)
	cmp ax, 0
	jnz decimal
	
print:
	pop dx
	mov ah, 02h ;print ASCII from dl (instruction to store in ah)
	int	21h ;execute instruction
	dec ch ;decrement counter
	jnz print

	; Exit to DOS
	mov	ax, 4c00h
	int	21h

; --- END

; _------------------------------- END OF CODE ---------------------------------
END main
