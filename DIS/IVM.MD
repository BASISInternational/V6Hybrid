0010 REM "IVM - Item Maintenance (Warehouse Status)"
0020 REM "Program IVM.MD"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0070 SETERR 9000
0080 SETESC 9000
0090 PRECISION P[1]
0200 REM " --- IOLIST's"
0220 IVM02A: IOLIST B0$(1),B1$(1),B2$,B[ALL]
0230 IVM12A: IOLIST C0$(1),C1$,C2$,C[ALL]
0300 IVM10C: IOLIST W0$(1)
0500 REM " --- Initializations"
0510 DIM B0$(24),B1$(64),B[20],C0$(28),C[12],W0$(32),O[4]
0550 LET TYPES$="BEGRECBLTSLDISSXFIXFOADJRETEND",TYPES=LEN(TYPES$),INDEX=0
0560 LET LINES=INT(TYPES/3),O[1]=39-M2,O[2]=52-M2,O[3]=65-M2,O[4]=78-M2
0600 REM " --- Retrieve column titles"
0610 DIM TITLES$[LINES]
0620 FOR X=1 TO TYPES STEP 3
0630 LET V$=TYPES$(X,3)
0640 CALL "IVC.FA",V$,V1$,V2$,STATUS
0650 LET INDEX=INDEX+1,TITLES$[INDEX]=V2$
0660 NEXT X
0700 REM " --- Background"
0710 CALL "SYC.WC",1,1,0,11,13,11,0
0715 CALL "SYC.WC",1,1,0,14,26,8,0
0720 CALL "SYC.WC",1,1,0,11,39,11,0
0725 CALL "SYC.WC",1,1,0,16,52,6,0
0730 CALL "SYC.WC",1,1,0,11,65,11,0
0735 CALL "SYC.WC",1,0,51,0,0,7,0
0740 CALL "SYC.WC",1,0,80,0,0,10,0
0745 PRINT 'SB',@(0,6),"Warehouse ID:",@(58),"On Hand",@(56,7),"Committed",@(4
0745:,8),"Location",@(28),"Last Physcl",@(56),"Available",@(2,9),"Cycle Code",
0745:@(29),"Phys Count",@(57),"On Order",@(18,11),"Last",
0750 FOR X=1 TO LINES
0760 PRINT 'SB',@(12-LEN(TITLES$[X]),11+X),TITLES$[X],'SF',
0790 NEXT X
0900 REM " --- Position file"
0990 READ (IVM03_DEV,KEY=A0$(1,2)+"G"+A0$(3),DOM=1000)
1000 REM " --- Warehouse ID"
1005 PRINT 'CF',
1010 LET V2$="",V2$=KEY(IVM03_DEV,END=1040)
1020 IF POS(A0$(1,2)+"G"+A0$(3)=V2$)<>1 THEN LET V2$=""
1030 IF V2$<>"" THEN LET V2$=V2$(24)
1040 LET V0$="S",V1$="KCE",V3$="",V0=2,V1=14,V2=6
1043 IF I3$(1,1)<>"Y" THEN LET V2$=I3$(6,2)
1045 LET V4$="Enter A Valid Warehouse ID <F3>=Lookup)"
1050 GOSUB 7000
1055 ON V3 GOTO 1065,1000,1000,1060,4900
1060 CALL "IVC.LK",3,V1,V2,V$
1065 IF V$="" THEN GOTO 0900
1070 LET V$=V$+"  ",V$=V$(1,2)
1080 IF I3$(1,1)<>"Y" THEN IF V$<>I3$(6,2) THEN GOTO 1000
1200 REM " --- Retrieve record"
1210 FIND (IVM10_DEV,KEY=N0$+"C"+V$,DOM=1000)IOL=IVM10C
1220 LET B0$(1)=A0$(1,2)+V$+A0$(3),K$=A0$(1,2)+"G"+A0$(3)+V$
1230 FIND (IVM02_DEV,KEY=B0$,DOM=1000)IOL=IVM02A
1240 LET WHEN$=B1$(28,12)+B1$(43,6)+B1$(40,3)+B1$(49,3)
1250 LET PERIOD=P[6]+1,YEAR=P[7],AVAILABLE=B[0]-B[2]
1260 IF PERIOD>G[0] THEN LET PERIOD=1,YEAR=YEAR+1
1290 READ (IVM03_DEV,KEY=K$,DOM=1300)
1300 REM " --- Display record"
1310 GOSUB 5000
2000 REM " --- Initializations for period display"
2010 DIM HEADINGS$[4],QTY[4,10]
2020 LET P=PERIOD,Y=YEAR
2100 REM " --- Retrieve period records"
2110 FOR X=1 TO 4
2120 LET HEADINGS$[X]=MONTHS$((P-1)*3+1,3)+" "+STR(1900+Y:"0000")
2130 LET C0$(1)=B0$+FNYEAR_YY21$(Y)+STR(P:"00"),P=P-1
2140 IF P<1 THEN LET P=G[0],Y=Y-1
2150 FIND (IVM12_DEV,KEY=C0$,DOM=2190)IOL=IVM12A
2160 LET QTY[X,1]=C[0],QTY[X,2]=C[1],QTY[X,3]=C[2],QTY[X,4]=C[3]
2170 LET QTY[X,5]=C[4],QTY[X,6]=C[6],QTY[X,7]=C[7],QTY[X,8]=C[5]
2180 LET QTY[X,9]=C[8],QTY[X,10]=C[0]+C[1]+C[2]-C[3]-C[4]+C[5]+C[6]-C[7]+C[8]
2190 NEXT X
2200 REM " --- Display period quantities"
2210 FOR X=1 TO 4
2220 PRINT @(O[X]+M2-9,11),HEADINGS$[X],
2230 FOR P=1 TO 10
2240 PRINT @(O[X],11+P),QTY[X,P]:M2$,
2250 NEXT P
2290 NEXT X
4000 REM " --- Correct?"
4010 LET V4$="Press <Enter> To Continue (<F1>=Next Warehouse/<F2>=Prior/<F3>=N
4010:ext)"
4020 LET V0$="S",V1$="KC",V2$="",V3$="",V0=1,V1=FNV(V4$),V2=22
4030 GOSUB 7000
4040 ON V3 GOTO 4050,4100,4200,4300,4900
4090 GOTO 1000
4100 REM " --- Next warehouse"
4110 IF I3$(1,1)<>"Y" THEN LET V$=I3$(6,2); GOTO 1200
4120 LET K$=KEY(IVM03_DEV,END=4000)
4130 IF POS(A0$(1,2)+"G"+A0$(3)=K$)<>1 THEN GOTO 4000
4140 READ (IVM03_DEV,END=4000)
4150 LET V$=K$(24,2)
4190 GOTO 1200
4200 REM " --- Prior 4 periods"
4210 LET PERIOD=PERIOD-4
4220 IF PERIOD<1 THEN LET PERIOD=G[0]+PERIOD,YEAR=YEAR-1
4290 GOTO 2000
4300 REM " --- Next 4 periods"
4310 LET PERIOD=PERIOD+4
4320 IF PERIOD>G[0] THEN LET PERIOD=PERIOD-G[0],YEAR=YEAR+1
4390 GOTO 2000
4900 REM " --- Run menu overlay"
4990 RUN "IVM.MA"
5000 REM " --- Display record"
5010 DIM X$(8)
5020 LET V$=""
5030 IF FNP$(B1$(16,3))<>"" THEN LET V$=FNB$(B1$(16,3))
5040 PRINT @(14,6),B0$(3,2)," ",W0$(6,24),@(14,8),B1$(1,10),@(14,9),B1$(11,2),
5040:@(43,8),V$,@(O[2],9),B[8]:M2$,@(O[4],6),B[0]:M2$,@(O[4],7),B[2]:M2$,@(O[4
5040:],8),AVAILABLE:M2$,@(O[4],9),B[1]:M2$,
5050 FOR X=1 TO 8
5055 LET X$(1)=""
5060 IF FNP$(WHEN$((X-1)*3+1,3))<>"" THEN LET X$=FNB$(WHEN$((X-1)*3+1,3))
5070 PRINT @(16,12+X),X$,
5080 NEXT X
5090 RETURN
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
8000 REM " --- Functions"
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8070 DEF FNP$(Q$)=CVS(Q$,2)
8080 DEF FNV(Q$)=42+INT(LEN(Q$)/2)
8110 REM " --- FNYEAR_YY21$ Convert Numeric Year to 21st Century 2-Char Year"
8115 DEF FNYEAR_YY21$(Q)=FNYY_YY21$(STR(MOD(Q,100):"00"))
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
