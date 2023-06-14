0010 REM "PRM - Report Code Maintenance Listing"
0020 REM "Program PRM.HB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files
0170 CALL "SYC.GA",7,1,"","",STATUS
0175 IF STATUS=1 THEN GOTO 9900
0200 REM " --- IOLists
0210 PRM10H: IOLIST A0$
0500 REM " --- Init Data
0510 LET H0=80,H1=72,H=0,H1$=N4$+" Listing"
0520 LET L9=59,L=L9+1,T0=0,HEADINGS=2
0530 DIM HEADINGS$[HEADINGS]
0540 LET WHEN$=F0$(7,3),CLOCK$=""
0550 LET HEADINGS$[0]=N1$,HEADINGS$[1]=N4$+" Listing"
1000 REM " --- Init Read
1020 READ (PRM10_DEV1,KEY=N0$+"H",DOM=1030)
1100 REM " --- Main Read
1120 LET K$=KEY(PRM10_DEV1,END=4000)
1130 IF POS(N0$+"H"=K$)<>1 THEN GOTO 4000
1140 READ (PRM10_DEV1)IOL=PRM10H
2000 REM " --- Print
2020 IF L+1>L9 THEN GOSUB 5000
2040 PRINT (7)@(0),A0$(4,1),"-",A0$(5,2),@(5),A0$(7,10),@(20),A0$(17,2),@(30),
2040:A0$(19,2)
2200 LET L=L+1,T0=T0+1
2290 GOTO 1100
4000 REM " --- Options
4020 PRINT (7)'LF',@(10),"Total Records:",T0
4100 GOTO 9900
5000 REM " --- Heading
5020 LET L=HEADINGS+1
5040 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,H,H0,WHEN$,CLOCK$,STATUS
5050 IF STATUS<>0 THEN EXITTO 9900
5090 IF P3$(2,1)="Y" THEN PRINT @(29),"Dist",
5100 PRINT (7)@(0),"Report",@(17),"Register",@(29),"Check"
5110 PRINT (7)@(0),"Code",@(5),"Description",@(19),"Code",@(28),"History",'LF'
5180 LET L=L+3
5190 RETURN
8000 REM " --- Functions
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
9900 RUN "SYS.AA"
9999 END
