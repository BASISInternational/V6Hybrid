0010 REM "SYC - Make File Like Another"
0020 REM "Program SYC.ML
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0060 REM "MAKE$ : Name of file to make (input)"
0062 REM "LIKE$ : Name of template file (input)"
0064 REM "STATUS: Zero=No Error/Non-Zero=Error (returned)"
0070 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER MAKE$,LIKE$,STATUS
1000 REM " --- Verify File Names"
1020 LET STATUS=0
1040 IF FNP$(MAKE$)="" THEN LET STATUS=998
1060 IF LEN(LIKE$)<6 THEN LET STATUS=997
1080 IF STATUS>0 THEN GOTO 9900
1100 REM " --- Open Batching Template File"
1110 LET PROCESS$=STBL("!PROCESS",ERR=1200),LIKE_DEV=UNT
1120 OPEN (LIKE_DEV,ERR=1150)LIKE$; REM "Can't use SYC.DA for batched files
1130 GOTO 1500
1150 LET STATUS=996
1160 IF ERR=12 THEN LET STATUS=912
1190 GOTO 9900
1200 REM " --- Open Non-Batching Template File"
1210 DIM FILES$[1],OPTIONS$[1],CHANNELS[1]
1220 LET FILES$[1]=LIKE$
1230 CALL "SYC.DA",1,1,1,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
1240 IF STATUS THEN GOTO 9900
1250 LET LIKE_DEV=CHANNELS[1]
1290 GOTO 1500
1500 REM " --- Get Parameters From Template File"
1520 CALL "SYC.JA",LIKE_DEV,FILENAME$,PATHNAME$,FILETYPE$,KEYLEN,RECORDS,RECLE
1520:N,NUMREC,STATUS
1530 IF STATUS THEN GOTO 9900
2000 REM " --- Create New File"
2020 IF FILETYPE$="K" THEN LET FILETYPE$="D"
2040 CALL "SYC.MA",FILETYPE$,MAKE$,LIKE$(1,2),STR(KEYLEN),0,RECLEN,STATUS
2060 IF STATUS THEN GOTO 9900
4000 REM " --- Done"
4020 LET STATUS=0
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
9220 LET STATUS=ERR
9240 IF STATUS=0 THEN LET STATUS=999
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 REM " --- Return to caller"
9910 CLOSE (LIKE_DEV,ERR=9950)
9950 EXIT
9999 END
