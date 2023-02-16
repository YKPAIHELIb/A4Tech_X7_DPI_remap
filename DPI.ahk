; AHKv1 Script
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;Must be in auto-execute section if I want to use the constants
#Include %A_ScriptDir%\AHKHID.ahk

;Create GUI to receive messages
Gui, +LastFound
hGui := WinExist()

;Intercept WM_INPUT messages
WM_INPUT := 0xFF
OnMessage(WM_INPUT, "InputMsg")

;Register Remote Control with RIDEV_INPUTSINK (so that data is received even in the background)
r := AHKHID_Register(65440, 165, hGui, RIDEV_INPUTSINK)

btnDPIShiftState = false ; 6th button, below scroll wheel
btnTripleClickState = false ; 7th button, between LMB and scroll wheel
DPIMode = 0 ; 0-5: black, green, yellow, red, yellow-red, green-yellow respectively. Some models have only 0-4 modes.

/*
;Prefix loop
Loop {
    Sleep 1000
    If WinActive("ahk_class QWidget") Or WinActive("ahk_class VLC DirectX")
    sPrefix := "VLC"
    Else If WinActive("ahk_class Winamp v1.x") Or WinActive("ahk_class Winamp Video")
    sPrefix := "Winamp"
    Else If WinActive("ahk_class MediaPlayerClassicW")
    sPrefix := "MPC"
    Else sPrefix := "Default"
}
*/
Return

InputMsg(wParam, lParam) {
    Local devh, iKey, sLabel

    Critical

    ;Get handle of device
    devh := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)

    ;Check for error
    If (devh <> -1) ;Check that it is compatible a4tech x7 mouse
    And (AHKHID_GetDevInfo(devh, DI_DEVTYPE, True) = RIM_TYPEHID) {
        VendorID := AHKHID_GetDevInfo(devh, DI_HID_VENDORID, True)
        ProductID := AHKHID_GetDevInfo(devh, DI_HID_PRODUCTID, True)
        VersionNumber := AHKHID_GetDevInfo(devh, DI_HID_VERSIONNUMBER, True)
        isCompatible := false
        
        ; Model a4tech X-710BK (5 DPI modes version, rectangular sensor hole (VersionNumber=258) and 6 DPI modes version, round sensor hole(VersionNumber=259))
        If (VendorID = 2522)
        And (ProductID = 37008)
        And (VersionNumber = 259 or VersionNumber = 258) {
            isCompatible := true
            btnDataByte := 3 ; 4th byte
            DPIModeDataByte := 7 ; 8th byte
            flagBtnDPIShift := 0x20
            flagBtnTripleClick := 0x40
        }
        
        ; Model a4tech F4
        If (VendorID = 2522)
        And (ProductID = 36966)
        And (VersionNumber = 259) {
            isCompatible := true
            btnDataByte := 3 ; 4th byte
            DPIModeDataByte := 7 ; 8th byte
            flagBtnDPIShift := 0x80
            flagBtnTripleClick := 0x40
        }
        
        ;insert here block for your own mouse model
        
        if (isCompatible) {
            ;Get data
            iKey := AHKHID_GetInputData(lParam, uData)

            ;Check for error
            If (iKey <> -1) {
                ;Get key map (located at the 4th byte)
                iKey := NumGet(uData, btnDataByte, "UChar")
                
                btnCurDPIShiftState := (iKey & flagBtnDPIShift) != 0
                btnCurTripleClickState := (iKey & flagBtnTripleClick) != 0
                
                ;Get DPI mode (located at the 8th byte)
                curDPIMode := NumGet(uData, DPIModeDataByte, "UChar")
                curDPIMode &= 0xF
                DPIMode := curDPIMode
                
                if (btnDPIShiftState <> btnCurDPIShiftState) {
                    btnDPIShiftState := btnCurDPIShiftState
                    Gosub, ON_BTN_DPISHIFT
                }
                if (btnTripleClickState <> btnCurTripleClickState) {
                    btnTripleClickState := btnCurTripleClickState
                    Gosub, ON_BTN_TRIPLECLICK
                }
            }
        }
    }
}

ON_BTN_DPISHIFT: ;up/down btnDPIShift event
    If (btnDPIShiftState) {
        Send {Click Down}
    } else {
        Send {Click Up} ;replace with your own mapping
		Send +{F12}
    }
Return

ON_BTN_TRIPLECLICK: ;up/down btnTripleClick event
    If (btnTripleClickState) { ; you can also remap triple-click key, if you want
        
    } else {
        
    }
Return