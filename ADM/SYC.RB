0010 REM "SYC - Roll Matrix Pages for Lookups"
0020 REM "Program SYC.RB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0 - 15May96 |"
0026 REM "|      Copyright (c) 1996 Open Systems Holdings Corp.       |"
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0043 REM "LLIST$[n]: Std SpeedSearch/Lookup LLIST$ matrix (input/returned)"
0045 REM "MORE$[n] : Std SpeedSearch/Lookup MORE$ matrix (input/returned)"
0047 REM "PAGES    : Maximum number of pages (input)"
0050 REM "PAGE     : Current page number (returned)"
0053 REM "MAXROW   : Maximum number of rows (input)"
0055 REM "MAXL     : Maximum number of LLIST$ elements (input)"
0057 REM "MAXM     : Maximum number of MORE$ elements (input)"
0060 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER LLIST$[ALL],MORE$[ALL],PAGES,PAGE,MAXROW,MAXL,MAXM
1000 REM " --- LLIST$/MORE$ Full. Drop first page of both"
1010 FOR P=1 TO PAGES-1
1020 FOR R=1 TO MAXROW
1030 FOR X=1 TO MAXL
1035 IF LLIST$[P+1,R,X]<>"" OR LLIST$[P,R,X]<>"" THEN LET LLIST$[P,R,X]=LLIST$
1035:[P+1,R,X]
1040 NEXT X
1050 FOR X=1 TO MAXM
1060 IF MORE$[P+1,R,X]<>"" OR MORE$[P,R,X]<>"" THEN LET MORE$[P,R,X]=MORE$[P+1
1060:,R,X]
1070 NEXT X
1080 NEXT R
1090 NEXT P
1100 REM " --- Blank last page of LLIST$/MORE$"
1110 FOR R=1 TO MAXROW
1120 FOR X=1 TO MAXL
1130 IF LLIST$[PAGES,R,X]<>"" THEN LET LLIST$[PAGES,R,X]=""
1140 NEXT X
1150 FOR X=1 TO MAXM
1160 IF MORE$[PAGES,R,X]<>"" THEN LET MORE$[PAGES,R,X]=""
1170 NEXT X
1190 NEXT R
4000 REM " --- All done"
4090 GOTO 9900
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
9900 REM " --- Return to calling program"
9910 LET PAGE=PAGES-1
9950 EXIT
9999 END
