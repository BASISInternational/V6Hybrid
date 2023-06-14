0010 REM "WOM - OP CODE MAINTENANCE LISTING"
0020 REM "Program  WOM.BB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0095 PRECISION IVS01_PRECISION
0100 REM " --- Open/Lock Files"
0170 CALL "SYC.GA",7,1,"","",STATUS
0180 IF STATUS THEN GOTO 9900
0200 REM " --- IOLISTs"
0210 WOM02A: IOLIST A0$,A[ALL]
0400 REM " --- Parameters"
0500 REM " --- Init Data"
0510 LET H0=132,H=0,H1$=N4$+" Listing"
0520 LET L9=50,L=L9+1,T0=0,HEADINGS=2
0530 DIM HEADINGS$[HEADINGS]
0540 LET WHEN$=F0$(7,3),CLOCK$=""
0550 LET HEADINGS$[0]=N1$,HEADINGS$[1]=H1$
0700 REM " --- Background"
0800 REM " --- Options"
0900 REM " --- Notification Box "
0910 CALL "SYC.NB","Printing:",3,COLUMN
1000 REM " --- Initial Read"
1020 READ (WOM02_DEV,KEY=N0$,DOM=1030)
1100 REM " --- Main Read"
1120 READ (WOM02_DEV,END=4000)IOL=WOM02A
1200 REM " --- Breaks"
1220 IF A0$(1,2)<>N0$ THEN GOTO 4000
1230 PRINT @(COLUMN,11),A0$(3,3)
2000 REM " --- Print"
2020 IF L>L9 THEN GOSUB 5000
2040 PRINT (7)@(0),A0$(3,3),"  ",A0$(6,20),@(30),A[0]:M2$,@(40),A[1]:M1$,@(50)
2040:,A[2]:M2$,@(60),A[3]:M6$,@(70),A[4]:M6$,@(80),A[5]:M6$
2200 LET L=L+1,T0=T0+1
2290 GOTO 1100
4000 REM " --- Options"
4020 PRINT (7)'LF',@(10),"Total Records:",T0
4100 GOTO 9900
5000 REM " --- Heading"
5010 LET L=0
5020 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,H,H0,WHEN$,CLOCK$,STATUS
5030 IF STATUS>0 THEN EXITTO 9900
5100 PRINT (7)@(0),"Operation",@(29+M2-6),"Direct",@(39+M1-6),"Pieces",@(49+M2
5100:-4),"O.H."
5110 PRINT (7)@(0),"Code",@(5),"Description",@(29+M2-4),"Rate",@(39+M1-5),"/Ho
5110:ur",@(49+M2-6),"Factor",@(60+M6-5),"Queue",@(70+M6-5),"Setup",@(80+M6-4),
5110:"Move",'LF'
5190 RETURN
8000 REM " --- Functions"
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8030 DEF FNC$(Q1$)=FNA$(Q1$(2),Q1$)+FNA$(Q1$(3),Q1$)+FNA$(Q1$(1),Q1$)
8040 DEF FND$(Q$)=CHR(FNYY_YEAR(Q$(5,2))+32)+CHR(NUM(Q$(1,2))+32)+CHR(NUM(Q$(3
8040:,2))+32)
8070 DEF FNG$(Q$)=STR((ASC(Q$)-32)*POS(" "<>Q$):"000")
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
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 RUN "SYS.AA"
9999 END
