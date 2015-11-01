****************************************
* MiniDisplayTester                    *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2015-10-05                          *
****************************************

                       org          $2000                  ; start at $2000 (all ProDOS8 system files)

RELOCATOR                                                  ; This uses my ProDOS8 relocator from daglib/src/rel.8
                       jsr          CopyChunkZP
                       jmp          _PGMSTART

CopyChunkZP
                       lda          #_PGMSTART_PREMOVE
                       sta          $00
                       lda          #>_PGMSTART_PREMOVE
                       sta          $01
                       lda          #_PGMSTART
                       sta          $02
                       lda          #>_PGMSTART
                       sta          $03


                       lda          #_PGMTOTAL
                       sta          :finalpage+1           ;leftover bytes
                       lda          #>_PGMTOTAL
                       sta          :pageloop+1
                       inc
                       sta          :pastend+1             ;lame final check



                       ldx          #0                     ; page counter
:pageloop              cpx          #$00                   ; <- THIS IS OVERWRITTEN ABOVE
                       bne          :notfinalpage
:finalpage             ldy          #$00                   ; <- THIS IS OVERWRITTEN ABOVE
                       bra          :quickloop
:notfinalpage          ldy          #$FF                   ; full page
:quickloop             lda          ($00),y
                       sta          ($02),y
                       dey
                       cpy          #$FF                   ;argh.
                       bne          :quickloop
                       inc          $1
                       inc          $3
                       inx
:pastend               cpx          #$00                   ; <- THIS IS OVERWRITTEN ABOVE
                       bcc          :pageloop
                       rts








_PGMSTART_PREMOVE
                       org          $4000
_PGMSTART              =            *

Init
                       jsr          ModeText40


*
* Main Menu loop begin2
*
Main
:menuLoop
:menuNoDrawLoop        jsr          CheckKey
                       bcc          :menuNoDrawLoop        ;hmm?
:keyHit                cmp          #"q"
                       bne          :check1
                       beq          :quitter               ;because an option might have changed

:check1                cmp          #"1"
                       bne          :check2
                       jsr          ModeText40
                       beq          :menuNoDrawLoop

:check2                cmp          #"2"
                       bne          :check3
                       jsr          ModeText80
                       beq          :menuNoDrawLoop
:check3                cmp          #"3"
                       bne          :check4
                       jsr          ModeLores
                       beq          :menuNoDrawLoop

:check4                cmp          #"4"
                       bne          :check5
                       jsr          ModeDoubleLores
                       bra          :menuNoDrawLoop
:check5                cmp          #"5"
                       bne          :check6
                       jsr          ModeHires
                       bra          :menuNoDrawLoop
:check6                cmp          #"6"
                       bne          :check7
                       jsr          ModeDoubleHires
                       bra          :menuNoDrawLoop
:check7                cmp          #"7"
                       bne          :check8
                       jsr          ModeSuperHires320
                       bra          :menuNoDrawLoop
:check8                cmp          #"8"
                       bne          :check9
                       jsr          ModeSuperHires640
                       bra          :menuNoDrawLoop
:check9                cmp          #"9"
                       bne          :unknownKey
                       jsr          ModeBorderTest
                       bra          :menuNoDrawLoop


:unknownKey

                       clc
                       bcc          :menuNoDrawLoop
*
* Main Menu loop end ^^^
*
:quitter               jmp          Quit



ModeText40             jsr          SetModeText40
                       jsr          PrintMenu
                       rts

ModeText80             jsr          SetModeText80
                       jsr          PrintMenu
                       rts

ModeLores              jsr          SetModeLores
                       jsr          DrawLoresChart1
                       rts

ModeDoubleLores        jsr          SetModeDoubleLores
                       jsr          DrawDoubleLoresChart1
                       rts

ModeHires              jsr          SetModeHires
    jsr HiresFun
                       rts
ModeDoubleHires        jsr          SetModeDoubleHires
                       rts

ModeSuperHires320      jsr          SetModeSuperHires320
                       jsr          SHRCLEARMEM
                       jsr          DrawSHR320SCBs
                       jsr          SHRSTRIPES
                       jsr          DrawCurrentPalette
                       jsr          IncPal
                       rts

ModeSuperHires640      jsr          SetModeSuperHires640
                       jsr          SHRCLEARMEM
                       jsr          DrawSHR640SCBs
                       jsr          SHRSTRIPES
                       jsr          DrawCurrentPalette
                       jsr          IncPal
                       rts
_lastcolor             db           0
ModeBorderTest
                       lda          $c034
                       pha
:loop
                       lda          KEY
                       bpl          :nokey
                       sta          STROBE
                       bra          :done
:nokey                 lda          $c02e
                       cmp          _lastcolor
                       beq          :nokey
                       sta          _lastcolor
                       and          #$0F
                       nop
                       nop
                       sta          $c034
                       bra          :loop
:done                  pla
                       sta          $c034
                       rts

SetModeText40          jsr          SHROFF
                       sta          TXTSET
                       lda          #" "                   ;omg weird.. this turns on, output ctrl-U to turn off (21)
                       jsr          $c300
                       sta          C80STOREOFF
                       lda          #$95
                       jsr          COUT
                       sta          CLR80COL
                       sta          CLR80VID
                       rts

SetModeText80          jsr          SHROFF
                       sta          TXTSET
                       lda          #" "                   ;omg weird.. this turns on, output ctrl-U to turn off (21)
                       jsr          $c300
                       sta          SET80COL
                       sta          SET80VID
                       rts

SetModeLores           jsr          SHROFF
                       lda          #$95
                       jsr          COUT
                       sta          LORES
                       sta          TXTCLR                 ;turn on graphics
                       lda          SETAN3
                       rts

SetModeDoubleLores     jsr          SHROFF
                       lda          LORES                  ;set lores
                       sta          TXTCLR
                       lda          CLRAN3                 ;enables DLR
                       sta          SET80VID
                       sta          C80STOREON             ; enable aux/page1,2 mapping
                       sta          MIXCLR                 ;make sure graphics-only mode
                       rts

SetModeHires           jsr          SHROFF
                       sta          HIRES
                       sta          TXTCLR
                       lda          SETAN3                 ;no DLR
                       rts
SetModeDoubleHires     jsr          SHROFF
                       sta          HIRES
                       sta          TXTCLR
                       lda          CLRAN3                 ;enables DLR
                       sta          SET80VID
                       sta          C80STOREON             ; enable aux/page1,2 mapping
                       sta          MIXCLR                 ;make sure graphics-only mode
                       rts

IncPal
                       inc          _curpal
                       lda          _curpal
                       cmp          #4
                       bcc          :noroll
                       lda          #1
                       sta          _curpal
:noroll                rts

SHROFF                 lda          #$01
                       sta          $c029
                       sta          _curpal                ;hack to reset pal between text modes... kinda pointless
                       rts
SHRON                  lda          #$c1
                       sta          $c029
                       rts

SHRCLEARMEM            clc
                       xce
                       rep          #$30
                       lda          #0
                       ldx          #0
:loop                  stal         $e12000,x
                       inx
                       inx
                       cpx          #$8000
                       bne          :loop
                       sec
                       xce
                       sep          #$30
                       rts

SHRSTRIPES             clc
                       xce
                       rep          #$30
                       ldx          #0
:stripestart           lda          #0
:stripepass            ldy          #0
:loop                  stal         $e12000,x
                       inx
                       inx
                       cpx          #$7d00
                       bcs          :done
                       iny
                       cpy          #5
                       bne          :loop
                       cmp          #$ffff
                       beq          :stripestart
:notF                  clc
                       adc          #$1111
                       bra          :stripepass
:done                  sec
                       xce
                       sep          #$30
                       rts

DrawSHR640SCBs
                       lda          #0
                       ldx          #0
:loop2                 ldy          #0
:loop                  ora          #%10000000
                       stal         $e19d00,x
                       inx
                       iny
:stretch               cpy          #12
                       bne          :loop

                       pha                                 ;this part makes it to 12 then 13 lines.  to make avg of 12.5
                       lda          :stretch+1
                       cmp          #12
                       bne          :is13
                       lda          #13
                       bne          :storestretcher
:is13                  lda          #12
:storestretcher        sta          :stretch+1
                       pla

                       inc
                       cpx          #200
                       bcc          :loop2
                       rts

DrawSHR320SCBs
                       lda          #0
                       ldx          #0
:loop2                 ldy          #0
:loop                  stal         $e19d00,x
                       inx
                       iny
:stretch               cpy          #12
                       bne          :loop

                       pha                                 ;this part makes it to 12 then 13 lines.  to make avg of 12.5
                       lda          :stretch+1
                       cmp          #12
                       bne          :is13
                       lda          #13
                       bne          :storestretcher
:is13                  lda          #12
:storestretcher        sta          :stretch+1
                       pla

                       inc
                       cpx          #200
                       bcc          :loop2
                       rts

PalTable               da           _pal1,_pal2,_pal3
_pal1
                       dw           $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0F0F
                       dw           $0000,$0100,$0000,$0010,$0000,$0001,$0000,$0110,$0000,$0101,$0000,$0011,$0000,$0111,$0000,$0E1F
                       dw           $0000,$0200,$0000,$0020,$0000,$0002,$0000,$0220,$0000,$0202,$0000,$0022,$0000,$0222,$0000,$0D2E
                       dw           $0000,$0300,$0000,$0030,$0000,$0003,$0000,$0330,$0000,$0303,$0000,$0033,$0000,$0333,$0000,$0C3E
                       dw           $0000,$0400,$0000,$0040,$0000,$0004,$0000,$0440,$0000,$0404,$0000,$0044,$0000,$0444,$0000,$0B4D
                       dw           $0000,$0500,$0000,$0050,$0000,$0005,$0000,$0550,$0000,$0505,$0000,$0055,$0000,$0555,$0000,$0A5D
                       dw           $0000,$0600,$0000,$0060,$0000,$0006,$0000,$0660,$0000,$0606,$0000,$0066,$0000,$0666,$0000,$096C
                       dw           $0000,$0700,$0000,$0070,$0000,$0007,$0000,$0770,$0000,$0707,$0000,$0077,$0000,$0777,$0000,$087C
                       dw           $0000,$0800,$0000,$0080,$0000,$0008,$0000,$0880,$0000,$0808,$0000,$0088,$0000,$0888,$0000,$078B
                       dw           $0000,$0900,$0000,$0090,$0000,$0009,$0000,$0990,$0000,$0909,$0000,$0099,$0000,$0999,$0000,$069B
                       dw           $0000,$0A00,$0000,$00A0,$0000,$000A,$0000,$0AA0,$0000,$0A0A,$0000,$00AA,$0000,$0AAA,$0000,$05AA
                       dw           $0000,$0B00,$0000,$00B0,$0000,$000B,$0000,$0BB0,$0000,$0B0B,$0000,$00BB,$0000,$0BBB,$0000,$04BA
                       dw           $0000,$0C00,$0000,$00C0,$0000,$000C,$0000,$0CC0,$0000,$0C0C,$0000,$00CC,$0000,$0CCC,$0000,$03C9
                       dw           $0000,$0D00,$0000,$00D0,$0000,$000D,$0000,$0DD0,$0000,$0D0D,$0000,$00DD,$0000,$0DDD,$0000,$02D9
                       dw           $0000,$0E00,$0000,$00E0,$0000,$000E,$0000,$0EE0,$0000,$0E0E,$0000,$00EE,$0000,$0EEE,$0000,$01E8
                       dw           $0000,$0F00,$0000,$00F0,$0000,$000F,$0000,$0FF0,$0000,$0F0F,$0000,$00FF,$0000,$0FFF,$0000,$00F8

_pal2
                       dw           $0F00,$0F01,$0F12,$0F13,$0F24,$0F25,$0F36,$0F37,$0F48,$0F49,$0F5A,$0F5B,$0F6C,$0F6D,$0F7E,$0F7F
                       dw           $0E00,$0E11,$0E12,$0E23,$0E24,$0E35,$0E36,$0E47,$0E48,$0E59,$0E5A,$0E6B,$0E6C,$0E7D,$0E7E,$0E8F
                       dw           $0D10,$0D11,$0D22,$0D23,$0D34,$0D35,$0D46,$0D47,$0D58,$0D59,$0D6A,$0D6B,$0D7C,$0D7D,$0D8E,$0D8F
                       dw           $0C10,$0C21,$0C22,$0C33,$0C34,$0C45,$0C46,$0C57,$0C58,$0C69,$0C6A,$0C7B,$0C7C,$0C8D,$0C8E,$0C9F
                       dw           $0B20,$0B21,$0B32,$0B33,$0B44,$0B45,$0B56,$0B57,$0B68,$0B69,$0B7A,$0B7B,$0B8C,$0B8D,$0B9E,$0B9F
                       dw           $0A20,$0A31,$0A32,$0A43,$0A44,$0A55,$0A56,$0A67,$0A68,$0A79,$0A7A,$0A8B,$0A8C,$0A9D,$0A9E,$0AAF
                       dw           $0930,$0931,$0942,$0943,$0954,$0955,$0966,$0967,$0978,$0979,$098A,$098B,$099C,$099D,$09AE,$09AF
                       dw           $0830,$0841,$0842,$0853,$0854,$0865,$0866,$0877,$0878,$0889,$088A,$089B,$089C,$08AD,$08AE,$08BF
                       dw           $0740,$0741,$0752,$0753,$0764,$0765,$0776,$0777,$0788,$0789,$079A,$079B,$07AC,$07AD,$07BE,$07BF
                       dw           $0640,$0651,$0652,$0663,$0664,$0675,$0676,$0687,$0688,$0699,$069A,$06AB,$06AC,$06BD,$06BE,$06CF
                       dw           $0550,$0551,$0562,$0563,$0574,$0575,$0586,$0587,$0598,$0599,$05AA,$05AB,$05BC,$05BD,$05CE,$05CF
                       dw           $0450,$0461,$0462,$0473,$0474,$0485,$0486,$0497,$0498,$04A9,$04AA,$04BB,$04BC,$04CD,$04CE,$04DF
                       dw           $0360,$0361,$0372,$0373,$0384,$0385,$0396,$0397,$03A8,$03A9,$03BA,$03BB,$03CC,$03CD,$03DE,$03DF
                       dw           $0260,$0271,$0272,$0283,$0284,$0295,$0296,$02A7,$02A8,$02B9,$02BA,$02CB,$02CC,$02DD,$02DE,$02EF
                       dw           $0170,$0171,$0182,$0183,$0194,$0195,$01A6,$01A7,$01B8,$01B9,$01CA,$01CB,$01DC,$01DD,$01EE,$01EF
                       dw           $0070,$0081,$0082,$0093,$0094,$00A5,$00A6,$00B7,$00B8,$00C9,$00CA,$00DB,$00DC,$00ED,$00EE,$00FF


_pal3
                       dw           $0000,$0001,$0012,$0013,$0024,$0025,$0036,$0037,$0048,$0049,$005A,$005B,$006C,$006D,$007E,$007F
                       dw           $0100,$0111,$0112,$0123,$0124,$0135,$0136,$0147,$0148,$0159,$015A,$016B,$016C,$017D,$017E,$018F
                       dw           $0210,$0211,$0222,$0223,$0234,$0235,$0246,$0247,$0258,$0259,$026A,$026B,$027C,$027D,$028E,$028F
                       dw           $0310,$0321,$0322,$0333,$0334,$0345,$0346,$0357,$0358,$0369,$036A,$037B,$037C,$038D,$038E,$039F
                       dw           $0420,$0421,$0432,$0433,$0444,$0445,$0456,$0457,$0468,$0469,$047A,$047B,$048C,$048D,$049E,$049F
                       dw           $0520,$0531,$0532,$0543,$0544,$0555,$0556,$0567,$0568,$0579,$057A,$058B,$058C,$059D,$059E,$05AF
                       dw           $0630,$0631,$0642,$0643,$0654,$0655,$0666,$0667,$0678,$0679,$068A,$068B,$069C,$069D,$06AE,$06AF
                       dw           $0730,$0741,$0742,$0753,$0754,$0765,$0766,$0777,$0778,$0789,$078A,$079B,$079C,$07AD,$07AE,$07BF
                       dw           $0840,$0841,$0852,$0853,$0864,$0865,$0876,$0877,$0888,$0889,$089A,$089B,$08AC,$08AD,$08BE,$08BF
                       dw           $0940,$0951,$0952,$0963,$0964,$0975,$0976,$0987,$0988,$0999,$099A,$09AB,$09AC,$09BD,$09BE,$09CF
                       dw           $0A50,$0A51,$0A62,$0A63,$0A74,$0A75,$0A86,$0A87,$0A98,$0A99,$0AAA,$0AAB,$0ABC,$0ABD,$0ACE,$0ACF
                       dw           $0B50,$0B61,$0B62,$0B73,$0B74,$0B85,$0B86,$0B97,$0B98,$0BA9,$0BAA,$0BBB,$0BBC,$0BCD,$0BCE,$0BDF
                       dw           $0C60,$0C61,$0C72,$0C73,$0C84,$0C85,$0C96,$0C97,$0CA8,$0CA9,$0CBA,$0CBB,$0CCC,$0CCD,$0CDE,$0CDF
                       dw           $0D60,$0D71,$0D72,$0D83,$0D84,$0D95,$0D96,$0DA7,$0DA8,$0DB9,$0DBA,$0DCB,$0DCC,$0DDD,$0DDE,$0DEF
                       dw           $0E70,$0E71,$0E82,$0E83,$0E94,$0E95,$0EA6,$0EA7,$0EB8,$0EB9,$0ECA,$0ECB,$0EDC,$0EDD,$0EEE,$0EEF
                       dw           $0F70,$0F81,$0F82,$0F93,$0F94,$0FA5,$0FA6,$0FB7,$0FB8,$0FC9,$0FCA,$0FDB,$0FDC,$0FED,$0FEE,$0FFF

_curpal                db           1

DrawPresetPalette1     clc
                       xce
                       rep          #$30

                       ldx          #0
:loop                  lda          _pal1,x
                       stal         $e19e00,x
                       inx
                       inx
                       cpx          #$200
                       bne          :loop
                       sec
                       xce
                       sep          #$30
                       rts

DrawCurrentPalette     lda          _curpal                ;
                       dec                                 ;table is at 0 so pal--
                       asl                                 ;
                       tax                                 ;
                       lda          PalTable,x             ;patch code to point to palette
                       sta          :loop+1                ;
                       lda          PalTable+1,x           ;
                       sta          :loop+2                ;

                       clc                                 ;16-bit for copy
                       xce
                       rep          #$30


                       ldx          #0
:loop                  lda          _pal2,x
                       stal         $e19e00,x
                       inx
                       inx
                       cpx          #$200
                       bne          :loop
                       sec
                       xce
                       sep          #$30
                       rts

SetModeSuperHires320   jsr          SHRON
                       rts
SetModeSuperHires640   jsr          SHRON
                       rts

DrawLoresChart1
                       lda          #0
                       jsr          LoresFillScreen
                       jsr          LoresPattern
                       jsr          LoresPattern2
                       lda          #$11
                       ldx          #0
                       jsr          LoresVlinX
                       ldx          #39
                       jsr          LoresVlinX
                       ldx          #0
                       jsr          LoresHlinX
                       ldx          #23
                       jsr          LoresHlinX
                       rts

DrawDoubleLoresChart1
                       lda          #0
                       jsr          DL_Clear
                       lda          #$01
                       ldy          #0
                       jsr          DL_Hline
                       lda          #$10
                       ldy          #23
                       jsr          DL_Hline
                       sta          TXTPAGE2
                       ldx          #$11
                       lda          MainAuxMap,x
                       ldx          #0
                       jsr          LoresVlinX
                       jsr          LoresPattern
                       sta          TXTPAGE1
                       lda          #$11
                       ldx          #39
                       jsr          LoresVlinX
                       jsr          LoresPattern
                       jsr          LoresPattern2
                       rts

LoresPattern           ldx          #$02
                       lda          #$11
:patternloop           sta          Lo04,x
                       sta          Lo05,x
                       sta          Lo06,x
                       sta          Lo07,x
                       sta          Lo08,x
                       inx
                       cmp          #$ff
                       beq          :done
                       clc
                       adc          #$11
                       bne          :patternloop
:done                  rts

LoresPattern2          ldx          #$02
                       lda          #$11
:patternloop2          sta          Lo14,x
                       sta          Lo15,x
                       sta          Lo16,x
                       sta          Lo17,x
                       sta          Lo18,x
                       inx
                       inx
                       cmp          #$ff
                       beq          :done
                       clc
                       adc          #$11
                       bne          :patternloop2
:done                  rts

LoresFillScreen
                       ldx          #39
:storeloop             jsr          LoresVlinX
                       dex
                       bpl          :storeloop
                       rts

LoresVlinX
                       sta          Lo01,x
                       sta          Lo02,x
                       sta          Lo03,x
                       sta          Lo04,x
                       sta          Lo05,x
                       sta          Lo06,x
                       sta          Lo06,x
                       sta          Lo06,x
                       sta          Lo07,x
                       sta          Lo08,x
                       sta          Lo09,x
                       sta          Lo10,x
                       sta          Lo11,x
                       sta          Lo12,x
                       sta          Lo13,x
                       sta          Lo14,x
                       sta          Lo15,x
                       sta          Lo16,x
                       sta          Lo17,x
                       sta          Lo18,x
                       sta          Lo19,x
                       sta          Lo20,x
                       sta          Lo21,x
                       sta          Lo22,x
                       sta          Lo23,x
                       sta          Lo24,x
                       rts
LoresHlinX             pha
                       lda          LoLineTableL,x
                       sta          $0
                       lda          LoLineTableH,x
                       sta          $1
                       ldy          #39
                       pla
:loop                  sta          ($0),y
                       dey
                       bpl          :loop
                       rts

LoLineTable            da           Lo01,Lo02,Lo03,Lo04,Lo05,Lo06
                       da           Lo07,Lo08,Lo09,Lo10,Lo11,Lo12
                       da           Lo13,Lo14,Lo15,Lo16,Lo17,Lo18
                       da           Lo19,Lo20,Lo21,Lo22,Lo23,Lo24
** Here we split the table for an optimization
** We can directly get our line numbers now
** Without using ASL
LoLineTableH           db           >Lo01,>Lo02,>Lo03,>Lo04,>Lo05,>Lo06
                       db           >Lo07,>Lo08,>Lo09,>Lo10,>Lo11,>Lo12
                       db           >Lo13,>Lo14,>Lo15,>Lo16,>Lo17,>Lo18
                       db           >Lo19,>Lo20,>Lo21,>Lo22,>Lo23,>Lo24
LoLineTableL           db           <Lo01,<Lo02,<Lo03,<Lo04,<Lo05,<Lo06
                       db           <Lo07,<Lo08,<Lo09,<Lo10,<Lo11,<Lo12
                       db           <Lo13,<Lo14,<Lo15,<Lo16,<Lo17,<Lo18
                       db           <Lo19,<Lo20,<Lo21,<Lo22,<Lo23,<Lo24

MainAuxMap
                       hex          00,08,01,09,02,0A,03,0B,04,0C,05,0D,06,0E,07,0F
                       hex          80,88,81,89,82,8A,83,8B,84,8C,85,8D,86,8E,87,8F
                       hex          10,18,11,19,12,1A,13,1B,14,1C,15,1D,16,1E,17,1F
                       hex          90,98,91,99,92,9A,93,9B,94,9C,95,9D,96,9E,97,9F
                       hex          20,28,21,29,22,2A,23,2B,24,2C,25,2D,26,2E,27,2F
                       hex          A0,A8,A1,A9,A2,AA,A3,AB,A4,AC,A5,AD,A6,AE,A7,AF
                       hex          30,38,31,39,32,3A,33,3B,34,3C,35,3D,36,3E,37,3F
                       hex          B0,B8,B1,B9,B2,BA,B3,BB,B4,BC,B5,BD,B6,BE,B7,BF
                       hex          40,48,41,49,42,4A,43,4B,44,4C,45,4D,46,4E,47,4F
                       hex          C0,C8,C1,C9,C2,CA,C3,CB,C4,CC,C5,CD,C6,CE,C7,CF
                       hex          50,58,51,59,52,5A,53,5B,54,5C,55,5D,56,5E,57,5F
                       hex          D0,D8,D1,D9,D2,DA,D3,DB,D4,DC,D5,DD,D6,DE,D7,DF
                       hex          60,68,61,69,62,6A,63,6B,64,6C,65,6D,66,6E,67,6F
                       hex          E0,E8,E1,E9,E2,EA,E3,EB,E4,EC,E5,ED,E6,EE,E7,EF
                       hex          70,78,71,79,72,7A,73,7B,74,7C,75,7D,76,7E,77,7F
                       hex          F0,F8,F1,F9,F2,FA,F3,FB,F4,FC,F5,FD,F6,FE,F7,FF



** A = lo-res color byte
DL_Clear               sta          TXTPAGE1
                       ldx          #40
:loop                  dex
                       sta          Lo01,x
                       sta          Lo02,x
                       sta          Lo03,x
                       sta          Lo04,x
                       sta          Lo05,x
                       sta          Lo06,x
                       sta          Lo07,x
                       sta          Lo08,x
                       sta          Lo09,x
                       sta          Lo10,x
                       sta          Lo11,x
                       sta          Lo12,x
                       sta          Lo13,x
                       sta          Lo14,x
                       sta          Lo15,x
                       sta          Lo16,x
                       sta          Lo17,x
                       sta          Lo18,x
                       sta          Lo19,x
                       sta          Lo20,x
                       sta          Lo21,x
                       sta          Lo22,x
                       sta          Lo23,x
                       sta          Lo24,x
                       bne          :loop
                       tax                                 ; get aux color value
                       lda          MainAuxMap,x
                       sta          TXTPAGE2               ; turn on p2
                       ldx          #40
:loop2                 dex
                       sta          Lo01,x
                       sta          Lo02,x
                       sta          Lo03,x
                       sta          Lo04,x
                       sta          Lo05,x
                       sta          Lo06,x
                       sta          Lo07,x
                       sta          Lo08,x
                       sta          Lo09,x
                       sta          Lo10,x
                       sta          Lo11,x
                       sta          Lo12,x
                       sta          Lo13,x
                       sta          Lo14,x
                       sta          Lo15,x
                       sta          Lo16,x
                       sta          Lo17,x
                       sta          Lo18,x
                       sta          Lo19,x
                       sta          Lo20,x
                       sta          Lo21,x
                       sta          Lo22,x
                       sta          Lo23,x
                       sta          Lo24,x
                       bne          :loop2
                       rts

** A = lo-res color byte  Y = line byte (0-23)
DL_Hline               tax
                       lda          LoLineTableL,y
                       sta          $0
                       lda          LoLineTableH,y
                       sta          $0+1
                       txa

                       sta          TXTPAGE1
                       ldy          #39
:loopMain              sta          ($0),y
                       dey
                       bpl          :loopMain

                       sta          TXTPAGE2
                       tax
                       lda          MainAuxMap,x
                       ldy          #39
:loopAux               sta          ($0),y
                       dey
                       bpl          :loopAux
                       rts
PrintMenu
                       jsr          HOME
                       PRINTSTRING  MSG_MENU1
                       PRINTSTRING  MSG_MENU2
                       PRINTSTRING  MSG_MENU3
                       PRINTSTRING  MSG_MENU4
                       PRINTSTRING  MSG_MENU5
                       PRINTSTRING  MSG_MENU6
                       PRINTSTRING  MSG_MENU7
                       PRINTSTRING  MSG_MENU8
                       PRINTSTRING  MSG_MENU9
                       PRINTSTRING  MSG_MENUQ
                       PRINTSTRING  MSG_INFO1
                       PRINTSTRING  MSG_INFO2

                       rts

MSG_MENU1              asc          "1.  40-COLUMN MODE (THIS)",8D,00
MSG_MENU2              asc          "2.  80-COLUMN MODE ",8D,00
MSG_MENU3              asc          "3.  LORES MODE ",8D,00
MSG_MENU4              asc          "4.  DOUBLE LORES MODE ",8D,00
MSG_MENU5              asc          "5.  HIRES MODE ",8D,00
MSG_MENU6              asc          "6.  DOUBLE HIRES MODE ",8D,00
MSG_MENU7              asc          "7.  SUPER HIRES 320 MODE",8D,00
MSG_MENU8              asc          "8.  SUPER HIRES 640 MODE",8D,00
MSG_MENU9              asc          "9.  BORDER COLOR TEST",8D,00

MSG_MENUQ              asc          "Q.  QUIT",8D,00
MSG_INFO1              asc          8D,8D,8D,8D,8D,8D,8D,8D,"            MINI DISPLAY TESTER",8D,00
MSG_INFO2              asc          "           (C)2015 - DAGEN BROCK",8D,00





HiresFun  clc
  xce
  rep #$30
  lda #$0000
  tay
:loop  sta $2000,y
  inc
  inc
  iny
  iny
  cpy #$2000
  bne :loop
  sec
  xce
  sep #$30
  rts




WaitKey                jsr          CheckKey
                       bcs          :done
                       bcc          WaitKey
:done                  rts

CheckKey               lda          KEY
                       bpl          :noKey
                       sta          STROBE
                       jsr          ToLower
                       sec
                       rts
:noKey                 clc
                       rts

ToLower                cmp          #"Z"
                       bcs          :notUpper
                       cmp          #"A"
                       bcc          :notUpper
                       clc
                       adc          #$20                   ;add 32 to get lower char
:notUpper              rts


PushAll                MAC
                       pha
                       phx
                       phy
                       <<<

PopAll                 MAC
                       ply
                       plx
                       pla
                       <<<




Quit                   jsr          MLI                    ; first actual command, call ProDOS vector
                       dfb          $65                    ; with "quit" request ($65)
                       da           QuitParm
                       bcs          Error
                       brk          $00                    ; shouldn't ever get here!

QuitParm               dfb          4                      ; number of parameters
                       dfb          0                      ; standard quit type
                       da           $0000                  ; not needed when using standard quit
                       dfb          0                      ; not used
                       da           $0000                  ; not used

Error                  brk          $00                    ; shouldn't be here either
                       put          strings


_PGMEND                =            *
_PGMTOTAL              =            _PGMEND-_PGMSTART
                       typ          $ff                    ; set P8 type ($ff = "SYS") for output file
                       dsk          mdtsystem              ; tell compiler what name for output file
                       put          applerom
