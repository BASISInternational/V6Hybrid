0010 REM "ARM - Customer Maintenance (Hard Copy Report Overlay)"
0020 REM "Program ARM.MG"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLists"
0210 ARM01A: IOLIST A0$,A1$
0220 ARM02A: IOLIST B0$,B1$,B[ALL]
0230 ARM03A: IOLIST C0$,C1$(1)
0240 ARM06A: IOLIST D0$,D1$,D[ALL]
0250 ART01A: IOLIST E0$,E[ALL]
0260 ART11A: IOLIST X0$,X1$,X[ALL]
0290 ARM09A: IOLIST C0$,C1$,C[ALL]
0300 ARM05A: IOLIST X0$,X1$
0310 ARM10A: IOLIST V2$
0320 ARM10B: IOLIST V7$
0330 ARM10D: IOLIST V4$
0340 ARM10F: IOLIST V1$
0350 ARM10G: IOLIST V5$
0360 ARM10H: IOLIST V3$
0370 ARM10I: IOLIST V6$
0380 ARM10L: IOLIST V8$
0500 REM " --- Init Data"
0510 LET HEADINGS=2,WHEN$=F0$(7,3),CLOCK$="",ORIGINAL_M1$=M1$
0520 DIM X[8],W[2],D1$(16),E[4],O[2],HEADINGS$[HEADINGS]
0530 LET H0=80,H=0,L8=59,L=L8+1,T0=0,O[0]=35,O[1]=O[0]+M1,O[2]=O[1]+M1
0540 IF H1$="" THEN LET H1$="Customer Detail Listing"
0550 LET HEADINGS$[0]=FNP$(N1$),HEADINGS$[1]=FNP$(H1$)
0900 REM " --- Initialize File"
0910 READ (ARM01_DEV,KEY=N0$+K0$,DOM=1000)IOL=ARM01A
0920 GOTO 1100
1000 REM " --- Customer Maintenance"
1010 LET NEXT$="",NEXT$=KEY(ARM01_DEV,END=4000)
1020 IF NEXT$(1,2)<>N0$ THEN GOTO 4000
1030 IF K1$<>"" THEN IF NEXT$(3,6)>K1$ THEN GOTO 4000
1050 READ (ARM01_DEV,KEY=NEXT$)IOL=ARM01A
1060 LET H=0
1150 IF CLS$<>"Y" THEN PRINT @(40,9),A0$(3,6),
1160 GOSUB 5000
1170 PRINT (7)@(0),J$,@(15),"Name, Address & Profile"
1180 PRINT (7)@(6),"Address:",@(15),A1$(31,24),@(46),"Alt Seq:",@(55),A1$(146,
1180:10),'LF',@(15),A1$(55,24),@(42),"Date Opened:",@(55),FNB$(A1$(156,3)),'LF
1180:',@(15),A1$(79,24),@(45),"Ship-Via:",@(55),A1$(159,10),'LF',@(15),A1$(179
1180:,24),@(44),"Resale No:",@(55),A1$(126,20),'LF',@(15),A1$(203,24),@(44),"F
1180:ax Phone: ",@(55),FNF$(A1$(169,10),M8$),'LF',@(3),"Zip/Postal:",@(15),FNZ
1180:$(A1$(103)),@(46),"Contact:",@(55),A1$(228,20),'LF',@(4),"Telephone:",@(1
1180:5),FNF$(A1$(112,10),M8$),@(30),"Ext:",@(35),A1$(122,4),@(47),"Retain: ",A
1180:1$(227,1),'LF',@(3),"D&B Number:",@(15),A1$(248,9),@(46),"SIC Code:",@(55
1180:),A1$(257,8),'LF'
1190 LET L=L+10
1200 PRINT (7)@(0),J$
1210 DIM B1$(64),B[10],D1$(16),D[21]
1220 READ (ARM02_DEV,KEY=A0$(1,8)+"  ",DOM=2000)IOL=ARM02A
1225 FIND (ARM06_DEV,KEY=A0$(1,8),DOM=1230)IOL=ARM06A
1230 GOSUB 6000
1240 PRINT (7)@(3),"Slsprsn No:",@(15),B1$(1,3)," ",V1$,@(48),"Finance Charge?
1240::",@(65),B1$(10,1),'LF',@(3),"Terms Code:",@(15),B1$(4,2),"  ",V2$,@(48),
1240:"Sales Analysis?:",@(65),B1$(11,1),'LF',@(3)," Territory:",@(15),B1$(21,3
1240:)," ",V3$,@(48),"    Statements?:",@(65),B1$(20,1),'LF',@(4),"Dist Code:"
1240:,@(15),B1$(8,2),"  ",V4$,@(48),"   Pricing Code:",@(65),B1$(24,4),'LF',@(
1240:0),"  Std Message:",@(15),B1$(30,2),"  ",V5$,@(48),"         Labels:",@(6
1240:5),B1$(28,2),'LF',@(0),"Sale Discount:",@(15),B1$(6,2),"  ",V6$,@(50),"Cu
1240:stomer Type:",@(65),B1$(34,3)," ",V8$
1250 PRINT (7)@(4)," Tax Code:",@(15),B1$(32,2)," ",V7$,@(51),"Credit Limit:",
1250:@(65),B[6]:M1$
1255 IF C9$(7,1)="Y" THEN PRINT (7)@(2),"Credit Hold: ",@(15),; IF B1$(39,1)="
1255:Y" THEN PRINT (7)"***Credit Hold***", ELSE PRINT (7)"N",
1260 PRINT (7)@(33),"Retain Invoice Detail History?:",@(65),B1$(38,1)
1300 LET L=L+9
1400 REM " --- Aging"
1420 PRINT (7)'LF',@(0),J$,@(15),"Aging, Sales Summary & Open Invoices"
1440 PRINT (7)@(M1-7),"Future",@(M1*2-11),"Current",@(M1*3-14),"30 Days",@(M1*
1440:4-17),"60 Days",@(M1*5-20),"90 Days",@(M1*6-24),"120 Days",@(M1*7-26),"Ba
1440:lance"
1460 PRINT (7)@(0),B[0]:M1$,@(M1*2-6),B[2]:M1$,@(M1*4-12),B[4]:M1$,@(M1*6-18),
1460:B[0]+B[1]+B[2]+B[3]+B[4]+B[5]:M1$,'LF',
1480 PRINT (7)@(M1-3),B[1]:M1$,@(M1*3-9),B[3]:M1$,@(M1*5-15),B[5]:M1$
1490 PRINT (7)'LF',@(1),"Last Invoice: ",FNB$(D1$(1,3)),@(27),"Last Payment: "
1490:,FNB$(D1$(4,3)),@(58),"Avg Days To Pay: ",D[6]:"###0-"
1500 PRINT (7)'LF',@(47+M1-6),"Prior",@(61+M1-6),"Next"
1510 PRINT (7)@(19+M1-4),"MTD",@(33+M1-4),"YTD",@(47+M1-6),"Year",@(61+M1-6),"
1510:Month"
1520 PRINT (7)@(9),"Sales:",@(19),D[0]:M1$,@(33),D[1]:M1$,@(47),D[2]:M1$,@(61)
1520:,D[8]:M1$
1530 PRINT (7)@(10),"Cost:",@(19),D[3]:M1$,@(33),D[4]:M1$,@(47),D[5]:M1$,@(61)
1530:,D[9]:M1$
1540 PRINT (7)@(2),"Gross Profit:",@(19),D[0]-D[3]:M1$,@(33),D[1]-D[4]:M1$,@(4
1540:7),D[2]-D[5]:M1$,@(61),D[8]-D[9]:M1$
1545 IF D[0]=0 THEN LET T1=0 ELSE LET T1=(D[0]-D[3])*100/D[0]
1550 IF D[1]=0 THEN LET T2=0 ELSE LET T2=(D[1]-D[4])*100/D[1]
1555 IF D[2]=0 THEN LET T3=0 ELSE LET T3=(D[2]-D[5])*100/D[2]
1557 IF D[8]=0 THEN LET T4=0 ELSE LET T4=(D[8]-D[9])*100/D[8]
1560 PRINT (7)@(0),"Gross Profit %:",@(19+M1-8),T1:"-##0.00%",@(33+M1-8),T2:"-
1560:##0.00%",@(47+M1-8),T3:"-##0.00%",@(61+M1-8),T4:"-##0.00%"
1562 PRINT (7)@(2),"Avg Days Pay:",@(19+M1-6),D[10]:"-###0",@(33+M1-6),D[12]:"
1562:-###0",@(47+M1-6),D[14]:"-###0",@(61+M1-6),D[16]:"-###0"
1564 PRINT (7)@(3),"High Credit:",@(19),D[18]:M1$,@(33),D[19]:M1$,@(47),D[20]:
1564:M1$,@(61),D[21]:M1$
1570 LET L=L+16
1990 CALL "SYC.RM",M1$,M1,9,13
2000 REM " --- Open Invoices"
2010 LET W0$="  ",T0=0,T1=0,T2=0
2020 DIM W[2],X[5]
2030 READ (ART01_DEV,KEY=N0$+W0$+A0$(3,6),DOM=2040)
2040 LET K$=KEY(ART01_DEV,END=2900)
2050 IF K$(1,10)<>N0$+W0$+A0$(3,6) THEN GOTO 2900
2060 READ (ART01_DEV)IOL=ART01A
2070 GOSUB 5600
2080 GOSUB 5840
2085 LET T0=T1+T2
2090 PRINT (7)@(7),"***Customer Total:",@(O[0]),T1:M1$,@(O[1]),T2:M1$,@(O[2]),
2090:T0:M1$; LET L=L+1
3000 REM " --- Ship-To"
3040 READ (ARM03_DEV,KEY=N0$+A0$(3,6),DOM=3060)
3080 GOSUB 5400
3100 REM " --- Job Number"
3105 IF P3$(12,1)="N" THEN GOTO 3200; REM "SKIP JOB #
3120 DIM C0$(40),C1$(148),C[2]
3140 READ (ARM09_DEV,KEY=N0$+A0$(3,6),DOM=3150)
3180 GOSUB 5500
3200 REM " --- Comments
3210 IF Y$<>"Y" THEN GOTO 3300
3215 GOSUB 5700
3220 READ (ARM05_DEV,KEY=A0$,DOM=3230)
3240 LET K$=KEY(ARM05_DEV,END=3300)
3250 IF K$(1,8)<>A0$(1,8) THEN GOTO 3300
3260 READ (ARM05_DEV,KEY=K$)IOL=ARM05A
3270 IF L>L8 THEN GOSUB 5700
3280 PRINT (7)@(0),X0$(9,2),@(7),X1$
3285 LET L=L+1
3290 GOTO 3240
3990 GOTO 1000
4000 REM " --- End"
4010 CLOSE (7,ERR=4020)
4020 LET V1$="",V2$="",V3$="",V4$="",V5$="",V6$="",V7$="",V8$=""
4030 LET M1$=ORIGINAL_M1$,M1=LEN(M1$)
4080 IF CLS$="Y" THEN PRINT @(0,L0),'CE',
4090 RUN O9$
5000 REM " --- Heading"
5020 LET L=HEADINGS+1
5040 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,H,H0,WHEN$,CLOCK$,STATUS
5050 IF STATUS<>0 THEN GOTO 4000
5060 PRINT (7)@(2),"Customer No:",@(15),FNF$(A0$(3,P[0]),M0$)
5080 PRINT (7)@(9),"Name:",@(15),A1$(1,30),'LF'
5090 LET L=L+3
5190 RETURN
5200 REM " --- Ship-To"
5210 IF L>L8-8 THEN GOSUB 5000
5240 PRINT (7)@(0),J$,@(15),"Ship-To Maintenance"
5250 LET L=L+1
5290 RETURN
5300 REM " --- Job Number"
5310 IF L>L8-16 THEN GOSUB 5000
5340 PRINT (7)'LF',@(0),J$,@(12),"Job Number Maintenance"
5350 LET L=L+2
5390 RETURN
5400 REM " --- Ship-To"
5410 LET K$=KEY(ARM03_DEV,END=5490)
5420 IF K$(1,8)<>A0$(1,8) THEN GOTO 5490
5425 DIM C1$(174),V1$(20),V3$(20),V7$(20)
5430 READ (ARM03_DEV)IOL=ARM03A
5440 GOSUB 5200
5444 FIND (ARM10_DEV,KEY=N0$+"F"+C1$(146,3),DOM=5450)IOL=ARM10F
5447 LET V1$=V1$(7,20)
5450 FIND (ARM10_DEV,KEY=N0$+"H"+C1$(149,3),DOM=5455)IOL=ARM10H
5453 LET V3$=V3$(7,20)
5455 FIND (ARM10_DEV,KEY=N0$+"B"+C1$(152,2),DOM=5460)IOL=ARM10B
5457 LET V7$=V7$(6,20)
5460 PRINT (7)@(3),"Ship-To No:",@(15),C0$(9,6),'LF',@(0),"Ship-To Name:",@(14
5460:),C1$(1,30),@(47),"Contact: ",C1$(126,20),'LF',@(5),"Address:",@(14),C1$(
5460:31,24),@(45),"Telephone: ",FNF$(C1$(112,10),M8$)," Ext: ",C1$(122,4),'LF'
5460:,@(14),C1$(55,24),@(45),"Salesprsn: ",C1$(146,3)," ",V1$,'LF',@(14),C1$(7
5460:9,24),@(45),"Territory: ",C1$(149,3)," ",V3$,'LF',@(2),"Zip/Postal:",@(14
5460:),FNZ$(C1$(103)),@(46),"Tax Code: ",C1$(152,2),"  ",V7$
5470 LET L=L+6
5480 GOTO 5410
5490 RETURN
5500 REM " --- Job Number
5510 LET K$=KEY(ARM09_DEV,END=5590)
5520 IF K$(1,8)<>A0$(1,8) THEN GOTO 5590
5530 READ (ARM09_DEV)IOL=ARM09A
5540 GOSUB 5300
5560 PRINT (7)@(7),"Job No:",@(15),C0$(9,10),'LF',@(5),"Job Name:",@(15),C1$(1
5560:,30),'LF',@(6),"Address:",@(15),C1$(31,24),'LF',@(15),C1$(55,24),'LF',@(1
5560:5),C1$(79,24),'LF',@(3),"Zip/Postal:",@(15),FNZ$(C1$(103)),'LF',@(6),"Con
5560:tact: ",C1$(126,20),'LF',@(4),"Telephone:",@(15),FNF$(C1$(112,10),M8$),@(
5560:30),"Ext:",@(35),C1$(122,4),@(42),"Retain:",@(50),C0$(40,1),'LF',
5565 PRINT (7)@(16),"Preliminary Lien Info:",'LF',@(24),"Date:",@(33),FNB$(C0$
5565:(19,3)),'LF',@(21),"Lien No:",@(30),C0$(22,12),'LF',@(22),"Amount:",@(30)
5565:,C[0]:M1$,'LF',@(6),"Date Of First Shipment:",@(33),FNB$(C0$(34,3)),'LF',
5565:@(9),"Total Sales To Date:",@(30),C[1]:M1$,'LF',@(10),"Date Last Invoiced
5565::",@(33),FNB$(C0$(37,3))
5570 LET L=L+15
5580 GOTO 5510
5590 RETURN
5600 REM " --- Open Invoices
5610 IF L>L8-3 THEN GOSUB 5000
5620 PRINT (7)@(0),J$,'LF',@(0),"Invoice",@(10),"Date",@(19),"Due",@(26),"Trms
5620:",@(31),"Type",@(O[0]+M1-8),"Invoice",@(O[1]+M1-8),"Applied",@(O[2]+M1-8)
5620:,"Balance"
5630 LET L=L+2
5690 RETURN
5700 REM " --- Comments"
5705 IF L+3>L8 THEN GOSUB 5000
5710 PRINT (7)@(0),J$,@(15),"Comments"
5720 PRINT (7)@(0),"Seq"
5740 LET L=L+2
5790 RETURN
5800 REM " --- Open Invoices
5810 LET K$=KEY(ART01_DEV,END=5966)
5820 IF K$(1,10)<>N0$+W0$+A0$(3,6) THEN GOTO 5990
5830 READ (ART01_DEV)IOL=ART01A
5840 IF L>L8-3 THEN GOSUB 5000; GOSUB 5620
5850 LET T1=T1+E[0],T2=T2+E[2]+E[3]
5880 PRINT (7)@(0),E0$(11,7)," ",FNB$(E0$(24,3))," ",FNB$(E0$(27,3)),"  ",E0$(
5880:22,2),"   ",E0$(33,1),@(O[0]),E[0]:M1$,
5883 LET FIRST$="Y"
5890 LET W[0]=0,L1=0
5900 READ (ART11_DEV,KEY=E0$(1,17),DOM=5905)
5905 LET K11$=KEY(ART11_DEV,END=5950)
5910 IF K11$(1,17)<>E0$(1,17) THEN GOTO 5950
5915 READ (ART11_DEV)IOL=ART11A
5917 IF X1$="" THEN GOTO 5905
5918 GOSUB 5970
5925 IF X1$(1,1)=" " THEN GOTO 5950
5930 LET W[0]=W[0]+X[0]+X[1],T2=T2+X[0]+X[1]
5940 GOTO 5905
5950 IF L1<1 THEN PRINT (7)@(O[2]),E[0]+W[0]:M1$; LET L=L+1; GOTO 5810
5955 PRINT (7)@(16),"***Total:",@(O[2]),E[0]+W[0]:M1$
5960 LET L=L+1
5965 GOTO 5810
5966 RETURN
5970 REM " --- Invoice Detail
5975 IF FIRST$="Y" THEN LET FIRST$="N"; PRINT (7)'LF',; LET L=L+1
5980 IF X1$(1,1)=" " THEN GOTO 5988
5981 IF L+3>L8 THEN GOSUB 5000; GOSUB 5620
5982 PRINT (7)@(8),FNB$(X1$(2,3)),@(18),X1$(5,7),@(32),X1$(1,1),@(O[1]),X[0]:M
5982:1$
5983 IF X[1]<>0 THEN PRINT (7)@(8),FNB$(X1$(2,3))," Discount Taken",@(O[1]),X[
5983:1]:M1$; LET L=L+1
5985 LET L=L+1,L1=L1+1
5990 RETURN
6000 REM " --- Subroutines"
6010 LET V1$="",V2$="",V3$="",V4$="",V5$="",V6$="",V7$="",V8$=""
6020 FIND (ARM10_DEV,KEY=N0$+"F"+B1$(1,3),DOM=6030)IOL=ARM10F
6025 LET V1$=V1$(7,20)
6030 FIND (ARM10_DEV,KEY=N0$+"A"+B1$(4,2),DOM=6040)IOL=ARM10A
6035 LET V2$=V2$(6,20)
6040 FIND (ARM10_DEV,KEY=N0$+"H"+B1$(21,3),DOM=6050)IOL=ARM10H
6045 LET V3$=V3$(7,20)
6050 FIND (ARM10_DEV,KEY=N0$+"D"+B1$(8,2),DOM=6060)IOL=ARM10D
6055 LET V4$=V4$(6,20)
6060 FIND (ARM10_DEV,KEY=N0$+"G"+B1$(30,2)+"1",DOM=6070)IOL=ARM10G
6065 LET V5$=V5$(7,20)
6070 FIND (ARM10_DEV,KEY=N0$+"I"+B1$(6,2),DOM=6080)IOL=ARM10I
6075 LET V6$=V6$(6,20)
6080 FIND (ARM10_DEV,KEY=N0$+"B"+B1$(32,2),DOM=6090)IOL=ARM10B
6085 LET V7$=V7$(6,20)
6090 FIND (ARM10_DEV,KEY=N0$+"L"+B1$(34,3),DOM=6099)IOL=ARM10L
6095 LET V8$=V8$(7,10)
6099 RETURN
8000 REM " --- Functions"
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8070 DEF FNP$(Q$)=CVS(Q$,2)
8085 DEF FNZ$(Q$)=FILL(10,CVS(Q$(1,3)+FILL(POS("9"<Q$(1,5))>0)+Q$(4,2)+FILL(AB
8085:S(POS("A">=Q$(1,6))>0)-POS("0">Q$(6,4))>0,"-")+Q$(6,4)+FILL(10),16))
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
