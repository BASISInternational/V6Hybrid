0010 REM "SYC - Report Heading Subroutine"
0020 REM "Program SYC.HA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.1           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0031 REM "02Jul96 JAL: Route interrupt message to (PRINTER) rather than (7) (7
0031:450-7460)"
0040 REM 
0045 REM "PRINTER    : Printer channel"
0050 REM "HEADING$[*]: Report heading lines"
0055 REM "HEADINGS   : Number of HEADING$ lines to print (1 or more)"
0060 REM "PAGE       : Page number"
0065 REM "WIDTH      : Width of report line (80 or 132)"
0070 REM "WHEN$      : Date in packed format"
0075 REM "CLOCK$     : Time (set automatically on first call)"
0077 REM "STATUS     : 0=No Error / Otherwise printer error or interrupt"
0079 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER PRINTER,HEADING$[ALL],HEADINGS,PAGE,WIDTH,WHEN$,CLOCK$,STATUS
0400 REM " --- Parameters"
0410 DIM GLCONTROL$(640)
0420 LET GLCONTROL$(1)=STBL("!GLCONTROL",ERR=0430)
0430 LET AUDIT=WIDTH-1,AUDIT$=FNP$(GLCONTROL$(20,7))
0440 IF AUDIT$="" THEN GOTO 0500
0450 LET AUDIT$="Audit # "+AUDIT$,AUDIT=WIDTH-LEN(AUDIT$)
0500 REM " --- Initializations"
0510 LET STATUS=0,FF$='FF'
0540 IF CLOCK$="" THEN LET CLOCK$=DATE(0:"%hz:%mz %p")
0550 IF WHEN$="" THEN LET WHEN$=FND$(DATE(0:"%Mz%Dz%Yz"))
0560 LET TMP1$=FNB$(WHEN$),TMP2$=CLOCK$
1000 REM " --- Check for interrupt"
1010 GOSUB 7400
1100 IF HEADINGS=0 AND FNP$(HEADING$[0])="" THEN GOTO 4000
1200 REM " --- Initial form feed?"
1210 IF PAGE>0 THEN GOTO 1400
1220 LET X$=STBL("!FF",ERR=1400)
1230 IF X$="N" THEN LET FF$='CR'
1240 LET X$=STBL("!CLEAR","!FF",ERR=1400)
1400 REM " --- Batching?"
1420 LET PROCESS$=STBL("!PROCESS",ERR=2000)
1440 LET TMP1$=FNB$(WHEN$)+" "+CLOCK$,TMP2$="Batch: "+STR(NUM(PROCESS$(13,3)):
1440:"000")
2000 REM " --- Print report heading"
2010 LET PAGE=PAGE+1
2030 PRINT (PRINTER)FF$,@(FNC(HEADING$[0],WIDTH)),HEADING$[0],@(0),TMP1$,@(WID
2030:TH-9)," Page",PAGE:"###0"
2040 PRINT (PRINTER)@(FNC(HEADING$[1],WIDTH)),HEADING$[1],@(0),TMP2$,@(AUDIT),
2040:AUDIT$
2100 REM " --- Print remaining heading lines"
2110 IF HEADINGS<2 THEN GOTO 4000
2120 FOR X=2 TO HEADINGS
2130 PRINT (PRINTER)@(FNC(HEADING$[X],WIDTH)),HEADING$[X]
2140 NEXT X
4000 REM " --- All done"
4090 GOTO 9900
7400 REM " --- Printing interrupt"
7410 INPUT (0,SIZ=0,TIM=0,ERR=7490)V$
7420 IF CTL<>4 THEN GOTO 7490
7430 CALL "SYC.RI",V
7440 IF V=0 THEN GOTO 7490
7450 PRINT (PRINTER)""
7460 PRINT (PRINTER)"----> Report Terminated by Operator"
7470 LET STATUS=999
7480 GOTO 9900
7490 RETURN
8000 REM " --- Functions"
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8025 DEF FNC(Q$,Q)=INT((Q-LEN(Q$))/2)
8040 DEF FND$(Q$)=CHR(FNYY_YEAR(Q$(5,2))+32)+CHR(NUM(Q$(1,2))+32)+CHR(NUM(Q$(3
8040:,2))+32)
8090 DEF FNP$(Q$)=CVS(Q$,2)
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
9210 LET STATUS=ERR
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
