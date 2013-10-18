; ==============================================================================
; Empty example assembly file.
; ==============================================================================
.MODEL small ; one data and one code segment, stack and data segment are grouped
.STACK 1024  ; stack, 1024 bytes
.DATA        ; data segment, global variables

string "hello world!$"

.CODE        ; code segment

; ----------------------------- CODE STARTS HERE -------------------------------

printDecimal PROC NEAR
	push bp
	mov bp, sp
	
	;==saving reg values on stack==
	push ax
	push bx
	push cx
	push dx
	;==end==

	mov bx, 10 ;base 10
	mov ch, 0  ;counter
	mov ax, [bp+4] ;division happens in ax (take arg from stack, 2 places further from the current bp)

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
	
	;==restoring reg values on stack==
	pop dx
	pop cx
	pop bx
	pop ax
	;==end==
	
	mov sp, bp
	pop bp
	ret 0
printDecimal ENDP
	
main:
	mov	ax, @DATA
	mov	ds, ax
	
	mov bx, offset string
	mov si, 0 ;si is counter register

stringLoop:
	mov al, [bx][si]
	cmp '$', al ; '$' means end of string
	mov ax, si
	inc si
	jnz stringLoop
	
	push si ;counter will be printed
	call printDecimal

	; Exit to DOS
	mov	ax, 4c00h
	int	21h

; --- END

; _------------------------------- END OF CODE ---------------------------------
END main
