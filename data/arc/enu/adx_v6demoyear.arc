//#charset: windows-1252

// ASCII Resource File
// ADX_V6DEMOYEAR - V6 Change Demo Data Year
// Barista Application Framework.  Copyright BASIS International Ltd

VERSION "4.0"

WINDOW 1000 "" 0010 0040 0330 0110
BEGIN
    NAME "win_adx_v6demoyear"
    MANAGESYSCOLOR
    KEYBOARDNAVIGATION
    DIALOGBEHAVIOR
    EVENTMASK 1136656524
    INVISIBLE
    FONT "Dialog" 8
    ENTERASTAB
    
    STATICTEXT 02001, "Current Demo Fiscal Year:", 49, 12, 158, 17
    BEGIN
        NOT OPAQUE
        JUSTIFICATION 32768
        NAME "txt_current_year"
        FONT "Dialog" 8
    END
    
    INPUTE 03001, "", 210, 10, 40, 19
    BEGIN
        NAME "ine_current_year"
        CLIENTEDGE
        PASSENTER
        HIGHLIGHT
        PADCHARACTER 0
        MASK "0000"
        FONT "Dialog" 8
    END
    
    STATICTEXT 02002, "Increment Year By:", 91, 33, 116, 17
    BEGIN
        NOT OPAQUE
        JUSTIFICATION 32768
        NAME "txt_increment_year"
        FONT "Dialog" 8
    END
    INPUTN 03002, "", 210, 31, 40, 19
    BEGIN
        NAME "inn_increment_year"
        CLIENTEDGE
        PASSENTER
        HIGHLIGHT
        DECIMALREPLACE
        MASK "00"
        FONT "Dialog" 8
    END
END

