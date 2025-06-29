; This uses my ProDOS8 relocator from daglib/src/rel.8

* ]1 = src location
* ]2 = dst location
* ]3 = len in bytes
Relocate          MAC
                  lda   #]1
                  sta   $00
                  lda   #>]1
                  sta   $01
                  lda   #]2
                  sta   $02
                  lda   #>]2
                  sta   $03


                  lda   #]3
                  sta   _finalpage+1             ;leftover bytes
                  lda   #>]3
                  sta   _pageloop+1
                  inc
                  sta   _pastend+1               ;lame final check


                  ldx   #0                       ; page counter
_pageloop         cpx   #$00                     ; <- THIS IS OVERWRITTEN ABOVE
                  bne   _notfinalpage
_finalpage        ldy   #$00                     ; <- THIS IS OVERWRITTEN ABOVE
                  bra   _quickloop
_notfinalpage     ldy   #$FF                     ; full page
_quickloop        lda   ($00),y
                  sta   ($02),y
                  dey
                  cpy   #$FF                     ;argh.
                  bne   _quickloop
                  inc   $1
                  inc   $3
                  inx
_pastend          cpx   #$00                     ; <- THIS IS OVERWRITTEN ABOVE
                  bcc   _pageloop
                  <<<
