[[ARM10D.BDEQ]]
rem --- Check if code is used as a customer default code

ars01a: iolist x$,p1$,p2$,p3$

	files=1
	dim files$[files],options$[files],channels[files]
	files$[1]="sys-01"
	call "syc.da",1,1,files,files$[all],options$[all],channels[all],batch,status
	if status then goto std_exit
	sys01_dev=channels[1]

	find (sys01_dev,key=firm_id$+"AR00",dom=*next)iol=ars01a

	if p3$(62,2) = callpoint!.getColumnData("ARM10D.V6_DIST_CODE") then
		callpoint!.setMessage("AR_DIST_CODE_IN_DFLT")
		callpoint!.setStatus("ABORT")
	endif
[[ARM10D.ASHO]]
rem --- Disable some columns if PO system not installed

dim info$[20]
call "SYC.VA","PO",info$[all]

if info$[20] = "N"

	callpoint!.setColumnEnabled("ARM10D.GL_INV_ADJ",-1)
	callpoint!.setColumnEnabled("ARM10D.GL_COGS_ADJ",-1)
	callpoint!.setColumnEnabled("ARM10D.GL_PURC_ACCT",-1)
	callpoint!.setColumnEnabled("ARM10D.GL_PPV_ACCT",-1)

endif
