; ==============================================================================
; Exercise 1
; ==============================================================================
.MODEL small ; one data and one code segment, stack and data segment are grouped
.STACK 1024  ; stack, 1024 bytes
.DATA        ; data segment, global variables

msg	db "Hello World!$"

.CODE        ; code segment

; ----------------------------- CODE STARTS HERE -------------------------------
main:
	mov	ax, @data	; get data segment address
	mov	ds, ax		; set DS to data segment

	mov	ah, 09h		; select function 09h
	mov	dx, offset msg	; load offset address of msg (in data segment)
	int	21h		; call DOS, function 09h, print to stdout

	mov	ax, 4c00h	; exit to DOS function, return code 00h
	int	21h		; call DOS

; _------------------------------- END OF CODE ---------------------------------
END main