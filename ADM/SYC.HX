0010 REM "SYC - Verify Entered Hex Code"
0020 REM "Program SYC.HX"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0045 REM "HEX$  : Hex code to verify (input)"
0050 REM "STATUS: 0=No error (returned)"
0060 REM 
0070 SETERR 9000
0080 SETESC 9000
0090 ENTER HEX$,STATUS
0500 REM " --- Initializations"
0510 DIM MESSAGE$[2]
0550 LET STATUS=99,HEX$=FNP$(HEX$),L=LEN(HEX$),VALID$="0123456789ABCDEF"
1000 REM " --- Even number of characters?"
1010 IF L=0 THEN GOTO 2000
1020 IF MOD(L,2) THEN GOTO 3000
1200 REM " --- Valid characters?"
1210 FOR X=1 TO L
1220 IF POS(HEX$(X,1)=VALID$)=0 THEN EXITTO 3000
1230 NEXT X
2000 REM " --- Hex code is OK"
2010 LET STATUS=0
2090 GOTO 4000
3000 REM " --- Display warning"
3010 LET MESSAGE$[0]="Hex Code Strings Must Consist Of An Even Number Of Chara
3010:cters"
3020 LET MESSAGE$[1]="And May Only Contain A Combination Of Digits And The Let
3020:ters"
3030 LET MESSAGE$[2]=$22$+"A"+$22$+" through "+$22$+"F"+$22$+" (<Enter>=Contin
3030:ue)"
3040 CALL "SYC.XA",2,MESSAGE$[ALL],2,22,-1,V$,V3
3050 IF V$="SPECIAL" THEN LET STATUS=0
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
9900 REM " --- Return to calling program"
9950 EXIT
9999 END
