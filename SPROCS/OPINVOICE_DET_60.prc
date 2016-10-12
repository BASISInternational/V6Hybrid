rem ----------------------------------------------------------------------------
rem --- OP Invoice Printing
rem --- Program: OPINVOICE_DET.prc
rem --- Description: Stored Procedure to create detail for a jasper-based OP invoice 
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
    tfl$="C:/temp_downloads/sproctrace.txt"
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
	firm_id$ =     sp!.getParameter("FIRM_ID")
	ar_type$ =     sp!.getParameter("AR_TYPE")
	customer_id$ = sp!.getParameter("CUSTOMER_ID")
	order_no$ =    sp!.getParameter("ORDER_NO")
    ar_inv_no$ =   sp!.getParameter("AR_INV_NO")
	qty_mask$ =    sp!.getParameter("QTY_MASK")
	amt_mask$ =    sp!.getParameter("AMT_MASK")
	price_mask$ =  sp!.getParameter("PRICE_MASK")
	ext_mask$ =    sp!.getParameter("EXT_MASK")
	barista_wd$ =  sp!.getParameter("BARISTA_WD")

	chdir barista_wd$

rem --- create the in memory recordset for return
	dataTemplate$ = ""
	dataTemplate$ = dataTemplate$ + "order_qty_masked:c(1*), ship_qty_masked:c(1*), backord_qty_masked:c(1*), "
	dataTemplate$ = dataTemplate$ + "item_id:c(1*), item_desc:c(1*), um:c(1*), "
	dataTemplate$ = dataTemplate$ + "price_raw:c(1*), price_masked:c(1*), "
	dataTemplate$ = dataTemplate$ + "extended_raw:c(1*), extended_masked:c(1*), internal_seq_no:c(1*), "
	dataTemplate$ = dataTemplate$ + "item_is_ls:c(1), linetype_allows_ls:c(1),ship_qty:c(1*)"

	rs! = BBJAPI().createMemoryRecordSet(dataTemplate$)
	
rem --- Initializationas
	
rem --- Open Files    
rem --- Note 'files' and 'channels[]' are used in close loop, so don't re-use

    files=2,begfile=1,endfile=files
    dim files$[files],options$[files],ids$[files],templates$[files],channels[files]    

    files$[1]="ARE-13",      ids$[1]="ARE13";rem opt_invdet (ope_orddet)
    files$[2]="ARM-10",      ids$[2]="ARM10E";rem opc_linecode

	call pgmdir$+"adc_fileopen.aon",action,begfile,endfile,files$[all],options$[all],ids$[all],templates$[all],channels[all],batch,status

    if status then
        seterr 0
        x$=stbl("+THROWN_ERR","TRUE")   
        throw "File open error.",1001
    endif
    
	files_opened = files; rem used in loop to close files

    are13_dev   = channels[1]
    arm10e_dev   = channels[2]
    
    dim are13a$:templates$[1]
    dim arm10e$:templates$[2]

rem --- open files (V6)

ivm01a: iolist *,x2$,x9$(1)

    v6_files=1
    dim files$[v6_files],options$[v6_files],v6_channels[v6_files]
    files$[1]="IVM-01"

    call "SYC.DA",1,1,v6_files,files$[all],options$[all],v6_channels[all],batch,status

    if status then
        seterr 0
        x$=stbl("+THROWN_ERR","TRUE")   
        throw "File open error.",1001
    endif

    ivm01_dev=v6_channels[1]
	
rem --- Main

    read (are13_dev, key=firm_id$+ar_type$+customer_id$+order_no$, dom=*next)
	
    rem --- Detail lines

        while 1
				
			order_qty_masked$ =   ""
			ship_qty_masked$ =    ""
			ship_qty$ =           ""
			backord_qty_masked$ = ""
			item_id$ =            ""
			item_desc$ =          ""
			lotser_no$ =          ""
			um$ =                 ""
			price_raw$ =          ""
			price_masked$ =       ""
			ext_raw$ =            ""
			ext_masked$ =         ""
			internal_seq_no$ =    ""
			linetype_allows_ls$ = "N"
			item_is_ls$ =         "N"	
			
            read record (are13_dev, end=*break) are13a$

            if firm_id$     <> are13a.v6_firm_id$     then break
			if ar_type$     <> are13a.v6_ar_type$     then break
            if customer_id$ <> are13a.v6_customer_nbr$ then break
            if order_no$    <> are13a.v6_order_number$    then break

			internal_seq_no$ = are13a.v6_line_number$
			
        rem --- Type
		
            dim arm10e$:fattr(arm10e$)
            dim x2$(60),x9$(62)
            item_description$ = "Item not found"
            start_block = 1
			
            if start_block then
                find record (arm10e_dev, key=firm_id$+"E"+are13a.v6_line_code$, dom=*endif) arm10e$
                x2$ = are13a.v6_item_number$
            endif

            if pos(arm10e.v6_line_type$=" SP") then
				linetype_allows_ls$ = "Y"
                find (ivm01_dev, key=firm_id$+are13a.v6_item_number$, dom=*next)iol=ivm01a
                item_description$ = x2$
				item_is_ls$ = x9$(19,1)
			endif

            if arm10e.v6_line_type$="M" and pos(arm10e.v6_message_type$="BI ")=0 then continue

line_detail: rem --- Item Detail

			if pos(arm10e.v6_line_type$="MO")=0 then
				order_qty_masked$= str(are13a.v6_qty_ordered:qty_mask$)
				ship_qty_masked$= str(are13a.v6_qty_shipped:qty_mask$)
				ship_qty$= str(are13a.v6_qty_shipped)
				backord_qty_masked$= str(are13a.v6_qty_backord:qty_mask$)
			endif

			if pos(arm10e.v6_line_type$="MNO") then
				item_id$= are13a.v6_order_memo$
			endif

			if pos(arm10e.v6_line_type$=" SRDP") then 
				item_id$= are13a.v6_item_number$
			endif

			if pos(arm10e.v6_line_type$=" SRDNP") then 
				price_raw$=   str(are13a.v6_unit_price)
				price_masked$=str(are13a.v6_unit_price:price_mask$)
			endif

			if arm10e.v6_line_type$<>"M" then 
				ext_raw$=   str(are13a.v6_ext_price)
				ext_masked$=str(are13a.v6_ext_price:ext_mask$)
			endif

			if arm10e.v6_line_type$="S" then 
				um$= x9$(4,2)
			endif

			if pos(arm10e.v6_line_type$="SP") then
				item_desc$= item_description$
			endif

			data! = rs!.getEmptyRecordData()
			data!.setFieldValue("ORDER_QTY_MASKED", order_qty_masked$)
			data!.setFieldValue("SHIP_QTY_MASKED", ship_qty_masked$)
			data!.setFieldValue("SHIP_QTY", ship_qty$)
			data!.setFieldValue("BACKORD_QTY_MASKED", backord_qty_masked$)
			data!.setFieldValue("ITEM_ID", item_id$)
			data!.setFieldValue("ITEM_DESC", item_desc$)
			data!.setFieldValue("UM", um$)
			data!.setFieldValue("PRICE_RAW", price_raw$)
			data!.setFieldValue("PRICE_MASKED", price_masked$)
			data!.setFieldValue("EXTENDED_RAW", ext_raw$)
			data!.setFieldValue("EXTENDED_MASKED", ext_masked$)
			data!.setFieldValue("INTERNAL_SEQ_NO",internal_seq_no$)
			data!.setFieldValue("ITEM_IS_LS",item_is_ls$)
			data!.setFieldValue("LINETYPE_ALLOWS_LS",linetype_allows_ls$)

			rs!.insert(data!)		

        rem --- End of detail lines

        wend

rem --- Tell the stored procedure to return the result set.

	sp!.setRecordSet(rs!)

	goto std_exit

	
sproc_error:rem --- SPROC error trap/handler
    rd_err_text$="", err_num=err
    if tcb(2)=0 and tcb(5) then rd_err_text$=pgm(tcb(5),tcb(13),err=*next)
    x$=stbl("+THROWN_ERR","TRUE")   
    throw "["+pgm(-2)+"] "+str(tcb(5))+": "+rd_err_text$,err_num
    
std_exit:

	rem --- Close files
		x = files_opened
		while x>=1
			close (channels[x],err=*next)
			x=x-1
		wend
        
        close (ivm01_dev,err=*next);rem V6demo --- opened using SYC.DA

    end
