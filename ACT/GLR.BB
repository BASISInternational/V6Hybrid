0010 REM "GLR - G/L Trial Balance (Report Overlay)"
0020 REM "Program GLR.BB"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLIST's"
0210 GLM01A: IOLIST A0$(1),A1$(1)
0220 GLM02A: IOLIST X0$(1),A[ALL]
0400 REM " --- Parameters"
0410 LET BREAK$="",DESC$=""
0420 FIND (SYS01_DEV,KEY=N0$+N2$+"01",DOM=0480)
0430 CALL "GLC.RG",GLM10_DEV,N0$,BREAK$,DESC$
0480 CALL "SYC.RM",M1$,M1,9,15
0490 LET W=M1*2+1
0500 REM " --- Initializations"
0510 DIM A0$(2+P[4]),A1$(40),X0$(3+P[4]),A[MP],U1$(M1,"-"),TOTALS[5]
0520 DIM D[5],W[5],S[5],T[5],O[8],H3$(W,"-"),H4$(W,"-"),H5$(W,"-")
0530 LET L9=59,L=L9+1
0540 LET X$=" Beginning Balance ",H3$(FNC(X$,W),LEN(X$))=X$
0545 LET X$=" Period To Date ",H4$(FNC(X$,W),LEN(X$))=X$
0550 LET X$=" Ending Balance ",H5$(FNC(X$,W),LEN(X$))=X$
0555 LET PERIOD=NUM(BEGPER$),NUMBER=0
0600 REM " --- Print positions"
0610 LET O[8]=H0-M1
0620 FOR X=7 TO 3 STEP -1
0630 LET O[X]=O[X+1]-M1-1
0640 NEXT X
0650 LET O[2]=O[3]-36,X=MAX(M0,8),O[1]=O[2]-X-1
0660 IF O[1]<2 THEN LET O[1]=2,O[2]=O[1]+X+1
0670 LET WIDTH=O[3]-O[2]
0680 IF WIDTH>35 THEN LET WIDTH=35
0700 REM " --- Background"
0750 CALL "SYC.NB","Printing",M0,COLUMN
0800 REM " --- Which GLM-02 record?"
0805 LET YEAR=0,YEAR=FNYY_YEAR(BEGYEAR$,ERR=0810)
0810 IF P4$(6,1)="Y" THEN GOTO 0850
0820 IF YEAR=P[2] THEN LET RECORD$="4"
0830 IF YEAR=P[2]-1 THEN LET RECORD$="0"
0840 IF YEAR=P[2]-2 THEN LET RECORD$="2"
0845 GOTO 0900
0850 IF YEAR=P[2] THEN LET RECORD$="0"
0860 IF YEAR=P[2]-1 THEN LET RECORD$="2"
0875 IF YEAR=P[2]+1 THEN LET RECORD$="4"
0900 REM " --- Position file"
0990 READ (GLM01_DEV,KEY=N0$,DOM=1000)
1000 REM " --- Read next GLM-01 record"
1010 LET K$=KEY(GLM01_DEV,END=4000)
1020 IF POS(N0$=K$)<>1 THEN GOTO 4000
1030 READ (GLM01_DEV)IOL=GLM01A
1040 PRINT @(COLUMN,11),FNF$(A0$(3,P[3]),M0$)
1050 LET TYPE=POS(A1$(36,1)="ALCIE")
1100 REM " --- Read GLM-02 record"
1110 LET X0$(1)=A0$,X0$(3+P[4],1)=RECORD$
1120 FIND (GLM02_DEV,KEY=X0$,DOM=3900)IOL=GLM02A
1200 REM " --- Chart of Account Break?"
1210 IF BREAK$<>"" THEN IF A0$(3,P[4])<BREAK$(1,P[4]) THEN GOTO 2000
1220 IF BREAK$="" THEN GOTO 2000
1400 REM " --- Print subtotal and new heading"
1410 GOSUB 6000
1420 LET TITLE$=FNP$(DESC$(1,20))
1430 GOSUB 5200
1500 REM " --- Strip current heading"
1510 IF LEN(BREAK$)>P[4] THEN LET BREAK$=BREAK$(P[4]+1),DESC$=DESC$(21)
1520 IF LEN(BREAK$)<=P[4] THEN LET BREAK$="",DESC$=""
1530 IF BREAK$<>"" THEN IF POS(" "<>BREAK$(1,P[4]))=0 THEN GOTO 1500
1590 GOTO 1200
2000 REM " --- Accumulate beginning balance"
2010 LET BALANCE=A[0],SUM=ABS(BALANCE)
2020 IF PERIOD-1<1 THEN GOTO 2100
2030 FOR X=1 TO PERIOD-1
2040 LET BALANCE=BALANCE+A[X],SUM=SUM+ABS(A[X])
2050 NEXT X
2100 REM " --- Extract period to date and calculate ending balance"
2110 DIM D[5]
2120 LET CURRENT=A[PERIOD],ENDING=BALANCE+CURRENT,SUM=SUM+ABS(CURRENT)
2130 IF SUM=0 THEN GOTO 3900
2140 IF BALANCE>0 THEN LET D[0]=BALANCE
2150 IF BALANCE<0 THEN LET D[1]=ABS(BALANCE)
2160 IF CURRENT>0 THEN LET D[2]=CURRENT
2170 IF CURRENT<0 THEN LET D[3]=ABS(CURRENT)
2180 IF ENDING>0 THEN LET D[4]=ENDING
2190 IF ENDING<0 THEN LET D[5]=ABS(ENDING)
2200 REM " --- Heading?"
2210 IF L+1<L9 THEN GOTO 2300
2220 GOSUB 5000
2230 GOSUB 5200
2300 REM " --- Print detail line"
2310 PRINT (7)@(O[1]),FNF$(A0$(3,P[3]),M0$),@(O[2]),A1$(1,WIDTH),
2320 FOR X=0 TO 5
2330 IF D[X]<>0 THEN PRINT (7)@(O[X+3]),D[X]:M1$,
2340 NEXT X
2350 PRINT (7)""
2390 LET L=L+1
2500 REM " --- Accumulate totals"
2510 FOR X=0 TO 5
2520 LET S[X]=S[X]+D[X],T[X]=T[X]+D[X]
2530 NEXT X
2540 LET TOTALS[TYPE]=TOTALS[TYPE]+D[4]-D[5]
3900 REM " --- Loop back for next record"
3990 GOTO 1000
4000 REM " --- All done"
4010 LET DONE=1
4020 GOSUB 6000
4100 REM " --- Print report totals"
4110 IF L+2>L9 THEN GOSUB 5000
4120 FOR X=0 TO 5
4130 LET W[X]=T[X]
4140 NEXT X
4150 LET TOTAL$="Total For Report"
4160 GOSUB 6200
4200 REM " --- Print account type totals"
4210 IF L+8>L9 THEN GOSUB 5000
4220 LET INCOME=(-TOTALS[4])-TOTALS[5]
4225 PRINT (7)""
4230 PRINT (7)@(O[1]),"Total Assets",@(O[3]),TOTALS[1]:M1$
4240 PRINT (7)@(O[1]),"Total Liabilities",@(O[3]),-TOTALS[2]:M1$
4250 PRINT (7)@(O[1]),"Total Equity",@(O[3]),-TOTALS[3]:M1$
4260 PRINT (7)@(O[1]),"Total Income",@(O[3]),-TOTALS[4]:M1$
4270 PRINT (7)@(O[1]),"Total Expenses",@(O[3]),TOTALS[5]:M1$
4280 PRINT (7)@(O[3]),U1$
4290 PRINT (7)@(O[1]),"Net Income/(Loss)",@(O[3]),INCOME:M1$
4900 REM " --- Return to menu"
4990 GOTO 9900
5000 REM " --- Report Heading"
5010 LET L=HEADINGS+1
5020 CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,PAGE,H0,WHEN$,CLOCK$,STATUS
5030 IF STATUS>0 THEN EXITTO 9900
5050 PRINT (7)""
5060 PRINT (7)@(O[3]),H3$,@(O[5]),H4$,@(O[7]),H5$
5070 PRINT (7)@(O[1]),"Account",@(O[2]),"Description",@(O[3]+M1-6),"Debit",@(O
5070:[4]+M1-7),"Credit",@(O[5]+M1-6),"Debit",@(O[6]+M1-7),"Credit",@(O[7]+M1-6
5070:),"Debit",@(O[8]+M1-7),"Credit"
5080 LET L=L+3
5090 RETURN
5200 REM " --- Subheading"
5210 IF L+6>L9 THEN GOSUB 5000
5220 PRINT (7)""
5230 PRINT (7)@(O[0]),TITLE$
5240 PRINT (7)""
5250 LET L=L+3
5290 RETURN
6000 REM " --- Chart of Accounts Break"
6010 IF T0$="" THEN GOTO 6100
6020 IF FNP$(A0$(3,P[4]))="" THEN GOTO 6100
6030 FOR X=0 TO 5
6040 LET W[X]=S[X]
6050 NEXT X
6060 LET TOTAL$="Total For "+TITLE$
6070 IF L+2>L9 THEN GOSUB 5000; GOSUB 5200
6080 GOSUB 6200
6100 IF DONE>0 THEN RETURN
6110 DIM S[5]
6120 LET T0$=A0$(3,P[4])
6190 RETURN
6200 REM " --- Print subtotal/total"
6210 PRINT (7)@(O[3]),U1$,@(O[4]),U1$,@(O[5]),U1$,@(O[6]),U1$,@(O[7]),U1$,@(O[
6210:8]),U1$
6220 PRINT (7)@(O[1]),TOTAL$,@(O[3]),W[0]:M1$,@(O[4]),W[1]:M1$,@(O[5]),W[2]:M1
6220:$,@(O[6]),W[3]:M1$,@(O[7]),W[4]:M1$,@(O[8]),W[5]:M1$
6230 LET L=L+2
6290 RETURN
8000 REM " --- Functions"
8025 DEF FNC(Q$,Q)=INT((Q-LEN(Q$))/2)
8070 DEF FNP$(Q$)=CVS(Q$,2)
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
9210 SETERR 9000
9290 GOTO 9900
9300 REM " --- Standard Escape Routine"
9310 CALL "SYC.ES",ERR=9350,PGM(-2),TCB(8),E$,E2,V3
9320 IF V3<>127 THEN GOTO 9390
9330 PRINT @(0,E2),'CL','CURSOR'("ON"),E$,'LF'
9350 ESCAPE
9390 RETURN
9900 RUN "SYS.AA"
9999 END
