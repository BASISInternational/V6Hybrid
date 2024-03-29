0010 REM "APE - PAYMENT SELECTION ENTRY/VENDOR & INVOICE"
0020 REM "Program APE.EC"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.2           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0031 REM "30Oct96 Caj: Wasn't correctly writing key to APE-16 which resulted i
0031:n no selection info appearing on the report (6670)
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLists
0210 APE04A: IOLIST X0$,X[ALL]
0220 APE06A1: IOLIST *,X0
0230 APE06A2: IOLIST N0$,X0
0240 APE16A: IOLIST X0$,V0$
0250 APM01A: IOLIST *,Y1$
0260 APM03A: IOLIST *,Y1$
0270 APM10A: IOLIST X0$
0310 APT01A: IOLIST A0$,A[ALL]
0320 APT11A: IOLIST W0$,W1$,W[ALL]
0500 REM " --- Init Data
0510 DIM Z[3],MESSAGE$[1]
0520 LET P6$="  ",P8$="",P7$=""
0700 REM " --- Invoices
0720 PRINT 'CF','SB',@(25,6),"Vendor Number:",@(24,7),"Invoice Number:",@(26,8
0720:),"Gross Amount:",@(23,9),"Discount Amount:",@(24,10),"Payment Amount:",
0730 IF P3$(1,1)="Y" THEN PRINT 'SB',@(31,5),"AP Type:",
0740 IF P3$(3,1)="Y" THEN PRINT @(22,11),"Retention Amount:",
0750 PRINT 'SF',
2000 REM " --- AP Type
2005 PRINT 'CF',
2010 IF P3$(1,1)<>"Y" THEN GOTO 2100
2015 DIM P6$(2)
2020 LET V0$="S",V1$="KCE",V2$=P6$,V0=2,V1=40,V2=5,V4$="Enter A Valid AP Type,
2020: (<F3>=Lookup)"
2030 GOSUB 7000
2031 IF V3<>3 THEN GOTO 2035
2032 LET V4=1,V5=APM10_DEV,V6=4,V7=2,V8=6,V9=20,V5$="A"
2033 CALL "SYC.LZ",V1,V2,V4,V5,V6,V7,V8,V9,V$,V5$,N0$
2034 IF V$="" THEN GOTO 2000
2035 IF V3=4 THEN RUN "APE.EB"
2040 LET P6$(1)=V$
2050 FIND (APM10_DEV,KEY=N0$+"A"+P6$,DOM=2000)IOL=APM10A
2060 PRINT @(V1,V2),P6$," ",X0$(6,20),
2100 REM " --- Vendor
2120 LET V0$="M",V1$="KCE",V2$="",V3$=P1$,V0=6,V1=40,V2=6,V4$="Enter A Valid V
2120:endor (<F1>=Temporary Vendor/<F3>=Lookup)"
2125 PRINT @(V1+V0,V2),'CL',
2130 GOSUB 7000
2135 IF V3=2 THEN GOTO 2000
2140 IF V3=4 THEN RUN "APE.EB"
2150 IF V3=1 THEN GOTO 2200 ELSE IF V3=3 THEN GOTO 2900
2155 LET P8$=V$
2160 READ (APM01_DEV,KEY=N0$+P8$,DOM=2100)IOL=APM01A
2162 IF Y1$(159,1)<>"Y" THEN GOTO 2170
2164 LET MESSAGE$[0]="This Vendor Is In Hold Status (<Enter>=Continue/<F4>=Re-
2164:enter)"
2166 CALL "SYC.XA",2,MESSAGE$[ALL],0,22,-1,V$,V3
2168 IF V3<>0 THEN GOTO 2100
2170 LET Y1$=Y1$(1,30),Y0$=FNF$(P8$(1,P[0]),M0$)
2180 PRINT @(V1+M0+1,V2),Y1$,
2185 LET S9$=N0$+P6$+P8$,S8$="",O2=0
2190 GOTO 2300
2200 REM " --- Temp Vendor
2210 LET P8$="TEMP  ",Y0$=P8$
2220 PRINT @(40,6),P8$,'CL',
2240 LET S9$=N0$+P6$+P8$,S8$="",O2=0
2300 REM " --- Invoice
2310 GOSUB 5200
2320 LET V0$="S",V1$="KCE",V2$="",V0=10,V1=40,V2=7,I0=0,V4$="Enter A Valid Inv
2320:oice Number (<F3>=Include/Exclude All Invoices/<Enter>=Next)",O2=0
2330 GOSUB 7000
2332 IF V3=2 THEN GOTO 2100
2334 IF V3=4 THEN RUN "APE.EB"
2336 IF P8$(1,4)<>"TEMP" AND V3=3 THEN GOTO 4000
2338 IF V$="" THEN GOSUB 6700
2340 IF O2=2 THEN GOTO 2300
2350 LET P7$=V$+J1$(1,10),P7$=P7$(1,10),K0$=N0$+P6$+P8$+P7$+"00"
2352 FIND (APE04_DEV,KEY=K0$(1,20),DOM=2360)IOL=APE04A
2353 PRINT 'SB',@(69,7),"(Selected)",'SF',
2354 GOSUB 5000
2355 LET S8$=P7$,Z0$=X0$,Z[0]=X[0],Z[1]=X[1],Z[2]=X[2],Z[3]=X[3],X[0]=0
2356 READ (APT01_DEV1,KEY=K0$,DOM=2358)IOL=APT01A
2357 GOSUB 6000; REM "Get Invoice Balance
2358 LET Y0=X[0],X0$=Z0$,X[0]=Z[0],X[1]=Z[1],X[2]=Z[2],X[3]=Z[3]
2359 GOTO 3000
2360 READ (APT01_DEV1,KEY=K0$,DOM=2300)IOL=APT01A
2362 IF A0$(67,1)<>"Y" THEN GOTO 2370
2363 PRINT 'RB',
2364 LET MESSAGE$[0]="This Invoice Is In Hold Status (<Enter>=Continue/<F4>=Re
2364:-enter)"
2365 CALL "SYC.XA",2,MESSAGE$[ALL],0,22,-1,V$,V3
2366 IF V3<>0 THEN GOTO 2300
2370 GOSUB 6000
2372 LET Y0=X[0]; REM "Invoice Balance
2375 IF X[0]=0 THEN LET O2=1; GOSUB 6700; GOTO 2340
2380 IF X[1]<0 THEN LET X[1]=0
2385 IF X[2]<>0 THEN IF X[2]>X[0] THEN LET X[2]=X[0]
2386 LET S8$=P7$
2388 PRINT 'SB',@(65,7),"(Not Selected)",'SF',
2390 GOSUB 5000
2395 GOTO 3900
2400 REM " --- Invoice Amount
2410 LET V4$=""
2420 LET V0$="N",V1$="C",V2$=STR(X[0]),V3$=M1$,V1=40,V2=8,I0=1
2440 GOSUB 7000
2450 IF ABS(V)>ABS(Y0) THEN LET V4$="Payment Cannot Exceed Invoice Balance"+ST
2450:R(Y0:M1$); PRINT 'RB'; GOTO 2420
2460 LET X[0]=V
2490 GOTO 3900
2500 REM " --- Discount
2520 LET V0$="N",V2$=STR(X[1]),V3$=M1$,V4$="",V1=40,V2=9
2530 GOSUB 7000
2540 LET X[1]=V
2550 IF X[0]<=0 THEN IF X[1]<X[0] THEN GOTO 2500
2560 IF X[0]>0 THEN IF X[1]>X[0] THEN GOTO 2500
2580 PRINT @(40,10),X[0]-X[1]-X[2]:M1$,
2590 GOTO 3900
2600 REM " --- Retention
2605 GOTO 3900
2610 IF P3$(3,1)<>"Y" THEN GOTO 3900
2620 LET V0$="N",V2$=STR(X[2]),V3$=M1$,V1=40,V2=11
2630 GOSUB 7000
2640 LET X[2]=V
2650 IF X[0]<=0 THEN IF X[2]<X[0] THEN GOTO 2600
2660 IF X[0]>0 THEN IF X[2]>X[0] THEN GOTO 2600
2690 GOTO 3900
2900 REM " --- Alpha Search
2940 CALL "SYC.LV",V$
2960 IF V$="" THEN GOTO 2100
2970 LET X$=FNF$(V$(1,P[0]),M0$)
2980 PRINT X$
2990 GOTO 2155
3000 REM " --- Write
3010 LET V0$="S",V1$="C",V2$="",V3$="",V4$="Is The Above Information Correct (
3010:Y=Select/N/D=Deselect)?",V0=1,V1=FNV(V4$),V2=22
3020 GOSUB 7000
3040 IF V$="D" OR V$="DESELECT" THEN GOTO 3200
3060 ON POS(V$="YN") GOTO 3000,3100,2400
3120 WRITE (APE04_DEV,KEY=X0$(1,20))IOL=APE04A
3130 LET V0$="Select Vendor "+Y0$+" "+Y1$+" Invoice "+P7$
3140 GOSUB 6600
3190 GOTO 2300
3200 REMOVE (APE04_DEV,KEY=X0$(1,20),DOM=2300)
3220 LET V0$="Delete Vendor "+Y0$+" Invoice "+P7$
3240 GOSUB 6600
3290 GOTO 2300
3900 REM " --- Next Field
3910 IF V3<>2 THEN GOTO 3940
3920 IF I0>0 THEN LET I0=I0-1
3930 GOTO 3950
3940 LET I0=I0+1
3960 ON I0 GOTO 2300,2400,2500,2600,3000
4000 REM " --- Correct?
4005 LET P5$=""
4010 LET V0$="S",V1$="CE",V2$="",V3$="",V4$="Include Or Exclude All Invoices F
4010:or This Vendor (I/E)?",V0=1,V1=FNV(V4$),V2=22
4020 GOSUB 7000
4040 IF V3=4 THEN GOTO 2300
4050 IF V$="I" OR V$="INCLUDE" THEN LET P5$="I",V0$="Include"
4060 IF V$="E" OR V$="EXCLUDE" THEN LET P5$="E",V0$="Exclude"
4080 IF P5$="" THEN GOTO 4000
4100 LET V0$=V0$+" All Invoices For Vendor "+Y0$+" "+Y1$
4120 GOSUB 6600
4200 RUN "APE.ED"
5000 REM " --- Display Invoice Amounts
5020 PRINT @(40,8),X[0]:M1$,@(40,9),X[1]:M1$,@(40,10),X[0]-X[1]-X[2]:M1$,
5040 IF P3$(3,1)="Y" THEN PRINT @(40,11),X[2]:M1$,
5050 IF P8$(1,4)<>"TEMP" THEN RETURN
5060 LET Y1$="Not On File",Y0$="TEMP"
5070 FIND (APM03_DEV,KEY=N0$+P6$+P7$,DOM=5080)IOL=APM03A
5075 LET Y1$=Y1$(1,30)
5080 PRINT @(45,6),Y1$,
5090 RETURN
5200 REM " --- Clear Invoice Info
5220 FOR X=23 TO 7 STEP -1
5240 IF X<=11 THEN PRINT @(40,X),'CL', ELSE PRINT @(0,X),'CL',
5260 NEXT X
5290 RETURN
6000 REM " --- Get Open Invoice Amount
6010 DIM X0$(60),X[3]
6020 LET X[0]=A[0],X[1]=A[1],X[2]=A[2],X[3]=A[0],X0$=A0$(1,20)+A0$(29,3)+A0$(3
6020:5,6)+A0$(41,26)
6090 READ (APT11_DEV,KEY=K0$(1,20),DOM=6100)
6100 LET K$=KEY(APT11_DEV,END=6300)
6110 IF K$(1,20)<>K0$(1,20) THEN GOTO 6300
6120 READ (APT11_DEV)IOL=APT11A
6140 IF W1$(1,1)=" " THEN GOTO 6190
6150 LET X[0]=X[0]+W[0],X[1]=X[1]+W[1],X[2]=X[2]+W[2]
6160 IF POS(W1$(1,1)="A")<>0 THEN LET X[3]=X[3]+W[0]
6200 GOTO 6100
6300 RETURN
6600 REM " --- Write Transaction
6610 LET X0=0
6620 EXTRACT (APE06_DEV,KEY=N0$,DOM=6630)IOL=APE06A1
6640 LET X0=X0+1
6650 WRITE (APE06_DEV,KEY=N0$)IOL=APE06A2
6660 LET X0$=N0$+STR(X0:"000")
6670 WRITE (APE16_DEV,KEY=X0$)IOL=APE16A
6690 RETURN
6700 REM " --- Get Next Invoice
6705 IF S8$<>"" THEN LET S8$=S8$+$FF$
6707 IF O2=1 THEN GOTO 6720
6710 READ (APT01_DEV2,KEY=S9$+S8$,DOM=6720)
6720 LET K$=KEY(APT01_DEV2,END=6770)
6724 READ (APT01_DEV2)
6730 IF LEN(K$)<>22 THEN LET K$=""
6735 IF K$<>"" THEN IF K$(1,10)<>S9$ THEN LET K$="",O2=2
6740 IF K$<>"" THEN LET V$=K$(11,10)
6750 IF K$<>"" THEN PRINT @(V1,V2),V$,
6760 GOTO 6780
6770 LET O2=2
6780 IF K$="" THEN LET S8$=""
6790 RETURN
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
8075 DEF FNV(Q$)=42+INT(LEN(Q$)/2)
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
9220 GOTO 2100
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 RUN "SYS.AA"
9999 END
