// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// $Id: rt.s,v 1.7 2004/12/21 13:52:18 rn Exp $

// BCPL compiler runtime

                .include "sys_defs.inc"

		.set IFLAGS,0
		.set MODE,0666

                .set FCBCNT,8
                .set FCBSIZ,18
                .set BUFSIZ,512
                .set STRSIZ,256

                .set FD.STDIN,0
                .set FD.STDOUT,1

                .set FCB.BF,0
                .set FCB.XP,4
                .set FCB.CP,8
                .set FCB.FD,12
                .set FCB.FL,16

                .set FL.RD,1
                .set FL.WR,2
                .set FL.BF,4
                .set FL.EOF,64
                .set FL.ERR,128

                .global rtinit
rtinit:         push $FCBCNT*BUFSIZ
                call sbrk
                pop RC

                mov $ft,RB
                mov $FCBCNT,RC
rtinit.1:       mov RA,(RB)
                add $BUFSIZ,RA
                add $FCBSIZ,RB
                loop rtinit.1

                mov $ft,RB
                mov $FD.STDIN,RA
                mov $FL.RD,%dl
                call fopen

                mov $ft+FCBSIZ,RB
                mov $FD.STDOUT,RA
                mov $FL.WR,%dl
                call fopen
                ret 

                .global rtexit
rtexit:         mov $ft,RB
                mov $FCBCNT,RC
rtexit.1:       cmpb $0,FCB.FL(RB)
                je rtexit.2
                push RC
                call fclose
                pop RC
rtexit.2:       add $FCBSIZ,RB
                loop rtexit.1
                ret 

                .global findinput
findinput:      mov $IFLAGS,RD
                jmp findio

                .global findoutput
findoutput:     mov oflags,RD

findio:         push RB
                push RSI
                push RDI
                mov $ft,RB
                mov $FCBCNT,RC
findio.1:       cmpb $0,FCB.FL(RB)
                je findio.3
                add $FCBSIZ,RB
                loop findio.1
findio.2:       xor RA,RA
                jmp findio.5
findio.3:       shl $2,RA
                mov RA,RSI
                sub $STRSIZ,RSP
                mov RSP,RDI
                push $MODE
                push RD
                push RDI
                lodsb
                xor RC,RC
                mov %al,%cl
                rep movsb
                mov %cl,(RDI)
                call open
                lea 12+STRSIZ(RSP),RSP
                jb findio.2

                cmp $IFLAGS,RD
                mov $FL.RD,%dl
                je findio.4
                mov $FL.WR,%dl
findio.4:       call fopen

                mov RB,RA
findio.5:       pop RDI
                pop RSI
                pop RB
                ret 

fopen:          mov RA,FCB.FD(RB)
                mov FCB.BF(RB),RA
                mov RA,FCB.CP(RB)
                mov RA,FCB.XP(RB)
                mov %dl,FCB.FL(RB)
                cmp $FL.RD,%dl
                je fopen.1
                push FCB.FD(RB)
                call isatty
                pop RC
                test RA,RA
                jnz fopen.1
                addl $BUFSIZ,FCB.XP(RB)
fopen.1:        ret

                .global wrch
wrch:           push RB
                mov cos,RB
                mov FCB.CP(RB),RC
                mov %al,(RC)
                inc RC
                mov RC,FCB.CP(RB)
                cmp FCB.XP(RB),RC
                jb wrch.2
                testb $FL.BF,FCB.FL(RB)
                jne wrch.1
                sub FCB.BF(RB),RC
                cmp $BUFSIZ,RC
                je wrch.1
                cmp $0xa,%al
                jne wrch.2
wrch.1:         call flush
wrch.2:         pop RB
                ret 

flush:          mov FCB.CP(RB),RC
                mov FCB.BF(RB),RD
                mov RD,FCB.CP(RB)
                sub RD,RC
                je flush.2
flush.1:        push RC
                push RD
                push FCB.FD(RB)
                call write
                lea 12(RSP,1),RSP
                jb ferr
                add RA,RD
                sub RA,RC
                jne flush.1
flush.2:        xor RA,RA
                ret 

ferr:           orb $FL.ERR,FCB.FL(RB)
                ret 

fclose:         testb $FL.WR,FCB.FL(RB)
                jz fclose.1
                call flush
fclose.1:       push FCB.FD(RB)
                call close
                pop RC
                movb $0,FCB.FL(RB)
                ret

                .global rdch
rdch:           mov cis,RB
                mov FCB.CP(RB),RC
                cmp FCB.XP(RB),RC
                jb rdch.1

                mov FCB.BF(RB),RC
                mov RC,FCB.CP(RB)
                mov RC,FCB.XP(RB)

                push $BUFSIZ
                push RC
                push FCB.FD(RB)
                call read
                lea 12(RSP,1),RSP
                jb ferr
                test RA,RA
                je feof
                add RA,FCB.XP(RB)

rdch.1:         xor RA,RA
                mov (RC),%al
                inc RC
                mov RC,FCB.CP(RB)
                ret 

feof:           orb $FL.EOF,FCB.FL(RB)
                dec RA
                ret 

                .global unrdch
unrdch:         mov cis,RD
                mov FCB.CP(RD),RC
                cmp FCB.BF(RD),RC
                je unrdch.1
                dec RC
                mov RC,FCB.CP(RD)
unrdch.1:       ret

/======================================================================
                .global selectinput
selectinput:    mov RA,cis
                ret

                .global selectoutput
selectoutput:   mov RA,cos
                ret

                .global input
input:          mov cis,RA
                ret

                .global output
output:         mov cos,RA
                ret

                .global endread
endread:        mov cis,RB
                call fclose
                xor RA,RA
                mov RA,cis
                ret

                .global endwrite
endwrite:       mov cos,RB
                call fclose
                xor RA,RA
                mov RA,cos
                ret

                .global rewind
rewind:         mov cis,RB
                xor RC,RC
                push RC
                push RC
                push FCB.FD(RB)
                call olseek
                pop RA
                pop RC
                pop RC
                mov $FL.RD,%dl
                jmp fopen

                .data
cis:            .long ft
cos:            .long ft+FCBSIZ

                .comm ft,FCBCNT*FCBSIZ
