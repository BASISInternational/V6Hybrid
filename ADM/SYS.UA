0010 REM "SYS.UA - ADD+ON Upgrade Program
0020 REM "Program SYS.UA
0022 REM "+-----------------------------------------------------------+"
0024 REM "| ADD+ON Software, Inc. Advantage/V Version 6.0.0           |
0026 REM "|      Copyright BASIS International Ltd.                   |
0028 REM "|                  All Rights Reserved                      |"
0030 REM "+-----------------------------------------------------------+"
0040 REM 
0050 BEGIN
0085 SETESC 9000
0090 SETERR 9000
0100 REM " --- Open/Lock Files"
0110 LET FILES=6
0120 DIM FILES$[FILES],OPTIONS$[FILES],CHANNELS[FILES]
0130 LET FILES$[1]="SYS-01",FILES$[2]="SYM-04",FILES$[3]="ZFILES"
0140 LET FILES$[4]="_FILES"
0150 CALL "SYC.DA",1,1,2,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0160 IF STATUS THEN GOTO 9750
0170 LET SYS01_DEV=CHANNELS[1],SYM04_DEV=CHANNELS[2]
0200 REM " --- IOLIST's"
0210 SYM04A: IOLIST X0$(1),X1$(1),X2$,X3$,X[ALL]
0220 FILES: IOLIST A0$(1),A1$(1)
0230 ZFILES: IOLIST A0$(1),A1$(1)
0270 SYS01T: IOLIST X$,F0$,X$,X$,X$,F4$,F5$,F6$
0280 SYM04A1: IOLIST B0$(1),B1$(1)
0400 REM " --- Parameters"
0410 FIND (SYS01_DEV,KEY="T"+FID(0),DOM=9900)IOL=SYS01T
0420 LET N0$=F0$(16,2),N1$=F4$,N2$="SY",N4$=F5$,MODULES=15
0500 REM " --- Initialization"
0510 DIM J1$(78),MODULES$[MODULES,4],A0$(12),A1$(32),X0$(2),X1$(64),X[2]
0540 LET M1$="##,##0"
0550 REM " --- Software Modules"
0555 LET MODULES$[1,1]="SY",MODULES$[1,2]="ADD+ON Administrator"
0560 LET MODULES$[2,1]="AP",MODULES$[2,2]="Accounts Payable"
0565 LET MODULES$[3,1]="AR",MODULES$[3,2]="Accounts Receivable"
0570 LET MODULES$[4,1]="BM",MODULES$[4,2]="Bill of Materials"
0575 LET MODULES$[5,1]="DD",MODULES$[5,2]="Data Dictionary"
0580 LET MODULES$[6,1]="GE",MODULES$[6,2]="GENERAL Report Writer"
0585 LET MODULES$[7,1]="GL",MODULES$[7,2]="General Ledger"
0590 LET MODULES$[8,1]="IV",MODULES$[8,2]="Inventory Control"
0595 LET MODULES$[9,1]="MP",MODULES$[9,2]="MRP"
0600 LET MODULES$[10,1]="OP",MODULES$[10,2]="Order Processing"
0605 LET MODULES$[11,1]="PO",MODULES$[11,2]="Purchase Orders"
0610 LET MODULES$[12,1]="PR",MODULES$[12,2]="Payroll"
0615 LET MODULES$[13,1]="SA",MODULES$[13,2]="Sales Analysis"
0620 LET MODULES$[14,1]="SH",MODULES$[14,2]="SpeedShip"
0625 LET MODULES$[15,1]="WO",MODULES$[15,2]="Shop Floor Control"
0700 REM " --- Background"
0710 CALL "SYC.WC",ERR=9800,0,0,59,4,11,4,0
0720 PRINT @(13,5),"     This program installs or upgrades the ADD+ON"
0730 PRINT @(13,6),"Software Modules which have been copied to your system."
0740 PRINT @(7,9),"This program will merge the menu, parameter and control inf
0740:ormation"
0750 PRINT @(7,10),"necessary to use the new or upgraded ADD+ON Software Modul
0750:es. It is"
0755 PRINT @(7,11),"also used to install maintenance (SCN) releases."
0760 PRINT @(7,13),"This program may also be used to re-install ADD+ON Softwar
0760:e Modules,"
0770 PRINT @(7,14),"overwriting any existing menu, parameter and control infor
0770:mation."
0790 GOSUB 6900
0900 REM " --- Check for distribution files"
0910 CALL "SYC.DA",1,3,4,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
0920 IF STATUS>0 THEN GOTO 9700
0930 LET ZFILES_DEV=CHANNELS[3],FILES_DEV=CHANNELS[4]
1000 REM " --- Format screen"
1010 LET ROW=5,COLUMN=0
1090 PRINT @(0,3),'CE',@(0,4),"The following ADD+ON Software Modules will be i
1090:nstalled or upgraded:"
1100 REM " --- Which modules?"
1110 FOR X=1 TO MODULES
1120 LET PROGRAM$=MODULES$[X,1]+"C.VN"
1130 CALL PROGRAM$,ERR=1170,VERSION$
1140 LET ROW=ROW+1,MODULES$[X,3]="Y",MODULES$[X,4]=VERSION$
1150 PRINT @(COLUMN,ROW),MODULES$[X,1],"  ",MODULES$[X,2],@(COLUMN+26,ROW),MOD
1150:ULES$[X,4],
1160 IF ROW>19 THEN LET ROW=5,COLUMN=40
1170 NEXT X
1180 CALL "SYC.VS",ERR=1200,SCN_VER$
1185 LET ROW=ROW+1; IF ROW>16 THEN LET ROW=5,COLUMN=40
1190 PRINT @(COLUMN,ROW),"SCN ",SCN_VER$," Software Change Notices",
1200 REM " --- Administrator (and SpeedSearch) must be at least 6.0.0"
1210 GOSUB 6900
1220 IF MODULES$[1,3]="Y" THEN GOTO 1300
1230 FOR X=1 TO 1
1235 DIM B0$(2),B1$(64)
1240 FIND (SYM04_DEV,KEY=MODULES$[X,1],DOM=1280)IOL=SYM04A1
1245 LET VERSION$=FNP$(B1$(40,6))
1250 IF LEN(VERSION$)<5 THEN GOTO 1280
1255 LET VERSION=NUM(VERSION$(1,3),ERR=1280)
1260 LET MODULES$[X,4]=VERSION$
1270 IF VERSION>=6 THEN GOTO 1290
1280 EXITTO 9600
1290 NEXT X
1300 REM " --- Look for files which might be overwritten"
1310 PRINT @(0,3),'CE',@(0,4),"Verifying Distribution File",
1320 LET FOUND=0,ROW=7,COLUMN=0,PRM10$="N"
1400 REM " --- Read next ZFILES record"
1410 LET K$=KEY(ZFILES_DEV,END=1800)
1420 READ (ZFILES_DEV)IOL=ZFILES
1425 IF A1$(27,1)<>"A" THEN GOTO 1400
1430 LET FILENAME$=K$
1450 PRINT @(28,4),FILENAME$,'CL',
1500 REM " --- Does this file exist?"
1510 LET FILES$[5]="Z"+FNP$(FILENAME$),FILES$[6]=FNP$(FILENAME$)
1520 LET OPTIONS$[5]="F",OPTIONS$[6]="F"
1530 CALL "SYC.DA",1,5,6,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
1540 IF STATUS THEN GOTO 1700
1550 IF CHANNELS[6]=0 THEN GOTO 1700
1560 IF CHANNELS[5]=0 THEN GOTO 1700
1570 IF POS("PRM-10"=FILENAME$)>0 THEN LET PRM10$="Y"
1600 REM " --- It does!"
1610 IF FOUND=0 THEN PRINT @(0,6),'CE',"The following files will be overwritte
1610:n if the installation continues:"
1620 LET ROW=ROW+1,FOUND=FOUND+1
1630 PRINT @(COLUMN,ROW),FILENAME$," ",A1$(1,24),
1640 IF ROW<20 THEN GOTO 1700
1650 LET COLUMN=COLUMN+40,ROW=7
1660 IF COLUMN=40 THEN GOTO 1700
1670 GOSUB 6900
1680 LET COLUMN=0
1690 PRINT @(0,ROW),'CE',
1700 REM " --- Loop back for next ZFILES record"
1710 CLOSE (CHANNELS[5],ERR=1720)
1730 CLOSE (CHANNELS[6],ERR=1740)
1790 GOTO 1400
1800 REM " --- Done"
1810 IF FOUND=0 THEN GOTO 2000
1820 GOSUB 6900
1840 IF PRM10$<>"Y" THEN GOTO 1900
1850 REM " --- Payroll Installed?"
1855 PRINT @(0,3),'CE',
1860 CALL "SYC.WC",ERR=1865,0,0,59,4,11,4,0
1865 PRINT @(36,4)," WARNING ",
1870 PRINT @(13,5),"Payroll Tax Files currently exist on this system. This"
1875 PRINT @(13,6),"indicates that an active payroll system may be present."
1880 PRINT @(1,10),"Proceeding with this installation will overwrite these pay
1880:roll files. If this"
1885 PRINT @(1,11),"is a new payroll installation (or re-installation) you sho
1885:uld proceed and"
1890 PRINT @(1,12),"overwrite the files."
1895 GOSUB 6900
1900 REM " --- Verify operator's intent to overwrite existing files"
1910 PRINT @(0,22),'CL',"Are you SURE that you wish to proceed (Enter YES to c
1910:ontinue/<F4> to exit)?",
1920 LET V0$="S",V1$="CE",V2$="NO",V3$="YESNO ",V4$="",V0=3,V1=76,V2=22
1930 GOSUB 7000
1940 IF V3<>0 THEN LET V$="NO"
1950 IF V$<>"YES" THEN GOTO 9900
2000 REM " --- Install Distribution Files"
2010 PRINT @(0,3),'CE',@(0,4),"Installing Distribution Files",
2050 LET ROW=6,COLUMN=0
2090 READ (ZFILES_DEV,KEY="",DOM=2100)
2100 REM " --- Read next ZFILES record"
2105 LET K$=KEY(ZFILES_DEV,END=2300)
2110 READ (ZFILES_DEV)IOL=ZFILES
2115 LET FILENAME$=K$
2125 FOR X=1 TO MODULES
2130 IF A1$(25,2)<>MODULES$[X,1] THEN GOTO 2140
2135 IF MODULES$[X,3]="Y" THEN EXITTO 2150
2140 NEXT X
2145 GOTO 2100
2150 LET FILES$[5]="Z"+FNP$(FILENAME$),FILES$[6]=FNP$(FILENAME$)
2155 LET OPTIONS$[5]="F",OPTIONS$[6]="F"
2160 CALL "SYC.DA",1,5,6,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
2165 IF STATUS THEN GOTO 2100
2170 CLOSE (CHANNELS[5],ERR=2175)
2175 CLOSE (CHANNELS[6],ERR=2180)
2180 IF CHANNELS[6] THEN IF A1$(27,1)<>"A" THEN GOTO 2100
2185 IF CHANNELS[5] THEN GOTO 2200
2190 GOTO 2100
2200 REM " --- Display file to be renamed"
2205 PRINT @(COLUMN,ROW),FILENAME$," ",A1$(1,24)
2210 LET ROW=ROW+1
2215 IF ROW<21 THEN GOTO 2250
2220 LET ROW=6,COLUMN=COLUMN+40
2225 IF COLUMN=40 THEN GOTO 2250
2230 GOSUB 6900
2235 PRINT @(0,ROW),'CE',
2240 LET COLUMN=0
2250 REM " --- Rename Zxxx-xx to xxx-xx"
2255 LET NUMBER=1
2260 DIM SOURCE$[NUMBER],TARGET$[NUMBER],ERASE$[NUMBER]
2265 LET SOURCE$[1]="Z"+FNP$(FILENAME$),TARGET$[1]=FNP$(FILENAME$)
2270 CALL "SYC.RN",SOURCE$[ALL],TARGET$[ALL],ERASE$[ALL],NUMBER,STATUS
2280 IF STATUS THEN GOTO 9500
2290 GOTO 2100
2300 REM " --- RENAME'ing completed. Now merge _FILES records"
2310 GOSUB 6900
2320 PRINT @(0,3),'CE',@(0,4),"Merging Distribution Files",
2350 LET ROW=6,COLUMN=0
2400 REM " --- Read next _FILES record"
2405 LET K$=KEY(FILES_DEV,END=3000)
2410 READ (FILES_DEV)IOL=FILES
2415 LET FILENAME$=K$
2425 FOR X=1 TO MODULES
2430 IF A1$(25,2)<>MODULES$[X,1] THEN GOTO 2440
2435 IF MODULES$[X,3]="Y" THEN EXITTO 2450
2440 NEXT X
2445 GOTO 2400
2450 IF ROW<21 THEN GOTO 2470
2455 LET ROW=6
2460 GOSUB 6900
2465 PRINT @(0,ROW),'CE',
2470 PRINT @(COLUMN,ROW),FILENAME$," ",A1$(1,24),
2480 LET X=COLUMN+38,Y=ROW,NUMBER=0,ROW=ROW+1
2500 REM " --- Does this file exist?"
2510 LET FILES$[5]="_"+FNP$(FILENAME$),FILES$[6]=FNP$(FILENAME$)
2520 LET OPTIONS$[5]="F",OPTIONS$[6]="F"
2530 CALL "SYC.DA",1,5,6,FILES$[ALL],OPTIONS$[ALL],CHANNELS[ALL],BATCH,STATUS
2540 LET SOURCE_DEV=CHANNELS[5],TARGET_DEV=CHANNELS[6]
2550 IF SOURCE_DEV=0 THEN GOTO 2900
2560 IF STATUS=0 THEN GOTO 2800
2700 REM " --- Missing target file. Create it using source file parameters."
2710 CALL "SYC.JA",SOURCE_DEV,X$,PATHNAME$,FILETYPE$,KEYLEN,RECORDS,RECLEN,NUM
2710:REC,STATUS
2720 IF FILETYPE$="K" THEN LET FILETYPE$="D"
2730 IF FILETYPE$="D" THEN IF RECLEN=0 THEN LET FILETYPE$="S"
2750 CALL "SYC.MA",FILETYPE$,FNP$(FILENAME$),A1$(25,2),STR(KEYLEN),RECORDS,REC
2750:LEN,STATUS
2780 CLOSE (SOURCE_DEV,ERR=2790)
2790 GOTO 2500
2800 REM " --- Merge records from _xxx-xx into xxx-xx"
2810 LET K$=KEY(SOURCE_DEV,END=2900)
2820 READ RECORD(SOURCE_DEV,KEY=K$)R$
2830 LET NUMBER=NUMBER+1
2840 IF MOD(NUMBER,10)=0 THEN PRINT @(X,Y),NUMBER:M1$,
2880 WRITE RECORD(TARGET_DEV,KEY=K$)R$
2890 GOTO 2800
2900 REM " --- Loop back for next _FILES record"
2910 PRINT @(X,Y),NUMBER:M1$
2920 CLOSE (SOURCE_DEV,ERR=2930)
2930 CLOSE (TARGET_DEV,ERR=2940)
2990 GOTO 2400
3000 REM " --- Update version number on SY record for installed modules"
3010 GOSUB 6900
3030 PRINT @(0,3),'CE',@(0,4),"Updating System Records"
3040 IF MODULES$[1,3]="Y" THEN CALL "SYC.VN",ERR=9600,SYS_VER$ ELSE LET SYS_VE
3040:R$=MODULES$[1,4]
3050 LET ROW=6,COLUMN=0
3100 REM " --- Update each installed module"
3110 FOR X=1 TO MODULES
3120 IF MODULES$[X,3]<>"Y" THEN GOTO 3290
3130 PRINT @(COLUMN,ROW),MODULES$[X,1],"  ",MODULES$[X,2]
3140 LET ROW=ROW+1
3145 IF ROW<21 THEN GOTO 3200
3150 LET ROW=6,COLUMN=COLUMN+40
3160 IF COLUMN=40 THEN GOTO 3200
3170 GOSUB 6900
3180 PRINT @(0,ROW),'CE',
3190 LET COLUMN=0
3200 REM 
3210 DIM X0$(2),X1$(64),X[2]
3220 LET X0$(1)=MODULES$[X,1]
3230 LET X1$(1)=MODULES$[X,2],X1$(36,1)="Y",X1$(37,2)="99",X2$="",X3$=""
3235 IF SYS_VER$>MODULES$[X,4] THEN LET VERSION$=SYS_VER$ ELSE LET VERSION$=MO
3235:DULES$[X,4]
3240 FIND (SYM04_DEV,KEY=X0$,DOM=3250)IOL=SYM04A
3250 LET X1$(39,1)="Y",X1$(40,6)=VERSION$
3260 IF POS(X1$(46,1)="NY")=0 THEN LET X1$(46,1)="Y"; REM "Default GL Posting 
3260:to YES
3270 WRITE (SYM04_DEV,KEY=X0$)IOL=SYM04A
3290 NEXT X
3300 REM " --- Remove Z files"
3310 GOSUB 6900
3320 PRINT @(0,3),'CE',@(0,4),"Removing Distribution Files",
3330 LET ROW=6,COLUMN=0
3390 READ (ZFILES_DEV,KEY="",DOM=3400)
3400 REM " --- Read next ZFILES record"
3410 LET K$=KEY(ZFILES_DEV,END=3500)
3420 READ (ZFILES_DEV)IOL=ZFILES
3425 LET FILENAME$=K$
3430 PRINT @(COLUMN,ROW),FILENAME$," ",A1$(1,24)
3435 LET ROW=ROW+1
3440 IF ROW<21 THEN GOTO 3470
3445 LET ROW=6,COLUMN=COLUMN+40
3450 IF COLUMN=40 THEN GOTO 3470
3455 GOSUB 6900
3460 PRINT @(0,ROW),'CE',
3465 LET COLUMN=0
3470 ERASE "Z"+FNP$(FILENAME$),ERR=3490
3480 GOTO 3470
3490 GOTO 3400
3500 REM " --- Remove '_' files"
3510 GOSUB 6900
3540 LET ROW=6,COLUMN=0
3550 PRINT @(0,3),'CE',@(0,4),"Removing Merge Files",
3590 READ (FILES_DEV,KEY="",DOM=3600)
3600 REM " --- Read next _FILES record"
3610 LET K$=KEY(FILES_DEV,END=3900)
3620 READ (FILES_DEV)IOL=FILES
3625 LET FILENAME$=K$
3630 PRINT @(COLUMN,ROW),FILENAME$," ",A1$(1,24)
3635 LET ROW=ROW+1
3640 IF ROW<21 THEN GOTO 3670
3645 LET ROW=6,COLUMN=COLUMN+40
3650 IF COLUMN=40 THEN GOTO 3670
3655 GOSUB 6900
3660 PRINT @(0,ROW),'CE',
3665 LET COLUMN=0
3670 ERASE "_"+FNP$(FILENAME$),ERR=3690
3680 GOTO 3670
3690 GOTO 3600
3900 REM " --- Erase version programs"
3905 GOSUB 6900
3910 FOR X=1 TO MODULES
3920 IF MODULES$[X,3]<>"Y" THEN GOTO 3990
3930 LET PROGRAM$=MODULES$[X,1]+"C.VN"
3940 ERASE PROGRAM$,ERR=3990
3950 GOTO 3940
3990 NEXT X
3995 GOSUB 6100
4000 REM " --- Installation completed"
4010 PRINT @(0,3),'CE',@(13,4),"The ADD+ON Software Upgrade Procedure is now c
4010:omplete.",
4020 PRINT @(1,6),"If you are adding a new application, refer to the Installat
4020:ion Section of the",
4030 PRINT @(1,7),"appropriate ADD+ON User Guide for guidance in initializing 
4030:any new parameters,",
4040 PRINT @(1,8),"control fields or data files.",
4050 PRINT @(1,10),"If you are upgrading an existing system, please continue t
4050:o follow the upgrade",
4060 PRINT @(1,11),"instructions contained in the Release Notes. Be sure to re
4060:view menu, parameter",
4070 PRINT @(1,12),"and control information for accuracy before using any appl
4070:ication.",
4080 PRINT @(1,14),"If you are installing an SCN release, be sure to check the
4080: accompanying SCN",
4090 PRINT @(1,15),"Release Notes for any special instructions regarding the m
4090:aintenance release.",
4100 GOSUB 6900
4110 PRINT @(0,6),'CE',@(5,6),"For new applications and upgrades to existing s
4110:ystems be sure to:",
4120 PRINT @(5,8),"1) Run System Description Maintenance (to verify data paths
4120:).",
4130 PRINT @(5,9),"2) Run the File Mapping Utility (to create new data files).
4130:",
4140 PRINT @(5,10),"3) If this upgrade includes SpeedShip, follow the instruct
4140:ions in",
4150 PRINT @(5,11),"   the Dealer Manual to complete the installation of Speed
4150:Ship.",
4160 CALL "SYC.WC",0,0,65,4,5,13,0
4170 PRINT @(32,13)," WARNING "
4180 PRINT @(7,14),"Do NOT use the ADD+ON File Mapping Utility to re-map exist
4180:ing",
4190 PRINT @(7,15),"data files. The data in these files will be erased.",
4200 GOSUB 6900
4900 REM " --- Return to menu"
4990 GOTO 9900
6100 REM " --- Reset Version Number for SCN Releases"
6110 CALL "SYC.VS",ERR=6200,SCN_VER$
6120 FOR X=1 TO MODULES
6130 FIND (SYM04_DEV,KEY=MODULES$[X,1],ERR=6160)IOL=SYM04A
6140 IF X1$(39,1)="Y" AND X1$(40,POS("."=X1$(40,6),-1))=SCN_VER$(1,POS("."=SCN
6140:_VER$,-1)) THEN LET X1$(40,6)=SCN_VER$
6150 WRITE (SYM04_DEV,KEY=X0$)IOL=SYM04A
6160 NEXT X
6170 ERASE "SYC.VS",ERR=6190
6180 GOTO 6170
6190 LET SYS_VER$=SCN_VER$
6200 LET X$=STBL("!VERSION",SYS_VER$)
6290 RETURN
6900 REM " --- Proceed or quit?"
6910 PRINT @(0,22),'CL',@(14,22),"Press <Enter> to continue or <F4> to exit:",
6910:'CI',
6920 LET V0$="S",V1$="C",V2$="",V3$="",V4$="",V0=1,V1=57,V2=22
6930 GOSUB 7000
6940 ON V3 GOTO 6950,6900,6900,6900,9900
6990 RETURN
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
9400 REM " --- Missing SYS.ZA"
9410 PRINT @(0,3),'CE',@(0,4),"ERROR: Unable to locate and/or run the ADD+ON C
9410:opyright Program (SYS.ZA)"
9490 GOTO 9800
9500 REM " --- Rename problem"
9510 PRINT @(0,3),'CE',@(0,4),"ERROR: Unable to rename ","Z"+FILENAME$," to ",
9510:FILENAME$
9590 GOTO 9800
9600 REM " --- Missing Administrator Module"
9610 PRINT @(0,3),'CE',@(1,4),"ERROR: The ADD+ON Administrator Module (Version
9610: 6.0.0 or greater) is required"
9620 PRINT @(1,5),"       to run these applications."
9690 GOTO 9800
9700 REM " --- Missing distribution file(s)"
9710 PRINT @(0,3),'CE',@(1,4),"ERROR: Unable to locate or open installation da
9710:ta file (ZFILES or _FILES)"
9740 GOTO 9800
9750 REM " --- Missing SYS-01"
9760 PRINT @(0,3),'CE',@(1,4),"ERROR: Unable to locate or open ADD+ON System C
9760:ontrol File (SYS-01)"
9800 REM " --- Distribution installation and/or rename problem"
9810 CALL "SYC.WC",ERR=9820,0,0,80,7,0,12,0
9820 PRINT @(2,13),"If you are installing ADD+ON Software:"
9825 PRINT @(2,14),"Reload the Administrator media and try the installation pr
9825:ocedure again."
9830 PRINT @(2,16),"If problems persist:"
9835 PRINT @(2,17),"Call ADD+ON Software Support at (800) 275-6350"
9840 GOSUB 6900
9900 REM " --- Return to menu"
9950 RUN "SYS.AA"
9999 END
