0010 REM "SYC - Print Screen Image"
0020 REM "Program SYC.SP"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0080 SETERR 9000
0085 SETESC 9000
0100 REM " --- Open/Lock Files"
0110 LET FILES=1
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0130 LET FILES$[1]="SYS-01",MESSAGE=0,PFNAME$="",RESERVED$="",NAME$=""
0150 CALL "SYC.DA",1,1,FILES,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STA
0150:TUS
0160 IF STATUS>0 THEN GOTO 9900
0170 LET SYS01_DEV=CHANNELS[1],PRINTER=UNT
0180 CALL "SYC.GA",PRINTER,MESSAGE,PFNAME$,RESERVED$,STATUS
0190 IF STATUS>0 THEN GOTO 9900
0200 REM " --- IOLIST's"
0270 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0400 REM " --- Parameters"
0410 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9900)IOL=SYS01T
0420 LET F4$=FNP$(F4$),F5$=FNP$(F5$)
0450 LET X$=STBL("!STERMS",ERR=9900),X$=STBL("!TERMS",X$,ERR=9900)
0460 LET X$=STBL("!SEDIT",ERR=9900),X$=STBL("!EDIT",X$,ERR=9900)
0500 REM " --- Initializations"
0510 DIM IMAGE$[25](80),HEADINGS$[2],MESSAGE$[1]
0550 LET HEADINGS$[0]=FNP$(F4$),HEADINGS$[1]=FNP$(F5$)
0560 LET CLOCK$="",WHEN$=F0$(7,3),H=0,H0=80
1000 REM " --- Retrieve screen"
1005 PRINT (0,ERR=9900)'FL',"1",
1010 PRINT (0,ERR=9900)'EE'+'CI'+'WINDOW'("LIST"),
1020 READ RECORD(0,SIZ=1)COUNT$
1030 READ RECORD(0,SIZ=ASC(COUNT$),ERR=9900)LIST$
1040 PRINT (0,ERR=9900)'BE',
1050 LET NAME$=LIST$(1,1)
2000 REM " --- Cycle through windows"
2010 FOR WINDOW=LEN(LIST$) TO 1 STEP -1
2020 PRINT (0,ERR=2900)'GOTO'(ASC(LIST$(WINDOW))),
2030 DIM U[1],C[1],ATTR$:"bcolor:U(1),fcolor:U(1),attribs:U(1),ccodes:C(1)"
2100 REM " --- Determine window position"
2110 PRINT @(0,0),
2120 LET X$=FIN(0,ERR=2900),COLUMN=DEC(X$(1,1)),ROW=DEC(X$(2,1))
2130 LET WIDTH=DEC(X$(7,1)),HEIGHT=DEC(X$(8,1))
2150 INPUT (0,ERR=2900)@(0,0),'EE','GS','RP',W$,'GE','BE'
2160 GOSUB 6000
2400 REM " --- Outline true windows"
2410 LET BAR$=""
2420 IF ASC(LIST$(WINDOW))=0 OR WIDTH>78 THEN GOTO 2500
2430 LET BAR$="|"
2440 LET IMAGE$[ROW](COLUMN,WIDTH+2)="+"+FILL(WIDTH,"-")+"+"
2500 REM " --- Store window"
2510 LET OFFSET=LEN(BAR$)
2530 FOR X=1 TO LEN(X$) STEP WIDTH
2540 LET IMAGE$[ROW+1](COLUMN+1-OFFSET,WIDTH+(OFFSET*2))=BAR$+X$(X,WIDTH)+BAR$
2540:,ROW=ROW+1
2550 NEXT X
2590 IF ASC(LIST$(WINDOW))>0 AND WIDTH<79 THEN LET IMAGE$[ROW+1](COLUMN,WIDTH+
2590:2)="+"+FILL(WIDTH,"-")+"+"
2900 REM " --- Next window"
2990 NEXT WINDOW
3000 REM " --- Notify user and print heading"
3010 LET UNAME$="",V4$="Printing Screen..."
3020 CALL "SYC.WA",0,40,3,20,10,"",UNAME$
3030 PRINT @(1,0),V4$,
3090 GOSUB 5000
3500 REM " --- Print screen"
3510 FOR ROW=1 TO 24
3520 LET LINE$=IMAGE$[ROW]
3540 PRINT (PRINTER)LINE$
3590 NEXT ROW
4000 REM " --- All done"
4010 CALL "SYC.WD",UNAME$
4020 LET MESSAGE$[0]="Screen Printed (<Enter>=Continue)"
4030 CALL "SYC.XA",0,MESSAGE$[ALL],0,-1,-1,V$,V3
4090 GOTO 9900
5000 REM " --- Report heading"
5010 CALL "SYC.HA",PRINTER,HEADINGS$[ALL],2,H,H0,WHEN$,CLOCK$,STATUS
5090 RETURN
6000 REM " --- Convert graphics characters"
6010 LET X$=""
6020 FOR X=1 TO LEN(W$) STEP 4
6030 LET ATTR$=W$(1,4),W$=W$(5),G$=ATTR$(3,1),C$=ATTR$(4,1)
6040 IF G$<>$A0$ THEN GOTO 6080
6045 IF POS(C$=$32333435$)>0 THEN LET C$="+"
6050 IF C$=$30$ THEN LET C$="-"
6055 IF C$=$31$ THEN LET C$="|"
6080 LET X$=X$+C$
6085 NEXT X
6090 RETURN
8000 REM " --- Function Definitions"
8025 DEF FNC(Q$,Q)=INT((Q-LEN(Q$))/2)
8050 DEF FNE$(Q$)=STR(INT(TIM):"00")+":"+STR(FPT(TIM)*60:"00")
8090 DEF FNP$(Q$)=CVS(Q$,2)
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
9910 CLOSE (SYS01_DEV,ERR=9920)
9920 CLOSE (PRINTER,ERR=9930)
9925 IF UNAME$<>"" THEN CALL "SYC.WD",UNAME$
9930 IF NAME$<>"" THEN CALL "SYC.WB",NAME$,0
9940 PRINT (0,ERR=9945)'BE','RS','CI',
9945 CALL "SYC.FK",STATUS
9950 EXIT
9999 END
