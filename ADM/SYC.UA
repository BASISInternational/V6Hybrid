0010 REM "SYC - Return fully qualified pathname of file"
0020 REM "Program SYC.UA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0045 REM "FILENAME$: Name of file to return path for (input)"
0050 REM "PATHNAME$: Fully qualified pathname of FILENAME$ (returned)"
0055 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER FILENAME$,PATHNAME$
0100 REM " --- Open/Lock Files"
0105 LET FILES=1
0110 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0120 LET FILES$[1]=FILENAME$,OPTIONS$[1]="F"
0140 CALL "SYC.DA",1,1,FILES,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STA
0140:TUS
0150 IF STATUS>0 THEN GOTO 9900
0160 LET CHANNEL=CHANNELS[1]
1000 REM " --- Retrieve pathname using FID"
1010 LET PATHNAME$=""
1020 IF CHANNEL>0 THEN LET PATHNAME$=FID(CHANNEL),PATHNAME$=PATHNAME$(9)
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
9900 REM " --- Return to caller"
9910 CLOSE (CHANNEL,ERR=9920)
9950 EXIT
9999 END
