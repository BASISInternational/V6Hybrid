0010 REM "IVC - Inventory SpeedSearch (Lot/Serial Numbers)"
0020 REM "Program IVC.QC"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0045 REM "D_STATUS  : SpeedSearch Status (0=No Error)"
0050 REM "OPTION$[n]: Standard SpeedSearch Options Array"
0055 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER D_STATUS,OPTION$[ALL]
0100 REM " --- Open Files"
0105 LET FILES=6
0110 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0120 LET FILES$[1]="IVM-01",FILES$[2]="IVM-07",FILES$[3]="IVM-03"
0130 LET FILES$[4]="IVM-10",FILES$[5]="IVM-14",FILES$[6]="APM-01"
0150 CALL "SYC.DA",1,1,5,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0160 IF STATUS>0 THEN GOTO 9900
0170 LET IVM01_DEV=CHANNELS[1],IVM07_DEV=CHANNELS[2],IVM03_DEV=CHANNELS[3]
0180 LET IVM10_DEV=CHANNELS[4],IVM14_DEV=CHANNELS[5]
0200 REM " --- IOLIST's"
0210 IVM01A: IOLIST A0$(1),A1$(1),A2$(1),A3$,A4$,A5$,A6$,A[ALL]
0220 IVM07A: IOLIST B0$(1),B1$(1),B[ALL]
0230 APM01A: IOLIST C0$(1),C1$(1)
0240 IVM10C: IOLIST X0$(1)
0260 IVS01A: IOLIST X$,P1$,P2$,P3$,P4$,M0$,M1$,M2$,M3$
0270 APS01A: IOLIST X$,I1$,I2$,I3$,I4$,M0$
0400 REM " --- Parameters"
0410 DIM P[5],I[2],INFO$[20],X$(128)
0415 LET X$(1)=STBL("!SPEEDSEARCH",ERR=9900),N0$=X$(1,2),MAXPAGE=NUM(X$(66,2))
0420 LET TNAME$=FNP$(X$(3,8)),TWIDTH=NUM(X$(35,2)),THEIGHT=NUM(X$(37,2))
0425 LET NAME$=FNP$(X$(11,8)),WIDTH=NUM(X$(39,2)),HEIGHT=NUM(X$(41,2))
0430 LET SNAME$=FNP$(X$(19,8)),SWIDTH=NUM(X$(43,2)),SHEIGHT=NUM(X$(45,2))
0435 LET MAXOPT=NUM(X$(57,2)),SYS01_DEV=NUM(STBL("!SYS01")),ONAME$=FNP$(X$(27,
0435:8))
0440 LET PARAM$=FNU$(FNP$(OPTION$[2])),SUBPARAM$="",P=POS("/"=PARAM$)
0445 IF P>0 THEN LET SUBPARAM$=PARAM$(P+1),PARAM$=PARAM$(1,P-1)
0450 LET PAGES=INT((DSZ-5000)/4000)
0455 IF PAGES<3 THEN GOTO 9900
0460 IF PAGES>MAXPAGE THEN LET PAGES=MAXPAGE
0465 FIND (SYS01_DEV,KEY=N0$+"IV00",DOM=9900)IOL=IVS01A
0470 IF POS(P3$(17,1)="LS")=0 THEN GOTO 4900
0475 LET P[0]=NUM(P2$(1,2)),P[1]=NUM(P2$(5,1)),P[2]=MAX(NUM(P2$(7,2)),12)
0480 LET P[3]=NUM(P2$(9,2)),P[4]=NUM(P2$(11,2)),P[5]=NUM(P2$(13,2))
0485 CALL "SYC.VA","AP",INFO$[ALL]
0490 LET AP$=INFO$[20]
0500 REM " --- Initializations"
0505 PRECISION P[1]
0510 DIM A0$(22),A1$(60),A2$(64),A[12],OPTLIST$[2,MAXOPT,6],FILES[14]
0520 DIM HEADING$(WIDTH-2),FOOTING$(WIDTH-2),PARAMS[3],ITEM$[6],X0$(32)
0530 DIM B0$(45),B1$(96),B[12],C0$(8),C1$(30),VENDOR$(50)
0540 LET D_STATUS=0,MAXROW=HEIGHT-5,PAGE=1,A0$(1)=N0$+OPTION$[3],H0=WIDTH-2
0560 LET PARAMS[0]=P[0],PARAMS[1]=P[3],PARAMS[2]=P[4],PARAMS[3]=P[5],DONE=0
0570 LET FILES[1]=IVM01_DEV,FILES[14]=IVM14_DEV,COLUMN=17+MAX(M3,M4)
0580 LET M2=LEN(M2$),P=M2+13,PGM$=PGM(-2),OPTN=0,DW=WIDTH-P[0]-10
0600 REM " --- Additional file opens"
0610 IF AP$="N" THEN GOTO 0650
0615 CALL "SYC.DA",1,6,6,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0620 IF STATUS>0 THEN GOTO 9900
0625 FIND (SYS01_DEV,KEY=N0$+"AP00",DOM=9900)IOL=APS01A
0630 LET I[0]=NUM(I2$(1,2)),APM01_DEV=CHANNELS[6],M0=LEN(M0$)
0650 REM " --- Option Window"
0660 CALL "SYC.QC",SYM01_DEV,SYM11_DEV,PGM$,SECURITY$,OPTION,OPTLIST$[ALL],TIT
0660:LE$,OMAXROW,PREVMENU$,ONAME$
0700 REM " --- Background"
0710 CALL "SYC.WB",NAME$,0
0720 LET HEADING$(2)="Lot/Serial #",HEADING$(P[2]+3)="Received Issued"
0730 IF AP$="N" THEN GOTO 0740
0735 LET HEADING$(P[2]+21)="Vendor",HEADING$(P[2]+21+MAX(M0,7))="Name"
0740 LET FOOTING$(2)=TITLE$,FOOTING$(WIDTH-26)="PgUp  PgDn  F4=End"
0750 PRINT @(0,0),'CS','SB','BR',HEADING$,@(0,HEIGHT-3),FOOTING$,'ER','SF',
0900 REM " --- Position file"
0910 CALL "SYC.WB",SNAME$,0
0920 PRINT 'CF',
0930 CALL "SYC.WB",TNAME$,0
0940 PRINT 'CS',
0990 GOTO 1100
1000 REM " --- Process key field"
1010 GOSUB 6000
1015 CALL "SYC.WB",TNAME$,0
1020 PRINT @(0,0),'CS','SB'," Item:",'SF',
1025 LET V2$="",V2$=KEY(IVM01_DEV,END=1040)
1030 IF POS(N0$=V2$)<>1 THEN LET V2$=""
1035 IF V2$<>"" THEN LET V2$=V2$(3,P[0])
1040 LET ACTION$="V",V1=7,V2=0,V4$=""
1045 CALL "IVC.IA",ACTION$,V1,V2,FILES[ALL],N0$,V2$,V4$,PARAMS[ALL],ITEM$[ALL]
1045:,A[ALL],V3
1050 ON V3 GOTO 1060,1000,1000,1000,3800,3900,3800
1060 LET V$=FNP$(ITEM$[0])
1070 IF V$="" THEN GOTO 0900
1080 LET A0$(3)=V$
1100 REM " --- Retrieve record for display"
1110 DIM LLIST$[PAGES,MAXROW,5],MORE$[PAGES,MAXROW,SHEIGHT-2],D$(DW)
1120 READ (IVM01_DEV,KEY=A0$,DOM=1000)IOL=IVM01A
1130 LET LINE=1,L=1,X0=0,X1=1,PAGE=1,D$(1)=FNITEM$(A1$,P[3],P[4],P[5])
1140 PRINT @(0,0),'CL','SB'," Item: ",'SF',A0$(3,P[0])," ",D$,
1150 LET X$="",X1$=A0$(3,P[0]),X2$=PARAM$,WHSE$=""
1160 CALL "SYC.QB",X$,X1$,X2$
1170 READ (IVM03_DEV,KEY=N0$+"G"+A0$(3),DOM=1180)
1180 LET K$=KEY(IVM03_DEV,END=1200)
1185 IF POS(N0$+"G"+A0$(3)=K$)<>1 THEN GOTO 1200
1190 LET WHSE$=K$(24,2)
1200 REM " --- Warehouse ID"
1205 PRINT @(1,1),'CL','SB',"Whse:",'SF',
1210 LET V0$="S",V1$="KE",V2$=WHSE$,V3$="",V4$="",V0=2,V1=7,V2=1
1215 GOSUB 7000
1240 ON V3 GOTO 1260,1200,1000,1250,3800,3900,3800
1250 CALL "IVC.LK",3,V1,V2,V$
1260 LET WHSE$=V$+"  ",WHSE$=WHSE$(1,2)
1270 FIND (IVM10_DEV,KEY=N0$+"C"+WHSE$,DOM=1200)IOL=IVM10C
1280 PRINT @(V1,V2),WHSE$," ",X0$(6,20),
1300 REM " --- Position lot/serial master"
1380 LET FIRST$=N0$+WHSE$+A0$(3)
1390 READ (IVM07_DEV,KEY=FIRST$,DOM=1400)
1400 REM " --- Read next IVM-07 record"
1410 LET K$=KEY(IVM07_DEV,END=1900)
1420 IF POS(FIRST$=K$)<>1 THEN GOTO 1900
1430 READ (IVM07_DEV)IOL=IVM07A
1440 LET VENDOR$(1)=""
1450 IF AP$="N" THEN GOTO 1500
1455 IF FNP$(B1$(55,6))="" THEN GOTO 1500
1460 LET C1$(1)=" (Not On File)"
1470 FIND (APM01_DEV,KEY=N0$+B1$(55,6),DOM=1480)IOL=APM01A
1480 LET VENDOR$(1)=FNF$(C0$(3,I[0]),M0$),VENDOR$(MAX(8,M0+2))=C1$
1500 REM " --- Display page?"
1510 IF L<MAXROW THEN GOTO 1600
1520 LET ACTION$="M",CHOICE1$="",CHOICE2$=""
1530 GOSUB 5000
1540 IF DONE THEN GOTO 4000
1570 IF ANSWER$<>"" THEN GOTO 3000
1590 LET L=1,X1=1
1600 REM " --- Middle window record"
1610 DIM G1$(WIDTH-2),G2$(SWIDTH-2)
1620 LET G1$(2)=B0$(25),RECEIPT$=FNL$(B1$(64,3),B1$(67,3))
1630 LET ISSUED$=FNL$(B1$(70,3),B1$(73,3))
1640 IF FNP$(RECEIPT$)<>"" THEN LET G1$(P[2]+3)=FNB$(RECEIPT$)
1650 IF FNP$(ISSUED$)<>"" THEN LET G1$(P[2]+12)=FNB$(ISSUED$)
1680 LET G1$(P[2]+21)=VENDOR$,G1$(WIDTH-2)=""
1690 LET LLIST$[PAGE,X1,1]=G1$,LLIST$[PAGE,X1,2]=B0$(25)
1700 REM " --- Bottom window record"
1710 LET MORE$[PAGE,X1,0]=STR(SHEIGHT-2)
1720 LET G2$(1)="  {On Hand:}"+STR(B[0]:M2$),G2$(P+1)=B1$(14,40)
1730 LET MORE$[PAGE,X1,1]=G2$,G2$(1)="{Committed:}"+STR(B[1]:M2$)
1740 LET G2$(P)="{Unit Cost:}"+STR(B[4]:M3$),MORE$[PAGE,X1,2]=G2$
1750 LET G2$(1)="{Available:}"+STR(B[0]-B[1]:M2$)
1760 LET G2$(P)=" {Location:}"+B1$(1,7),MORE$[PAGE,X1,3]=G2$
1780 LET LLIST$[PAGE,X1,5]=SNAME$,X0=X0+1,X1=X1+1,L=L+1
1790 GOTO 1400
1900 REM " --- No more warehouses"
1910 IF X0>0 THEN GOTO 2000
1920 DIM MESSAGE$[1]
1930 LET MESSAGE$[0]="No Lot/Serial Numbers Found (<Enter>=Continue)"
1940 CALL "SYC.XA",3,MESSAGE$[ALL],0,-1,-1,V$,V3
1960 IF V3=5 THEN GOTO 3900
1970 IF V3=6 THEN GOTO 3800
1980 LET SELECTION$="PRIOR"
1990 GOTO 3000
2000 REM " --- Display last page"
2010 LET ACTION$="M",CHOICE1$="",CHOICE2$=""
2020 GOSUB 5000
2030 IF DONE THEN GOTO 4000
3000 REM " --- Process option window"
3010 DIM MORE$[1,MAXOPT,1],LLIST$[0,0,0]
3020 LET ACTION$="O",CHOICE1$=A0$(3),CHOICE2$=""
3030 GOSUB 5000
3040 IF CONTROL=1 THEN GOTO 1000
3090 GOTO 4000
3800 REM " --- Exit"
3810 LET OPTION$[1]="EXIT"
3890 GOTO 4000
3900 REM " --- Startover"
3910 LET OPTION$[1]="STARTOVER"
4000 REM " --- All done"
4010 GOSUB 6000
4090 GOTO 9900
4900 REM " --- Lotted/Serialized Inventory not enabled"
4910 CALL "IVC.SB","L",STATUS
4920 LET D_STATUS=0
4990 GOTO 9900
5000 REM " --- Standard window processing"
5010 DIM WININFO$[10],WININFO[10]
5020 LET WININFO$[1]=CHOICE1$,WININFO$[2]=CHOICE2$
5030 LET WININFO[1]=PAGE,WININFO[2]=PAGES,WININFO[3]=OMAXROW
5050 CALL "SYC.QW",ACTION$,OPTION$[ALL],OPTLIST$[ALL],LLIST$[ALL],MORE$[ALL],W
5050:ININFO$[ALL],WININFO[ALL],FKEY
5060 LET ANSWER$=WININFO$[0],CONTROL=WININFO[0],PAGE=WININFO[1]
5080 LET DONE=OPTION$[1]="EXIT" OR OPTION$[1]="STARTOVER" OR OPTION$[1]="PRIOR
5080:"
5090 RETURN
6000 REM " --- Clear all windows"
6010 CALL "SYC.WB",TNAME$,0
6020 PRINT 'CF',
6030 CALL "SYC.WB",NAME$,0
6040 PRINT 'CF',
6050 CALL "SYC.WB",SNAME$,0
6060 PRINT 'CS',
6090 RETURN
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
8080 DEF FNP$(Q$)=CVS(Q$,2)
8085 DEF FNU$(Q$)=CVS(Q$,4)
8090 DEF FNITEM$(Q$,Q1,Q2,Q3)=CVS(Q$(1,Q1)+" "+Q$(Q1+1,Q2)+" "+Q$(Q1+Q2+1,Q3),
8090:32)
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
8300 REM " --- Multi-Line Functions"
8310 DEF FNL$(Q1$,Q2$)
8320 IF CVS(Q1$,2)="" THEN LET Q1$="ZZZ"
8330 IF CVS(Q2$,2)="" THEN LET Q2$="ZZZ"
8340 LET Q$=Q1$
8350 IF Q2$>Q1$ THEN LET Q$=Q2$
8360 IF Q$="ZZZ" THEN LET Q$="   "
8370 RETURN Q$
8380 FNEND
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
9900 REM " --- Return to caller"
9910 FOR X=1 TO FILES
9920 CLOSE (CHANNEL[X],ERR=9921)
9930 NEXT X
9950 EXIT
9999 END
