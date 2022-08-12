[[ADX_V6INITMENU.ASVA]]
rem --- Get mounted system ID and base directory for the menus
rem ---    if the menu we've selected is V6Hybrid, we're disabling standard Addon, and (re)enabling V6Hybrid, or vice versa
rem ---    after toggling to desired menu, do auto-sync quick sync if needed

	ddm_systems=fnget_dev("DDM_SYSTEMS")
	dim ddm_systems$:fnget_tpl$("DDM_SYSTEMS")

	aonMountSys$="ADDON"
	readrecord(ddm_systems,key=pad(aonMountSys$,16),dom=std_exit)ddm_systems$
	aonBaseDir$=ddm_systems.mount_dir$
	aonBaseDir$=FileObject.fixPath(aonBaseDir$, "/")
	strip_pos=pos("/aon/"=cvs(aonBaseDir$,11))
	if strip_pos
		aonBaseDir$=aonBaseDir$(1,strip_pos+4)
	else
		goto std_exit;rem something went wrong if aon not found
	endif

	V6MountSys$="V6HYBRID"
	readrecord(ddm_systems,key=pad(V6MountSys$,16),dom=std_exit)ddm_systems$
	V6BaseDir$=ddm_systems.mount_dir$
	V6BaseDir$=FileObject.fixPath(V6BaseDir$, "/")
	strip_pos=pos("/v6hybrid/"=cvs(V6BaseDir$,11))
	if strip_pos
		V6BaseDir$=V6BaseDir$(1,strip_pos+9)
	else
		goto std_exit;rem something went wrong if v6hybrid not found
	endif

	if callpoint!.getColumnData("ADX_V6INITMENU.SELECT_MENU")="V"
		disableBaseDir$=aonBaseDir$
		disableMountSys$=aonMountSys$
		enableBaseDir$=V6BaseDir$
	else
		disableBaseDir$=V6BaseDir$
		disableMountSys$=V6MountSys$
		enableBaseDir$=aonBaseDir$
	endif

	if disableBaseDir$<>""
		gosub disable_menu
	endif

	need_quick_sync=0
	sync_dir_dev=unt
	sync_dir$=enableBaseDir$+"data/sync/"
	open(sync_dir_dev)sync_dir$
	ext_from$=".notUsed"
	ext_to$=".xml"
	gosub rename_xmls
	close(sync_dir_dev)
    
	sync_dir_dev=unt
	sync_dir$=enableBaseDir$+"data/admin_backup/"
	open(sync_dir_dev)sync_dir$
	ext_from$=".notUsed"
	ext_to$=".xml"
	gosub rename_xmls
	close(sync_dir_dev)

	if need_quick_sync
		rem --- Launch bax_dd_synch_auto.bbj to do quick sync, bringing xml's for selected menu back into menu tables from data/sync/ or data/admin_backup/ xml's
		bar_dir$=dsk("")+dir("")
		rdAdmin! = BBjAPI().getGroupNamespace().getValue("+bar_admin_" + cvs(stbl("+USER_ID"), 11))
		run_arg$="bbj -tT0 -q -WD"+$22$+bar_dir$+$22$+" -c"+$22$+bar_dir$+"/sys/config/enu/barista.cfg"+$22$+" "+$22$+bar_dir$+"/sys/prog/bax_launch_task.bbj"+$22$
		user_arg$=" - "+" -u"+rdAdmin!.getUser()+" -p"+rdAdmin!.getPassword()+" -t"+"DDM_TABLES"+" -y"+"A"+" -a" +"bax_dd_synch_auto.bbj"+$22$+" - -b -qs"+$22$+" -w"
		scall_result=scall(run_arg$+user_arg$)
	endif
    

[[ADX_V6INITMENU.BSHO]]
rem --- use statements

    use java.io.File
    use ::ado_file.src::FileObject


rem --- open tables

    num_files=1
    dim open_tables$[1:num_files],open_opts$[1:num_files],open_chans$[1:num_files],open_tpls$[1:num_files]
    open_tables$[1]="DDM_SYSTEMS",open_opts$[1]="OTA"

    gosub open_tables

    ddm_systems=num(open_chans$[1]);dim ddm_systems$:open_tpls$[1]

[[ADX_V6INITMENU.<CUSTOM>]]

disable_menu: rem ======================================================================
rem --- in: disableBaseDir$, disableMountSys$ of whichever menu we're disabling
rem --- Rename data/sync/ xml's and data/admin_backup xml's (adm_mnu_item*.xml and adm_mnu_trans*.xml) 
rem ---     for the menu we're *not* using to have .notUsed at the end
rem --- Also delete records from the actual menu tables (adm_mnu_item.dat and adm_mnu_trans.dat)
rem ---    that have disableMountSys$ as the mount_sys_id
rem --- This leaves either the Integrated V6Hybrid menu or the Standard Addon menu in place
rem ---    and should prevent subsequent sync's from syncing back in the data/sync/ xml entries
rem --- Note: this is new for v21 since menu is now table-based. 
rem --- Older versions always installed the V6Hybrid menu by renaming addon.men so Barista would only 'see' v6hybrid.men.

	sync_dir_dev=unt
	sync_dir$=disableBaseDir$+"data/sync/"
	open(sync_dir_dev)sync_dir$
	ext_from$=".xml"
	ext_to$=".notUsed"
	gosub rename_xmls
	close(sync_dir_dev)
    
	sync_dir_dev=unt
	sync_dir$=disableBaseDir$+"data/admin_backup/"
	open(sync_dir_dev)sync_dir$
	ext_from$=".xml"
	ext_to$=".notUsed"
	gosub rename_xmls
	close(sync_dir_dev)    

	sql_chan=sqlunt
	sqlopen(sql_chan)stbl("+DBNAME")
    
	sql_prep$="DELETE FROM ADM_MNU_ITEM WHERE MOUNT_SYS_ID='"+disableMountSys$+"'"
	sqlprep(sql_chan)sql_prep$
	sqlexec(sql_chan)

	sql_prep$="DELETE FROM ADM_MNU_TRANS WHERE MOUNT_SYS_ID='"+disableMountSys$+"'"
	sqlprep(sql_chan)sql_prep$
	sqlexec(sql_chan)

	close(sql_chan)

	rdGlobalSpace!=BBjAPI().getGlobalNamespace()
	rdGlobalSpace!.setValue("+rebuild_menu","ALL")

	return

rename_xmls: rem ==========================================================================
rem --- either renaming .xml to .xml.notUsed if disabling, or from .xml.notUsed back to .xml if re-enabling

	while 1
		readrecord (sync_dir_dev,end=*break)sync_file$
		syncFile!=sync_file$
		if (syncFile!.startsWith("adm_mnu_item") or syncFile!.startsWith("adm_mnu_trans")) and syncFile!.endsWith(ext_from$)
			if ext_from$=".notUsed" then need_quick_sync=1;rem if re-enabling menu that had been disabled, will need to sync it back into data tables
			menuFile!=new File(sync_dir$+syncFile!)
			if ext_from$=".notUsed"
				rename_file$=sync_dir$+menuFile!.getName()
				rename_file$=rename_file$(1,pos(ext_from$=rename_file$)-1)
			else
				rename_file$=sync_dir$+menuFile!.getName()+ext_to$
			endif
			newFile!=new File(rename_file$)
			rename menuFile!.getAbsolutePath() to newFile!.getAbsolutePath()
		endif
	wend

	return



