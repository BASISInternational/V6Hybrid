0010 REM "POC - Retrieve/Update Vendor/Item Information"
0020 REM "Program POC.UA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0042 REM "ACTION$  : Action code R=Read/W=Write (Input)"
0044 REM "TYPE$    : Record type (Input)"
0046 REM "           R=Requisition/P=Purchase Order"
0048 REM "           Q=QA Receipt/C=PO Receipt"
0050 REM "IVM05_DEV: IVM-05 channel number (Input)"
0052 REM "A0$      : Header record 1st string (Input)"
0054 REM "A1$      : Header record 2nd string (Input)"
0056 REM "W3$      : Detail record 4th string - warehouse/item (Input)"
0058 REM "W[ALL]   : Detail record numerics (Input)"
0060 REM "PLACES   : Number of decimal places precision (Input)"
0062 REM "STATUS   : 0=No error (Returned)"
0064 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER ACTION$,TYPE$,IVM05_DEV,A0$,A1$,W3$,W[ALL],PLACES,STATUS
0200 REM " --- IOLIST's"
0210 IVM05A: IOLIST B0$(1),B1$(1),B2$(1),B[ALL]
0500 REM " --- Initializations"
0505 PRECISION PLACES
0510 DIM B0$(28),B1$(32),B2$(20),B[12]
0550 LET B0$(1)=A0$(1,8)+W3$(3),B1$(1,1)="S"
0560 LET WHEN$=FND$(FNN$(A1$(5,6))),QTY=W[2]
0570 IF POS(TYPE$="PQC") THEN LET QTY=W[3]
0580 LET QTY=QTY*W[0]
1000 REM " --- Retrieve current record"
1010 FIND (IVM05_DEV,KEY=B0$,DOM=4000)IOL=IVM05A
1020 IF ACTION$="W" THEN GOTO 3000
2000 REM " --- Reassign cost if record exists"
2010 IF B[6]>0 THEN LET W[1]=B[6]*W[0]
2020 IF B[3]>0 THEN IF QTY>=B[0] THEN LET W[1]=B[3]*W[0]
2030 IF B[4]>0 THEN IF QTY>=B[1] THEN LET W[1]=B[4]*W[0]
2040 IF B[5]>0 THEN IF QTY>=B[2] THEN LET W[1]=B[5]*W[0]
2090 GOTO 4000
3000 REM " --- Update last PO date"
3010 IF W[0] THEN LET B[6]=W[1]/W[0]
3020 IF WHEN$>B1$(2,3) THEN LET B1$(2,3)=WHEN$
3030 IF POS(TYPE$="PQC") THEN WRITE (IVM05_DEV,KEY=B0$)IOL=IVM05A
4000 REM " --- All done"
4090 GOTO 9900
8000 REM " --- Functions"
8040 DEF FND$(Q$)=CHR(FNYY_YEAR(Q$(5,2))+32)+CHR(NUM(Q$(1,2))+32)+CHR(NUM(Q$(3
8040:,2))+32)
8060 DEF FNN$(Q$)=Q$(3,4)+Q$(1,2)
8080 DEF FNP$(Q$)=CVS(Q$,2)
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
