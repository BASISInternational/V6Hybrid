rem ----------------------------------------------------------------------------
rem Program: SIMPLE_INVOICE_DTL_60.prc
rem Description: Stored Procedure to create a jasper-based simple invoice in AR
rem Invoice Detail sub-report
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
    tfl$="C:/temp_downloads/sproctrace2.txt"
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
    amt_mask$ = sp!.getParameter("AMT_MASK")
    unit_mask$ = sp!.getParameter("UNIT_MASK")
    barista_wd$ = sp!.getParameter("BARISTA_WD")

    chdir barista_wd$

rem V6demo - iolists
are15a: iolist w0$,w1$,w[all]

    rem --- create the in memory recordset for return

    dataTemplate$ = "trns_date:c(10),memo:c(1*),units:c(1*),unit_price:c(1*),ext_price:c(1*),tot_price:c(1*)"

    rs! = BBJAPI().createMemoryRecordSet(dataTemplate$)

    rem --- open files
    files=1
    dim files$[files],options$[files],channels[files]
    files$[1]="ARE-15"

    call "SYC.DA",1,1,files,files$[all],options$[all],channels[all],batch,status

    if status then
        seterr 0
        x$=stbl("+THROWN_ERR","TRUE")   
        throw "File open error.",1001
    endif

    are15_dev=channels[1]
    
    rem --- init   

    dim w[2]
    read (are15_dev,key=firm_id$+ar_inv_no$,dom=*next)

    rem -- detail loop

    while 1

        read (are15_dev,end=*break)iol=are15a
        if pos(firm_id$+ar_inv_no$=w0$)<>1 then break

        tot_price=tot_price+w[2]
        memo=w[0]+w[2]<>0

        rem --- put data into recordset

        data! = rs!.getEmptyRecordData()
        data!.setFieldValue("TRNS_DATE", fnb6$(w1$(11,6)))
        data!.setFieldValue("MEMO", w1$(17,30))
        if memo
            data!.setFieldValue("UNITS",str(w[0]:unit_mask$))
            data!.setFieldValue("UNIT_PRICE",str(w[1]:amt_mask$))
            data!.setFieldValue("EXT_PRICE",str(w[2]:amt_mask$))
        else
            data!.setFieldValue("UNITS","")
            data!.setFieldValue("UNIT_PRICE","")
            data!.setFieldValue("EXT_PRICE","")        
        endif
        data!.setFieldValue("TOT_PRICE",str(tot_price:amt_mask$))
        rs!.insert(data!)

    wend

    rem --- close files

    close(are15_dev,err=*next)

    sp!.setRecordSet(rs!)

    end

rem --- Date/time handling functions

    def fndate$(q$)
        q1$=""
        q1$=date(jul(num(q$(1,4)),num(q$(5,2)),num(q$(7,2)),err=*next),err=*next)
        if q1$="" q1$=q$
        return q1$
    fnend

    rem V6demo functions
    DEF FNB6$(Q1$)=Q1$(3,2)+"/"+Q1$(5,2)+"/"+FNYY21_YY$(Q1$(1,2))
    REM " --- FNYY21_YY$ Un-Convert 21st Century 2-Char Year to 2-Char Year"
    DEF FNYY21_YY$(Q1$)
        LET Q3$=" 01234567890123456789",Q1$(1,1)=Q3$(POS(Q1$(1,1)=" 0123456789ABCDEFGHIJ"))
        RETURN Q1$
    FNEND

    def fnyy$(q$)=q$(3,2)
    def fnclock$(q$)=date(0:"%hz:%mz %p")
    def fntime$(q$)=date(0:"%Hz%mz")

sproc_error:rem --- SPROC error trap/handler
    rd_err_text$="", err_num=err
    if tcb(2)=0 and tcb(5) then rd_err_text$=pgm(tcb(5),tcb(13),err=*next)
    x$=stbl("+THROWN_ERR","TRUE")   
    throw "["+pgm(-2)+"] "+str(tcb(5))+": "+rd_err_text$,err_num

std_exit:
end


