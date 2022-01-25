[[OPX_TAXCDSVC.ASHO]]
	msg_id$="GENERIC_OK"
	dim msg_tokens$[1]

	if callpoint!.getDevObject("op")<>"Y" then
		msg_tokens$[1]=Translate!.getTranslation("AON_OP_NOT_INST")
	else
		rem --- Disable TAX_SVC_CD when OP is not using a Sales Tax Service
		ops_params_dev=fnget_dev("OPS_PARAMS")
		dim ops_params$:fnget_tpl$("OPS_PARAMS")
		find record (ops_params_dev,key=firm_id$+"AR00",err=std_missing_params)ops_params$
		if cvs(ops_params.sls_tax_intrface$,2)="" then
			msg_tokens$[1]=Translate!.getTranslation("AON_OP_NOT_USING_TAX_SVC")
		else
			msg_id$=""
		endif
	endif

	if msg_id$<>""
		gosub disp_message
		callpoint!.setStatus("EXIT")
	endif
	break

[[OPX_TAXCDSVC.BSHO]]
rem --- Inits

rem --- Is Sales Order Processing installed?

call dir_pgm1$+"adc_application.aon","OP",info$[all]
op$=info$[20]
callpoint!.setDevObject("op",op$)

rem --- Open/Lock files

files=1,begfile=1,endfile=files
dim files$[files],options$[files],chans$[files],templates$[files]
files$[1]="OPS_PARAMS",options$[1]="OTA"
call dir_pgm$+"bac_open_tables.bbj",begfile,endfile,files$[all],options$[all],
:                                 chans$[all],templates$[all],table_chans$[all],batch,status$

if status$<>"" then
	remove_process_bar:
	bbjAPI!=bbjAPI()
	rdFuncSpace!=bbjAPI!.getGroupNamespace()
	rdFuncSpace!.setValue("+build_task","OFF")
	release
endif

[[OPX_TAXCDSVC.<CUSTOM>]]
#include [+ADDON_LIB]std_missing_params.aon



