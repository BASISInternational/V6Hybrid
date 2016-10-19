rem ' ****************************************************
rem ' * SPROC to drive customer statements
rem ' ****************************************************
rem ' program name: custStatements.prc

seterr sproc_error

rem ' ****************************************************
rem ' * declares
rem ' ****************************************************
declare BBjStoredProcedureData sp!
declare BBjRecordSet rs!
declare BBjRecordData data!

rem ' ****************************************************
rem ' * get SPROC parameters
rem ' ****************************************************
sp! = BBjAPI().getFileSystem().getStoredProcedureData()

rem ' looks like '01' or '02'
firm_id$ = sp!.getParameter("FIRM_ID")

rem ' in the form of YYYYMMDD
statement_date$ = sp!.getParameter("STATEMENT_DATE")

rem ' customer numbers maybe any length up to 6
customer$ = sp!.getParameter("CUSTOMER_ID")
while len(customer$) < 6
	customer$ = "0" + customer$
wend

barista_wd$ = sp!.getParameter("BARISTA_WD")
chdir barista_wd$

rem 'set up trace if desired
    goto trace_end;rem to enable trace
    tfl$="C:/temp_downloads/stmtTraceSPROC.txt"
    erase tfl$,err=*next
    string tfl$
    tchan=unt
    open(tchan)tfl$
    settrace (tchan,MODE="UNTIMED")

trace_end:

rem ' ****************************************************
rem ' * create the in memory recordset for return
rem ' ****************************************************
dataTemplate$ = "firm_id:C(2),statement_date:C(10),customer_nbr:C(6),cust_name:C(30),address1:C(30),address2:C(30),"
dataTemplate$ = dataTemplate$ + "address3:C(30),address4:C(30),address5:C(30), address6:C(30),"
dataTemplate$ = dataTemplate$ + "invoice_date:C(10),ar_inv_nbr:C(7),po_number:C(10),currency:C(3),invoice_amt:N(10),trans_amt:N(10),"
dataTemplate$ = DataTemplate$ + "invBalance:N(10),aging_cur:N(10),aging_30:N(10),aging_60:N(10),aging_90:N(10),aging_120:N(10)"
rs! = BBJAPI().createMemoryRecordSet(dataTemplate$)

rem ' ****************************************************
rem ' * open files
rem ' ****************************************************
files=4
dim files$[files],options$[files],channels[files]
files$[1]="ARM-01",files$[2]="ARM-02"
files$[3]="ART-01",files$[4]="ART-11"

call "SYC.DA",1,1,files,files$[all],options$[all],channels[all],batch,status

if status>0 then goto close_and_exit

arm01=channels[1],arm02=channels[2],art01=channels[3],art11=channels[4]

rem ' ****************************************************
rem ' * initialize; position file pointer
rem ' ****************************************************

gosub build_list_of_aging_dates
gosub lookup_customer_address
gosub determine_customer_aging

read (art01, key = firm_id$ + "  " + customer$, dom=*next)

rem ' ****************************************************
rem ' * main loop
rem ' ****************************************************

while 1

	currency$ = ""
	AO$="";DIM A[1]
	read (art01,end=*break)IOL=ART01A; REM A0$,A[ALL]

	if A0$(1,2) <> firm_id$ then break
	if A0$(5,6) <> customer$ then break

    invoice_date$=FNC$(A0$(24,3))
	if invoice_date$ > statement_date$ then continue

	rem ' ****************************************************
	rem ' * calc invoice balance
	rem ' ****************************************************

	read (art11, key=A0$(1,2) + A0$(3,2) + A0$(5,6) + A0$(11,7), dom=*next)
	trans_amt = 0
	while 1
        W0$="",W1$="";DIM W[1]
		read (art11,end=*break)IOL=ART11A; REM W0$,W1$,W[ALL]
		if A0$(1,2) + A0$(3,2) + A0$(5,6) + A0$(11,7) <> W0$(1,2) + W0$(3,2) + W0$(5,6) + W0$(11,7) then break
		trans_date$=FNC$(W1$(2,3))
		if trans_date$ <= statement_date$ then trans_amt = trans_amt + W[0] + W[1]
	wend

	invBalance = A[0] + trans_amt

	if invBalance = 0 then continue

	rem ' ****************************************************
	rem ' * output data
	rem ' ****************************************************
	data! = rs!.getEmptyRecordData()
	data!.setFieldValue("FIRM_ID",firm_id$)
	data!.setFieldValue("STATEMENT_DATE",statement_date$(3,2) + "/" + statement_date$(5,2) + "/" + statement_date$(1,2))
	data!.setFieldValue("CUSTOMER_NBR",customer$)
	data!.setFieldValue("CUST_NAME",B1$(1,30))
	data!.setFieldValue("ADDRESS1", address$(1,30))
	data!.setFieldValue("ADDRESS2", address$(31,30))
	data!.setFieldValue("ADDRESS3", address$(61,30))
	data!.setFieldValue("ADDRESS4", address$(91,30))
	data!.setFieldValue("ADDRESS5", address$(121,30))
	data!.setFieldValue("ADDRESS6", address$(151,30))
	invoice_date$ = invoice_date$(3,2) + "/" + invoice_date$(5,2) + "/" + invoice_date$(1,2)
	data!.setFieldValue("INVOICE_DATE",invoice_date$)
	data!.setFieldValue("AR_INV_NBR",A0$(11,7))
	data!.setFieldValue("PO_NUMBER",PO_NUMBER$)
	data!.setFieldValue("CURRENCY",currency$)
	data!.setFieldValue("INVOICE_AMT",str(A[0]))
	data!.setFieldValue("TRANS_AMT",str(trans_amt))
	data!.setFieldValue("INVBALANCE",str(invBalance))
	data!.setFieldValue("AGING_CUR",str(aging_cur))
	data!.setFieldValue("AGING_30",str(aging_30))
	data!.setFieldValue("AGING_60",str(aging_60))
	data!.setFieldValue("AGING_90",str(aging_90))
	data!.setFieldValue("AGING_120",str(aging_120))
	rs!.insert(data!)
wend

close_and_exit:
rem ' close files
close(arm01)
close(arm02)
close(art01)
close(art11)

sp!.setRecordSet(rs!)
end

rem ' ****************************************************
rem ' * look up customer address
rem ' ****************************************************
lookup_customer_address:

	rem ' get the customer name
    B0$="",B1$=""
	read (arm01,key=firm_id$ + customer$)IOL=ARM01A
    address$=B1$(31,72)+B1$(179,48)+B1$(103,9)+B1$(265,24)
    call "SYC.AA",address$,24,5,9,30

return

rem ' ****************************************************
rem ' * determine customer aging
rem ' ****************************************************
determine_customer_aging:

	rem ' read the customer aging record
    C0$="",C1$="";DIM C[10]
	read (arm02,key=firm_id$ + customer$ + "  ")IOL=ARM02A

	dim c[5]

	read (art01, key = firm_id$ + "  " + customer$, dom=*next)


	rem ' --- Invoice Records
	while 1
        A0$="";DIM A[1]
		read (art01, end = *break)IOL=ART01A; REM A0$,A[ALL]

		if A0$(1,2) <> firm_id$ then break
		if A0$(5,6) <> customer$ then break

		rem ' the date to use for aging
		check_date$=FNC$(A0$(24,3))
		if check_date$ > statement_date$ then continue

		rem ' loop Payment/Adjustment Records		
		trans_amt = 0
		read (art11, key = A0$(1,2) + A0$(3,2) + A0$(5,6) + A0$(11,7), dom=*next)
		while 1
            W0$="",W1$="";DIM W[1]
			read (art11, end = *break)IOL=ART11A; REM W0$,W1$,W[ALL]

			if W0$(11,7) <> A0$(11,7) then break

			trans_date$=FNC$(W1$(2,3))
			if trans_date$ <= statement_date$ then trans_amt = trans_amt + W[0] + W[1]
		wend

		bal = A[0] + trans_amt

		if bal = 0 then continue

		rem ' Age
		let period = pos(check_date$ > aging_dates$,6)
		if period = 0 then
			period = 5
		else
			period = int(period / 6)
		endif
		c[period] = c[period] + bal

	wend

	rem ' put aging buckets back into arm02
	aging_future = c[0]
	aging_cur = c[1]
	aging_30 = c[2]
	aging_60 = c[3]
	aging_90 = c[4]
	aging_120 = c[5]

return

rem ' ****************************************************
rem ' * build list of aging dates
rem ' ****************************************************
build_list_of_aging_dates:

	aging_dates$ = ""
	statement_date = jul(num(statement_date$(1,2)), num(statement_date$(3,2)), num(statement_date$(5,2)))

	for x = -5 TO 0
		aging_date = statement_date + (x *30)
		aging_dates$ = date(aging_date:"%Yz%Mz%Dz") + aging_dates$
	next x

return

sproc_error:rem --- SPROC error trap/handler
    rd_err_text$="", err_num=err
    if tcb(2)=0 and tcb(5) then rd_err_text$=pgm(tcb(5),tcb(13),err=*next)
    x$=stbl("+THROWN_ERR","TRUE")
    throw "["+pgm(-2)+"] "+str(tcb(5))+": "+rd_err_text$,err_num

REM " --- Functions
DEF FNA$(Q$,Q2$)=STR(MOD((ASC(Q$)-32)*POS(" "<>Q2$(2,1)),100):"00")
DEF FNB$(Q1$)=FNA$(Q1$(2),Q1$)+"/"+FNA$(Q1$(3),Q1$)+"/"+FNA$(Q1$(1),Q1$)
DEF FNC$(Q1$)=FNA$(Q1$(1),Q1$)+FNA$(Q1$(2),Q1$)+FNA$(Q1$(3),Q1$)

REM " --- IOLists"
DIM A[1],C[10],W[1]
ARM01A: IOLIST B0$,B1$
ARM02A: IOLIST C0$,C1$,C[ALL]
ARM10A: IOLIST X1$
ART01A: IOLIST A0$,A[ALL]
ART11A: IOLIST W0$,W1$,W[ALL]

end