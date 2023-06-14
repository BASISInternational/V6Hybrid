0010 REM "APR - Cash Requirements Report (Sort Overlay)"
0020 REM "Program APR.BB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files"
0170 CALL "SYC.GA",7,1,"","",STATUS
0175 IF STATUS THEN GOTO 9900
0200 REM " --- IOLists
0220 APM01A: IOLIST B0$(1),B1$(1)
0230 APW02A: IOLIST K$
0500 REM " --- Initializations"
0510 DIM B0$(8),B1$(198)
0550 LET T0$="",M0=LEN(M0$),W=3+MAX(M0,10)
0700 REM " --- Background"
0710 CALL "SYC.NB"," Sorting",W,COLUMN
0800 REM " --- Options"
0810 IF SEQUENCE$<>"A" THEN GOTO 4000
0900 REM " --- File Initializations"
0990 READ (APT01_DEV,KEY=N0$,DOM=1000)
1000 REM " --- Get next key"
1010 LET K$=KEY(APT01_DEV,END=4000)
1020 IF POS(N0$=K$)<>1 THEN GOTO 4000
1100 REM " --- Read next invoice header"
1110 READ (APT01_DEV)
1200 REM " --- New vendor?"
1220 DIM B0$(8),B1$(198),X$(MAX(M0,4))
1230 LET B0$(1)=N0$+K$(5,6),X$(1)=B0$(3)
1240 FIND (APM01_DEV,KEY=B0$,DOM=1250)IOL=APM01A
1250 IF B0$(3,4)<>"TEMP" THEN LET X$(1)=FNF$(B0$(3,P[0]),M0$)
1290 PRINT @(COLUMN,11),K$(3,2)," ",X$
2000 REM " --- Write sort record"
2010 LET K$=K$(1,4)+B1$(146,10)+K$(5)
2020 WRITE (APW02_DEV,KEY=K$)IOL=APW02A
3900 REM " --- Loop back for next record"
3990 GOTO 1000
4000 REM " --- Run report overlay"
4090 RUN REPORT$,ERR=9900
8000 REM " --- Functions"
8200 REM " --- FNF$ AlphaNumeric Masking Function"
8210 DEF FNF$(Q1$,Q2$)
8220 IF Q2$="" THEN LET Q2$=FILL(LEN(Q1$),"0")
8230 RETURN STR(-NUM(Q1$,ERR=ALPHA_FNF):Q2$,ERR=ALPHA_FNF)
8240 ALPHA_FNF:
8245 LET Q=1,Q0=0
8250 WHILE LEN(Q2$(Q))
8255 IF POS(Q2$(Q,1)="-()") THEN LET Q0=Q0+1 ELSE LET Q2$(Q,1)="X"
8260 LET Q=Q+1
8265 WEND
8270 IF LEN(Q1$)>LEN(Q2$)-Q0 THEN LET Q1$=Q1$(1,LEN(Q2$)-Q0)
8280 RETURN STR(Q1$:Q2$)
8290 FNEND
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
9210 SETERR 9000
9220 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 RUN "SYS.AA"
9999 END
