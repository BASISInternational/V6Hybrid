0010 REM "PRR - Daily Entry Register"
0020 REM "Program PRR.UA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0050 BEGIN
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files"
0110 LET FILES=4
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0125 LET FILES$[1]="PRE-02",FILES$[2]="PRM-01",FILES$[3]="PRM-10"
0130 LET FILES$[4]="SYS-01"
0160 CALL "SYC.DA",1,1,4,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0170 IF STATUS>0 THEN GOTO 9900
0180 LET PRE02_DEV=CHANNELS[1],PRM01_DEV=CHANNELS[2],PRM10_DEV=CHANNELS[3]
0185 LET SYS01_DEV=CHANNELS[4]
0200 REM " --- IOLists"
0210 PRE02A: IOLIST A0$,A1$,A[ALL]
0220 PRM01A: IOLIST B0$,B1$
0230 PRM10H: IOLIST X0$
0240 PRM10E: IOLIST H3$
0260 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0270 PRS01A: IOLIST P0$,P1$,P2$,P3$,P4$,M0$,M1$,M2$,M3$
0280 PRS01B: IOLIST *,X$
0400 REM " --- Parameters"
0410 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9800)IOL=SYS01T
0420 LET N0$=F0$(16,2),N1$=F4$,N2$="PR",N3$=F5$
0430 FIND (SYS01_DEV,KEY=N0$+N2$+"00",DOM=9800)IOL=PRS01A
0440 FIND (SYS01_DEV,KEY=N0$+N2$+"01",DOM=9800)IOL=PRS01B
0450 LET H4$="Pay Period Ending "+FNB$(X$(1,3))
0480 DIM P[4]
0490 LET P[0]=NUM(P2$(1,2)),P[1]=NUM(P2$(3,2)),P[3]=NUM(P3$(8,1)),P[4]=NUM(P3$
0490:(7,1))
0500 REM " --- Init Data"
0510 DIM A[2],T[2],S[2],U[2],HEADINGS$[3]
0520 LET L9=59,L=L9+1,PAGE=0,WIDTH=80,HEADINGS=3,WHEN$=F0$(7,3),CLOCK$=""
0530 LET HEADINGS$[0]=N1$,HEADINGS$[1]=N3$,HEADINGS$[2]=H4$
0540 CALL "SYC.RM",M1$,M1,8,13
0550 LET M0=LEN(M0$),M3=LEN(M3$),M2=LEN(M2$)
0700 REM " --- Run Report?"
0710 LET V4$="Do You Want To Print The "+N3$
0720 CALL "SYC.YN",1,V4$,2,V$,V3
0730 IF V3=4 THEN GOTO 9900
0740 IF V$<>"Y" THEN GOTO 9900
0750 CALL "SYC.GA",7,1,"","",STATUS
0760 IF STATUS>0 THEN GOTO 9900
0770 CALL "SYC.NB","Printing",LEN(M0$),COLUMN
0800 REM " --- Build Headings"
0810 LET U0$="",U1$=""
0850 READ (PRM10_DEV,KEY=N0$+"H"+"A",DOM=0860)
0860 LET K$=KEY(PRM10_DEV,END=0980)
0870 IF K$(1,4)<>N0$+"H"+"A" THEN GOTO 0980
0880 READ (PRM10_DEV)IOL=PRM10H
0890 LET U0$=U0$+X0$(5,2),X$=X0$(7,10)
1000 REM " --- Init Read"
1010 PRECISION P[4]
1020 READ (PRE02_DEV,KEY=N0$,DOM=1030)
1060 PRINT @(40,3),'CL',
1100 REM " --- Main Read"
1120 LET K$=KEY(PRE02_DEV,END=4000)
1130 IF K$(1,2)<>N0$ THEN GOTO 4000
1140 READ (PRE02_DEV)IOL=PRE02A
1180 PRINT @(COLUMN,11),FNF$(A0$(3,P[0]),M0$),
1190 IF K$(1,2)<>N0$ THEN GOTO 4000
1200 REM " --- Employee"
1210 DIM B1$(150)
1220 FIND (PRM01_DEV,KEY=A0$(1,11),DOM=1300)IOL=PRM01A
1500 REM " --- Breaks"
1520 IF K$(3,P[3])<>T0$ THEN GOSUB 6000
1540 IF K$(3,9)<>T1$ THEN GOSUB 6400
2000 REM " --- Print"
2020 IF L+1>L9 THEN GOSUB 5400
2040 PRINT (7)@(5),A0$(12,3),@(9),FNB$(A0$(15,3)),@(18),A0$(18,2),@(21),A0$(20
2040:,2),@(24),A0$(22,2),@(27),A[0]:M3$,A[1]:M2$,A[2]:M1$
2060 LET L=L+1
2100 FOR X=1 TO 2
2120 LET T[X]=T[X]+A[X],U[X]=U[X]+A[X],S[X]=S[X]+A[X]
2140 NEXT X
2900 REM " --- Next"
2990 GOTO 1100
4000 REM " --- Totals"
4010 LET T9$="E"
4020 GOSUB 6000
4040 IF L+2>L9 THEN GOSUB 5000
4060 PRINT (7)'LF',@(10),"Grand Totals:",@(27+M3),U[1]:M2$,U[2]:M1$
4100 RUN "PRU.FA"
5000 REM " --- Report Heading"
5010 LET L=HEADINGS+1
5020 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,PAGE,WIDTH,WHEN$,CLOCK$,STATUS
5030 IF STATUS>0 THEN EXITTO 9900
5100 PRINT (7)"Employee"
5110 PRINT (7)"No.",@(M0+1),"Name"
5140 PRINT (7)@(5),"Seq",@(11),"Date",@(18),"EC",@(21),"TC",@(24),"DC",@(22+M3
5140:),"Rate",@(21+M3+M2),"Units",@(20+M3+M2+M1),"Amount"
5180 LET L=L+3
5190 RETURN
5200 REM " --- Dept Heading"
5210 IF L+2>L9 THEN GOSUB 5000
5220 IF P[3]=0 THEN RETURN
5240 PRINT (7)'LF',@(0),T0$," ",H3$
5280 LET L=L+2
5290 RETURN
5400 REM " --- Employee Heading"
5410 IF L+1>L9 THEN GOSUB 5200
5420 PRINT (7)@(0),FNF$(T1$(1,P[0]),M0$)," ",H5$
5440 LET L=L+1
5490 RETURN
6000 REM " --- Dept Break"
6010 IF T0$="" THEN GOTO 6100
6020 IF T9$="" THEN LET T9$="D"
6025 GOSUB 6400
6030 IF T9$="D" THEN LET T9$=""
6035 LET T1$=""
6040 IF P[3]=0 THEN GOTO 6100
6050 IF L+2>L9 THEN GOSUB 5200
6060 PRINT (7)'LF',@(10),"Dept Totals:",@(27+M3),S[1]:M2$,S[2]:M1$
6070 LET L=L+2
6100 IF T9$="E" THEN RETURN
6120 DIM S[2]
6140 LET T0$=K$(3,P[3])
6150 IF P[3]=0 THEN RETURN
6160 LET H3$=""
6170 FIND (PRM10_DEV,KEY=N0$+"E"+B1$(221,2),DOM=6200)IOL=PRM10E
6180 LET H3$=H3$(6,20)
6200 GOSUB 5200
6290 RETURN
6400 REM " --- Employee Break"
6420 IF T1$="" THEN GOTO 6500
6430 IF L+1>L9 THEN GOSUB 5400
6440 PRINT (7)@(10),"Employee Totals:",@(27+M3),T[1]:M2$,T[2]:M1$
6460 LET L=L+1
6500 IF T9$<>"" THEN RETURN
6510 DIM T[2]
6520 LET T1$=A0$(3,9),H5$="***Not On File***",L2=0
6550 LET H5$=B1$(1,30),X=POS("  "=H5$(1,16))
6560 IF X>1 THEN LET H5$=B1$(1,X-1)+", "+B1$(17,14)
6570 IF X<=1 THEN LET H5$=B1$(1,16)+", "+B1$(17,14)
6580 GOSUB 5400
6590 RETURN
8000 REM " --- Functions"
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
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
