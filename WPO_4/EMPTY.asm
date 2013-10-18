; ==============================================================================
; Empty example assembly file.
; ==============================================================================
.MODEL small ; one data and one code segment, stack and data segment are grouped
.STACK 1024  ; stack, 1024 bytes
.DATA        ; data segment, global variables

	palette db 0,0,0,63,63,63
	
.CODE        ; code segment

; ----------------------------- CODE STARTS HERE -------------------------------

drawRectangle PROC NEAR
	push bp
	mov bp, sp
	
	;start-x of rect
	mov ch, 160
	sub ch, bh
	;start-y of rect
	mov cl, 100
	sub cl, bl
	
firstHorizontal:
	mov ax, 0
	mov al, bl ;y-coord in al
	mul 320 ;mult al with screen-width
	add al, bh ;add x-coord
	
	mov dx
	mov[es:ax], 

main:
	;set resolution to default (320x200)
	mov ax, 13h
	int 10h
	
	;set palette (0= black, 1=white)
	mov ax, @data
	mov ds, ax
	mov es, ax
	mov dx, offset palette
	xor bx, bx
	mov cx, 2
	mov ax, 1012h
	int 10h
	
	;test
	mov al, 1
	mov ah, 0ch
	mov cx, 50
	mov dx, 50
	int 10h
	
	mov ax, 0a000h
	mov es, ax
	mov ax, 2500
	mov cx, 1
	mov [es:2500], cx

	; Exit to DOS
	mov	ax, 4c00h
	int	21h

; --- END

; _------------------------------- END OF CODE ---------------------------------
END main
