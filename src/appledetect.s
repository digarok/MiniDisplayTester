*********************
*** Defined Types ***
*********************

* cpuTypes {0=6502,1=65c02,2=65816}
CPU_TYPE_6502           =   0
CPU_TYPE_65C02          =   1
CPU_TYPE_65816          =   2


* AD_GetCpu : detect 6502/65c02/65816
*
* inputs   : none
* destroys : A
* return   : A = {cpuType}

AD_GetCpu               lda #$00
                        inc                         ; !6502
                        cmp #$01
                        bmi :store
                        xba                         ; !65c02
                        dec
                        xba                         ; 65816 re-zeros
                        inc
:store                  rts
