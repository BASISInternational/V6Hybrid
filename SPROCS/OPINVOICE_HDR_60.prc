rem ----------------------------------------------------------------------------
rem --- OP Invoice Printing
rem --- Program: OPINVOICE_HDR.prc 

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
    tfl$="C:/temp_downloads/sproctraceOPHDR.txt"
    erase tfl$,err=*next
    string tfl$
    tfl=unt
    open(tfl)tfl$
    settrace(tfl,MODE="UNTIMED")
skip_trace:

seterr sproc_error

declare BBjStoredProcedureData sp!
declare BBjRecordSet rs!
declare BBjRecordData data!

rem --- Get the infomation object for the Stored Procedure
sp! = BBjAPI().getFileSystem().getStoredProcedureData()

rem --- get SPROC parameters

firm_id$ =     sp!.getParameter("FIRM_ID")
ar_type$ =     sp!.getParameter("AR_TYPE")
customer_id$ = sp!.getParameter("CUSTOMER_ID")
order_no$ =    sp!.getParameter("ORDER_NO")
ar_inv_no$ =   sp!.getParameter("AR_INV_NO")
cust_mask$ =   sp!.getParameter("CUST_MASK")
cust_size = num(sp!.getParameter("CUST_SIZE"))
barista_wd$ =  sp!.getParameter("BARISTA_WD")

chdir barista_wd$

rem --- create the in memory recordset for return

dataTemplate$ = ""
dataTemplate$ = dataTemplate$ + "invoice_no:C(7),invoice_date:C(10),order_date:C(10),"
datatemplate$ = datatemplate$ + "bill_addr_line1:C(30),bill_addr_line2:C(30),bill_addr_line3:C(30),"
datatemplate$ = datatemplate$ + "bill_addr_line4:C(30),bill_addr_line5:C(30),bill_addr_line6:C(30),"
datatemplate$ = datatemplate$ + "bill_addr_line7:C(30),"
datatemplate$ = datatemplate$ + "ship_addr_line1:C(30),ship_addr_line2:C(30),ship_addr_line3:C(30),"
datatemplate$ = datatemplate$ + "ship_addr_line4:C(30),ship_addr_line5:C(30),ship_addr_line6:C(30),"
datatemplate$ = datatemplate$ + "ship_addr_line7:C(30),"
dataTemplate$ = dataTemplate$ + "salesrep_code:C(3),salesrep_desc:C(20),cust_po_num:C(20),ship_via:C(10),"
dataTemplate$ = dataTemplate$ + "fob:C(15),ship_date:C(10),terms_code:C(3),terms_desc:C(20),"
datatemplate$ = datatemplate$ + "inv_message_line1:C(40),inv_message_line2:C(40),inv_message_line3:C(40),"
datatemplate$ = datatemplate$ + "inv_message_line4:C(40),inv_message_line5:C(40),inv_message_line6:C(40),"
datatemplate$ = datatemplate$ + "inv_message_line7:C(40),inv_message_line8:C(40),inv_message_line9:C(40),"
datatemplate$ = datatemplate$ + "inv_message_line10:C(40), paid_desc:C(20), paid_text1:C(40), paid_text2:C(40),"
dataTemplate$ = dataTemplate$ + "discount_amt_raw:C(1*),tax_amt_raw:C(1*),freight_amt_raw:C(1*)"

rs! = BBJAPI().createMemoryRecordSet(dataTemplate$)

rem --- Types of calls

    batch_inv  = 2
    
rem --- Use statements and Declares
    
    declare BBjVector custIds!
    declare BBjVector orderNos!

rem --- Retrieve the program path

    pgmdir$=""
    pgmdir$=stbl("+DIR_PGM",err=*next)
    sypdir$=""
    sypdir$=stbl("+DIR_SYP",err=*next)

rem --- Init

    start_block = 1
    nothing_printed = 1	

rem --- Open Files    
rem --- Note 'files' and 'channels[]' are used in close loop, so don't re-use

    files=11,begfile=1,endfile=files
    dim files$[files],options$[files],ids$[files],templates$[files],channels[files]    

    files$[1]="ARM-01", ids$[1]="ARM01";rem arm_custmast
    files$[2]="ARM-02", ids$[2]="ARM02";rem arm_custdet
    files$[3]="ARM-03", ids$[3]="ARM03";rem arm_custship
    files$[4]="ARM-10", ids$[4]="ARM10A";rem arc_termcode
    files$[5]="ARM-10", ids$[5]="ARM10C";rem arc_cashcode
    files$[6]="ARM-10", ids$[6]="ARM10F"; rem arc_salecode
    files$[7]="ARE-03", ids$[7]="ARE03";rem opt_invhdr (ope_ordhdr)
    files$[8]="ARE-04", ids$[8]="ARE04";rem ope_prntlist
    files$[9]="ARE-33", ids$[9]="ARE33";rem opt_invship (ope_ordship)
    files$[10]="ARE-20", ids$[10]="ARE20";rem opt_invcash (ope_invcash)   
    files$[11]="ARM-10", ids$[11]="ARM10G";rem opc_msghdr/det


	call pgmdir$+"adc_fileopen.aon",action,begfile,endfile,files$[all],options$[all],ids$[all],templates$[all],channels[all],batch,status

    if status then
        seterr 0
        x$=stbl("+THROWN_ERR","TRUE")   
        throw "File open error.",1001
    endif
    
	files_opened = files; rem used in loop to close files
	
    arm01_dev = channels[1]
    arm02_dev = channels[2]
    arm03_dev = channels[3]
    arm10a_dev = channels[4]
    arm10c_dev = channels[5]
    arm10f_dev = channels[6]
    are03_dev = channels[7]
    are04_dev = channels[8]
    are33_dev = channels[9]
    are20_dev = channels[10]
    arm10g_dev = channels[11]
    
    
    dim arm01a$:templates$[1]
    dim arm01a1$:templates$[1]
    dim arm02a$:templates$[2]
    dim arm03a$:templates$[3]
    dim arm10a$:templates$[4]
    dim arm10c$:templates$[5]
    dim arm10f$:templates$[6]
    dim are03a$:templates$[7]
    dim are04a$:templates$[8]	
    dim are33a$:templates$[9]
    dim are20a$:templates$[10]
    dim arm10g$:templates$[11]

rem --- open files (V6)

ars01a: iolist x$,x$,x$,p3$

    v6_files=1
    dim files$[v6_files],options$[v6_files],v6_channels[v6_files]
    files$[1]="SYS-01"

    call "SYC.DA",1,1,v6_files,files$[all],options$[all],v6_channels[all],batch,status

    if status then
        seterr 0
        x$=stbl("+THROWN_ERR","TRUE")   
        throw "File open error.",1001
    endif

    sys01_dev=v6_channels[1]
	
rem --- Initialize Data

    dim p3$[113]
    read (sys01_dev,key=firm_id$+"AR00",dom=*next)iol=ars01a
    zip_len=iff(num(p3$(4,1))<>0,num(p3$(4,1)),9)

    dim table_chans$[512,6]

	max_stdMsg_lines = 10
	stdMsg_len = 40
	
	max_billAddr_lines = 7
	bill_addrLine_len = 30
	dim b$(max_billAddr_lines * bill_addrLine_len)
	
	max_custAddr_lines = 7
	cust_addrLine_len = 30	
	dim c$(max_custAddr_lines * cust_addrLine_len)
	
	invoice_date$ = ""
	order_date$ =   ""
	slspsn_code$ =  ""
	slspsn_desc$ =  ""
	cust_po_no$ =   ""
	ship_via$ =     ""
	fob$ =          ""
	ship_date$ =    ""
	terms_code$ =   ""
	terms_desc$ =   ""
	discount_amt$ = ""
    tax_amt$ =      ""
    freight_amt$ =  ""
	
	paid_desc$ =    ""
	paid_text1$ =   ""
	paid_text2$ =   ""
	
rem --- Main Read

    find record (are03_dev, key=firm_id$+ar_type$+customer_id$+order_no$+"000", dom=all_done) are03a$
	
	ar_inv_no$ =    are03a.v6_ar_inv_nbr$
	invoice_date$ = fndate$(fnv6dt$(are03a.v6_invoice_date$))
	order_date$ =   fndate$(fnv6dt$(are03a.v6_order_date$))
	cust_po_no$ =   are03a.v6_cust_po_nbr$
	ship_via$ =     are03a.v6_ar_ship_via$
	ship_date$ =    fndate$(fnv6dt$(are03a.v6_shipmnt_date$))
	discount_amt_raw$ = str(-are03a.v6_discount_amt:amt_mask$)
    tax_amt_raw$ =      str(are03a.v6_tax_amount:amt_mask$)
    freight_amt_raw$ =  str(are03a.v6_freight_amt:amt_mask$)
	discount_amt$ = str(discount_amt_raw:amt_mask$)
    tax_amt$ =      str(tax_amt_raw:amt_mask$)
    freight_amt$ =  str(freight_amt_raw:amt_mask$)

	rem --- Cash Sale?
	
		if are03a.v6_cash_sale$ = "Y" then
			arm10c.v6_code_desc$  = "Invalid Receipt Code"
			arm10c.v6_trans_type$ = "C"

			if are20_dev then
				find record (are20_dev, key=firm_id$+ar_type$+are03a.v6_customer_nbr$+are03a.v6_order_number$, dom=*endif, err=*endif) are20a$; rem z0$, z1$
				find record (arm10c_dev, key=firm_id$+"C"+are20a.v6_cash_rec_cd$, dom=*next) arm10c$; rem y7$, y9$                
			endif
		endif
		
        if are03a.v6_cash_sale$="Y"
		
		    paid_desc$ = cvs(arm10c.v6_code_desc$,2)
			
			if arm10c.v6_trans_type$="P" then
                paid_text1$ = cvs(are20a.v6_payment_id$,3)
                if len(paid_text1$)>4
                    paid_text1$ = "# "+fill(len(paid_text1$)-4,"X") + paid_text1$(len(paid_text1$)-3,4)                    
                else
                    paid_text1$ = "# " + are20a.v6_payment_id$
                endif
			else
				if arm10c.v6_trans_type$="C" then
					paid_text1$ = "# " + are20a.v6_ar_check_nbr$ 
				endif
			endif
			
			paid_text2$ = are20a.v6_cust_name$
		
		endif

    rem --- Heading (bill-to address)

        found = 0
        start_block = 1

        if start_block then
            read record (arm01_dev, key=firm_id$+are03a.v6_customer_nbr$, dom=*endif) arm01a$
            b$ = arm01a.v6_addr_line_1$+arm01a.v6_addr_line_2$+arm01a.v6_addr_line_3$+arm01a.v6_addr_line_4$+arm01a.v6_addr_line_5$+arm01a.v6_zip_code$
            call "SYC.AA",b$,24,5,zip_len,30
            b$ = pad(arm01a.v6_cust_name$ + b$,(max_billAddr_lines * bill_addrLine_len))
            found = 1
        endif

        if !found then
            b$ = pad("Customer not found", bill_addrLine_len*max_billAddr_lines)
        endif
        
    rem --- Ship-To
   
        c$ = b$
        start_block = 1

        if are03a.v6_shipto_nbr$ = "000099" then 
            shipto$ = ""

            if start_block then
                find record (are33_dev, key=firm_id$+are03a.v6_customer_nbr$+are03a.v6_order_number$, dom=*endif) are33a$
                c$ = are33a.v6_addr_line_1$+are33a.v6_addr_line_2$+are33a.v6_addr_line_3$+are33a.v6_zip_code$
                call "SYC.AA",c$,24,3,zip_len,30
                c$ = pad(are33a.v6_name$ + c$, (max_custAddr_lines * cust_addrLine_len))
            endif
        else
            shipto$ = ""

            if start_block then
                find record (arm03_dev,key=firm_id$+are03a.v6_customer_nbr$+are03a.v6_shipto_nbr$, dom=*endif) arm03a$
                c$ = arm03a.v6_addr_line_1$+arm03a.v6_addr_line_2$+arm03a.v6_addr_line_3$+arm03a.v6_zip_code$
                call "SYC.AA",c$,24,3,zip_len,30
                c$ = pad(arm03a.v6_name$ + c$,(max_custAddr_lines * cust_addrLine_len))
                shipto$ = are03a.v6_shipto_no$
            endif
        endif

    rem --- Terms

        dim arm10a$:fattr(arm10a$)
        arm10a.v6_code_desc$ = "Not Found"
        find record (arm10a_dev,key=firm_id$+"A"+are03a.v6_terms_code$,dom=*next) arm10a$

		terms_code$ = are03a.v6_terms_code$
		terms_desc$ = arm10a.v6_code_desc$
		
    rem --- Salesperson

        arm10f.v6_code_desc$ = "Not Found"
        find record (arm10f_dev,key=firm_id$+"F"+are03a.v6_slspsn_code$,dom=*next) arm10f$

		slspsn_code$ = are03a.v6_slspsn_code$
		slspsn_desc$ = arm10f.v6_code_desc$

    rem --- Standard Message
		
		gosub get_stdMessage

    nothing_printed = 0
        
all_done:    rem --- End of invoice -- Send data out

rem --- Format addresses to be bottom justified
	address$=b$
	line_len=bill_addrLine_len
    max_lines=max_billAddr_lines
	gosub format_address
	b$=address$
	
	address$=c$
	line_len=cust_addrLine_len
    max_lines=max_custAddr_lines
	gosub format_address
	c$=address$

		data! = rs!.getEmptyRecordData()
		data!.setFieldValue("INVOICE_NO", ar_inv_no$)
		data!.setFieldValue("INVOICE_DATE", invoice_date$)
		data!.setFieldValue("ORDER_DATE", order_date$)

		data!.setFieldValue("BILL_ADDR_LINE1", b$((bill_addrLine_len*0)+1,bill_addrLine_len))
		data!.setFieldValue("BILL_ADDR_LINE2", b$((bill_addrLine_len*1)+1,bill_addrLine_len))
		data!.setFieldValue("BILL_ADDR_LINE3", b$((bill_addrLine_len*2)+1,bill_addrLine_len))
		data!.setFieldValue("BILL_ADDR_LINE4", b$((bill_addrLine_len*3)+1,bill_addrLine_len))
		data!.setFieldValue("BILL_ADDR_LINE5", b$((bill_addrLine_len*4)+1,bill_addrLine_len))
		data!.setFieldValue("BILL_ADDR_LINE6", b$((bill_addrLine_len*5)+1,bill_addrLine_len))
		data!.setFieldValue("BILL_ADDR_LINE7", b$((bill_addrLine_len*6)+1,bill_addrLine_len))

		data!.setFieldValue("SHIP_ADDR_LINE1", c$((cust_addrLine_len*0)+1,cust_addrLine_len))
		data!.setFieldValue("SHIP_ADDR_LINE2", c$((cust_addrLine_len*1)+1,cust_addrLine_len))
		data!.setFieldValue("SHIP_ADDR_LINE3", c$((cust_addrLine_len*2)+1,cust_addrLine_len))
		data!.setFieldValue("SHIP_ADDR_LINE4", c$((cust_addrLine_len*3)+1,cust_addrLine_len))
		data!.setFieldValue("SHIP_ADDR_LINE5", c$((cust_addrLine_len*4)+1,cust_addrLine_len))
		data!.setFieldValue("SHIP_ADDR_LINE6", c$((cust_addrLine_len*5)+1,cust_addrLine_len))
		data!.setFieldValue("SHIP_ADDR_LINE7", c$((cust_addrLine_len*6)+1,cust_addrLine_len))

		data!.setFieldValue("SALESREP_CODE", slspsn_code$)
		data!.setFieldValue("SALESREP_DESC", slspsn_desc$)
		data!.setFieldValue("CUST_PO_NUM", cust_po_no$)
		data!.setFieldValue("SHIP_VIA", ship_via$)
		data!.setFieldValue("FOB", fob$)
		data!.setFieldValue("SHIP_DATE", ship_date$)
		data!.setFieldValue("TERMS_CODE", terms_code$)
		data!.setFieldValue("TERMS_DESC", terms_desc$)

		data!.setFieldValue("INV_MESSAGE_LINE1", stdMessage$((stdMsg_len*0)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE2", stdMessage$((stdMsg_len*1)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE3", stdMessage$((stdMsg_len*2)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE4", stdMessage$((stdMsg_len*3)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE5", stdMessage$((stdMsg_len*4)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE6", stdMessage$((stdMsg_len*5)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE7", stdMessage$((stdMsg_len*6)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE8", stdMessage$((stdMsg_len*7)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE9", stdMessage$((stdMsg_len*8)+1,stdMsg_len))
		data!.setFieldValue("INV_MESSAGE_LINE10",stdMessage$((stdMsg_len*9)+1,stdMsg_len))
		
		data!.setFieldValue("PAID_DESC", paid_desc$)
		data!.setFieldValue("PAID_TEXT1", paid_text1$)
		data!.setFieldValue("PAID_TEXT2", paid_text2$)

		data!.setFieldValue("DISCOUNT_AMT_RAW", discount_amt_raw$)
		data!.setFieldValue("TAX_AMT_RAW", tax_amt_raw$)
		data!.setFieldValue("FREIGHT_AMT_RAW", freight_amt_raw$)

		rs!.insert(data!)

rem Tell the stored procedure to return the result set.
	sp!.setRecordSet(rs!)
    
	goto std_exit

format_address: rem --- Reformat address to bottom justify

	dim tmp_address$(max_lines*line_len)
	y=(max_lines-1)*line_len+1
	for x=y to 1 step -line_len
		if cvs(address$(x,line_len),2)<>""
			tmp_address$(y,line_len)=address$(x,line_len)
			y=y-line_len
		endif
	next x
	address$=tmp_address$
	return

get_stdMessage: rem --- Get Standard Message lines
	
	rem --- stdMessage$ is a string of standard message details

    for x=1 to 2
        find record (arm10g_dev, key=firm_id$+"G"+are03a.v6_message_code$+str(x), dom=*break) arm10g$
        for y=1 to 5
            stdMessage$ = stdMessage$ + pad(field(arm10g$,"V6_MSG_TEXT_"+str(y:"00")), stdMsg_len)
        next y
    next x

    stdMessage$ = pad(stdMessage$, (max_stdMsg_lines * stdMsg_len))
	
    return

rem --- Functions

rem --- V6demo date functions

    rem --- takes in MM/DD/YY from V6; converts YY to 2-char year (e.g., 16 > B6), then to numeric year (e.g., B6 -> 116), then runs thru date(jul()) to return YYYYMMDD
    def fnv6dt$(wq$)
        wq1$=fnb$(wq$)
        wq1$=date(jul(fnyy_year(fnyear_yy21$(num(wq1$(7,2)))),num(wq1$(1,2)),num(wq1$(4,2))):"%Y%Mz%Dz")
        return wq1$
    fnend
    
    def FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
    def FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
    def FNB6$(Q1$)=Q1$(3,2)+"/"+Q1$(5,2)+"/"+FNYY21_YY$(Q1$(1,2)) 
    def FNC$(Q1$)=FNA$(Q1$(2),Q1$)+FNA$(Q1$(3),Q1$)+FNA$(Q1$(1),Q1$)           
    def FND$(Q$)=CHR(FNYY_YEAR(Q$(5,2))+32)+CHR(NUM(Q$(1,2))+32)+CHR(NUM(Q$(3,2))+32)

    rem --- FNYEAR_YY21$ Convert Numeric Year to 21st Century 2-Char Year"   
    def FNYEAR_YY21$(Q)=FNYY_YY21$(STR(MOD(Q,100):"00"))

    rem --- FNYEAR_YY$ Un-Convert 21st Century Numeric Year to 2-Char Year" 
    def FNYEAR_YY$(Q)=STR(MOD(Q,100):"00") 

    rem --- FNYY_YEAR Convert 2-Char Year to 21st Century Numeric Year"
	def FNYY_YEAR(Q1$)
	Q=NUM(FNYY21_YY$(Q1$)); if Q<50 then Q=Q+100
	return Q
	fnend
    
    rem --- FNYY21_YY$ Un-Convert 21st Century 2-Char Year to 2-Char Year"
	def FNYY21_YY$(Q1$)
	Q3$=" 01234567890123456789",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABCDEFGHIJ"))
	return Q1$
	fnend

    rem --- FNYY_YY21$ Convert 2-Char Year to 21st Century 2-Char Year
	def FNYY_YY21$(Q1$)
	Q3$=" ABCDE56789ABCDEFGHIJ",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABCDEFGHIJ"))
	return Q1$
	fnend

rem --- Date/time handling functions

    def fndate$(q$)
        q1$=""
        q1$=date(jul(num(q$(1,4)),num(q$(5,2)),num(q$(7,2)),err=*next),err=*next)
        if q1$="" q1$=q$
        return q1$
    fnend

rem #include std_end.src

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
        
        close (sys01_dev,err=*next);rem V6demo --- opened using SYC.DA

    end
