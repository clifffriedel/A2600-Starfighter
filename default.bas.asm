 processor 6502
 include "vcs.h"
 include "macro.h"
 include "2600basic.h"
 include "2600basic_variable_redefs.h"
 ifconst bankswitch
  if bankswitch == 8
     ORG $1000
     RORG $D000
  endif
  if bankswitch == 16
     ORG $1000
     RORG $9000
  endif
  if bankswitch == 32
     ORG $1000
     RORG $1000
  endif
 else
   ORG $F000
 endif
; This is a 2-line kernel!
kernel
 sta WSYNC
 lda #255
 sta TIM64T

 lda #1
 sta VDELBL
 sta VDELP0
 ldx ballheight
 inx
 inx
 stx temp4
 lda player1y
 sta temp3

 ifconst shakescreen
   jsr doshakescreen
 else
   ldx missile0height
   inx
 endif

 inx
 stx stack1

 lda bally
 sta stack2

 lda player0y
 ldx #0
 sta WSYNC
 stx GRP0
 stx GRP1
 stx PF1
 stx PF2
 stx CXCLR
 ifconst readpaddle
   stx paddle
 else
   sleep 3
 endif

 sta temp2,x

 ;store these so they can be retrieved later
 ifnconst pfres
   ldx #128-44
 else
   ldx #132-pfres*4
 endif

 inc player1y

 lda missile0y
 sta temp5
 lda missile1y
 sta temp6

 lda playfieldpos
 sta temp1
 
 ifconst pfrowheight
 lda #pfrowheight+2
 else
 ifnconst pfres
   lda #10
 else
   lda #(96/pfres)+2 ; try to come close to the real size
 endif
 endif

 clc
 sbc playfieldpos
 sta playfieldpos
 jmp .startkernel

.skipDrawP0
 lda #0
 tay
 jmp .continueP0

.skipDrawP1
 lda #0
 tay
 jmp .continueP1

.kerloop ; enter at cycle 59??

continuekernel
 sleep 2
continuekernel2
 lda ballheight
 
 ifconst pfres
 ldy playfield+pfres*4-132,x
 sty PF1 ;3
 ldy playfield+pfres*4-131,x
 sty PF2 ;3
 ldy playfield+pfres*4-129,x
 sty PF1 ; 3 too early?
 ldy playfield+pfres*4-130,x
 sty PF2 ;3
 else
 ldy playfield+44-128,x ;4
 sty PF1 ;3
 ldy playfield+45-128,x ;4
 sty PF2 ;3
 ldy playfield+47-128,x ;4
 sty PF1 ; 3 too early?
 ldy playfield+46-128,x;4
 sty PF2 ;3
 endif

 dcp bally
 rol
 rol
; rol
; rol
goback
 sta ENABL 
.startkernel
 lda player1height ;3
 dcp player1y ;5
 bcc .skipDrawP1 ;2
 ldy player1y ;3
 lda (player1pointer),y ;5; player0pointer must be selected carefully by the compiler
			; so it doesn't cross a page boundary!

.continueP1
 sta GRP1 ;3

 ifnconst player1colors
   lda missile1height ;3
   dcp missile1y ;5
   rol;2
   rol;2
   sta ENAM1 ;3
 else
   lda (player1color),y
   sta COLUP1
 ifnconst playercolors
   sleep 7
 else
   lda.w player0colorstore
   sta COLUP0
 endif
 endif

 ifconst pfres
 lda playfield+pfres*4-132,x 
 sta PF1 ;3
 lda playfield+pfres*4-131,x 
 sta PF2 ;3
 lda playfield+pfres*4-129,x 
 sta PF1 ; 3 too early?
 lda playfield+pfres*4-130,x 
 sta PF2 ;3
 else
 lda playfield+44-128,x ;4
 sta PF1 ;3
 lda playfield+45-128,x ;4
 sta PF2 ;3
 lda playfield+47-128,x ;4
 sta PF1 ; 3 too early?
 lda playfield+46-128,x;4
 sta PF2 ;3
 endif 
; sleep 3

 lda player0height
 dcp player0y
 bcc .skipDrawP0
 ldy player0y
 lda (player0pointer),y
.continueP0
 sta GRP0

 ifnconst no_blank_lines
 ifnconst playercolors
   lda missile0height ;3
   dcp missile0y ;5
   sbc stack1
   sta ENAM0 ;3
 else
   lda (player0color),y
   sta player0colorstore
   sleep 6
 endif
   dec temp1
   bne continuekernel
 else
   dec temp1
   beq altkernel2
 ifconst readpaddle
   ldy currentpaddle
   lda INPT0,y
   bpl noreadpaddle
   inc paddle
   jmp continuekernel2
noreadpaddle
   sleep 2
   jmp continuekernel
 else
 ifnconst playercolors 
 ifconst PFcolors
   txa
   tay
   lda (pfcolortable),y
 ifnconst backgroundchange
   sta COLUPF
 else
   sta COLUBK
 endif
   jmp continuekernel
 else
   sleep 12
 endif
 else
   lda (player0color),y
   sta player0colorstore
   sleep 4
 endif
   jmp continuekernel
 endif
altkernel2
   txa
   sbx #252
   bmi lastkernelline
 ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
   jmp continuekernel
 endif

altkernel

 ifconst PFmaskvalue
   lda #PFmaskvalue
 else
   lda #0
 endif
 sta PF1
 sta PF2


 ;sleep 3

 ;28 cycles to fix things
 ;minus 11=17

; lax temp4
; clc
 txa
 sbx #252

 bmi lastkernelline

 ifconst PFcolorandheight
   ldy playfieldcolorandheight-87,x
 ifnconst backgroundchange
   sty COLUPF
 else
   sty COLUBK
 endif
   lda playfieldcolorandheight-88,x
   sta.w temp1
 endif
 ifconst PFheights
   lsr
   lsr
   tay
   lda (pfheighttable),y
   sta.w temp1
 endif
 ifconst PFcolors
   tay
   lda (pfcolortable),y
 ifnconst backgroundchange
   sta COLUPF
 else
   sta COLUBK
 endif
 ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
 endif
 ifnconst PFcolorandheight
 ifnconst PFcolors
 ifnconst PFheights
 ifnconst no_blank_lines
 ; read paddle 0
 ; lo-res paddle read
  ; bit INPT0
  ; bmi paddleskipread
  ; inc paddle0
;donepaddleskip
   sleep 10
 ifconst pfrowheight
   lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
 endif
 endif
 endif
 endif
 

 lda ballheight
 dcp bally
 sbc temp4


 jmp goback


 ifnconst no_blank_lines
lastkernelline
 ifnconst PFcolors
   sleep 10
 else
   ldy #124
   lda (pfcolortable),y
   sta COLUPF
 endif

 ifconst PFheights
 ldx #1
 sleep 4
 else
 ldx playfieldpos
 sleep 3
 endif

 jmp enterlastkernel

 else
lastkernelline
 
 ifconst PFheights
 ldx #1
 sleep 5
 else
   ldx playfieldpos
 sleep 4
 endif

   cpx #1
   bne .enterfromNBL
   jmp no_blank_lines_bailout
 endif

 if ((<*)>$d5)
 align 256
 endif
 ; this is a kludge to prevent page wrapping - fix!!!

.skipDrawlastP1
 sleep 2
 lda #0
 jmp .continuelastP1

.endkerloop ; enter at cycle 59??
 
 nop

.enterfromNBL
 ifconst pfres
 ldy.w playfield+pfres*4-4
 sty PF1 ;3
 ldy.w playfield+pfres*4-3
 sty PF2 ;3
 ldy.w playfield+pfres*4-1
 sty PF1 ; possibly too early?
 ldy.w playfield+pfres*4-2
 sty PF2 ;3
 else
 ldy.w playfield+44
 sty PF1 ;3
 ldy.w playfield+45
 sty PF2 ;3
 ldy.w playfield+47
 sty PF1 ; possibly too early?
 ldy.w playfield+46
 sty PF2 ;3
 endif

enterlastkernel
 lda ballheight

; tya
 dcp bally
; sleep 4

; sbc stack3
 rol
 rol
 sta ENABL 

 lda player1height ;3
 dcp player1y ;5
 bcc .skipDrawlastP1
 ldy player1y ;3
 lda (player1pointer),y ;5; player0pointer must be selected carefully by the compiler
			; so it doesn't cross a page boundary!

.continuelastP1
 sta GRP1 ;3

 ifnconst player1colors
   lda missile1height ;3
   dcp missile1y ;5
 else
   lda (player1color),y
   sta COLUP1
 endif

 dex
 ;dec temp4 ; might try putting this above PF writes
 beq endkernel


 ifconst pfres
 ldy.w playfield+pfres*4-4
 sty PF1 ;3
 ldy.w playfield+pfres*4-3
 sty PF2 ;3
 ldy.w playfield+pfres*4-1
 sty PF1 ; possibly too early?
 ldy.w playfield+pfres*4-2
 sty PF2 ;3
 else
 ldy.w playfield+44
 sty PF1 ;3
 ldy.w playfield+45
 sty PF2 ;3
 ldy.w playfield+47
 sty PF1 ; possibly too early?
 ldy.w playfield+46
 sty PF2 ;3
 endif

 ifnconst player1colors
   rol;2
   rol;2
   sta ENAM1 ;3
 else
 ifnconst playercolors
   sleep 7
 else
   lda.w player0colorstore
   sta COLUP0
 endif
 endif
 
 lda.w player0height
 dcp player0y
 bcc .skipDrawlastP0
 ldy player0y
 lda (player0pointer),y
.continuelastP0
 sta GRP0



 ifnconst no_blank_lines
   lda missile0height ;3
   dcp missile0y ;5
   sbc stack1
   sta ENAM0 ;3
   jmp .endkerloop
 else
 ifconst readpaddle
   ldy currentpaddle
   lda INPT0,y
   bpl noreadpaddle2
   inc paddle
   jmp .endkerloop
noreadpaddle2
   sleep 4
   jmp .endkerloop
 else ; no_blank_lines and no paddle reading
 sleep 14
 jmp .endkerloop
 endif
 endif


;  ifconst donepaddleskip
;paddleskipread
 ; this is kind of lame, since it requires 4 cycles from a page boundary crossing
 ; plus we get a lo-res paddle read
; bmi donepaddleskip
;  endif

.skipDrawlastP0
 sleep 2
 lda #0
 jmp .continuelastP0

 ifconst no_blank_lines
no_blank_lines_bailout
 ldx #0
 endif

endkernel
 ; 6 digit score routine
 stx PF1
 stx PF2
 stx PF0
 clc

 ifconst pfrowheight
 lda #pfrowheight+2
 else
 ifnconst pfres
   lda #10
 else
   lda #(96/pfres)+2 ; try to come close to the real size
 endif
 endif

 sbc playfieldpos
 sta playfieldpos
 txa

 ifconst shakescreen
   bit shakescreen
   bmi noshakescreen2
   ldx #$3D
noshakescreen2
 endif

   sta WSYNC,x

;                STA WSYNC ;first one, need one more
 sta REFP0
 sta REFP1
                STA GRP0
                STA GRP1
 ;               STA PF1
   ;             STA PF2
 sta HMCLR
 sta ENAM0
 sta ENAM1
 sta ENABL

 lda temp2 ;restore variables that were obliterated by kernel
 sta player0y
 lda temp3
 sta player1y
 ifnconst player1colors
   lda temp6
   sta missile1y
 endif
 ifnconst playercolors
 ifnconst readpaddle
   lda temp5
   sta missile0y
 endif
 endif
 lda stack2
 sta bally

 ifconst no_blank_lines
 sta WSYNC
 endif

 lda INTIM
 clc
 ifnconst vblank_time
 adc #43+12+87
 else
 adc #vblank_time+12+87
 endif
; sta WSYNC
 sta TIM64T

 ifconst minikernel
 jsr minikernel
 endif

 ; now reassign temp vars for score pointers

; score pointers contain:
; score1-5: lo1,lo2,lo3,lo4,lo5,lo6
; swap lo2->temp1
; swap lo4->temp3
; swap lo6->temp5
 ifnconst noscore
 lda scorepointers+1
; ldy temp1
 sta temp1
; sty scorepointers+1

 lda scorepointers+3
; ldy temp3
 sta temp3
; sty scorepointers+3


 sta HMCLR
 tsx
 stx stack1 
 ldx #$10
 stx HMP0

 sta WSYNC
 ldx #0
                STx GRP0
                STx GRP1 ; seems to be needed because of vdel

 lda scorepointers+5
; ldy temp5
 sta temp5,x
; sty scorepointers+5
 lda #>scoretable
 sta scorepointers+1
 sta scorepointers+3
 sta scorepointers+5,x
 sta temp2,x
 sta temp4,x
 sta temp6,x
                LDY #7
                STA RESP0
                STA RESP1


        LDA #$03
        STA NUSIZ0
        STA NUSIZ1,x
        STA VDELP0
        STA VDELP1
        LDA #$20
        STA HMP1
               LDA scorecolor 
;               STA HMCLR
;               STA WSYNC; second one
                STA HMOVE ; cycle 73 ?

                STA COLUP0
                STA COLUP1
 lda  (scorepointers),y
 sta  GRP0
 ifconst pfscore
 lda pfscorecolor
 sta COLUPF
 endif
 lda  (scorepointers+8),y
 sta WSYNC
 sleep 2
 jmp beginscore

 if ((<*)>$d4)
 align 256 ; kludge that potentially wastes space!  should be fixed!
 endif

loop2
 lda  (scorepointers),y     ;+5  68  204
 sta  GRP0            ;+3  71  213      D1     --      --     --
 ifconst pfscore
 lda.w pfscore1
 sta PF1
 else
 sleep 7
 endif
 ; cycle 0
 lda  (scorepointers+$8),y  ;+5   5   15
beginscore
 sta  GRP1            ;+3   8   24      D1     D1      D2     --
 lda  (scorepointers+$6),y  ;+5  13   39
 sta  GRP0            ;+3  16   48      D3     D1      D2     D2
 lax  (scorepointers+$2),y  ;+5  29   87
 txs
 lax  (scorepointers+$4),y  ;+5  36  108
 sleep 3

 ifconst pfscore
 lda pfscore2
 sta PF1
 else
 sleep 6
 endif

 lda  (scorepointers+$A),y  ;+5  21   63
 stx  GRP1            ;+3  44  132      D3     D3      D4     D2!
 tsx
 stx  GRP0            ;+3  47  141      D5     D3!     D4     D4
 sta  GRP1            ;+3  50  150      D5     D5      D6     D4!
 sty  GRP0            ;+3  53  159      D4*    D5!     D6     D6
 dey
 bpl  loop2           ;+2  60  180

 ldx stack1 
 txs
; lda scorepointers+1
 ldy temp1
; sta temp1
 sty scorepointers+1

                LDA #0   
 sta PF1
               STA GRP0
                STA GRP1
        STA VDELP0
        STA VDELP1;do we need these
        STA NUSIZ0
        STA NUSIZ1

; lda scorepointers+3
 ldy temp3
; sta temp3
 sty scorepointers+3

; lda scorepointers+5
 ldy temp5
; sta temp5
 sty scorepointers+5
 endif ;noscore
 LDA #%11000010
 sta WSYNC
 STA VBLANK
 RETURN

 ifconst shakescreen
doshakescreen
   bit shakescreen
   bmi noshakescreen
   sta WSYNC
noshakescreen
   ldx missile0height
   inx
   rts
 endif

start
 sei
 cld
 ldy #0
 lda $D0
 cmp #$2C               ;check RAM location #1
 bne MachineIs2600
 lda $D1
 cmp #$A9               ;check RAM location #2
 bne MachineIs2600
 dey
MachineIs2600
 ldx #0
 txa
clearmem
 inx
 txs
 pha
 bne clearmem
 sty temp1
 ifconst pfrowheight
 lda pfrowheight
 else
 ifconst pfres
 lda #(96/pfres)
 else
 lda #8
 endif
 endif
 sta playfieldpos
 ldx #5
initscore
 lda #<scoretable
 sta scorepointers,x 
 dex
 bpl initscore
 lda #1
 sta CTRLPF
 ora INTIM
 sta rand

 ifconst multisprite
   jsr multisprite_setup
 endif

 ifnconst bankswitch
   jmp game
 else
   lda #>(game-1)
   pha
   lda #<(game-1)
   pha
   pha
   pha
   ldx #1
   jmp BS_jsr
 endif
; playfield drawing routines
; you get a 32x12 bitmapped display in a single color :)
; 0-31 and 0-11

pfclear ; clears playfield - or fill with pattern
 ifconst pfres
 ldx #pfres*4-1
 else
 ldx #47
 endif
pfclear_loop
 ifnconst superchip
 sta playfield,x
 else
 sta playfield-128,x
 endif
 dex
 bpl pfclear_loop
 RETURN
 
setuppointers
 stx temp2 ; store on.off.flip value
 tax ; put x-value in x 
 lsr
 lsr
 lsr ; divide x pos by 8 
 sta temp1
 tya
 asl
 asl ; multiply y pos by 4
 clc
 adc temp1 ; add them together to get actual memory location offset
 tay ; put the value in y
 lda temp2 ; restore on.off.flip value
 rts

pfread
;x=xvalue, y=yvalue
 jsr setuppointers
 lda setbyte,x
 and playfield,y
 eor setbyte,x
; beq readzero
; lda #1
; readzero
 RETURN

pfpixel
;x=xvalue, y=yvalue, a=0,1,2
 jsr setuppointers

 ifconst bankswitch
 lda temp2 ; load on.off.flip value (0,1, or 2)
 beq pixelon_r  ; if "on" go to on
 lsr
 bcs pixeloff_r ; value is 1 if true
 lda playfield,y ; if here, it's "flip"
 eor setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN
pixelon_r
 lda playfield,y
 ora setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN
pixeloff_r
 lda setbyte,x
 eor #$ff
 and playfield,y
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN

 else
 jmp plotpoint
 endif

pfhline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 jmp noinc
keepgoing
 inx
 txa
 and #7
 bne noinc
 iny
noinc
 jsr plotpoint
 cpx temp3
 bmi keepgoing
 RETURN

pfvline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 sty temp1 ; store memory location offset
 inc temp3 ; increase final x by 1 
 lda temp3
 asl
 asl ; multiply by 4
 sta temp3 ; store it
 ; Thanks to Michael Rideout for fixing a bug in this code
 ; right now, temp1=y=starting memory location, temp3=final
 ; x should equal original x value
keepgoingy
 jsr plotpoint
 iny
 iny
 iny
 iny
 cpy temp3
 bmi keepgoingy
 RETURN

plotpoint
 lda temp2 ; load on.off.flip value (0,1, or 2)
 beq pixelon  ; if "on" go to on
 lsr
 bcs pixeloff ; value is 1 if true
 lda playfield,y ; if here, it's "flip"
 eor setbyte,x
  ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts
pixelon
 lda playfield,y
 ora setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts
pixeloff
 lda setbyte,x
 eor #$ff
 and playfield,y
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts

setbyte
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
pfscroll ;(a=0 left, 1 right, 2 up, 4 down, 6=upup, 12=downdown)
 bne notleft
;left
 ifconst pfres
 ldx #pfres*4
 else
 ldx #48
 endif
leftloop
 lda playfield-1,x
 lsr

 ifconst superchip
 lda playfield-2,x
 rol
 sta playfield-130,x
 lda playfield-3,x
 ror
 sta playfield-131,x
 lda playfield-4,x
 rol
 sta playfield-132,x
 lda playfield-1,x
 ror
 sta playfield-129,x
 else
 rol playfield-2,x
 ror playfield-3,x
 rol playfield-4,x
 ror playfield-1,x
 endif

 txa
 sbx #4
 bne leftloop
 RETURN

notleft
 lsr
 bcc notright
;right

 ifconst pfres
 ldx #pfres*4
 else
 ldx #48
 endif
rightloop
 lda playfield-4,x
 lsr
 ifconst superchip
 lda playfield-3,x
 rol
 sta playfield-131,x
 lda playfield-2,x
 ror
 sta playfield-130,x
 lda playfield-1,x
 rol
 sta playfield-129,x
 lda playfield-4,x
 ror
 sta playfield-132,x
 else
 rol playfield-3,x
 ror playfield-2,x
 rol playfield-1,x
 ror playfield-4,x
 endif
 txa
 sbx #4
 bne rightloop
  RETURN

notright
 lsr
 bcc notup
;up
 lsr
 bcc onedecup
 dec playfieldpos
onedecup
 dec playfieldpos
 beq shiftdown 
 bpl noshiftdown2 
shiftdown
  ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif

 sta playfieldpos
 lda playfield+3
 sta temp4
 lda playfield+2
 sta temp3
 lda playfield+1
 sta temp2
 lda playfield
 sta temp1
 ldx #0
up2
 lda playfield+4,x
 ifconst superchip
 sta playfield-128,x
 lda playfield+5,x
 sta playfield-127,x
 lda playfield+6,x
 sta playfield-126,x
 lda playfield+7,x
 sta playfield-125,x
 else
 sta playfield,x
 lda playfield+5,x
 sta playfield+1,x
 lda playfield+6,x
 sta playfield+2,x
 lda playfield+7,x
 sta playfield+3,x
 endif
 txa
 sbx #252
 ifconst pfres
 cpx #(pfres-1)*4
 else
 cpx #44
 endif
 bne up2

 lda temp4
 
 ifconst superchip
 ifconst pfres
 sta playfield+pfres*4-129
 lda temp3
 sta playfield+pfres*4-130
 lda temp2
 sta playfield+pfres*4-131
 lda temp1
 sta playfield+pfres*4-132
 else
 sta playfield+47-128
 lda temp3
 sta playfield+46-128
 lda temp2
 sta playfield+45-128
 lda temp1
 sta playfield+44-128
 endif
 else
 ifconst pfres
 sta playfield+pfres*4-1
 lda temp3
 sta playfield+pfres*4-2
 lda temp2
 sta playfield+pfres*4-3
 lda temp1
 sta playfield+pfres*4-4
 else
 sta playfield+47
 lda temp3
 sta playfield+46
 lda temp2
 sta playfield+45
 lda temp1
 sta playfield+44
 endif
 endif
noshiftdown2
 RETURN


notup
;down
 lsr
 bcs oneincup
 inc playfieldpos
oneincup
 inc playfieldpos
 lda playfieldpos

  ifconst pfrowheight
 cmp #pfrowheight+1
 else
 ifnconst pfres
   cmp #9
 else
   cmp #(96/pfres)+1 ; try to come close to the real size
 endif
 endif

 bcc noshiftdown 
 lda #1
 sta playfieldpos

 ifconst pfres
 lda playfield+pfres*4-1
 sta temp4
 lda playfield+pfres*4-2
 sta temp3
 lda playfield+pfres*4-3
 sta temp2
 lda playfield+pfres*4-4
 else
 lda playfield+47
 sta temp4
 lda playfield+46
 sta temp3
 lda playfield+45
 sta temp2
 lda playfield+44
 endif

 sta temp1

 ifconst pfres
 ldx #(pfres-1)*4
 else
 ldx #44
 endif
down2
 lda playfield-1,x
 ifconst superchip
 sta playfield-125,x
 lda playfield-2,x
 sta playfield-126,x
 lda playfield-3,x
 sta playfield-127,x
 lda playfield-4,x
 sta playfield-128,x
 else
 sta playfield+3,x
 lda playfield-2,x
 sta playfield+2,x
 lda playfield-3,x
 sta playfield+1,x
 lda playfield-4,x
 sta playfield,x
 endif
 txa
 sbx #4
 bne down2

 lda temp4
 ifconst superchip
 sta playfield-125
 lda temp3
 sta playfield-126
 lda temp2
 sta playfield-127
 lda temp1
 sta playfield-128
 else
 sta playfield+3
 lda temp3
 sta playfield+2
 lda temp2
 sta playfield+1
 lda temp1
 sta playfield
 endif
noshiftdown
 RETURN
;standard routines needed for pretty much all games
; just the random number generator is left - maybe we should remove this asm file altogether?
; repositioning code and score pointer setup moved to overscan
; read switches, joysticks now compiler generated (more efficient)

randomize
	lda rand
	lsr
 ifconst rand16
	rol rand16
 endif
	bcc noeor
	eor #$B4
noeor
	sta rand
 ifconst rand16
	eor rand16
 endif
	RETURN
drawscreen
 ifconst debugscore
   ldx #14
   lda INTIM ; display # cycles left in the score

 ifconst mincycles
 lda mincycles 
 cmp INTIM
 lda mincycles
 bcc nochange
 lda INTIM
 sta mincycles
nochange
 endif

;   cmp #$2B
;   bcs no_cycles_left
   bmi cycles_left
   ldx #64
   eor #$ff ;make negative
cycles_left
   stx scorecolor
   and #$7f ; clear sign bit
   tax
   lda scorebcd,x
   sta score+2
   lda scorebcd1,x
   sta score+1
   jmp done_debugscore   
scorebcd
 .byte $00, $64, $28, $92, $56, $20, $84, $48, $12, $76, $40
 .byte $04, $68, $32, $96, $60, $24, $88, $52, $16, $80, $44
 .byte $08, $72, $36, $00, $64, $28, $92, $56, $20, $84, $48
 .byte $12, $76, $40, $04, $68, $32, $96, $60, $24, $88
scorebcd1
 .byte 0, 0, 1, 1, 2, 3, 3, 4, 5, 5, 6
 .byte 7, 7, 8, 8, 9, $10, $10, $11, $12, $12, $13
 .byte $14, $14, $15, $16, $16, $17, $17, $18, $19, $19, $20
 .byte $21, $21, $22, $23, $23, $24, $24, $25, $26, $26
done_debugscore
 endif

 ifconst debugcycles
   lda INTIM ; if we go over, it mucks up the background color
;   cmp #$2B
;   BCC overscan
   bmi overscan
   sta COLUBK
   bcs doneoverscan
 endif

 
overscan
 lda INTIM ;wait for sync
 bmi overscan
doneoverscan
;do VSYNC
 lda #2
 sta WSYNC
 sta VSYNC
 STA WSYNC
 STA WSYNC
 LDA #0
 STA WSYNC
 STA VSYNC
 sta VBLANK
 ifnconst overscan_time
 lda #37+128
 else
 lda #overscan_time+128
 endif
 sta TIM64T

 ifconst legacy
 if legacy < 100
 ldx #4
adjustloop
 lda player0x,x
 sec
 sbc #14 ;?
 sta player0x,x
 dex
 bpl adjustloop
 endif
 endif
 if (<*)>$F0
 align 256, $EA
 endif
  sta WSYNC
  ldx #4
  SLEEP 3
HorPosLoop       ;     5
  lda player0x,X  ;+4   9
  sec           ;+2  11
DivideLoop
  sbc #15
  bcs DivideLoop;+4  15
  sta temp1,X    ;+4  19
  sta RESP0,X   ;+4  23
  sta WSYNC
  dex
  bpl HorPosLoop;+5   5
                ;     4

  ldx #4
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 18

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 32

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 46

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 60

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 74

  sta WSYNC
 
  sta HMOVE     ;+3   3


 ifconst legacy
 if legacy < 100
 ldx #4
adjustloop2
 lda player0x,x
 clc
 adc #14 ;?
 sta player0x,x
 dex
 bpl adjustloop2
 endif
 endif




;set score pointers
 lax score+2
 jsr scorepointerset
 sty scorepointers+5
 stx scorepointers+2
 lax score+1
 jsr scorepointerset
 sty scorepointers+4
 stx scorepointers+1
 lax score
 jsr scorepointerset
 sty scorepointers+3
 stx scorepointers

vblk
; run possible vblank bB code
 ifconst vblank_bB_code
   jsr vblank_bB_code
 endif
vblk2
 LDA INTIM
 bmi vblk2
 jmp kernel
 

    .byte $80,$70,$60,$50,$40,$30,$20,$10,$00
    .byte $F0,$E0,$D0,$C0,$B0,$A0,$90
repostable

scorepointerset
 and #$0F
 asl
 asl
 asl
 adc #<scoretable
 tay 
 txa
; and #$F0
; lsr
 asr #$F0
 adc #<scoretable
 tax
 rts
minikernel ; display up to 6 lives on screen
 sta WSYNC
 sleep 10 ; can we optimize this?
 lda #0
 ldy #7
 sta VDELP0
 sta VDELP1
 ifnconst lives_compact
 ifnconst lives_centered
 sta RESP0
 endif
 lda.w lives
 ifnconst lives_centered
 sta RESP1
 endif
 lsr
 lsr
 lsr
 lsr
 ifconst lives_centered
 sta RESP0
 endif
 lsr
 tax
 ifconst lives_centered
 sta RESP1
 endif
 lda lifenusiz0table,x
 sta NUSIZ0
 lda lifenusiz1table,x
 sta NUSIZ1
 lda lifecolor
 sta COLUP0
 sta COLUP1
 lda #$b0
 sta HMP0

 else

 ifnconst lives_centered
 sta.w RESP0
 sta RESP1
 endif
 lda lives
 lsr
 lsr
 lsr
 lsr
 lsr
 tax
 lda lifenusiz0table,x
 ifconst lives_centered
 sta RESP0
 sta RESP1
 sta.w NUSIZ0
 else
 sta NUSIZ0
 endif
 lda lifenusiz1table,x
 sta NUSIZ1
 lda lifecolor
 sta COLUP0
 sta COLUP1
 lda #$10
 sta HMP1

 endif

 sta HMOVE ; cycle 73

lifeloop
 cpx #0
 beq skipall
 lda (lifepointer),y
 sta GRP0
 cpx #1
 beq skipall
 sta GRP1
skipall
 dey
 sta WSYNC
 bpl lifeloop
 iny
 sty GRP0
 sty GRP1
 rts

 if (<*) > $F5
 align 256
 endif
 ifconst lives_compact
lifenusiz1table
 .byte 0
lifenusiz0table
 .byte 0,0,0,1,1,3,3,3
 else
lifenusiz1table
 .byte 0
lifenusiz0table
 .byte 0,0,0,2,2,6,6,6
 endif
; y and a contain multiplicands, result in a

mul8
 sty temp1
 sta temp2
 lda #0
reptmul8
 lsr temp2
 bcc skipmul8
 clc
 adc temp1
;bcs donemul8 might save cycles?
skipmul8
;beq donemul8 might save cycles?
 asl temp1
 bne reptmul8
donemul8
 RETURN

div8
 ; a=numerator y=denominator, result in a
 cpy #2
 bcc div8end+1;div by 0 = bad, div by 1=no calc needed, so bail out
 sty temp1
 ldy #$ff
div8loop
 sbc temp1
 iny
 bcs div8loop
div8end
 tya
 ; result in a
 RETURN
game
.L00 ;  rem Generated 3/4/2010 2:36:53 PM by Visual bB Version 1.0.0.550

.L01 ;  rem **********************************

.L02 ;  rem *<filename>                      *

.L03 ;  rem *<description>                   *

.L04 ;  rem *<author>                        *

.L05 ;  rem *<contact info>                  *

.L06 ;  rem *<license>                       *

.L07 ;  rem **********************************

.
 ; 

.
 ; 

.L08 ;  rem minikernel hud initialization

.L09 ;  include 6lives.asm

.L010 ;  include div_mul.asm

.L011 ;  set smartbranching on

.
 ; 

.L012 ;  rem cut up the score variable so you can use it later to determine level

.L013 ;  dim sc1 = score

.L014 ;  dim sc2 = score + 1

.L015 ;  dim sc3 = score + 2

.
 ; 

.
 ; 

.L016 ;  rem player sprite

.L017 ;  player1:

	LDA #<playerL017_1

	STA player1pointerlo
	LDA #>playerL017_1

	STA player1pointerhi
	LDA #8
	STA player1height
.
 ; 

.L018 ;  rem initial variables setup

.L019 ;  player1x  =  80

	LDA #80
	STA player1x
.L020 ;  player1y  =  88

	LDA #88
	STA player1y
.L021 ;  lives  =  96

	LDA #96
	STA lives
.L022 ;  lifecolor  =  0

	LDA #0
	STA lifecolor
.L023 ;  score  =  0

	LDA #$00
	STA score+2
	LDA #$00
	STA score+1
	LDA #$00
	STA score
.L024 ;  rem variable l is for level

.L025 ;  l  =  1

	LDA #1
	STA l
.L026 ;  rem variable e is for enemy on the screen

.L027 ;  e  =  0

	LDA #0
	STA e
.L028 ;  rem variable f is for player fired

.L029 ;  f  =  0

	LDA #0
	STA f
.L030 ;  rem variable t is for tone multiplier

.L031 ;  t  =  0

	LDA #0
	STA t
.L032 ;  rem h is for horizontal movement

.L033 ;  h  =  1

	LDA #1
	STA h
.L034 ;  rem v is for vertical movement

.L035 ;  v  =  1

	LDA #1
	STA v
.L036 ;  rem w is for enemy fire

.L037 ;  w = 0

	LDA #0
	STA w
.L038 ;  rem z is for enemy tone

.L039 ;  z = 0

	LDA #0
	STA z
.L040 ;  rem y is to multiply level

.L041 ;  x = 0

	LDA #0
	STA x
.L042 ;  rem x is to assign rand

.L043 ;  b = 0

	LDA #0
	STA b
.L044 ;  rem b is a loop variable.  It can be reused

.L045 ;  s = 0

	LDA #0
	STA s
.L046 ;  rem s is the start screen flag.  if on, show the start screen

.L047 ;  z = 0

	LDA #0
	STA z
.L048 ;  rem z is a locking mechanism.  It can be reused.

.L049 ;  r = 0

	LDA #0
	STA r
.L050 ;  rem r is to reverse the boss.

.L051 ;  c = 0

	LDA #0
	STA c
.L052 ;  rem c is fireball flag.

.L053 ;  a = 0

	LDA #0
	STA a
.L054 ;  rem a is for boss hits.  

.main_loop
 ; main_loop

.
 ; 

.L055 ;  rem life icon

.L056 ;  lives:

	LDA #<lives__L056
	STA lifepointer
	LDA lifepointer+1
	AND #$E0
	ORA #(>lives__L056)&($1F)
	STA lifepointer+1
.
 ; 

.L057 ;  rem call subroutines and draw screen

.
 ; 

.L058 ;  if s  =  0 then gosub startscreen

	LDA s
	CMP #0
     BNE .skipL058
.condpart0
 jsr .startscreen

.skipL058
.L059 ;  COLUP1  =  14

	LDA #14
	STA COLUP1
.L060 ;  COLUBK  =  0

	LDA #0
	STA COLUBK
.L061 ;  lifecolor  =  6

	LDA #6
	STA lifecolor
.L062 ;  scorecolor  =  30

	LDA #30
	STA scorecolor
.L063 ;  gosub levelup

 jsr .levelup

.L064 ;  gosub pmove

 jsr .pmove

.L065 ;  gosub pfire

 jsr .pfire

.L066 ;  if e  =  0 then gosub enemystart

	LDA e
	CMP #0
     BNE .skipL066
.condpart1
 jsr .enemystart

.skipL066
.L067 ;  if e  =  1 then gosub enemymove

	LDA e
	CMP #1
     BNE .skipL067
.condpart2
 jsr .enemymove

.skipL067
.L068 ;  gosub coldet

 jsr .coldet

.L069 ;  drawscreen

 jsr drawscreen
.
 ; 

.L070 ;  if lives  >  31 goto main_loop

	LDA #31
	CMP lives
 if ((* - .main_loop) < 127) && ((* - .main_loop) > -128)
	bcc .main_loop
 else
	bcs .0skipmain_loop
	jmp .main_loop
.0skipmain_loop
 endif
.
 ; 

.L071 ;  rem endgame stuff goes in here

.L072 ;  player0x  =  0

	LDA #0
	STA player0x
.L073 ;  player0y  =  0

	LDA #0
	STA player0y
.L074 ;  player1x  =  0

	LDA #0
	STA player1x
.L075 ;  player1y  =  0

	LDA #0
	STA player1y
.L076 ;  missile1x  =  0

	LDA #0
	STA missile1x
.L077 ;  missile1y  =  0

	LDA #0
	STA missile1y
.
 ; 

.L078 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel0
PF_data0
	.byte %01111000, %00010001, %10111110, %00000000
	.byte %10000001, %10110010, %10100000, %00000000
	.byte %10111011, %01010111, %10111100, %00000000
	.byte %10001010, %00010100, %10100000, %00000000
	.byte %01110010, %00010100, %10111110, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000011, %10001001, %01111101, %00000111
	.byte %00000100, %10001010, %01000001, %00001000
	.byte %00000100, %10001010, %01111001, %00000111
	.byte %00000100, %01010010, %01000001, %00001000
	.byte %00000011, %00100001, %01111101, %00001000
pflabel0
	lda PF_data0,x
	sta playfield,x
	dex
	bpl pflabel0
.
 ; 

.L079 ;  COLUBK  =  64

	LDA #64
	STA COLUBK
.L080 ;  COLUPF  =  68

	LDA #68
	STA COLUPF
.L081 ;  gosub joywait

 jsr .joywait

.L082 ;  rem main game loop end

.
 ; 

.bosshit
 ; bosshit

.L083 ;  a  =  a  +  1

	INC a
.L084 ;  missile1x  =  0

	LDA #0
	STA missile1x
.L085 ;  missile1y  =  0

	LDA #0
	STA missile1y
.L086 ;  AUDV0 = 0

	LDA #0
	STA AUDV0
.L087 ;  f = 0

	LDA #0
	STA f
.L088 ;  t = 0

	LDA #0
	STA t
.L089 ;  COLUP0  =  64

	LDA #64
	STA COLUP0
.L090 ;  drawscreen

 jsr drawscreen
.L091 ;  COLUP0  =  8

	LDA #8
	STA COLUP0
.L092 ;  if a <> 5 then bossdied

	LDA a
	CMP #5
 if ((* - .bossdied) < 127) && ((* - .bossdied) > -128)
	BNE .bossdied
 else
	beq .1skipbossdied
	jmp .bossdied
.1skipbossdied
 endif
.L093 ;  score  =  score  +  5000

	SED
	CLC
	LDA score+2
	ADC #$00
	STA score+2
	LDA score+1
	ADC #$50
	STA score+1
	LDA score
	ADC #$00
	STA score
	CLD
.L094 ;  player0x  =  0

	LDA #0
	STA player0x
.L095 ;  player0y  =  0

	LDA #0
	STA player0y
.L096 ;  missile0x  =  0

	LDA #0
	STA missile0x
.L097 ;  missile0y  =  0

	LDA #0
	STA missile0y
.L098 ;  ballx  =  0

	LDA #0
	STA ballx
.L099 ;  bally  =  0

	LDA #0
	STA bally
.L0100 ;  e  =  0

	LDA #0
	STA e
.L0101 ;  w  =  0

	LDA #0
	STA w
.L0102 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.L0103 ;  c  =  0

	LDA #0
	STA c
.L0104 ;  a  =  0

	LDA #0
	STA a
.bossdied
 ; bossdied

.L0105 ;  return

	RTS
.
 ; 

.coldet
 ; coldet

.L0106 ;  if !collision(player0,missile1) then pmc1

	BIT CXM1P
 if ((* - .pmc1) < 127) && ((* - .pmc1) > -128)
	bpl .pmc1
 else
	bmi .2skippmc1
	jmp .pmc1
.2skippmc1
 endif
.L0107 ;  score  =  score  +  100

	SED
	CLC
	LDA score+2
	ADC #$00
	STA score+2
	LDA score+1
	ADC #$01
	STA score+1
	LDA score
	ADC #$00
	STA score
	CLD
.L0108 ;  if l = 5 then gosub bosshit  :  return

	LDA l
	CMP #5
     BNE .skipL0108
.condpart3
 jsr .bosshit
	RTS
.skipL0108
.L0109 ;  player0x  =  0

	LDA #0
	STA player0x
.L0110 ;  player0y  =  0

	LDA #0
	STA player0y
.L0111 ;  missile1x  =  0

	LDA #0
	STA missile1x
.L0112 ;  missile1y  =  0

	LDA #0
	STA missile1y
.L0113 ;  missile0x  =  0

	LDA #0
	STA missile0x
.L0114 ;  missile0y  =  0

	LDA #0
	STA missile0y
.L0115 ;  e  =  0

	LDA #0
	STA e
.L0116 ;  f  =  0

	LDA #0
	STA f
.L0117 ;  t  =  0

	LDA #0
	STA t
.L0118 ;  w  =  0

	LDA #0
	STA w
.L0119 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.pmc1
 ; pmc1

.
 ; 

.L0120 ;  if !collision(player0,player1) then pmc2

	BIT CXPPMM
 if ((* - .pmc2) < 127) && ((* - .pmc2) > -128)
	bpl .pmc2
 else
	bmi .3skippmc2
	jmp .pmc2
.3skippmc2
 endif
.L0121 ;  lives  =  lives  - 32

	LDA lives
	SEC
	SBC #32
	STA lives
.L0122 ;  player1x  =  80

	LDA #80
	STA player1x
.L0123 ;  player1y  =  88

	LDA #88
	STA player1y
.L0124 ;  player0x  =  0

	LDA #0
	STA player0x
.L0125 ;  player0y  =  0

	LDA #0
	STA player0y
.L0126 ;  missile1x  =  0

	LDA #0
	STA missile1x
.L0127 ;  missile1y  =  0

	LDA #0
	STA missile1y
.L0128 ;  missile0x  =  0

	LDA #0
	STA missile0x
.L0129 ;  missile0y  =  0

	LDA #0
	STA missile0y
.L0130 ;  ballx  =  0

	LDA #0
	STA ballx
.L0131 ;  bally  =  0

	LDA #0
	STA bally
.L0132 ;  e  =  0

	LDA #0
	STA e
.L0133 ;  f  =  0

	LDA #0
	STA f
.L0134 ;  t  =  0

	LDA #0
	STA t
.L0135 ;  w  =  0

	LDA #0
	STA w
.L0136 ;  c  =  0

	LDA #0
	STA c
.L0137 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.L0138 ;  if lives  >  31 gosub joywait

	LDA #31
	CMP lives
 if ((* - .joywait) < 127) && ((* - .joywait) > -128)
	bcc .joywait
 else
	bcs .4skipjoywait
	jmp .joywait
.4skipjoywait
 endif
.pmc2
 ; pmc2

.
 ; 

.L0139 ;  if !collision(missile0,player1) then pmc3

	BIT CXM0P
 if ((* - .pmc3) < 127) && ((* - .pmc3) > -128)
	bpl .pmc3
 else
	bmi .5skippmc3
	jmp .pmc3
.5skippmc3
 endif
.L0140 ;  lives  =  lives  - 32

	LDA lives
	SEC
	SBC #32
	STA lives
.L0141 ;  player1x  =  80

	LDA #80
	STA player1x
.L0142 ;  player1y  =  88

	LDA #88
	STA player1y
.L0143 ;  player0x  =  0

	LDA #0
	STA player0x
.L0144 ;  player0y  =  0

	LDA #0
	STA player0y
.L0145 ;  missile1x  =  0

	LDA #0
	STA missile1x
.L0146 ;  missile1y  =  0

	LDA #0
	STA missile1y
.L0147 ;  missile0x  =  0

	LDA #0
	STA missile0x
.L0148 ;  missile0y  =  0

	LDA #0
	STA missile0y
.L0149 ;  ballx  =  0

	LDA #0
	STA ballx
.L0150 ;  bally  =  0

	LDA #0
	STA bally
.L0151 ;  e  =  0

	LDA #0
	STA e
.L0152 ;  f  =  0

	LDA #0
	STA f
.L0153 ;  t  =  0

	LDA #0
	STA t
.L0154 ;  w  =  0

	LDA #0
	STA w
.L0155 ;  c  =  0

	LDA #0
	STA c
.L0156 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.L0157 ;  if lives  >  31 gosub joywait

	LDA #31
	CMP lives
 if ((* - .joywait) < 127) && ((* - .joywait) > -128)
	bcc .joywait
 else
	bcs .6skipjoywait
	jmp .joywait
.6skipjoywait
 endif
.pmc3
 ; pmc3

.
 ; 

.L0158 ;  if !collision(ball,player1) then pmc4

	BIT CXP1FB
 if ((* - .pmc4) < 127) && ((* - .pmc4) > -128)
	bvc .pmc4
 else
	bvs .7skippmc4
	jmp .pmc4
.7skippmc4
 endif
.L0159 ;  lives  =  lives  - 32

	LDA lives
	SEC
	SBC #32
	STA lives
.L0160 ;  player1x  =  80

	LDA #80
	STA player1x
.L0161 ;  player1y  =  88

	LDA #88
	STA player1y
.L0162 ;  player0x  =  0

	LDA #0
	STA player0x
.L0163 ;  player0y  =  0

	LDA #0
	STA player0y
.L0164 ;  missile1x  =  0

	LDA #0
	STA missile1x
.L0165 ;  missile1y  =  0

	LDA #0
	STA missile1y
.L0166 ;  missile0x  =  0

	LDA #0
	STA missile0x
.L0167 ;  missile0y  =  0

	LDA #0
	STA missile0y
.L0168 ;  ballx  =  0

	LDA #0
	STA ballx
.L0169 ;  bally  =  0

	LDA #0
	STA bally
.L0170 ;  e  =  0

	LDA #0
	STA e
.L0171 ;  f  =  0

	LDA #0
	STA f
.L0172 ;  t  =  0

	LDA #0
	STA t
.L0173 ;  w  =  0

	LDA #0
	STA w
.L0174 ;  c  =  0

	LDA #0
	STA c
.L0175 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.L0176 ;  if lives  >  31 gosub joywait

	LDA #31
	CMP lives
 if ((* - .joywait) < 127) && ((* - .joywait) > -128)
	bcc .joywait
 else
	bcs .8skipjoywait
	jmp .joywait
.8skipjoywait
 endif
.pmc4
 ; pmc4

.
 ; 

.L0177 ;  if !collision(ball,missile1) then pmc5

	BIT CXM1FB
 if ((* - .pmc5) < 127) && ((* - .pmc5) > -128)
	bvc .pmc5
 else
	bvs .9skippmc5
	jmp .pmc5
.9skippmc5
 endif
.L0178 ;  missile1x  =  0

	LDA #0
	STA missile1x
.L0179 ;  missile1y  =  0

	LDA #0
	STA missile1y
.L0180 ;  ballx  =  0

	LDA #0
	STA ballx
.L0181 ;  bally  =  0

	LDA #0
	STA bally
.L0182 ;  f  =  0

	LDA #0
	STA f
.L0183 ;  t  =  0

	LDA #0
	STA t
.L0184 ;  c  =  0

	LDA #0
	STA c
.L0185 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.pmc5
 ; pmc5

.L0186 ;  return

	RTS
.
 ; 

.joywait
 ; joywait

.L0187 ;  COLUP1 = 14

	LDA #14
	STA COLUP1
.L0188 ;  drawscreen

 jsr drawscreen
.L0189 ;  b = b + 1  :  if b > 50 then b = 50  :  if b = 50  &&  joy0fire then b = 0  :  return

	INC b
	LDA #50
	CMP b
     BCS .skipL0189
.condpart4
	LDA #50
	STA b
	LDA b
	CMP #50
     BNE .skip4then
.condpart5
 lda #$80
 bit INPT4
	BNE .skip5then
.condpart6
	LDA #0
	STA b
	RTS
.skip5then
.skip4then
.skipL0189
.L0190 ;  goto joywait

 jmp .joywait

.
 ; 

.enemystart
 ; enemystart

.L0191 ;  if l  <> 1 then level1enemy

	LDA l
	CMP #1
 if ((* - .level1enemy) < 127) && ((* - .level1enemy) > -128)
	BNE .level1enemy
 else
	beq .10skiplevel1enemy
	jmp .level1enemy
.10skiplevel1enemy
 endif
.L0192 ;  player0:

	LDA #<playerL0192_0

	STA player0pointerlo
	LDA #>playerL0192_0

	STA player0pointerhi
	LDA #12
	STA player0height
.level1enemy
 ; level1enemy

.
 ; 

.L0193 ;  if l  <> 2 then level2enemy

	LDA l
	CMP #2
 if ((* - .level2enemy) < 127) && ((* - .level2enemy) > -128)
	BNE .level2enemy
 else
	beq .11skiplevel2enemy
	jmp .level2enemy
.11skiplevel2enemy
 endif
.level2sprite
 ; level2sprite

.L0194 ;  player0:

	LDA #<playerL0194_0

	STA player0pointerlo
	LDA #>playerL0194_0

	STA player0pointerhi
	LDA #8
	STA player0height
.level2enemy
 ; level2enemy

.
 ; 

.L0195 ;  if l  <> 3 then level3enemy

	LDA l
	CMP #3
 if ((* - .level3enemy) < 127) && ((* - .level3enemy) > -128)
	BNE .level3enemy
 else
	beq .12skiplevel3enemy
	jmp .level3enemy
.12skiplevel3enemy
 endif
.level3sprite
 ; level3sprite

.L0196 ;  player0:

	LDA #<playerL0196_0

	STA player0pointerlo
	LDA #>playerL0196_0

	STA player0pointerhi
	LDA #8
	STA player0height
.level3enemy
 ; level3enemy

.
 ; 

.L0197 ;  if l <> 4 then level4enemy

	LDA l
	CMP #4
 if ((* - .level4enemy) < 127) && ((* - .level4enemy) > -128)
	BNE .level4enemy
 else
	beq .13skiplevel4enemy
	jmp .level4enemy
.13skiplevel4enemy
 endif
.level4sprite
 ; level4sprite

.L0198 ;  player0:

	LDA #<playerL0198_0

	STA player0pointerlo
	LDA #>playerL0198_0

	STA player0pointerhi
	LDA #8
	STA player0height
.level4enemy
 ; level4enemy

.
 ; 

.L0199 ;  if l <> 5 then level5enemy

	LDA l
	CMP #5
 if ((* - .level5enemy) < 127) && ((* - .level5enemy) > -128)
	BNE .level5enemy
 else
	beq .14skiplevel5enemy
	jmp .level5enemy
.14skiplevel5enemy
 endif
.level5sprite
 ; level5sprite

.L0200 ;  player0:

	LDA #<playerL0200_0

	STA player0pointerlo
	LDA #>playerL0200_0

	STA player0pointerhi
	LDA #20
	STA player0height
.level5enemy
 ; level5enemy

.
 ; 

.100 ; 100 x = rand  :  rem I am using a line number here so I can call back to it if the number is out of bounds

 jsr randomize
	STA x
.L0201 ;  if x  <  40  ||  x  >  110 then goto 100  :  rem this should put the ships closer to the screen 

	LDA x
	CMP #40
     BCS .skipL0201
.condpart7
 jmp .condpart8
.skipL0201
	LDA #110
	CMP x
     BCS .skip1OR
.condpart8
 jmp .100
.skip1OR
.L0202 ;  if l <> 5 then COLUP0 = 14 +  ( 16 * l )   :  player0x  =  x  :  player0y  =  12  :  NUSIZ0 = $00

	LDA l
	CMP #5
     BEQ .skipL0202
.condpart9
; complex statement detected
	LDA #14
	PHA
	LDA #16
	LDY l
 jsr mul8
	TSX
	INX
	TXS
	CLC
	ADC $100,x
	STA COLUP0
	LDA x
	STA player0x
	LDA #12
	STA player0y
	LDA #$00
	STA NUSIZ0
.skipL0202
.L0203 ;  if l = 5 then COLUP0 = 8  :  player0x =  100  :  player0y = 20  :  NUSIZ0  =  $15

	LDA l
	CMP #5
     BNE .skipL0203
.condpart10
	LDA #8
	STA COLUP0
	LDA #100
	STA player0x
	LDA #20
	STA player0y
	LDA #$15
	STA NUSIZ0
.skipL0203
.L0204 ;  e  = 1

	LDA #1
	STA e
.return
 ; return

.
 ; 

.enemymove
 ; enemymove

.L0205 ;  if l <> 5 then COLUP0 = 14 +  ( 16 * l )   :  NUSIZ0 = $00

	LDA l
	CMP #5
     BEQ .skipL0205
.condpart11
; complex statement detected
	LDA #14
	PHA
	LDA #16
	LDY l
 jsr mul8
	TSX
	INX
	TXS
	CLC
	ADC $100,x
	STA COLUP0
	LDA #$00
	STA NUSIZ0
.skipL0205
.L0206 ;  if l = 5 then COLUP0  =  8  :  NUSIZ0 = $15

	LDA l
	CMP #5
     BNE .skipL0206
.condpart12
	LDA #8
	STA COLUP0
	LDA #$15
	STA NUSIZ0
.skipL0206
.L0207 ;  x  =  rand

 jsr randomize
	STA x
.L0208 ;  y  =  5  *  l

	LDA #5
	LDY l
 jsr mul8
	STA y
.L0209 ;  rem for level 4, we don't want to shoot

.L0210 ;  if l = 4 then y = 0

	LDA l
	CMP #4
     BNE .skipL0210
.condpart13
	LDA #0
	STA y
.skipL0210
.L0211 ;  if x  <  y  &&  w = 0 then gosub mis0draw

	LDA x
	CMP y
     BCS .skipL0211
.condpart14
	LDA w
	CMP #0
     BNE .skip14then
.condpart15
 jsr .mis0draw

.skip14then
.skipL0211
.L0212 ;  if w  =  1 then gosub mis0flight

	LDA w
	CMP #1
     BNE .skipL0212
.condpart16
 jsr .mis0flight

.skipL0212
.L0213 ;  if l  =  5  &&  x  <  10  &&  c = 0 then gosub fireball

	LDA l
	CMP #5
     BNE .skipL0213
.condpart17
	LDA x
	CMP #10
     BCS .skip17then
.condpart18
	LDA c
	CMP #0
     BNE .skip18then
.condpart19
 jsr .fireball

.skip18then
.skip17then
.skipL0213
.L0214 ;  if c = 1 then gosub fbflight

	LDA c
	CMP #1
     BNE .skipL0214
.condpart20
 jsr .fbflight

.skipL0214
.
 ; 

.L0215 ;  rem Level 1 movement for transports (Cowardly)

.L0216 ;  if l <> 1 then Move1

	LDA l
	CMP #1
 if ((* - .Move1) < 127) && ((* - .Move1) > -128)
	BNE .Move1
 else
	beq .15skipMove1
	jmp .Move1
.15skipMove1
 endif
.L0217 ;  v  =  1

	LDA #1
	STA v
.L0218 ;  if x  <  30  &&  player1x  >  player0x then player0x  =  player0x  -  1

	LDA x
	CMP #30
     BCS .skipL0218
.condpart21
	LDA player0x
	CMP player1x
     BCS .skip21then
.condpart22
	DEC player0x
.skip21then
.skipL0218
.L0219 ;  if x  >  235  &&  player1x  <  player0x then player0x  =  player0x  +  1

	LDA #235
	CMP x
     BCS .skipL0219
.condpart23
	LDA player1x
	CMP player0x
     BCS .skip23then
.condpart24
	INC player0x
.skip23then
.skipL0219
.L0220 ;  if player0x  <  1 then player0x  =  1

	LDA player0x
	CMP #1
     BCS .skipL0220
.condpart25
	LDA #1
	STA player0x
.skipL0220
.L0221 ;  if player0x  >  153 then player0x  = 153

	LDA #153
	CMP player0x
     BCS .skipL0221
.condpart26
	LDA #153
	STA player0x
.skipL0221
.L0222 ;  player0y  =  player0y + v

	LDA player0y
	CLC
	ADC v
	STA player0y
.L0223 ;  if player0y  >  88 then player0y  =  0  :  player0x  =  0  :  e  =  0  :  w  =  0  :  missile0x  =  0  :  missile0y  =  0

	LDA #88
	CMP player0y
     BCS .skipL0223
.condpart27
	LDA #0
	STA player0y
	STA player0x
	STA e
	STA w
	STA missile0x
	STA missile0y
.skipL0223
.Move1
 ; Move1

.
 ; 

.L0224 ;  rem Level 2 movement for drones (Curve In)

.L0225 ;  if l <> 2 then Move2

	LDA l
	CMP #2
 if ((* - .Move2) < 127) && ((* - .Move2) > -128)
	BNE .Move2
 else
	beq .16skipMove2
	jmp .Move2
.16skipMove2
 endif
.L0226 ;  v  =  1

	LDA #1
	STA v
.L0227 ;  if player0y  >  40  &&  player1x  >  player0x then player0x  =  player0x  +  l

	LDA #40
	CMP player0y
     BCS .skipL0227
.condpart28
	LDA player0x
	CMP player1x
     BCS .skip28then
.condpart29
	LDA player0x
	CLC
	ADC l
	STA player0x
.skip28then
.skipL0227
.L0228 ;  if player0y  >  40  &&  player1x  <  player0x then player0x  =  player0x  -  l

	LDA #40
	CMP player0y
     BCS .skipL0228
.condpart30
	LDA player1x
	CMP player0x
     BCS .skip30then
.condpart31
	LDA player0x
	SEC
	SBC l
	STA player0x
.skip30then
.skipL0228
.L0229 ;  if player0x  <  1 then player0x  =  1

	LDA player0x
	CMP #1
     BCS .skipL0229
.condpart32
	LDA #1
	STA player0x
.skipL0229
.L0230 ;  if player0x  >  153 then player0x  = 153

	LDA #153
	CMP player0x
     BCS .skipL0230
.condpart33
	LDA #153
	STA player0x
.skipL0230
.L0231 ;  player0y  =  player0y + v

	LDA player0y
	CLC
	ADC v
	STA player0y
.L0232 ;  if player0y  >  88 then player0y  =  0  :  player0x  =  0  :  e  =  0  :  w  =  0  :  missile0x  =  0  :  missile0y  =  0

	LDA #88
	CMP player0y
     BCS .skipL0232
.condpart34
	LDA #0
	STA player0y
	STA player0x
	STA e
	STA w
	STA missile0x
	STA missile0y
.skipL0232
.Move2
 ; Move2

.
 ; 

.L0233 ;  rem Level 3 movement for drones (Zig-Zag)

.L0234 ;  if l <> 3 then Move3

	LDA l
	CMP #3
 if ((* - .Move3) < 127) && ((* - .Move3) > -128)
	BNE .Move3
 else
	beq .17skipMove3
	jmp .Move3
.17skipMove3
 endif
.L0235 ;  v = 1

	LDA #1
	STA v
.L0236 ;  if player0y  <  10 then player0x  =  player0x  +  1

	LDA player0y
	CMP #10
     BCS .skipL0236
.condpart35
	INC player0x
.skipL0236
.L0237 ;  if player0y  >  9  &&  player0y  <  30 then player0x  =  player0x  +  1

	LDA #9
	CMP player0y
     BCS .skipL0237
.condpart36
	LDA player0y
	CMP #30
     BCS .skip36then
.condpart37
	INC player0x
.skip36then
.skipL0237
.L0238 ;  if player0y  >  29  &&  player0y  <  50 then player0x  =  player0x  -  1

	LDA #29
	CMP player0y
     BCS .skipL0238
.condpart38
	LDA player0y
	CMP #50
     BCS .skip38then
.condpart39
	DEC player0x
.skip38then
.skipL0238
.L0239 ;  if player0y  >  49  &&  player0y  <  70 then player0x  =  player0x  +  1

	LDA #49
	CMP player0y
     BCS .skipL0239
.condpart40
	LDA player0y
	CMP #70
     BCS .skip40then
.condpart41
	INC player0x
.skip40then
.skipL0239
.L0240 ;  if player0y  >  69  &&  player0y  <  90 then player0x  =  player0x  -  1

	LDA #69
	CMP player0y
     BCS .skipL0240
.condpart42
	LDA player0y
	CMP #90
     BCS .skip42then
.condpart43
	DEC player0x
.skip42then
.skipL0240
.L0241 ;  if player0x  <  2 then player0x  =  2

	LDA player0x
	CMP #2
     BCS .skipL0241
.condpart44
	LDA #2
	STA player0x
.skipL0241
.L0242 ;  if player0x  >  152 then player0x  = 152

	LDA #152
	CMP player0x
     BCS .skipL0242
.condpart45
	LDA #152
	STA player0x
.skipL0242
.L0243 ;  player0y  =  player0y + v

	LDA player0y
	CLC
	ADC v
	STA player0y
.L0244 ;  if player0y  >  88 then player0y  =  0  :  player0x  =  0  :  e  =  0  :  w  =  0  :  missile0x  =  0  :  missile0y  =  0

	LDA #88
	CMP player0y
     BCS .skipL0244
.condpart46
	LDA #0
	STA player0y
	STA player0x
	STA e
	STA w
	STA missile0x
	STA missile0y
.skipL0244
.Move3
 ; Move3

.
 ; 

.L0245 ;  rem Level 4 movement for the missile storm (straight and fast)

.L0246 ;  if l <> 4 then Move4

	LDA l
	CMP #4
 if ((* - .Move4) < 127) && ((* - .Move4) > -128)
	BNE .Move4
 else
	beq .18skipMove4
	jmp .Move4
.18skipMove4
 endif
.L0247 ;  v  =  3

	LDA #3
	STA v
.L0248 ;  player0y  =  player0y + v

	LDA player0y
	CLC
	ADC v
	STA player0y
.L0249 ;  if player0y  >  88 then player0y  =  0  :  player0x  =  0  :  e  =  0  :  w  =  0  :  missile0x  =  0  :  missile0y  =  0

	LDA #88
	CMP player0y
     BCS .skipL0249
.condpart47
	LDA #0
	STA player0y
	STA player0x
	STA e
	STA w
	STA missile0x
	STA missile0y
.skipL0249
.Move4
 ; Move4

.
 ; 

.L0250 ;  rem Level 5 movement for the boss (Figure 8)

.L0251 ;  if l <> 5 then Move5

	LDA l
	CMP #5
 if ((* - .Move5) < 127) && ((* - .Move5) > -128)
	BNE .Move5
 else
	beq .19skipMove5
	jmp .Move5
.19skipMove5
 endif
.L0252 ;  if player0x  >  140 then r  =  1  :  player0x  =  140

	LDA #140
	CMP player0x
     BCS .skipL0252
.condpart48
	LDA #1
	STA r
	LDA #140
	STA player0x
.skipL0252
.L0253 ;  if player0x  <  10 then r  =  0  :  player0x  =  10

	LDA player0x
	CMP #10
     BCS .skipL0253
.condpart49
	LDA #0
	STA r
	LDA #10
	STA player0x
.skipL0253
.L0254 ;  if r = 0 then player0x  =  player0x  +  2

	LDA r
	CMP #0
     BNE .skipL0254
.condpart50
	LDA player0x
	CLC
	ADC #2
	STA player0x
.skipL0254
.L0255 ;  if r = 1 then player0x  =  player0x  -  2

	LDA r
	CMP #1
     BNE .skipL0255
.condpart51
	LDA player0x
	SEC
	SBC #2
	STA player0x
.skipL0255
.
 ; 

.L0256 ;  if player0y  >  88 then player0y  =  0  :  player0x  =  0  :  e  =  0  :  w  =  0  :  missile0x  =  0  :  missile0y  =  0

	LDA #88
	CMP player0y
     BCS .skipL0256
.condpart52
	LDA #0
	STA player0y
	STA player0x
	STA e
	STA w
	STA missile0x
	STA missile0y
.skipL0256
.Move5
 ; Move5

.L0257 ;  return

	RTS
.
 ; 

.L0258 ;  rem move player

.pmove
 ; pmove

.L0259 ;  COLUP1 = 14

	LDA #14
	STA COLUP1
.L0260 ;  if joy0left then player1x  =  player1x  - 1

 lda #$40
 bit SWCHA
	BNE .skipL0260
.condpart53
	DEC player1x
.skipL0260
.L0261 ;  if joy0right then player1x  =  player1x + 1

 lda #$80
 bit SWCHA
	BNE .skipL0261
.condpart54
	INC player1x
.skipL0261
.L0262 ;  if player1x  >  153 then player1x  =  153

	LDA #153
	CMP player1x
     BCS .skipL0262
.condpart55
	LDA #153
	STA player1x
.skipL0262
.L0263 ;  if player1x  <  1 then player1x  =  1

	LDA player1x
	CMP #1
     BCS .skipL0263
.condpart56
	LDA #1
	STA player1x
.skipL0263
.L0264 ;  return

	RTS
.
 ; 

.L0265 ;  rem player fires missile

.pfire
 ; pfire

.L0266 ;  if joy0fire  &&  f = 0 then gosub mis1draw

 lda #$80
 bit INPT4
	BNE .skipL0266
.condpart57
	LDA f
	CMP #0
     BNE .skip57then
.condpart58
 jsr .mis1draw

.skip57then
.skipL0266
.L0267 ;  if f = 1 then gosub mis1flight

	LDA f
	CMP #1
     BNE .skipL0267
.condpart59
 jsr .mis1flight

.skipL0267
.L0268 ;  return

	RTS
.
 ; 

.L0269 ;  rem draw player missile

.mis1draw
 ; mis1draw

.L0270 ;  missile1x = player1x  +  4

	LDA player1x
	CLC
	ADC #4
	STA missile1x
.L0271 ;  missile1y = player1y  -  4

	LDA player1y
	SEC
	SBC #4
	STA missile1y
.L0272 ;  missile1height = 4

	LDA #4
	STA missile1height
.L0273 ;  f  =  1

	LDA #1
	STA f
.L0274 ;  return

	RTS
.
 ; 

.L0275 ;  rem missile in flight

.mis1flight
 ; mis1flight

.L0276 ;  t  =  t + 3

	LDA t
	CLC
	ADC #3
	STA t
.L0277 ;  if t  >  30 then t  =  30

	LDA #30
	CMP t
     BCS .skipL0277
.condpart60
	LDA #30
	STA t
.skipL0277
.L0278 ;  missile1y = missile1y  -  4

	LDA missile1y
	SEC
	SBC #4
	STA missile1y
.L0279 ;  AUDV0  =  10  :  AUDC0  =  15  :  AUDF0  =  t

	LDA #10
	STA AUDV0
	LDA #15
	STA AUDC0
	LDA t
	STA AUDF0
.L0280 ;  if missile1y  >  0 then return

	LDA #0
	CMP missile1y
     BCS .skipL0280
.condpart61
	RTS
.skipL0280
.L0281 ;  rem send missile off screen if it hits the top

.L0282 ;  missile1x = 0

	LDA #0
	STA missile1x
.L0283 ;  missile1y = 0

	LDA #0
	STA missile1y
.L0284 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.L0285 ;  f = 0

	LDA #0
	STA f
.L0286 ;  t = 0

	LDA #0
	STA t
.L0287 ;  return

	RTS
.
 ; 

.levelup
 ; levelup

.L0288 ;  if sc1  =  $00  &&  sc2  >  $14 then l = 2

	LDA sc1
	CMP #$00
     BNE .skipL0288
.condpart62
	LDA #$14
	CMP sc2
     BCS .skip62then
.condpart63
	LDA #2
	STA l
.skip62then
.skipL0288
.L0289 ;  if sc1  =  $00  &&  sc2  >  $34 then l = 3

	LDA sc1
	CMP #$00
     BNE .skipL0289
.condpart64
	LDA #$34
	CMP sc2
     BCS .skip64then
.condpart65
	LDA #3
	STA l
.skip64then
.skipL0289
.L0290 ;  if sc1  =  $00  &&  sc2  >  $59 then l = 4

	LDA sc1
	CMP #$00
     BNE .skipL0290
.condpart66
	LDA #$59
	CMP sc2
     BCS .skip66then
.condpart67
	LDA #4
	STA l
.skip66then
.skipL0290
.L0291 ;  if sc1  =  $00  &&  sc2  >  $74 then l = 5

	LDA sc1
	CMP #$00
     BNE .skipL0291
.condpart68
	LDA #$74
	CMP sc2
     BCS .skip68then
.condpart69
	LDA #5
	STA l
.skip68then
.skipL0291
.L0292 ;  if sc1  =  $12  &&  sc2  >  $49 then lives  =  0

	LDA sc1
	CMP #$12
     BNE .skipL0292
.condpart70
	LDA #$49
	CMP sc2
     BCS .skip70then
.condpart71
	LDA #0
	STA lives
.skip70then
.skipL0292
.L0293 ;  return

	RTS
.
 ; 

.mis0draw
 ; mis0draw

.L0294 ;  missile0x = player0x  +  4

	LDA player0x
	CLC
	ADC #4
	STA missile0x
.L0295 ;  if l  =  5 then missile0x = player0x  +  9

	LDA l
	CMP #5
     BNE .skipL0295
.condpart72
	LDA player0x
	CLC
	ADC #9
	STA missile0x
.skipL0295
.L0296 ;  missile0y = player0y

	LDA player0y
	STA missile0y
.L0297 ;  missile0height = 4

	LDA #4
	STA missile0height
.L0298 ;  w  =  1

	LDA #1
	STA w
.L0299 ;  return

	RTS
.
 ; 

.mis0flight
 ; mis0flight

.L0300 ;  z  =  z + 3

	LDA z
	CLC
	ADC #3
	STA z
.L0301 ;  if z  >  30 then z  =  30

	LDA #30
	CMP z
     BCS .skipL0301
.condpart73
	LDA #30
	STA z
.skipL0301
.L0302 ;  missile0y = missile0y  +  4

	LDA missile0y
	CLC
	ADC #4
	STA missile0y
.L0303 ;  AUDV0  =  10  :  AUDC0  =  15  :  AUDF0  =  z

	LDA #10
	STA AUDV0
	LDA #15
	STA AUDC0
	LDA z
	STA AUDF0
.L0304 ;  if missile0y  <  88 then return

	LDA missile0y
	CMP #88
     BCS .skipL0304
.condpart74
	RTS
.skipL0304
.L0305 ;  rem send missile off screen if it hits the top

.L0306 ;  missile0x = 0

	LDA #0
	STA missile0x
.L0307 ;  missile0y = 0

	LDA #0
	STA missile0y
.L0308 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.L0309 ;  w = 0

	LDA #0
	STA w
.L0310 ;  z = 0

	LDA #0
	STA z
.L0311 ;  return

	RTS
.
 ; 

.startscreen
 ; startscreen

.L0312 ;  player1x  =  0

	LDA #0
	STA player1x
.L0313 ;  player1y  =  0

	LDA #0
	STA player1y
.L0314 ;  COLUPF  =  192

	LDA #192
	STA COLUPF
.L0315 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel1
PF_data1
	.byte %01110100, %00000000, %00000000, %00010101
	.byte %10000111, %01000100, %11000000, %00001110
	.byte %01100100, %11001010, %00000001, %00111111
	.byte %00010100, %01001010, %00000000, %00001110
	.byte %11100011, %01010100, %00000000, %00010101
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %11110100, %00010111, %01000011, %00110100
	.byte %10000001, %00010100, %01110111, %00001101
	.byte %11100100, %01110111, %01000100, %00000100
	.byte %10000100, %10010100, %01000100, %00000101
	.byte %10000101, %10010011, %00110011, %00000100
pflabel1
	lda PF_data1,x
	sta playfield,x
	dex
	bpl pflabel1
.L0316 ;  gosub joywait

 jsr .joywait

.L0317 ;  drawscreen

 jsr drawscreen
.L0318 ;  COLUPF  =  0

	LDA #0
	STA COLUPF
.L0319 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel2
PF_data2
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
pflabel2
	lda PF_data2,x
	sta playfield,x
	dex
	bpl pflabel2
.L0320 ;  player1x  =  80

	LDA #80
	STA player1x
.L0321 ;  player1y  =  88

	LDA #88
	STA player1y
.L0322 ;  s  =  1

	LDA #1
	STA s
.L0323 ;  return

	RTS
.
 ; 

.fireball
 ; fireball

.L0324 ;  ballx = player0x + 6

	LDA player0x
	CLC
	ADC #6
	STA ballx
.L0325 ;  bally = player0y - 6

	LDA player0y
	SEC
	SBC #6
	STA bally
.L0326 ;  ballheight = 4

	LDA #4
	STA ballheight
.L0327 ;  COLUPF = 30

	LDA #30
	STA COLUPF
.L0328 ;  CTRLPF = $21

	LDA #$21
	STA CTRLPF
.L0329 ;  c = 1

	LDA #1
	STA c
.L0330 ;  return

	RTS
.
 ; 

.fbflight
 ; fbflight

.L0331 ;  z  =  z + 3

	LDA z
	CLC
	ADC #3
	STA z
.L0332 ;  if z  >  30 then z  =  30

	LDA #30
	CMP z
     BCS .skipL0332
.condpart75
	LDA #30
	STA z
.skipL0332
.L0333 ;  bally = bally  +  4

	LDA bally
	CLC
	ADC #4
	STA bally
.L0334 ;  if player1x  <  ballx then ballx  =  ballx  -  2

	LDA player1x
	CMP ballx
     BCS .skipL0334
.condpart76
	LDA ballx
	SEC
	SBC #2
	STA ballx
.skipL0334
.L0335 ;  if player1x  >  ballx then ballx  =  ballx  +  2

	LDA ballx
	CMP player1x
     BCS .skipL0335
.condpart77
	LDA ballx
	CLC
	ADC #2
	STA ballx
.skipL0335
.L0336 ;  rem  AUDV0 = 10 : AUDC0 = 15 : AUDF0 = z

.L0337 ;  if bally  <  88 then return

	LDA bally
	CMP #88
     BCS .skipL0337
.condpart78
	RTS
.skipL0337
.L0338 ;  rem send missile off screen if it hits the top

.L0339 ;  ballx = 0

	LDA #0
	STA ballx
.L0340 ;  bally = 0

	LDA #0
	STA bally
.L0341 ;  rem AUDV0 = 0

.L0342 ;  c = 0

	LDA #0
	STA c
.L0343 ;  z = 0

	LDA #0
	STA z
.L0344 ;  return

	RTS
 if (<*) > (<(*+9))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL017_1

	.byte 0
	.byte  %10000001
	.byte  %11011011
	.byte  %01111110
	.byte  %00011000
	.byte  %00011000
	.byte  %00111100
	.byte  %00111100
	.byte  %00011000
 if (<*) > (<(*+8))
	repeat ($100-<*)
	.byte 0
	repend
	endif
lives__L056
	.byte  %10000001
	.byte  %11011011
	.byte  %01111110
	.byte  %00011000
	.byte  %00011000
	.byte  %00111100
	.byte  %00111100
	.byte  %00011000
 if (<*) > (<(*+13))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL0192_0

	.byte 0
	.byte  %00111100
	.byte  %01100110
	.byte  %11111111
	.byte  %11011011
	.byte  %10011001
	.byte  %00011000
	.byte  %10111101
	.byte  %11111111
	.byte  %11111111
	.byte  %10111101
	.byte  %10011001
	.byte  %00111100
 if (<*) > (<(*+9))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL0194_0

	.byte 0
	.byte  %00010000
	.byte  %00111000
	.byte  %00010000
	.byte  %10111010
	.byte  %11101110
	.byte  %11000110
	.byte  %01111100
	.byte  %00111000
 if (<*) > (<(*+9))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL0196_0

	.byte 0
	.byte  %00011000
	.byte  %00111100
	.byte  %00011000
	.byte  %00011000
	.byte  %10111101
	.byte  %11111111
	.byte  %11011011
	.byte  %10000001
 if (<*) > (<(*+9))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL0198_0

	.byte 0
	.byte  %00010000
	.byte  %00111000
	.byte  %00010000
	.byte  %00010000
	.byte  %00010000
	.byte  %00111000
	.byte  %01111100
	.byte  %00010000
 if (<*) > (<(*+21))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL0200_0

	.byte 0
	.byte  %00111100
	.byte  %01100110
	.byte  %11011011
	.byte  %11111111
	.byte  %01111110
	.byte  %00100100
	.byte  %00100100
	.byte  %00111100
	.byte  %00011000
	.byte  %01011010
	.byte  %11011011
	.byte  %11011011
	.byte  %11111111
	.byte  %11111111
	.byte  %11111111
	.byte  %11100111
	.byte  %11000011
	.byte  %11000011
	.byte  %11000011
	.byte  %11000011
       echo "    ",[(scoretable - *)]d , "bytes of ROM space left")
 
 
 
; feel free to modify the score graphics - just keep each digit 8 high
; and keep the conditional compilation stuff intact
 ifconst ROM2k
   ORG $F7AC
 else
   ifconst bankswitch
     if bankswitch == 8
       ORG $2F94-bscode_length
       RORG $FF94-bscode_length
     endif
     if bankswitch == 16
       ORG $4F94-bscode_length
       RORG $FF94-bscode_length
     endif
     if bankswitch == 32
       ORG $8F94-bscode_length
       RORG $FF94-bscode_length
     endif
   else
     ORG $FF9C
   endif
 endif


scoretable
       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100

       .byte %01111110
       .byte %00011000
       .byte %00011000
       .byte %00011000
       .byte %00011000
       .byte %00111000
       .byte %00011000
       .byte %00001000

       .byte %01111110
       .byte %01100000
       .byte %01100000
       .byte %00111100
       .byte %00000110
       .byte %00000110
       .byte %01000110
       .byte %00111100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00000110
       .byte %00011100
       .byte %00000110
       .byte %01000110
       .byte %00111100

       .byte %00001100
       .byte %00001100
       .byte %01111110
       .byte %01001100
       .byte %01001100
       .byte %00101100
       .byte %00011100
       .byte %00001100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00000110
       .byte %00111100
       .byte %01100000
       .byte %01100000
       .byte %01111110

       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01111100
       .byte %01100000
       .byte %01100010
       .byte %00111100

       .byte %00110000
       .byte %00110000
       .byte %00110000
       .byte %00011000
       .byte %00001100
       .byte %00000110
       .byte %01000010
       .byte %00111110

       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %00111100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00111110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100 


 ifconst ROM2k
   ORG $F7FC
 else
   ifconst bankswitch
     if bankswitch == 8
       ORG $2FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 16
       ORG $4FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 32
       ORG $8FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
   else
     ORG $FFFC
   endif
 endif
 ifconst bankswitch
   if bankswitch == 8
     ORG $2FFC
     RORG $FFFC
   endif
   if bankswitch == 16
     ORG $4FFC
     RORG $FFFC
   endif
   if bankswitch == 32
     ORG $8FFC
     RORG $FFFC
   endif
 else
   ifconst ROM2k
     ORG $F7FC
   else
     ORG $FFFC
   endif
 endif
 .word start
 .word start
