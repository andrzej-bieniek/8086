PAGE_NOACCESS                   equ     00000001h
PAGE_READONLY                   equ     00000002h
PAGE_READWRITE                  equ     00000004h
PAGE_WRITECOPY                  equ     00000008h
PAGE_EXECUTE                    equ     00000010h
PAGE_EXECUTE_READ               equ     00000020h
PAGE_EXECUTE_READWRITE          equ     00000040h
PAGE_EXECUTE_WRITECOPY          equ     00000080h
PAGE_GUARD                      equ     00000100h
PAGE_NOCACHE                    equ     00000200h
;
MEM_COMMIT                      equ     00001000h
MEM_RESERVE                     equ     00002000h
MEM_DECOMMIT                    equ     00004000h
MEM_RELEASE                     equ     00008000h
MEM_FREE                        equ     00010000h
MEM_PRIVATE                     equ     00020000h
MEM_MAPPED                      equ     00040000h
MEM_TOP_DOWN                    equ     00100000h

WM_CREATE			equ     0001h
WM_DESTROY			equ     0002h
WM_SIZE				equ     0005h
WM_SETTEXT			equ     000Ch
WM_PAINT			equ     000Fh
WM_CLOSE			equ     0010h
WM_ERASEBKGND			equ     0014h
WM_NOTIFY			equ     004Eh
WM_HELP				equ     0053h
WM_CHAR				equ     0102h
WM_INITDIALOG			equ     0110h
WM_COMMAND			equ     0111h
WM_TIMER			equ     0113h
WM_HSCROLL			equ     0114h
WM_VSCROLL			equ     0115h
WM_MENUSELECT			equ     011Fh
WM_CTLCOLORDLG			equ     0136h
WM_MOUSEMOVE			equ     0200h
WM_LBUTTONDOWN			equ     0201h
WM_LBUTTONUP			equ     0202h
WM_LBUTTONDBLCLK		equ     0203h
WM_RBUTTONDOWN			equ     0204h
WM_RBUTTONUP			equ     0205h
WM_RBUTTONDBLCLK		equ     0206h
WM_CUT				equ     0300h
WM_COPY				equ     0301h
WM_PASTE			equ     0302h
WM_CLEAR			equ     0303h
WM_UNDO				equ     0304h
WM_USER				equ     0400h
				   
WS_POPUP			equ     080000000h
WS_CHILD			equ     040000000h
WS_MINIMIZE			equ     020000000h
WS_VISIBLE			equ     010000000h
WS_MAXIMIZE			equ     001000000h
WS_CAPTION			equ     000C00000h
WS_BORDER			equ     000800000h
WS_DLGFRAME			equ     000400000h
WS_VSCROLL			equ     000200000h
WS_HSCROLL			equ     000100000h
WS_SYSMENU			equ     000080000h
;WS_SIZEBOX			equ     000040000h
WS_MINIMIZEBOX			equ     000020000h
WS_MAXIMIZEBOX			equ     000010000h
WS_OVERLAPPEDWINDOW		equ     000CF0000h
WS_EX_NOPARENTNOTIFY		equ     000000004h
WS_EX_WINDOWEDGE		equ     000000100h
WS_EX_CLIENTEDGE		equ     000000200h
WS_EX_OVERLAPPEDWINDOW		equ     WS_EX_WINDOWEDGE + WS_EX_CLIENTEDGE

; ===============
; window messages
; ===============
;
WM_NULL                         equ     0000h
WM_CREATE                       equ     0001h
WM_DESTROY                      equ     0002h
WM_MOVE                         equ     0003h
WM_SIZE                         equ     0005h
WM_ACTIVATE                     equ     0006h
WM_SETFOCUS                     equ     0007h
WM_KILLFOCUS                    equ     0008h
WM_ENABLE                       equ     000Ah
WM_SETREDRAW                    equ     000Bh
WM_SETTEXT                      equ     000Ch
WM_GETTEXT                      equ     000Dh
WM_GETTEXTLENGTH                equ     000Eh
WM_PAINT                        equ     000Fh
WM_CLOSE                        equ     0010h
WM_QUERYENDSESSION              equ     0011h
WM_QUIT                         equ     0012h
WM_QUERYOPEN                    equ     0013h
WM_ERASEBKGND                   equ     0014h
WM_SYSCOLORCHANGE               equ     0015h
WM_ENDSESSION                   equ     0016h
WM_SHOWWINDOW                   equ     0018h
WM_WININICHANGE                 equ     001Ah
WM_SETTINGCHANGE                equ     WM_WININICHANGE
WM_DEVMODECHANGE                equ     001Bh
WM_ACTIVATEAPP                  equ     001Ch
WM_FONTCHANGE                   equ     001Dh
WM_TIMECHANGE                   equ     001Eh
WM_CANCELMODE                   equ     001Fh
WM_SETCURSOR                    equ     0020h
WM_MOUSEACTIVATE                equ     0021h
WM_CHILDACTIVATE                equ     0022h
WM_QUEUESYNC                    equ     0023h
WM_GETMINMAXINFO                equ     0024h
WM_PAINTICON                    equ     0026h
WM_ICONERASEBKGND               equ     0027h
WM_NEXTDLGCTL                   equ     0028h
WM_SPOOLERSTATUS                equ     002Ah
WM_DRAWITEM                     equ     002Bh
WM_MEASUREITEM                  equ     002Ch
WM_DELETEITEM                   equ     002Dh
WM_VKEYTOITEM                   equ     002Eh
WM_CHARTOITEM                   equ     002Fh
WM_SETFONT                      equ     0030h
WM_GETFONT                      equ     0031h
WM_SETHOTKEY                    equ     0032h
WM_GETHOTKEY                    equ     0033h
WM_QUERYDRAGICON                equ     0037h
WM_COMPAREITEM                  equ     0039h
WM_COMPACTING                   equ     0041h
WM_COMMNOTIFY                   equ     0044h           ;no longer suported
WM_WINDOWPOSCHANGING            equ     0046h
WM_WINDOWPOSCHANGED             equ     0047h
WM_POWER                        equ     0048h
WM_COPYDATA                     equ     004Ah
WM_CANCELJOURNAL                equ     004Bh
WM_NOTIFY                       equ     004Eh
WM_INPUTLANGCHANGEREQUEST       equ     0050h
WM_INPUTLANGCHANGE              equ     0051h
WM_TCARD                        equ     0052h
WM_HELP                         equ     0053h
WM_USERCHANGED                  equ     0054h
WM_NOTIFYFORMAT                 equ     0055h
WM_CONTEXTMENU                  equ     007Bh
WM_STYLECHANGING                equ     007Ch
WM_STYLECHANGED                 equ     007Dh
WM_DISPLAYCHANGE                equ     007Eh
WM_GETICON                      equ     007Fh
WM_SETICON                      equ     0080h
WM_NCCREATE                     equ     0081h
WM_NCDESTROY                    equ     0082h
WM_NCCALCSIZE                   equ     0083h
WM_NCHITTEST                    equ     0084h
WM_NCPAINT                      equ     0085h
WM_NCACTIVATE                   equ     0086h
WM_GETDLGCODE                   equ     0087h
;
WM_NCMOUSEMOVE                  equ     00A0h
WM_NCLBUTTONDOWN                equ     00A1h
WM_NCLBUTTONUP                  equ     00A2h
WM_NCLBUTTONDBLCLK              equ     00A3h
WM_NCRBUTTONDOWN                equ     00A4h
WM_NCRBUTTONUP                  equ     00A5h
WM_NCRBUTTONDBLCLK              equ     00A6h
WM_NCMBUTTONDOWN                equ     00A7h
WM_NCMBUTTONUP                  equ     00A8h
WM_NCMBUTTONDBLCLK              equ     00A9h
;
WM_KEYFIRST                     equ     0100h
WM_KEYDOWN                      equ     0100h
WM_KEYUP                        equ     0101h
WM_CHAR                         equ     0102h
WM_DEADCHAR                     equ     0103h
WM_SYSKEYDOWN                   equ     0104h
WM_SYSKEYUP                     equ     0105h
WM_SYSCHAR                      equ     0106h
WM_SYSDEADCHAR                  equ     0107h
WM_KEYLAST                      equ     0108h
;
WM_IME_STARTCOMPOSITION         equ     010Dh
WM_IME_ENDCOMPOSITION           equ     010Eh
WM_IME_COMPOSITION              equ     010Fh
WM_IME_KEYLAST                  equ     010Fh
WM_INITDIALOG                   equ     0110h
WM_COMMAND                      equ     0111h
WM_SYSCOMMAND                   equ     0112h
WM_TIMER                        equ     0113h
WM_HSCROLL                      equ     0114h
WM_VSCROLL                      equ     0115h
WM_INITMENU                     equ     0116h
WM_INITMENUPOPUP                equ     0117h
WM_MENUSELECT                   equ     011Fh
WM_MENUCHAR                     equ     0120h
WM_ENTERIDLE                    equ     0121h
WM_CTLCOLORMSGBOX               equ     0132h
WM_CTLCOLOREDIT                 equ     0133h
WM_CTLCOLORLISTBOX              equ     0134h
WM_CTLCOLORBTN                  equ     0135h
WM_CTLCOLORDLG                  equ     0136h
WM_CTLCOLORSCROLLBAR            equ     0137h
WM_CTLCOLORSTATIC               equ     0138h
;
WM_MOUSEFIRST                   equ     0200h
WM_MOUSEMOVE                    equ     0200h
WM_LBUTTONDOWN                  equ     0201h
WM_LBUTTONUP                    equ     0202h
WM_LBUTTONDBLCLK                equ     0203h
WM_RBUTTONDOWN                  equ     0204h
WM_RBUTTONUP                    equ     0205h
WM_RBUTTONDBLCLK                equ     0206h
WM_MBUTTONDOWN                  equ     0207h
WM_MBUTTONUP                    equ     0208h
WM_MBUTTONDBLCLK                equ     0209h
WM_MOUSELAST                    equ     0209h
;
WM_PARENTNOTIFY                 equ     0210h
WM_ENTERMENULOOP                equ     0211h
WM_EXITMENULOOP                 equ     0212h
WM_NEXTMENU                     equ     0213h
WM_SIZING                       equ     0214h
WM_CAPTURECHANGED               equ     0215h
WM_MOVING                       equ     0216h
WM_POWERBROADCAST               equ     0218h
WM_DEVICECHANGE                 equ     0219h
WM_MDICREATE                    equ     0220h
WM_MDIDESTROY                   equ     0221h
WM_MDIACTIVATE                  equ     0222h
WM_MDIRESTORE                   equ     0223h
WM_MDINEXT                      equ     0224h
WM_MDIMAXIMIZE                  equ     0225h
WM_MDITILE                      equ     0226h
WM_MDICASCADE                   equ     0227h
WM_MDIICONARRANGE               equ     0228h
WM_MDIGETACTIVE                 equ     0229h
WM_MDISETMENU                   equ     0230h
WM_ENTERSIZEMOVE                equ     0231h
WM_EXITSIZEMOVE                 equ     0232h
WM_DROPFILES                    equ     0233h
WM_MDIREFRESHMENU               equ     0234h
;
WM_IME_SETCONTEXT               equ     0281h
WM_IME_NOTIFY                   equ     0282h
WM_IME_CONTROL                  equ     0283h
WM_IME_COMPOSITIONFULL          equ     0284h
WM_IME_SELECT                   equ     0285h
WM_IME_CHAR                     equ     0286h
WM_IME_KEYDOWN                  equ     0290h
WM_IME_KEYUP                    equ     0291h
;
WM_CUT                          equ     0300h
WM_COPY                         equ     0301h
WM_PASTE                        equ     0302h
WM_CLEAR                        equ     0303h
WM_UNDO                         equ     0304h
WM_RENDERFORMAT                 equ     0305h
WM_RENDERALLFORMATS             equ     0306h
WM_DESTROYCLIPBOARD             equ     0307h
WM_DRAWCLIPBOARD                equ     0308h
WM_PAINTCLIPBOARD               equ     0309h
WM_VSCROLLCLIPBOARD             equ     030Ah
WM_SIZECLIPBOARD                equ     030Bh
WM_ASKCBFORMATNAME              equ     030Ch
WM_CHANGECBCHAIN                equ     030Dh
WM_HSCROLLCLIPBOARD             equ     030Eh
WM_QUERYNEWPALETTE              equ     030Fh
WM_PALETTEISCHANGING            equ     0310h
WM_PALETTECHANGED               equ     0311h
WM_HOTKEY                       equ     0312h
WM_PRINT                        equ     0317h
WM_PRINTCLIENT                  equ     0318h
;
WM_HANDHELDFIRST                equ     0358h
WM_HANDHELDLAST                 equ     035Fh
;
WM_AFXFIRST                     equ     0360h
WM_AFXLAST                      equ     037Fh
;
WM_PENWINFIRST                  equ     0380h
WM_PENWINLAST                   equ     038Fh
;
WM_DDE_FIRST                    equ     03E0h
WM_DDE_INITIATE                 equ     WM_DDE_FIRST
WM_DDE_TERMINATE                equ     WM_DDE_FIRST+1
WM_DDE_ADVISE                   equ     WM_DDE_FIRST+2
WM_DDE_UNADVISE                 equ     WM_DDE_FIRST+3
WM_DDE_ACK                      equ     WM_DDE_FIRST+4
WM_DDE_DATA                     equ     WM_DDE_FIRST+5
WM_DDE_REQUEST                  equ     WM_DDE_FIRST+6
WM_DDE_POKE                     equ     WM_DDE_FIRST+7
WM_DDE_EXECUTE                  equ     WM_DDE_FIRST+8
WM_DDE_LAST                     equ     03E8h
;
WM_USER                         equ     0400h
WM_APP                          equ     8000h

RECT				struct
rc_left				dword	0	; left margin
rc_top				dword	0	; top margin
rc_right			dword	0	; right margin
rc_bottom			dword	0	; bottom margin
RECT				ends
RECT_				equ	4+4+4+4


HKEY_CLASSES_ROOT		equ	80000000h
HKEY_CURRENT_USER		equ	80000001h
HKEY_LOCAL_MACHINE		equ	80000002h
HKEY_USERS			equ	80000003h
HKEY_PERFORMANCE_DATA		equ	80000004h
HKEY_CURRENT_CONFIG		equ	80000005h
HKEY_DYN_DATA			equ	80000006h

REG_NONE			equ	0
REG_SZ				equ	1
REG_EXPAND_SZ			equ	2
REG_BINARY			equ	3
REG_DWORD			equ	4
REG_DWORD_LITTLE_ENDIAN		equ	4
REG_DWORD_BIG_ENDIAN		equ	5
REG_LINK			equ	6
REG_MULTI_SZ			equ	7
REG_RESOURCE_LIST		equ	8
REG_FULL_RESOURCE_DESCRIPTOR	equ	9
REG_RESOURCE_REQUIREMENTS_LIST	equ	10




