rem SALES_CUST_TYPE.prc
rem 
rem AddonSoftware
rem Copyright BASIS International Ltd.
rem ----------------------------------------------------------------------------
rem ' Return sales totals by customer type for a given month period
rem ----------------------------------------------------------------------------
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
beg_dt$ = sp!.getParameter("BEGDATE")
end_dt$ = sp!.getParameter("ENDDATE")
barista_wd$=sp!.getParameter("BARISTA_WD")

rem V6demo --- ART03 defined in BASIS dictionary with V6_INVOICE_DATE as a Date field, using AON format
beg_dt$=beg_dt$(1,4)+"-"+beg_dt$(5,2)+"-"+beg_dt$(7,2)
end_dt$=end_dt$(1,4)+"-"+end_dt$(5,2)+"-"+end_dt$(7,2)

sv_wd$=dir("")
chdir barista_wd$

rem ' set up the sql query
sql$ = "SELECT SUM(t1.V6_TOTAL_SALES) as total_sales, t2.V6_CUST_TYPE as CUST_TYPE, t3.V6_CODE_DESC as CODE_DESC "
sql$ = sql$ + "FROM ART03 t1 "
sql$ = sql$ + "INNER JOIN ARM02 t2 ON t1.V6_firm_id = t2.V6_firm_id AND t1.V6_CUSTOMER_NBR = t2.V6_CUSTOMER_NBR "
sql$ = sql$ + "INNER JOIN ARM10L t3 ON t2.V6_firm_id = t3.V6_firm_id AND t2.V6_CUST_TYPE = t3.V6_CUST_TYPE AND t3.V6_RECORD_ID_L='L' "
sql$ = sql$ + "WHERE t1.V6_firm_id = '" + firm_id$ + "' AND t1.V6_ar_type = '  ' AND t1.V6_INVOICE_DATE >= '" + beg_dt$ + "' and t1.V6_INVOICE_DATE <= '" +end_dt$ + "' "
sql$ = sql$ + "GROUP BY t2.V6_CUST_TYPE, t3.V6_CODE_DESC "
sql$ = sql$ + "ORDER BY total_sales DESC "

chan = sqlunt
sqlopen(chan,mode="PROCEDURE",err=*next)stbl("+DBNAME")
sqlprep(chan)sql$
dim irec$:sqltmpl(chan)
sqlexec(chan)

rs! = BBJAPI().createMemoryRecordSet("FIRM_ID:C(2),CUST_TYPE:C(3),CODE_DESC:C(20),TOTAL_SALES:N(15)")

while 1
    irec$ = sqlfetch(chan,err=*break)
    data! = rs!.getEmptyRecordData()
    data!.setFieldValue("FIRM_ID",firm_id$)
    data!.setFieldValue("CUST_TYPE",irec.cust_type$)
    data!.setFieldValue("CODE_DESC",irec.code_desc$)
    data!.setFieldValue("TOTAL_SALES",str(irec.total_sales))
    rs!.insert(data!)
wend

rem ' Close the sql channel and set the stored procedure's result set to the record set that 
rem ' was created and populated in the code above
done:
sqlclose (chan)
sp!.setRecordSet(rs!)
end

sproc_error:rem --- SPROC error trap/handler
    rd_err_text$="", err_num=err
    if tcb(2)=0 and tcb(5) then rd_err_text$=pgm(tcb(5),tcb(13),err=*next)
    x$=stbl("+THROWN_ERR","TRUE")
    throw "["+pgm(-2)+"] "+str(tcb(5))+": "+rd_err_text$,err_num