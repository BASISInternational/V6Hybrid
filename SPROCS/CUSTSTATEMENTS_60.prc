rem ----------------------------------------------------------------------------
rem Program: CUSTSTATEMENTS_60.prc
rem Description: Stored Procedure to create a jasper-based customer statement
rem              either on-demand, or batch
rem AddonSoftware
rem Copyright BASIS International Ltd.
rem ----------------------------------------------------------------------------

rem --- V6demo --- altered to work against V6 database

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

declare BBjStoredProcedureData sp!
declare BBjRecordSet rs!
declare BBjRecordData data!

sp! = BBjAPI().getFileSystem().getStoredProcedureData()

rem --- get SPROC parameters

firm_id$ = sp!.getParameter("FIRM_ID")
statement_date$ = sp!.getParameter("STATEMENT_DATE")
customer$ = sp!.getParameter("CUSTOMER_ID")
age_basis$ = sp!.getParameter("AGE_BASIS")
amt_mask$ = sp!.getParameter("AMT_MASK")
cust_mask$ = sp!.getParameter("CUST_MASK")
customer_size = num(sp!.getParameter("CUST_SIZE"))
period_dates$ = sp!.getParameter("PERIOD_DATES")
barista_wd$ = sp!.getParameter("BARISTA_WD")

chdir barista_wd$

ars01b: iolist r0$,r1$

rem --- create the in memory recordset for return

dataTemplate$ = "firm_id:c(2),statement_date:C(10),customer_id:C(1*),cust_name:C(30),address1:C(30),address2:C(30),"
dataTemplate$ = dataTemplate$ + "address3:C(30),address4:C(30),address5:C(30),address6:C(30),"
dataTemplate$ = dataTemplate$ + "invoice_date:C(10),ar_inv_no:C(7),inv_type:C(11),invoice_amt:C(1*),trans_amt:C(1*),"
dataTemplate$ = DataTemplate$ + "invBalance:C(1*),aging_cur:C(1*),aging_30:C(1*),aging_60:C(1*),aging_90:C(1*),aging_120:C(1*),total_bal:C(1*),"
dataTemplate$ = dataTemplate$ + "remit1:C(30),remit2:C(30),remit3:C(30), remit4:C(30),"
dataTemplate$ = dataTemplate$ + "ar_address1:C(30),ar_address2:C(30),ar_address3:C(30),ar_address4:C(30),ar_phone_no:C(1*)"

rs! = BBJAPI().createMemoryRecordSet(dataTemplate$)

rem --- open files

    files=3,begfile=1,endfile=files
    dim files$[files],options$[files],ids$[files],templates$[files],channels[files]
    files$[1]="ARM-01",ids$[1]="ARM01"
    files$[2]="ART-01",ids$[2]="ART01"
    files$[3]="ART-11",ids$[3]="ART11"

    call pgmdir$+"adc_fileopen.aon",action,begfile,endfile,files$[all],options$[all],ids$[all],templates$[all],channels[all],batch,status
    if status then
        seterr 0
        x$=stbl("+THROWN_ERR","TRUE")   
        throw "File open error.",1001
    endif

    arm01=channels[1]
    art01=channels[2]
    art11=channels[3]
    
    rem --- Dimension string templates

	dim arm01$:templates$[1]
    dim art01$:templates$[2]
    dim art11$:templates$[3]

rem --- V6demo - open ars params

    rem --- open files
    files=1
    dim files$[files],options$[files],channels[files]
    files$[1]="SYS-01"

    call "SYC.DA",1,1,files,files$[all],options$[all],channels[all],batch,status

    if status then
        seterr 0
        x$=stbl("+THROWN_ERR","TRUE")   
        throw "File open error.",1001
    endif

    sys01=channels[1]
    
rem --- init

    read (sys01,key=firm_id$+"AR02",err=*next)iol=ars01b
    ar_phone_no$=""
    if len(r1$)>=112
        call stbl("+DIR_SYP")+"bac_getmask.bbj","T",cvs(r1$(103,10),2),"",phone_mask$
        ar_phone_no$=str(cvs(r1$(103,10),2):phone_mask$)
    endif   

    dim aging[5]

    read record (arm01, key = firm_id$ + customer$, dom=*next)arm01$

    rem --- positional read

    read record(art01, key = firm_id$ + "  " + customer$, dom=*next)

rem --- main loop

    while 1
	
        read record(art01,end=*break)art01$

        if art01.v6_firm_id$ <> firm_id$ then break
        if art01.v6_customer_nbr$ <> customer$ then break
        
        if fnv6dt$(art01.v6_invoice_date$) > statement_date$ then continue
        
        rem --- calculate invoice balance
        read record(art11, key=art01.v6_firm_id$ + art01.v6_ar_type$ + art01.v6_customer_nbr$ + art01.v6_ar_inv_nbr$, dom=*next)art11$
        trans_amt = 0
        while 1
            read record(art11,end=*break)art11$
            if art01.v6_firm_id$ + art01.v6_ar_type$ + art01.v6_customer_nbr$ + art01.v6_ar_inv_nbr$ <> art11.v6_firm_id$ + art11.v6_ar_type$ + art11.v6_customer_nbr$ + art11.v6_ar_inv_nbr$ then break
            if fnv6dt$(art11.v6_trans_date$) <= statement_date$ then trans_amt = trans_amt + art11.v6_trans_amt + art11.v6_adj_disc_amt
        wend
        
        inv_type$="Invoice"
        if art01.v6_invoice_type$="F" then inv_type$="Fin. Charge"
        
        invBalance = art01.v6_invoice_amt + trans_amt

        if invBalance = 0 then continue
        total_bal = total_bal + invBalance

        rem --- Age this invoice

        agingdate$=fnv6dt$(art01.v6_invoice_date$)
        if age_basis$<>"I" agingdate$=fnv6dt$(art01.v6_inv_due_date$)
        invagepd=pos(agingdate$>period_dates$,8); rem determine invoice aging period for proper accumulation
        if invagepd=0 invagepd=5 else invagepd=int(invagepd/8)
        aging[invagepd]=aging[invagepd]+invBalance

        rem --- put data into recordset
        
        data! = rs!.getEmptyRecordData()
        data!.setFieldValue("FIRM_ID",firm_id$)
        data!.setFieldValue("STATEMENT_DATE",fndate$(statement_date$))
        data!.setFieldValue("CUSTOMER_ID",fnmask$(customer$(1,customer_size),cust_mask$))
        data!.setFieldValue("CUST_NAME",arm01.v6_cust_name$)
        data!.setFieldValue("ADDRESS1", arm01.v6_addr_line_1$)
        data!.setFieldValue("ADDRESS2", arm01.v6_addr_line_2$)
        data!.setFieldValue("ADDRESS3", arm01.v6_addr_line_3$)
        data!.setFieldValue("ADDRESS4", arm01.v6_addr_line_4$)
        data!.setFieldValue("ADDRESS5", arm01.v6_addr_line_5$)
        data!.setFieldValue("ADDRESS6", "")
        data!.setFieldValue("INVOICE_DATE",fndate$(fnv6dt$(art01.v6_invoice_date$)))
        data!.setFieldValue("AR_INV_NO",art01.v6_ar_inv_nbr$)
        data!.setFieldValue("INV_TYPE",inv_type$)
        data!.setFieldValue("INVOICE_AMT",str(art01.v6_invoice_amt:amt_mask$))
        data!.setFieldValue("TRANS_AMT",str(trans_amt:amt_mask$))
        data!.setFieldValue("INVBALANCE",str(invBalance:amt_mask$))
        data!.setFieldValue("AGING_CUR",str(aging[1]:amt_mask$))
        data!.setFieldValue("AGING_30",str(aging[2]:amt_mask$))
        data!.setFieldValue("AGING_60",str(aging[3]:amt_mask$))
        data!.setFieldValue("AGING_90",str(aging[4]:amt_mask$))
        data!.setFieldValue("AGING_120",str(aging[5]:amt_mask$))
        data!.setFieldValue("TOTAL_BAL",str(total_bal:amt_mask$))
        data!.setFieldValue("REMIT1", r1$(1,30))
        data!.setFieldValue("REMIT2", r1$(31,24))
        data!.setFieldValue("REMIT3", r1$(55,24))
        data!.setFieldValue("REMIT4", r1$(79,24))
        data!.setFieldValue("AR_ADDRESS1", r1$(1,30))
        data!.setFieldValue("AR_ADDRESS2", r1$(31,24))
        data!.setFieldValue("AR_ADDRESS3", r1$(55,24))
        data!.setFieldValue("AR_ADDRESS4", r1$(79,24))
        data!.setFieldValue("AR_PHONE_NO", ar_phone_no$)
        rs!.insert(data!)
    
    wend

rem --- close files

    close(arm01)
    close(art01)
    close(art11)
    close(sys01)

    sp!.setRecordSet(rs!)
    end

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

    def fnyy$(q$)=q$(3,2)
    def fnclock$(q$)=date(0:"%hz:%mz %p")
    def fntime$(q$)=date(0:"%Hz%mz")

rem --- fnmask$: Alphanumeric Masking Function (formerly fnf$)

    def fnmask$(q1$,q2$)
        if q2$="" q2$=fill(len(q1$),"0")
        return str(-num(q1$,err=*next):q2$,err=*next)
        q=1
        q0=0
        while len(q2$(q))
            if pos(q2$(q,1)="-()") q0=q0+1 else q2$(q,1)="X"
            q=q+1
        wend
        if len(q1$)>len(q2$)-q0 q1$=q1$(1,len(q2$)-q0)
        return str(q1$:q2$)
    fnend

sproc_error:rem --- SPROC error trap/handler
    rd_err_text$="", err_num=err
    if tcb(2)=0 and tcb(5) then rd_err_text$=pgm(tcb(5),tcb(13),err=*next)
    x$=stbl("+THROWN_ERR","TRUE")   
    throw "["+pgm(-2)+"] "+str(tcb(5))+": "+rd_err_text$,err_num
    
std_exit:
    end
