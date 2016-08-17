0010 REM "SHC - Open Scale Port as Raw Device"
0020 REM "Program SHC.GS"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.5 - 01Dec98 |"
0026 REM "|         Copyright (c) 1997 ADD+ON Software Inc.           |"
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0031 REM "13May97 JAL: Error 36/Line 90 (90)"
0032 REM "05Feb98 JWK: Solve ERR 14 when opening scale (90)
0033 REM "16Oct98 WGH: Return Errors opening scale (90,550,2030)
0040 REM 
0045 REM "SCALE_DEV: Channel to open scale on (input)"
0050 REM "SCALE$   : Scale Port ID (input)"
0055 REM "STATUS   : 0=No error (returned)"
0060 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER SCALE_DEV,SCALE$,STATUS
0500 REM " --- Initializations"
0550 LET STATUS=0,DEVICE=0,DEVICE$=""
1000 REM " --- Extract full device name from config file"
1010 WHILE DEVICE$=""
1020 LET ALIAS$=TSK(DEVICE)
1030 IF ALIAS$(3,2)=SCALE$ THEN LET DEVICE$=ALIAS$(5)
1040 LET DEVICE=DEVICE+1
1090 WEND
2000 REM " --- Open port"
2010 LET P=POS("/"=DEVICE$)
2020 IF P>0 THEN LET DEVICE$=DEVICE$(P)
2030 OPEN (SCALE_DEV,ERR=9200)DEVICE$
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
9210 LET STATUS=ERR
9220 IF STATUS=0 THEN LET STATUS=999
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 REM " --- Return to caller"
9950 EXIT
9999 END
