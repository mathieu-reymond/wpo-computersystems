; ==============================================================================
; Exercise 3
; ==============================================================================
.MODEL small ; one data and one code segment, stack and data segment are grouped
.STACK 1024  ; stack, 1024 bytes


; ----------------------------- DATA STARTS HERE -------------------------------
.DATA        ; data segment, static variables

palette		db 0, 0, 0, 63, 63, 63	; defines black and white
oldVideoMode	db ?

SCREENW		equ 320
SCREENH		equ 200

; ----------------------------- CODE STARTS HERE -------------------------------
.CODE        ; code segment
main PROC NEAR
	mov	ax, @data	; get data segment address
	mov	ds, ax		; set DS to data segment

	; Set mode 13h
	mov	ax, 13h
	push	ax
	call	setVideoMode
	mov	[oldVideoMode], al
	
	; Set palette
	mov	ax, offset palette
	push	ax
	mov	ax, 2
	push	ax
	call setPalette
	
	; Setup ES
	mov	ax, 0a000h
	mov	es, ax
	
	; Clear video memory
	mov	cx, 64000 / 2
	xor	di, di
	xor	ax, ax
	rep	stosw
	
	; Draw a rectangle
	mov	ax, 100
	push	ax
	mov	ax, 40
	push	ax
	call drawRect
	
	; wait for keyboard press
@wait_key:
	xor	ax, ax
	int	16h
	cmp	al, 27	; test for ESC
	jne	@wait_key
	
	; Restore original video mode
	mov	al, [oldVideoMode]
	xor	ah, ah
	push	ax
	call	setVideoMode

	; Exit to DOS
	mov	ax, 4c00h	; exit to DOS function, return code 00h
	int	21h		; call DOS
main ENDP

; Set the video mode and returns the previous mode in AL.
setVideoMode PROC NEAR
	push	bp	; save dynamic link
	mov	bp, sp	; update bp
	push	bx
	
	mov	ah, 0fh	; get current video mode in al
	int	10h
	
	mov	bx, ax
	
	mov	ax, [bp+4][0]	; get requested mode
	xor	ah, ah		; function 0
	int	10h
	
	mov	ax, bx
	
	pop	bx
	pop	bp
	; return
	ret	2
setVideoMode ENDP

; Sets the palette colors
setPalette PROC NEAR
	push	bp	; save dynamic link
	mov	bp, sp	; update bp
	push	es
	push	ax
	push	bx
	push	cx
	push	dx
	
	; Set ES
	push	ds
	pop	es
	
	; Setup function 1012h of int 10h
	mov	dx, [bp+4][2]	; first arg
	mov	cx, [bp+4][0]	; second arg
	xor	bx, bx
	mov	ax, 1012h
	int	10h
	
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	es
	; return
	pop	bp
	ret	4
setPalette ENDP

; Draw a rectangle at the center of the screen.
; W, H passed on stack.
; Assumes ES is set to 0a000h.
drawRect PROC NEAR
	push	bp
	mov	bp, sp
	
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	
	; Calculate posX
	mov	ax, [bp+4][2]
	neg	ax
	add	ax, SCREENW
	shr	ax, 1
	mov	bx, ax		; posX is in BX now
	
	; Calculate posY
	mov	ax, [bp+4][0]
	neg	ax
	add	ax, SCREENH
	shr	ax, 1		; and posY is in AX
	
	; Calculate offset of top-left corner
	mov	dx, SCREENW
	mul	dx		; AX = posY * SCREENW
	add	ax, bx		; AX now conatins start offset of rectangle
	push	ax		; store for left vertical line drawing
	
	; Draw upper horizontal line
	mov	di, ax
	mov	cx, [bp+4][2]	; rect W
	mov	al, 1	; color
	rep	stosb	; draw
	
	dec	di
	mov	bx, di	; BX now contains the start of the right vertical line
	
	; Draw left vertical line
	pop	di
	push	bx	; store BX for drawing the right vertical line	
	mov	cx, [bp+4][0]	; rect H
@loopLeftLine:
	mov	es:[di], al	; set pixel
	add	di, SCREENW	; jump to next pixel (on next line)
	loop	@loopLeftLine
	
	sub	di, SCREENW
	mov	bx, di	; BX now conatins the start of the bottom horizontal line
	
	; Draw right vertical line
	pop	di
	push	bx	; store BX for drawing bottom horizontal line
	mov	cx, [bp+4][0]	; rect H
@loopRightLine:
	mov	es:[di], al	; set pixel
	add	di, SCREENW	; jump to next pixel (on next line)
	loop	@loopRightLine
	
	; Draw bottom horizontal line
	pop	di
	mov	cx, [bp+4][2]	; rect W
	rep	stosb	; draw
	
	; We are done
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	; return
	pop	bp
	ret	4
drawRect ENDP

; _------------------------------- END OF CODE ---------------------------------
END main
