;
; LEVEL ONE
;

; Code and graphics by T.M.R/cosine
; Music by aNdy/Cosine


; This source code is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with Exomizer which can be downloaded at
; https://csdb.dk/release/?id=167084

; build.bat will call both to create an assembled file and then the
; crunched release version.


; Select an output filename
		!to "level_one.prg",cbm


; Yank in some binary data
		* = $0c00
		!binary "data/start_screen.raw"

		* = $0800
char_data	!binary "data/background.chr"

		* = $1000
music		!binary "data/y_sgrechian_o_jarre.prg",,2

		* = $3c00
scroll_sprs_ub	!binary "data/scroll_sprites.spr",$200

		* = $3e00
scroll_sprs_lb	!binary "data/scroll_sprites.spr",$200,$200


; Constants
rstr1p		= $00
rstr2p		= $22
rstr3p		= $ef

screen_col	= $0b
border_col	= $0c

scroll_length	= $c0		; how wide the map is in bytes

; Colours for the upper border's splits
ub_scroll_col_00	= $05
ub_scroll_col_01	= $03
ub_scroll_col_02	= $0d
ub_scroll_col_03	= $01
ub_scroll_col_04	= $0d
ub_scroll_col_05	= $03
ub_scroll_col_06	= $0e
ub_scroll_col_07	= $04
ub_scroll_col_08	= $06

; Colours for the lower border's splits
lb_scroll_col_00	= $04
lb_scroll_col_01	= $0e
lb_scroll_col_02	= $03
lb_scroll_col_03	= $0d
lb_scroll_col_04	= $01
lb_scroll_col_05	= $0d
lb_scroll_col_06	= $03
lb_scroll_col_07	= $05
lb_scroll_col_08	= $0b

; Labels
rn		= $50
sync		= $51
scroll_cnt_ub	= $52
scroll_cnt_lb	= $53

d016_mirror	= $54
d018_mirror	= $55
bg_scroll_x	= $56
map_width	= $57

parallax_tmr	= $58

char_buffer	= $60		; $18 bytes
cos_logo_zp	= $78		; $08 bytes

; Background scroller buffers
buffer_1	= $0400
buffer_2	= $0c00


; Entry point at $0a00 - one-shot initialisation code
		* = $0a00
entry		sei

; Turn off ROMs and set up interrupts
		lda #$35
		sta $01

		lda #<nmi
		sta $fffa
		lda #>nmi
		sta $fffb

		lda #<int
		sta $fffe
		lda #>int
		sta $ffff

		lda #$7f
		sta $dc0d
		sta $dd0d

		lda $dc0d
		lda $dd0d

		lda #rstr1p
		sta $d012

		lda #$1b
		sta $d011
		lda #$01
		sta $d019
		sta $d01a

; Clear label space and set some specific labels
		ldx #$50
		lda #$00
nuke_zp		sta $00,x
		inx
		bne nuke_zp

		lda #$01
		sta rn

		lda #$07
		sta d016_mirror
		lda #$32
		sta d018_mirror

		lda #$00
		sta bg_scroll_x

; Reset the scrolling messages
		jsr reset_ub
		jsr reset_lb

		ldx #$00
		lda #$ff
char_bffr_rst	sta char_buffer,x
		inx
		cpx #$18
		bne char_bffr_rst

; Clear the colour RAM
		ldx #$00
		lda #$0c
colour_init	sta $d800,x
		sta $d900,x
		sta $da00,x
		sta $dae8,x
		inx
		bne colour_init

; Copy a little character data to the ZP for timing reasons(!)
		ldx #$00
cos_copy	lda cos_char_data,x
		sta cos_logo_zp,x
		inx
		cpx #$08
		bne cos_copy

; Initialise the music
		lda #$00
		jsr music+$00

; Configure the RLE depacker
		jsr scroll_init

		cli

		jmp main_loop

; Copyright symbol graphic used by the lower border logo
; (gets copied to the zero page so the lower border routine can
; waste a cycle!)
cos_char_data	!byte %11100001
		!byte %11011110
		!byte %10110001
		!byte %10100111
		!byte %10100111
		!byte %10110001
		!byte %11011110
		!byte %11100001


; IRQ interrupt
		* = $1b00

int		pha
		txa
		pha
		tya
		pha

		lda $d019
		and #$01
		sta $d019
		bne ya
		jmp ea31

ya		lda rn

		cmp #$02
		bne *+$05
		jmp rout2

		cmp #$03
		bne *+$05
		jmp rout3


; Raster split 1
rout1		lda #border_col
		sta $d020
		lda #border_col
		sta $d021

		lda #$0f
		sta $d022
		lda #$09
		sta $d023
		lda #$00
		sta $d024

		lda #$00
		sta $3fff

		lda #$1b
		sta $d011
		lda #$07
		sta $d016
		lda d018_mirror
		sta $d018

; Init sprites for the upper border
		lda #$ff
		sta $d015

		ldx #$00
set_spr_pos_ub	lda sprite_pos_ub,x
		sta $d000,x
		inx
		cpx #$11
		bne set_spr_pos_ub

		ldx #$00
set_spr_dp_ub	lda sprite_dp_ub,x
		sta buffer_1+$3f8,x
		sta buffer_2+$3f8,x
		lda #$00
		sta $d027,x
		inx
		cpx #$08
		bne set_spr_dp_ub

; Set up for the second raster split
		lda #$02
		sta rn
		lda #rstr2p
		sta $d012

		jmp ea31


; Sprite data for the upper border
sprite_pos_ub	!byte $27,$28,$3f,$28,$57,$28,$6f,$28
		!byte $87,$28,$9f,$28,$17,$28,$2f,$28
		!byte $c0

sprite_dp_ub	!byte $f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7


; Sprite data for the upper border
sprite_pos_lb	!byte $27,$f9,$3f,$f9,$b7,$f9,$cf,$f9
		!byte $e7,$f9,$ff,$f9,$17,$f9,$2f,$f9
		!byte $c0

sprite_dp_lb	!byte $f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff


; Text buffer for the upper scroller
buffer_ub	!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$00

; Mask for the lower border scroller
lb_char_mask	!byte %01010100
		!byte %10101001
		!byte %11010000
		!byte %10101010
		!byte %01010100
		!byte %11101001
		!byte %11010010
		!byte %01101000

; Quick and dirty $d018 decode table for the background scroller
d018_decode	!byte $32,$32,$32,$32,$32,$32,$32,$32
		!byte $12,$12,$12,$12,$12,$12,$12,$12

; Raster split 2
		* = ((*/$100)+$01)*$100

rout2		nop
		nop
		nop
		nop
		nop
		bit $ea

		lda $d012
		cmp #rstr2p+$01
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr2p+$02
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$03
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$04
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		bit $ea
		nop
		lda $d012
		cmp #rstr2p+$05
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		bit $ea
		lda $d012
		cmp #rstr2p+$06
		bne *+$02
;		sta $d020

; Wait for the start of the upper border effect
		ldx #$08
		dex
		bne *-$01
		nop
		nop

		lda #$ff
		sta $3fff

		ldx #$05
		dex
		bne *-$01
		nop
		nop

		ldx #ub_scroll_col_00
		stx $d021

; Upper border splitter
		ldy #$00
ghost_ub_00a	lda #$ff
		sta $3fff
		sty $3fff

		nop
		nop
		nop
		nop
		nop
		nop

		lda #$ff
		sta $3fff

		lda #ub_scroll_col_01
		sta $d021

ghost_ub_01a	lda #$ff
		sty $3fff

		ldx #%10000011
		stx $3fff
		sta $3fff
		sty $3fff

		nop
		nop
		nop
		nop
		nop
		nop

		lda #$ff
		sta $3fff

		lda #ub_scroll_col_02
		sta $d021

ghost_ub_02a	lda #$ff
		sty $3fff

		ldx #%00111001
		stx $3fff
		sta $3fff
		sty $3fff

		nop
		nop
		nop
		nop
		nop
		nop

		lda #$ff
		sta $3fff

		lda #ub_scroll_col_03
		sta $d021

ghost_ub_03a	lda #$ff
		sty $3fff

		ldx #%00111111
		stx $3fff
		sta $3fff
		sty $3fff

		nop
		nop
		nop
		nop
		nop
		nop

		lda #$ff
		sta $3fff

		lda #ub_scroll_col_04
		sta $d021

ghost_ub_04a	lda #$ff
		sty $3fff

		ldx #%00001111
		stx $3fff
		sta $3fff
		sty $3fff

		nop
		nop
		nop
		nop
		nop
		nop

		lda #$ff
		sta $3fff

		lda #ub_scroll_col_05
		sta $d021

ghost_ub_05a	lda #$ff
		sty $3fff

		ldx #%00011111
		stx $3fff
		sta $3fff
		sty $3fff

		nop
		nop
		nop
		nop
		nop
		nop

		lda #$ff
		sta $3fff

		lda #ub_scroll_col_06
		sta $d021

ghost_ub_06a	lda #$ff
		sty $3fff

		ldx #%00011111
		stx $3fff
		sta $3fff
		sty $3fff

		nop
		nop
		nop
		nop
		nop
		nop

		lda #$ff
		sta $3fff

		lda #ub_scroll_col_07
		sta $d021

ghost_ub_07a	lda #$ff
		sty $3fff

		ldx #%00000001
		stx $3fff
		sta $3fff
		sty $3fff



		nop
		nop
		nop
		nop
		nop
		nop

		lda #$ff
		sta $3fff

		lda #ub_scroll_col_08
		sta $d021

ghost_ub_08a	lda #$ff
		sty $3fff

		ldx #%10000001
		stx $3fff
		sta $3fff

; First text area done so get ready for the screen
		ldx #$03
		dex
		bne *-$01

		lda d016_mirror
		ldx #$5b
		ldy #screen_col
		sta $d016

		nop
		nop
		nop
		nop
		sty $d021
		stx $d011

; Call updater code for the upper border text
		lda #$32
		sta $01

		jsr update_ub
		inc scroll_cnt_ub

; Call updater code for the lower border scroll
		jsr update_lb
		jsr update_lb

		lda #$35
		sta $01

; Let the runtime code know it's time to execute
		lda #$01
		sta sync

; Set up for the next raster split
		lda #$03
		sta rn
		lda #rstr3p
		sta $d012

		jmp ea31


; Runtime loop to handle the background scroller
main_loop	lda #$00
		sta sync
sw_loop		cmp sync
		beq sw_loop

; Update the background scroller
		jsr scroll_manage

		lda bg_scroll_x
		clc
		adc #$01
		and #$0f
		sta bg_scroll_x

		tax
		lda d018_decode,x
		sta d018_mirror

		lda bg_scroll_x
		and #$07
		eor #$07
		sta d016_mirror

; Check to see if the map needs to wrap around
		lda bg_scroll_x
		and #$07
		bne map_end_chk_skp

		dec map_width
		bne map_end_chk_skp

; Reset the map
		jsr scroll_init

; Check to see if space has been pressed
map_end_chk_skp	lda $dc01
		cmp #$ef
		beq *+$05
		jmp main_loop

; Time to quit - reset some registers
		sei

		lda #$00
		sta $d011
		sta $d020
		sta $d021
		sta $d418

; Reset the C64 (a linker would go here...)
		lda #$37
		sta $01

		jmp $fce2

; Raster split 3
		* = ((*/$100)+$01)*$100

rout3		ldx #$0c
		dex
		bne *-$01
		nop
		nop
		nop
		lda $d012
		cmp rstr3p+$02
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr3p+$03
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr3p+$04
		bne *+$02
;		sta $d020

		ldx #$02
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr3p+$05
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr3p+$06
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr3p+$07
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		bit $ea
		lda $d012
		cmp #rstr3p+$08
		bne *+$02
;		sta $d020

		lda #$ff
		sta $3fff

; Move the sprites for the lower scroller (unrolled for speed)
		lda sprite_pos_lb+$00
		sta $d000
		lda sprite_pos_lb+$02
		sta $d002
		lda sprite_pos_lb+$04
		sta $d004
		lda sprite_pos_lb+$06
		sta $d006
		lda sprite_pos_lb+$08
		sta $d008
		lda sprite_pos_lb+$0a
		sta $d00a
		lda sprite_pos_lb+$0c
		sta $d00c
		lda sprite_pos_lb+$0e
		sta $d00e

		lda sprite_pos_lb+$10
		sta $d010

		lda sprite_pos_lb+$01
		sta $d001
		sta $d003
		sta $d005
		sta $d007
		sta $d009
		sta $d00b
		sta $d00d
		sta $d00f

		nop
		nop
		nop

		lda #$ff
		sta $3fff
		lda #$53
		sta $d011

; Getting ready for the lower border splitter
!set spr_cnt=$00
!do {
		lda sprite_dp_lb+spr_cnt
		sta buffer_1+$3f8+spr_cnt

		!set spr_cnt=spr_cnt+$01
}until spr_cnt=$08

		lda #$12
		sta $d018

		bit $ea
		nop
		nop
		nop

		lda #$13
		ldx #$00
		ldy #$07
		sta $d011
		stx $d021
		sty $d016

		ldx #$04
		dex
		bne *-$01
		lda #lb_scroll_col_00
		sta $d021

; Lower border splitter
ghost_lb_00a	ldx cos_logo_zp+$00
		ldy #$00
		stx $3fff
		sty $3fff
		lda #$ff
		sta $3fff

		lda #lb_scroll_col_01
		sta $d021
		lda #$00
		sta $3fff

		bit $ea
		nop
		nop

ghost_lb_00b	lda #$55
ghost_lb_01a	ldx cos_logo_zp+$01
		ldy #$00
		sta $3fff
		stx $3fff
		sty $3fff
		lda #$ff
		sta $3fff

		lda #lb_scroll_col_02
		sta $d021
		lda #$00
		sta $3fff

		bit $ea
		nop
		nop

ghost_lb_01b	lda #$55
ghost_lb_02a	ldx cos_logo_zp+$02
		ldy #$00
		sta $3fff
		stx $3fff
		sty $3fff
		lda #$ff
		sta $3fff

		lda #lb_scroll_col_03
		sta $d021
		lda #$00
		sta $3fff

		bit $ea
		nop
		nop

ghost_lb_02b	lda #$55
ghost_lb_03a	ldx cos_logo_zp+$03
		ldy #$00
		sta $3fff
		stx $3fff
		sty $3fff
		lda #$ff
		sta $3fff

		lda #lb_scroll_col_04
		sta $d021
		lda #$00
		sta $3fff

		bit $ea
		nop
		nop

ghost_lb_03b	lda #$55
ghost_lb_04a	ldx cos_logo_zp+$04
		ldy #$00
		sta $3fff
		stx $3fff
		sty $3fff
		lda #$ff
		sta $3fff

		lda #lb_scroll_col_05
		sta $d021
		lda #$00
		sta $3fff

		bit $ea
		nop
		nop

ghost_lb_04b	lda #$55
ghost_lb_05a	ldx cos_logo_zp+$05
		ldy #$00
		sta $3fff
		stx $3fff
		sty $3fff
		lda #$ff
		sta $3fff

		lda #lb_scroll_col_06
		sta $d021
		lda #$00
		sta $3fff

		bit $ea
		nop
		nop

ghost_lb_05b	lda #$55
ghost_lb_06a	ldx cos_logo_zp+$06
		ldy #$00
		sta $3fff
		stx $3fff
		sty $3fff
		lda #$ff
		sta $3fff

		lda #lb_scroll_col_07
		sta $d021
		lda #$00
		sta $3fff

		bit $ea
		nop
		nop

ghost_lb_06b	lda #$55
ghost_lb_07a	ldx cos_logo_zp+$07
		ldy #$00
		sta $3fff
		stx $3fff
		sty $3fff
		lda #$ff
		sta $3fff

		lda #lb_scroll_col_08
		sta $d021
		lda #$00
		sta $3fff

		bit $ea
		nop
		nop
		nop

ghost_lb_07b	lda #$55
ghost_lb_08a	ldx #$ff

		sta $3fff
		stx $3fff

		lda #border_col
		sta $d021

		ldx #$06
		dex
		bne *-$01
		nop

		lda #$00
		sta $3fff

; Roll back the scroller's parallax character
		inc parallax_tmr
		lda parallax_tmr
		and #$01
		bne parallax_skip

		ldx #$00
parallax_upd	lda char_data+$0f8,x
		lsr
		bcc *+$04
		ora #$80
		sta char_data+$0f8,x
		inx
		cpx #$08
		bne parallax_upd

parallax_skip

; Play the music
		jsr music+$03

; Set up for the first raster split
		lda #$01
		sta rn
		lda #rstr1p
		sta $d012

; Exit IRQ interrupt
ea31		pla
		tay
		pla
		tax
		pla
nmi		rti


; Upper and lower border update code
		!src "includes/update_ub.asm"
		!src "includes/update_lb.asm"

; Main background scroller
		!src "includes/scroller.asm"

; Drag in the RLE packer's source
		!src "includes/rle_depack.asm"


; RLE compressed map data for the background scroller
map_data	!binary "data/background.rle"

; Text for the upper border text area (19 bytes per block)
scroll_text_ub	!scr "** LEVEL ONE +4M **"

		!scr "Cracked and Trained"
		!scr ">  on 2019/01/05  <"

		!scr "                   "

		!scr "Intro Programming &"
		!scr "Graphics by   T.M.R"

		!scr "Soundtrack by  aNdy"

		!scr "                   "

		!scr "Visit Cosine online"

		!scr "** Cosine.org.uk **"

		!scr "                   "

		!byte $00

; Text for the lower border scroller
scroll_text_lb	!scr "Cosine greet:  "

		!scr "Absence, "
		!scr "Abyss Connection, "
		!scr "Arkanix Labs, "
		!scr "Artstate, "
		!scr "Ate Bit, "
		!scr "Atlantis, "

		!scr "Booze Design, "

		!scr "Camelot, "
		!scr "Censor Design, "
		!scr "Chorus, "
		!scr "Chrome, "
		!scr "CNCD, "
		!scr "CPU, "
		!scr "Crescent, "
		!scr "Crest, "
		!scr "Covert Bitops, "

		!scr "Defence Force, "
		!scr "Dekadence, "
		!scr "Desire, "
		!scr "DAC, "
		!scr "DMAgic, "
		!scr "Dual Crew, "

		!scr "Exclusive On, "

		!scr "Fairlight, "
		!scr "F4CG, "
		!scr "FIRE, "
		!scr "Flat 3, "
		!scr "Focus, "
		!scr "French Touch, "
		!scr "Funkscientist Productions, "

		!scr "Genesis Project, "
		!scr "Gheymaid Inc, "

		!scr "Hitmen, "
		!scr "Hoaxers, "
		!scr "Hokuto Force, "

		!scr "Legion Of Doom, "
		!scr "Level 64, "

		!scr "Maniacs Of Noise, "
		!scr "Mayday, "
		!scr "Meanteam, "
		!scr "Metalvotze, "

		!scr "Noname, "
		!scr "Nostalgia, "
		!scr "Nuance, "

		!scr "Offence, "
		!scr "Onslaught, "
		!scr "Orb, "
		!scr "Oxyron, "

		!scr "Padua, "
		!scr "Performers, "
		!scr "Plush, "
		!scr "PPCS, "
		!scr "Psytronik, "

		!scr "Reptilia, "
		!scr "Resource, "
		!scr "RGCD, "

		!scr "Secure, "
		!scr "SHAPE, "
		!scr "Side B, "
		!scr "Singular, "
		!scr "Slash, "
		!scr "Slipstream, "
		!scr "Success And TRC, "
		!scr "Style, "
		!scr "Suicyco Industries, "

		!scr "Taquart, "
		!scr "Tempest, "
		!scr "TEK, "
		!scr "Triad, "
		!scr "Tristar And Red Sector, "

		!scr "Viruz, "
		!scr "Vision, "

		!scr "WOW, "
		!scr "Wrath Designs, "

		!scr "Xenon, "
		!scr "Xentax"

		!scr "          "

		!byte $00	; end of text marker
