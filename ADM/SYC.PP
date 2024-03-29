0010 REM "SYC - Public Program Manager"
0020 REM "Program SYC.PP"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0045 REM "ACTION$: Action Code - A=Add/D=Drop (Input)"
0050 REM "PGM$   : Program name or null for all (Input)"
0055 REM "STATUS : 0=No Error (Returned)"
0060 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER ACTION$,PGM$,STATUS
0100 REM " --- Open/Lock Files"
0105 IF PGM$="" THEN GOTO 0500
0110 DIM FILES$[1],OPTIONS$[1],CHANNELS[1]
0120 LET FILES$[1]="SYM-05",STATUS=0
0150 CALL "SYC.DA",1,1,1,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0160 IF STATUS>0 THEN GOTO 9900
0170 LET SYM05_DEV=CHANNELS[1]
0200 REM " --- IOLIST's"
0210 SYM05A: IOLIST A0$(1),A1$(1),A2$(1)
0500 REM " --- Initializations"
0510 DIM A0$(11),A1$(8),A2$(64)
0550 LET X=0
0800 REM " --- Drop all programs?"
0810 IF PGM$="" THEN GOTO 3000
0900 REM " --- Position file"
0990 READ (SYM05_DEV,KEY=PGM$,DOM=1000)
1000 REM " --- Read next"
1010 LET K$=KEY(SYM05_DEV,END=4000)
1020 IF POS(PGM$=K$)<>1 THEN GOTO 4000
1030 READ (SYM05_DEV)IOL=SYM05A
1040 IF ACTION$="D" THEN DROP FNP$(A1$),ERR=1900
1050 IF ACTION$="A" THEN IF A2$(51,1)="Y" THEN ADDR FNP$(A1$),ERR=1900
1900 REM " --- Loop back for next ADDR'd program"
1990 GOTO 1000
3000 REM " --- Drop all public programs"
3010 IF ACTION$<>"D" THEN GOTO 4000
3200 REM " --- Main Process"
3210 LET X$=PUB(X,ERR=4000)
3220 DROP X$(17),ERR=3250
3230 GOTO 3200
3250 LET X=X+1
3290 GOTO 3200
4000 REM " --- All done"
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
9910 CLOSE (SYM05_DEV,ERR=9911)
9950 EXIT
9999 END
