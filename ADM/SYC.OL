0010 REM "SYC - Load Options (Lookup Programs)"
0020 REM "Program SYC.OL"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0042 REM "PGM$       : Calling program/menu name (input)"
0044 REM "OPTIONS    : Number of options on menu (returned)"
0046 REM "WIDTH      : Width of longest option (returned)"
0048 REM "OPTLIST$[n]: Standard options list (returned)"
0050 REM "PARAM$[n]  : Lookup parameters (returned)"
0052 REM "TITLE$     : Title for lookup window (returned)"
0054 REM "MAXROW     : Maximum number of options allowed (input)"
0056 REM "KEYMASK$   : Optional key mask (e.g. Customer mask) (input)"
0058 REM "KEYLEN     : Optional key length (e.g. item number length) (input)"
0075 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER PGM$,OPTIONS,WIDTH,OPTLIST$[ALL],PARAM$[ALL],TITLE$,MAXROW,KEYMASK$
0090:,KEYLEN
0100 REM " --- Open/Lock Files"
0110 LET FILES=3
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0130 LET FILES$[1]="SYS-01",FILES$[2]="SYM-01",FILES$[3]="SYM-11"
0150 CALL "SYC.DA",1,1,FILES,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STA
0150:TUS
0160 IF STATUS>0 THEN GOTO 9900
0170 LET SYS01_DEV=CHANNELS[1],SYM01_DEV=CHANNELS[2],SYM11_DEV=CHANNELS[3]
0200 REM " --- IOLIST's"
0260 SYS01T: IOLIST TERMINAL$,F0$
0400 REM " --- Parameters"
0410 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9900)IOL=SYS01T
0500 REM " --- Initializations"
0550 LET SECURITY$=F0$(15,1),WIDTH=0,TITLE$=""
1000 REM " --- Load option array for current menu"
1010 CALL "SYC.QC",SYM01_DEV,SYM11_DEV,PGM$,SECURITY$,OPTIONS,OPTLIST$[ALL],TI
1010:TLE$,MAXROW,X$,NAME$
1100 REM " --- Store options"
1110 FOR X=1 TO OPTIONS
1120 LET WIDTH=MAX(WIDTH,LEN(OPTLIST$[1,X,1])),PARAMETER$=OPTLIST$[1,X,3]
1200 REM " --- Extract data type"
1210 IF PARAMETER$="" THEN GOTO 3900
1220 IF OPTLIST$[1,X,4]<>"L" THEN GOTO 2000
1230 LET PARAM$[1,X,1]="S"
1240 LET P=POS("TYPE="=PARAMETER$)
1250 IF P=0 THEN GOTO 1300
1260 LET PARAM$[1,X,1]=PARAMETER$(P+5,1)
1300 REM " --- Extract length"
1310 LET PARAM$[1,X,2]="1"
1320 LET P=POS("LEN="=PARAMETER$)
1330 IF P=0 THEN GOTO 1400
1340 LET X$=PARAMETER$(P+4),P=POS(","=X$)
1350 IF P=0 THEN LET P=LEN(X$)
1360 IF X$(1,P)<>"KEY" THEN GOTO 1380
1365 LET P=KEYLEN
1370 GOTO 1390
1380 LET P=NUM(X$(1,P),ERR=1400)
1390 LET PARAM$[1,X,2]=STR(P)
1400 REM " --- Extract mask"
1410 LET P=POS("MASK="=PARAMETER$)
1420 IF P=0 THEN GOTO 1500
1430 LET X$=PARAMETER$(P+5),P=POS(","=X$)-1
1440 IF P<1 THEN LET P=LEN(X$)
1450 LET PARAM$[1,X,3]=X$(1,P)
1460 IF POS("TYPE="=PARAMETER$)=0 THEN LET PARAM$[1,X,1]="M"
1470 IF PARAM$[1,X,3]="KEY" THEN LET PARAM$[1,X,3]=KEYMASK$
3900 REM " --- Loop back for next element"
3990 NEXT X
4000 REM " --- All done"
4010 FOR X=1 TO OPTIONS
4020 LET WIDTH=MAX(MAX(NUM(PARAM$[1,X,2]),WIDTH),LEN(FNP$(PARAM$[1,X,3])))
4030 NEXT X
4090 GOTO 9900
8000 REM " --- Functions"
8080 DEF FNP$(Q$)=CVS(Q$,2)
9000 REM " --- Standard Error Routine (15May95)"
9010 IF ERR=127 THEN GOTO 9300
9020 CALL "SYC.EA",ERR=9090,EXIT_CTRL,PGM(-2),ERR,TCB(5),E$,E1,E2
9030 IF E1=1 THEN GOTO 9100
9040 IF E1=3 THEN GOTO 9200
9080 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9090 ESCAPE
9100 REM " --- Retry"
9190 RETRY
9200 REM " --- Return"
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 REM " --- Return to caller"
9910 FOR X=1 TO FILES
9920 CLOSE (CHANNELS[X],ERR=9921)
9930 NEXT X
9950 EXIT
9999 END
