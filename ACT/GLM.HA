0010 REM "GLM - Create Departmental Reports"
0020 REM "Program GLM.HA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0060 BEGIN
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files"
0110 LET FILES=7
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0130 LET FILES$[1]="GLM-01",FILES$[2]="GLM-11",FILES$[3]="GLM-21"
0140 LET FILES$[4]="GLM-12",FILES$[5]="GLM-22",FILES$[6]="GLM-32"
0150 LET FILES$[7]="SYS-01"
0160 CALL "SYC.DA",1,1,7,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0170 IF STATUS>0 THEN GOTO 9900
0180 LET GLM01_DEV=CHANNELS[1],GLM11_DEV=CHANNELS[2],GLM21_DEV=CHANNELS[3]
0185 LET GLM12_DEV=CHANNELS[4],GLM22_DEV=CHANNELS[5],GLM32_DEV=CHANNELS[6]
0190 LET SYS01_DEV=CHANNELS[7]
0200 REM " --- IOLIST's"
0210 GLM01A: IOLIST A0$(1),A1$(1)
0220 GLM11A: IOLIST D0$(1),D1$(1)
0230 GLM12A: IOLIST B0$(1),B1$(1)
0240 GLM22A: IOLIST C0$(1),C1$(1),C2$(1),C3$(1)
0250 GLM32A: IOLIST R0$(1),R1$(1)
0260 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0270 GLS01A: IOLIST P0$,P1$,P2$(1),P3$(1),P4$(1),M0$,M1$,M2$,M3$
0400 REM " --- Parameters"
0410 DIM P2$(10),P3$(325),P4$(32),P[4]
0420 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9800)IOL=SYS01T
0430 LET N0$=F0$(16,2),N1$=F4$,N2$="GL",N3$=F5$
0440 FIND (SYS01_DEV,KEY=N0$+N2$+"00",DOM=9800)IOL=GLS01A
0450 LET M0=LEN(M0$)
0480 FOR X=0 TO 4
0485 LET P[X]=NUM(P2$(X*2+1,2),ERR=0490)
0490 NEXT X
0495 LET P[2]=FNYY_YEAR(P2$(5,2))
0500 REM " --- Initializations"
0510 DIM A0$(2+P[4]),A1$(40),B0$(30),C0$(8),C1$(56),D0$(14),D1$(6),R0$(7),R1$(
0510:7)
0520 DIM J0$(P[4],"0"),J1$(40),MESSAGE$[1]
0550 LET LETBEGACCT$="",ENDACCT$=""
0560 LET COLUMN=0,TOTAL=0
0700 REM " --- Background"
0710 FOR X=6 TO 18 STEP 2
0720 CALL "SYC.WC",1,0,80,0,0,X,0
0730 NEXT X
0740 PRINT 'SB',@(0,3),"Assignment No:",@(4,4),"Report No:",@(0,5),"Starting L
0740:ine:",@(1,7),"From Account:",@(1,9),"Thru Account:",@(6,11),"Dept No:",@(
0740:5,13),"Desc Col:",@(5,15),"Total No:",@(5,17),"Updating:",'SF',
0800 REM " --- Assignment Number"
0810 PRINT 'CF',
0820 LET V0$="Z",V1$="CR",V2$="",V3$="",V0=2,V1=15,V2=3
0830 LET V4$="Enter Assignment Number (1 through 10)"
0840 GOSUB 7000
0850 ON V3 GOTO 0860,0800,0800,0800,9900
0860 LET NUMBER=NUM(V$)
0870 IF NUMBER<1 OR NUMBER>10 THEN GOTO 0800
0900 REM " --- Position GLR-01"
0990 READ (GLM12_DEV,KEY=N0$,DOM=1000)
1000 REM " --- Report Number"
1005 LET V2$="",V2$=KEY(GLM12_DEV,END=1040)
1010 IF V2$(1,2)<>N0$ THEN LET V2$=""
1030 IF V2$<>"" THEN LET V2$=V2$(3,2)
1040 LET V0$="Z",V1$="EK",V3$="",V0=2,V1=15,V2=4,I0=0
1050 LET V4$="Enter A Valid Report Number (<F3>=Lookup)"
1060 GOSUB 7000
1070 ON V3 GOTO 1090,1000,0800,1080,0800
1080 CALL "GLC.LF",N0$,V$
1085 IF V$="" THEN GOTO 1000
1090 LET B0$(1)=N0$+V$,B0$(5)="0000"
1100 REM " --- Retrieve header"
1110 READ (GLM12_DEV,KEY=B0$(1,8),DOM=1000)IOL=GLM12A
1120 PRINT @(V1,V2),B0$(3,2)," ",B0$(9,20),
1180 READ (GLM22_DEV,KEY=B0$(1,4),DOM=1190)
1190 GOTO 3900
1200 REM " --- Line Number"
1210 LET V2$="",V2$=KEY(GLM22_DEV,END=1240)
1220 IF V2$(1,4)<>B0$(1,4) THEN LET V2$=""
1230 IF V2$<>"" THEN LET V2$=V2$(5,4)
1240 LET V0$="Z",V1$="C",V3$="",V0=4,V1=15,V2=5
1250 LET V4$="Enter A Valid Line Number (<F3>=Lookup)"
1260 GOSUB 7000
1270 ON V3 GOTO 1290,1200,3900,1275,3900
1275 LET REPORT$=B0$(3,2)
1280 CALL "GLC.LL",REPORT$,N0$,V$
1285 IF V$="" OR V$="0000" THEN GOTO 1200
1290 LET C0$(1)=B0$(1,4)+V$,X0$=C0$(5,4)
1300 REM " --- Retrieve detail line"
1310 READ (GLM22_DEV,KEY=C0$,DOM=3900)IOL=GLM22A
1320 PRINT @(V1,V2),C0$(5,4)," ",C1$(2,35)
1330 LET MESSAGE$[0]="This report line already exists (<Enter>=Continue)"
1340 CALL "SYC.XA",2,MESSAGE$[ALL],0,22,-1,V$,V3
1390 GOTO 3900
1400 REM " --- From G/L Account Number"
1410 LET V0$="M",V1$="C",V2$=BEGACCT$,V3$=M0$,V0=P[4],V1=15,V2=7
1420 LET V4$="Enter A Valid G/L Account (<F3>=Lookup)",I0=2
1430 GOSUB 7000
1440 ON V3 GOTO 1460,1400,3900,1450,3900
1450 CALL "SYC.LG",V$
1460 LET V$=V$+J0$,V$=V$(1,P[4]),A0$(1)=N0$+V$
1470 FIND (GLM01_DEV,KEY=A0$,DOM=1400)IOL=GLM01A
1480 PRINT @(V1,V2),FNF$(A0$(3,P[3]),M0$)," ",A1$(1,35),'CL',
1485 LET BEGACCT$=A0$(3)
1490 GOTO 3900
1600 REM " --- Thru G/L Account Number"
1610 LET V0$="M",V1$="C",V2$=ENDACCT$,V3$=M0$,V0=P[4],V1=15,V2=9
1620 LET V4$="Enter A Valid G/L Account (<F3>=Lookup)"
1630 GOSUB 7000
1640 ON V3 GOTO 1655,1600,3900,1650,3900
1650 CALL "SYC.LG",V$
1655 IF V$<BEGACCT$ THEN GOTO 1600
1660 LET V$=V$+J0$,V$=V$(1,P[4]),A0$(1)=N0$+V$
1670 FIND (GLM01_DEV,KEY=A0$,DOM=1600)IOL=GLM01A
1680 PRINT @(V1,V2),FNF$(A0$(3,P[3]),M0$)," ",A1$(1,35),'CL',
1685 LET ENDACCT$=A0$(3)
1690 GOTO 3900
1800 REM " --- Department"
1810 LET V0$="S",V1$="C",V2$=DEPT$,V3$="",V0=P[3],V1=15,V2=11
1820 LET V4$="Enter A Valid Department Number"
1830 GOSUB 7000
1840 ON V3 GOTO 1850,1800,3900,1800,3900
1850 LET V=NUM(V$,ERR=1800),DEPT$=V$
1880 PRINT @(V1,V2),DEPT$,'CL',
1890 GOTO 3900
2000 REM " --- Description Column"
2010 LET V0$="N",V1$="C",V2$=STR(COLUMN),V3$="###",V0=3,V1=15,V2=13,I0=5
2020 LET V4$="Enter The Report Column Where The Account Description Should Be 
2020:Printed"
2030 GOSUB 7000
2040 ON V3 GOTO 2050,2000,3900,2000,3900
2050 IF V<0 OR V>132 THEN GOTO 2000
2060 LET COLUMN=V
2070 PRINT @(V1,V2),STR(COLUMN),'CL',
2090 GOTO 3900
2200 REM " --- Total Number"
2210 LET V0$="N",V1$="C",V2$=STR(TOTAL),V3$="###",V0=3,V1=15,V2=15,I0=6
2220 LET V4$="Enter The Total Number To Which Each Detail Line Should Be Accum
2220:ulated"
2230 GOSUB 7000
2240 ON V3 GOTO 2250,2200,3900,2200,3900
2250 IF V<0 OR V>254 OR V=31 OR V=137 THEN GOTO 2200
2260 LET TOTAL=V
2280 PRINT @(V1,V2),STR(TOTAL),'CL',
2290 GOTO 3900
3900 REM " --- Next field"
3915 IF V3=4 THEN GOTO 0800
3920 IF V3<>2 THEN GOTO 3950
3930 IF I0>0 THEN LET I0=I0-1
3940 GOTO 3960
3950 LET I0=I0+1
3960 ON I0 GOTO 1000,1200,1400,1600,1800,2000,2200,3990
3990 LET I0=0
4000 REM " --- Correct?"
4010 LET V0$="Y",V4$="Is The Above Information Correct (Y/N)?",I0=0
4020 LET V1$="C",V2$="Y",V3$="",V0=1,V1=FNV(V4$),V2=22
4030 GOSUB 7000
4040 ON V3 GOTO 4050,4000,4000,4000,9900
4090 ON POS(V$="YN") GOTO 4000,4100,1000
4100 REM " --- Generate GLM-22 Detail Lines"
4110 LET K$=N0$+BEGACCT$
4180 READ (GLM01_DEV,KEY=K$,DOM=4200)IOL=GLM01A
4190 GOTO 4250
4200 REM " --- Read next GLM-01 record"
4210 LET K$=KEY(GLM01_DEV,END=4900)
4220 IF K$(1,P[4]+2)>N0$+ENDACCT$ THEN GOTO 4900
4230 READ (GLM01_DEV)IOL=GLM01A
4250 IF DEPT$="" THEN GOTO 4300
4260 IF K$(P[3]-LEN(DEPT$)+3,LEN(DEPT$))<>DEPT$ THEN GOTO 4200
4300 REM " --- Update GLM-11 record"
4310 LET D0$(1)=A0$+STR(NUMBER:"00"),D1$=B0$(3,2)+X0$
4390 WRITE (GLM11_DEV,KEY=D0$)IOL=GLM11A
4400 REM " --- Write GLM-22 line"
4405 DIM C0$(8),C1$(56),C2$(20),C3$(24)
4410 LET C0$(1)=N0$+B0$(3,2)+X0$,C1$(1)="D"+A1$(1,35)+STR(COLUMN:"000")+FILL(1
4410:1)+"N ",C2$(1)=STR(TOTAL:"000")+"+"
4420 READ (GLM32_DEV,KEY=B0$(1,4),DOM=4430)
4430 FOR X=0 TO 7
4435 LET K32$=KEY(GLM32_DEV,END=4460)
4440 IF K32$(1,4)<>B0$(1,4) THEN EXITTO 4460
4445 READ (GLM32_DEV,KEY=K32$)IOL=GLM32A
4450 LET C3$(3*X+1,3)=R1$(5,3)
4455 NEXT X
4460 WRITE (GLM22_DEV,KEY=C0$)IOL=GLM22A
4465 PRINT @(15,17),X0$," ",C1$(1,35),
4470 LET X=NUM(X0$)+10
4475 IF X>9999 THEN GOTO 4500
4480 LET X0$=STR(X:"0000")
4490 GOTO 4200
4510 DIM MESSAGE$[1]
4520 LET MESSAGE$[0]="Report Line Number Exceeds 9999 (<Enter>=Continue)"
4530 CALL "SYC.XA",1,MESSAGE$[ALL],0,22,-1,V$,V3
4540 GOTO 0800
4900 REM 
4990 GOTO 1400
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
8090 DEF FNV(Q$)=42+INT(LEN(Q$)/2)
8145 REM " --- FNYY21_YY$ Un-Convert 21st Century 2-Char Year to 2-Char Year"
8150 DEF FNYY21_YY$(Q1$)
8155 LET Q3$=" 01234567890123456789",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABC
8155:DEFGHIJ"))
8160 RETURN Q1$
8165 FNEND
8170 REM " --- FNYY_YEAR Convert 2-Char Year to 21st Century Numeric Year"
8175 DEF FNYY_YEAR(Q1$)
8180 LET Q=NUM(FNYY21_YY$(Q1$)); IF Q<50 THEN LET Q=Q+100
8185 RETURN Q
8190 FNEND
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
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9800 REM " --- Display Parameter record error"
9810 LET LINE_ERR$=LST(PGM(TCB(5)))
9820 CALL "SYC.YA",LINE_ERR$,N2$,ERR
9900 RUN "SYS.AA"
9999 END
