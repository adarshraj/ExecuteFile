; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; General Asm Template by Lahar 
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

.686					;Use 686 instuction set to have all inel commands
.model flat, stdcall	;Use flat memory model since we are in 32bit 
option casemap: none	;Variables and others are case sensitive

include Template.inc	;Include our files containing libraries

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Our constant values will go onto this section
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.const
	IDD_DLGBOX	equ	1001
	IDC_EXIT	equ	1002
	IDC_FILENAME	equ	1004
	IDC_OPEN	equ	1005
	IDC_DO		equ	1006
	APP_ICON	equ	2000
	MAXSIZE		equ	300

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Our initialised variables will go into in this .data section
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.data
	szAppName	db	"Application Name",0
	szFilter	db	"All Files",0 ,"*.*",0,0,0
	szTitle		db	"Select Any file...",0	
	szFileName	db	MAXSIZE 		dup (0)	
	lpBuffer	db	MAXSIZE 		dup (0)	
	szOpen		db	"open",0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Our uninitialised variables will go into in this .data? section
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.data?
	hInstance	HINSTANCE	?
	ofn	OPENFILENAME <> 
	

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; This is the section to write our main code
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.code

start:	
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke InitCommonControls
	invoke DialogBoxParam, hInstance, IDD_DLGBOX, NULL, addr DlgProc, NULL
	invoke ExitProcess, NULL

DlgProc		proc	hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.if uMsg == WM_INITDIALOG
	
			mov ofn.OPENFILENAME.lStructSize, sizeof OPENFILENAME
			mov ofn.OPENFILENAME.hInstance,offset hInstance
			mov ofn.OPENFILENAME.lpstrFilter, offset szFilter
			mov ofn.OPENFILENAME.lpstrCustomFilter, NULL
			mov ofn.OPENFILENAME.nFilterIndex, 1
			mov ofn.OPENFILENAME.lpstrFile, offset szFileName
			mov ofn.OPENFILENAME.nMaxFile, SIZEOF szFileName
			mov ofn.OPENFILENAME.lpstrTitle,offset szTitle
			mov ofn.OPENFILENAME.Flags,OFN_FILEMUSTEXIST or \
									 OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
									 OFN_EXPLORER or OFN_HIDEREADONLY	
		invoke SetWindowText, hWnd, addr szAppName
		invoke LoadIcon, hInstance, APP_ICON
		invoke SendMessage, hWnd, WM_SETICON, 1, eax	
	.elseif uMsg == WM_COMMAND
		mov eax, wParam
		.if eax == IDC_EXIT
			invoke SendMessage, hWnd, WM_CLOSE, 0, 0
		.elseif eax == IDC_OPEN
			invoke GetOpenFileName, addr ofn	
			invoke SetDlgItemText, hWnd, IDC_FILENAME, addr szFileName
		.elseif eax == IDC_DO
			;invoke WinExec,	addr szFileName,SW_SHOW
			;invoke OpenFile, addr szFileName,NULL,OF_REOPEN
			invoke GetCurrentDirectory, 120, addr lpBuffer
			invoke ShellExecute,hWnd,addr szOpen,addr szFileName,NULL,NULL,SW_SHOW
		.endif
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, NULL
	.endif
	
	xor eax, eax				 
	Ret
DlgProc EndP

end start	
	 