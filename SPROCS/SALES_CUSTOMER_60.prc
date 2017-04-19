rem SALES_CUSTOMER.prc
rem 
rem AddonSoftware
rem Copyright BASIS International Ltd.
rem ----------------------------------------------------------------------------
rem ' Return invoices by customer for a given month period
rem
rem
rem V6demo --- modified to work Addon 6.0 Data
rem
rem
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

rem ' Declare some variables ahead of time
declare BBjStoredProcedureData sp!
declare BBjRecordSet rs!
declare BBjRecordData data!

rem ' Get the infomation object for the Stored Procedure
sp! = BBjAPI().getFileSystem().getStoredProcedureData()

rem ' Get the IN and IN/OUT parameters used by the procedure
firm_id$=sp!.getParameter("FIRM_ID")
customer_nbr$=sp!.getParameter("CUSTOMER_NBR")
beg_dt$ = sp!.getParameter("BEGDATE")
end_dt$ = sp!.getParameter("ENDDATE")
barista_wd$=sp!.getParameter("BARISTA_WD")

rem V6demo --- ART03 defined in BASIS dictionary with V6_INVOICE_DATE as a Date field, using AON format
beg_dt$=beg_dt$(1,4)+"-"+beg_dt$(5,2)+"-"+beg_dt$(7,2)
end_dt$=end_dt$(1,4)+"-"+end_dt$(5,2)+"-"+end_dt$(7,2)

sv_wd$=dir("")
chdir barista_wd$

rem ' set up the sql query
sql$ = "SELECT t1.V6_ar_inv_nbr as ar_inv_nbr, "
sql$ = sql$ + "t1.V6_invoice_date AS invoice_date, "
sql$ = sql$ + "t1.V6_total_sales as invoice_amt FROM ART03 t1 "
sql$ = sql$ + "WHERE V6_firm_id = '" + firm_id$ + "' AND t1.V6_ar_type = '  ' AND V6_CUSTOMER_NBR = '" + customer_nbr$ + "' AND t1.V6_INVOICE_DATE >= '" + beg_dt$ + "' and t1.V6_INVOICE_DATE <= '" +end_dt$ + "' "
sql$ = sql$ + "ORDER BY t1.V6_ar_inv_nbr"

chan = sqlunt
sqlopen(chan,mode="PROCEDURE",err=*next)stbl("+DBNAME")
sqlprep(chan)sql$
dim irec$:sqltmpl(chan)
sqlexec(chan)

sp!.setResultSet(chan)

sqlclose (chan)

end

sproc_error:rem --- SPROC error trap/handler
    rd_err_text$="", err_num=err
    if tcb(2)=0 and tcb(5) then rd_err_text$=pgm(tcb(5),tcb(13),err=*next)
    x$=stbl("+THROWN_ERR","TRUE")   
    throw "["+pgm(-2)+"] "+str(tcb(5))+": "+rd_err_text$,err_num

