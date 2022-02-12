[[ADX_V6TOGGLTRIGS.ASVA]]
rem --- Enable/Disable Triggers

	if stbl("+V6DATA",err=*endif)<>""
		use ::ado_util.src::util
		enable%=num(callpoint!.getColumnData("ADX_V6TOGGLTRIGS.TOGGLE_TRIGS"))
		util.setTriggersEnabled(enable%)
		msg_id$="GENERIC_OK"
		dim msg_tokens$[1]
		desc$=iff(enable%=0,"Disabled","Enabled")
        		msg_tokens$[0]=desc$+" triggers in "+stbl("+V6DATA")+" and "+stbl("+DIR_DAT")+"."
		gosub disp_message
	endif



