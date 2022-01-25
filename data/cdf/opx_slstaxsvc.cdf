[[OPX_SLSTAXSVC.ARER]]
rem --- Get fields from ops_params

	ops_params=fnget_dev("OPS_PARAMS")
	dim ops_params$:fnget_tpl$("OPS_PARAMS")

	readrecord(ops_params,key=firm_id$+"AR00",err=std_missing_params)ops_params$
	callpoint!.setColumnData("OPX_SLSTAXSVC.SLS_TAX_INTRFACE",ops_params.sls_tax_intrface$,1)
	callpoint!.setColumnData("OPX_SLSTAXSVC.TAX_SVC_CD_SRC",ops_params.tax_svc_cd_src$,1)

[[OPX_SLSTAXSVC.ASVA]]
rem --- Write the fields to ops_params

	ops_params=fnget_dev("OPS_PARAMS")
	dim ops_params$:fnget_tpl$("OPS_PARAMS")

	extractrecord(ops_params,key=firm_id$+"AR00",dom=std_missing_params)ops_params$
	ops_params.sls_tax_intrface$=callpoint!.getColumnData("OPX_SLSTAXSVC.SLS_TAX_INTRFACE")
	ops_params.tax_svc_cd_src$=callpoint!.getColumnData("OPX_SLSTAXSVC.TAX_SVC_CD_SRC")
	writerecord(ops_params)ops_params$

[[OPX_SLSTAXSVC.BSHO]]
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

if op$<>"Y" or status$<>"" then
	remove_process_bar:
	bbjAPI!=bbjAPI()
	rdFuncSpace!=bbjAPI!.getGroupNamespace()
	rdFuncSpace!.setValue("+build_task","OFF")
	release
endif

[[OPX_SLSTAXSVC.<CUSTOM>]]
#include [+ADDON_LIB]std_missing_params.aon



