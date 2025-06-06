// Copyright (c) 2004, 2012 Robert Nordier.  All rights reserved.

// BCPL compiler backend: generates x86 assembler from INTCODE

GET "LIBHDR"

MANIFEST $(
    WORDSZ=4; GSZ=500; LSZ=500;
    // register numbers
    RAX=0; RCX=1; RDX=2; RBX=3; RSP=4; RBP=5; RSI=6; RDI=7;
    // log2 of word size used for shifts
    SHIFT = WORDSZ=8 -> 3, 2
$)

// Type values (N=number, P=local, G=global, L=static, R=register)
// at up to two levels of indirection
MANIFEST $(
T.N=0;  T.LP=1; T.LG=2;  T.LL=3
T.R=4;  T.P=5;  T.G=6;   T.L=7
T.IR=8; T.IP=9; T.IG=10; T.IL=11
$)

// Assembler statement patterns for code generation: with the
// jump instructions first, as they need to be distinguished
MANIFEST $(
A.JE=0;   A.JNE=1;  A.JL=2;   A.JGE=3;  A.JG=4;   A.JLE=5;  A.JMP=6
A.MUL=7;  A.DIV=8;  A.MOV=9;  A.ADD=10; A.SUB=11; A.CMP=12; A.SHL=13
A.SHR=14; A.AND=15; A.OR=16;  A.XOR=17; A.MV2=18; A.LEA=19; A.SL2=20
A.SR2=21; A.SNE=22; A.SE=23;  A.SGE=24; A.SL=25;  A.SLE=26; A.SG=27
$)

GLOBAL $(
G:150           // Definitions vector for globals
L:151           // Definitions vector for labels
LN:152          // Labels in L vector
LOFF:153        // Label offset value
SECT:154        // Section (text or data) in output
LINE:155        // Source line number
COL:156         // Source column number
CH:157          // Source character last read
ERR:158         // Stream for errors
ASM:159         // Stream for output
$)

LET START() = VALOF
$(  LET GVEC = VEC GSZ
    AND LVEC = VEC LSZ
    G := GVEC
    L := LVEC
    FOR I = 0 TO GSZ DO G!I := 0
    LN, SECT, LINE, COL := 0, 0, 0, 0
    LOFF := 2000
    CH := '*N'
    ERR := OUTPUT()
    ASM := FINDOUTPUT("ASM")
    SELECTOUTPUT(ASM)
    ASSEM()
    EPILOG()
    ENDWRITE()
    RESULTIS 0
$)

AND ASSEM() BE
$(  LET F, A, T, I = 0, 0, 0, 0
    RCH()
    F := CH
    SWITCHON F INTO $(
    DEFAULT:
        ERROR(1)
    CASE ENDSTREAMCH:
        GENER(0, 0, 0)
        RETURN
    CASE '*S': CASE '*N': CASE '$':
        LOOP
    CASE 'Z':
        LOFF := LOFF + 500
        LOOP
    CASE 'G':
        RCH()
        A := RDN()
        UNLESS A<GSZ ERROR(2)
        UNLESS CH='L' ERROR(3)
        RCH()
        G!A := LOFF + RDN()
        LOOP
    CASE '0': CASE '1': CASE '2': CASE '3': CASE '4':
    CASE '5': CASE '6': CASE '7': CASE '8': CASE '9':
        F := 'B'
        A := LOFF + RDN()
        ENDCASE
    CASE 'A': CASE 'F': CASE 'J': CASE 'K':
    CASE 'L': CASE 'S': CASE 'T': CASE 'X':
        RCH()
        IF CH='I' $( I := 1; RCH() $)
        T := CH='G' -> T.LG,
             CH='P' -> T.LP,
             CH='L' -> T.LL, T.N
        IF F='S' $( IF T=T.N ERROR(4); I := I + 1 $)
        IF T RCH()
        A := RDN()
        IF T=T.LL A := A + LOFF
        T := I << 2 | T
        ENDCASE
    CASE 'C':
        RCH()
        A := RDN()
        ENDCASE
    CASE 'D':
        RCH()
        IF CH='L' $( T := T.LL; RCH() $)
        A := RDN()
        IF T=T.LL A := A + LOFF
    $)
    GENER(F, A, T)
$) REPEAT

AND GENER(F1, A1, T1) BE
$(  STATIC $(
        F=0; A=0; T=0
        F0=0; A0=0; T0=0
        XL=0
    $)

    LET XDYADIC(X) = 5<=X<=21 | X=32 | 35<=X<=37

    AND XFORCE(X, T) =
        (5<=X<=7 & T=T.N) |
        (16<=X<=17 & T NE T.N) |
        X>=32

    AND LOAD(R, J, FORCE) BE
    $(  LET E = T=T.LP | T=T.LG
        AND M = E | (NOT J & T=T.LL)
        AND I = T>=T.IR
        IF FORCE | M | I $(
            CODE1(E -> A.LEA, A.MOV, A, T, R)
            IF M & NOT J CODE1(A.SHR, 2, T.N, R)
            A, T := R, I -> T.IR, T.R
        $)
    $)

    LET X = ?
    SWITCHON F INTO $(
    CASE 0:
        ENDCASE
    CASE 'B':
        UNLESS LN<LSZ ERROR(5)
        L!LN := A
        LN := LN + 1
        ENDCASE
    CASE 'D':
        SECT := 1
        DATA(".long @A", A, T)
        SECT := 0
        ENDCASE
    CASE 'C':
        SECT := 1
        DATA(".byte @A", A, 0)
        UNLESS F1='C' EMIT(".align @N,0", 0, T.N, WORDSZ, FALSE)
        SECT := 0
        ENDCASE
    CASE 'L':
        X := F1='X' & XDYADIC(A1) -> 1, 0
        LOAD(X, FALSE, X=0 | XFORCE(A1, T))
        ENDCASE
    CASE 'A': CASE 'S':
        LOAD(1, FALSE, FALSE)
        CODE((F='A' -> A.ADD, A.MV2), A, T)
        ENDCASE
    CASE 'J':
        LOAD(1, TRUE, FALSE)
        CODE(A.JMP, A, T)
        ENDCASE
    CASE 'T': CASE 'F':
        UNLESS T=T.LL ERROR(6)
        X := A0
        UNLESS F0='X' & 10<=X<=15 $(
            EMIT("test@S @0,@0")
            X := 11
        $)
        CODE((X - 10) NEQV (F='F' -> 1, 0), A, T)
        ENDCASE
    CASE 'K':
        UNLESS T=T.N ERROR(7)
        EMIT("mov@S @5,@1")
        EMIT("add@S @A,@5", A << SHIFT, T.N, 0, FALSE)
        EMIT("mov@S @1,(@5)")
        EMIT("mov@S $1f,@N(@5)", 0, T.N, WORDSZ, FALSE)
        EMIT("jmp **@0")
        EMIT("1:")
        ENDCASE
    CASE 'X':
        SWITCHON A INTO $(
        DEFAULT: ERROR(8)
        CASE 1:
            EMIT("mov@S (,@0,@N),@0", 0, T.N, 1<<SHIFT, FALSE)
            ENDCASE
        CASE 2:
            EMIT("neg@S @0")
            ENDCASE
        CASE 3:
            EMIT("xor@S $-1,@0")
            ENDCASE
        CASE 4:
            EMIT("mov@S @N(@5),@1", 0, T.N, WORDSZ, FALSE)
            EMIT("mov@S (@5),@5")
            EMIT("jmp **@1")
            ENDCASE
        CASE 5:
            CODE(A.MUL, A0, T0)
            ENDCASE
        CASE 6: CASE 7:
            EMIT(WORDSZ=8 -> "cqto", "cltd")
            CODE(A.DIV, A0, T0)
            IF A=7
                EMIT("mov@S @2,@0")
            ENDCASE
        CASE 8:
            CODE(A.ADD, A0, T0)
            ENDCASE
        CASE 9:
            CODE(A.SUB, A0, T0)
            ENDCASE
        CASE 10: CASE 11: CASE 12: CASE 13: CASE 14: CASE 15:
            CODE(A.CMP, A0, T0)
            IF F1='F' | F1='T'
                ENDCASE
            EMIT(ASTR(A - 10 + A.SNE))
            EMIT(WORDSZ=8 -> "movzbq %al,%rax", "movzbl %al,%eax")
            EMIT("dec@S @0")
            ENDCASE
        CASE 16:
            CODE(T0=T.N -> A.SHL, A.SL2, A0, T0)
            ENDCASE
        CASE 17:
            CODE(T0=T.N -> A.SHR, A.SR2, A0, T0)
            ENDCASE
        CASE 18:
            CODE(A.AND, A0, T0)
            ENDCASE
        CASE 19:
            CODE(A.OR, A0, T0)
            ENDCASE
        CASE 20:
            CODE(A.XOR, A0, T0)
            ENDCASE
        CASE 21:
            EMIT("xor@S $-1,@0")
            CODE(A.XOR, A0, T0)
            ENDCASE
        CASE 22:
            EMIT("jmp finish")
            ENDCASE
        CASE 23:
            EMIT("mov@S @A,@6", XL, T.LL, 0, FALSE)
            EMIT("mov@S (@6),@1")
            EMIT("mov@S @N(@6),@2", 0, T.N, WORDSZ, FALSE)
            EMIT(WORDSZ=8 -> "jrcxz 2f", "jecxz 2f")
            EMIT("1:")
            EMIT("add@S $@N,@6", 0, T.N, WORDSZ*2, FALSE)
            EMIT("cmp@S (@6),@0")
            EMIT("je 3f")
            EMIT("loop 1b")
            EMIT("2:")
            EMIT("jmp **@2")
            EMIT("3:")
            EMIT("jmp **@N(@6)", 0, T.N, WORDSZ, FALSE)
            L!LN := XL
            LN := LN + 1
            XL := XL + 1
            ENDCASE
        CASE 24:
            EMIT("call selectinput")
            ENDCASE
        CASE 25:
            EMIT("call selectoutput")
            ENDCASE
        CASE 26:
            EMIT("call rdch")
            ENDCASE
        CASE 27:
            EMIT("call wrch")
            ENDCASE
        CASE 28:
            EMIT("call findinput")
            ENDCASE
        CASE 29:
            EMIT("call findoutput")
            ENDCASE
        CASE 30:
            EMIT("jmp stop")
            ENDCASE
        CASE 31:
            EMIT("mov@S (@5),@0")
        ENDCASE
    CASE 32:
            EMIT("mov@S @1,@5")
            EMIT("jmp **@0")
            ENDCASE
        CASE 33:
            EMIT("call endread")
            ENDCASE
        CASE 34:
            EMIT("call endwrite")
            ENDCASE
        CASE 35:
            EMIT("mov@S @5,@6")
            EMIT("mov@S @0,@3")
            EMIT("inc@S @3")
            EMIT("shl@S $@N,@3", 0, T.N, SHIFT, FALSE)
            EMIT("add@S @3,@6")
            EMIT("mov@S (@5),@3")
            EMIT("mov@S @3,(@6)")
            EMIT("mov@S @N(@5),@3", 0, T.N, WORDSZ, FALSE)
            EMIT("mov@S @3,@N(@6)", 0, T.N, WORDSZ, FALSE)
            EMIT("mov@S @5,@3")
            EMIT("shr@S $@N,@3", 0, T.N, SHIFT, FALSE)
            EMIT("mov@S @3,@N(@6)", 0, T.N, WORDSZ*2, FALSE)
            EMIT("mov@S @0,@N(@6)", 0, T.N, WORDSZ*3, FALSE)
            EMIT("mov@S @6,@5")
            EMIT("jmp **@1")
            ENDCASE
        CASE 36:
            EMIT("shl@S $@N,@1", 0, T.N, SHIFT, FALSE)
            EMIT("add@S @0,@1")
            EMIT(WORDSZ=8 -> "movzbq (@1),%rax", "movzbl (@1),%eax")
            ENDCASE
        CASE 37:
            EMIT("shl@S $@N,@1", 0, T.N, SHIFT, FALSE)
            EMIT("add@S @0,@1")
            EMIT("mov@S @N(@5),@0", 0, T.N, WORDSZ*4, FALSE)
            EMIT("movb %al,(@1)")
            ENDCASE
        CASE 38:
            EMIT("call input")
            ENDCASE
        CASE 39:
            EMIT("call output")
            ENDCASE
        CASE 40:
            EMIT("call unrdch")
            ENDCASE
        CASE 41:
            EMIT("call rewind")
        $)
    $)
    F0, A0, T0 := F, A, T
    F, A, T := F1, A1, T1
$)

AND EPILOG() BE
$(  SECT := 1
    EMIT(".global G")
    EMIT(".align @N", 0, T.N, WORDSZ, FALSE)
    EMIT("G:")
    FOR I = 0 TO GSZ-1
        EMIT(".long @A # @N", G!I, G!I -> T.LL, T.N, I, 1)
$)

AND CODE(OP, A, T) BE CODE1(OP, A, T, 0)
AND CODE1(OP, A, T, R) BE EMIT(ASTR(OP), A, T, R, OP<=A.JMP)
AND DATA(S, A, T) BE EMIT(S, A, T, 0, TRUE)

AND ASTR(X) = VALOF
    SWITCHON X INTO $(
    CASE A.JE:  RESULTIS "je @A"
    CASE A.JNE: RESULTIS "jne @A"
    CASE A.JL:  RESULTIS "jl @A"
    CASE A.JGE: RESULTIS "jge @A"
    CASE A.JG:  RESULTIS "jg @A"
    CASE A.JLE: RESULTIS "jle @A"
    CASE A.JMP: RESULTIS "jmp @A"
    CASE A.MUL: RESULTIS "imul@S @A"
    CASE A.DIV: RESULTIS "idiv@S @A"
    CASE A.MOV: RESULTIS "mov@S @A,@R"
    CASE A.ADD: RESULTIS "add@S @A,@R"
    CASE A.SUB: RESULTIS "sub@S @A,@R"
    CASE A.CMP: RESULTIS "cmp@S @A,@R"
    CASE A.SHL: RESULTIS "shl@S @A,@R"
    CASE A.SHR: RESULTIS "shr@S @A,@R"
    CASE A.AND: RESULTIS "and@S @A,@R"
    CASE A.OR:  RESULTIS "or@S @A,@R"
    CASE A.XOR: RESULTIS "xor@S @A,@R"
    CASE A.MV2: RESULTIS "mov@S @R,@A"
    CASE A.LEA: RESULTIS "lea@S @A,@R"
    CASE A.SL2: RESULTIS "shll %cl,@R"
    CASE A.SR2: RESULTIS "shrl %cl,@R"
    CASE A.SNE: RESULTIS "setne %al"
    CASE A.SE:  RESULTIS "sete %al"
    CASE A.SGE: RESULTIS "setge %al"
    CASE A.SL:  RESULTIS "setl %al"
    CASE A.SLE: RESULTIS "setle %al"
    CASE A.SG:  RESULTIS "setg %al"
    DEFAULT: ERROR(9)
    $)

AND EMIT(S, A, T, X, J) BE
$(  STATIC $( PSECT=0 $)
    UNLESS SECT=PSECT $(
        WRITES(SECT=0 -> ".text", ".data"); WRCH('*N')
        PSECT := SECT $)
    IF LN $(
        WRITES(".align ")
        WRN(WORDSZ)
        FOR I = 0 TO LN - 1 $( WRCH('L'); WRN(L!I); WRITES(":*N") $)
        LN := 0 $)
    FOR I = 1 TO GETBYTE(S, 0) $(
        LET C = GETBYTE(S, I)
        TEST C='@' $(
            I := I + 1
            LET D = GETBYTE(S, I)
            SWITCHON D INTO $(
            CASE 'A':
                TEST NOT J & (T=T.N | T=T.LL) WRCH('$')
                OR IF J & T>=T.R WRCH('**')
                ARGOUT(A, T)
                ENDCASE
            CASE 'N':
                ARGOUT(X, T.N)
                ENDCASE
            CASE 'R':
                ARGOUT(X, T.R)
                ENDCASE
            CASE 'S':
                WRITES(WORDSZ=8 -> "q", "l")
                ENDCASE
            DEFAULT:
                IF '0'<=D<='9' $( WRREG(D - '0') $) OR $( WRCH('@'); WRCH(D) $)
            $)
         $) OR WRCH(C)
    $)
    WRCH('*N')
$)

AND WRREG(R) BE
$(  IF WORDSZ=8 $(
        SWITCHON R INTO $(
            CASE RAX: WRITES("%rax")
            CASE RCX: WRITES("%rcx")
            CASE RDX: WRITES("%rdx")
            CASE RBX: WRITES("%rbx")
            CASE RSP: WRITES("%rsp")
            CASE RBP: WRITES("%rbp")
            CASE RSI: WRITES("%rsi")
            CASE RDI: WRITES("%rdi")
        $)
    $) OR $(
        SWITCHON R INTO $(
            CASE RAX: WRITES("%eax")
            CASE RCX: WRITES("%ecx")
            CASE RDX: WRITES("%edx")
            CASE RBX: WRITES("%ebx")
            CASE RSP: WRITES("%esp")
            CASE RBP: WRITES("%ebp")
            CASE RSI: WRITES("%esi")
            CASE RDI: WRITES("%edi")
        $)
    $)
$)

AND ARGOUT(A, T) BE
$(  TEST T=T.R | T=T.IR $(
        IF T=T.IR WRITES("(,")
        WRREG(A)
        IF T=T.IR WRITES(",4)")
    $) OR $(
        LET K, E = T & 3, K=T.LP | K=T.LG
        IF K=T.LL WRCH('L')
        IF E DO A := A * WORDSZ
        WRN(A)
        IF E $( WRCH('('); WRREG(K=T.LP -> RBP, RDI); WRCH(')') $)
    $)
$)

AND WRN(N) BE
$(  TEST N<0 WRCH('-') OR N := -N
    IF N<-9 WRN(-N / 10)
    WRCH('0' - N REM 10)
$)

AND RDN() = VALOF
$(  LET X, N, I = 0, FALSE, 0
    IF CH='-' $( N := TRUE; RCH() $)
    WHILE '0' <= CH <= '9' $(
        X := X * 10 - (CH - '0')
        I := I + 1
        RCH()
    $)
    IF I=0 ERROR(10)
    RESULTIS N -> X, -X
$)

AND RCH() BE
$(  RCH1()
    UNLESS CH='/' RETURN
    $( RCH1();
       IF CH=ENDSTREAMCH DO ERROR(11)
    $) REPEATUNTIL CH='*N'
$) REPEAT

AND RCH1() BE
$(  IF CH='*N' LINE, COL := LINE + 1, 0
    COL := COL + 1
    CH := RDCH()
$)

AND ERROR(N) BE
$(  SELECTOUTPUT(ERR)
    UNLESS LINE=0
        WRITEF("stdin(%N,%N): ", LINE, COL)
    WRITEF("xg error %N*N", N)
    STOP(1)
$)
