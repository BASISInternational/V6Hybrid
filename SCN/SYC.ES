0010 REM "SYC - Trap User ESCAPE's"
0020 REM "Program SYC.ES"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0031 REM "09Nov00 KJS: Modifications for the Web Kit (a95)
0040 REM 
0042 REM "PROGNAME$ : Name of program which trapped ESCAPE (input)"
0044 REM "LINE      : Line number where ESCAPE was trapped (input)"
0046 REM "STATEMENT$: Statement listing of LINE (output)"
0048 REM "ROW       : Last row in current window/screen (output)"
0050 REM "FKEY      : Function key value (output)"
0052 REM "            FKEY=127  -> exit to console mode"
0054 REM "            FKEY<>127 -> continue processing"
0055 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER PROGNAME$,LINE,STATEMENT$,ROW,FKEY
0095 IF FID(0)="IO" THEN LET FKEY=0; GOTO 9950
0100 REM " --- Open/Lock Files"
0105 LET KEYBOARD=UNT
0110 OPEN (KEYBOARD)FID(0)
0500 REM " --- Initializations"
0550 LET WIDTH=38,FKEY=0,PASSWORD$="",STATEMENT$="",ROW=22
0560 LET PASSWORD$=STBL("!SCREEN",ERR=0570),PASSWORD$=FNP$(PASSWORD$(1,8))
0570 IF PASSWORD$<>"" THEN LET WIDTH=42
0580 LET WIN_X=INT((80-WIDTH)/2)
0700 REM " --- Background"
0710 CALL "SYC.WA",0,WIDTH,3,WIN_X,10,"Source Code Security",NAME$
1000 REM " --- No source code password"
1010 IF PASSWORD$<>"" THEN GOTO 2000
1050 INPUT (0,LEN=1,ERR=1050)'CS','RB','SB'," Escape Requested (<Enter>=Retry)
1050: ",'SF',V$,
1070 IF V$="E" OR CTL=4 THEN LET FKEY=127
1090 GOTO 4000
2000 REM " --- Source code password required"
2010 PRINT 'CS','RB','SB'," Please enter the password [",'SF',"XXXXXXXXXX",'SB
2010:',"]",'SF',@(28,0),
2050 INPUT (KEYBOARD,SIZ=10,TIM=10,ERR=2050)V$,@(0,0),'CL',
2070 IF FNU$(FNP$(V$))=FNU$(PASSWORD$) THEN LET FKEY=127
4000 REM " --- All done"
4010 IF FKEY<>127 THEN GOTO 9900
4020 IF FNP$(PGM$)="" THEN GOTO 9900
4030 IF LINE=0 THEN GOTO 9900
4040 CALL "SYC.UB",0,PROGNAME$,STATEMENT$,STR(LINE),STATUS
4090 GOTO 9900
8000 REM " --- Functions"
8080 DEF FNP$(Q$)=CVS(Q$,2)
8090 DEF FNU$(Q$)=CVS(Q$,4)
9000 REM " --- Trap User ESCAPE Error Routine"
9010 IF ERR=127 THEN GOTO 9900
9020 CALL "SYC.EA",ERR=9090,EXIT_CTRL,PGM(-2),ERR,TCB(5),E$,E1,E2
9030 IF E1=1 THEN GOTO 9100
9040 IF E1=3 THEN GOTO 9200
9080 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9090 ESCAPE
9100 REM " --- Retry"
9190 RETRY
9200 REM " --- Return"
9290 GOTO 9900
9900 REM " --- Return to caller"
9910 CLOSE (KEYBOARD,ERR=9911)
9920 IF NAME$<>"" THEN CALL "SYC.WD",NAME$
9930 LET FIN$=FIN(0),ROW=MIN(DEC(FIN$(8,1)),23)-1
9950 EXIT
9999 END
