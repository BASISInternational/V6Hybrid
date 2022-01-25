[[OPX_LINETAXSVC.ADIS]]
rem --- Show TAX_SVC_CD description
	salesTax!=callpoint!.getDevObject("salesTax")
	if salesTax!<>null() then
		taxSvcCd$=cvs(callpoint!.getColumnData("OPX_LINETAXSVC.TAX_SVC_CD"),2)
		if taxSvcCd$<>"" then
			success=0
			desc$=salesTax!.getTaxSvcCdDesc(taxSvcCd$,err=*next); success=1
			if success then
				if desc$<>"" then
					rem --- Good code entered
					callpoint!.setColumnData("<<DISPLAY>>.TAX_SVC_DESC",desc$,1)
				else
					rem --- Bad code entered
					msg_id$="OP_BAD_TAXSVC_CD"
					dim msg_tokens$[1]
					msg_tokens$[1]=taxSvcCd$
					gosub disp_message

					callpoint!.setColumnData("<<DISPLAY>>.TAX_SVC_DESC","",1)
				endif
			else
				rem --- AvaTax call error
				callpoint!.setColumnData("<<DISPLAY>>.TAX_SVC_DESC","connect error",1)
			endif
		else
			rem --- No code entered, so clear description.
			callpoint!.setColumnData("<<DISPLAY>>.TAX_SVC_DESC","",1)
		endif
	endif

[[OPX_LINETAXSVC.AREC]]
rem --- Clear TAX_SVC_CD description
	salesTax!=callpoint!.getDevObject("salesTax")
	if salesTax!<>null() then
		callpoint!.setColumnData("<<DISPLAY>>.TAX_SVC_DESC","",1)
	endif

[[OPX_LINETAXSVC.ASHO]]
	callpoint!.setDevObject("salesTax",null())
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
			rem --- Get connection to Sales Tax Service
			salesTax!=new AvaTaxInterface(firm_id$)
			if salesTax!.connectClient(Form!,err=connectErr) then
				msg_id$=""
				callpoint!.setDevObject("salesTax",salesTax!)
			else
				callpoint!.setStatus("EXIT")
				salesTax!.close()
			endif
		endif
	endif

	if msg_id$<>""
		gosub disp_message
		callpoint!.setStatus("EXIT")
	endif
	break

connectErr:
	if salesTax!<>null() then salesTax!.close()
	callpoint!.setStatus("EXIT")

	break

[[OPX_LINETAXSVC.BEND]]
rem --- Close connection to Sales Tax Service
	salesTax!=callpoint!.getDevObject("salesTax")
	if salesTax!<>null() then
		salesTax!.close()
	endif

[[OPX_LINETAXSVC.BSHO]]
rem --- Inits

use ::ado_util.src::util
use ::opo_AvaTaxInterface.aon::AvaTaxInterface

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

[[OPX_LINETAXSVC.TAX_SVC_CD.AVAL]]
rem --- Validate TAX_SVC_CD
	taxSvcCd$=cvs(callpoint!.getUserInput(),2)
		if taxSvcCd$<>"" then
			salesTax!=callpoint!.getDevObject("salesTax")
			success=0
			desc$=salesTax!.getTaxSvcCdDesc(taxSvcCd$,err=*next); success=1
			if success then
				if desc$<>"" then
					rem --- Good code entered
					callpoint!.setColumnData("<<DISPLAY>>.TAX_SVC_DESC",desc$,1)
				else
					rem --- Bad code entered
					msg_id$="OP_BAD_TAXSVC_CD"
					dim msg_tokens$[1]
					msg_tokens$[1]=taxSvcCd$
					gosub disp_message

					callpoint!.setColumnData("OPX_LINETAXSVC.TAX_SVC_CD","",1)
					callpoint!.setStatus("ABORT")
					break
				endif
			else
				rem --- AvaTax call error
				callpoint!.setColumnData("OPX_LINETAXSVC.TAX_SVC_CD","connect error",1)
				callpoint!.setStatus("ABORT")
				break
			endif
		else
			rem --- No code entered, so clear description.
			callpoint!.setColumnData("<<DISPLAY>>.TAX_SVC_DESC","",1)
		endif

[[OPX_LINETAXSVC.<CUSTOM>]]
#include [+ADDON_LIB]std_missing_params.aon



