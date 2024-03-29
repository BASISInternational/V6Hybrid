0010 REM "SYM - User Maintenance Listing"
0020 REM "Program SYM.BB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0080 SETERR 9000
0090 SETESC 9000
0100 REM " --- Open/Lock Files"
0110 CALL "SYC.GA",7,1,"","",STATUS
0120 IF STATUS THEN GOTO 9900
0200 REM " --- IOLIST's"
0210 SYM02A: IOLIST A0$(1),A1$(1),A[ALL]
0500 REM " --- Initializations"
0510 DIM HEADINGS$[2],KOLORS$[6]
0550 LET L9=55,L=L9+1,WIDTH=80,PAGE=0,HEADINGS=2,NUMBER=0,WHEN$=""
0560 LET HEADINGS$[0]="ADD+ON Software",HEADINGS$[1]=F5$+" Listing"
0570 LET C[1]=C[1]-6,C[3]=C[3]-6,C[5]=C[5]-6
0700 REM " --- Background"
0710 CALL "SYC.NB","Printing",3,COLUMN
0900 REM " --- Position File"
0990 READ (SYM02_DEV,KEY="",DOM=1000)
1000 REM " --- Main Read"
1010 READ (SYM02_DEV,END=4000)IOL=SYM02A
1020 PRINT @(COLUMN,11),A0$,
1200 REM " --- Retrieve firms/printers"
1210 LET CHANNEL=SYM12_DEV,FIRMS$="",V$=""
1220 GOSUB 6000
1230 LET CHANNEL=SYM22_DEV,PRINTERS$="",FIRMS$=V$,V$=""
1240 GOSUB 6000
1500 REM " --- Format output fields"
1510 DIM KOLORS$[6]
1520 LET PASSWORD$="No",PRINTERS$=V$,JUMP$="No"
1530 IF A1$(27,1)="Y" THEN LET PASSWORD$="Yes"
1535 IF A1$(110,1)="Y" THEN LET JUMP$="Yes"
1540 FOR X=1 TO 6
1550 LET X$=A1$(X[X],10)
1560 FOR Y=1 TO 8
1570 IF FNP$(X$)=FNP$(FNU$(COLORS$[Y])) THEN LET KOLORS$[X]=COLORS$[Y]
1580 NEXT Y
1590 NEXT X
2000 REM " --- Print user info"
2010 IF L+9>L9 THEN GOSUB 5000
2020 PRINT (7)""
2030 PRINT (7)A0$," ",A1$(1,24),@(30),A1$(25,1),@(33),PASSWORD$,@(40),A1$(104,
2030:6),@(47),JUMP$,@(52),A1$(26,1),@(58),A1$(37,2),@(63),A1$(39,2),@(72),A[0]
2030::M2$,@(77),A1$(101,3)
2040 PRINT (7)""
2200 REM " --- Firms"
2210 PRINT (7)@(9),"Firms: ",
2220 IF LEN(FIRMS$)>0 THEN GOTO 2250
2230 PRINT (7)"All",
2240 GOTO 2290
2250 FOR X=1 TO LEN(FIRMS$) STEP 2
2260 PRINT (7)FIRMS$(X,2)," ",
2270 NEXT X
2290 PRINT (7)""
2300 REM " --- Printers"
2310 PRINT (7)@(6),"Printers: ",
2320 IF LEN(PRINTERS$)>0 THEN GOTO 2350
2330 PRINT (7)"None",
2340 GOTO 2390
2350 FOR X=1 TO LEN(PRINTERS$) STEP 2
2360 PRINT (7)PRINTERS$(X,2)," ",
2370 NEXT X
2390 PRINT (7)""
2400 REM " --- Colors"
2410 PRINT (7)""
2420 PRINT (7)@(C[1]),"Base Window Color",@(C[3]),"Window 1 Color",@(C[5]),"Wi
2420:ndow 2 Color"
2430 PRINT (7)@(4),"Background:",@(C[1]),KOLORS$[1],@(C[3]),KOLORS$[3],@(C[5])
2430:,KOLORS$[5]
2440 PRINT (7)@(4),"Foreground:",@(C[1]),KOLORS$[2],@(C[3]),KOLORS$[4],@(C[5])
2440:,KOLORS$[6]
2450 LET L=L+9,NUMBER=NUMBER+1
3900 REM " --- Loop back for next record"
3990 GOTO 1000
4000 REM " --- All done"
4010 IF L+2>L9 THEN GOSUB 5000
4020 PRINT (7)""
4030 PRINT (7)NUMBER," Total User(s)"
4090 GOTO 9900
5000 REM " --- Report heading"
5010 LET L=HEADINGS+3
5020 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,PAGE,WIDTH,WHEN$,CLOCK$,STATUS
5030 IF STATUS>0 THEN EXITTO 9900
5040 PRINT (7)"User",@(29),"Sec",@(40),"Def",@(47),"Menu Field Case Caps - PF 
5040:Files -"
5050 PRINT (7)"ID  Name",@(29),"Lev Passwd",@(40),"Menu",@(47),"Jump Type  Key
5050:  Key  Number    ID"
5090 RETURN
6000 REM " --- Retrieve firms/printers"
6010 READ (CHANNEL,KEY=A0$,DOM=6020)
6020 LET K$=KEY(CHANNEL,END=6090)
6030 IF POS(A0$=K$)<>1 THEN GOTO 6090
6040 READ (CHANNEL)
6050 LET V$=V$+K$(4)
6060 GOTO 6020
6090 RETURN
8000 REM " --- Functions"
8025 DEF FNC(Q$,Q)=INT((Q-LEN(Q$))/2)
8080 DEF FNP$(Q$)=CVS(Q$,2)
8090 DEF FNU$(Q$)=CVS(Q$,4)
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
