0010 REM "BMR - Inventory Production Register
0020 REM " Program BMR.HA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0050 BEGIN
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files
0110 LET FILES=16
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0125 LET FILES$[1]="BME-01",FILES$[2]="BMM-01",FILES$[3]="BMM-02"
0130 LET FILES$[4]="BMM-03",FILES$[5]="BMM-08",FILES$[6]="IVM-01"
0135 LET FILES$[7]="IVM-02",FILES$[8]="IVM-10",FILES$[9]="SYS-01"
0140 LET FILES$[10]="ARM-10",FILES$[11]="BMM-05"
0145 LET FILES$[12]="IVW-04",FILES$[13]="IVW-05"
0150 LET FILES$[14]="GLM-01",FILES$[15]="GLW-11",FILES$[16]="IVM-04"
0155 LET OPTIONS$[1]="L",OPTIONS$[12]="CL",OPTIONS$[13]="CL"
0160 CALL "SYC.DA",1,1,9,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0170 IF STATUS<>0 THEN GOTO 9900
0175 LET BME01_DEV=CHANNELS[1],BMM01_DEV=CHANNELS[2],BMM02_DEV=CHANNELS[3]
0180 LET BMM03_DEV=CHANNELS[4],BMM08_DEV=CHANNELS[5],IVM01_DEV=CHANNELS[6]
0185 LET IVM02_DEV=CHANNELS[7],IVM10_DEV=CHANNELS[8],SYS01_DEV=CHANNELS[9]
0200 REM " --- IOLists
0210 ARM10D: IOLIST UU$,DIST_ACCTS$(1)
0220 ARS01A: IOLIST *,*,*,X$
0230 BME01A: IOLIST A0$,A1$,A[ALL]
0240 BMM01A1: IOLIST L0$,L1$,L2$,L[ALL]
0245 BMM01A2: IOLIST LX0$,LX1$,LX2$,LX[ALL]
0250 BMM02A: IOLIST S0$,S1$,S2$,S[ALL]
0255 BMM03A: IOLIST K1$,K2$,K[ALL]
0260 BMM05A: IOLIST SUB0$,SUB1$,SUB2$,SUB3$,SUB4$,SUB[ALL]
0265 BMM08A: IOLIST X1$(1),X[ALL]
0270 IVM01A: IOLIST B0$,B1$(1),B2$,B3$,B4$,B5$,B6$(1)
0275 IVM02A: IOLIST C0$,C1$(1),C2$,C[ALL]
0280 IVM02A1: IOLIST *,*,*,JUNK[ALL],UNITCOST
0285 IVM02A2: IOLIST C0$,C1$(1)
0290 IVM10C: IOLIST X0$
0295 IVW05A: IOLIST W9$,ICOST
0300 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0310 BMS01A: IOLIST R0$(1),R1$
0320 IVS01A: IOLIST P0$,P1$,P2$,P3$,P4$,M0$,M1$,M2$,M3$
0330 GLS01A: IOLIST X$,G1$,G2$,G3$,G4$,G5$,G6$,G7$
0400 REM " --- Parameters
0404 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9800)IOL=SYS01T
0408 LET N0$=F0$(16,2),N1$=F4$,N2$="IV",N3$=F5$,SOURCE$=PGM(-2)
0412 FIND (SYS01_DEV,KEY=N0$+N2$+"00",DOM=9800)IOL=IVS01A
0416 DIM R0$(36),INFO$[20]
0417 LET IL=NUM(P2$(1,2))
0420 FIND (SYS01_DEV,KEY=N0$+"BM00",DOM=9800)IOL=BMS01A
0424 FIND (SYS01_DEV,KEY=N0$+"GL00",DOM=9800)IOL=GLS01A
0428 LET AR_DIST$="N"
0432 FIND (SYS01_DEV,KEY=N0$+"AR00",DOM=0464)IOL=ARS01A
0436 IF X$(11,1)<>"Y" THEN GOTO 0464
0440 CALL "SYC.VA","AR",INFO$[ALL]
0444 IF INFO$[20]="N" THEN GOTO 0464
0448 CALL "SYC.DA",1,10,10,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATU
0448:S
0452 IF STATUS<>0 THEN GOTO 9900
0456 LET ARM10_DEV=CHANNELS[10]
0460 LET AR_DIST$="Y"
0464 DIM P[4],G[4],DESC[3],INFO$[20]
0468 FOR X=0 TO 4
0472 LET G[X]=NUM(G2$(X*2+1,2),ERR=0476)
0476 NEXT X
0478 LET G[2]=FNYY_YEAR(G2$(5,2))
0480 FOR X=1 TO 3
0484 LET DESC[X]=NUM(P2$((X-1)*2+9,2))
0488 NEXT X
0492 LET P[0]=NUM(P2$(1,2)),P[1]=NUM(P2$(3,2)),P[2]=NUM(P2$(5,2)),P[3]=NUM(P2$
0492:(7,2)),LF$="N"
0496 IF POS(P3$(3,1)="LF")>0 THEN LET LF$="Y"
0498 DIM IV_CHANS[10]
0500 REM " --- Init Data
0505 PRECISION NUM(P2$(5,1))
0510 LET H0=132,H1=120,H=0,H1$=N1$,H2$=N3$,O1$="",O2$="",O1=0
0520 LET L9=59,L=L9+1,HEADINGS=3,WHEN$=F0$(7,3),CLOCK$="",GLSTATUS=0
0530 DIM HEADINGS$[HEADINGS]
0540 DIM A[1],C[20],S[10],K[11],L[11],LX[11],SUB[9],B1$(60),C1$(64)
0545 LET HEADINGS$[0]=H1$,HEADINGS$[1]=H2$,ERRORS=0
0550 CALL "SYC.RM",M1$,M1,6,15
0555 CALL "SYC.RM",M2$,M2,10,15
0560 CALL "SYC.RM",M3$,M3,5,10
0565 LET DASHES$=FILL(M1,"-")
0570 LET WIP_ACCT$=R0$(7,G[4])
0580 LET M0=P[0],UNITS=0
0590 IF M0<6 THEN LET M0=6
0600 REM " --- Open Additional Files
0610 CALL "SYC.VA","AP",INFO$[ALL]
0615 LET AP$=INFO$[20]
0620 IF AP$<>"Y" THEN GOTO 0640
0625 CALL "SYC.DA",1,11,11,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATU
0625:S
0630 IF STATUS<>0 THEN GOTO 9900
0635 LET BMM05_DEV=CHANNELS[11]
0640 IF LF$<>"Y" THEN GOTO 0660
0645 CALL "SYC.DA",1,12,13,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATU
0645:S
0650 IF STATUS<>0 THEN GOTO 9900
0655 LET IVW04_DEV=CHANNELS[12],IVW05_DEV=CHANNELS[13]
0656 CALL "SYC.DA",1,16,16,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATU
0656:S
0657 IF STATUS THEN GOTO 9900
0658 LET IVM04_DEV=CHANNELS[16]
0660 LET GL$="N",STATUS=0
0665 CALL "GLC.BA",ERR=0670,SOURCE$,N2$,GLW11$,GL$,STATUS
0670 IF STATUS<>0 THEN GOTO 9900
0675 IF GL$<>"Y" THEN GOTO 0700
0680 LET FILES$[14]="GLM-01",FILES$[15]=GLW11$,OPTIONS$[15]="CL"
0685 CALL "SYC.DA",1,14,15,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATU
0685:S
0690 IF STATUS>0 THEN GOTO 9900
0695 LET GLM01_DEV=CHANNELS[14],GLW11_DEV=CHANNELS[15]
0700 REM " --- Background
0720 CALL "SYC.NB","Printing",11+P[0],COLUMN
0800 REM " --- Options
0810 LET U0$=WIP_ACCT$
0900 REM " --- Run Report?
0910 LET V4$="Do You Want To Print The "+N3$
0920 CALL "SYC.YN",1,V4$,2,V$,V3
0930 IF V3=4 THEN GOTO 9900
0940 IF V$<>"Y" THEN GOTO 9900
0950 CALL "SYC.GA",7,1,"","",STATUS
0960 IF STATUS THEN GOTO 9900
1000 REM " --- Initial Read
1020 READ (BME01_DEV,KEY=N0$,DOM=1030)
1030 LET K$=KEY(BME01_DEV,END=4500)
1035 IF POS(N0$=K$)<>1 THEN GOTO 4500
1100 REM " --- Heading Read
1110 LET VALUE=0
1120 READ (BME01_DEV,END=4000)IOL=BME01A
1200 REM " --- Breaks
1220 IF A0$(1,2)<>N0$ THEN GOTO 4000; REM " --- Company"
1240 IF A0$(3,2)<>T0$ THEN GOSUB 6000; REM " --- Warehouse"
1260 IF A0$(5,3)<>T1$ THEN GOSUB 6200; REM " --- Production Date"
1270 IF A0$(8,7)<>T2$ THEN GOSUB 6700; REM " --- Reference Number"
1280 PRINT @(COLUMN,11),A0$(3,2)," ",A0$(8,7)," ",A0$(15,P[0]),
1290 LET REF1$="Whse "+A0$(3,2),REF2$=A0$(8,7),REF3$="Prod Entry"
1300 REM " --- Get Item Info
1310 LET I0$=A0$(15,20)
1320 GOSUB GET_ITEMINFO
1330 LET IVACCT$=B6$(1,G[4])
1400 REM " --- Additional Reads
1410 DIM L[11]
1420 READ (BMM01_DEV,KEY=A0$(1,2)+A0$(15),DOM=1430)IOL=BMM01A1
1430 IF L[4]=0 THEN LET L[4]=100
1500 REM " --- Print Bill
1520 IF L+2>L9 THEN GOSUB 5000
1540 LET U0$=B6$(1,G[4])
1560 PRINT (7)@(0),A0$(8,7),@(8),A0$(15,P[0])
1570 PRINT (7)@(8),B1$(1,60)
1580 LET L=L+2
1700 REM " --- Component Items
1710 DIM C[20]
1720 LET SAVEB0$=B0$
1730 IF A1$(8,1)="Y" THEN GOSUB 2600
1740 READ (BMM02_DEV,KEY=B0$,DOM=1750)
1750 LET K$=KEY(BMM02_DEV,END=2130)
1760 IF POS(SAVEB0$(1,22)=K$)<>1 THEN GOTO 2130
1770 READ (BMM02_DEV)IOL=BMM02A
1780 IF S2$(4,1)="M" THEN GOTO 1750
1790 IF S2$(5,3)<>"   " THEN IF A0$(5,3)<S2$(5,3) THEN GOTO 1750
1800 IF S2$(8,3)<>"   " THEN IF A0$(5,3)>=S2$(8,3) THEN GOTO 1750
1810 FIND (BMM01_DEV,KEY=N0$+S1$,DOM=1830)IOL=BMM01A2
1820 IF LX2$(40,1)<>"Y" THEN GOTO 1830
1825 GOSUB EXPLODEPHANTOMS
1826 READ (BMM02_DEV,KEY=K$)
1827 GOTO 1750
1830 LET O1$="",I0$=S1$
1835 GOSUB GET_ITEMINFO
1840 LET U1$=B6$(1,G[4])
1850 FIND (IVM02_DEV,KEY=A0$(1,4)+S1$,DOM=1880)IOL=IVM02A
1855 LET UNITCOST=C[11]
1860 IF LF$="Y" THEN GOSUB 5700; LET UNITCOST=ICOST
1870 GOTO 1900
1880 LET O1$="** Missing Warehouse Record **",O1=1
1890 GOTO 2000
1900 GOSUB 2700
2000 REM " --- Print Components
2010 IF L+2>L9 THEN GOSUB 5000
2020 LET I0$=S1$
2025 GOSUB GET_ITEMINFO
2030 PRINT (7)@(12),"< ",S1$," ",O1$
2040 IF S[3]=0 THEN LET S[3]=1
2050 PRINT (7)@(14),B1$(1,30),@(132-4*M2),C[0]-C[2]:M2$,FNQTY(S[0],S[1],S[3],L
2050:[4],S[4])*A[0]:M2$,
2060 IF C[0]-C[2]>=FNQTY(S[0],S[1],S[3],L[4],S[4])*A[0] THEN GOTO 2090
2070 PRINT (7)@(132-2*M2),ABS(C[0]-C[2]-FNQTY(S[0],S[1],S[3],L[4],S[4])*A[0]):
2070:M2$,
2080 LET SHORT=SHORT+1
2090 PRINT (7)@(132-M2),C[1]:M2$
2100 LET L=L+2
2110 GOTO 1750
2120 LET MEMO$="Variance"
2130 GOSUB 6370
2140 IF A[0]=0 THEN LET DIV0=DIV0+1
2150 IF AP$="Y" THEN GOSUB 5500
2160 IF P3$(8,1)<>"S" AND A[0]>0 THEN LET COST=VALUE/A[0]; GOTO 2500
2170 LET I0$=A0$(15,20)
2180 GOSUB GET_ITEMINFO
2190 LET GLDATE$=A0$(5,3),ACCOUNT$=R0$(27,G[4]),COST=UNITCOST,AMOUNT=VALUE-COS
2190:T*A[0]
2200 GOSUB GLRECAP
2210 IF A1$(8,1)="N" THEN LET U0$=WIP_ACCT$ ELSE LET U0$=IVACCT$
2220 LET ACCOUNT$=U0$,AMOUNT=-AMOUNT
2230 GOSUB GLRECAP
2500 REM " --- Print Total for BME-01 record
2510 LET T0=T0+COST*A[0],U0=U0+COST*A[0],U1=U1+COST*A[0]
2520 IF L+2>L9 THEN GOSUB 5000
2530 PRINT (7)@(0),"Total",@(8),A0$(15,P[0]),@(34),COST:M3$,@(34+M3),A[0]:M2$,
2530:@(34+M3+M2),COST*A[0]:M1$,@(37+M3+M2+M1),A1$(8,1),'LF'
2540 LET L=L+2
2550 LET COST=0
2560 GOTO 1100
2600 REM " --- Dist Code
2610 IF AR_DIST$="N" THEN GOTO 2660
2620 READ (IVM02_DEV,KEY=A0$(1,4)+A0$(15,20),DOM=2660)IOL=IVM02A2
2630 DIM DIST_ACCTS$(8*G[4],"0")
2640 FIND (ARM10_DEV,KEY=N0$+"D"+C1$(13,2),DOM=2650)IOL=ARM10D
2650 LET U0$=DIST_ACCTS$(6*G[4]+1,G[4]),IVACCT$=U0$
2660 RETURN
2700 REM " --- Distribution
2710 IF AR_DIST$="N" THEN GOTO 2800
2720 DIM DIST_ACCTS$(8*G[4],"0")
2730 FIND (ARM10_DEV,KEY=N0$+"D"+C1$(13,2),DOM=2740)IOL=ARM10D
2740 LET U1$=DIST_ACCTS$(6*G[4]+1,G[4])
2800 REM " --- Update G/L
2810 IF A1$(8,1)="N" THEN LET U0$=WIP_ACCT$ ELSE LET U0$=IVACCT$
2820 LET GLDATE$=A0$(5,3),ACCOUNT$=U0$,AMOUNT=UNITCOST*FNQTY(S[0],S[1],S[3],L[
2820:4],S[4])*A[0],MEMO$="Item "+A0$(15,20)
2830 PRECISION 2
2840 LET AMOUNT=AMOUNT*1,VALUE=VALUE+AMOUNT
2850 GOSUB GLRECAP
2860 LET GLDATE$=A0$(5,3),ACCOUNT$=U1$,AMOUNT=(-1)*AMOUNT,MEMO$="Item "+C0$(5,
2860:20)
2870 GOSUB GLRECAP
2880 PRECISION NUM(P2$(5,1))
2890 RETURN
4000 REM " --- Totals
4020 LET T9$="E"
4040 GOSUB 6000
4050 IF O1=0 AND O2$="" AND DIV0=0 THEN GOTO 4100
4055 IF O1<>0 AND L+3>L9 THEN GOSUB 5000
4060 IF O1<>0 THEN PRINT (7)'LF','LF',@(10),"*** Missing Warehouse Records, Ca
4060:n Not Proceed With Update At This Time"
4065 IF O2$<>"" AND L+5>L9 THEN GOSUB 5000
4070 IF O2$<>"" THEN PRINT (7)'LF',@(0),O2$,'LF','LF',@(10),"*** Missing Opera
4070:tion Codes, Can Not Proceed With Update At This Time"
4075 IF DIV0<>0 AND L+3>L9 THEN GOSUB 5000
4080 IF DIV0<>0 THEN PRINT (7)'LF','LF',@(10),"*** Records With Production Qua
4080:ntity Of 0 Exist. Can Not Proceed With Update At This Time"
4090 GOTO 9900
4100 REM 
4120 IF SHORT=0 THEN GOTO 4180
4122 IF L+2>L9 THEN GOSUB 5000
4125 PRINT (7)'LF',@(10),"*** Warning - Amounts In The Shortage Column Will Cr
4125:eate Negative On Hand Balances In Inventory."
4130 DIM MESSAGE$[1]
4140 LET MESSAGE$[0]="Amounts In The Shortage Column Will Create Negative On H
4140:and"
4150 LET MESSAGE$[1]="Balances In Inventory (<Enter>=Continue)"
4170 CALL "SYC.XA",2,MESSAGE$[ALL],1,22,-1,V$,V3
4175 IF V3=4 THEN GOTO 9900
4180 LET CHANNEL=BMW01_DEV,WIDTH=H0,PAGE=H,UPDATE$="BMU.AA"
4185 IF GL$="Y" THEN RUN "GLR.XA"
4190 RUN UPDATE$,ERR=9900
4500 REM " --- No Data
4510 LET T9$="E"
4520 GOSUB 5000
4540 PRINT (7)'LF','LF',@(10),"*** Nothing To Report ***"
4590 GOTO 9900
5000 REM " --- Heading
5010 LET L=HEADINGS+1
5020 LET HEADINGS$[2]="For Warehouse "+H3$
5030 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,H,H0,WHEN$,CLOCK$,STATUS
5040 IF STATUS>0 THEN EXITTO 9900
5060 IF T9$<>"E" THEN GOSUB 5200
5110 PRINT (7)@(0),"Ref #",@(8),"Main Bill Number",@(34+M3-5),"Cost",@(34+M3+M
5110:2-4),"Qty",@(34+M3+M2+M1-6),"Total",@(34+M3+M2+M1+1),"Update?",
5130 PRINT (7)@(132-3*M2-10),"Available",@(132-2*M2-9),"Required",@(132-M2-9),
5130:"Shortage",@(132-9),"On-Order",'LF'
5140 LET L=L+2
5190 RETURN
5200 REM " --- Date Heading
5220 PRINT (7)@(0),"Production Date: ",FNB$(T1$)
5230 IF GLSTATUS>0 THEN CALL "GLC.GA",7,T1$,GLSTATUS,L,ERRORS,STATUS
5240 PRINT (7)""
5250 LET L=L+2
5290 RETURN
5500 REM " --- Subcontracts
5505 DIM SUB[9]
5510 READ (BMM05_DEV,KEY=A0$(1,2)+A0$(15,20),DOM=5520)
5520 LET K1$=KEY(BMM05_DEV,END=5690)
5530 IF POS(A0$(1,2)+A0$(15,20)=K1$)<>1 THEN GOTO 5690
5540 READ (BMM05_DEV)IOL=BMM05A
5550 IF SUB2$(1,3)<>"   " THEN IF A0$(5,3)<SUB2$(1,3) THEN GOTO 5520
5560 IF SUB2$(4,3)<>"   " THEN IF A0$(5,3)>=SUB2$(4,3) THEN GOTO 5520
5570 IF SUB1$(1,1)<>"S" THEN GOTO 5520
5580 IF A1$(8,1)="N" THEN LET U0$=WIP_ACCT$ ELSE LET U0$=IVACCT$
5590 IF SUB[3]=0 THEN LET SUB[3]=1
5600 LET A0=A[0]*SUB[2]*FNSUB(SUB[0],SUB[1],SUB[3])
5610 LET GLDATE$=A0$(5,3),ACCOUNT$=U0$,AMOUNT=A0,VALUE=VALUE+AMOUNT,MEMO$="Ite
5610:m "+CVS(A0$(15,20),2)+" "+SUB1$(10)
5620 GOSUB GLRECAP
5630 LET ACCOUNT$=R0$(17,G[4]),AMOUNT=-A0
5640 GOSUB GLRECAP
5685 GOTO 5520
5690 RETURN
5700 REM " --- LIFO/FIFO
5705 DIM ITEM$[10]
5710 LET ITEM$[0]=N0$,ITEM$[1]=A0$(3,2),ITEM$[2]=S1$,TYPE$="R",LF_DATE$=A0$(5,
5710:3)
5712 LET IV_CHANS[0]=IVM04_DEV,IV_CHANS[1]=IVW04_DEV,IV_CHANS[2]=IVM02_DEV
5715 LET ACTION$=P3$(3,1)+"I",QTY=ABS(FNQTY(S[0],S[1],S[3],L[4],S[4])*A[0]),CO
5715:ST=UNITCOST
5720 IF FNQTY(S[0],S[1],S[3],L[4],S[4])*A[0]>=0 THEN GOTO 5810
5730 REM " --- Inquires For Tier Cost For Returned Items
5740 LET ACTION$(2,1)="R",TYPE$="I"
5770 CALL "IVC.LF",ACTION$,TYPE$,LF_DATE$,IV_CHANS[ALL],ITEM$[ALL],PLACES,QTY,
5770:COST,RET_COST,STATUS
5780 IF RET_COST<>0 THEN LET COST=RET_COST
5790 LET TYPE$="R"
5810 CALL "IVC.LF",ACTION$,TYPE$,LF_DATE$,IV_CHANS[ALL],ITEM$[ALL],PLACES,QTY,
5810:COST,RET_COST,STATUS
5820 IF RET_COST<>0 THEN LET ICOST=RET_COST
5830 LET W9$=FILL(17)+S1$+S0$(23,3)
5840 WRITE (IVW05_DEV,KEY=W9$)IOL=IVW05A
5850 RETURN
6000 REM " --- Warehouse
6020 IF T0$="" THEN GOTO 6100
6030 IF T9$="" THEN LET T9$="A"
6040 GOSUB 6200
6050 IF T9$="A" THEN LET T9$=""
6060 PRINT (7)@(34+M3+M2),DASHES$,'LF',@(10),"Warehouse Total:",@(34+M3+M2),T0
6060::M1$
6080 LET L=L9+1,T0=0,U0=0
6100 IF T9$<>"" THEN RETURN
6120 LET T0$=A0$(3,2),T1$=A0$(5,3),H3$="Not On File",T2$=A0$(8,7)
6130 FIND (IVM10_DEV,KEY=N0$+"C"+A0$(3,2),DOM=6150)IOL=IVM10C
6140 LET H3$=FNP$(X0$(4,2)+" "+X0$(6,20))
6150 IF GL$="Y" THEN CALL "GLC.EA",T1$,"N",PERIOD$,YEAR$,GLSTATUS
6180 RETURN
6200 REM " --- Date
6210 IF T1$="" THEN GOTO 6250
6220 GOSUB 6700
6230 PRINT (7)@(34+M3+M2),DASHES$,'LF',@(10),"Date Total:",@(34+M3+M2),U0:M1$
6240 LET L=L+2
6250 IF T9$<>"" THEN RETURN
6260 LET U0=0,T1$=A0$(5,3),L=L9+1
6270 IF GL$="Y" THEN CALL "GLC.EA",T1$,"N",PERIOD$,YEAR$,GLSTATUS
6280 RETURN
6300 REM " --- Item
6305 GET_ITEMINFO:
6310 LET UNITCOST=0
6320 DIM B1$(60),B6$(50),JUNK[10]
6330 READ (IVM01_DEV,KEY=N0$+I0$,DOM=6340)IOL=IVM01A
6340 LET B1$=FNITEM$(B1$,DESC[1],DESC[2],DESC[3]),B1$=B1$+FILL(62-LEN(B1$))
6350 READ (IVM02_DEV,KEY=N0$+A0$(3,2)+I0$,DOM=6360)IOL=IVM02A1
6360 RETURN
6370 REM " --- Operation
6380 DIM X1$(50),X[13],K[11],L[11]
6390 READ (BMM01_DEV,KEY=A0$(1,2)+A0$(15,20),DOM=6400)IOL=BMM01A1
6400 READ (BMM03_DEV,KEY=A0$(1,2)+A0$(15,20),DOM=6410)
6410 LET K1$=KEY(BMM03_DEV,END=6695)
6420 IF POS(A0$(1,2)+A0$(15,20)=K1$)<>1 THEN GOTO 6695
6430 READ (BMM03_DEV)IOL=BMM03A
6440 IF K2$(65,3)<>"   " THEN IF A0$(5,3)<K2$(65,3) THEN GOTO 6410
6450 IF K2$(68,3)<>"   " THEN IF A0$(5,3)>=K2$(68,3) THEN GOTO 6410
6460 IF K2$(4,1)="M" THEN GOTO 6410
6470 FIND (BMM08_DEV,KEY=K1$(1,2)+K2$(1,3),DOM=6490)IOL=BMM08A
6480 GOTO 6500
6490 LET O2$=O2$+"** Missing Operation Code In Bill Number "+K1$(3,P[0])+" Seq
6490:uence "+K1$(23,3)+" **"+'LF'
6500 IF L[5]=0 THEN LET L[5]=1
6510 IF K[1]=0 THEN LET K[1]=1
6520 IF A[0]<>0 THEN LET A0=FNOP2(A[0],K[0],X[0],K[1],L[4],K[4]) ELSE LET A0=0
6530 LET A1=A0*X[2]
6540 REM " --- Direct Labor
6550 PRECISION 2
6560 LET A0=A0*1,A1=A1*1
6570 LET GLDATE$=A0$(5,3),ACCOUNT$=X1$(31,G[4]),AMOUNT=-A0,MEMO$="Item "+CVS(A
6570:0$(15,IL),2)+" "+X1$(6,20)
6580 GOSUB GLRECAP
6590 IF A1$(8,1)="N" THEN LET U0$=WIP_ACCT$ ELSE LET U0$=IVACCT$
6600 LET GLDATE$=A0$(5,3),ACCOUNT$=U0$,AMOUNT=A0,VALUE=VALUE+AMOUNT
6610 GOSUB GLRECAP
6620 REM " --- Overhead
6630 LET GLDATE$=A0$(5,3),ACCOUNT$=X1$(41,G[4]),AMOUNT=-A1
6640 GOSUB GLRECAP
6650 IF A1$(8,1)="N" THEN LET U0$=WIP_ACCT$ ELSE LET U0$=IVACCT$
6660 LET GLDATE$=A0$(5,3),ACCOUNT$=U0$,AMOUNT=A1,VALUE=VALUE+AMOUNT
6670 GOSUB GLRECAP
6680 PRECISION NUM(P2$(5,1))
6690 GOTO 6410
6695 RETURN
6700 REM " --- Reference Total
6710 IF T2$="" THEN GOTO 6760
6715 IF L>L9 THEN GOSUB 5000
6720 PRINT (7)@(34+M3+M2),DASHES$,'LF',@(10),"Reference Total: ",@(34+M3+M2),U
6720:1:M1$,'LF'
6730 LET L=L+3
6760 IF T9$<>"" THEN RETURN
6770 LET U1=0,T2$=A0$(8,7)
6790 RETURN
6800 REM " --- Explode Phantoms
6803 EXPLODEPHANTOMS:
6805 DIM CHANNEL[15],INFO$[20],INFO[20]
6810 LET CHANNEL[0]=BMM01_DEV,CHANNEL[1]=BMM03_DEV,CHANNEL[2]=BMM05_DEV
6815 LET CHANNEL[3]=BMM08_DEV,CHANNEL[4]=IVM01_DEV,CHANNEL[5]=IVM02_DEV
6820 LET CHANNEL[6]=7,CHANNEL[7]=SYS01_DEV,CHANNEL[8]=GLM01_DEV
6825 LET CHANNEL[9]=GLW11_DEV,CHANNEL[10]=ARM10_DEV,CHANNEL[11]=GLT05_DEV
6830 LET CHANNEL[12]=IVM04_DEV,CHANNEL[13]=IVW04_DEV,CHANNEL[14]=IVW05_DEV
6832 LET CHANNEL[15]=BMM02_DEV
6835 LET INFO$[0]=S1$,INFO$[1]=REF1$,INFO$[2]=REF2$,INFO$[3]=AP$,INFO$[4]=AR_D
6835:IST$
6840 LET INFO$[5]=O2$,INFO$[6]=A0$(3,2),INFO$[7]=A0$(5,3),INFO$[8]=A1$(8,1)
6845 LET INFO$[9]=GL$,INFO$[10]=T1$,INFO$[11]=IVACCT$
6855 LET INFO[0]=A[0]*S[0],INFO[1]=L,INFO[2]=L9,INFO[3]=HEADINGS
6860 LET INFO[4]=SHORT,INFO[5]=O1,INFO[6]=0,INFO[7]=U0,INFO[8]=U1,INFO[9]=1
6865 LET INFO[10]=H,INFO[12]=GLSTATUS,INFO[13]=L[4]*LX[4]/100,INFO[14]=VALUE
6870 CALL "BMC.FA",CHANNEL[ALL],INFO$[ALL],INFO[ALL],HEADINGS$[ALL],A0$(15,20)
6875 IF INFO[11]>0 THEN EXITTO 9900
6880 LET O2$=INFO$[5]
6885 LET L=INFO[1],SHORT=INFO[4],O1=INFO[5],U0=INFO[7],U1=INFO[8],H=INFO[10],V
6885:ALUE=INFO[14]
6890 RETURN
6900 REM " --- Standard G/L Recap Routine
6910 GLRECAP:
6920 IF GL$<>"Y" THEN GOTO 6990
6950 CALL "GLC.AA",GLM01_DEV,GLW11_DEV,GLT05_DEV,ACCOUNT$,GLDATE$,REF1$,REF2$,
6950:REF3$,MEMO$,AMOUNT,UNITS,STATUS
6990 RETURN
8000 REM " --- Functions
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8070 DEF FNOP2(Q1,Q2,Q3,Q4,Q5,Q6)=Q1*100*(Q2*Q3/Q4)/Q5+SGN(Q1)*Q6*Q3
8080 DEF FNP$(Q$)=CVS(Q$,2)
8085 DEF FNQTY(Q1,Q2,Q3,Q4,Q5)=10000*Q1*Q2/(Q3*Q4*(100-Q5))
8090 DEF FNITEM$(Q$,Q1,Q2,Q3)=CVS(Q$(1,Q1)+" "+Q$(Q1+1,Q2)+" "+Q$(Q1+Q2+1,Q3),
8090:32)
8095 DEF FNSUB(Q1,Q2,Q3)=Q1*Q2/Q3
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
