// Copyright (c) 2004 Robert Nordier.  All rights reserved.

// $Id: rt.s,v 1.7 2004/12/21 13:52:18 rn Exp $

// BCPL compiler runtime

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
                pop %ecx

                mov $ft,%ebx
                mov $FCBCNT,%ecx
rtinit.1:       mov %eax,(%ebx)
                add $BUFSIZ,%eax
                add $FCBSIZ,%ebx
                loop rtinit.1

                mov $ft,%ebx
                mov $FD.STDIN,%eax
                mov $FL.RD,%dl
                call fopen

                mov $ft+FCBSIZ,%ebx
                mov $FD.STDOUT,%eax
                mov $FL.WR,%dl
                call fopen
                ret 

                .global rtexit
rtexit:         mov $ft,%ebx
                mov $FCBCNT,%ecx
rtexit.1:       cmpb $0,FCB.FL(%ebx)
                je rtexit.2
                push %ecx
                call fclose
                pop %ecx
rtexit.2:       add $FCBSIZ,%ebx
                loop rtexit.1
                ret 

                .global findinput
findinput:      mov $IFLAGS,%edx
                jmp findio

                .global findoutput
findoutput:     mov oflags,%edx

findio:         push %ebx
                push %esi
                push %edi
                mov $ft,%ebx
                mov $FCBCNT,%ecx
findio.1:       cmpb $0,FCB.FL(%ebx)
                je findio.3
                add $FCBSIZ,%ebx
                loop findio.1
findio.2:       xor %eax,%eax
                jmp findio.5
findio.3:       shl $2,%eax
                mov %eax,%esi
                sub $STRSIZ,%esp
                mov %esp,%edi
                push $MODE
                push %edx
                push %edi
                lodsb
                xor %ecx,%ecx
                mov %al,%cl
                rep movsb
                mov %cl,(%edi)
                call open
                lea 12+STRSIZ(%esp),%esp
                jb findio.2

                cmp $IFLAGS,%edx
                mov $FL.RD,%dl
                je findio.4
                mov $FL.WR,%dl
findio.4:       call fopen

                mov %ebx,%eax
findio.5:       pop %edi
                pop %esi
                pop %ebx
                ret 

fopen:          mov %eax,FCB.FD(%ebx)
                mov FCB.BF(%ebx),%eax
                mov %eax,FCB.CP(%ebx)
                mov %eax,FCB.XP(%ebx)
                mov %dl,FCB.FL(%ebx)
                cmp $FL.RD,%dl
                je fopen.1
                push FCB.FD(%ebx)
                call isatty
                pop %ecx
                test %eax,%eax
                jnz fopen.1
                addl $BUFSIZ,FCB.XP(%ebx)
fopen.1:        ret

                .global wrch
wrch:           push %ebx
                mov cos,%ebx
                mov FCB.CP(%ebx),%ecx
                mov %al,(%ecx)
                inc %ecx
                mov %ecx,FCB.CP(%ebx)
                cmp FCB.XP(%ebx),%ecx
                jb wrch.2
                testb $FL.BF,FCB.FL(%ebx)
                jne wrch.1
                sub FCB.BF(%ebx),%ecx
                cmp $BUFSIZ,%ecx
                je wrch.1
                cmp $0xa,%al
                jne wrch.2
wrch.1:         call flush
wrch.2:         pop %ebx
                ret 

flush:          mov FCB.CP(%ebx),%ecx
                mov FCB.BF(%ebx),%edx
                mov %edx,FCB.CP(%ebx)
                sub %edx,%ecx
                je flush.2
flush.1:        push %ecx
                push %edx
                push FCB.FD(%ebx)
                call write
                lea 12(%esp,1),%esp
                jb ferr
                add %eax,%edx
                sub %eax,%ecx
                jne flush.1
flush.2:        xor %eax,%eax
                ret 

ferr:           orb $FL.ERR,FCB.FL(%ebx)
                ret 

fclose:         testb $FL.WR,FCB.FL(%ebx)
                jz fclose.1
                call flush
fclose.1:       push FCB.FD(%ebx)
                call close
                pop %ecx
                movb $0,FCB.FL(%ebx)
                ret

                .global rdch
rdch:           mov cis,%ebx
                mov FCB.CP(%ebx),%ecx
                cmp FCB.XP(%ebx),%ecx
                jb rdch.1

                mov FCB.BF(%ebx),%ecx
                mov %ecx,FCB.CP(%ebx)
                mov %ecx,FCB.XP(%ebx)

                push $BUFSIZ
                push %ecx
                push FCB.FD(%ebx)
                call read
                lea 12(%esp,1),%esp
                jb ferr
                test %eax,%eax
                je feof
                add %eax,FCB.XP(%ebx)

rdch.1:         xor %eax,%eax
                mov (%ecx),%al
                inc %ecx
                mov %ecx,FCB.CP(%ebx)
                ret 

feof:           orb $FL.EOF,FCB.FL(%ebx)
                dec %eax
                ret 

                .global unrdch
unrdch:         mov cis,%edx
                mov FCB.CP(%edx),%ecx
                cmp FCB.BF(%edx),%ecx
                je unrdch.1
                dec %ecx
                mov %ecx,FCB.CP(%edx)
unrdch.1:       ret

/======================================================================
                .global selectinput
selectinput:    mov %eax,cis
                ret

                .global selectoutput
selectoutput:   mov %eax,cos
                ret

                .global input
input:          mov cis,%eax
                ret

                .global output
output:         mov cos,%eax
                ret

                .global endread
endread:        mov cis,%ebx
                call fclose
                xor %eax,%eax
                mov %eax,cis
                ret

                .global endwrite
endwrite:       mov cos,%ebx
                call fclose
                xor %eax,%eax
                mov %eax,cos
                ret

                .global rewind
rewind:         mov cis,%ebx
                xor %ecx,%ecx
                push %ecx
                push %ecx
                push FCB.FD(%ebx)
                call olseek
                pop %eax
                pop %ecx
                pop %ecx
                mov $FL.RD,%dl
                jmp fopen

                .data
cis:            .long ft
cos:            .long ft+FCBSIZ

                .comm ft,FCBCNT*FCBSIZ
