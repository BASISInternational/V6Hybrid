0010 REM "WOE - Shop Floor Dispatch Report"
0020 REM "Program WOR.PB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLists
0210 ARM01A: IOLIST C0$,C1$(1)
0220 BMM08A: IOLIST D0$(1),D[ALL]
0230 WOE01A: IOLIST A0$(1),A1$(1),A[ALL]
0240 WOE02A: IOLIST B0$(1),B1$(1),B[ALL]
0250 WOM02A: IOLIST D0$(1),D[ALL]
0260 WOM05A: IOLIST L0$,L1$,L2$,L[ALL]
0270 WOT01A: IOLIST W0$(1),W1$(1),W[ALL]
0500 REM " --- Initializations
0510 LET HEADINGS=5
0520 DIM HEADINGS$[HEADINGS]
0530 LET HEADINGS$[0]=N1$,HEADINGS$[1]=N4$,HEADINGS$[2]=H0$
0540 LET HEADINGS$[3]=H1$,HEADINGS$[4]=H2$
0550 LET H0=132,WHEN$=F0$(7,3),CLOCK$=""
0600 REM " --- Open Printer
0610 CALL "SYC.GA",7,1,"","",STATUS
0620 IF STATUS THEN GOTO 9900
0700 REM " --- Calculate Actual Transactions "
0710 GOSUB 3200
0720 CALL "SYC.NB","Printing:   ",12,COLUMN
0900 REM " --- Position WOM-05 detail file
0910 DIM SCHED[DAYS],A0$(75),A1$(141),A[11]
0920 LET TOTSET=0,TOTRUN=0,WTOTSET=0,WTOTRUN=0
0980 LET PREFIX$=N0$+OP_CODE$
0990 READ (WOM05_DEV,KEY=PREFIX$,DOM=1000)
1000 REM " --- Read next WOM-05 detail record
1010 LET K$=KEY(WOM05_DEV,END=4000)
1020 IF POS(PREFIX$=K$)<>1 THEN GOTO 4000
1030 READ (WOM05_DEV)IOL=WOM05A
1060 LET THISSEQ$=K$(16,3)
1080 PRINT @(COLUMN,11),K$(3,3)," ",FNB$(K$(6,3)),
1100 REM " --- Retrieve WOE-02 operations record
1110 DIM B0$(15),B1$(151),B[13],C1$(30)
1200 REM " --- Work order still open?
1220 LET A0$(1)=K$(1,2)+"  "+K$(9,7),MOVE=0
1230 FIND (WOE01_DEV,KEY=A0$(1,11),DOM=2900)IOL=WOE01A
1240 IF POS(A0$(15,1)=STATUS$)=0 THEN GOTO 2900
1250 DIM DESC$(20)
1260 LET DESC$(1)=A1$(1,30)
1270 IF A0$(14,1)="I" THEN LET DESC$(1)=A0$(56)+" "+DESC$
1280 LET MOVE=MOVE+L[3]
1290 IF AR$="Y" THEN FIND (ARM01_DEV,KEY=N0$+A0$(34,6),DOM=1300)IOL=ARM01A
1300 REM "--- Shall we print it?
1305 GOSUB 6200
1310 GOSUB 6800
1315 IF BEGDATE$<>"" THEN IF BEGDATE$>K$(6,3) THEN GOTO 2900
1320 IF LASTDATE$<>"" THEN IF LASTDATE$<K$(6,3) THEN GOTO 2900
1325 IF A1$(97,1)>PR_CODE$ THEN GOTO 2900
1330 IF RUNT=0 AND SET=0 AND MOVE=0 THEN GOTO 2900
1340 IF T1$<>K$(6,3) THEN GOSUB 5600
1350 IF T0$<>K$(3,3) THEN GOSUB 6000
1360 GOSUB 5200
1370 LET TOTSET=TOTSET+SET,TOTRUN=TOTRUN+RUNT,WTOTSET=WTOTSET+SET,WTOTRUN=WTOT
1370:RUN+RUNT
2900 REM " --- Loop back for next record
2990 GOTO 1000
3200 REM " --- Calculate Actual Run & Setup Time From Transactions "
3210 DIM W0$(18),W1$(30),W[11],K3$(21),KT$(18)
3220 LET WOSTR$=""
3230 READ (WOE03_DEV,KEY=N0$+"D  "+OP_CODE$,DOM=3240)
3240 CALL "SYC.NB","Calculating:",12,COLUMN
3250 LET K3$=KEY(WOE03_DEV,END=3380)
3260 IF K3$(3,1)<>"D" THEN GOTO 3380
3270 IF K3$(6,LEN(OP_CODE$))<>OP_CODE$ THEN GOTO 3380
3280 READ (WOE03_DEV)
3290 READ (WOT01_DEV,KEY=N0$+K3$(4,2)+K3$(12,7),DOM=3300)
3300 LET KT$=KEY(WOT01_DEV,END=3400)
3310 PRINT @(COLUMN,11),KT$(5,7)+" "+KT$(16,3)
3320 IF KT$(5,7)<>K3$(12,7) THEN GOTO 3400
3330 READ (WOT01_DEV)IOL=WOT01A
3340 IF W0$(15,1)<>"O" THEN GOTO 3300
3350 IF W1$(4,LEN(OP_CODE$))<>OP_CODE$ THEN GOTO 3300
3360 LET UNITS=UNITS+W[0],SET=SET+W[6]
3370 GOTO 3300
3380 RETURN
3400 REM " --- Done With This Work Order "
3410 IF UNITS=0 AND SET=0 THEN GOTO 3250
3420 LET WOSTR$=WOSTR$+K3$(12,7)+STR(UNITS:UMASK$)+STR(SET:UMASK$)
3430 LET UNITS=0,SET=0
3440 GOTO 3250
4000 REM " --- End Of File
4010 LET T9$="E"
4020 IF LEN(K$)<>0 THEN GOTO 4050
4030 GOSUB 5000
4040 GOTO 4090
4050 GOSUB 6000
4090 GOTO 9900
5000 REM " --- Heading
5005 LET L=HEADINGS+1
5010 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,H,H0,WHEN$,CLOCK$,STATUS
5020 IF STATUS>0 THEN EXITTO 9900
5030 PRINT (7)@(2),"Date",@(8),"Pri",@(12),"WO",@(15),"WO",@(18),"W.O.",@(26),
5030:"Description",@(47),"At",@(51),"Frm",@(57),"Sched",@(64),"Customer",@(124
5030:-M3*2-6),"Setup",@(124-M3-4),"Run",@(119),"Move",@(124),"Critical"
5040 PRINT (7)@(2),"Req'd",@(8),"Cod",@(12),"St",@(15),"Tp",@(18),"Number",@(4
5040:7),"Opn Opn",@(55),"Complete",@(124-M3*2-5),"Time",@(124-M3-5),"Time",@(1
5040:19),"Time",@(125),"Ratio"
5050 PRINT (7)""
5080 LET L=L+3
5090 RETURN
5200 REM "--- Detail display
5210 IF L+1>L9 THEN GOSUB 5000
5220 IF L0=0 THEN GOSUB 5400
5225 GOSUB 6700
5230 PRINT (7)@(0),FNB$(K$(6,3)),@(9),A1$(97,1),@(12),A0$(15,1),@(15),A0$(12,2
5230:),@(18),A0$(5,7),@(26),DESC$,@(47),AT$,@(51),FROM$,@(55),FNB$(A0$(22,3)),
5230:@(64),C1$(1,30),@(124-M3*3),SET:M3$,RUNT:M3$,MOVE:M3$,@(125),CRITR:M2$,
5240 IF NOT_FOUND$="Y" THEN PRINT (7)"*" ELSE PRINT (7)""
5250 LET L=L+1,L0=L0+1,L1=L1+1
5290 RETURN
5400 REM " --- Sub Heading
5410 IF L+2>L9 THEN GOSUB 5000
5420 DIM D0$(90)
5430 IF BM$="Y" THEN FIND (BMM08_DEV,KEY=N0$+K$(3,3),DOM=5440)IOL=BMM08A
5440 IF BM$<>"Y" THEN FIND (WOM02_DEV,KEY=N0$+K$(3,3),DOM=5450)IOL=WOM02A
5450 PRINT (7)@(0),"Operation Code: ",K$(3,3)," ",D0$(6,20)
5460 PRINT (7)""
5470 LET L=L+2
5490 RETURN
5600 REM " --- Week Ending Subtotals
5610 IF T1$="" OR L1=0 THEN GOTO 5720
5615 LET DUMMY$="",SDATE$=""
5620 CALL "SYC.CB",T1$,DUMMY$,DOW
5630 IF DOW=0 THEN GOTO 5720
5640 CALL "SYC.CA",T1$,SDATE$,7-DOW
5650 IF T9$<>"E" THEN IF K$(6,3)<=SDATE$ AND T0$=K$(3,3) THEN GOTO 5720
5660 IF L+3>L9 THEN GOSUB 5000
5670 PRINT (7)@(124-M3*3),DASHES$(1,M3*2)
5680 PRINT (7)@(40),"Totals For Week Ending: ",FNB$(SDATE$),@(124-M3*3),WTOTSE
5680:T:M3$,WTOTRUN:M3$
5690 PRINT (7)""
5700 LET L=L+3
5710 LET WTOTSET=0,WTOTRUN=0
5720 LET T1$=K$(6,3)
5730 LET L1=0
5790 RETURN
6000 REM " --- Totals
6005 GOSUB 5600
6010 IF T0$="" OR L0=0 THEN GOTO 6070
6020 IF L+3>L9 THEN GOSUB 5000
6030 PRINT (7)@(124-M3*3),DASHES$(1,M3*2)
6040 PRINT (7)@(124-M3*3),@(40),"Total For Op Code ",T0$,@(124-M3*3),TOTSET:M3
6040:$,TOTRUN:M3$
6050 PRINT (7)""
6060 IF T9$<>"E" THEN GOSUB 5000
6070 LET TOTSET=0,TOTRUN=0,L0=0
6080 LET T0$=K$(3,3)
6090 RETURN
6200 REM " --- Initialize WO 
6210 DIM RUNTIM[OPNMAX],SETUP[OPNMAX],ACTRUN[OPNMAX],ACTSET[OPNMAX],B0$(15),B1
6210:$(152),B[13],OPS$[OPNMAX,1]
6220 LET OPIND$="",X0=0,NOW=0,AT$="",FROM$="",SET=0,RUNT=0,NOT_FOUND$=""
6230 READ (WOE02_DEV,KEY=A0$(1,11),DOM=6240)
6240 LET WOEKEY$=KEY(WOE02_DEV,END=6400)
6250 IF POS(A0$(1,11)=WOEKEY$)<>1 THEN GOTO 6400
6260 READ (WOE02_DEV)IOL=WOE02A
6270 IF B1$(91,1)<>"S" THEN GOTO 6240
6280 LET OPIND$=OPIND$+B0$(13,3),OPS$[X0,0]=B1$(1,3),OPS$[X0,1]=B1$(4,3),RUNTI
6280:M[X0]=L[2],SETUP[X0]=L[1]
6290 LET X0=X0+1
6300 GOTO 6240
6400 REM " --- Calculate Actual
6405 DIM W0$(18),W1$(40),W[11]
6410 READ (WOT01_DEV,KEY=A0$(1,11),DOM=6420)
6420 LET WOTKEY$=KEY(WOT01_DEV,END=6600)
6430 IF POS(A0$(1,11)=WOTKEY$)<>1 THEN GOTO 6600
6440 READ (WOT01_DEV)IOL=WOT01A
6460 LET SEQ$=W1$(1,3),COD$=W1$(4,3)
6470 LET INDX=POS(SEQ$=OPIND$,3)
6480 IF INDX<>0 THEN GOTO 6530
6490 LET OPIND$=OPIND$+SEQ$,OPS$[X0,0]=COD$,X0=X0+1
6500 GOTO 6470
6530 LET INDX=INT(INDX/3),ACTSET[INDX]=ACTSET[INDX]+W[6],ACTRUN[INDX]=ACTRUN[I
6530:NDX]+W[0]
6540 IF NOW<INDX THEN LET NOW=INDX
6550 GOTO 6420
6600 REM "---- This operation? 
6605 IF ACTSET[NOW]+ACTRUN[NOW]>SETUP[NOW]+RUNTIM[NOW] THEN LET NOW=NOW+1
6610 LET AT$=OPS$[NOW,0]
6620 LET THISINDX=POS(THISSEQ$=OPIND$,3)
6630 IF THISINDX=0 THEN GOTO 6690
6640 LET THISINDX=INT(THISINDX/3),XFROM=THISINDX-1; IF XFROM<0 THEN LET XFROM=
6640:0
6650 LET FROM$=OPS$[XFROM,0]
6660 LET RUNT=RUNTIM[THISINDX],SET=SETUP[THISINDX]
6690 RETURN
6700 REM " --- Calculate Critical Ratio
6705 LET REQSAV$="",REMSAV=0
6710 LET X=NOW*3+1
6715 LET IND=INT(X/3)
6720 LET REQD$=K$(6,3)
6725 IF REQSAV$<>REQD$ THEN GOTO 6740
6730 LET REMAIN=REMSAV
6735 GOTO 6770
6740 LET REQSAV$=REQD$
6745 CALL "WOC.BA",SCHEDATE$,REQD$,REMAIN,K$(3,3),FLAG$
6750 IF FLAG$<>"Y" THEN GOTO 6765
6755 CALL "SYC.CA",SCHEDATE$,REQD$,REMAIN
6760 LET REMAIN=REMAIN*8,NOT_FOUND$="Y"
6765 LET REMSAV=REMAIN
6770 IF RUNT+SET=0 THEN GOTO 6790
6776 LET CRITR=REMAIN/(RUNT+SET)
6780 IF CRITR>999.9 THEN LET CRITR=999.9
6785 IF CRITR<-999.9 THEN LET CRITR=-999.9
6790 RETURN
6800 REM " --- Calculate Remaining Units "
6815 LET UNITRUN=0,UNITSET=0
6820 LET WOPOS=POS(A0$(5,7)=WOSTR$)
6825 IF WOPOS=0 THEN GOTO 6895
6830 LET UNITRUN=NUM(WOSTR$(WOPOS+7,UMASK))
6835 LET UNITSET=NUM(WOSTR$(WOPOS+7+UMASK,UMASK))
6840 LET RUNT=RUNT-UNITRUN,SET=SET-UNITSET
6845 IF RUNT<0 THEN GOTO 6860
6850 LET WOSTR$(WOPOS+7,UMASK)=STR(0:UMASK$)
6855 GOTO 6870
6860 LET UNITRUN=-RUNT,WOSTR$(WOPOS+7,UMASK)=STR(UNITRUN:UMASK$)
6865 LET RUNT=0
6870 IF SET<0 THEN GOTO 6885
6875 LET WOSTR$(WOPOS+7+UMASK,UMASK)=STR(0:UMASK$)
6880 GOTO 6895
6885 LET UNITSET=-UNITSET,WOSTR$(WOPOS+7+UMASK,UMASK)=STR(UNITSET:UMASK$)
6890 LET SET=0
6895 RETURN
8000 REM " --- Functions
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
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
9800 REM " --- Display Parameter record error"
9810 LET LINE_ERR$=LST(PGM(TCB(5)))
9820 CALL "SYC.YA",LINE_ERR$,N2$,ERR
9900 RUN "SYS.AA"
9999 END
