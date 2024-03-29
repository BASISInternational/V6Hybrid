0010 REM "SYM - G/L Posting Control Listing"
0020 REM "Program GLM.BB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files"
0110 CALL "SYC.GA",7,1,"","",STATUS
0115 IF STATUS THEN GOTO 9900
0200 REM " --- IOLIST's"
0210 SYM19A: IOLIST A0$(1),A1$(1),A2$,A3$,A[ALL]
0220 GLM06A: IOLIST B0$(1),B1$(1),B2$(1),B3$,B[ALL]
0500 REM " --- Initializations"
0510 DIM HEADINGS$[2]
0520 LET L9=59,L=L9+1,H0=132,H=0,HEADINGS=2,WHEN$=F0$(7,3),CLOCK$=""
0550 LET HEADINGS$[0]=N1$,HEADINGS$[1]=N4$+" Listing"
0700 REM " --- Background"
0750 CALL "SYC.NB","Printing",19,COLUMN
0900 REM " --- Position File"
0990 READ (GLM06_DEV,KEY=N0$,DOM=1000)
1000 REM " --- Main Read"
1010 LET K$=KEY(GLM06_DEV,END=4000)
1020 IF POS(N0$=K$)<>1 THEN GOTO 4000
1040 READ (GLM06_DEV)IOL=GLM06A
1050 PRINT @(COLUMN,11),B0$(3,10)," ",B0$(13,8),
1500 REM " --- Retrieve SYM-19 Process Definition"
1510 LET A1$(1)="Not On File"
1520 FIND (SYM19_DEV,KEY=B0$(3,18),DOM=1530)IOL=SYM19A
2000 REM " --- Format detail line fields"
2010 DIM D0$(32)
2020 LET USEDDATE$="",USEDTIME$="",UPDTDATE$="",UPDTTIME$=""
2110 IF FNP$(B1$(11,6))<>"" THEN LET USEDDATE$=FNB6$(B1$(11,6)),USEDTIME$=FNT$
2110:(B1$(17,4))
2120 IF FNP$(B1$(21,6))<>"" THEN LET UPDTDATE$=FNB6$(B1$(21,6)),UPDTTIME$=FNT$
2120:(B1$(27,4))
2130 LET AUDIT$="None",SUMMARY$="None",DETAIL$="Summary"
2140 IF B1$(37,1)="Y" THEN LET AUDIT$=STR(B[0]:M1$)
2150 IF B1$(38,1)="Y" THEN LET SUMMARY$=B1$(31,6)
2160 IF B1$(39,1)="Y" THEN LET DETAIL$="Detail"
2170 IF B1$(39,1)="A" THEN LET DETAIL$="By Acct"
2200 REM " --- Print Record"
2210 IF L>L9 THEN GOSUB 5000
2250 PRINT (7)B0$(3,10),@(12),B0$(13,8),@(22),A1$,@(54),B1$(1,2),@(58),DETAIL$
2250:,@(66),AUDIT$,@(96),USEDDATE$," ",USEDTIME$," ",@(111),UPDTDATE$," ",UPDT
2250:TIME$,@(126),SUMMARY$
2290 LET L=L+1,T0=T0+1
3900 REM " --- Loop back for next record"
3990 GOTO 1000
4000 REM " --- All done"
4010 IF L+2>L9 THEN GOSUB 5000
4020 PRINT (7)""
4030 PRINT (7)T0," Total Record(s)"
4090 GOTO 9900
5000 REM " --- Report heading"
5010 LET L=HEADINGS+1
5020 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,H,H0,WHEN$,CLOCK$,STATUS
5030 IF STATUS>0 THEN EXITTO 9900
5040 PRINT (7)@(66),"Last",@(99),"Last Used",@(113),"Last Updated"
5050 PRINT (7)"Process",@(12),"Program",@(22),"Description",@(53),"Jrnl",@(58)
5050:,"Detail",@(66),"Audit #",@(98),"Date    Time",@(113),"Date    Time",@(12
5050:6),"File"
5060 PRINT (7)""
5080 LET L=L+3
5090 RETURN
8000 REM " --- Functions"
8020 DEF FNB6$(Q$)=Q$(3,2)+"/"+Q$(5,2)+"/"+FNYY21_YY$(Q$(1,2))
8070 DEF FNT$(Q$)=Q$(1,2)+":"+Q$(3,2)
8080 DEF FNP$(Q$)=CVS(Q$,2)
8145 REM " --- FNYY21_YY$ Un-Convert 21st Century 2-Char Year to 2-Char Year"
8150 DEF FNYY21_YY$(Q1$)
8155 LET Q3$=" 01234567890123456789",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABC
8155:DEFGHIJ"))
8160 RETURN Q1$
8165 FNEND
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
9900 REM " --- Return to menu"
9950 RUN "SYS.AA"
9999 END
