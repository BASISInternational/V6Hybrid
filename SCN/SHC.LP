0010 REM "SHC - Package/Shipment Lookup And Inquiry"
0020 REM "Program SHC.LP"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.5           |
0026 REM "|         Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0031 REM "25Mar98 WGH: Error 47 on Line 1650 when Shipping History Inquiry is 
0031:displayed in Customer sequence (1650)"
0040 REM 
0041 REM "TYPE$      : L=Lookup/I=Inquiry (input)"
0054 REM "CHANNELS[N]: Channel Numbers (input)"
0055 REM "             [0] = ARM-01/SHM-02   [3] = SHE-02/SHT-02"
0056 REM "             [1] = SHM-10          [4] = SHE-04/SHT-04"
0057 REM "             [2] = SHE-01/SHT-01   [5] = SYS-01"
0060 REM "PARAMS$[n] : SpeedShip Parameters (input)"
0061 REM "             [0] = Firm ID            [2] = Customer Input Mask"
0062 REM "             [1] = Parameter string   [3] = Customer Output Mask"
0064 REM "CUSTLEN    : Customer number length (input)"
0065 REM "OPTIONS$[n]: Inventory Item Information (input/returned)"
0066 REM "             [0] = Sequence              [7] = Ending Order"
0067 REM "             [1] = Detail Level          [8] = Beginning PO"
0068 REM "             [2] = Beginning date        [9] = Ending PO"
0069 REM "             [3] = Ending date          [10] = Carrier"
0070 REM "             [4] = Beginning customer   [11] = Beginning Service"
0071 REM "             [5] = Ending customer      [12] = Ending Service"
0072 REM "             [6] = Beginning order"
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER TYPE$,CHANNELS[ALL],PARAMS$[ALL],CUSTLEN,OPTIONS$[ALL],SELECTION$
0100 REM " --- Open/Lock Files"
0110 LET ARM01_DEV=CHANNELS[0],SHM10_DEV=CHANNELS[1],SHE01_DEV=CHANNELS[2]
0120 LET SHE02_DEV=CHANNELS[3],SHT04_DEV=CHANNELS[4],SYS01_DEV=CHANNELS[5]
0200 REM " --- IOLIST's"
0210 SHE01A: IOLIST A0$,A1$,A2$,A[ALL]
0220 ARM01A: IOLIST B0$(1),B1$(1)
0270 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0310 SHE02A: IOLIST W0$,W1$(1)
0400 REM " --- Parameters"
0405 DIM P[2],SPEED$(128)
0410 LET PAGES=INT((DSZ-5000)/4000),MAXROW=15,MAXPAGE=21
0420 IF PAGES<3 THEN GOTO 9900
0430 IF PAGES>MAXPAGE THEN LET PAGES=MAXPAGE
0440 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9800)IOL=SYS01T
0445 LET I1$=PARAMS$[1],M0$=PARAMS$[3]
0450 LET N0$=F0$(16,2),SPEEDSEARCH$="N",P[0]=CUSTLEN,M0=LEN(M0$)
0460 LET SPEED$(1)=STBL("!SPEEDSEARCH",ERR=0480)
0470 LET N0$=SPEED$(1,2),SPEEDSEARCH$="Y"
0500 REM " --- Initializations"
0510 DIM A[8],B0$(8),B1$(30),W1$(128)
0540 LET WIDTH=80,HEIGHT=12,WIN_X=0,WIN_Y=4
0550 IF TYPE$="I" THEN LET WIN_Y=3,HEIGHT=20
0560 LET MAX_ROW=HEIGHT-5
0600 REM " --- Window arrays"
0610 DIM HEADING$(WIDTH-2),FOOTING$(WIDTH-2)
0620 LET HEADING$(2)="Customer",HEADING$(21)="Shipment Ordered  Shipped"
0625 LET HEADING$(48)="Service Customer PO Total Pkgs"
0630 LET FOOTING$(2)="F1=Restart  F4=End  PgUp  PgDn"
0640 LET TITLE$="Shipment Lookup"
0650 IF TYPE$="I" THEN LET TITLE$="Shipment Inquiry"
0700 REM " --- Background"
0710 CALL "SYC.WA",0,WIDTH,HEIGHT,WIN_X,WIN_Y,TITLE$,NAME$
0720 PRINT @(0,0),'SB','BR',HEADING$,@(0,HEIGHT-3),FOOTING$,'ER','SF',
0800 REM " --- Range parameters"
0810 LET SEQUENCE$=OPTIONS$[0],LEVEL$=OPTIONS$[1],BEGDATE$=OPTIONS$[2]
0820 LET ENDDATE$=OPTIONS$[3],BEGCUST$=OPTIONS$[4],ENDCUST$=OPTIONS$[5]
0830 LET BEGSHIP$=OPTIONS$[6],ENDSHIP$=OPTIONS$[7],BEGPO$=OPTIONS$[8]
0840 LET ENDPO$=OPTIONS$[9],CARRIER$=OPTIONS$[10],BEGSERV$=OPTIONS$[11]
0850 LET ENDSERV$=OPTIONS$[12],START$=BEGSHIP$
0860 IF SEQUENCE$="C" THEN LET START$=BEGCUST$
0875 IF SEQUENCE$="D" THEN LET START$=BEGDATE$
1000 REM " --- Position file"
1010 DIM LLIST$[PAGES,MAX_ROW,5],MORE$[PAGES,MAX_ROW,2]
1020 LET PAGE=1,L=1,X1=1,X0=0,SELECTION$=""
1090 ON POS(SEQUENCE$="SCD") GOTO 9900,1100,1200,1300
1100 REM " --- Shipment Number"
1110 READ (SHE01_DEV,KEY=N0$+START$,DOM=1400)
1190 GOTO 1400
1200 REM " --- By Customer"
1210 READ (SHT04_DEV,KEY=N0$+"A"+START$,DOM=1400)
1290 GOTO 1400
1300 REM " --- By Date"
1310 READ (SHT04_DEV,KEY=N0$+"B"+START$,DOM=1400)
1400 REM " --- Read next record"
1490 ON POS(SEQUENCE$="SCD") GOTO 9900,1500,1600,1700
1500 REM " --- Next SHE-01 key"
1510 LET K$=KEY(SHE01_DEV,END=3000)
1520 IF POS(N0$=K$)<>1 THEN GOTO 3000
1530 LET X$=K$(3)
1590 GOTO 1900
1600 REM " --- Next SHT-04 Customer key"
1610 LET K$=KEY(SHT04_DEV,END=3000)
1620 IF POS(N0$+"A"=K$)<>1 THEN GOTO 3000
1630 IF ENDCUST$<>"" THEN IF K$(4,6)>ENDCUST$ THEN GOTO 3000
1640 READ (SHT04_DEV)
1650 LET K$=N0$+K$(10),X$=K$(3)
1690 GOTO 1900
1700 REM " --- Next SHT-04 Date key"
1710 LET K$=KEY(SHT04_DEV,END=3000)
1720 IF POS(N0$+"B"=K$)<>1 THEN GOTO 3000
1730 IF ENDDATE$<>"" THEN IF K$(4,6)>ENDDATE$ THEN GOTO 3000
1740 READ (SHT04_DEV)
1750 LET K$=N0$+K$(16)+K$(4,6),X$=K$(3)
1900 REM " --- Read record"
1910 LET LOCKED=0
1920 READ (SHE01_DEV,KEY=K$,ERR=1950)IOL=SHE01A
1940 GOTO 2000
1950 REM " --- Error reading record"
1960 IF ERR=11 THEN GOTO 2900
1970 IF ERR<>0 THEN GOTO 9000
1980 LET LOCKED=1
2000 REM " --- Display page?"
2010 IF L+1<MAX_ROW THEN GOTO 2100
2020 LET XMODE=5,BRANCH=0
2030 GOSUB 6200
2040 IF FKEY=1 THEN GOTO 1000
2050 IF FKEY=4 THEN GOTO 9900
2060 IF SELECTION$<>"" THEN GOTO 4000
2100 REM " --- Range tests"
2110 IF BEGSHIP$<>"" THEN IF A0$(3,7)<BEGSHIP$ THEN GOTO 2900
2120 IF ENDSHIP$<>"" THEN IF A0$(3,7)>ENDSHIP$ THEN GOTO 2900
2130 IF BEGDATE$<>"" THEN IF A0$(21,6)<BEGDATE$ THEN GOTO 2900
2140 IF ENDDATE$<>"" THEN IF A0$(21,6)>ENDDATE$ THEN GOTO 2900
2150 IF BEGCUST$<>"" THEN IF A1$(1,6)<BEGCUST$ THEN GOTO 2900
2160 IF ENDCUST$<>"" THEN IF A1$(1,6)>ENDCUST$ THEN GOTO 2900
2170 IF BEGPO$<>"" THEN IF A2$(13,10)<BEGPO$ THEN GOTO 2900
2180 IF ENDPO$<>"" THEN IF A2$(13,10)>ENDPO$ THEN GOTO 2900
2300 REM " --- Read customer"
2310 LET B0$(1)=N0$+A1$(1,6),B1$(1)="",CUSTOMER$=B0$(3,P[0]),SERVICE$=""
2320 FIND (ARM01_DEV,KEY=B0$,DOM=2330)IOL=ARM01A
2330 IF I1$(1,1)="Y" THEN LET CUSTOMER$=FNF$(CUSTOMER$,M0$)
2350 REM " --- Get service from first detail"
2360 LET NUMBER=0
2390 READ (SHE02_DEV,KEY=A0$,DOM=2400)
2400 REM " --- Check for carrier and service ranges"
2410 LET K$=KEY(SHE02_DEV,END=2600)
2420 IF POS(A0$(1,17)=K$)<>1 THEN GOTO 2600
2430 READ (SHE02_DEV)IOL=SHE02A
2440 IF CARRIER$<>"" THEN IF W1$(11,1)<>CARRIER$ THEN GOTO 2490
2450 IF BEGSERV$<>"" THEN IF W1$(4,7)<BEGSERV$ THEN GOTO 2490
2460 IF ENDSERV$<>"" THEN IF W1$(4,7)>ENDSERV$ THEN GOTO 2490
2470 IF SERVICE$="" THEN LET SERVICE$=W1$(4,7)
2480 LET NUMBER=NUMBER+1
2490 GOTO 2400
2600 REM " --- Any valid packages?
2610 IF NUMBER=0 THEN GOTO 2900
2700 REM " --- Lookup window record"
2710 DIM G$(WIDTH-2)
2720 IF LOCKED THEN GOTO 2750
2730 LET G$(2)=CUSTOMER$+" "+B1$
2740 GOTO 2780
2750 LET G$(2)=CUSTOMER$+" Record In Use"
2780 LET LLIST$[PAGE,X1,1]=G$,LLIST$[PAGE,X1,2]=A0$
2790 LET X0=X0+1,X1=X1+1,L=L+1
2800 REM " --- Second line of window"
2810 LET G$(1)="",G$(21)=A0$(3,7)
2820 IF FNP$(A2$(7,6))<>"" THEN LET G$(30)=FNB6$(A2$(7,6))
2830 LET G$(39)=FNB6$(A2$(1,6)),G$(48)=SERVICE$,G$(56)=A2$(13,10)
2840 LET G$(66)=STR(A[0]+A[1]:"###0.00"),G$(74)=STR(A[2]:"###0")
2880 LET LLIST$[PAGE,X1,1]=G$,LLIST$[PAGE,X1,2]=A0$
2890 LET X0=X0+1,X1=X1+1,L=L+1
2900 REM " --- Loop back for next record"
2910 IF LOCKED=0 THEN GOTO 1400
2920 LET LOCKED=0
2930 IF PREFIX$<>"" AND PREFIX$<>"*" THEN GOTO 1400
2940 LET K$=K$(1,LEN(K$)-1)+CHR(ASC(K$(LEN(K$),1))+1)
2950 READ (SHE01_DEV,KEY=K$,DOM=1400,END=3000)IOL=SHE01A
2990 GOTO 1400
3000 REM " --- End of file"
3010 IF X0>0 THEN GOTO 3500
3020 DIM MESSAGE$[1]
3030 LET V2=WIN_Y+INT(HEIGHT/2)-2,V1=-1
3035 LET MESSAGE$[0]="No Shipments Found (<Enter>=Continue)"
3040 CALL "SYC.XA",3,MESSAGE$[ALL],0,V2,V1,V$,V3
3060 IF V3=5 THEN GOTO 4000
3070 IF V3=6 THEN GOTO 4000
3080 IF V3=4 THEN GOTO 4000
3090 GOTO 0800
3500 REM " --- Display last page"
3510 LET XMODE=5,BRANCH=1,SELECTION$=SELECTION$+"|EOF"
3520 GOSUB 6200
3530 IF FKEY=1 THEN GOTO 1000
4000 REM " --- All done"
4010 IF TYPE$<>"I" THEN GOTO 9900
4020 IF FKEY=4 THEN GOTO 9900
4030 IF SELECTION$="END" THEN LET SELECTION$=""
4040 IF SELECTION$="PRIOR" AND SPEEDSEARCH$="N" THEN LET SELECTION$=""
4050 IF SELECTION$="" THEN GOTO 9900
4100 REM " --- Retrieve header and call detail lookup"
4110 LET A0$(1)=SELECTION$
4120 FIND (SHE01_DEV,KEY=A0$,DOM=9900)IOL=SHE01A
4130 CALL "SHC.LD",TYPE$,A0$,CHANNELS[ALL],PARAMS$[ALL],CUSTLEN,OPTIONS$[ALL],
4130:X$
4200 REM " --- Branch back to display"
4210 ON BRANCH GOTO 2000,3500,9900
4290 GOTO 9900
6200 REM " --- Display page"
6210 CALL "SYC.SA",XMODE,LLIST$[ALL],MORE$[ALL],SELECTION$,PAGE,MAX_ROW,NAME$,
6210:HEIGHT,WIDTH,FKEY
6220 IF FKEY=1 THEN GOTO 6290
6230 IF FKEY=-16 THEN LET PAGE=PAGE+1
6250 IF PAGE>PAGES-1 THEN CALL "SYC.RB",LLIST$[ALL],MORE$[ALL],PAGES,PAGE,MAX_
6250:ROW,5,SHEIGHT-2
6280 LET L=1,X1=1
6290 RETURN
8000 REM " --- Functions"
8025 DEF FNB6$(Q$)=Q$(3,2)+"/"+Q$(5,2)+"/"+FNYY21_YY$(Q$(1,2))
8070 DEF FNP$(Q$)=CVS(Q$,2)
8145 REM " --- FNYY21_YY$ Un-Convert 21st Century 2-Char Year to 2-Char Year"
8150 DEF FNYY21_YY$(Q1$)
8155 LET Q3$=" 01234567890123456789",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABC
8155:DEFGHIJ"))
8160 RETURN Q1$
8165 FNEND
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
9800 REM " --- Display Parameter record error"
9810 LET LINE_ERR$=LST(PGM(TCB(5)))
9820 CALL "SYC.YA",LINE_ERR$,N2$,ERR
9900 REM " --- Return to calling program"
9910 IF FKEY=4 THEN LET SELECTION$="END"
9920 IF NAME$<>"" THEN CALL "SYC.WD",NAME$
9930 IF SELECTION$="END" THEN LET SELECTION$=""
9940 IF SELECTION$="PRIOR" AND SPEEDSEARCH$="N" THEN LET SELECTION$=""
9950 EXIT
9999 END
