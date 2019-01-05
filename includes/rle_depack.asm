;
; RLE DECOMPRESSOR
;

rle_unpack	ldx rle_timer
		beq rle_new_byte

; There's currently a run length on the go
rle_expand	dec rle_timer
		lda rle_byte
		rts

; No run length, so fetch a byte and check to see if the next is the same
rle_new_byte	ldx #$00
		jsr rle_read
		sta rle_byte
		inx
		jsr rle_read

; Found an RLE token
		cmp rle_byte
		beq rle_init_run

rle_exit	jsr rle_read_bump

		lda rle_byte
		rts

; Start of a run detected so configure for it
rle_init_run	jsr rle_read_bump
		jsr rle_read_bump

		ldx #$00
		jsr rle_read
		clc
		adc #$01
		sta rle_timer

		jmp rle_exit


; Self modifying byte reader
rle_read	lda $6502,x
		rts

rle_read_bump	inc rle_read+$01
		bne *+$05
		inc rle_read+$02
		rts

rle_timer	!byte $00
rle_byte	!byte $00
