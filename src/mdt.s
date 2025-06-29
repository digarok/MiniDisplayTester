****************************************
* MiniDisplayTester                    *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  (c) 2015-2025                       *
****************************************

                        use relocate
                        org $2000
* start at $2000 (all ProDOS8 system files), then immediately relocate
* our program to $4000 to free up the hires page 1
                        Relocate _PGMSTART_PREMOVE;_PGMSTART;_PGMTOTAL
                        jmp _PGMSTART


_PGMSTART_PREMOVE
                        org $4000
_PGMSTART               =   *                       ; so we are relocating to $4000

Init
                        lda #$20                    ; set page address $20xx
                        sta HPAG                    ; for hires page 1
                        jsr ModeText40

* Main Menu loop begin2
*
Main
:menuLoop
:menuNoDrawLoop         jsr CheckKey
                        bcc :menuNoDrawLoop         ;hmm?
                        jsr MenuKeyPressed
                        clc
                        bcc :menuNoDrawLoop


MenuKeyPressed          sta MAIN_KEY_HIT            ; will be called with CharToUpper(key) in A
                        ldx #0
:scan_key_table_loop    lda MAIN_KEY_TABLE,x
                        beq :key_not_found          ; hit end of table marker
                        cmp MAIN_KEY_HIT            ; matches key hit?
                        beq :key_found              ; yes, branch
                        inx                         ; no, check next value in table
                        bne :scan_key_table_loop    ; BRA
:key_found              txa                         ; index
                        asl                         ; 6502 jmp table routine
                        tax                         ; ...
                        lda MAIN_KEY_JUMP_TABLE+1,X ; ...
                        pha                         ; push it on stack
                        lda MAIN_KEY_JUMP_TABLE,X   ; ...
                        pha                         ; push second byte of address(-1) on stack
                        rts                         ; and return (jmp)
:key_not_found          GOXY #19;#1
                        lda MAIN_KEY_HIT
                        jsr PRBYTE                  ; $FDDA
                        rts


MAIN_KEY_HIT            db  0                       ; store last key hit in buffer
MAIN_KEY_TABLE          asc "Q","1","2","3"
                        asc "4","5","6","7"
                        asc "8","9","[","]"
                        asc "=",00
MAIN_KEY_JUMP_TABLE     da  Quit-1,ModeText40-1,ModeText80-1,ModeLores-1
                        da  ModeDoubleLores-1,ModeHires-1,ModeDoubleHires-1,ModeSuperHires320-1
                        da  ModeSuperHires640-1,ModeBorderTest-1,ModeBGColor-1,ModeFGColor-1
                        da  ModeBorderColor-1



* Current display screen for each mode
ModeText_CURDISP        db  0
ModeLores_CURDISP       db  0
ModeDoubleLores_CURDISP db  0
ModeHires_CURDISP       db  0
ModeDoubleHires_CURDISP db  0

* Key "1" hit!
ModeText40              jsr SetModeText40
                        jsr ResetDrawChar

                        lda ModeText_CURDISP
                        beq :mode0
                        cmp #1
                        beq :mode1
                        cmp #2
                        beq :mode2
                        cmp #3
                        beq :mode3
                        cmp #4
                        beq :mode4

:mode0                  jsr PrintMenu
                        jmp :done
:mode1                  jsr PrintBorderBoxes40
                        jmp :done
:mode2                  jsr Print4_3Box
                        jmp :done
:mode3                  jsr PrintCharTest
                        jsr PrintRegularChar
                        jmp :done
:mode4                  sta SETALTCH
                        jsr PrintCharTest
                        jsr PrintAltChar
                        jmp :done

:done                   INCROLLOVER ModeText_CURDISP;#5
                        rts



* Key "2" hit!
ModeText80              jsr SetModeText80
                        jsr ResetDrawChar

                        lda ModeText_CURDISP
                        beq :mode0
                        cmp #1
                        beq :mode1
                        cmp #2
                        beq :mode2
                        cmp #3
                        beq :mode3
                        cmp #4
                        beq :mode4

:mode0                  jsr PrintMenu
                        jmp :done
:mode1                  jsr PrintBorderBoxes80
                        jmp :done
:mode2                  jsr Print4_3Box80
                        jmp :done
:mode3                  jsr PrintCharTest
                        jsr PrintRegularChar
                        jmp :done
:mode4                  sta SETALTCH
                        jsr PrintCharTest
                        jsr PrintAltChar
                        jmp :done

:done                   INCROLLOVER ModeText_CURDISP;#5
                        rts

* Key "3" hit!
ModeLores               jsr SetModeLores
                        sta MIXCLR                  ; turn off mix mode by default
                        lda ModeLores_CURDISP
                        beq :mode0
                        cmp #1
                        beq :mode1
                        cmp #2
                        beq :mode2
                        cmp #3
                        beq :mode3
                        cmp #4
                        beq :mode4
:mode0                  jsr DrawLoresChart1
                        jmp :done
:mode1                  jsr DrawLoresChart2
                        jmp :done
:mode2                  jsr DrawLoresMix1
                        jmp :done
:mode3                  jsr DrawLoresMix2
                        jmp :done
:mode4                  jsr DrawLoresMixLabel
                        jmp :done

:done                   INCROLLOVER ModeLores_CURDISP;#5
                        rts

* Key "4" hit!
ModeDoubleLores         jsr SetModeDoubleLores
                        sta MIXCLR                  ; turn off mix mode by default

                        lda ModeDoubleLores_CURDISP
                        beq :mode0
                        cmp #1
                        beq :mode1
                        cmp #2
                        beq :mode2
:mode0
                        jsr DrawDoubleLoresChart1
                        jmp :done
:mode1
                        jsr DrawLoresChart2
                        jmp :done
:mode2
                        jsr DrawDoubleLoresMix1
                        jmp :done

:done                   INCROLLOVER ModeDoubleLores_CURDISP;#3
                        rts

* Key "5" hit!
ModeHires               jsr SetModeHires
                        sta TXTPAGE1

                        lda ModeHires_CURDISP
                        beq :mode0
                        cmp #1
                        beq :mode1
                        cmp #2
                        beq :mode2
                        cmp #3
                        beq :mode3
:mode0                  sta MIXCLR
                        jsr HiresFun3
                        jmp :done
:mode1                  sta MIXCLR
                        jsr HiresFun4
                        jmp :done



:mode2                  sta MIXSET
                        sta CLR80COL
                        sta CLR80VID
                        jsr HiresFun4
                        jsr ClearDLo4
                        PRINTXYSTRING #2;#21;MSG_HIRES_MIX_40
                        jsr DrawMixedLineNum
                        jmp :done

:mode3                  sta MIXSET
                        sta SET80VID
                        sta SET80COL
                        jsr HiresFun4
                        jsr ClearDLo4
                        PRINTXYSTRING #20;#21;MSG_HIRES_MIX_80
                        jsr DrawMixedLineNum

:done                   INCROLLOVER ModeHires_CURDISP;#4

                        rts

* Key "6" hit!
ModeDoubleHires         jsr SetModeDoubleHires

                        lda ModeDoubleHires_CURDISP
                        beq :mode0
                        cmp #1
                        beq :mode1
                        cmp #2
                        beq :mode2
                        cmp #3
                        beq :mode3

:mode0                  sta MIXCLR
                        sta TXTPAGE2
                        jsr HiresFun3
                        sta TXTPAGE1
                        jsr HiresFun3
                        beq :done
:mode1                  sta MIXCLR
                        sta TXTPAGE2
                        jsr HiresFun5
                        sta TXTPAGE1
                        jsr HiresFun5
                        beq :done


:mode2                  sta MIXSET
                        sta TXTPAGE2
                        jsr HiresFun5
                        sta TXTPAGE1
                        jsr HiresFun5
                        sta SET80VID
                        sta SET80COL
                        jsr ClearDLo4
                        PRINTXYSTRING #20;#21;MSG_DBLHIRES_MIX_80
                        jsr DrawMixedLineNum
                        bne :done

:mode3                  sta MIXSET
                        sta TXTPAGE2
                        jsr HiresFun5
                        sta TXTPAGE1
                        jsr HiresFun5
                        sta SET80VID
                        sta SET80COL
                        jsr ClearDLo4
                        PRINTXYSTRING #2;#20;MSG_DBLHIRES_80_LBL


:done                   INCROLLOVER ModeDoubleHires_CURDISP;#4

                        rts

* Key "7" hit!
ModeSuperHires320       jsr SetModeSuperHires320
                        jsr SHRCLEARMEM
                        jsr DrawSHR320SCBs
                        jsr SHRSTRIPES
                        jsr DrawCurrentPalette
                        jsr IncPal
                        rts

* Key "8" hit!
ModeSuperHires640       jsr SetModeSuperHires640
                        jsr SHRCLEARMEM
                        jsr DrawSHR640SCBs
                        jsr SHRSTRIPES
                        jsr DrawCurrentPalette
                        jsr IncPal
                        rts
_lastcolor              db  0

* Key "9" hit!
ModeBorderTest
                        lda $c034
                        pha
:loop
                        lda KEY
                        bpl :nokey
                        sta STROBE
                        jmp :done
:nokey                  lda $c02e
                        cmp _lastcolor
                        beq :nokey
                        sta _lastcolor
                        and #$0F
                        nop
                        nop
                        sta $c034
                        jmp :loop
:done                   pla
                        sta $c034
                        rts

* Key "[" hit!
ModeBGColor             lda GSTEXT
                        tax
                        lda #$0F
                        trb GSTEXT
                        inx                         ; +1
                        txa
                        and #$0F
                        tsb GSTEXT
                        rts

* Key "]" hit!
ModeFGColor             lda GSTEXT
                        clc
                        adc #$10                    ; +1 (high nibble)
                        sta GSTEXT
                        rts

* Key "=" hit!
ModeBorderColor         lda GSBORDER
                        tax
                        lda #$0F
                        trb GSBORDER
                        inx                         ; +1
                        txa
                        and #$0F
                        tsb GSBORDER
                        rts



SetModeText40           jsr SHROFF
                        sta TXTSET
                        lda #" "                    ;omg weird.. this turns on, output ctrl-U to turn off (21)"
                        jsr $c300
                        sta C80STOREOFF
                        lda #$95
                        jsr COUT
                        sta CLR80COL
                        sta CLR80VID
                        rts

SetModeText80           jsr SHROFF
                        sta TXTSET
                        lda #" "                    ;omg weird.. this turns on, output ctrl-U to turn off (21)"
                        jsr $c300
                        sta SET80COL
                        sta SET80VID
                        rts

SetModeLores            jsr SHROFF
                        lda #$95
                        jsr COUT
                        sta LORES
                        sta TXTCLR                  ; turn on graphics
                        lda SETAN3
                        sta CLR80VID                ; turn 80 off
                        rts

SetModeDoubleLores      jsr SHROFF
                        lda LORES                   ; set lores
                        sta TXTCLR
                        lda CLRAN3                  ; enables DLR
                        sta SET80VID
                        sta C80STOREON              ; enable aux/page1,2 mapping
                        sta MIXCLR                  ; make sure graphics-only mode
                        rts

SetModeHires            jsr SHROFF
                        sta HIRES
                        sta TXTCLR
                        lda SETAN3                  ;no DLR
                        rts

SetModeDoubleHires      jsr SHROFF
                        sta HIRES
                        sta TXTCLR
                        lda CLRAN3                  ;enables DLR
                        sta SET80VID
                        sta C80STOREON              ; enable aux/page1,2 mapping
                        sta MIXCLR                  ;make sure graphics-only mode
                        rts

SetModeSuperHires320    jsr SHRON
                        rts
SetModeSuperHires640    jsr SHRON
                        rts

* A = val  X = Max
IncRollover             stx _checkMax+1
                        clc
                        adc #1
_checkMax               cmp #$FF                    ; this is clobbered every call
                        bcc :done
                        lda #0
:done                   rts

INCROLLOVER             MAC
                        lda ]1
                        ldx ]2
                        jsr IncRollover
                        sta ]1
                        <<<



IncPal
                        inc _curpal
                        lda _curpal
                        cmp #4
                        bcc :noroll
                        lda #1
                        sta _curpal
:noroll                 rts

SHROFF                  lda #$01
                        sta $c029
                        sta _curpal                 ;hack to reset pal between text modes... kinda pointless
                        rts

SHRON                   lda #$c1
                        sta $c029
                        rts

SHRCLEARMEM             clc
                        xce
                        rep #$30
                        lda #0
                        ldx #0
:loop                   stal $e12000,x
                        inx
                        inx
                        cpx #$8000
                        bne :loop
                        sec
                        xce
                        sep #$30
                        rts

SHRSTRIPES              clc
                        xce
                        rep #$30
                        ldx #0
:stripestart            lda #0
:stripepass             ldy #0
:loop                   stal $e12000,x
                        inx
                        inx
                        cpx #$7d00
                        bcs :done
                        iny
                        cpy #5
                        bne :loop
                        cmp #$ffff
                        beq :stripestart
:notF                   clc
                        adc #$1111
                        bra :stripepass
:done                   sec
                        xce
                        sep #$30
                        rts

DrawSHR640SCBs
                        lda #0
                        ldx #0
:loop2                  ldy #0
:loop                   ora #%10000000
                        stal $e19d00,x
                        inx
                        iny
:stretch                cpy #12
                        bne :loop

                        pha                         ;this part makes it to 12 then 13 lines.  to make avg of 12.5
                        lda :stretch+1
                        cmp #12
                        bne :is13
                        lda #13
                        bne :storestretcher
:is13                   lda #12
:storestretcher         sta :stretch+1
                        pla

                        inc
                        cpx #200
                        bcc :loop2
                        rts

DrawSHR320SCBs
                        lda #0
                        ldx #0
:loop2                  ldy #0
:loop                   stal $e19d00,x
                        inx
                        iny
:stretch                cpy #12
                        bne :loop

                        pha                         ;this part makes it to 12 then 13 lines.  to make avg of 12.5
                        lda :stretch+1
                        cmp #12
                        bne :is13
                        lda #13
                        bne :storestretcher
:is13                   lda #12
:storestretcher         sta :stretch+1
                        pla

                        inc
                        cpx #200
                        bcc :loop2
                        rts

PalTable                da  _pal1,_pal2,_pal3
_pal1
                        dw  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0F0F
                        dw  $0000,$0100,$0000,$0010,$0000,$0001,$0000,$0110,$0000,$0101,$0000,$0011,$0000,$0111,$0000,$0E1F
                        dw  $0000,$0200,$0000,$0020,$0000,$0002,$0000,$0220,$0000,$0202,$0000,$0022,$0000,$0222,$0000,$0D2E
                        dw  $0000,$0300,$0000,$0030,$0000,$0003,$0000,$0330,$0000,$0303,$0000,$0033,$0000,$0333,$0000,$0C3E
                        dw  $0000,$0400,$0000,$0040,$0000,$0004,$0000,$0440,$0000,$0404,$0000,$0044,$0000,$0444,$0000,$0B4D
                        dw  $0000,$0500,$0000,$0050,$0000,$0005,$0000,$0550,$0000,$0505,$0000,$0055,$0000,$0555,$0000,$0A5D
                        dw  $0000,$0600,$0000,$0060,$0000,$0006,$0000,$0660,$0000,$0606,$0000,$0066,$0000,$0666,$0000,$096C
                        dw  $0000,$0700,$0000,$0070,$0000,$0007,$0000,$0770,$0000,$0707,$0000,$0077,$0000,$0777,$0000,$087C
                        dw  $0000,$0800,$0000,$0080,$0000,$0008,$0000,$0880,$0000,$0808,$0000,$0088,$0000,$0888,$0000,$078B
                        dw  $0000,$0900,$0000,$0090,$0000,$0009,$0000,$0990,$0000,$0909,$0000,$0099,$0000,$0999,$0000,$069B
                        dw  $0000,$0A00,$0000,$00A0,$0000,$000A,$0000,$0AA0,$0000,$0A0A,$0000,$00AA,$0000,$0AAA,$0000,$05AA
                        dw  $0000,$0B00,$0000,$00B0,$0000,$000B,$0000,$0BB0,$0000,$0B0B,$0000,$00BB,$0000,$0BBB,$0000,$04BA
                        dw  $0000,$0C00,$0000,$00C0,$0000,$000C,$0000,$0CC0,$0000,$0C0C,$0000,$00CC,$0000,$0CCC,$0000,$03C9
                        dw  $0000,$0D00,$0000,$00D0,$0000,$000D,$0000,$0DD0,$0000,$0D0D,$0000,$00DD,$0000,$0DDD,$0000,$02D9
                        dw  $0000,$0E00,$0000,$00E0,$0000,$000E,$0000,$0EE0,$0000,$0E0E,$0000,$00EE,$0000,$0EEE,$0000,$01E8
                        dw  $0000,$0F00,$0000,$00F0,$0000,$000F,$0000,$0FF0,$0000,$0F0F,$0000,$00FF,$0000,$0FFF,$0000,$00F8

_pal2
                        dw  $0F00,$0F01,$0F12,$0F13,$0F24,$0F25,$0F36,$0F37,$0F48,$0F49,$0F5A,$0F5B,$0F6C,$0F6D,$0F7E,$0F7F
                        dw  $0E00,$0E11,$0E12,$0E23,$0E24,$0E35,$0E36,$0E47,$0E48,$0E59,$0E5A,$0E6B,$0E6C,$0E7D,$0E7E,$0E8F
                        dw  $0D10,$0D11,$0D22,$0D23,$0D34,$0D35,$0D46,$0D47,$0D58,$0D59,$0D6A,$0D6B,$0D7C,$0D7D,$0D8E,$0D8F
                        dw  $0C10,$0C21,$0C22,$0C33,$0C34,$0C45,$0C46,$0C57,$0C58,$0C69,$0C6A,$0C7B,$0C7C,$0C8D,$0C8E,$0C9F
                        dw  $0B20,$0B21,$0B32,$0B33,$0B44,$0B45,$0B56,$0B57,$0B68,$0B69,$0B7A,$0B7B,$0B8C,$0B8D,$0B9E,$0B9F
                        dw  $0A20,$0A31,$0A32,$0A43,$0A44,$0A55,$0A56,$0A67,$0A68,$0A79,$0A7A,$0A8B,$0A8C,$0A9D,$0A9E,$0AAF
                        dw  $0930,$0931,$0942,$0943,$0954,$0955,$0966,$0967,$0978,$0979,$098A,$098B,$099C,$099D,$09AE,$09AF
                        dw  $0830,$0841,$0842,$0853,$0854,$0865,$0866,$0877,$0878,$0889,$088A,$089B,$089C,$08AD,$08AE,$08BF
                        dw  $0740,$0741,$0752,$0753,$0764,$0765,$0776,$0777,$0788,$0789,$079A,$079B,$07AC,$07AD,$07BE,$07BF
                        dw  $0640,$0651,$0652,$0663,$0664,$0675,$0676,$0687,$0688,$0699,$069A,$06AB,$06AC,$06BD,$06BE,$06CF
                        dw  $0550,$0551,$0562,$0563,$0574,$0575,$0586,$0587,$0598,$0599,$05AA,$05AB,$05BC,$05BD,$05CE,$05CF
                        dw  $0450,$0461,$0462,$0473,$0474,$0485,$0486,$0497,$0498,$04A9,$04AA,$04BB,$04BC,$04CD,$04CE,$04DF
                        dw  $0360,$0361,$0372,$0373,$0384,$0385,$0396,$0397,$03A8,$03A9,$03BA,$03BB,$03CC,$03CD,$03DE,$03DF
                        dw  $0260,$0271,$0272,$0283,$0284,$0295,$0296,$02A7,$02A8,$02B9,$02BA,$02CB,$02CC,$02DD,$02DE,$02EF
                        dw  $0170,$0171,$0182,$0183,$0194,$0195,$01A6,$01A7,$01B8,$01B9,$01CA,$01CB,$01DC,$01DD,$01EE,$01EF
                        dw  $0070,$0081,$0082,$0093,$0094,$00A5,$00A6,$00B7,$00B8,$00C9,$00CA,$00DB,$00DC,$00ED,$00EE,$00FF


_pal3
                        dw  $0000,$0001,$0012,$0013,$0024,$0025,$0036,$0037,$0048,$0049,$005A,$005B,$006C,$006D,$007E,$007F
                        dw  $0100,$0111,$0112,$0123,$0124,$0135,$0136,$0147,$0148,$0159,$015A,$016B,$016C,$017D,$017E,$018F
                        dw  $0210,$0211,$0222,$0223,$0234,$0235,$0246,$0247,$0258,$0259,$026A,$026B,$027C,$027D,$028E,$028F
                        dw  $0310,$0321,$0322,$0333,$0334,$0345,$0346,$0357,$0358,$0369,$036A,$037B,$037C,$038D,$038E,$039F
                        dw  $0420,$0421,$0432,$0433,$0444,$0445,$0456,$0457,$0468,$0469,$047A,$047B,$048C,$048D,$049E,$049F
                        dw  $0520,$0531,$0532,$0543,$0544,$0555,$0556,$0567,$0568,$0579,$057A,$058B,$058C,$059D,$059E,$05AF
                        dw  $0630,$0631,$0642,$0643,$0654,$0655,$0666,$0667,$0678,$0679,$068A,$068B,$069C,$069D,$06AE,$06AF
                        dw  $0730,$0741,$0742,$0753,$0754,$0765,$0766,$0777,$0778,$0789,$078A,$079B,$079C,$07AD,$07AE,$07BF
                        dw  $0840,$0841,$0852,$0853,$0864,$0865,$0876,$0877,$0888,$0889,$089A,$089B,$08AC,$08AD,$08BE,$08BF
                        dw  $0940,$0951,$0952,$0963,$0964,$0975,$0976,$0987,$0988,$0999,$099A,$09AB,$09AC,$09BD,$09BE,$09CF
                        dw  $0A50,$0A51,$0A62,$0A63,$0A74,$0A75,$0A86,$0A87,$0A98,$0A99,$0AAA,$0AAB,$0ABC,$0ABD,$0ACE,$0ACF
                        dw  $0B50,$0B61,$0B62,$0B73,$0B74,$0B85,$0B86,$0B97,$0B98,$0BA9,$0BAA,$0BBB,$0BBC,$0BCD,$0BCE,$0BDF
                        dw  $0C60,$0C61,$0C72,$0C73,$0C84,$0C85,$0C96,$0C97,$0CA8,$0CA9,$0CBA,$0CBB,$0CCC,$0CCD,$0CDE,$0CDF
                        dw  $0D60,$0D71,$0D72,$0D83,$0D84,$0D95,$0D96,$0DA7,$0DA8,$0DB9,$0DBA,$0DCB,$0DCC,$0DDD,$0DDE,$0DEF
                        dw  $0E70,$0E71,$0E82,$0E83,$0E94,$0E95,$0EA6,$0EA7,$0EB8,$0EB9,$0ECA,$0ECB,$0EDC,$0EDD,$0EEE,$0EEF
                        dw  $0F70,$0F81,$0F82,$0F93,$0F94,$0FA5,$0FA6,$0FB7,$0FB8,$0FC9,$0FCA,$0FDB,$0FDC,$0FED,$0FEE,$0FFF

_curpal                 db  1

DrawPresetPalette1      clc
                        xce
                        rep #$30

                        ldx #0
:loop                   lda _pal1,x
                        stal $e19e00,x
                        inx
                        inx
                        cpx #$200
                        bne :loop
                        sec
                        xce
                        sep #$30
                        rts

DrawCurrentPalette      lda _curpal                 ;
                        dec                         ;table is at 0 so pal--
                        asl                         ;
                        tax                         ;
                        lda PalTable,x              ;patch code to point to palette
                        sta :loop+1                 ;
                        lda PalTable+1,x            ;
                        sta :loop+2                 ;

                        clc                         ;16-bit for copy
                        xce
                        rep #$30


                        ldx #0
:loop                   lda _pal2,x
                        stal $e19e00,x
                        inx
                        inx
                        cpx #$200
                        bne :loop
                        sec
                        xce
                        sep #$30
                        rts


PrintRegularChar        bit RD80VID
                        bmi :pr80
:pr40                   PRINTXYSTRING #9;#17;MSG_REGULAR_CHARSET
                        rts
:pr80                   PRINTXYSTRING #29;#17;MSG_REGULAR_CHARSET
                        rts

PrintAltChar            bit RD80VID
                        bmi :pr80
:pr40                   PRINTXYSTRING #8;#17;MSG_ALT_CHARSET
                        rts
:pr80                   PRINTXYSTRING #28;#17;MSG_ALT_CHARSET
                        rts

PrintCharTest

                        bit RD80VID
                        bpl :40col

:80col                  BOX #0;#0;#79;#23
                        ldy #22                     ; actual x
                        sta TXTPAGE2
                        tya
                        lsr
                        tax
                        inx
                        bne :initchar               ; BRA

:40col                  BOX #0;#0;#39;#23
                        ldx #4
:initchar               lda #0

:charloop               sta Lo06,x                  ;1
                        ora #%00100000
                        sta Lo07,x                  ;2
                        and #%11011111
                        ora #%01000000
                        sta Lo08,x                  ;3
                        ora #%01100000
                        sta Lo09,x                  ;4
                        and #%10011111
                        ora #%10000000
                        sta Lo10,x                  ;5
                        ora #%10100000
                        sta Lo11,x                  ;6
                        and #%11011111
                        ora #%11000000
                        sta Lo12,x                  ;7
                        ora #%11100000
                        sta Lo13,x                  ;8
                        and #%00011111
                        bit RD80VID
                        bpl :40col_next

:80col_next             pha
                        iny
                        tya
                        lsr
                        bcc :even
:odd                    sta TXTPAGE1
                        bcs :80col_fin
:even                   sta TXTPAGE2
:80col_fin              tax
                        pla

:40col_next             inx

:next                   clc
                        adc #1
                        cmp #32
                        bcc :charloop
                        rts



PrintBorderBoxes40
                        lda #0
                        sta BOX_X1
                        sta BOX_Y1
                        lda #39
                        sta BOX_X2
                        lda #23
                        sta BOX_Y2
:boxloop                jsr PrintBox
                        lda BOX_Y1
                        cmp #20/2
                        bcs :printMessage
                        clc
                        adc #2
                        sta BOX_X1
                        sta BOX_Y1
                        dec BOX_X2
                        dec BOX_X2
                        dec BOX_Y2
                        dec BOX_Y2
                        jmp :boxloop
:printMessage           PRINTXYSTRING #12;#11;MSG_BORDER_EDGE
                        PRINTXYSTRING #16;#12;MSG_RES_LO
                        rts


PrintBorderBoxes80
                        lda #0
                        sta BOX_X1
                        sta BOX_Y1
                        lda #79
                        sta BOX_X2
                        lda #23
                        sta BOX_Y2
:boxloop                jsr PrintBox
                        lda BOX_Y1
                        cmp #16/2                   ; 16/2
                        bcs :printMessage
                        clc
                        adc #2
                        sta BOX_X1
                        sta BOX_Y1
                        dec BOX_X2
                        dec BOX_X2
                        dec BOX_Y2
                        dec BOX_Y2
                        jmp :boxloop
:printMessage           PRINTXYSTRING #32;#11;MSG_BORDER_EDGE
                        PRINTXYSTRING #36;#12;MSG_RES_HI
                        rts


Print4_3Box             BOX #2;#0;#37;#23
:printMessage           PRINTXYSTRING #11;#11;MSG_BORDER_4_3
                        PRINTXYSTRING #16;#12;MSG_RES_40_4_3
                        rts

Print4_3Box80           BOX #4;#0;#75;#23
:printMessage           PRINTXYSTRING #31;#11;MSG_BORDER_4_3
                        PRINTXYSTRING #36;#12;MSG_RES_80_4_3
                        rts

DrawLoresChart2         lda #0
                        jsr LoresFillScreen

                        lda #$FF
                        sta DRAWCHAR

                        lda #0
                        sta BOX_X1
                        sta BOX_Y1
                        bit RD80VID
                        bmi :80col
:40col                  lda #39
                        bpl :storeX2
:80col                  lda #79
:storeX2                sta BOX_X2
                        lda #23
                        sta BOX_Y2
:boxloop                jsr PrintBox
                        lda DRAWCHAR                ; \
                        sec                         ;  \_  2-nibble DRAWCHAR++
                        sbc #$11                    ;  /
                        sta DRAWCHAR                ; /
                        lda BOX_Y1
                        cmp #15                     ; iterations to get all colors (minus black)
                        bcs :boxDone


                        clc
                        adc #1
                        sta BOX_X1
                        sta BOX_Y1
                        dec BOX_X2

                        dec BOX_Y2
                        jmp :boxloop
:boxDone
                        rts

DrawLoresMix1
                        lda #$55
                        jsr LoresFillScreen
                        jsr DrawLoresBars
                        sta MIXSET
                        jsr ClearLo4
                        PRINTXYSTRING #2;#21;MSG_LORES_MIX_40
                        jsr DrawMixedLineNum
                        rts

ClearDLo4               sta TXTPAGE2
                        jsr ClearLo4
                        sta TXTPAGE1
                        jmp ClearLo4

ClearLo4                lda #" "
                        ldx #23
                        jsr LoresHlinX
                        dex
                        jsr LoresHlinX
                        dex
                        jsr LoresHlinX
                        dex
                        jsr LoresHlinX
                        rts

DrawLoresMix2
                        lda #$55
                        jsr LoresFillScreen
                        jsr DrawLoresBars
                        sta MIXSET
                        sta SET80VID
                        sta SET80COL
                        jsr ClearDLo4
                        PRINTXYSTRING #20;#21;MSG_LORES_MIX_80
                        jsr DrawMixedLineNum
                        rts

DrawLoresMixLabel
                        lda #$00
                        jsr LoresFillScreen
                        jsr DrawLoresBars2
                        sta MIXSET
                        jsr ClearDLo4
                        PRINTXYSTRING #1;#20;MSG_LORES_MIX_40_LBL
                        PRINTXYSTRING #5;#21;MSG_LORES_MIX_40_LBL2
                        rts

DrawDoubleLoresMix1
                        lda #$55
                        jsr DoubleLoresFillScreen
                        jsr DrawDoubleLoresBars
                        sta MIXSET
                        jsr ClearDLo4
                        PRINTXYSTRING #20;#21;MSG_DBLLORES_MIX_80
                        jsr DrawMixedLineNum
                        rts

DrawMixedLineNum        bit RD80VID
                        bpl :40col1
                        sta TXTPAGE2
:40col1                 lda #"1"
                        sta Lo20
                        lda #"2"
                        sta Lo21
                        lda #"3"
                        sta Lo22
                        lda #"4"
                        sta Lo23
                        bit RD80VID
                        bpl :40col2
                        sta TXTPAGE1
:40col2                 lda #"1"
                        sta Lo20+#39
                        lda #"2"
                        sta Lo21+#39
                        lda #"3"
                        sta Lo22+#39
                        lda #"4"
                        sta Lo23+#39
                        rts

                                                    ; main aux colors mapping
                                                    ; 0  => 0,
                                                    ;    1  => 8,
                                                    ;    2  => 1,
                                                    ;    3  => 9,
                                                    ;    4  => 2,
                                                    ;    5  => 10,
                                                    ;    6  => 3,
                                                    ;    7  => 11,
                                                    ;    8  => 4,
                                                    ;    9  => 12,
                                                    ;    10 => 5,
                                                    ;    11 => 13,
                                                    ;    12 => 6,
                                                    ;    13 => 14,
                                                    ;    14 => 7,
                                                    ;    15 => 15
                        *   color,                  x
DrawDoubleLoresBars     sta TXTPAGE2
                        lda #$11                    ; dk blue
                        ldx #2
                        jsr LoresVlinX
                        ldx #37
                        jsr LoresVlinX
                        sta TXTPAGE1
                        lda #$66                    ; blue
                        ldx #2
                        jsr LoresVlinX
                        ldx #37
                        jsr LoresVlinX
                        sta TXTPAGE2
                        lda #$bb                    ; l blue
                        ldx #3
                        jsr LoresVlinX
                        ldx #38
                        jsr LoresVlinX

                        sta TXTPAGE2
                        lda #$22                    ; dk grn
                        ldx #8
                        jsr LoresVlinX
                        ldx #31
                        jsr LoresVlinX
                        sta TXTPAGE1
                        lda #$cc                    ; grn
                        ldx #8
                        jsr LoresVlinX
                        ldx #31
                        jsr LoresVlinX
                        sta TXTPAGE2
                        lda #$77                    ; grn
                        ldx #9
                        jsr LoresVlinX
                        ldx #32
                        jsr LoresVlinX

                        sta TXTPAGE1
                        lda #$11                    ; dk grn
                        ldx #14
                        jsr LoresVlinX
                        ldx #24
                        jsr LoresVlinX
                        sta TXTPAGE2
                        lda #$cc                    ; grn
                        ldx #15
                        jsr LoresVlinX
                        ldx #25
                        jsr LoresVlinX
                        sta TXTPAGE1
                        lda #$dd                    ; grn
                        ldx #15
                        jsr LoresVlinX
                        ldx #25
                        jsr LoresVlinX

                        rts


* color, x
DrawLoresBars           lda #$22                    ; dk blue
                        ldx #0
                        jsr LoresVlinX
                        ldx #37
                        jsr LoresVlinX
                        lda #$66                    ; blue
                        ldx #1
                        jsr LoresVlinX
                        ldx #38
                        jsr LoresVlinX
                        lda #$77                    ; l blue
                        ldx #2
                        jsr LoresVlinX
                        ldx #39
                        jsr LoresVlinX

                        lda #$44                    ; dk grn
                        ldx #7
                        jsr LoresVlinX
                        ldx #30
                        jsr LoresVlinX
                        lda #$cc                    ; grn
                        ldx #8
                        jsr LoresVlinX
                        ldx #31
                        jsr LoresVlinX
                        lda #$ee                    ; grn
                        ldx #9
                        jsr LoresVlinX
                        ldx #32
                        jsr LoresVlinX


                        lda #$11                    ; dk grn
                        ldx #14
                        jsr LoresVlinX
                        ldx #22
                        jsr LoresVlinX
                        lda #$99                    ; grn
                        ldx #15
                        jsr LoresVlinX
                        ldx #23
                        jsr LoresVlinX
                        lda #$dd                    ; grn
                        ldx #16
                        jsr LoresVlinX
                        ldx #24
                        jsr LoresVlinX

                        rts


DrawLoresBars2          lda #$00                    ; start: a=black, x=x pos 5, y=loop counter 0
                        tay
                        ldx #4

:loop                   jsr LoresVlinX
                        inx
                        iny
                        cpy #1
                        bne :loop                   ; next column, same color
                        ldy #0
                        inx                         ; skip column
                        clc
                        adc #$11                    ; next color
                        bcc :loop                   ; or done

                        rts



DrawLoresChart1
                        lda #0
                        jsr LoresFillScreen
                        jsr LoresPattern
                        jsr LoresPattern2
                        lda #$11
                        ldx #0
                        jsr LoresVlinX
                        ldx #39
                        jsr LoresVlinX
                        ldx #0
                        jsr LoresHlinX
                        ldx #23
                        jsr LoresHlinX
                        rts

DrawDoubleLoresChart1
                        lda #0
                        jsr DoubleLoresFillScreen
                        lda #$01
                        ldy #0
                        jsr DL_Hline
                        lda #$10
                        ldy #23
                        jsr DL_Hline
                        sta TXTPAGE2
                        ldx #$11
                        lda MainAuxMap,x
                        ldx #0
                        jsr LoresVlinX
                        jsr LoresPattern
                        sta TXTPAGE1
                        lda #$11
                        ldx #39
                        jsr LoresVlinX
                        jsr LoresPattern
                        jsr LoresPattern2
                        rts

LoresPattern            ldx #$0C
                        lda #$11
:patternloop            sta Lo03,x
                        sta Lo04,x
                        sta Lo05,x
                        sta Lo06,x
                        sta Lo07,x
                        inx
                        cmp #$ff
                        beq :done
                        clc
                        adc #$11
                        bne :patternloop
:done                   rts

LoresPattern2           ldx #$05
                        lda #$11
:patternloop2           sta Lo13,x
                        sta Lo14,x
                        sta Lo15,x
                        sta Lo16,x
                        sta Lo17,x
                        inx
                        inx
                        cmp #$ff
                        beq :done
                        clc
                        adc #$11
                        bne :patternloop2
:done                   rts

** A = lo-res color byte
DoubleLoresFillScreen
                        ldx #39
:storeloop              sta TXTPAGE1
                        jsr LoresVlinX
                        tay                         ; switch colors
                        lda MainAuxMap,y
                        sta TXTPAGE2
                        jsr LoresVlinX
                        tya                         ; switch back
                        dex
                        bpl :storeloop
                        rts

** A = lo-res color byte
LoresFillScreen
                        ldx #39
:storeloop              jsr LoresVlinX
                        dex
                        bpl :storeloop
                        rts

LoresVlinX
                        sta Lo00,x
                        sta Lo01,x
                        sta Lo02,x
                        sta Lo03,x
                        sta Lo04,x
                        sta Lo05,x
                        sta Lo05,x
                        sta Lo05,x
                        sta Lo06,x
                        sta Lo07,x
                        sta Lo08,x
                        sta Lo09,x
                        sta Lo10,x
                        sta Lo11,x
                        sta Lo12,x
                        sta Lo13,x
                        sta Lo14,x
                        sta Lo15,x
                        sta Lo16,x
                        sta Lo17,x
                        sta Lo18,x
                        sta Lo19,x
                        sta Lo20,x
                        sta Lo21,x
                        sta Lo22,x
                        sta Lo23,x
                        rts

LoresHlinX              pha
                        lda LoLineTableL,x
                        sta $0
                        lda LoLineTableH,x
                        sta $1
                        ldy #39
                        pla
:loop                   sta ($0),y
                        dey
                        bpl :loop
                        rts

LoLineTable             da  Lo00,Lo01,Lo02,Lo03,Lo04,Lo05
                        da  Lo06,Lo07,Lo08,Lo09,Lo10,Lo11
                        da  Lo12,Lo13,Lo14,Lo15,Lo16,Lo17
                        da  Lo18,Lo19,Lo20,Lo21,Lo22,Lo23
** Here we split the table for an optimization
** We can directly get our line numbers now
** Without using ASL
LoLineTableH            db  >Lo00,>Lo01,>Lo02,>Lo03,>Lo04,>Lo05
                        db  >Lo06,>Lo07,>Lo08,>Lo09,>Lo10,>Lo11
                        db  >Lo12,>Lo13,>Lo14,>Lo15,>Lo16,>Lo17
                        db  >Lo18,>Lo19,>Lo20,>Lo21,>Lo22,>Lo23
LoLineTableL            db  <Lo00,<Lo01,<Lo02,<Lo03,<Lo04,<Lo05
                        db  <Lo06,<Lo07,<Lo08,<Lo09,<Lo10,<Lo11
                        db  <Lo12,<Lo13,<Lo14,<Lo15,<Lo16,<Lo17
                        db  <Lo18,<Lo19,<Lo20,<Lo21,<Lo22,<Lo23

MainAuxMap
                        hex 00,08,01,09,02,0A,03,0B,04,0C,05,0D,06,0E,07,0F
                        hex 80,88,81,89,82,8A,83,8B,84,8C,85,8D,86,8E,87,8F
                        hex 10,18,11,19,12,1A,13,1B,14,1C,15,1D,16,1E,17,1F
                        hex 90,98,91,99,92,9A,93,9B,94,9C,95,9D,96,9E,97,9F
                        hex 20,28,21,29,22,2A,23,2B,24,2C,25,2D,26,2E,27,2F
                        hex A0,A8,A1,A9,A2,AA,A3,AB,A4,AC,A5,AD,A6,AE,A7,AF
                        hex 30,38,31,39,32,3A,33,3B,34,3C,35,3D,36,3E,37,3F
                        hex B0,B8,B1,B9,B2,BA,B3,BB,B4,BC,B5,BD,B6,BE,B7,BF
                        hex 40,48,41,49,42,4A,43,4B,44,4C,45,4D,46,4E,47,4F
                        hex C0,C8,C1,C9,C2,CA,C3,CB,C4,CC,C5,CD,C6,CE,C7,CF
                        hex 50,58,51,59,52,5A,53,5B,54,5C,55,5D,56,5E,57,5F
                        hex D0,D8,D1,D9,D2,DA,D3,DB,D4,DC,D5,DD,D6,DE,D7,DF
                        hex 60,68,61,69,62,6A,63,6B,64,6C,65,6D,66,6E,67,6F
                        hex E0,E8,E1,E9,E2,EA,E3,EB,E4,EC,E5,ED,E6,EE,E7,EF
                        hex 70,78,71,79,72,7A,73,7B,74,7C,75,7D,76,7E,77,7F
                        hex F0,F8,F1,F9,F2,FA,F3,FB,F4,FC,F5,FD,F6,FE,F7,FF


** A = lo-res color byte  Y = line byte (0-23)
DL_Hline                tax
                        lda LoLineTableL,y
                        sta $0
                        lda LoLineTableH,y
                        sta $0+1
                        txa

                        sta TXTPAGE1
                        ldy #39
:loopMain               sta ($0),y
                        dey
                        bpl :loopMain

                        sta TXTPAGE2
                        tax
                        lda MainAuxMap,x
                        ldy #39
:loopAux                sta ($0),y
                        dey
                        bpl :loopAux
                        rts





PrintMenu               jsr HOME
                        PRINTXYSTRING #2;#2;MSG_MENU1
                        PRINTXYSTRING #2;#3;MSG_MENU2
                        PRINTXYSTRING #2;#4;MSG_MENU3
                        PRINTXYSTRING #2;#5;MSG_MENU4
                        PRINTXYSTRING #2;#6;MSG_MENU5
                        PRINTXYSTRING #2;#7;MSG_MENU6
                        PRINTXYSTRING #2;#8;MSG_MENU7
                        PRINTXYSTRING #2;#9;MSG_MENU8
                        PRINTXYSTRING #2;#10;MSG_MENU9
                        PRINTXYSTRING #2;#12;MSG_MENU10
                        PRINTXYSTRING #2;#13;MSG_MENU11
                        PRINTXYSTRING #2;#14;MSG_MENU12
                        PRINTXYSTRING #2;#16;MSG_MENUQ
                        PRINTXYSTRING #10;#20;MSG_INFO1
                        PRINTXYSTRING #2;#21;MSG_INFO2
                        PRINTXYSTRING #6;#23;MSG_INFO3
                        bit RD80VID
                        bmi :80col
:40col                  PRINTXYSTRING #24;#2;MSG_THIS
                        rts
:80col                  PRINTXYSTRING #24;#3;MSG_THIS
                        rts


MSG_THIS                asc "(THIS)",00
MSG_MENU1               asc "1.  40-COLUMN MODE ",00
MSG_MENU2               asc "2.  80-COLUMN MODE ",00
MSG_MENU3               asc "3.  LORES MODE ",00
MSG_MENU4               asc "4.  DOUBLE LORES MODE ",00
MSG_MENU5               asc "5.  HIRES MODE ",00
MSG_MENU6               asc "6.  DOUBLE HIRES MODE ",00
MSG_MENU7               asc "7.  SUPER HIRES 320 MODE",00
MSG_MENU8               asc "8.  SUPER HIRES 640 MODE",00
MSG_MENU9               asc "9.  BORDER COLOR TEST",00


MSG_MENU10              asc "[.  GS BACKGROUND COLOR",00
MSG_MENU11              asc "].  GS FOREGROUND COLOR",00
MSG_MENU12              asc "=.  GS BORDER COLOR",00

MSG_MENUQ               asc "Q.  QUIT",00
MSG_INFO1               asc "MINI DISPLAY TESTER",00
MSG_INFO2               asc "GITHUB.COM/DIGAROK/MINIDISPLAYTESTER",00
MSG_INFO3               asc "(C)2015 - 2025 DAGEN BROCK",00

MSG_REGULAR_CHARSET     asc "REGULAR CHARACTER SET",00
MSG_ALT_CHARSET         asc "ALTERNATE CHARACTER SET",00
MSG_BORDER_EDGE         asc "BORDER-TO-BORDER",00
MSG_RES_LO              asc "40 X 24",00
MSG_RES_HI              asc "80 X 24",00
MSG_BORDER_4_3          asc "ASPECT RATIO ~ 4:3",00
MSG_RES_40_4_3          asc "36 X 24",00
MSG_RES_80_4_3          asc "72 X 24",00
MSG_LORES_MIX_40        asc "LORES MIXED MODE WITH 40-COLUMN TEXT",00
MSG_LORES_MIX_80        asc "LORES MIXED MODE WITH 80-COLUMN TEXT",00
MSG_LORES_MIX_40_LBL    asc "BLK   DBL DGN BLU BRN LGY GRN LGN   BLK",00
MSG_LORES_MIX_40_LBL2   asc "RED PUR GRY LBL ORN PNK YEL WHT",00
MSG_DBLLORES_MIX_80     asc "DOUBLE LORES MIXED MODE WITH 80-COLUMN TEXT",00
MSG_HIRES_MIX_40        asc "HIRES MIXED MODE WITH 40-COLUMN TEXT",00
MSG_HIRES_MIX_80        asc "HIRES MIXED MODE WITH 80-COLUMN TEXT",00
MSG_DBLHIRES_MIX_80     asc "DOUBLE HIRES MIXED MODE WITH 80-COLUMN TEXT",00
MSG_DBLHIRES_80_LBL     asc "Blk  Gry  Brn DBlu Blu  Grn Orng Red Pnk  Yel LGrn Aqua Pur Cyan LGy Wht ",00

HiresY00                da  $2000
HiresY01                da  $2400
HiresY02                da  $2080
HiresY03                da  $2080

HiresPatternChunk       MAC
                        lda #]1
                        ldx #]2
]loop                   jsr HGRLinePattern
                        clc
                        adc #1
                        cmp #]1+18
                        bne ]loop
                        <<<

HGRClear
                        lda #0                      ;starting line
                        ldx #$00                    ; starting bit pattern
:black                  jsr HGRLineSolid
                        clc
                        adc #1
                        cmp #192
                        bne :black
                        rts


HiresFun3
                        jsr HGRClear

                        HiresPatternChunk #0;#0
                        HiresPatternChunk #22;#40
                        HiresPatternChunk #44;#80
                        HiresPatternChunk #66;#120
                        HiresPatternChunk #88;#160
                        HiresPatternChunk #110;#200
                        HiresPatternChunk #132;#240
                        lda #191                    ;starting line
                        ldx #$FF                    ; starting bit pattern
:loop                   jsr HGRLineSolid
                        sec
                        sbc #1
                        jsr HGRLineSolid
                        sec
                        sbc #1
                        tay
                        txa
                        sec
                        sbc #$11
                        beq :done
                        tax
                        tya
                        bne :loop
:done                   rts

HiresFun4               jsr HGRClear


                        lda #15
:loop1                  ldx HGR_PATTERN_GREEN
                        ldy HGR_PATTERN_GREEN+1
                        jsr HGRLineSolidWord
                        clc
                        adc #1
                        cmp #30
                        bne :loop1

                        lda #35
:loop2                  ldx HGR_PATTERN_PURPLE
                        ldy HGR_PATTERN_PURPLE+1
                        jsr HGRLineSolidWord
                        clc
                        adc #1
                        cmp #50
                        bne :loop2


                        lda #55
:loop3                  ldx HGR_PATTERN_WHITE1
                        ldy HGR_PATTERN_WHITE1+1
                        jsr HGRLineSolidWord
                        clc
                        adc #1
                        cmp #70
                        bne :loop3



                        lda #75
:loop4                  ldx HGR_PATTERN_BLACK2
                        ldy HGR_PATTERN_BLACK2+1
                        jsr HGRLineSolidWord
                        clc
                        adc #1
                        cmp #90
                        bne :loop4

                        lda #105
:loop5                  ldx HGR_PATTERN_ORANGE
                        ldy HGR_PATTERN_ORANGE+1
                        jsr HGRLineSolidWord
                        clc
                        adc #1
                        cmp #120
                        bne :loop5


                        lda #125
:loop6                  ldx HGR_PATTERN_BLUE
                        ldy HGR_PATTERN_BLUE+1
                        jsr HGRLineSolidWord
                        clc
                        adc #1
                        cmp #140
                        bne :loop6


                        lda #145
:loop7                  ldx HGR_PATTERN_WHITE2
                        ldy HGR_PATTERN_WHITE2+1
                        jsr HGRLineSolidWord
                        clc
                        adc #1
                        cmp #160
                        bne :loop7

                        lda #161
:bottom                 tax
                        tay
                        jsr HGRLineSolidWord
                        clc
                        adc #1
                        cmp #192
                        bne :bottom
                        rts



HiresFun5
                        lda #$0
:loop                   ldx #DLR_RAINBOW_MAIN
                        ldy #>DLR_RAINBOW_MAIN
                        pha
                        sta TXTPAGE1
                        jsr HGRLinePatternBytes
                        pla
                        ldx #DLR_RAINBOW_AUX
                        ldy #>DLR_RAINBOW_AUX
                        pha
                        sta TXTPAGE2
                        jsr HGRLinePatternBytes

                        pla
                        clc
                        adc #1
                        cmp #192
                        bne :loop
                        rts


DLR_RAINBOW_MAIN        hex 00,00,00,55,01,20,08,00,22,00,66,00,44,01,00,66,00,44,00,6E,01,70,1D,00,4C,00,6E,00,32,04,60,5D,00,2A,00,7F,01,00,00,00
DLR_RAINBOW_AUX         hex 00,00,00,00,2A,00,44,00,11,00,30,0C,00,08,00,33,00,20,08,40,5D,00,6E,00,66,01,70,1D,00,66,00,6E,00,54,05,40,7F,00,00,00


HGR_PATTERN_BLACK1      hex 00,00                   ; low bit
HGR_PATTERN_GREEN       hex 2A,55                   ;
HGR_PATTERN_PURPLE      hex 55,2A                   ;
HGR_PATTERN_WHITE1      hex 7F,7F                   ;
HGR_PATTERN_BLACK2      hex 80,80                   ; high bit
HGR_PATTERN_ORANGE      hex AA,D5                   ;
HGR_PATTERN_BLUE        hex D5,AA                   ;
HGR_PATTERN_WHITE2      hex FF,FF                   ;



* call with line in A, pattern in X
HGRLinePattern          PHA
                        jsr HGRBASE                 ;only uses A.  XY are preserved
                        ldy #0
                        txa                         ;THIS IS OUR BIT PATTERN (START)
:looop                  sta (GBAS),y
                        iny
                        clc
                        adc #1                      ;NEXT BIT PATTERN
                        cpy #40
                        bne :looop
                        PLA
                        rts


* call with line in A, pattern in X
HGRLineSolid            PHA
                        jsr HGRBASE                 ;only uses A.  XY are preserved
                        ldy #0
                        txa                         ;THIS IS OUR ONLY BIT PATTERN
:looop                  sta (GBAS),y
                        iny
                        cpy #40
                        bne :looop
                        PLA
                        rts

* call with line in A, pattern in XY
HGRLineSolidWord        PHA
                        stx :loop+1                 ; set our write bytes
                        sty :loop_+1

                        jsr HGRBASE                 ;only uses A.  XY are preserved
                        ldy #0

:loop                   lda #$00                    ; this is overwritten
                        sta (GBAS),y
                        iny
:loop_                  lda #$00                    ; this is overwritten
                        sta (GBAS),y
                        iny
                        cpy #40
                        bne :loop
                        PLA
                        rts


* call with line in A, pattern adder in XY
HGRLinePatternBytes     PHA
                        stx :loop+1                 ; set our write bytes
                        sty :loop+2

                        jsr HGRBASE                 ;only uses A.  XY are preserved
                        ldy #0

:loop                   lda $2000,y                 ; this is overwritten
                        sta (GBAS),y
                        iny
                        cpy #40
                        bne :loop
                        PLA
                        rts

HiresFun2
                        lda #0
:loop
                        PHA
                        jsr HGRBASE                 ;
                        ldy #0
                        tya
:looop                  sta (GBAS),y
                        iny
                        clc
                        adc #1
                        cmp #40
                        bne :looop
                        PLA
                        clc
                        adc #1
                        cmp #192
                        bne :loop
                        rts

* for y=0 to
*  for x=0 to
*   getline_offset(y)
*   stx lineoff,x
* next x y

HiresFun                clc
                        xce
                        rep #$30
                        lda #$0000
                        tay
                        inc
:loop                   sta $2000,y

                                                    ;lda #%0110111011011101
                                                    ;sta $2000,y
                        inc
                        cmp #20
                        bne :noroll
                        lda #0
:noroll
                        iny
                        iny
                        cpy #$2000
                        bne :loop
                        sec
                        xce
                        sep #$30
                        jsr WaitKey
                        rts


***************************************************************
* "Assembly Lines" AL20-HIRES BASE ADDRESS CALCULATOR ROUTINE *
***************************************************************
* NOTE: Set a value for HPAG before calling HGRBASE
GBAS                    EQU $26
HPAG                    EQU $E6                     ; HGR=$20, HGR2=$40
*
* CALC BASE ADDRESS FOR Y-COORD IN ACCUM.
* GBAS = ADDR OF 1ST BYTE OF LINE SPECIFIED.
* ASSUME ACCUM HAS BITS abcdefgh, C=carry
HGRBASE                 PHA                         ; abcdefgh
                        AND #$C0                    ; ab000000
                        STA GBAS
                        LSR                         ; 0ab00000
                        LSR                         ; 00ab0000
                        ORA GBAS                    ; abab0000
                        STA GBAS
                        PLA                         ; abcdefgh
                        STA GBAS+1
                        ASL                         ; bcdefgh0 C=a
                        ASL                         ; cdefgh00 C=b
                        ASL                         ; defgh000 C=c
                        ROL GBAS+1                  ; bcdefghc C=a
                        ASL                         ; efgh0000 C=d
                        ROL GBAS+1                  ; cdefghcd C=b
                        ASL                         ; fgh00000 C=e
                        ROR GBAS                    ; eabab000

                        LDA GBAS+1                  ; cdefghcd
                        AND #$1F                    ; 000fghcd
                        ORA HPAG                    ; 001fghcd (PAGE 1)
                        STA GBAS+1                  ; 001fghcd

DONE                    RTS





WaitKey                 jsr CheckKey
                        bcs :done
                        bcc WaitKey
:done                   rts



SafeWait                PushAll
                        jsr WaitKey
                        PopAll
                        rts



CheckKey                lda KEY
                        bpl :noKey
                        sta STROBE
                        jsr CharToUpper
                        sec
                        rts
:noKey                  clc
                        rts


PushAll                 MAC
                        pha
                        phx
                        phy
                        <<<

PopAll                  MAC
                        ply
                        plx
                        pla
                        <<<




* Key "Q" hit!
Quit                    jsr MLI                     ; first actual command, call ProDOS vector
                        dfb $65                     ; with "quit" request ($65)
                        da  QuitParm
                        bcs Error
                        brk $00                     ; shouldn't ever get here!

QuitParm                dfb 4                       ; number of parameters
                        dfb 0                       ; standard quit type
                        da  $0000                   ; not needed when using standard quit
                        dfb 0                       ; not used
                        da  $0000                   ; not used

Error                   brk $00                     ; shouldn't be here either
                        put strings
                        put appledetect

_PGMEND                 =   *
_PGMTOTAL               =   _PGMEND-_PGMSTART
                        typ $ff                     ; set P8 type ($ff = "SYS") for output file
                        dsk mdt.system              ; tell compiler what name for output file
                        put applerom
