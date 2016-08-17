0010 REM "SYC - Load Menu"
0020 REM "Program SYC.QC"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0 - 15May96 |"
0026 REM "|      Copyright (c) 1996 Open Systems Holdings Corp.       |"
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0043 REM "SYM01_DEV      : SYM-01 channel (input)"
0044 REM "SYM11_DEV      : SYM-11 channel (input)"
0045 REM "PGM$           : Calling program name (input)"
0046 REM "SECURITY$      : User security level (input/output)"
0047 REM "OPTION         : Starting element of OPTLIST$ (input)"
0048 REM "OPTLIST$[a,b,c]: Option list (output)
0049 REM "               : a = Number of pages, must be greater than one"
0050 REM "               : b = Option number
0052 REM "               : c = Option element"
0054 REM "               :     1 = Description"
0056 REM "               :     2 = Program/Menu Name"
0058 REM "               :     3 = Parameter String"
0060 REM "               :     4 = Option Type"
0062 REM "               :     5 = Security Level"
0064 REM "               :     6 = Password"
0066 REM "TITLE$         : Title of menu or submenu (output)"
0068 REM "MAXROW         : Number of options (output)"
0069 REM "PREVMENU$      : Return menu for current selection (output)"
0070 REM "NAME$          : If non-blank, program displays available options"
0072 REM "               : in window specified by NAME$"
0074 REM 
0080 SETERR 9000
0085 SETESC 9000
0090 ENTER SYM01_DEV,SYM11_DEV,PGM$,SECURITY$,OPTION,OPTLIST$[ALL],TITLE$,MAXR
0090:OW,PREVMENU$,NAME$
0200 REM " --- IOLIST's"
0210 SYM01A: IOLIST A0$(1),A1$(1),A2$(1)
0220 SYM11A: IOLIST W0$(1),W1$(1),W2$(1),W3$(1),W4$(1)
0400 REM " --- Parameters"
0410 DIM X$(128)
0420 LET CURRENT$="",MAXLINES=17
0450 LET X$(1)=STBL("!SPEEDSEARCH",ERR=0500),CURRENT$=X$(51,6)
0460 LET SYM01_DEV=NUM(STBL("!SYM01",ERR=9900)),MAXLINES=NUM(X$(63,2))
0470 LET SYM11_DEV=NUM(STBL("!SYM11",ERR=9900)),SECURITY$=X$(65,1)
0500 REM " --- Initializations"
0510 DIM A0$(6),A1$(35),A2$(16),W0$(8),W1$(35),W2$(16),W3$(30),W4$(60)
0550 LET PROGRAM$=FNP$(PGM$),TITLE$="",PREVMENU$=""
1000 REM " --- Load option array for program menu"
1010 LET A0$(1)=PROGRAM$,A2$(9,1)="S"
1020 GOSUB 6000
1090 IF POS(A2$(9,1)="ST")=0 THEN GOTO 3000
1100 REM " --- Load option array for current menu"
1110 LET A0$(1)=CURRENT$
1120 GOSUB 6000
1200 REM " --- Last option is always "PRIOR SCREEN"
1210 IF FNP$(CURRENT$)="" THEN GOTO 4000
1220 IF OPTION<MAXLINES THEN LET OPTION=OPTION+1
1230 LET OPTLIST$[1,OPTION,1]=" Prior Screen"
1240 LET OPTLIST$[1,OPTION,2]="PRIOR",OPTLIST$[1,OPTION,3]=""
3000 REM " --- Display options if option window is specified"
3010 IF NAME$="" THEN GOTO 4000
3020 CALL "SYC.WB",NAME$,0
3030 PRINT 'CS',
3040 FOR X=1 TO OPTION
3050 PRINT @(0,X-1),OPTLIST$[1,X,1],
3060 NEXT X
4000 REM " --- All done"
4010 LET MAXROW=OPTION+1
4090 GOTO 9900
6000 REM " --- Load option array for current menu"
6010 FIND (SYM01_DEV,KEY=A0$,DOM=6900)IOL=SYM01A
6020 IF TITLE$="" THEN LET TITLE$=FNP$(A1$)
6030 LET PREVMENU$=A2$(3,6),BLANK$=""
6040 IF A2$(9,1)<>"A" THEN LET BLANK$=" "
6090 READ (SYM11_DEV,KEY=A0$,DOM=6100)
6100 REM " --- Read next option"
6110 LET K$=KEY(SYM11_DEV,END=6900)
6120 IF POS(A0$=K$)<>1 THEN GOTO 6900
6130 READ (SYM11_DEV)IOL=SYM11A
6140 IF FNP$(W1$)="" THEN GOTO 6500
6150 IF A2$(9,1)<>"T" THEN IF FNP$(W3$)=PROGRAM$ THEN GOTO 6500
6160 IF W2$(2,1)<>" " THEN IF SECURITY$<W2$(2,1) THEN GOTO 6500
6170 LET OPTION=OPTION+1
6180 LET OPTLIST$[1,OPTION,1]=BLANK$+FNP$(W1$),OPTLIST$[1,OPTION,2]=FNP$(W3$)
6190 IF FNP$(W4$)<>"" THEN LET OPTLIST$[1,OPTION,3]=FNU$(FNP$(W4$))
6200 LET OPTLIST$[1,OPTION,4]=W2$(1,1),OPTLIST$[1,OPTION,5]=W2$(2,1)
6210 LET OPTLIST$[1,OPTION,6]=FNP$(W2$(3,6))
6500 REM " --- Loop back for next option"
6510 IF OPTION<MAXLINES THEN GOTO 6100
6900 REM " --- All done"
6990 RETURN
8000 REM " --- Functions"
8080 DEF FNP$(Q$)=CVS(Q$,2)
8085 DEF FNU$(Q$)=CVS(Q$,4)
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
