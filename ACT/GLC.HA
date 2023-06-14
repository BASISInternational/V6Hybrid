0010 REM "GLC - Budgets Not Implemented Warning"
0020 REM "Program GLC.HA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0045 REM "STATUS: 0=No error (returned)"
0050 REM 
0080 SETERR 9000
0085 SETESC 9900
0090 ENTER STATUS
0500 REM " --- Initializations"
0510 DIM MESSAGE$[1]
0550 LET MESSAGE$[0]="The "+$22$+"Use Budgets?"+$22$+" G/L Parameter Is Set To
0550: "+$22$+"No"+$22$+". This Task May Not Be"
0560 LET MESSAGE$[1]="Used Unless This Parameter Is Set To "+$22$+"Yes"+$22$+"
0560: (<Enter>=Continue)"
1000 REM " --- Display message"
1010 CALL "SYC.XA",2,MESSAGE$[ALL],1,22,-1,V$,V3
4000 REM " --- All Done"
4010 LET STATUS=0
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
9205 SETESC 9000
9210 SETERR 9000
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 REM " --- Return to Calling Program"
9950 EXIT
9999 END
