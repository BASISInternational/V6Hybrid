rem SALES_INVOICE_DETAIL.prc
rem 
rem AddonSoftware
rem Copyright BASIS International Ltd.
rem ----------------------------------------------------------------------------
rem ' Return invoice detail by invoice number
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
inv_nbr$ = sp!.getParameter("AR_INV_NBR")
barista_wd$=sp!.getParameter("BARISTA_WD")

rem ' set up the sql query
sql$ = "SELECT t1.V6_line_number as line_number, t1.V6_line_code as line_code, t1.V6_item_number as item_number, t1.V6_order_memo as order_memo, t1.V6_qty_shipped as qty_shipped, t1.V6_unit_price as unit_price, t1.V6_ext_price as ext_price "
sql$ = sql$ + "FROM ART13 t1 " 
sql$ = sql$ + "WHERE V6_firm_id = '" + firm_id$ + "' AND V6_ar_type = '  ' AND V6_CUSTOMER_NBR = '" + customer_nbr$ + "' AND V6_AR_INV_NBR = '" + inv_nbr$ + "' "
sql$ = sql$ + "ORDER BY t1.V6_line_number"

chan = sqlunt
sqlopen(chan,mode="PROCEDURE",err=*next)stbl("+DBNAME")
sqlprep(chan)sql$
sqlexec(chan)

sp!.setResultSet(chan)

sqlclose (chan)

end

sproc_error:rem --- SPROC error trap/handler
    rd_err_text$="", err_num=err
    if tcb(2)=0 and tcb(5) then rd_err_text$=pgm(tcb(5),tcb(13),err=*next)
    x$=stbl("+THROWN_ERR","TRUE")   
    throw "["+pgm(-2)+"] "+str(tcb(5))+": "+rd_err_text$,err_num
