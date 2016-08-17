0010 REM "GLC - Re-Group GLM-10 strings to 5.2 GLS-01 'B' structure"
0020 REM "Program GLC.RG"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0 - 15May96 |"
0026 REM "|      Copyright (c) 1996 Open Systems Holdings Corp.       |"
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0047 REM "GLM10_DEV  : Channel of GLM10 (Input)"
0050 REM "N0$        : Firm ID (Input)"
0053 REM "BREAK$     : Acct Number Break String (Returned)"
0055 REM "DESC$      : Acct Number Break Description String (Returned)"
0060 REM 
0080 SETESC 9900
0085 SETERR 9000
0090 ENTER GLM10_DEV,N0$,BREAK$,DESC$
0100 REM " --- Open/Lock Files"
0200 REM " --- IOLIST's"
0210 GLM10A: IOLIST A0$(1),A1$(1),A2$(1)
0400 REM " --- Parameters"
0500 REM " --- Initializations"
0510 DIM A0$(5),A1$(10),A2$(20),BREAK$(320),DESC$(640)
0520 LET CNT=1
0900 REM " --- Clear and position file"
0910 READ (GLM10_DEV,KEY=N0$,DOM=READ_GLM10)
1000 REM " --- Read through GLM-10"
1010 READ_GLM10:
1030 READ (GLM10_DEV,END=DONE_GLM10)IOL=GLM10A
1040 IF N0$<>A0$(1,2) THEN GOTO DONE_GLM10
2500 REM " --- Re-group Acct Break & Desc strings to structure of 5.2 GLS-01"
2535 LET BREAK$(CNT,10)=A1$(1,10)
2540 LET DESC$((CNT-1)*2+1,20)=A2$(1,20)
2570 LET CNT=CNT+10
2580 REM " --- Next Record
2585 NEXTREC_GLM10:
2590 GOTO READ_GLM10
4000 REM " --- All done"
4010 DONE_GLM10:
4090 GOTO 9900
8000 REM " --- Functions"
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
9900 REM " --- Return to Calling Program"
9950 EXIT
9999 END
