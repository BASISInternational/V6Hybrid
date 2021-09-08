[[ADX_V6DEMOYEAR.AREC]]
rem -- show current fiscal year

cur_fiscal_yr$=callpoint!.getDevObject("cur_fiscal_yr")
callpoint!.setColumnData("ADX_V6DEMOYEAR.CURRENT_YEAR",fnyy21_yy$(cur_fiscal_yr$))

[[ADX_V6DEMOYEAR.ASHO]]
rem --- verify working with demo data, not production data

msg_id$="DEMO_DATA_ONLY"
gosub disp_message
if msg_opt$="C"
	rem --- remove process bar:
	bbjAPI!=bbjAPI()
	rdFuncSpace!=bbjAPI!.getGroupNamespace()
	rdFuncSpace!.setValue("+build_task","OFF")
	release
endif

[[ADX_V6DEMOYEAR.BSHO]]
rem --- open SYS-01 to get GL params (current fiscal per/yr)


GLS01A: IOLIST A0$,A1$,A2$(1)

	dim A2$(10)
	files=1
	begfile=files,endfile=files,action=1
	dim files$[files],options$[files],channels[files]
	files$[1]="SYS-01"
	call "SYC.DA",action,begfile,endfile,files$[all],options$[all],channels[all],batch,status
	if status then escape 
	cal_dev=channels[1]

	find (cal_dev,key=firm_id$+"GL00",err=std_missing_params)IOL=GLS01A

	callpoint!.setDevObject("cur_fiscal_yr",A2$(5,2))
	close(cal_dev,err=*next)

[[ADX_V6DEMOYEAR.<CUSTOM>]]
#include std_missing_params.src

REM " --- FNYY_YY21$ Convert 2-Char Year to 21st Century 2-Char Year"
	DEF FNYY_YY21$(Q1$)                                                       
	LET Q3$=" ABCDE56789ABCDEFGHIJ",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABCDEFGHIJ"))                                                                
	RETURN Q1$                                                                
	FNEND                                                                     

REM " --- FNYY21_YY$ Un-Convert 21st Century 2-Char Year to 2-Char Year"  
	DEF FNYY21_YY$(Q1$)                                                       
	LET Q3$=" 01234567890123456789",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABCDEFGHIJ"))                                                                
	RETURN Q1$                                                                
	FNEND                                                                     

REM " --- FNYY_YEAR Convert 2-Char Year to 21st Century Numeric Year"     
	DEF FNYY_YEAR(Q1$)                                                        
	LET Q=NUM(FNYY21_YY$(Q1$)); IF Q<50 THEN LET Q=Q+100                      
	RETURN Q                                                                  
	FNEND

REM " --- FNYEAR_YY21$ Convert Numeric Year to 21st Century 2-Char Year"
	DEF FNYEAR_YY21$(Q)=FNYY_YY21$(STR(MOD(Q,100):"00"))                                                                     



