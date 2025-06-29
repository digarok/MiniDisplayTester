**************************************************
* Apple Standard Memory Locations
**************************************************

* APPLESOFT
CH                      equ $24
XPOS                    equ $24                     ; my name
CV                      equ $25
YPOS                    equ $25                     ; my name
HCOLOR                  equ $E4                     ;HCOLOR value
SETHCOL                 equ $F6EC                   ;Set active HCOLOR to value of X (0 ... 7)
HPLOT                   equ $F457                   ;Plots a colored dor at the position
                                                    ; given by A (vertical), Y (horizontal high),
                                                    ; and X (horizontal low)
HLIN                    equ $F53A                   ;Draws a line from the last plotted dot to the
                                                    ; position given by Y (vertical), X (horizontal high),
                                                    ; and A (horizontal low)
CLRLORES                equ $F832
CLRHIRES                equ $F3F2
CLRHIRESC               equ $F3F6                   ;clears to last color plotted


GSTEXT                  equ $C022                   ; my alternate description
TBCOLOR                 equ $C022                   ; Character Color: low nibble = BG, high nibble is FG (text)
GSBORDER                equ $C034                   ; my alternate description
CLOCKCTL                equ $C034                   ; b0-3=borderColor b5=stopBit b6=read b7=start


KEY                     equ $C000
C80STOREOFF             equ $C000                   ; disables TXTPAGE1/2 softswitches $c054 $c055
CLR80COL                equ $C000
C80STOREON              equ $C001                   ; enables TXTPAGE1/2 softswitches for 80-col writes
SET80COL                equ $C001
RDMAINRAM               equ $C002                   ;Read from main 48K RAM ($200-BFFF)
RDCARDRAM               equ $C003                   ;Read from alternate 48K RAM ($200-BFFF)
WRMAINRAM               equ $C004                   ;Write to main 48K RAM ($200-BFFF)
RAMWRTMAIN              equ $C004
WRCARDRAM               equ $C005                   ;Write to alternate 48K RAM ($200-BFFF)
RAMWRTAUX               equ $C005

CLR80VID                equ $C00C                   ; disable 80-col display (ie, 40-col mode)
SET80VID                equ $C00D                   ; turn on 80-col display

CLRALTCH                equ $C00E                   ;use main character set - normal LC, Flashing UC (WR-only)
SETALTCH                equ $C00F                   ;use alt char set - normal inverse, LC; no Flashing (WR-only)

STROBE                  equ $C010

** These all set bit 7 when true.  (Can easily test with BIT/BMI/BPL)

RDLCBNK2                equ $C011                   ; reading from LC bank $Dx 2
RDLCRAM                 equ $C012                   ; reading from LC RAM
RDRAMRD                 equ $C013                   ; reading from aux/alt 48K
RDRAMWR                 equ $C014                   ; writing to aux/alt 48K
RDCXROM                 equ $C015                   ; using internal slot ROM
RDAUXZP                 equ $C016                   ; using slot zero page, stack, & LC
RDC3ROM                 equ $C017                   ; using external (slot) C3 ROM
RD80COL                 equ $C018                   ; 80STORE is on; using 80-column memory mapping
RDVBLBAR                equ $C019                   ; no VBL (VBL signal low)
RDTEXT                  equ $C01A                   ; using text mode
RDMIXED                 equ $C01B                   ; using mixed mode
RDPAGE2                 equ $C01C                   ; using text/graphics page2
RDHIRES                 equ $C01D                   ; using Hi-res graphics mode
RDALTCH                 equ $C01E                   ; using alternate character set
RD80VID                 equ $C01F                   ; using 80-column display mode



VBL                     equ $C02E
SPEAKER                 equ $C030

TXTCLR                  equ $C050
TXTSET                  equ $C051
MIXCLR                  equ $C052
MIXSET                  equ $C053
TXTPAGE1                equ $C054
TXTPAGE2                equ $C055
LORES                   equ $C056
HIRES                   equ $C057


CLRAN3                  equ $C05E                   ;Clear annunciator-3 output  (DLR on)	 (Mislabeled in IIgs Firmare Ref?)
SETAN3                  equ $C05F                   ;Set annunciator-3 output


COUT                    equ $FDED                   ; Calls the output routine whose address is stored in CSW,
                                                    ;  normally COUTI
CLREOL                  equ $FC9C                   ; Clears to end of line from current cursor position
CLEOLZ                  equ $FC9E                   ; Clear to end ofline using contents of Y register as cursor
                                                    ;  position
CLREOP                  equ $FC42                   ; Clears to bottom of window
CLRSCR                  equ $F832                   ; Clears the low-resolution screen
CLRTOP                  equ $F836                   ; Clears the top 40 lines of the low-resolution screen
COUTI                   equ $FDF0                   ; Displays a character on the screen
CROUT                   equ $FD8E                   ; Generates a carriage return
CROUT1                  equ $FD8B                   ; Clears to end ofline and then generates a carriage return
GETLN                   equ $FD6A                   ; Displays the prompt character; accepts a string of characters
                                                    ;  by means of RDKEY
HLINE                   equ $F819                   ; Draws a horizontal line of blocks
HOME                    equ $FC58                   ; Clears the window and puts the cursor in the upper left
                                                    ;  corner of the window
KEYIN                   equ $FD1B                   ; With 80-column fumware inactive, displays checkerboard
                                                    ;  cursor; accepts characters from keyboard
PLOT                    equ $F800                   ; Plots a single low-resolution block on the screen
PRBL2                   equ $F94A                   ; Sends 1 to 256 blank spaces to the output device
PRBYTE                  equ $FDDA                   ; Prints a hexadecimal byte
PRHEX                   equ $FDE3                   ; Prints 4 bits as a hexadecimal number

PRNTAX                  equ $F941                   ; Prints the contents of A and X in hexadecimal format
RDKEY                   equ $FD0C                   ; Displays blinking cursor; goes to standard input
                                                    ;  routine, nonnally KEYIN or BASICIN
SCRN                    equ $F871                   ; Reads color of a low-resolution block
SETCOL                  equ $F864                   ; Sets the color for plotting in low-resolution block
VTAB                    equ $FC22                   ; Sets the cursor vertical position (from CV)
VTABZ                   equ $FC24                   ; Sets the cursor vertical position (0)
VLINE                   equ $F828                   ; Draws a vertical line of low-resolution blocks

GSROM                   equ $FB59                   ; should be int number of rom rev on Apple IIgs



* KEY EQUATES
KEY_UPARROW             =   $8B
KEY_DNARROW             =   $8A
KEY_RTARROW             =   $95
KEY_LTARROW             =   $88
KEY_ENTER               =   $8D
KEY_ESC                 =   $9B
KEY_TAB                 =   $89
KEY_DEL                 =   $FF



*************************************************************
* NOT PART OF THE ROMS!  RATHER, THIS IS FROM PRODOS8 !!!   *
* Still, as it's part of the "standard" Apple II ecosystem, *
* I wanted to start making them available in this file.     *
*************************************************************
MLI                     equ $BF00



*************************************
* LORES / DOUBLE LORES / TEXT LINES *
*************************************
* @todo: ZERO INDEXING PLEASE!!!!
Lo00                    equ $400
Lo01                    equ $480
Lo02                    equ $500
Lo03                    equ $580
Lo04                    equ $600
Lo05                    equ $680
Lo06                    equ $700
Lo07                    equ $780
Lo08                    equ $428
Lo09                    equ $4a8
Lo10                    equ $528
Lo11                    equ $5a8
Lo12                    equ $628
Lo13                    equ $6a8
Lo14                    equ $728
Lo15                    equ $7a8
Lo16                    equ $450
Lo17                    equ $4d0
Lo18                    equ $550
Lo19                    equ $5d0
* the "plus four" lines
Lo20                    equ $650
Lo21                    equ $6d0
Lo22                    equ $750
Lo23                    equ $7d0
