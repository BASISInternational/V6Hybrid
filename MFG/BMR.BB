0010 REM "BMR - Materials Where Used Listing
0020 REM "Program BMR.BB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0060 PRECISION NUM(P6$(5,1))
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLists
0210 BMM01A: IOLIST A0$,A1$,A2$,A[ALL]
0220 BMM02A: IOLIST B0$,B1$,B2$,B[ALL]
0240 IVM01A: IOLIST D0$,D1$(1)
0500 REM " --- Init Data
0510 LET H0=132,H=0,HEADINGS=2,WHEN$=F0$(7,3),CLOCK$=""
0520 DIM D1$(60),HEADINGS$[HEADINGS]
0540 LET HEADINGS$[0]=N1$,HEADINGS$[1]=N3$
0550 DIM QTYREQ[0]
0600 CALL "SYC.GA",7,1,"","",STATUS
0605 IF STATUS THEN GOTO 9900
0700 REM " --- Background
0750 CALL "SYC.NB"," Printing:",P[0],COLUMN
1000 REM " --- Initial Read
1030 READ (BMM04_DEV,KEY=N0$+ITEMFROM$,DOM=1040)
1100 REM " --- Read Where Used File
1120 LET K$=KEY(BMM04_DEV,END=4000)
1130 READ (BMM04_DEV)
1200 REM " --- Breaks
1220 IF K$(1,2)<>N0$ THEN GOTO 4000
1240 IF ITEMTHRU$<>"" THEN IF K$(3,LEN(ITEMTHRU$))>ITEMTHRU$ THEN GOTO 4000
1300 READ (BMM01_DEV,KEY=K$(1,2)+K$(23,20),DOM=1100)IOL=BMM01A
1400 READ (BMM02_DEV,KEY=A0$(1,22)+K$(43,3),DOM=1100)IOL=BMM02A
1420 IF K$(1,22)<>T0$ THEN GOSUB 6000
1440 PRINT @(COLUMN,11),K$(3,P[0]),
1450 DIM D1$(60); LET D1$(1)="*** Not On File ***"
1460 FIND (IVM01_DEV,KEY=A0$(1,22),DOM=1500)IOL=IVM01A
1470 LET D1$=FNITEM$(D1$,DESC[1],DESC[2],DESC[3])+FILL(60),D1$=D1$(1,60)
1500 REM " --- Print
1510 IF L+1>L9 THEN GOSUB 5200
1520 PRINT (7)@(32+M0),A0$(3,P[0]),@(33+2*M0),D1$(1,30),@(110-P1),FNB$(B2$(5,3
1520:))," ",FNB$(B2$(8,3)),FNQTY(B[0],B[1],B[3],A[4],B[4]):P1$,@(128),B0$(23,3
1520:)
1530 LET T0=T0+1,L=L+1,L1=L1+1
1540 LET QTYREQ[0]=QTYREQ[0]+B[0]
1580 GOTO 1100
4000 REM " --- Totals
4010 LET T9$="E"
4020 GOSUB 6000
4040 IF H=0 THEN GOSUB 5000
4100 PRINT (7)'LF',@(10),"Total Records:",T0
4200 GOTO 9900
5000 REM " --- Heading
5010 LET L=HEADINGS+1
5020 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,H,H0,WHEN$,CLOCK$,STATUS
5030 IF STATUS>0 THEN EXITTO 9900
5100 PRINT (7)@(0),"Item",@(32+M0),"Bill",@(111-P1),"Effect",@(119-P1),"Obsole
5100:te",@(123),"Qty"
5110 PRINT (7)@(0),"No.",@(M0+1),"Description",@(M0+32),"No.",@(33+2*M0),"Desc
5110:ription",@(112-P1),"Date",@(121-P1),"Date",@(121),"Req'd",@(128),"Seq",'L
5110:F'
5120 LET L=L+3
5140 LET W9$=""
5190 RETURN
5200 REM " --- Sub Heading
5220 IF L>L9 THEN GOSUB 5000
5230 LET R0$=" "
5240 FIND (BMM01_DEV,KEY=N0$+T0$(3),DOM=5260)
5250 LET R0$="*"
5270 PRINT (7)@(0),R0$,T0$(3),@(1+M0),DESCRIPTION$,
5290 RETURN
6000 REM " --- Item Break
6010 IF T0$="" THEN GOTO 6100
6020 IF L1<2 THEN GOTO 6080
6025 IF L+3>L9 THEN GOSUB 5000
6030 PRINT (7)@(127-P1),DASHES$(1,P1),'LF',@(11),"Item Total",@(127-P1),QTYREQ
6030:[0]:P1$,'LF'
6040 LET L=L+3
6080 IF L1<2 AND L+2>L9 THEN GOSUB 5000
6090 IF L1<2 THEN PRINT (7)'LF'; LET L=L+2
6100 IF T9$<>"" THEN RETURN
6110 LET T0$=K$(1,22),DESCRIPTION$="***Not On File***",L1=0
6120 DIM QTYREQ[0]
6130 FIND (IVM01_DEV,KEY=K$(1,22),DOM=6160)IOL=IVM01A
6140 LET DESCRIPTION$=FNITEM$(D1$,DESC[1],DESC[2],DESC[3])+FILL(30)
6150 LET DESCRIPTION$=DESCRIPTION$(1,30)
6160 GOSUB 5200
6190 RETURN
8000 REM " --- Functions
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8080 DEF FNQTY(Q1,Q2,Q3,Q4,Q5)=10000*Q1*Q2/(Q3*Q4*(100-Q5))
8090 DEF FNITEM$(Q$,Q1,Q2,Q3)=CVS(Q$(1,Q1)+" "+Q$(Q1+1,Q2)+" "+Q$(Q1+Q2+1,Q3),
8090:32)
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
