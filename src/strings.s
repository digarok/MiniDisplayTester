**** MACROS
* GOXY #x;#y
* PRINTXY #x;#y;StringAddrWord

* PRINTSTRING #addr
**** FUNCTIONS
* GoXY
* PrintStringsX
* PrintString

* In case we need to move these in the future
_SRCPTR_          =     $26
_DSTPTR_          =     $28

PRINTXY           MAC
                  ldx   ]1
                  ldy   ]2
                  stx   $24
                  sty   $25

                  lda   #]3
                  ldy   #>]3
                  jsr   PrintString
                  <<<

* Kind of redunant?
PRINTXY80         MAC
                  ldx   ]1
                  ldy   ]2
                  stx   $24
                  sty   $25

                  lda   #]3
                  ldy   #>]3
                  jsr   PrintString80
                  <<<

* Kind of redunant?
PRINTXY40         MAC
                  ldx   ]1
                  ldy   ]2
                  stx   $24
                  sty   $25

                  lda   #]3
                  ldy   #>]3
                  jsr   PrintString40
                  <<<

PrintString       ldx   RD80VID
                  bmi   :pr80
                  jmp   PrintString40
:pr80             jmp   PrintString80


* PrintString (A=Low Byte,  Y=High Byte)
PrintString80     sta   _SRCPTR_
                  sty   _SRCPTR_+1

                  ldx   $25                     ; y value
                  lda   LoLineTableL,x          ; get memory position of start of line (low byte)
                  sta   _DSTPTR_
                  lda   LoLineTableH,x          ; get memory position of start of line (high byte)
                  sta   _DSTPTR_+1

                  lda   #0                      ; src index
                  sta   $30                     ; src index
:loop
                  lda   $24
                  lsr
                  sta   $31                     ; dst index
                  bcc   :even
:odd              sta   TXTPAGE1
                  bcs   :print                  ; BRA
:even             sta   TXTPAGE2

:print            ldy   $30
                  lda   (_SRCPTR_),y
                  beq   :exit
                  ldy   $31
                  sta   (_DSTPTR_),y
                  inc   $24
                  inc   $30
                  bne   :loop
:exit             rts


PrintString40     sta   _SRCPTR_
                  sty   _SRCPTR_+1
                  ldx   $25                     ; y value
                  lda   LoLineTableL,x          ; get memory position of start of line (low byte)
                  clc
                  adc   $24                     ; add x value - no bounds checking
                  sta   _DSTPTR_
                  lda   LoLineTableH,x          ; get memory position of start of line (high byte)
                  sta   _DSTPTR_+1

                  ldy   #0
:loop             lda   (_SRCPTR_),y
                  beq   :exit
                  sta   (_DSTPTR_),y
                  iny
                  bne   :loop
:exit             rts

PRINTSTRING       MAC
                  lda   #]1
                  ldy   #>]1
                  jsr   PrintString
                  <<<

GOXY              MAC
                  ldx   ]1
                  ldy   ]2
                  stx   $24
                  sty   $25
                  jsr   VTAB
                  <<<


GoXY              stx   $24
                  sty   $25
                  jsr   VTAB
                  rts

*	lda #MainMenuStrs
*	ldy #>MainMenuStrs
*	ldx #05	; horiz pos
PrintStringsX     stx   _printstringsx_horiz

                  sta   $0
                  sty   $1
:loop             lda   _printstringsx_horiz
                  sta   $24
                  lda   $0                      ; slower, but allows API reuse
                  ldy   $1
                  jsr   PrintString             ; y is last val
                  iny
                  lda   ($0),y
                  beq   :done
                  tya                           ; not done so add strlen to source ptr
                  clc
                  adc   $0
                  sta   $0
                  bcc   :nocarry
                  inc   $1
:nocarry          bra   :loop


:done             rts



_printstringsx_horiz db 00






LOG               MAC
                  lda   #]1
                  ldy   #>]1
                  jsr   ConsoleLog
                  <<<

_consoleBottom    =     #23
* Write out to console window
ConsoleLog        pha
                  phy
                  lda   #0                      ;settings to bottom-left of window
                  sta   $24
                  lda   #_consoleBottom-1
                  sta   $25
                  jsr   VTAB
                  lda   #$8D                    ;pre-fix CR
                  jsr   COUT
                  ply
                  pla
                  jsr   PrintString
                  rts

* Set console windowing
WinConsole        lda   #3
                  sta   $20                     ;left edge
                  lda   #75
                  sta   $21                     ;width
                  lda   #17
                  sta   $22                     ;top edge
                  lda   #_consoleBottom
                  sta   $23                     ;bottom edge
                  rts

* Set info windowing
WinInfo           lda   #52
                  sta   $20                     ;left edge
                  lda   #26
                  sta   $21                     ;width
                  lda   #5
                  sta   $22                     ;top edge
                  lda   #16
                  sta   $23                     ;bottom edge
                  rts

* Restore full screen windowing
WinFull           stz   $20
                  stz   $22
                  lda   #80
                  sta   $21
                  lda   #24
                  sta   $23
                  rts

CharToUpper       cmp   #"z"
                  bcs   :notLower
                  cmp   #"a"
                  bcc   :notLower
                  sec
                  sbc   #$20                    ;sub 32 to get upper char
:notLower         rts

CharToLower       cmp   #"Z"
                  bcs   :notUpper
                  cmp   #"A"
                  bcc   :notUpper
                  clc
                  adc   #$20                    ;add 32 to get lower char
:notUpper         rts
