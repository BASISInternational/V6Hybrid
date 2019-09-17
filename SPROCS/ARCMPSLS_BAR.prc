rem --- V6demo - ARCMPSLS_BAR.proc
rem --- used by adx_V6aondashboard.aon
rem --- this sproc for the widget that shows bar chart of sales by month, comparing this year to last year

    seterr proc_error

    rem ' trace
    goto skip_trace;rem this out to do the trace
    tfl$="C:/temp_downloads/sproctrace.txt"
    erase tfl$,err=*next
    string tfl$
    tfl=unt
    open(tfl)tfl$
    settrace(tfl,MODE="UNTIMED")
skip_trace:

    use java.util.LinkedHashMap
    use ::sys/prog/bao_utilities.bbj::BarUtils

rem --- Declare some variables ahead of time

    declare BBjStoredProcedureData sp!

rem --- Get the infomation object for the Stored Procedure

    sp! = BBjAPI().getFileSystem().getStoredProcedureData()

rem --- get the input parameters

    firm_id$ = sp!.getParameter("FIRM_ID")
    customer_nbr$ = sp!.getParameter("CUSTOMER_NBR")
    slspsn_code$ = sp!.getParameter("SLSPSN_CODE")
    barista_wd$ = sp!.getParameter("BARISTA_WD")

    chdir barista_wd$

rem --- create current/prior year start/end dates based on today's date

    gosub set_dates

rem --- set the query string

    sql$ = "SELECT V6_INVOICE_DATE, V6_TOTAL_SALES FROM ART03 "
    if customer_nbr$ <> "ALL"
        sql$ = sql$ + "WHERE V6_FIRM_ID = '" + firm_id$ + "' AND V6_CUSTOMER_NBR = '" + customer_nbr$ + "' "
    else
        if slspsn_code$ <> "ALL"
            sql$ = sql$ + "WHERE V6_FIRM_ID = '" + firm_id$ + "' AND V6_SLSPSN_CODE = '" + slspsn_code$ + "' "
        else
            sql$ = sql$ + "WHERE V6_FIRM_ID = '" + firm_id$ + "' "
        endif
    endif
    sql$ = sql$ + "AND V6_INVOICE_DATE >= '" + sdate$ + "' and V6_INVOICE_DATE <= '" + edate$ + "'"

rem --- Get the query resultSet and summarize the results into month and year buckets

    dim totals[2,12]

    inRs!=BarUtils.getResultSet(sql$)

	while (inRs!.next())

        indate$ = str(inRs!.getObject("V6_INVOICE_DATE"))
        sales = num(inRs!.getString("V6_TOTAL_SALES"))

		year = num(indate$(1,4))
		month = num(indate$(6,2))

		if year < priYearEnd
			cur = 0
			pri = 1
		else
			if year = priYearEnd and month <= priYearEndMonth
				cur = 0
				pri = 1
			else
				cur = 1
				pri = 0
			endif
		endif

		monthBucket = num(months!.get(month))

		if cur
			totals[2,monthBucket] = totals[2,monthBucket] + sales
		else
			totals[1,monthBucket] = totals[1,monthBucket] + sales
		endif

    wend

rem --- Create a memory recordset for return

	dataTemplate$ = "YEAR:C(4*),PERIOD:C(3*),TOTAL:N(10*)"

	rs! = BBJAPI().createMemoryRecordSet(dataTemplate$)

rem --- Assign the summarized results to rs!

    monthStr$ = "JanFebMarAprMayJunJulAugSepOctNovDec"

    for month = 1 to 12

        monthActual$ = monthsRev!.get(month)
        monthActual = num(monthActual$)

        monthName$ = monthStr$(((monthActual*3)-2),3)

        data! = rs!.getEmptyRecordData()

        data!.setFieldValue("YEAR",firstYear$)
        data!.setFieldValue("PERIOD",str(monthActual:"00") + " " + monthName$)
        data!.setFieldValue("TOTAL",str(round(totals[1,month]/1000,0)))

        rs!.insert(data!)

        data! = rs!.getEmptyRecordData()

        data!.setFieldValue("YEAR",secondYear$)
        data!.setFieldValue("PERIOD",str(monthActual:"00") + " " + monthName$)
        data!.setFieldValue("TOTAL",str(round(totals[2,month]/1000,0)))

        rs!.insert(data!)

    next month

rem --- Tell the stored procedure to return the result set.

    sp!.setRecordSet(rs!)

    goto std_exit


set_dates:
rem --- set start and end dates based on today's date
rem --- today's date going back 1 year is 'current' year info, go back another year from start of 'current' to get 'prior'
rem --- output from this routine is used to summarize sales by invoice date into current or prior year/month buckets for return to widget

    eyear$ = date(0:"%Y")
    emonth$ = date(0:"%Mz")

    switch num(emonth$)
        case 1; eday$ = "31"
            break
        case 2; eday$ = "28"
            break
        case 3; eday$ = "31"
            break
        case 4; eday$ = "30"
            break
        case 5; eday$ = "31"
            break
        case 6; eday$ = "30"
            break
        case 7; eday$ = "31"
            break
        case 8; eday$ = "31"
            break
        case 9; eday$ = "30"
            break
        case 10; eday$ = "31"
            break
        case 11; eday$ = "30"
            break
        case 12; eday$ = "31"
            break
    swend
    
    if mod(num(eyear$),4) = 0 and num(emonth$) = 2 then eday$="29"
    edate$ = eyear$ + "-" + emonth$ + "-" + eday$

    curYearEnd = num(eyear$)
    curYearEndMonth = num(emonth$)

    if num(emonth$) = 12
        syear$ = str(num(eyear$)-1)
    else
        syear$ = str(num(eyear$)-2)
    endif

    smonth = num(emonth$)+1
    if smonth = 13 then smonth = 01
    smonth$ = str(smonth:"00")
    sdate$ = syear$ + "-" + smonth$ + "-" + "01"

    priYearStart = num(syear$)
    priYearStartMonth = num(smonth$)

    firstYear$=syear$ + "/" + smonth$ + " - "
    divMonth = num(smonth$)+11
    if divMonth > 12
        divMonth = divMonth - 12
        divMonth$ = str(divMonth:"00")
        divYear$ = str(num(syear$) + 1:"00")
    else
        divYear$ = syear$
        divMonth$ = str(divMonth:"00")
    endif
    firstYear$ = firstYear$ + divYear$ + "/" + divMonth$

    priYearEnd = num(divYear$)
    priYearEndMonth = num(divMonth$)

    divMonthN = divMonth + 1
    if divMonthN > 12
        divMonthN = divMonthN - 12
        divMonthN$ = str(divMonthN:"00")
        divYearN$ = str(num(divYear$) + 1:"0000")
    else
        divYearN$ = divYear$
        divMonthN$ = str(divMonthN:"00")
    endif
    secondYear$ = divYearN$ + "/" + divMonthN$ + " - " + eyear$ + "/" + emonth$

    curYearStart = num(divYearN$)
    curYearStartMonth = num(divMonthN$)

    months! = new LinkedHashMap()
    monthsRev! = new LinkedHashMap()

    count = 1
    theMonth = curYearStartMonth
    while 1
        months!.put(theMonth, str(count))
        monthsRev!.put(count, str(theMonth))
        count = count + 1
        theMonth = theMonth + 1
        if theMonth = 13 then theMonth = 1
        if count >= 13 then break
    wend

    return

proc_error:
    write(tfl)str(err) + " " + errmes(-1)

std_exit:

    end