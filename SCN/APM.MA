0010 REM "APM - Vendor Maintenance"
0020 REM "Program APM.MA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.7           |
0026 REM "|         Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0031 REM "27Aug96 WGH: Error 13 in Line 4560 of APM.MB when deleting a vendor 
0031:(140-160,195)"
0032 REM "20Nov96 Caj: Don't allow entry of vendor IDs that start with TEMP (1
0032:085,6200-6290)
0033 REM "11Feb97 JAL: Don't allow delete when assigned to inventory item (423
0033:,610,615)"
0034 REM "18Mar97 WGH: Can't print AP checks when someone is doing Vendor Main
0034:tenance (125,140,180,195)"
0035 REM "07Jun00 JAL: Correctly DIM APM-01 second string (520)"
0040 REM 
0050 SETESC 9000
0055 SETERR 9000
0060 ON O0 GOTO 0070,4000,1000,1200,4200
0070 BEGIN
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files
0110 LET FILES=24
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0125 LET FILES$[1]="APE-01",FILES$[2]="APM-01",FILES$[3]="APM-02"
0130 LET FILES$[4]="APM-04",FILES$[5]="APM-05",FILES$[6]="APM-09"
0135 LET FILES$[7]="APM-10",FILES$[8]="APS-10",FILES$[9]="APT-01"
0140 LET FILES$[10]="APT-11",FILES$[11]="SYS-01"
0160 CALL "SYC.DA",1,1,12,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0170 IF STATUS>0 THEN GOTO 9900
0180 LET APE01_DEV=CHANNELS[1],APM01_DEV=CHANNELS[2],APM02_DEV=CHANNELS[3]
0185 LET APM04_DEV=CHANNELS[4],APM05_DEV=CHANNELS[5],APM09_DEV=CHANNELS[6]
0190 LET APM10_DEV=CHANNELS[7],APS10_DEV=CHANNELS[8],APT01_DEV=CHANNELS[9]
0195 LET APT11_DEV=CHANNELS[10],SYS01_DEV=CHANNELS[11]
0200 REM " --- IOLists
0210 APM01A: IOLIST A0$(1),A1$(1)
0260 APS01A: IOLIST X$,P1$,P2$,P3$,P4$,M0$,M1$,M2$,M3$
0270 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0280 GLS01A: IOLIST X$,G1$,G2$,X$,G4$,G5$,G6$,G7$
0290 IVS01A: IOLIST *,*,I2$,X$,X$,X$,M5$,M6$,M7$,*,MCONVF$
0295 APS10N: IOLIST Y0$,Y[0],Y[1],Y[2]
0400 REM " --- Parameters
0403 DIM P[2],G[4],INFO$[20],DESCLEN[3]
0406 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9800)IOL=SYS01T
0409 LET N0$=F0$(16,2),N1$=F4$,N2$="AP",N4$=F5$
0412 FIND (SYS01_DEV,KEY=N0$+N2$+"00",DOM=9800)IOL=APS01A
0415 IF LEN(P3$)<21 THEN LET P3$=P3$+"N"; GOTO 0421
0418 FIND (SYS01_DEV,KEY=N0$+"GL00",DOM=9800)IOL=GLS01A
0421 CALL "SYC.VA","IV",INFO$[ALL]
0423 LET IV$=INFO$[20]
0424 IF INFO$[20]<>"Y" THEN GOTO 0445
0427 FIND (SYS01_DEV,KEY=N0$+"IV"+"00",DOM=0445)IOL=IVS01A
0430 LET IVPRECISION=NUM(I2$(5,1)),ITEMLEN=NUM(I2$(1,2)),VPRODLEN=NUM(I2$(3,2)
0430:)
0433 FOR X=1 TO 3
0436 LET DESCLEN[X]=NUM(I2$((X-1)*2+9,2))
0439 NEXT X
0442 GOTO 0448
0445 LET P3$(20,2)="NN"
0448 FOR X=0 TO 4
0451 LET G[X]=NUM(G2$(X*2+1,2),ERR=0454)
0454 NEXT X
0457 LET G[2]=FNYY_YEAR(G2$(5,2))
0460 LET P[0]=NUM(P2$(1,2)),P[1]=NUM(P2$(3,2)),P[2]=NUM(P3$(9,1))
0463 CALL "SYC.VA",N2$,INFO$[ALL]
0466 LET GL$=INFO$[9]
0469 CALL "SYC.VA","PO",INFO$[ALL]
0472 LET PO$=INFO$[20]
0500 REM " --- Init Data
0510 DIM J0$(20,"0"),J$(80,"-"),J1$(40," ")
0520 DIM A0$(8),A1$(245),B0$(10),B1$(24),B[13],B2$(G[4]),Y[2]
0530 LET K0=1,K9=8,L0=11,L9=20,L1=11
0540 LET A0$(1,2)=N0$
0545 CALL "SYC.RM",M1$,M1,6,14
0550 LET M8$="(###) ###-####",M9$="00000",G5=LEN(G5$)
0560 IF P[2]=9 THEN LET M9$="00000-0000"
0600 REM " --- Additional Opens
0610 IF P3$(21,1)="Y" THEN LET FILES$[14]="APM-06",FILES$[15]="IVM-10"
0615 IF IV$="Y" THEN LET FILES$[16]="IVM-03"
0620 IF GL$="Y" THEN LET FILES$[17]="GLM-01"
0630 IF PO$="Y" THEN LET FILES$[18]="POM-02",FILES$[19]="POT-04",FILES$[20]="P
0630:OT-05",FILES$[21]="POT-14",FILES$[22]="POT-25",FILES$[23]="POT-35",FILES$
0630:[24]="IVM-01"
0650 CALL "SYC.DA",1,14,24,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATU
0650:S
0655 IF STATUS>0 THEN GOTO 9900
0660 LET APM06_DEV=CHANNELS[14],IVM10_DEV=CHANNELS[15],IVM03_DEV=CHANNELS[16]
0670 LET GLM01_DEV=CHANNELS[17]
0680 LET POM02_DEV=CHANNELS[18],POT04_DEV=CHANNELS[19],POT05_DEV=CHANNELS[20]
0685 LET POT14_DEV=CHANNELS[21],POT25_DEV=CHANNELS[22],POT35_DEV=CHANNELS[23]
0690 LET IVM01_DEV=CHANNELS[24]
0700 REM " --- Background
0710 CALL "SYC.WC",1,0,80,0,0,L0-1,0
0720 PRINT 'SB',@(0,3),"Vendor Number:",@(44),"Fax Phone:",@(9,4),"Name:",@(46
0720:),"Acct ID:",@(6,5),"Address:",@(46),"Contact:",@(41,6),"Alt Sequence:",@
0720:(42,7),"Date Opened:",@(3,8),"Zip/Postal:",@(40),"Hold Invoices:",@(4,9),
0720:"Telephone:",@(30),"Ext:",@(43),"Federal ID:",@(71),"1099?",
0790 PRINT 'SF',
0900 REM " --- Init File
0920 READ (APM01_DEV,KEY=A0$(1,2),DOM=1000)
1000 REM " --- Key
1010 PRINT 'CF',
1015 DIM B0$(10),B1$(24),B[13],B2$(G[4])
1020 LET V2$="",V2$=KEY(APM01_DEV,END=1050)
1030 IF V2$(1,2)<>A0$(1,2) THEN LET V2$=""
1040 IF V2$<>"" THEN LET V2$=V2$(3,P[0])
1050 LET V0$="M",V1$="ECK",V3$=P1$,V0=6,V1=15,V2=3,O8=0,V4$="Enter a Valid Ven
1050:dor Number (<F2>=Auto Number/<F3>=Lookup)"
1060 GOSUB 7000
1065 IF V3=3 THEN CALL "SYC.LV",V$
1070 IF V3=4 THEN GOTO 9900
1075 IF V3=2 THEN PRINT @(V1,V2),J1$(1,LEN(M0$)); GOSUB 6000
1080 IF V$="" THEN GOTO 0900
1085 IF POS("TEMP"=V$)=1 THEN GOSUB NOTEMPS; GOTO 1050
1090 LET A0$(3)=V$,O5=0
1095 PRINT @(V1,V2),FNF$(A0$(3,P[0]),M0$),
1200 REM " --- Find Key
1220 FIND (APM01_DEV,KEY=A0$(1,K9),DOM=1400)IOL=APM01A
1240 LET O8=1
1300 REM " --- Display
1320 GOSUB 5000
1340 GOTO 4000
1400 REM " --- New Record
1420 CALL "SYC.YN",1,"Is This A New Record",2,V$,V3
1440 ON POS(V$="YN") GOTO 1400,1500,1000
1500 REM " --- Setup
1510 LET A1$(1)="",B1$(1)=""
1520 DIM B[13]
1530 LET A1$(156,3)=F0$(7,3),A1$(159,1)="N",A1$(175,1)="Y"
2000 REM " --- Overlay
2020 LET O0=1
2040 RUN "APM.MB"
4000 REM " --- Options"
4010 DIM MENUS$[3]
4020 LET MENUS=1,MENUS$[MENUS]="APM.MA",WIN_X=40,WIN_Y=L0+1
4030 LET HISTORY$="",O0=1,O9=0
4040 IF PO$="Y" THEN LET MENUS=MENUS+1,MENUS$[MENUS]="APM.MI"
4050 IF P3$(21,1)="Y" THEN LET MENUS=MENUS+1,MENUS$[MENUS]="APM.MJ"
4065 CALL "SYC.OA",MENUS,MENUS$[ALL],WIN_X,WIN_Y,DESCRIPTION$,SELECTION$
4070 CALL "SYC.WC",1,0,80,0,0,L0-1,0
4075 PRINT @(0,L0),'CE',
4080 IF SELECTION$="" THEN GOTO 1000
4085 IF SELECTION$="SYC.KA" THEN GOTO 4100
4090 RUN SELECTION$,ERR=4000
4100 REM " --- Comments
4110 DIM INFO$[5],INFO[5]
4120 LET X$="Vendor "+FNF$(A0$(3,P[0]),M0$)+" "+FNP$(A1$(1,30))
4130 LET INFO$[0]="APM-09",INFO$[1]=A0$,INFO$[2]=X$,ACTION=0,INFO[1]=L0
4150 CALL "SYC.KA",ACTION,INFO$[ALL],INFO[ALL]
4190 GOTO 4000
4200 REM " --- Restore screen after hardcopy listing
4210 CALL "SYC.WC",1,0,80,0,0,L0-1,0
4220 PRINT @(0,L0),'CE',
4290 GOTO 4000
5000 REM " --- Display
5020 PRINT @(55,3),FNF$(A1$(186,10),M8$),@(15,4),A1$(1,30),@(15,5),A1$(31,24),
5020:@(15,6),A1$(55,24),@(15,7),A1$(79,24),@(15,8),FNZ$(A1$(103)),@(15,9),FNF$
5020:(A1$(112,10),M8$),@(35,9),A1$(122,4),
5030 PRINT @(55,4),A1$(176,10),
5040 PRINT @(55,5),A1$(126,20),@(55,6),A1$(146,10),@(55,7),FNB$(A1$(156,3)),@(
5040:55,8),A1$(159,1),@(55,9),A1$(160,15),@(77,9),A1$(175,1),
5090 RETURN
6000 REM " --- Auto Number
6001 LET V4$="Are You Certain That You Wish To Create A New Number"
6002 CALL "SYC.YN",1,V4$,2,V$,V3
6004 IF V$<>"Y" THEN EXITTO 1000
6010 LET C9=1,Y0$=N0$+"N"
6020 EXTRACT (APS10_DEV,KEY=Y0$,DOM=6030)IOL=APS10N
6030 LET I=Y[0]
6040 DIM MAXNUM$(P[0],"9")
6050 LET V$=STR(I:J0$(1,P[0]))
6052 LET V$=V$+J0$,V$=V$(1,6)
6055 LET I=I+1
6060 IF I<=NUM(MAXNUM$) THEN GOTO 6070
6061 DIM MESSAGE$[1]
6062 LET MESSAGE$[0]="There Are No More Numbers Available (<Enter>=Continue)"
6066 CALL "SYC.XA",2,MESSAGE$[ALL],0,22,-1,V$,V3
6067 READ (APS10_DEV); REM "Unextract the record
6068 EXITTO 1000
6070 LET Y[0]=I
6075 FIND (APM01_DEV,KEY=N0$+V$,DOM=6080); GOTO 6030
6080 WRITE (APS10_DEV,KEY=Y0$)IOL=APS10N
6090 PRINT @(15,3),FNF$(V$(1,P[0]),M0$),
6099 RETURN
6200 REM " --- Display message that 'TEMP' is not valid in ID
6205 NOTEMPS:
6220 DIM MESSAGE$[0]
6230 LET MESSAGE$[0]="Vendor Numbers May NOT Begin with 'TEMP'."
6240 CALL "SYC.XA",2,MESSAGE$[ALL],0,-1,-1,V$,V3
6290 RETURN
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
8000 REM " --- Functions
8010 DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
8020 DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
8070 DEF FNP$(Q$)=CVS(Q$,2)
8080 DEF FNV(Q$)=42+INT(LEN(Q$)/2)
8085 DEF FNZ$(Q$)=FILL(10,CVS(Q$(1,3)+FILL(POS("9"<Q$(1,5))>0)+Q$(4,2)+FILL(AB
8085:S(POS("A">=Q$(1,6))>0)-POS("0">Q$(6,4))>0,"-")+Q$(6,4)+FILL(10),16))
8090 DEF FNITEM$(Q$,Q1,Q2,Q3)=CVS(Q$(1,Q1)+" "+Q$(Q1+1,Q2)+" "+Q$(Q1+Q2+1,Q3),
8090:32)
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
8200 REM " --- FNF$ AlphaNumeric Masking Function"
8210 DEF FNF$(Q1$,Q2$)
8220 IF Q2$="" THEN LET Q2$=FILL(LEN(Q1$),"0")
8230 RETURN STR(-NUM(Q1$,ERR=ALPHA_FNF):Q2$,ERR=ALPHA_FNF)
8240 ALPHA_FNF:
8245 LET Q=1,Q0=0
8250 WHILE LEN(Q2$(Q))
8255 IF POS(Q2$(Q,1)="-()") THEN LET Q0=Q0+1 ELSE LET Q2$(Q,1)="X"
8260 LET Q=Q+1
8265 WEND
8270 IF LEN(Q1$)>LEN(Q2$)-Q0 THEN LET Q1$=Q1$(1,LEN(Q2$)-Q0)
8280 RETURN STR(Q1$:Q2$)
8290 FNEND
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
9205 SETESC 9000
9210 SETERR 9000
9220 GOTO 0900
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
