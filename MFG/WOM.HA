0010 REM "WOM - Load Balance By Operation Inquiry"
0020 REM "Program WOM.HA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0060 BEGIN
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files"
0110 LET FILES=5
0115 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0120 LET FILES$[1]="WOE-01",FILES$[2]="WOM-05",FILES$[3]="WOM-04"
0125 LET FILES$[4]="SYS-01",FILES$[5]=""
0150 CALL "SYC.DA",1,1,4,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0155 IF STATUS THEN GOTO 9900
0160 LET WOE01_DEV=CHANNELS[1],WOM05_DEV=CHANNELS[2],WOM04_DEV=CHANNELS[3]
0165 LET SYS01_DEV=CHANNELS[4]
0200 REM " --- IOLIST's"
0210 WOE01A: IOLIST A0$(1),A1$(1),A[ALL]
0220 WOM05A: IOLIST B0$,B1$,B2$,B[ALL]
0240 WOM04A: IOLIST C0$(1),C1$,C2$,C[ALL]
0250 OPCODEA: IOLIST D0$(1),D[ALL]
0260 WOS01A: IOLIST X$,P1$,P2$,P3$,P4$,M0$,M1$,M2$,M3$
0265 IVS01A: IOLIST P0$,P1$,P2$,P3$,P4$,M0$,M1$,M2$,M3$
0270 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0400 REM " --- Parameters"
0405 DIM P[5],INFO$[20]
0410 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9800)IOL=SYS01T
0420 LET N0$=F0$(16,2),N1$=F4$,N2$="WO",N4$=F5$,BM$="N"
0430 FIND (SYS01_DEV,KEY=N0$+N2$+"00",DOM=9800)IOL=WOS01A
0440 LET BM$=P3$(1,1)
0450 FIND (SYS01_DEV,KEY=N0$+"IV00",DOM=9800)IOL=IVS01A
0455 LET P[0]=NUM(P2$(1,2)),P[1]=NUM(P2$(7,2)),P[2]=NUM(P2$(5,1))
0460 LET P[3]=NUM(P2$(9,2)),P[4]=NUM(P2$(11,2)),P[5]=NUM(P2$(13,2))
0485 IF BM$<>"Y" THEN GOTO 0500
0490 CALL "SYC.VA","BM",INFO$[ALL]
0495 LET BM$=INFO$[20]
0500 REM " --- Initializations"
0510 DIM A0$(56+P[0]),A1$(138),A[11],B[9],J1$(80)
0520 DIM C0$(9),C[31],D0$(90),D[13],MONTHS$[12],M[12]
0530 LET BEGDATE$=F0$(7,3),LASTDATE$="",OPERATION$="",L0=5,DAYS=24
0540 LET M2=LEN(M2$),M3=LEN(M3$),MINMASK=MAX(M2,M3),WIDTH=3,MARGIN=8
0545 CALL "SYC.RM",M2$,M2,MINMASK,15
0550 CALL "SYC.RM",M3$,M3,MINMASK,15
0555 LET AMTCOL=80-MINMASK,MONTHS$[1]="January",MONTHS$[2]="February"
0560 LET MONTHS$[3]="March",MONTHS$[4]="April",MONTHS$[5]="May"
0565 LET MONTHS$[6]="June",MONTHS$[7]="July",MONTHS$[8]="August"
0570 LET MONTHS$[9]="September",MONTHS$[10]="October"
0575 LET MONTHS$[11]="November",MONTHS$[12]="December"
0580 LET M[1]=31,M[2]=28,M[3]=31,M[4]=30,M[5]=31,M[6]=30
0585 LET M[7]=31,M[8]=31,M[9]=30,M[10]=31,M[11]=30,M[12]=31
0590 LET LINES=19-L0,H1$="  Hours",A$="A",S$="S",AX$=".",SX$="."
0600 REM " --- Build footing"
0610 DIM FOOTING$(WIDTH*DAYS),M4$(LEN(H1$),"#")
0615 LET P=1,M4$(LEN(M4$)-3)="0.00"
0620 FOR X=1 TO DAYS
0630 LET FOOTING$(P)=A$+S$,P=P+WIDTH
0640 NEXT X
0650 REM " --- Additional File Opens"
0660 IF BM$<>"Y" THEN LET FILES$[5]="WOM-02"
0670 IF BM$="Y" THEN LET FILES$[5]="BMM-08"
0680 CALL "SYC.DA",1,5,5,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0685 IF STATUS THEN GOTO 9900
0690 LET OPCODE_DEV=CHANNELS[5]
0700 REM " --- Background"
0750 PRINT 'SB',@(3,3),"W.O. Status:",@(39),"Date:",@(AMTCOL-11),"Queue Time",
0750:@(0,4),"Operation Code:",@(AMTCOL-16),"Pieces Per Hour",'SF',
0800 REM " --- W.O. Status"
0802 PRINT @(0,0),'CF',
0805 LET V0$="S",V1$="CK^",V2$=STATUS$,V3$="",V4$="O=Open, P=Planned, Q=Quote,
0805: Or Any Combination, <F1>=All",V0=3,V1=16,V2=3,DESC$=""
0810 GOSUB 7000
0815 ON V3 GOTO 0820,0817,0800,0820,9900
0817 LET V$=""
0820 IF V$="" THEN LET V$="OPQ"
0825 FOR X=1 TO LEN(V$); IF POS(V$(X,1)="OPQ")=0 THEN EXITTO 0800
0830 NEXT X
0835 IF POS("O"=V$)>0 THEN LET DESC$="Open/"
0837 IF POS("P"=V$)>0 THEN LET DESC$=DESC$+"Planned/"
0840 IF POS("Q"=V$)>0 THEN LET DESC$=DESC$+"Quote/"
0842 LET DESC$=DESC$(1,LEN(DESC$)-1)+J1$,DESC$=DESC$(1,18)
0845 PRINT @(V1,V2),V$,"   ",@(V1+4,V2),DESC$,
0847 LET STATUS$=V$
0850 REM " --- Beginning Date"
0860 LET V4$="Enter The Beginning Date For The Display"
0865 LET V0$="D",V1$="C",V2$=BEGDATE$,V3$="",V0=3,V1=45,V2=3
0870 GOSUB 7000
0875 ON V3 GOTO 0880,0850,0800,0850,9900
0880 LET BEGDATE$=V$,MMDDYY$=FNB$(BEGDATE$),BEGMM$=MMDDYY$(1,2)
0885 LET BEGDD$=MMDDYY$(4,2),BEGYY$=MMDDYY$(7,2),DD=NUM(BEGDD$)
0890 READ (OPCODE_DEV,KEY=N0$,DOM=0895)
0900 REM " --- Operation Code"
0905 PRINT @(0,L0),'CE',
0910 LET V2$="",V2$=KEY(OPCODE_DEV,END=0925)
0915 IF V2$(1,2)<>N0$ THEN LET V2$=""
0920 IF V2$<>"" THEN LET V2$=V2$(3)
0925 LET V0$="S",V1$="CRK",V3$="",V0=3,V1=16,V2=4
0930 LET V4$="Enter The Operation Code To Display (<F3>=Lookup)"
0935 GOSUB 7000
0940 ON V3 GOTO 0950,0900,0850,0945,9900
0945 GOSUB 6000
0950 REM " --- Correct?"
0955 LET D0$(1)=N0$+V$
0960 READ (OPCODE_DEV,KEY=D0$(1,5),DOM=0900)IOL=OPCODEA
0965 LET OPERATION$=D0$(3,3)
0970 GOSUB 5000
0975 LET V4$="Is The Above Information Correct: "
0985 CALL "SYC.YN",1,V4$,2,V$,V3
0990 ON V3 GOTO 0995,0900,0900,0900,9900
0995 ON POS(V$="YN") GOTO 0800,1000,0800
1000 REM 
1010 IF BEGDATE$=LASTDATE$ THEN GOTO 1900
1020 DIM HEADING$(WIDTH*DAYS),DATES$[DAYS],AVAIL[DAYS]
1030 LET X=DAYS,ENDDATE$="",MONTH2$="",HEADING=0
1040 CALL "SYC.CA",BEGDATE$,ENDDATE$,X
1050 LET MMDDYY$=FNB$(ENDDATE$),ENDMM$=MMDDYY$(1,2),ENDDD$=MMDDYY$(4,2)
1060 LET ENDYY$=MMDDYY$(7,2),YY$=BEGYY$,MM$=BEGMM$
1070 GOSUB 6200
1100 REM " --- Determine horizontal (date) scale"
1110 LET MONTH1$=M$,MONTH1=1,MONTH2=0,LAST=C[0],N=1
1120 IF LAST-DD+1>DAYS THEN LET LAST=DD+DAYS-1
1130 FOR X=DD TO LAST
1140 LET HEADING$(MONTH1)=STR(X:"00"),AVAIL[N]=C[X]
1170 LET MONTH1=MONTH1+WIDTH,N=N+1
1180 NEXT X
1190 LET MONTH1=MONTH1-2
1200 REM " --- Need another month?"
1210 IF BEGMM$=ENDMM$ THEN GOTO 1400
1220 LET YY$=ENDYY$,MM$=ENDMM$
1230 GOSUB 6200
1300 REM 
1310 LET P=MONTH1+2,LAST=DAYS-INT(P/WIDTH)
1315 IF LAST<1 THEN GOTO 1400
1320 LET MONTH2$=M$,MONTH2=1
1330 FOR X=1 TO LAST
1340 LET HEADING$(P)=STR(X:"00"),AVAIL[N]=C[X]
1370 LET MONTH2=MONTH2+WIDTH,P=P+WIDTH,N=N+1
1380 NEXT X
1390 LET MONTH2=MONTH2-2
1400 REM " --- Build list of corresponding dates"
1410 LET DATES$[1]=BEGDATE$,X$="",N=1
1420 FOR X=2 TO DAYS
1430 CALL "SYC.CA",BEGDATE$,X$,N
1440 LET DATES$[X]=X$,X$="",N=N+1
1490 NEXT X
1900 REM " --- Position WOM-05 detail file"
1910 DIM SCHED[DAYS],A0$(56+P[0]),A1$(138),A[11]
1950 CALL "SYC.NB","Processing",20,COLUMN
1980 LET PREFIX$=N0$+D0$(3,3),K$=PREFIX$+BEGDATE$
1990 READ (WOM05_DEV,KEY=K$,DOM=2000)
2000 REM " --- Read next WOM-05 operations record"
2010 LET K$=KEY(WOM05_DEV,END=3000)
2020 IF POS(PREFIX$=K$)<>1 THEN GOTO 3000
2030 IF K$(6,3)>ENDDATE$ THEN GOTO 3000
2040 DIM B[9]
2050 READ (WOM05_DEV)IOL=WOM05A
2060 PRINT @(COLUMN,11),FNB$(K$(6,3))," ",K$(9,7)," ",K$(16,3),
2200 REM " --- Work order still open?"
2210 IF B0$(12,7)=A0$(5,7) THEN GOTO 2240
2220 LET A0$(1)=B0$(1,2)+"  "+B0$(9,7)
2230 FIND (WOE01_DEV,KEY=A0$(1,11),DOM=2900)IOL=WOE01A
2240 IF A0$(15,1)="O" AND POS("O"=STATUS$)>0 THEN GOTO 2300
2250 IF A0$(15,1)="Q" AND POS("Q"=STATUS$)>0 THEN GOTO 2300
2260 IF A0$(15,1)="P" AND POS("P"=STATUS$)>0 THEN GOTO 2300
2290 GOTO 2900
2300 REM " --- Accumulate total standard units"
2310 LET N=0
2320 FOR X=1 TO DAYS
2330 IF K$(6,3)=DATES$[X] THEN LET N=X
2340 NEXT X
2350 IF N>0 THEN LET SCHED[N]=SCHED[N]+B[1]+B[2]
2900 REM " --- Loop back for next record"
2990 GOTO 2000
3000 REM " --- Calculate scale limits"
3010 LET MINVALUE=2^15,MAXVALUE=-MINVALUE
3020 FOR X=1 TO DAYS
3030 LET MINVALUE=MIN(AVAIL[X],MINVALUE),MAXVALUE=MAX(AVAIL[X],MAXVALUE)
3040 LET MINVALUE=MIN(SCHED[X],MINVALUE),MAXVALUE=MAX(SCHED[X],MAXVALUE)
3090 NEXT X
3100 REM 
3110 LET X1=ABS(MAXVALUE-MINVALUE)/14,X2=EPT(X1)
3120 IF X2>0 THEN GOTO 3200
3130 IF X2<1 THEN LET X=X1*10^(ABS(X2)+1)
3140 IF FPT(X)<>0 THEN LET X=INT(X+0.99)
3150 LET STEPVALUE=X/10^ABS(X2+1)
3190 GOTO 3300
3210 IF X2>0 THEN LET X=X1/10^(X2-1)
3220 IF FPT(X)<>0 THEN LET X=INT(X+0.99)
3230 LET STEPVALUE=X*10^(X2-1)
3300 REM 
3310 DIM SCALE[LINES]
3320 IF STEPVALUE=0 THEN LET STEPVALUE=1
3330 FOR X=1 TO LINES
3340 LET SCALE[X]=SCALE[X-1]+STEPVALUE
3350 NEXT X
3700 REM " --- Available hours"
3705 DIM DISPLAY$[LINES](DAYS*WIDTH)
3710 FOR X=1 TO DAYS
3720 LET NUMBER=AVAIL[X],CHAR$=AX$,INDEX=1
3730 GOSUB 6500
3790 NEXT X
3800 REM " --- Scheduled hours"
3810 FOR X=1 TO DAYS
3820 LET NUMBER=SCHED[X],CHAR$=SX$,INDEX=2
3830 GOSUB 6500
3890 NEXT X
3900 REM " --- Display the graph"
3910 GOSUB 5200
3990 GOSUB 5500
4000 REM " --- Continue?"
4010 LET V4$=A$+"=Available Hours/"+S$+"=Scheduled Hours (Z=Zoom/U=UnZoom/<Ent
4010:er>=Continue)"
4020 LET V0$="S",V1$="",V2$="",V3$="",V0=1,V1=FNV(V4$),V2=22
4030 GOSUB 7000
4040 IF V$="Z" THEN GOTO 4100
4050 IF V$="U" THEN GOTO 4200
4090 GOTO 0900
4100 REM " --- Zoom"
4110 LET STEPVALUE=STEPVALUE/2
4190 GOTO 3300
4200 REM " --- UnZoom"
4210 LET X$=STR(SCALE[LINES]*2:M4$,ERR=4000)
4220 LET STEPVALUE=STEPVALUE*2
4290 GOTO 3300
5000 REM " --- Display record"
5010 PRINT @(V1,V2),D0$(3,3)," ",D0$(6,20),@(AMTCOL,V2-1),D[3]:M3$,@(AMTCOL,V2
5010:),D[1]:M2$,
5090 RETURN
5200 REM " --- Display header"
5205 IF HEADING>0 THEN GOTO 5300
5210 PRINT @(0,L0),'CE',
5215 CALL "SYC.WC",1,0,MONTH1,0,MARGIN,L0,0
5220 LET OFFSET=0,M=MONTH1,M$=MONTH1$,CL$=""
5230 GOSUB 6400
5240 PRINT @(X,L0),X$,
5250 IF MONTH2=0 THEN GOTO 5400
5260 LET OFFSET=MONTH1,M=MONTH2,M$=MONTH2$
5270 GOSUB 6400
5275 CALL "SYC.WC",1,0,MONTH2,0,MARGIN+1+OFFSET,L0,0
5280 PRINT @(X,L0),X$,
5290 GOTO 5400
5300 REM " --- Clear display area"
5310 LET CL$='CL'
5400 REM " --- Display scale"
5410 IF HEADING=0 THEN PRINT @(0,L0+1),H1$,@(MARGIN),HEADING$,
5420 FOR X=1 TO LINES
5430 PRINT @(0,L0+1+X),SCALE[LINES-(X-1)]:M4$,CL$,
5440 NEXT X
5450 LET HEADING=1
5480 PRINT @(MARGIN,21),FOOTING$
5490 RETURN
5500 REM " --- Display graph"
5510 FOR N=1 TO LINES
5520 LET L=LEN(FNP$(DISPLAY$[N])),R=21-N
5525 IF L=0 THEN GOTO 5580
5530 FOR X=1 TO L
5540 LET X$=DISPLAY$[N](X,1),P=MOD(X-1+WIDTH,WIDTH)
5545 IF X$=" " THEN GOTO 5570
5550 LET BR$='BR',ER$='ER'
5555 IF P>0 THEN LET BR$='SB'+'BR',ER$='ER'+'SF'
5560 PRINT @(X+MARGIN-1,R),BR$,X$,ER$,
5570 NEXT X
5580 NEXT N
5590 RETURN
6000 REM " --- Operation Lookup"
6010 LET CHANNEL=OPCODE_DEV,RECORD$="",NUMBER=1,TITLE$="Operation Codes"
6020 DIM DESCRIPTION$[NUMBER],FIELD[NUMBER],POSITION[NUMBER],LENGTH[NUMBER]
6025 LET DESCRIPTION$[0]="Code",DESCRIPTION$[1]="Description"
6035 LET FIELD[0]=1,POSITION[0]=3,LENGTH[0]=3
6040 LET FIELD[1]=1,POSITION[1]=6,LENGTH[1]=20
6055 LET ROW=V2+1,COLUMN=79-LENGTH[0]-LENGTH[1]-2-NUMBER*4
6060 LET V$="SKIP"
6070 CALL "SYC.LK",CHANNEL,RECORD$,NUMBER,TITLE$,DESCRIPTION$[ALL],FIELD[ALL],
6070:POSITION[ALL],LENGTH[ALL],COLUMN,ROW,V$
6090 RETURN
6200 REM " --- Retrieve calendar record"
6210 DIM C0$(9),C[31]
6230 LET M$=" "+MONTHS$[NUM(MM$)]+" ",C0$(1)=N0$+OPERATION$+FNYY_YY21$(YY$)+MM
6230:$
6240 FIND (WOM04_DEV,KEY=C0$,DOM=6300)IOL=WOM04A
6290 GOTO 6390
6300 REM " --- Missing calendar record"
6310 LET Y=FNYY_YEAR(YY$),X=NUM(MM$),C[0]=M[X]
6320 IF MOD(Y,4)=0 THEN IF Y<>0 THEN IF X=2 THEN LET C[0]=29
6350 DIM MESSAGE$[1]
6360 LET MESSAGE$[0]="No Calendar Has Been Defined For"+M$+" "+STR(1900+Y)+" (
6360:<Enter>=Continue)"
6370 CALL "SYC.XA",2,MESSAGE$[ALL],0,22,-1,V$,V3
6390 RETURN
6400 REM " --- Calculate column position and month name for header"
6410 LET X=0,X$=""
6420 IF M=0 THEN GOTO 6490
6425 IF INT((M+2)/WIDTH)=1 THEN GOTO 6480
6430 LET X$=M$,X=MARGIN+1+OFFSET+FNC(X$,M)
6440 IF M>LEN(M$) THEN GOTO 6490
6450 LET X$=M$(1,4)+" ",X=MARGIN+1+OFFSET+FNC(X$,M)
6460 GOTO 6490
6480 LET X$=FNS$(M$(1,3)),X=MARGIN+OFFSET+(OFFSET>0)
6490 RETURN
6500 REM " --- Convert value to bar graph"
6505 IF NUMBER<SCALE[1] THEN GOTO 6690
6510 FOR N=1 TO LINES
6520 IF NUMBER>=SCALE[N] THEN GOTO 6580
6530 LET SIZE=N
6540 IF SCALE[N]-NUMBER>NUMBER-SCALE[N-1] THEN LET SIZE=N-1
6570 EXITTO 6600
6580 NEXT N
6590 LET SIZE=LINES
6600 REM 
6610 FOR N=1 TO SIZE
6620 LET DISPLAY$[N]((X-1)*WIDTH+INDEX,1)=CHAR$
6630 NEXT N
6690 RETURN
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
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8025 DEF FNC(Q$,Q)=INT((Q-LEN(Q$))/2)
8080 DEF FNP$(Q$)=CVS(Q$,2)
8085 DEF FNS$(Q$)=Q$(POS(" "<>Q$))
8090 DEF FNV(Q$)=42+INT(LEN(Q$)/2)
8120 REM " --- FNYY_YY21$ Convert 2-Char Year to 21st Century 2-Char Year"
8125 DEF FNYY_YY21$(Q1$)
8130 LET Q3$=" ABCDE56789ABCDEFGHIJ",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABC
8130:DEFGHIJ"))
8135 RETURN Q1$
8140 FNEND
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
9800 REM " --- Display Parameter record error"
9810 LET LINE_ERR$=LST(PGM(TCB(5)))
9820 CALL "SYC.YA",LINE_ERR$,N2$,ERR
9900 RUN "SYS.AA"
9999 END
