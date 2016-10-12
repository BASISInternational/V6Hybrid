0010 REM "OPR - Sales Register (Cash Sales)"
0020 REM "Program OPR.HB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0 - 15May96 |"
0026 REM "|      Copyright (c) 1996 Open Systems Holdings Corp.       |"
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLists"
0210 ARE03A: IOLIST A0$,A[ALL]
0220 ARE20A: IOLIST D0$,D1$,D[0]
0230 ARM01A: IOLIST B0$,B1$
0240 ARM10C: IOLIST *,X1$
0250 ARW20A: IOLIST X0$
0500 REM " --- Initialize Data"
0510 PRECISION 4
0520 DIM D[1],R[2,1]
0540 LET L=L9+1,HEADINGS$[3]="Cash Receipts Summary"
0550 LET T0$="",T9$=""

0600 rem 'V6Demo --- set up docout; use DocoutWrapper
0610 use ::DocoutWrapper.bbj::DocoutWrapper
0620 declare DocoutWrapper report!
0630 xUserName$ = "guest", xPassword$ = ""

0640 docname$ = n0$+"_CashSales"

0650 report! = new DocoutWrapper(n0$, "SlsRegCashSls", docname$, xUserName$, xPassword$)
0660 gosub addColumns; gosub addHeadings; gosub setOutputAction

0700 REM " --- Background"
0720 IF P3$(15,1)="N" THEN GOTO 4100
0780 PRINT @(40,5),"Sorting Cash Sales",'CL',@(0,10),'CL',@(0,11),'CL',@(0,12),'CL',
0790 CALL "SYC.NB","Sorting",M0+8,COLUMN
1000 REM " --- Sort Cash"
1040 READ (ARE20_DEV,KEY=N0$,DOM=1050)
1100 REM " --- Main Read"
1120 READ (ARE20_DEV,END=2000)IOL=ARE20A
1140 IF POS(N0$=D0$)<>1 THEN GOTO 2000
1160 FIND (ARE03_DEV,KEY=D0$(1,17)+"000",DOM=1100)IOL=ARE03A
1180 IF A0$(68,2)<>"YS" THEN GOTO 1100
1200 REM " --- Write Record"
1210 IF SEQ$="C" THEN PRINT @(COLUMN,11),FNF$(D0$(5,P[0]),M0$)," ",D0$(50,7),
1220 IF SEQ$="I" THEN PRINT @(COLUMN,11),D0$(50,7)," ",FNF$(D0$(5,P[0]),M0$),
1240 LET X0$=D0$(1,4)+D0$(18,3)+D0$(50,7)+D0$(5,13)
1250 IF SEQ$="C" THEN LET X0$(8,7)=""
1260 WRITE (ARW20_DEV,KEY=X0$)IOL=ARW20A
1290 GOTO 1100
2000 REM " --- Print"
2010 PRINT @(40,5),"Printing Cash Sales",'CL',@(0,10),'CL',@(0,11),'CL',@(0,12),'CL',
2020 CALL "SYC.NB","Printing",M0+17,COLUMN
2090 READ (ARW20_DEV,KEY=N0$,DOM=2100)
2100 REM " --- Main Read"
2120 LET K$=KEY(ARW20_DEV,END=4000)
2140 IF POS(N0$=K$)<>1 THEN GOTO 4000
2160 READ (ARW20_DEV)
2200 REM " --- Breaks
2220 IF K$(5,3)<>T0$ THEN LET I=0; GOSUB 6000
2320 FIND (ARE20_DEV,KEY=K$(1,4)+K$(15,13),DOM=2100)IOL=ARE20A
2330 DIM X1$(30)
2340 FIND (ARM10_DEV,KEY=N0$+"C"+D0$(21,3),DOM=2350)IOL=ARM10C
2400 REM " --- Get Customer
2440 FIND (ARM01_DEV,KEY=N0$+D0$(5,6),DOM=2460)IOL=ARM01A
2450 LET B1$=B1$(1,30)
2460 IF P3$(15,1)="Y" THEN IF D0$(5,6)=P3$(16,6) THEN IF FNP$(D1$)<>"" THEN LET B1$=D1$
2500 REM " --- Print"
2510 PRINT @(COLUMN,11),FNB$(T0$)," ",FNF$(D0$(5,P[0]),M0$)," ",D0$(50,7),
2520 IF L+1>L9 THEN GOSUB 5000

2540 rem ' PRINT (7)FNF$(D0$(5,P[0]),M0$),@(8),B1$(1,30),@(40),D0$(50,7),@(49),FNB$(D0$(18,3)),@(60),D0$(21,3),
2545 dim row$:rowTemplate$; row.column01$=FNF$(D0$(5,P[0]),M0$) + " " + B1$(1,30); row.column02$=D0$(50,7); row.column03$=FNB$(D0$(18,3)); row.column04$=D0$(21,3)

2550 rem ' IF X1$(21,1)="P" THEN PRINT (7)@(64),D0$(31,16),@(81),FNB$(D0$(47,3)),@(90),D[0]:M1$; GOTO 2600
2555 IF X1$(21,1)="P" then row.column05$=fill(12,"X")+D0$(43,4); row.column06$=FNB$(D0$(47,3)); row.column07$=str(D[0]:M1$)+$00$+"R"; report!.addRow(row$); goto 2600

2560 rem ' PRINT (7)@(104),D0$(31,16),@(120),D[0]:M1$
2565 row.column08$=D0$(31,16); row.column09$=str(D[0]:M1$)+$00$+"R"; report!.addRow(row$)

2600 LET L=L+1
2700 REM " --- Totals"
2710 FOR I=0 TO 1
2720 IF X1$(21,1)="$" THEN LET R[0,I]=R[0,I]+D[0]
2740 IF X1$(21,1)="C" THEN LET R[1,I]=R[1,I]+D[0]
2760 IF X1$(21,1)="P" THEN LET R[2,I]=R[2,I]+D[0]
2780 NEXT I
2990 GOTO 2100
4000 REM " --- Totals"
4020 LET T9$="E"
4030 FOR I=0 TO 1
4040 GOSUB 6000
4050 NEXT I
4060 report!.renderReport()
4100 RUN "OPR.HC"
5000 REM " --- Heading"
5005 rem ' replaced by docout 
5010 rem ' CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,PAGE,WIDTH,WHEN$,CLOCK$,STATUS
5015 rem ' IF STATUS>0 THEN EXITTO 9900
5020 rem ' LET L=HEADINGS+1
5040 rem ' PRINT (7)""
5050 rem ' PRINT (7)"Customer",@(40),"Invoice",@(49),"Invoice",@(59),"Pay",@(67),"***  Credit Card Deposit  ***",@(106),"***  Cash Deposit  ***"
5060 rem ' PRINT (7)@(0),"No.     Name",@(40),"Number",@(51),"Date",@(59),"Type",@(66),"Number",@(84),"Exp",@(93),"Amount",@(103),"Memo",@(125),"Amount"
5080 rem ' LET L=L+3
5090 RETURN
6000 REM " --- Date Break"
6010 IF T0$="" THEN GOTO 6100
6020 LET X$="Total For "+FNB$(T0$)
6040 IF I=1 THEN LET X$="Total All Cash Receipts"
6045 IF L+4>L9 THEN GOSUB 5000

6050 rem ' PRINT (7)@(90),FILL(M1,"-"),@(120),FILL(M1,"-"),'LF',@(39),X$,@(66),"Credit Cards:",@(90),R[2,1]:M1$,@(103),"Cash:",@(120),R[0,I]:M1$,'LF',@(103),"Checks:",@(120),R[1,I]:M1$,'LF'
6052 dim row$:rowTemplate$; row.column07$=FILL(15,"-"); row.column09$=FILL(15,"-");report!.addRow(row$)
6053 dim row$:rowTemplate$; row.column02$=X$; row.column05$="Credit Cards:"; row.column07$=str(R[2,1]:M1$)+$00$+"R"; row.column08$="Cash:"+$00$+"R"; row.column09$=str(R[0,I]:M1$)+$00$+"R"; report!.addRow(row$)
6054 dim row$:rowTemplate$; row.column08$="Checks:"+$00$+"R"; row.column09$=str(R[1,I]:M1$)+$00$+"R"; report!.addRow(row$)

6055 LET L=L+4
6100 IF T9$<>"" THEN RETURN
6110 LET T0$=K$(5,3)
6120 FOR X=0 TO 2
6130 FOR Y=0 TO I
6140 LET R[X,Y]=0
6150 NEXT Y
6160 NEXT X
6190 RETURN
8000 REM " --- Functions"
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8080 DEF FNP$(Q$)=CVS(Q$,2)
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

16000 addColumns:
16010 rem ' add columns to the Report
16020 report!.addColumn("Customer^No./Name","C",30,0,"","L","L")
16030 report!.addColumn("Invoice^Number","C",8,0,"","L","L")
16040 report!.addColumn("Invoice^Date","C",8,0,"","L","L")
16050 report!.addColumn("Pay^Type","C",5,0,"","L","L")
16060 report!.addColumn("Credit Card^Number","C",20,0,"","L^L","")
16070 report!.addColumn("Card^Expires","C",8,0,"","L^L","")
16080 report!.addColumn("Credit^Amount","C",10,0,"","R^R","")
16090 report!.addColumn("Cash^Memo","C",15,0,"","R^R","")
16100 report!.addColumn("Cash^Amount","C",10,0,"","R^R","R")
16140 columnCount = report!.getColumnCount()
16150 rowTemplate$ = report!.getRowTemplate()
16160 dim row$:rowTemplate$
16170 return

16200 addHeadings:
16210 report!.addHeading(HEADINGS$[0])
16220 report!.addHeading(HEADINGS$[1])
16230 report!.addHeading(HEADINGS$[3])
16240 return

16300 setOutputAction:
16310 rem ' indicates individual out put fields may contain special formatting
16320 report!.setOutputAction("FORMAT")
16330 return