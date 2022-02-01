0010 REM "OPR - Sales Register (Summary Overlay)"
0020 REM "Program OPR.HC"
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0 - 15May96 |"
0026 REM "|      Copyright (c) 1996 Open Systems Holdings Corp.       |"
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0085 SETESC 9000
0090 SETERR 9000
0200 REM " --- IOLIST's"
0210 ARM10E: IOLIST X$(1)
0220 ARM10F: IOLIST X$(1)
0230 ARM10H: IOLIST X$(1)
0310 ARW01A: IOLIST X0$,X0
0320 ARW11A: IOLIST X0$,X0
0330 ARW21A: IOLIST X0$,X0
0500 REM " --- Initializations"
0550 LET L9=55,L=L9+1,HEADINGS=1
0700 REM " --- Background"
0710 PRINT @(0,10),'CL',@(0,11),'CL',@(0,12),'CL',
0720 CALL "SYC.NB","Printing",3,COLUMN

0860 rem 'V6Demo --- set up docout; use DocoutWrapper
0862 use ::DocoutWrapper.bbj::DocoutWrapper
0864 declare DocoutWrapper report!
0866 xUserName$ = "guest", xPassword$ = ""

0867 docname$ = n0$+"_SalesRegisterSummary"

0869 report! = new DocoutWrapper(n0$, "SlsRegSummary", docname$, xUserName$, xPassword$)
0870 gosub addColumns; gosub addHeadings; gosub setOutputAction

1000 REM " --- Territory Summary"
1010 LET R1$="A",R2$="H",H$="Territory",WORK_DEV=ARW01_DEV,P=7,W=20
1020 GOSUB 6000
1200 REM " --- Transaction Summary"
1210 LET R1$="B",R2$="E",H$="Transaction",WORK_DEV=ARW11_DEV,P=5,W=20
1220 GOSUB 6000
1230 rem ' PRINT (7)@(5),"Tax",@(40),U[2]:M1$
1232 dim row$:rowTemplate$; row.column02$="Tax"; row.column03$=str(U[2]:M1$) + $00$ + "R"; report!.addRow(row$)
1240 rem ' PRINT (7)@(5),"Freight",@(40),U[3]:M1$
1242 dim row$:rowTemplate$; row.column02$="Freight"; row.column03$=str(U[3]:M1$) + $00$ + "R"; report!.addRow(row$)
1250 rem ' PRINT (7)@(5),"Discount",@(40),U[5]:M1$
1252 dim row$:rowTemplate$; row.column02$="Discount"; row.column03$=str(U[5]:M1$) + $00$ + "R"; report!.addRow(row$)
1400 REM " --- Salesperson Summary"
1410 LET R1$="C",R2$="F",H$="Salesperson",WORK_DEV=ARW21_DEV,P=7,W=20
1420 GOSUB 6000
1425 gosub AvaTax_Skipped_Invoices; rem --- V6Hybrid AvaTax invoices skipped due to failed tax calculation
1430 report!.renderReport()
4000 REM " --- All done"
4010 IF NONINV=0 AND INV=0 THEN GOTO 4500
4020 IF INV=1 THEN GOTO 4100
4030 LET V4$="Missing Non-Inventoried Serial/Lot Nos. Proceed With Update"
4040 CALL "SYC.YN",0,V4$,0,V$,V3
4050 IF V$="YES" THEN GOTO 4500
4090 GOTO 9900
4100 REM 
4110 DIM MESSAGE$[1]
4120 LET MESSAGE$[0]="Missing Inventoried Serial/Lot Numbers (<Enter>=Continue)"
4130 CALL "SYC.XA",1,MESSAGE$[ALL],0,22,-1,V$,V3
4190 GOTO 9900
4500 REM " --- Close Files Not Need For Update Or GL Summary"
4510 CLOSE (ARW01_DEV,ERR=4520)
4520 CLOSE (ARW04_DEV,ERR=4530)
4530 CLOSE (ARW11_DEV,ERR=4540)
4540 CLOSE (ARW20_DEV,ERR=4550)
4550 CLOSE (ARW21_DEV,ERR=4560)
4900 REM " --- Run next overlay"
4910 LET UPDATE$="OPU.CA"
4920 IF GL$<>"Y" THEN GOTO 4990
4930 DIM GLCONTROL$(640)
4940 LET GLCONTROL$(1)=STBL("!GLCONTROL",ERR=4970)
4950 LET GLCONTROL$(50,1)=P3$(79,1); REM "Print GL Sales Detail Report
4960 LET X$=STBL("!GLCONTROL",GLCONTROL$)
4970 PRINT @(40,5),"G/L Summary",'CL',
4980 RUN "GLR.XA.docout"
4990 RUN UPDATE$,ERR=9900
5000 REM " --- Heading"
5005 rem ' replaced by docout
5010 rem ' CALL "SYC.HA",7,HEADINGS$[ALL],HEADINGS,PAGE,WIDTH,WHEN$,CLOCK$,STATUS
5015 rem ' IF STATUS>0 THEN EXITTO 9900
5020 LET L=HEADINGS+1
5200 REM " --- Subheading"
5210 rem ' PRINT (7)""
5212 report!.addBlankRow()
5220 rem ' PRINT (7)H$," Summary",@(40+M1-7),"Amount"
5222 dim row$:rowTemplate$; row.column01$=H$ + " Summary"; row.column03$="Amount" + $00$ + "R"; report!.addRow(row$)
5230 rem ' PRINT (7)""
5232 report!.addBlankRow()
5240 LET L=L+3
5290 RETURN
6000 REM " --- Process Summary Section"
6010 PRINT @(40,5),H$," Summary",'CL',
6020 IF L+3>L9 THEN GOSUB 5000 ELSE GOSUB 5200
6090 READ (WORK_DEV,KEY=N0$+R1$,DOM=6100)
6100 REM " --- Read next record"
6110 LET K$=KEY(WORK_DEV,END=6400)
6120 IF POS(N0$+R1$=K$)<>1 THEN GOTO 6400
6130 PRINT @(COLUMN,11),K$(6)
6140 READ (WORK_DEV)IOL=ARW01A
6200 REM " --- Print record"
6210 DIM X$(32)
6220 LET X$(P)="Unknown "+H$
6230 FIND (ARM10_DEV,KEY=N0$+R2$+K$(6),DOM=6240)IOL=ARM10E
6235 IF R1$="B" THEN IF X$(25,1)="M" THEN GOTO 6290
6240 IF L>L9 THEN GOSUB 5000
6250 rem ' PRINT (7)@(5),K$(6)," ",X$(P,W),@(40),X0:M1$
6252 dim row$:rowTemplate$; row.column02$=K$(6) + " " + X$(P,W); row.column03$=str(X0:M1$) + $00$ + "R"; report!.addRow(row$)
6260 LET L=L+1
6290 GOTO 6100
6400 REM " --- Section complete"
6490 RETURN
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

11000 AvaTax_Skipped_Invoices: rem --- V6Hybrid AvaTax invoices skipped due to failed tax calculation
11005 if avataxFailed!.size()>0 then
11010   dim row$:rowTemplate$
11015   report!.addRow(row$)
11020   row.column01$="Invoices with failed tax calculation"
11025   report!.addRow(row$)
11030   row.column01$="Customer"+"  -  "+"Order"+"  -  "+"Invoice"
11035   report!.addRow(row$)
11035   for i=0 to avataxFailed!.size()-1
11045       custOrdInv!=avataxFailed!.getItem(i)
11050       row.column01$=custOrdInv!.getItem(0)+"  -  "+custOrdInv!.getItem(1)+"  -  "+custOrdInv!.getItem(2)
11055       report!.addRow(row$)
11060   next i
11070   msg_id$="OP_WARN_INV_SKIPPED"
11075   call stbl("+DIR_SYP")+"bac_message.bbj",msg_id$,msg_tokens$[all],msg_opt$,table_chans$[all]
11080 endif
11090 return

16000 addColumns:
16010 rem ' add columns to the Report
16020 report!.addColumn("","C",8,0,"","L","L")
16030 report!.addColumn("","C",30,0,"","L","L")
16040 report!.addColumn("","C",12,0,"","R","R")
16050 columnCount = report!.getColumnCount()
16060 rowTemplate$ = report!.getRowTemplate()
16070 dim row$:rowTemplate$
16080 return

16200 addHeadings:
16210 report!.addHeading(HEADINGS$[0])
16220 report!.addHeading(HEADINGS$[1])
16230 return

16300 setOutputAction:
16310 rem ' indicates individual out put fields may contain special formatting
16320 report!.setOutputAction("FORMAT")
16330 return