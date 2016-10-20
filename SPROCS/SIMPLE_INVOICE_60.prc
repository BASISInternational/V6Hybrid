rem ----------------------------------------------------------------------------
rem Program: SIMPLE_INVOICE_60.prc
rem Description: Stored Procedure to create a jasper-based simple invoice in AR
rem 
rem AddonSoftware
rem Copyright BASIS International Ltd.
rem ----------------------------------------------------------------------------
rem
rem
rem V6demo --- modified to work on Addon 6.0 Data
rem
rem
rem ----------------------------------------------------------------------------
    rem ' trace
    goto skip_trace;rem this out to do the trace
    tfl$="C:/temp_downloads/sproctrace1.txt"
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
    ar_inv_no$ = sp!.getParameter("AR_INV_NO")
    customer$ = sp!.getParameter("CUSTOMER_ID")
    amt_mask$ = sp!.getParameter("AMT_MASK")
    cust_mask$ = sp!.getParameter("CUST_MASK")
    customer_size = num(sp!.getParameter("CUST_SIZE"))
    unit_mask$ = sp!.getParameter("UNIT_MASK")
    barista_wd$ = sp!.getParameter("BARISTA_WD")
    terms_cd$ = sp!.getParameter("TERMS_CD")

    chdir barista_wd$

rem V6demo - iolists
arm01a: iolist c0$,c1$
arm10a: iolist x2$
ars01b: iolist r0$,r1$

    rem --- create the in memory recordset for return

    dataTemplate$ = "firm_id:c(2),customer_id:C(1*),cust_name:C(30),address1:C(30),address2:C(30),"
    dataTemplate$ = dataTemplate$ + "address3:C(30),address4:C(30),address5:C(30),address6:C(30),"
    dataTemplate$ = dataTemplate$ + "remit1:C(30),remit2:C(30),remit3:C(30), remit4:C(30),"
    dataTemplate$ = dataTemplate$ + "ar_address1:C(30),ar_address2:C(30),ar_address3:C(30),ar_address4:C(30),ar_phone_no:C(1*),terms_desc:C(1*)"

    rs! = BBJAPI().createMemoryRecordSet(dataTemplate$)

    rem --- open files
    files=3
    dim files$[files],options$[files],channels[files]
    files$[1]="ARM-01",files$[2]="ARM-10"
    files$[3]="SYS-01"

    call "SYC.DA",1,1,files,files$[all],options$[all],channels[all],batch,status

    if status then
        seterr 0
        x$=stbl("+THROWN_ERR","TRUE")   
        throw "File open error.",1001
    endif

    arm01_dev=channels[1],arm10_dev=channels[2],sys01_dev=channels[3]
        
    rem --- get info for invoice header

	read (arm01_dev,key=firm_id$ + customer$)iol=arm01a

    read (sys01_dev,key=firm_id$+"AR02",err=*next)iol=ars01b
    ar_phone_no$=""
    if len(r1$)>=112
        call stbl("+DIR_SYP")+"bac_getmask.bbj","T",cvs(r1$(103,10),2),"",phone_mask$ 
        ar_phone_no$=str(cvs(r1$(103,10),2):phone_mask$)
    endif

    read (arm10_dev,key=firm_id$+"A"+terms_cd$,dom=*next)iol=arm10a
    terms_desc$=iff(cvs(x2$(6,20),3)="","Undefined",cvs(x2$(6,20),3))   

    rem --- put data into recordset
print (tfl)"cust: "+customer$
print (tfl)"cust address: "+c1$
print (tfl)"remit/company address: "+r1$

    data! = rs!.getEmptyRecordData()
    data!.setFieldValue("FIRM_ID",firm_id$)
    data!.setFieldValue("CUSTOMER_ID",fnmask$(customer$(1,customer_size),cust_mask$))
    data!.setFieldValue("CUST_NAME",c1$(1,30))
    data!.setFieldValue("ADDRESS1", c1$(31,24))
    data!.setFieldValue("ADDRESS2", c1$(55,24))
    data!.setFieldValue("ADDRESS3", c1$(79,24))
    data!.setFieldValue("ADDRESS4", c1$(179,24))
    data!.setFieldValue("ADDRESS5", c1$(203,24))
    data!.setFieldValue("REMIT1", r1$(1,30))
    data!.setFieldValue("REMIT2", r1$(31,24))
    data!.setFieldValue("REMIT3", r1$(55,24))
    data!.setFieldValue("REMIT4", r1$(79,24))
    data!.setFieldValue("AR_ADDRESS1", r1$(1,30))
    data!.setFieldValue("AR_ADDRESS2", r1$(31,24))
    data!.setFieldValue("AR_ADDRESS3", r1$(55,24))
    data!.setFieldValue("AR_ADDRESS4", r1$(79,24))
    data!.setFieldValue("AR_PHONE_NO", ar_phone_no$)
    data!.setFieldValue("TERMS_DESC", terms_desc$)
    rs!.insert(data!)

    rem --- close files

    close(arm01_dev,err=*next)
    close(sys01_dev,err=*next)
    close(arm10_dev,err=*next)

    sp!.setRecordSet(rs!)

    end

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


