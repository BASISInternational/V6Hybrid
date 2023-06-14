0010 REM "IVC - Format Standard Transaction References"
0020 REM "Program IVC.TD"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0042 REM "TRANS$         : IVT-01/04 second string (A1$) (input)"
0044 REM "CHANNELS[n]    : Channel Numbers (input)"
0046 REM "                 [0] = IVM-01"
0048 REM "                 [1] = IVM-10"
0049 REM "                 [2] = ARM-01 (if installed)"
0050 REM "                 [3] = APM-01 (if installed)"
0051 REM "                 [4] = GLM-01 (if installed)"
0052 REM "PARAMS[n]      : Masking parameters (input)"
0054 REM "                 [0] = Item number length"
0056 REM "                 [1] = Customer number length (if installed)"
0058 REM "                 [2] = Vendor number length (if installed)"
0059 REM "                 [3] = GL account number length (if installed)"
0060 REM "                 [4] = Item description segment 1 length"
0062 REM "                 [5] = Item description segment 2 length"
0064 REM "                 [6] = Item description segment 3 length"
0070 REM "MASKS$[n]      : Firm ID and display masks (input)
0072 REM "                 [0] = Firm ID"
0073 REM "                 [1] = Customer mask (if installed)"
0074 REM "                 [2] = Vendor mask (if installed)"
0075 REM "                 [3] = GL account mask (if installed)"
0077 REM "TYPE$          : Abbreviated transaction type (returned)"
0078 REM "DESCRIPTION$[n]: Three line description block (returned)"
0079 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER TRANS$,CHANNELS[ALL],PARAMS[ALL],MASKS$[ALL],TYPE$,DESCRIPTION$[ALL
0090:]
0200 REM " --- IOLIST's"
0210 IVM01A: IOLIST A0$(1),A1$(1)
0220 ARM01A: IOLIST B0$(1),B1$(1)
0230 APM01A: IOLIST B0$(1),B1$(1)
0240 GLM01A: IOLIST C0$(1),C1$(1)
0250 IVM10B: IOLIST X0$(1)
0260 IVM10C: IOLIST X0$(1)
0500 REM " --- Initializations"
0510 DIM A0$(22),A1$(60),B0$(8),B1$(30),C0$(12),C1$(35),X0$(32),X1$(54),X2$(54
0510:)
0540 LET DESCRIPTION$[0]="",DESCRIPTION$[1]="",DESCRIPTION$[2]=""
0550 LET SOURCE$=TRANS$(1,2),REF1$=FNP$(TRANS$(3,6)),REF2$=TRANS$(9,7)
0555 IF POS(SOURCE$="IAIIIRIC",2)>0 THEN LET SOURCE$="IT"
0560 LET REF3$=TRANS$(16,7),REF4$=TRANS$(23,2),SEQ$=TRANS$(25,3),DESC$=""
0570 LET ITEM$=FNP$(TRANS$(51,20)),IVM01_DEV=CHANNELS[0],N0$=MASKS$[0]
0580 LET IVM10_DEV=CHANNELS[1],ARM01_DEV=CHANNELS[2]
0585 LET APM01_DEV=CHANNELS[3],GLM01_DEV=CHANNELS[4]
0590 LET TYPE$="",TYPES$="Beg BOM TranSalePhysP.O.XferXferW.O.W.O."
1000 REM " --- Retrieve finished item"
1010 IF POS(SOURCE$="BMWI",2)=0 THEN GOTO 1100
1020 LET A0$(1)=N0$+ITEM$,DESC$=""
1030 FIND (IVM01_DEV,KEY=A0$,DOM=1100)IOL=IVM01A
1040 LET DESC$=FNITEM$(A1$,PARAMS[4],PARAMS[5],PARAMS[6])
1100 REM " --- Retrieve customer name"
1110 IF POS(SOURCE$="OPWIWO",2)=0 THEN GOTO 1200
1120 IF ARM01_DEV=0 THEN GOTO 1200
1130 IF REF1$="" THEN GOTO 1200
1140 LET B0$(1)=N0$+REF1$
1150 FIND (ARM01_DEV,KEY=B0$,DOM=1160)IOL=ARM01A
1160 LET REF1$=FNF$(B0$(3,PARAMS[1]),MASKS$[1])
1200 REM " --- Retrieve vendor name"
1210 IF SOURCE$<>"PO" THEN GOTO 1300
1220 IF APM01_DEV=0 THEN GOTO 1300
1230 IF REF1$="" THEN GOTO 1300
1240 LET B0$(1)=N0$+REF1$
1250 FIND (APM01_DEV,KEY=B0$,DOM=1260)IOL=APM01A
1260 LET REF1$=FNF$(B0$(3,PARAMS[2]),MASKS$[2])
1300 REM " --- Retrieve GL account"
1310 IF POS(SOURCE$="OPITTITOBMWIWO",2)=0 THEN GOTO 1400
1320 IF GLM01_DEV=0 THEN GOTO 1400
1330 IF FNP$(TRANS$(71,10))="" THEN GOTO 1400
1340 LET C0$(1)=N0$+TRANS$(71,10)
1350 FIND (GLM01_DEV,KEY=C0$,DOM=1400)IOL=GLM01A
1360 LET DESCRIPTION$[2]="GL Acct "+FNF$(C0$(3,PARAMS[3]),MASKS$[3])+" "+C1$
1900 REM " --- Branch based on record source"
1910 LET SOURCE=POS(SOURCE$="BBBMITOPPHPOTITOWIWO",2)
1980 IF SOURCE>0 THEN LET SOURCE=INT((SOURCE+1)/2)
1990 ON SOURCE GOTO 4000,2000,2100,2200,2300,2400,2500,2600,2600,2700,2800,400
1990:0
2000 REM " --- BB Beginning Balance"
2010 LET X1$(1)="Beginning Balance"
2090 GOTO 4000
2100 REM " --- BM Bill of Materials Production Entry"
2110 LET X1$(1)="Ref "+REF2$
2120 IF ITEM$="" THEN GOTO 4000
2130 LET X2$(1)="Item "+ITEM$+" "+DESC$
2190 GOTO 4000
2200 REM " --- IT Inventory Transactions"
2210 LET X0$(6,20)="(Undefined Code)",X2$(1)="Ref "+REF2$
2220 FIND (IVM10_DEV,KEY=N0$+"B"+REF4$,DOM=2230)IOL=IVM10B
2230 LET X1$(1)="Code "+REF4$+" "+X0$(6,20)+TRANS$(31,20)
2240 IF FNP$(SEQ$)<>"" THEN LET X2$(12)="-"+SEQ$
2290 GOTO 4000
2300 REM " --- Type "OP" (Invoice)"
2310 LET X1$(1)="Customer "+REF1$+" "+B1$
2320 LET X2$(1)="Invoice "+REF3$+"-"+SEQ$+" Order "+REF2$+" Line "+TRANS$(28,1
2320:)
2390 GOTO 4000
2400 REM " --- PH Physical Inventory Adjustment"
2410 LET X1$(1)="Physical Inventory Adjustment"
2420 LET X2$(1)="Cycle "+REF4$+"  Loc "+TRANS$(81,10)
2490 GOTO 4000
2500 REM " --- PO Purchase Order Receipt"
2510 LET X1$(1)="Vendor "+REF1$+" "+B1$
2520 LET X2$(1)="PO "+REF2$+"-"+SEQ$+" Line "+TRANS$(91,2)
2590 GOTO 4000
2600 REM " --- TI/TO Transfer In/Out"
2610 LET X0$(6,24)="(Undefined Warehouse)",X2$(1)="Ref "+REF2$
2620 FIND (IVM10_DEV,KEY=N0$+"C"+REF4$,DOM=2630)IOL=IVM10C
2630 IF SOURCE$="TO" THEN LET X1$(1)="To "+REF4$+" "+X0$(6,24)
2640 IF SOURCE$="TI" THEN LET X1$(1)="From "+REF4$+" "+X0$(6,24)
2690 GOTO 4000
2700 REM " --- WI Work Order Issue"
2710 LET X1$(1)="WO "+REF3$+"-"+SEQ$+"  Type "+REF4$,P=1
2720 IF REF1$<>"" THEN LET X1$(29)="Customer "+REF1$
2730 IF FNP$(ITEM$)<>"" THEN LET X2$(P)="Item "+ITEM$,P=LEN(FNP$(ITEM$))+7
2740 IF FNP$(REF2$)<>"" THEN LET X2$(P)="SO "+REF2$
2750 IF FNP$(REF2$)="" THEN LET X2$(P)=DESC$
2790 GOTO 4000
2800 REM " --- WO Work Order Receipt"
2810 LET X1$(1)="WO "+REF3$+"  Type "+REF4$,P=1
2820 IF REF1$<>"" THEN LET X2$(1)="Customer "+REF1$,P=18
2830 IF FNP$(REF2$)<>"" THEN LET X2$(P)="SO "+REF2$
2890 GOTO 4000
4000 REM " --- All done"
4010 LET DESCRIPTION$[0]=FNP$(X1$),DESCRIPTION$[1]=FNP$(X2$)
4020 IF SOURCE>0 THEN LET TYPE$=TYPES$((SOURCE-1)*4+1,4)
4090 GOTO 9900
8000 REM " --- Functions"
8080 DEF FNP$(Q$)=CVS(Q$,2)
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
9210 LET STATUS=999
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 REM " --- Return to calling program"
9950 EXIT
9999 END
