0010 REM "SYC - Operating System Interface"
0020 REM "Program SYC.OS"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.5           |
0026 REM "|         Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0031 REM "30Mar98 KJS: Report OS errors (100-420,1010,1090,1100-1170,9920)
0040 REM 
0050 REM "COMMAND$: Operating system command to execute (input)"
0060 REM 
0080 SETESC 9000
0085 SETERR 9000
0090 ENTER COMMAND$
0100 REM " --- Open/Lock Files"
0110 LET FILES=1
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0130 LET FILES$[1]="SYS-01"
0150 CALL "SYC.DA",1,1,FILES,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STA
0150:TUS
0160 IF STATUS THEN LET NOSYS01=1
0170 LET SYS01_DEV=CHANNELS[1]
0200 REM " --- IOLIST's"
0210 SYS01S: IOLIST S0$,S1$,S2$,S3$,S4$,S5$,S6$
0400 REM " --- Parameters"
0410 IF NOSYS01 THEN GOTO 0421
0420 FIND (SYS01_DEV,KEY="S",DOM=0421)IOL=SYS01S
1000 REM " --- Execute system command"
1010 LET OS_STAT=SCALL(COMMAND$)
1090 IF COMMAND$=S5$ OR OS_STAT=0 THEN GOTO 4000
1100 REM " --- Report OS Error"
1110 DIM MESSAGE$[3]
1120 LET MESSAGE$[0]="There was a problem executing the following command:"
1130 LET MESSAGE$[1]=COMMAND$
1140 LET MESSAGE$[2]="The Operating System returned a status of "+STR(OS_STAT)
1150 LET MESSAGE$[3]="Press <Enter> to continue: "
1160 CALL "SYC.XA",1,MESSAGE$[ALL],3,-1,-1,V$,V3
1170 IF V$="SPECIAL" THEN GOTO 9300
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
9910 CALL "SYC.FK",STATUS
9920 CLOSE (SYS01_DEV,ERR=9921)
9950 EXIT
9999 END
