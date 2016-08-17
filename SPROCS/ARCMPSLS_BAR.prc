rem --- sproc for the sales by month compare this year to last year

rem --- set start and end dates

seterr proc_error

rem ' debug
goto skip_debug;rem this out to do the trace
tfl$="C:/temp_downloads/sproctrace.txt"
erase tfl$,err=*next
string tfl$
tfl=unt
open(tfl)tfl$
settrace(tfl,MODE="UNTIMED")
skip_debug:

use java.util.LinkedHashMap

eyear$ = date(0:"%Y")
emonth$ = date(0:"%Mz")

switch num(emonth$)
	case 1; eday$ = "31"
	case 2; eday$ = "28"
	case 3; eday$ = "31"
	case 4; eday$ = "30"
	case 5; eday$ = "31"
	case 6; eday$ = "30"
	case 7; eday$ = "31"
	case 8; eday$ = "31"
	case 9; eday$ = "30"
	case 10; eday$ = "31"
	case 11; eday$ = "30"
	case 12; eday$ = "31"
swend
if mod(num(eyear$),4) = 0 and num(emonth$) = 2 then eday$="29"
edate$ = eyear$ + "-" + emonth$ + "-" + eday$ 

curYearEnd = num(eyear$)
curYearEndMonth = num(emonth$)

if num(emonth$) = 12 then 
	syear$ = str(num(eyear$)-1)
else	
	syear$ = str(num(eyear$)-2)
fi

smonth = num(emonth$)+1
if smonth = 13 then smonth = 01
smonth$ = str(smonth:"00")
sdate$ = syear$ + "-" + smonth$ + "-" + "01"

priYearStart = num(syear$)
priYearStartMonth = num(smonth$)

firstYear$=syear$ + "/" + smonth$ + " - "
divMonth = num(smonth$)+11
if divMonth > 12 then  
	divMonth = divMonth - 12
	divMonth$ = str(divMonth:"00")
	divYear$ = str(num(syear$) + 1:"00")
else
	divYear$ = syear$
	divMonth$ = str(divMonth:"00")
fi
firstYear$ = firstYear$ + divYear$ + "/" + divMonth$

priYearEnd = num(divYear$)
priYearEndMonth = num(divMonth$)

divMonthN = divMonth + 1
if divMonthN > 12 then
	divMonthN = divMonthN - 12
	divMonthN$ = str(divMonthN:"00")
	divYearN$ = str(num(divYear$) + 1:"0000")
else
	divYearN$ = divYear$
	divMonthN$ = str(divMonthN:"00")
fi
secondYear$ = divYearN$ + "/" + divMonthN$ + " - " + eyear$ + "/" + emonth$

curYearStart = num(divYearN$)
curYearStartMonth = num(divMonthN$)

months! = new LinkedHashMap()
monthsRev! = new LinkedHashMap()

count = 1
theMonth = curYearStartMonth
while 1
	months!.put(theMonth, str(count))
	rem ' write(debug)"loading months: " + str(theMonth) + " " + str(count)
	monthsRev!.put(count, str(theMonth)) 
	rem ' write(debug)"loading months Rev: " + str(count) + " " + str(theMonth)
	count = count + 1
	theMonth = theMonth + 1
	if theMonth = 13 then theMonth = 1
	if count >= 13 then break
wend

rem ' debug
rem ' write(debug)"start date: " + sdate$
rem ' write(debug)"end date: " + edate$
rem ' write(debug)"priYearStart: " + str(priYearStart)
rem ' write(debug)"priYearStartMonth: " + str(priYearStartMonth)
rem ' write(debug)"priYearEnd: " + str(priYearEnd)
rem ' write(debug)"priYearEndMonth: " + str(priYearEndMonth)
rem ' write(debug)"curYearStart: " + str(curYearStart)
rem ' write(debug)"curYearStartMonth: " + str(curYearStartMonth)
rem ' write(debug)"curYearEnd: " + str(curYearEnd)
rem ' write(debug)"curYearEndMonth: " + str(curYearEndMonth)
rem ' write(debug)"firstYear: " + firstYear$
rem ' write(debug)"secondYear: " + secondYear$

rem ' debug
rem ' month = curYearStartMonth
rem ' while 1
rem ' 	theMonth = num(months!.get(month))
rem '  	write(debug)"month: " + str(month) + " " + str(theMonth)
rem '  	month = month + 1
rem '  	if month = 13 then month = 1
rem '  	if month = curYearStartMonth then break
rem ' wend
rem ' count = 1
rem ' while 1
rem '  	theMonth = num(monthsRev!.get(count))
rem '  	write(debug)"month Rev: " + str(count) + " " + str(theMonth)
rem '  	count = count + 1
rem '  	if count >= 13 then break
rem ' wend

rem --- Declare some variables ahead of time

declare BBjStoredProcedureData sp!
use ::SQLProperties.bbj::SQLProperties
declare SQLProperties props!

rem --- Get the infomation object for the Stored Procedure

sp! = BBjAPI().getFileSystem().getStoredProcedureData()

rem --- get the input parameters

firm_id$ = sp!.getParameter("FIRM_ID")
customer_nbr$ = sp!.getParameter("CUSTOMER_NBR")
slspsn_code$ = sp!.getParameter("SLSPSN_CODE")

rem --- set the query string

sql$ = "SELECT INVOICE_DATE, TOTAL_SALES FROM ART03 "
if customer_nbr$ <> "ALL" then
	sql$ = sql$ + "WHERE FIRM_ID = '" + firm_id$ + "' AND customer_nbr = '" + customer_nbr$ + "' "
else
	if slspsn_code$ <> "ALL" then
		sql$ = sql$ + "WHERE FIRM_ID = '" + firm_id$ + "' AND slspsn_code = '" + slspsn_code$ + "' "
	else	
		sql$ = sql$ + "WHERE FIRM_ID = '" + firm_id$ + "' "
	fi
fi
sql$ = sql$ + "AND INVOICE_DATE >= '" + sdate$ + "' and INVOICE_DATE <= '" + edate$ + "'"

rem --- prep the query

rem props! = new SQLProperties()
rem sqlConnect$ = props!.getDBConnectForDatabase("AddonSoftware")
inRs! = BBjAPI().createSQLRecordSet("AddonSoftware", "", sql$)

rem --- Summarize the SELECT results into month and year buckets

dim totals[2,12]

if !(inRs!.isEmpty()) then
	while 1
		rd! = inRs!.getCurrentRecordData()

		indate$ = rd!.getFieldValue("INVOICE_DATE")
		year = num(date(num(indate$):"%Y"))
		month = num(date(num(indate$):"%Mz"))
		
		if year < priYearEnd then
			cur = 0
			pri = 1
		else
			if year = priYearEnd and month <= priYearEndMonth then
				cur = 0
				pri = 1
			else
				cur = 1
				pri = 0
			fi
		fi		

		sales = num(rd!.getFieldValue("TOTAL_SALES"))
		rem ' write (debug)"get month bucket for: " + str(month)
		monthBucket = num(months!.get(month))
				
		if cur then
			totals[2,monthBucket] = totals[2,monthBucket] + sales
		else
			totals[1,monthBucket] = totals[1,monthBucket] + sales
		fi
		
		inRs!.next(err=*break)
	
	wend
fi

inRs!.close()
	
rem --- create the in memory recordset for return

	dataTemplate$ = "YEAR:C(4*),PERIOD:C(3*),TOTAL:N(10)"

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

rem ' endtrace
rem ' close(debug)

goto std_exit

proc_error:
    write(tfl)str(err) + " " + errmes(-1)

std_exit:

end