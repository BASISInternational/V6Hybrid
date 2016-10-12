rem ----------------------------------------------------------------------------
rem --- OP Invoice Printing
rem --- Program: OPINVOICE_DET_LOTSER.prc
rem --- Description: Stored Procedure to create Lot/Serial detail for a jasper-based OP invoice 
rem 
rem --- AddonSoftware
rem --- Copyright BASIS International Ltd.  All Rights Reserved.
rem --- All Rights Reserved

rem --- There are three sprocs and three .jaspers for this enhancement:
rem ---    - OPINVOICE_HDR.prc / OPInvoiceHdr.jasper
rem ---    - OPINVOICE_DET.prc / OPInvoiceDet.jasper
rem ---    - OPINVOICE_DET_LOTSER.prc / OPInvoiceDet-LotSer.jasper
rem ----------------------------------------------------------------------------

rem --- V6Demo --- altered for batch invoices to run against V6 database
rem --- Uses altered versions of the above SPROCs: 
rem ---    OPINVOICE_HDR_60.PRC
rem ---    OPINVOICE_DET_60.PRC
rem ---    OPINVOICE_DET_LOTSER_60.PRC

rem ----------------------------------------------------------------------------
    rem ' trace
    goto skip_trace;rem this out to do the trace
    tfl$="C:/temp_downloads/sproctrace"+str(int(tim*1000000))+".txt"
    erase tfl$,err=*next
    string tfl$
    tfl=unt
    open(tfl)tfl$
    settrace(tfl,MODE="UNTIMED")
skip_trace:

	seterr sproc_error

rem --- Use statements and Declares

	declare BBjStoredProcedureData sp!
	declare BBjRecordSet rs!
	declare BBjRecordData data!

	use ::ado_func.src::func

rem --- Get the infomation object for the Stored Procedure

	sp! = BBjAPI().getFileSystem().getStoredProcedureData()


rem --- Get 'IN' SPROC parameters 
	firm_id$ = sp!.getParameter("FIRM_ID")
	ar_type$ = sp!.getParameter("AR_TYPE")
	customer_id$ = sp!.getParameter("CUSTOMER_ID")
	order_no$ = sp!.getParameter("ORDER_NO")
    ar_inv_no$ = sp!.getParameter("AR_INV_NO")
	are13_line_no$ = sp!.getParameter("INTERNAL_SEQ_NO")
	are13_qty_shipped =  num(sp!.getParameter("OPE11_QTY_SHIPPED")); rem To conditionally print writein lines for missing Lot/Serial shipped qtys
	qty_mask$ = sp!.getParameter("QTY_MASK")
	lotser_flag$ = sp!.getParameter("IVS_LOTSER_FLAG")
	barista_wd$ = sp!.getParameter("BARISTA_WD")

	chdir barista_wd$

rem --- Get Barista System Program directory

	sypdir$=""
	sypdir$=stbl("+DIR_SYP",err=*next)
	
	pgmdir$=stbl("+DIR_PGM",err=*next)

rem --- create the in memory recordset for return

	dataTemplate$ = ""
	dataTemplate$ = dataTemplate$ + "lotser_no:c(1*), qty_shipped_raw:c(1*)" 
	
	rs! = BBJAPI().createMemoryRecordSet(dataTemplate$)
	
rem --- Initializationas

	total_lotser_qty_shipped = 0

rem --- Get any associated Lots/SerialNumbers

	sqlprep$=""
	sqlprep$=sqlprep$+"SELECT V6_LOTSER_NBR, V6_QTY_SHIPPED"
	sqlprep$=sqlprep$+" FROM ARE23"
	sqlprep$=sqlprep$+" WHERE v6_firm_id="       +"'"+ firm_id$+"'"
	sqlprep$=sqlprep$+"   AND v6_ar_type="       +"'"+ ar_type$+"'"
	sqlprep$=sqlprep$+"   AND v6_customer_nbr="   +"'"+ customer_id$+"'"
	sqlprep$=sqlprep$+"   AND v6_order_number="      +"'"+ order_no$+"'"
	sqlprep$=sqlprep$+"   AND v6_line_number="+"'"+ are13_line_no$+"'"

	sql_chan=sqlunt
	sqlopen(sql_chan,mode="PROCEDURE",err=*next)stbl("+DBNAME")
	sqlprep(sql_chan)sqlprep$
	dim read_tpl$:sqltmpl(sql_chan)
	sqlexec(sql_chan)

rem --- Process through SQL results 

	while 1

		read_tpl$ = sqlfetch(sql_chan,end=*break)
		
		data! = rs!.getEmptyRecordData()
		
		ls_qty_shipped = num (read_tpl.v6_qty_shipped$)
		
		data!.setFieldValue("LOTSER_NO", read_tpl.v6_lotser_nbr$)
		data!.setFieldValue("QTY_SHIPPED_RAW", str(ls_qty_shipped))

		rs!.insert(data!)
		
		total_lotser_qty_shipped = total_lotser_qty_shipped + ls_qty_shipped
	wend
	
	rem --- Compare LS shipped qty with Item's Shipped Qty
	rem --- If they do not match, send underscores to 
	rem --- prompt for L/S entry/write-in on the invoice.

	if total_lotser_qty_shipped <> are13_qty_shipped
	
		for y=1 to max(abs(are13_qty_shipped - total_lotser_qty_shipped),1)
			data! = rs!.getEmptyRecordData()
			
			data!.setFieldValue("LOTSER_NO", FILL(20,"_"))				
			data!.setFieldValue("QTY_SHIPPED_RAW", "0")

			rs!.insert(data!)
			
			if lotser_flag$="L" then break
		next y

	endif

rem --- Tell the stored procedure to return the result set.
	sp!.setRecordSet(rs!)

	goto std_exit

	
sproc_error:rem --- SPROC error trap/handler
    rd_err_text$="", err_num=err
    if tcb(2)=0 and tcb(5) then rd_err_text$=pgm(tcb(5),tcb(13),err=*next)
    x$=stbl("+THROWN_ERR","TRUE")   
    throw "["+pgm(-2)+"] "+str(tcb(5))+": "+rd_err_text$,err_num
    
std_exit:

    sqlclose (sql_chan,err=*next)

    end
