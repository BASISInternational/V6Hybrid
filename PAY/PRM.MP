0010 REM "PRM - Employee Maintenance - Union History Display
0020 REM "Program PRM.MP"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLists
0290 PRT04A: IOLIST X0$(1),X1$,X[ALL]
0500 REM " --- Init Data
0510 DIM MESSAGE$[1]
0520 DIM X[4],T[4]
0530 LET M5$=M1$,M1$="####,###.00-",M1=LEN(M1$)
0700 REM " --- Background
0720 PRINT @(0,L0),'CE','SB',@(15,5),"Union History Inquiry",@(0,6),"Union",@(
0720:7),"Pay Date",@(17+M2-6),"Hours",@(18+M2+M1-9),"Earnings",@(19+M2+2*M1-7)
0720:,"Deduct",@(20+M2+3*M1-6),"Taxes",@(21+M2+4*M1-8),"Contrib",'SF',
0900 REM " --- Init File
0910 LET X9$=N0$+A1$(238,3)+A1$(1,30)+A0$(3,9)
0920 READ (PRT04_DEV,KEY=X9$,DOM=0930)
0940 LET T0=0
0950 LET L=L0+1
1000 REM " --- Display
1005 DIM K$(47),X0$(47)
1010 LET K$(1)=KEY(PRT04_DEV,END=4000)
1020 IF K$(1,LEN(X9$))<>X9$ THEN GOTO 4000
1030 READ (PRT04_DEV)IOL=PRT04A
1040 IF L<=L9 THEN GOTO 1060
1045 GOSUB 6000
1050 IF V3=4 THEN GOTO 4100
1110 FOR I=0 TO 4
1120 LET T[I]=T[I]+X[I]
1130 NEXT I
1160 PRINT @(1,L),X0$(3,3),@(7),FNB$(X0$(45,3)),@(17),X[0]:M2$,@(18+M2),X[1]:M
1160:1$,@(19+M2+M1),X[2]:M1$,@(20+M2+2*M1),X[3]:M1$,@(21+M2+3*M1),X[4]:M1$,
1180 LET L=L+1
1290 GOTO 1000
4000 REM " --- Total
4020 PRINT @(5,20),"*Totals*",@(17),T[0]:M2$,@(18+M2),T[1]:M1$,@(19+M2+M1),T[2
4020:]:M1$,@(20+M2+2*M1),T[3]:M1$,@(21+M2+3*M1),T[4]:M1$,
4040 GOSUB 6000
4100 REM " --- Overlay
4180 LET M1$=M5$,M1=LEN(M1$)
4190 RUN "PRM.MA"
6000 REM " --- Clear Screen
6020 LET V0$="S",V1$="CE",V2$="",V3$="",V4$="Press <Enter> To Continue",V0=1,V
6020:1=FNV(V4$),V2=22
6025 GOSUB 7000
6060 LET L=L0+1
6070 PRINT @(0,L0+1),'CE',
6090 RETURN
7000 REM " --- Standard Input Routine (15May95)"
7010 CALL "SYC.IA",V0$,V1$,V2$,V3$,V4$,PGM(-2),V0,V1,V2,V$,V,V3,DISPLAY_LEN
7020 IF V3=999 THEN GOTO 7200
7030 IF V3=127 THEN GOTO 7100
7090 RETURN
7100 REM " --- Escape During Input"
7110 CALL "SYC.ES",ERR=7200,PGM(-2),TCB(8),E$,E2,V3
7120 IF V3<>127 THEN GOTO 7000
7130 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
7200 REM " --- Error During Input"
7210 ESCAPE
7290 GOTO 7000
8000 REM " --- Functions
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8095 DEF FNV(Q$)=42+INT(LEN(Q$)/2)
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
9220 RUN "PRM.MA"
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 RUN "SYS.AA"
9999 END
