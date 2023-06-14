0010 REM "PRW - Generate W2 Mag Media"
0020 REM "Program PRW.MA"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0050 BEGIN
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files
0110 LET FILES=2
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0125 LET FILES$[1]="W2REPORT",FILES$[2]="SYS-01"
0150 LET OPTIONS$[1]="F"
0160 CALL "SYC.DA",1,1,2,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0170 IF STATUS>0 THEN GOTO 9900
0180 LET W2REPORT_DEV=CHANNELS[1],SYS01_DEV=CHANNELS[2]
0190 IF W2REPORT_DEV=0 THEN GOTO NEEDREPORT
0200 REM " --- IOLists
0300 SYS01S: IOLIST S0$,S1$(1),S2$(1),S3$(1),S4$(1),S5$(1),S6$(1)
0310 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$
0330 PRS01A: IOLIST X$,P1$,P2$,P3$,P4$,M0$,M1$,M2$,M3$
0400 REM " --- Parameters"
0405 DIM S1$(8),S2$(8),S3$(1),S4$(1),S5$(30),S6$(60)
0410 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9800)IOL=SYS01T
0420 LET N0$=F0$(16,2),N1$=F4$,N2$="PR",N4$=F5$
0430 FIND (SYS01_DEV,KEY=N0$+N2$+"00",DOM=9800)IOL=PRS01A
0440 FIND (SYS01_DEV,KEY="S",DOM=9400)IOL=SYS01S
0450 IF POS(S3$(1,1)="UD")=0 THEN GOTO 9500
0460 LET S6$=FNP$(S6$)
0470 IF S6$="" THEN GOTO 9600
0800 REM " --- Options"
0810 DIM MESSAGE$[0]
0820 LET MESSAGE$[0]="Insert Formatted Media in Drive  <Enter>:"
0830 CALL "SYC.XA",0,MESSAGE$[ALL],0,22,-1,V$,V3
0840 ON V3 GOTO 0850,0800,0800,0800,9900
1000 REM " --- Copy W2REPORT to Mag Media"
1010 PRINT @(0,3),'CE',@(26,3),"Transferring W2REPORT using:",@(FNC(S6$,80)-1,
1010:4),$22$,S6$,$22$
1020 CALL "SYC.OS",S6$
4000 REM " --- All done"
4005 PRINT @(0,15),'CE',
4007 DIM MESSAGE$[4]
4010 LET MESSAGE$[0]=" If error(s) occurred, ensure the media was properly for
4010:matted and retry."
4020 LET MESSAGE$[1]=" If necessary, contact your ADD+ON dealer for assistance
4020:."
4030 LET MESSAGE$[2]=" If no errors occurred, label the media.  Remember to en
4030:close the "
4040 LET MESSAGE$[3]=" appropriate "+$22$+"Instructions for Social Security Ad
4040:ministration"+$22$+" sheet with "
4050 LET MESSAGE$[4]=" the media in the mailer.           <Enter>"
4070 CALL "SYC.XA",0,MESSAGE$[ALL],4,8,-1,V$,V3
4090 GOTO 9900
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
8025 DEF FNC(Q$,Q)=INT((Q-LEN(Q$))/2)
8080 DEF FNP$(Q$)=CVS(Q$,2)
8090 DEF FNV(Q$)=42+INT(LEN(V4$)/2)
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
9400 REM " --- Missing SYS-01 System Record"
9403 NEEDSYS01:
9405 DIM MESSAGE$[1]
9410 LET MESSAGE$[0]="System Definition Record is Missing. Use System Definiti
9410:on Maintenance"
9420 LET MESSAGE$[1]="to create this record and then retry.  <Enter>:"
9430 CALL "SYC.XA",0,MESSAGE$[ALL],1,22,-1,V$,V3
9490 GOTO 9900
9500 REM " --- No OS defined"
9503 NEEDOS:
9505 DIM MESSAGE$[1]
9510 LET MESSAGE$[0]="Operating System has not been defined properly. Use Syst
9510:em Definition"
9520 LET MESSAGE$[1]="Maintenance to define this field and then retry.  <Enter
9520:>:"
9530 CALL "SYC.XA",0,MESSAGE$[ALL],1,22,-1,V$,V3
9590 GOTO 9900
9600 REM " --- No W2 copy command defined"
9603 NEEDCOPY:
9605 DIM MESSAGE$[1]
9610 LET MESSAGE$[0]="No W2 Mag Media Copy Command has been specified. Use Sys
9610:tem Definition"
9620 LET MESSAGE$[1]="Maintenance to define this field and then retry.  <Enter
9620:>:"
9630 CALL "SYC.XA",0,MESSAGE$[ALL],1,22,-1,V$,V3
9690 GOTO 9900
9700 REM " --- User needs to create W2REPORT
9705 NEEDREPORT:
9710 DIM MESSAGE$[1]
9720 LET MESSAGE$[0]="File, W2REPORT, does not exist.  Run Magnetic Media"
9730 LET MESSAGE$[1]="Calculation to create this file.  <Enter>:"
9740 CALL "SYC.XA",0,MESSAGE$[ALL],1,22,-1,V$,V3
9790 GOTO 9900
9800 REM " --- Display Parameter record error"
9810 LET LINE_ERR$=LST(PGM(TCB(5)))
9820 CALL "SYC.YA",LINE_ERR$,N2$,ERR
9900 REM " --- Return to menu"
9950 RUN "SYS.AA"
9999 END
