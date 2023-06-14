0010 REM "POC - Create QA/PO Receiver From PO Or PO From Requisition"
0020 REM "Program POC.MA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.7           |
0026 REM "|         Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0031 REM "12Jul96 JAL: Use correct variable in IOLIST when updating POE-5x PO 
0031:by Receiver x-ref file (250)"
0032 REM "14Oct96 WGH: Write POE-42/43/44 by item x-ref for 'S' Line Types (49
0032:-60,140,240,410-420,530,2100-2320)"
0033 REM "28Oct97 WGH: Fix test for Shop Floor Control interface (2610)"
0034 REM "15Jun98 WGH: Don't initialize Last Receipt Date when creating PO fro
0034:m requisition (1010,1040)"
0035 REM "30Dec99 WGH: Use conversion factor for updating inventory's on-order
0035: quantity (2420)
0040 REM 
0042 REM "TYPE$    : Record type (Input)"
0046 REM "           P=Purchase Order/Q=QA Receipt/C=PO Receipt"
0048 REM "FILES[n] : Channel numbers (Input)"
0049 REM "                 TYPE$=P    TYPE$=Q    TYPE$=C
0050 REM "           [0]=   POE-11     POE-12     POE-12
0051 REM "           [1]=   POE-02     POE-03     POE-04
0052 REM "           [2]=   POE-12     POE-13     POE-14
0053 REM "           [3]=   POE-32     POE-33     POE-34
0054 REM "           [4]=   POE-52     POE-53     POE-54
0055 REM "           [5]=   POM-02     POM-02     POM-02
0056 REM "           [6]=   IVM-01       na         na
0057 REM "           [7]=   IVM-02       na         na
0058 REM "           [8]=   WOE-22       na         na
0059 REM "           [9]=   WOE-32       na         na
0060 REM "          [10]=   POE-42     POE-43     POE-44
0066 REM "STATUS   : 0=No error (Returned)" 
0068 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER TYPE$,FILES[ALL],PARAMS$[ALL],A0$,A1$,A[ALL],B0$,B1$,B[ALL],PLACES,
0090:STATUS
0100 REM " --- Open/Lock Files"
0110 LET POE12_DEV=FILES[0],POE04_DEV=FILES[1],POE14_DEV=FILES[2]
0120 LET POE34_DEV=FILES[3],POE54_DEV=FILES[4],POM02_DEV=FILES[5]
0130 LET IVM01_DEV=FILES[6],IVM02_DEV=FILES[7],WOE22_DEV=FILES[8]
0140 LET WOE32_DEV=FILES[9],POE44_DEV=FILES[10]
0200 REM " --- IOLIST's"
0210 POE04A: IOLIST A0$,A1$,A2$,A3$,A[ALL]
0230 POE34A: IOLIST X3$(1)
0240 POE44A: IOLIST X4$(1)
0250 POE54A: IOLIST X5$(1)
0280 POE12A: IOLIST R0$(1),W1$(1),W2$(1),W3$(1),W4$(1),W5$,W6$,W[ALL]
0290 POE14A: IOLIST W0$(1),W1$(1),W2$(1),W3$(1),W4$(1),W5$,W6$,W[ALL]
0310 POM02A: IOLIST Y0$(1),Y1$(1)
0400 REM " --- Parameters"
0410 LET X3=22,X4=45,W0=25
0420 IF TYPE$="P" THEN LET X3=15,X4=38,W0=18
0430 LET F0$=PARAMS$[0],I2$=PARAMS$[2],I3$=PARAMS$[3],I4$=PARAMS$[4]
0500 REM " --- Initializations"
0505 PRECISION PLACES
0510 DIM CHANNELS[99],PARAMS[10],ITEM$[10],REFS[20],REFS$[20]
0520 DIM W0$(W0),W1$(48),W2$(32),W3$(22),W4$(40),W[12],Y0$(4),Y1$(32),R0$(18)
0530 DIM X3$(X3),X4$(X4),X5$(22)
0550 LET N0$=A0$(1,2),CHANNELS[1]=IVM01_DEV,CHANNELS[2]=IVM02_DEV
1000 REM " --- Initialize receipt header and header xrefs"
1010 LET A1$(1)=B1$,A1$(29,6)="",A[ALL]=B[ALL]
1020 IF TYPE$="P" THEN GOTO 1200
1030 LET X3$(1)=N0$+A0$(16,7)+A0$(3),X5$(1)=N0$+A0$(9,7)+A0$(3,6)+A0$(16,7)
1040 LET A1$(29,6)=F0$(18,6)
1090 GOTO 1500
1200 REM " --- Initialize PO header and header xrefs"
1210 LET A1$(112,7)=B0$(9),X3$(1)=N0$+A0$(9)+A0$(3)
1220 LET X5$(1)=N0$+A1$(112,7)+A0$(3)
1500 REM " --- Write header and header xrefs"
1510 WRITE (POE04_DEV,KEY=A0$)IOL=POE04A
1520 WRITE (POE34_DEV,KEY=X3$)IOL=POE34A
1530 WRITE (POE54_DEV,KEY=X5$)IOL=POE54A
1900 REM " --- Position detail file"
1990 READ (POE12_DEV,KEY=B0$,DOM=2000)
2000 REM " --- Read next detail line"
2010 LET K$=KEY(POE12_DEV,END=4000)
2020 IF POS(B0$=K$)<>1 THEN GOTO 4000
2030 READ (POE12_DEV)IOL=POE12A
2040 LET W0$(1)=A0$+R0$(16,3)
2050 IF TYPE$="P" THEN LET W[3]=W[2]
2060 IF TYPE$="C" THEN LET W[4]=W[7],W[5]=0,W[6]=0,W[7]=0,W[8]=0
2080 WRITE (POE14_DEV,KEY=W0$)IOL=POE14A
2100 REM " --- Get Purchase Order Line Code"
2110 IF N0$+W1$(1,2)=Y0$ THEN GOTO 2220
2120 LET Y1$(1)=""
2130 FIND (POM02_DEV,KEY=N0$+W1$(1,2),DOM=2900)IOL=POM02A
2140 LET Y0$(1)=N0$+W1$(1,2)
2200 REM " --- Write By Item X-Ref For 'S' Line Types"
2210 IF Y1$(21,1)<>"S" THEN GOTO 2300
2220 IF TYPE$="P" THEN LET X4$(1)=W0$(1,2)+W3$(3,20)+W0$(9,10)+W0$(3,6) ELSE L
2220:ET X4$(1)=W0$(1,2)+W3$(3,20)+W0$(16,10)+W0$(3,13)
2240 WRITE (POE44_DEV,KEY=X4$)IOL=POE44A
2300 REM " --- Converting a Requisition to a PO requires additional"
2310 REM " --- processing for standard and nonstock items"
2320 IF TYPE$<>"P" THEN GOTO 2900
2400 REM " --- Increase quantity on-order"
2410 IF Y1$(21,1)<>"S" THEN GOTO 2600
2420 LET ITEM$[0]=N0$,ITEM$[1]=W3$(1,2),ITEM$[2]=W3$(3),REFS[0]=W[3]*W[0]
2430 LET ACTION$="OO",PARAMS$[2]=I2$,PARAMS$[3]=I3$,PARAMS$[4]=I4$
2440 CALL "IVC.UA",ACTION$,CHANNELS[ALL],PARAMS[ALL],PARAMS$[ALL],ITEM$[ALL],R
2440:EFS$[ALL],REFS[ALL],STATUS
2600 REM " --- Remove any existing work order link"
2610 IF WOE22_DEV=0 OR WOE32_DEV=0 THEN GOTO 2900
2620 IF POS(Y1$(21,1)="NS")=0 THEN GOTO 2900
2630 IF FNP$(W2$(1,7))="" THEN GOTO 2900
2650 LET PO$=W0$(9),OLDWO$=W2$(1,10),NEWWO$=OLDWO$
2660 CALL "POC.WA",WOE22_DEV,WOE32_DEV,N0$,PO$,TYPE$,Y1$,OLDWO$,NEWWO$,PLACES,
2660:STATUS
2900 REM " --- Loop back for next line item"
2990 GOTO 2000
4000 REM " --- All done"
4090 GOTO 9900
8000 REM " --- Functions"
8070 DEF FNP$(Q$)=CVS(Q$,2)
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
9950 EXIT
9999 END
