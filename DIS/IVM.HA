0010 REM "IVM - Description Masterfile Maintenance"
0020 REM "Program IVM.HA
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0060 BEGIN
0080 SETERR 9000
0090 SETESC 9000
0100 REM " --- Open/Lock Files"
0110 LET FILES=4
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0130 LET FILES$[1]="SYS-01",FILES$[2]="IVM-11"
0135 LET FILES$[3]="IVM-21",FILES$[4]="IVM-31"
0140 CALL "SYC.DA",1,1,1,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0150 IF STATUS>0 THEN GOTO 9900
0160 LET SYS01_DEV=CHANNELS[1]
0200 REM " --- IOLIST's"
0210 IVM11A: IOLIST A0$(1),A1$(1)
0260 IVS01A: IOLIST X$,P1$,P2$,P3$,P4$,M0$,M1$,M2$,M3$
0270 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0400 REM " --- Parameters"
0405 DIM P[3],TITLE$[3],OPTLIST$[2,20,6],MORE$[2,20,1]
0410 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9800)IOL=SYS01T
0415 LET N0$=F0$(16,2),N1$=F4$,N2$="IV",N4$=F5$,NUMBER=0,OPTION=0,WIDTH=0
0420 FIND (SYS01_DEV,KEY=N0$+N2$+"00",DOM=9800)IOL=IVS01A
0425 FOR X=51 TO 53
0430 IF P2$(X,1)<>"Y" THEN GOTO 0480
0435 LET NUMBER=X-50,DESCRIPTION$=FNP$(P2$(15+((NUMBER-1)*12),12))
0440 LET P[NUMBER]=NUM(P2$(9+((NUMBER-1)*2),2)),OPTION=OPTION+1
0450 LET OPTLIST$[1,OPTION,1]=" "+DESCRIPTION$,OPTLIST$[1,OPTION,2]=STR(NUMBER
0450:)
0460 LET WIDTH=MAX(WIDTH,LEN(DESCRIPTION$))
0480 NEXT X
0490 IF NUMBER=0 THEN GOTO 6900
0500 REM " --- Initializations"
0510 DIM A0$(22),A1$(30)
0550 LET WIN_X=0,WIN_Y=4,TITLE$="Options"
0700 REM " --- Background"
0710 PRINT @(3,5),'SB',"Description:",'SF',
0800 REM " --- Options"
0810 GOSUB 5500
0820 IF V3=4 THEN GOTO 9900
0830 IF OPTION$="END" THEN GOTO 9900
0840 PRINT @(14-LEN(DESCRIPTION$),4),'SB',DESCRIPTION$,":",'SF',
0850 LET X1=SELECTION+1,X2=X1
0900 REM " --- Open appropriate file"
0910 CLOSE (IVM11_DEV,ERR=0920)
0920 CALL "SYC.DA",1,X1,X2,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATU
0920:S
0930 IF STATUS>0 THEN GOTO 9900
0940 LET IVM11_DEV=CHANNELS[X1]
0950 REM " --- Position file"
0960 DIM A0$(22)
0980 LET A0$(1)=N0$
0990 READ (IVM11_DEV,KEY=A0$,DOM=1000)IOL=IVM11A
1000 REM " --- Key"
1010 PRINT 'CF'
1020 LET V2$="",V2$=KEY(IVM11_DEV,END=1050)
1030 IF V2$(1,2)<>A0$(1,2) THEN LET V2$=""
1040 IF V2$<>"" THEN LET V2$=V2$(3)
1050 LET V0$="S",V1$="E",V0=P[SELECTION],V1=16,V2=4
1055 LET V4$="Enter a Valid "+DESCRIPTION$+" (<F3>=Lookup)"
1060 GOSUB 7000
1065 IF V3=3 THEN GOSUB 6000
1070 IF V3=4 THEN GOTO 4500
1080 IF V$="" THEN GOTO 0900
1090 LET A0$(3)=V$
1200 REM " --- Retrieve record"
1210 READ (IVM11_DEV,KEY=A0$,DOM=1400)IOL=IVM11A
1300 REM " --- Display record"
1310 GOSUB 5000
1390 GOTO 4000
1400 REM " --- New record?"
1410 CALL "SYC.YN",1,"Is This A New Record",1,V$,V3
1440 ON V3 GOTO 1460,1400,1400,1400,4500
1490 ON POS(V$="YN") GOTO 1400,1500,1000
1500 REM " --- Initialize new record"
1510 DIM A1$(30)
2000 REM " --- Description"
2020 LET V0$="S",V1$="",V2$=A1$(1,30),V3$="",V0=30,V1=16,V2=5,I0=0
2040 GOSUB 7000
2050 ON V3 GOTO 2060,2000,3900,2000,3900
2060 LET A1$(1,30)=V$
2090 GOTO 3900
3900 REM " --- Next Field"
3905 IF V3=4 THEN GOTO 4000
3910 IF V3<>2 THEN GOTO 3940
3920 IF I0>0 THEN LET I0=I0-1
3930 GOTO 3950
3940 LET I0=I0+1
3960 ON I0 GOTO 2000,3990
4000 REM " --- Correct?"
4010 LET V4$="Is The Above Information Correct (Y/N/Delete)?"
4020 LET V0$="S",V1$="CER",V2$="Y",V3$="",V0=6,V2=22,V1=FNV(V4$)
4030 GOSUB 7000
4040 ON V3 GOTO 4050,4000,4000,4000,4500
4060 IF V$="DELETE" THEN GOTO 4200
4090 ON POS(V$="YN") GOTO 4000,4100,1600
4100 REM " --- Write record"
4110 WRITE (IVM11_DEV,KEY=A0$)IOL=IVM11A
4190 GOTO 1000
4200 REM " --- Remove record"
4210 REMOVE (IVM11_DEV,KEY=A0$,DOM=4230)
4290 GOTO 1000
4500 REM " --- Print?"
4510 CALL "SYC.YN",1,"Print A List Of All Records",1,V$,V3
4540 ON V3 GOTO 4550,4500,4500,4500,9900
4590 ON POS(V$="YN") GOTO 4500,4900,9900
4900 REM " --- Report Initializations"
4905 LET PROGRAM$="",TOTAL$="Inventory Description Masterfile"
4910 LET CHANNEL=IVM11_DEV,NUMBER=1,RECORD$="",HEADINGS=3,WIDTH=80
4915 DIM FIELD$[NUMBER],FIELD[NUMBER],POSITION[NUMBER]
4920 DIM LENGTH[NUMBER],TYPE$[NUMBER],MASK$[NUMBER]
4925 DIM HEADINGS$[HEADINGS]
4930 LET FIELD$[0]=DESCRIPTION$,FIELD[0]=1,POSITION[0]=3
4940 LET LENGTH[0]=P[SELECTION],TYPE$[0]="S",MASK$[0]=""
4945 LET FIELD$[1]="Description",FIELD[1]=2,POSITION[1]=1
4950 LET LENGTH[1]=30,TYPE$[1]="S",MASK$[1]=""
4980 LET HEADINGS$[0]=N1$,HEADINGS$[1]=TOTAL$+" Listing"
4990 RUN "SYR.AA"
5000 REM " --- Display"
5010 PRINT @(16,4),A0$(3,P[SELECTION]),@(16,5),A1$,
5090 RETURN
5500 REM " --- Submenu processing - Calculate window dimensions and location"
5505 LET SELECTION=NUM(OPTLIST$[1,1,2])
5510 IF OPTION<2 THEN GOTO 5990
5520 IF LEN(TITLE$)+4>WIDTH THEN LET WIDTH=LEN(TITLE$)+4
5530 LET HEIGHT=OPTION+2,WIDTH=WIDTH+4
5540 IF WIN_Y+HEIGHT>22 THEN LET WIN_Y=24-HEIGHT
5550 IF WIN_X=0 THEN LET WIN_X=INT((80-WIDTH)/2)
5560 IF WIN_X+WIDTH>79 THEN LET WIN_X=79-WIDTH
5590 CALL "SYC.WA",0,WIDTH,HEIGHT,WIN_X,WIN_Y,TITLE$,NAME$
5800 REM " --- Lightbar selection of menu option"
5810 LET MAX_ROW=HEIGHT-1,PAGE=1,XMODE=0,SELECTION$="",SELECTION=0
5820 CALL "SYC.SA",XMODE,OPTLIST$[ALL],MORE$[ALL],OPTION$,PAGE,MAX_ROW,NAME$,H
5820:EIGHT,WIDTH,FKEY
5830 IF FKEY=4 THEN GOTO 5990
5840 IF OPTION$="END" THEN GOTO 5990
5850 IF OPTION$="PRIOR" THEN GOTO 5800
5900 REM " --- Which option?"
5910 FOR X=1 TO OPTION
5920 IF OPTION$<>OPTLIST$[1,X,2] THEN GOTO 5950
5940 LET SELECTION=NUM(OPTION$),DESCRIPTION$=FNP$(FNS$(OPTLIST$[1,X,1]))
5950 NEXT X
5980 CALL "SYC.WD",NAME$
5990 RETURN
6000 REM " --- System Lookup"
6010 LET RECORD$="",NUMBER=1,TITLE$="Description Lookup"
6020 DIM DESCRIPTION$[NUMBER],FIELD[NUMBER],POSITION[NUMBER],LENGTH[NUMBER]
6030 LET DESCRIPTION$[0]=DESCRIPTION$,DESCRIPTION$[1]="Description"
6040 LET FIELD[0]=1,POSITION[0]=3,LENGTH[0]=P[SELECTION]
6050 LET FIELD[1]=2,POSITION[1]=1,LENGTH[1]=30
6060 LET ROW=3,COLUMN=79-LENGTH[0]-LENGTH[1]-NUMBER*4,V$=""
6070 CALL "SYC.LK",IVM11_DEV,RECORD$,NUMBER,TITLE$,DESCRIPTION$[ALL],FIELD[ALL
6070:],POSITION[ALL],LENGTH[ALL],COLUMN,ROW,V$
6090 RETURN
6900 REM " --- Standard Warning/Error"
6910 DIM MESSAGE$[1]
6920 LET MESSAGE$[0]="Description Masterfile Usage Is Not Enabled On The"
6930 LET MESSAGE$[1]="Inventory Parameter Record (<Enter>=Continue)"
6940 CALL "SYC.XA",1,MESSAGE$[ALL],1,22,-1,V$,V3
6990 GOTO 9900
7000 REM " --- Standard Input Routine (15May95)"
7010 CALL "SYC.IA",V0$,V1$,V2$,V3$,V4$,PGM(-2),V0,V1,V2,V$,V,V3,DISPLAY_LEN
7020 IF V3=999 THEN GOTO 7200
7030 IF V3=127 THEN GOTO 7100
7090 RETURN
7100 REM " --- Escape During Input"
7110 CALL "SYC.ES",ERR=7200,PGM(-2),TCB(8),E$,E2,V3
7120 IF V3<>127 THEN GOTO 7000
7130 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
7200 REM " --- Error During Input"
7210 ESCAPE
7290 GOTO 7000
8000 REM " --- Functions"
8080 DEF FNV(Q$)=42+INT(LEN(Q$)/2)
8085 DEF FNP$(Q$)=CVS(Q$,2)
8090 DEF FNS$(Q$)=CVS(Q$,1)
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
9800 REM " --- Display Parameter record error"
9810 LET LINE_ERR$=LST(PGM(TCB(5)))
9820 CALL "SYC.YA",LINE_ERR$,N2$,ERR
9900 REM " --- Return to menu"
9950 RUN "SYS.AA"
9999 END
