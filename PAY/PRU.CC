0010 REM "PRU - Check Update (Labor Distribution)"
0020 REM "Program PRU.CC"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLists
0210 PRW04A: IOLIST A0$,A[ALL]
0220 PRT05A: IOLIST B0$,B[ALL]
0500 REM " --- Init Data
0510 DIM A[1],B[11]
0520 LET P8=POS(FNYY_YY21$(FNC2$(P8$))<=P7$,4),P8=INT((P8+3)/4)
0700 REM " --- Background
0710 PRINT @(COLUMN,11),"       ",
1000 REM " --- Accumulate Labor Dist
1020 READ (PRW04_DEV,KEY=N0$,DOM=1030)
1100 REM " --- Main Read
1120 LET K0$=KEY(PRW04_DEV,END=4000)
1140 READ (PRW04_DEV)IOL=PRW04A
1160 IF A0$(1,2)<>N0$ THEN GOTO 4000
1170 PRINT @(COLUMN,11),A0$(3,2),
1200 REM " --- Update
1220 LET B0$=A0$
1240 DIM B[11]
1250 FIND (PRT05_DEV,KEY=B0$,DOM=1260)IOL=PRT05A
1260 IF P8$<=G9$ THEN LET B[0]=B[0]+A[1],B[6]=B[6]+A[0]
1270 IF P8<>0 THEN LET B[P8]=B[P8]+A[1],B[6+P8]=B[6+P8]+A[0]
1280 IF P8$>G9$ THEN LET B[5]=B[5]+A[1],B[11]=B[11]+A[0]
1290 WRITE (PRT05_DEV,KEY=B0$)IOL=PRT05A
1400 REM " --- Remove
1420 REMOVE (PRW04_DEV,KEY=K0$)
1490 GOTO 1100
4000 REM " --- End
4010 IF GL$="Y" THEN CALL "GLC.CA",STATUS
4090 GOTO 9900
8000 REM " --- Functions
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8035 DEF FNC2$(Q1$)=FNA$(Q1$(1),Q1$)+FNA$(Q1$(2),Q1$)
8120 REM " --- FNYY_YY21$ Convert 2-Char Year to 21st Century 2-Char Year"
8125 DEF FNYY_YY21$(Q1$)
8130 LET Q3$=" ABCDE56789ABCDEFGHIJ",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABC
8130:DEFGHIJ"))
8135 RETURN Q1$
8140 FNEND
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
9900 RUN "SYS.AA"
9999 END
