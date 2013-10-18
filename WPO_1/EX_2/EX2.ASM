; ==============================================================================
; Exercise 2
; ==============================================================================
.MODEL small ; one data and one code segment, stack and data segment are grouped
.STACK 1024  ; stack, 1024 bytes

; ----------------------------- DATA STARTS HERE -------------------------------
.DATA        ; data segment, global variables

newline	db 0dh, 0ah, '$'

; ----------------------------- CODE STARTS HERE -------------------------------
.CODE        ; code segment
main PROC NEAR
	mov	ax, @data	; get data segment address
	mov	ds, ax		; set DS to data segment

	mov	ax, 23578
	push	ax
	call	printint

	mov	ah, 09h
	mov	dx, offset newline
	int	21h
	
	mov	ax, -12345
	push	ax
	call	printints

	mov	ah, 09h
	mov	dx, offset newline
	int	21h
	
	mov	ax, 0
	push	ax
	call	printints

	mov	ax, 4c00h	; exit to DOS function, return code 00h
	int	21h		; call DOS
main ENDP

; print an unsigned integer to stdout
; value on stack
printint PROC NEAR
	push	bp	; save dynamic link
	mov	bp, sp	; update bp
	; save context on stack
	push	ax
	push	bx
	push	cx
	push	dx
	push	si	
	; load param in bx
	mov	bx, [bp + 4]	; near proc, one word return address
	; handle special case of zero
	test	bx, 0FFFFh
	jnz	@printint_nonzero
	mov	ah, 02h
	mov	dl, '0'
	int	21h		; print the '0' character
	jmp	@printint_done
@printint_nonzero:
	; prepare powers-of-ten on stack
	mov	ax, 1
	push	ax
	mov	ax, 10
	push	ax
	mov	ax, 100
	push	ax
	mov	ax, 1000
	push	ax
	mov	ax, 10000
	push	ax
	; from now on bx is strictly positive
	; determine largest power of ten smaller than bx
	; init si to point to first element of powersoften array
	; while bx < cx, pop cx 
@printint_nextpoweroften:
	pop	cx
	cmp	bx, cx
	jae	@printint_poweroftenfound
	jmp	@printint_nextpoweroften
@printint_poweroftenfound:
	; ok now print digits
	mov	ax, bx
	cwd		; sign extend to DX:AX (32-bit)
	idiv	cx	; divide DX:AX by current power of ten
				; result in AX, remainder in DX
	mov	bx, dx	; move remainder to bx
	mov	ah, 02h	; print one character
	mov	dl, al	; al contains the digit, move into dl
	add	dl, 48	; add 48 to convert it to ASCII
	int	21h	; call DOS function
	; was this the last digit? i.e. [si] equals 1
	cmp	cx, 1
	je	@printint_done
	pop	cx	; next power of ten
	jmp	@printint_poweroftenfound ; repeat for next digit
@printint_done:
	; restore context (reverse pop the registers)
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	; restore sp and bp
	mov	sp, bp
	pop	bp
	; return freeing param from stack (2 bytes)
	ret	2
printint ENDP

; print a signed integer to stdout
; value on stack
printints PROC NEAR
	push	bp	; save dynamic link
	mov	bp, sp	; update bp
	; save context on stack
	push	ax
	push	bx
	push	dx
	; load param in bx
	mov	bx, [bp + 4]	; near proc, one word return address
	; handle special case of zero and test for sign
	cmp	bx, 0
	jge	@printints_positive_or_zero
	; if negative, print sign and invert
	; print sign (int 21h, function 02h)
	mov	ah, 2
	mov	dl, '-'
	int	21h
	; invert sign of bx
	neg	bx
@printints_positive_or_zero:
	push	bx
	call	printint	
	; restore context (reverse pop the registers)
	pop	dx
	pop	bx
	pop	ax
	; restore sp and bp
	mov	sp, bp
	pop	bp
	; return freeing param from stack (2 bytes)
	ret	2
printints ENDP

; _------------------------------- END OF CODE ---------------------------------
END main
