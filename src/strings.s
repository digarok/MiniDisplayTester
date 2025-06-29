
* Notes:
* XPOS and YPOS are the same as CH/CV used in the firmware routines, $24 and $25

_SRCPTR_          =     $26
_DSTPTR_          =     $28

BOX_X1            db    0
BOX_X2            db    0
BOX_Y1            db    0
BOX_Y2            db    0
DRAWCHAR          db    $20                      ; this is what we will write to screen


** #nofirmware #6502
ResetDrawChar     lda   #$20
                  sta   DRAWCHAR
                  rts

** #nofirmware
PRINTSTRING       MAC
                  lda   #]1
                  ldy   #>]1
                  jsr   PrintString
                  <<<
** #nofirmware
PRINTXYSTRING     MAC
                  ldx   ]1
                  ldy   ]2
                  stx   XPOS
                  sty   YPOS

                  lda   #]3
                  ldy   #>]3
                  jsr   PrintString
                  <<<

** #firmware #6502
GOXY              MAC
                  ldx   ]1
                  ldy   ]2
                  stx   XPOS
                  sty   YPOS
                  jsr   VTAB
                  <<<

** #firmware
GoXY              stx   XPOS
                  sty   YPOS
                  jsr   VTAB
                  rts


** #nofirmware
BOX               MAC
                  lda   #]1
                  sta   BOX_X1
                  lda   #]2
                  sta   BOX_Y1
                  lda   #]3
                  sta   BOX_X2
                  lda   #]4
                  sta   BOX_Y2
                  jsr   PrintBox
                  <<<


********************************************************
* CharToUpper (char A)
* Desc: Converts any alpha in A to upper case
* Parm: A = any character
* Return: A = character, in upper case if alpha
** #nofirmware #6502
CharToUpper       cmp   #"z"
                  bcs   :notLower
                  cmp   #"a"
                  bcc   :notLower
                  sec
                  sbc   #$20                     ;sub 32 to get upper char
:notLower         rts


********************************************************
* CharToLower (char A)
* Desc: Converts any alpha in A to lower case
* Parm: A = any character
* Return: A = character, in lower case if alpha
** #nofirmware #6502
CharToLower       cmp   #"Z"
                  bcs   :notUpper
                  cmp   #"A"
                  bcc   :notUpper
                  clc
                  adc   #$20                     ;add 32 to get lower char
:notUpper         rts


********************************************************
* PrintString (srcPtr *AY, xpos $24, ypos $25)
* Desc: prints stringz at CH/CV in 40 or 80 col
* Parm: A = high byte of source string address
* Parm: Y = low byte of source string address
* Parm: $24 = x-pos
* Parm: $25 = y-pos
** #nofirmware
PrintString       ldx   RD80VID
                  bmi   _PrintString80           ; else PrintString40

** #internal #safe
_PrintString40    sta   _SRCPTR_
                  sty   _SRCPTR_+1
                  ldx   YPOS                     ; y value
                  lda   LoLineTableL,x           ; get memory position of start of line (low byte)
                  clc
                  adc   XPOS                     ; add x value - no bounds checking
                  sta   _DSTPTR_
                  lda   LoLineTableH,x           ; get memory position of start of line (high byte)
                  sta   _DSTPTR_+1

                  ldy   #0
:loop             lda   (_SRCPTR_),y
                  beq   :exit
                  sta   (_DSTPTR_),y
                  iny
                  bne   :loop
:exit             rts

* @todo: I don't like the use of $30 / $31 here undefined.
** #internal #safe
_PrintString80    sta   _SRCPTR_
                  sty   _SRCPTR_+1

                  ldx   YPOS                     ; y value
                  lda   LoLineTableL,x           ; get memory position of start of line (low byte)
                  sta   _DSTPTR_
                  lda   LoLineTableH,x           ; get memory position of start of line (high byte)
                  sta   _DSTPTR_+1

                  lda   #0                       ; src index
                  sta   $30                      ; src index
:loop
                  lda   XPOS
                  lsr
                  sta   $31                      ; dst index
                  bcc   :even
:odd              sta   TXTPAGE1
                  bcs   :print                   ; BRA
:even             sta   TXTPAGE2

:print            ldy   $30
                  lda   (_SRCPTR_),y
                  beq   :exit
                  ldy   $31
                  sta   (_DSTPTR_),y
                  inc   XPOS
                  inc   $30
                  bne   :loop
:exit             rts



************** BOX DRAWING ROUTINES
* @todo: Maybe change to ZP locs

********************************************************
* PrintBox (byte BOX_X1, byte BOX_Y1, byte BOX_X2, byte BOX_Y2, char DRAWCHAR)
* Desc: Takes box coords, calculates/makes 4 line draw calls to draw a box
* Parm: BOX_X1,BOX_X2,BOX_Y1,BOX_Y2 = Coords of a box with X1,Y1 being top-left
* Parm: DRAWCHAR = the character to use when drawing the box
** #nofirmware #6502
PrintBox          lda   BOX_X2                   ;top line
                  sec
                  sbc   BOX_X1
                  ldx   BOX_X1
                  ldy   BOX_Y1
                  jsr   PrintXLine

                  lda   BOX_X2                   ;bottom line
                  sec
                  sbc   BOX_X1
                  ldx   BOX_X1
                  ldy   BOX_Y2
                  jsr   PrintXLine

                  lda   BOX_Y2                   ;left line
                  sec
                  sbc   BOX_Y1
                  ldx   BOX_Y1
                  ldy   BOX_X1
                  jsr   PrintYLine

                  lda   BOX_Y2                   ;right line
                  sec
                  sbc   BOX_Y1
                  ldx   BOX_Y1
                  ldy   BOX_X2
                  jsr   PrintYLine
                  rts




* A = height
* x = start y
* y = screen x offset
PrintYLine
                  bit   RD80VID                  ; preserve A
                  bmi   _print_y_line_80

_print_y_line_40
:loop             pha
                  lda   LoLineTableL,x
                  sta   $0
                  lda   LoLineTableH,x
                  sta   $1
                  lda   DRAWCHAR
:write            sta   ($0),y
                  inx
                  pla
                  sec
                  sbc   #1
                  bpl   :loop
                  rts


_print_y_line_80  sta   $0                       ; tmp
                  lda   DRAWCHAR
                  pha                           ; store for aux preserve
                  lda   $0
                  pha                           ; back to our normal program loop

                  tya                           ; x offset (0-79)
                  lsr                           ; /2
                  bcc   :even
:odd              sta   TXTPAGE1

                  bcs   :go
:even             sta   TXTPAGE2
                  bit   RDTEXT
                  bmi   :go                      ; text only
                  pha
                  ldy   DRAWCHAR                 ; recolor
                  lda   MainAuxMap,y             ;
                  sta   DRAWCHAR                 ;
                  pla

:go               tay
                  pla
:loop             pha
                  lda   LoLineTableL,x
                  sta   $0
                  lda   LoLineTableH,x
                  sta   $1
                  lda   DRAWCHAR
:write            sta   ($0),y
                  inx
                  pla
                  sec
                  sbc   #1
                  bpl   :loop
                  pla
                  sta   DRAWCHAR
                  rts


* A = width
* x = start x
* y = screen y
PrintXLine
                  bit   RD80VID                  ; preserve A
                  bmi   _print_x_line_80

_print_x_line_40  pha
                  lda   LoLineTableL,y
                  sta   $0
                  lda   LoLineTableH,y
                  sta   $1
                  txa
                  clc
                  adc   $0
                  sta   $0
                  pla
                  tay
                  lda   DRAWCHAR
:write            sta   (0),y
                  dey
                  bpl   :write
                  rts

_print_x_line_80  pha                           ; stash width
                  lda   LoLineTableL,y
                  sta   $0
                  lda   LoLineTableH,y
                  sta   $1
                  pla                           ; width
                                                ; now y is done, x = x, a=iterations(width)
                  bit   RDTEXT                   ; text mode is simpler
                  bpl   :drawloopDLR             ; GR mode needs to handle aux color pixels :(
:drawloopText     pha
                  jsr   SetTxtPageAndY
                  lda   DRAWCHAR
                  sta   (0),y
                  pla
                  inx                           ; x++
                  sec
                  sbc   #1
                  bpl   :drawloopText
                  rts

:drawloopDLR      pha
                  txa
                  lsr
                  bcs   :noRecolor

:recolor          ldy   DRAWCHAR                 ; recolor aux colums (odd)
                  lda   MainAuxMap,y
                  pha
                  jsr   SetTxtPageAndY
                  pla
                  sta   (0),y
                  bcc   :converge

:noRecolor        jsr   SetTxtPageAndY           ; just straight store main cols (even)
                  lda   DRAWCHAR
                  sta   (0),y

:converge         pla
                  inx                           ; x++
                  sec
                  sbc   #1
                  bpl   :drawloopDLR
                  rts


* Sets the 80-col text page and appropriate y offset for (zp),y storage
* IN:  x=x position
* OUT: y=y offset
* TRASHED: a
SetTxtPageAndY    txa
                  lsr
                  bcc   :even
:odd              sta   TXTPAGE1
                  bcs   :next
:even             sta   TXTPAGE2
:next             tay
                  rts
