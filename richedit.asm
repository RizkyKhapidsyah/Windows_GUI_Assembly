; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

        RichEdit2        PROTO :DWORD,:DWORD,:DWORD,:DWORD
        file_read        PROTO :DWORD,:DWORD
        cbOpenFile       PROTO :DWORD,:DWORD,:DWORD,:DWORD
        file_write       PROTO :DWORD,:DWORD
        cbSaveFile       PROTO :DWORD,:DWORD,:DWORD,:DWORD
        Select_All       PROTO :DWORD

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

RichEdit2 proc iinstance:DWORD,hParent:DWORD,ID:DWORD,WRAP:DWORD

    LOCAL wStyle :DWORD

    mov wStyle, WS_VISIBLE or WS_CHILDWINDOW or WS_CLIPSIBLINGS or ES_MULTILINE or \
                WS_VSCROLL or ES_AUTOVSCROLL or ES_NOHIDESEL or ES_DISABLENOSCROLL

    .if WRAP == 0
      or wStyle, WS_HSCROLL or ES_AUTOHSCROLL
    .endif

    fn CreateWindowEx,WS_EX_STATICEDGE,"RichEdit20a",0,wStyle, \
                      0,0,100,100,hParent,ID,iinstance,NULL

    ret

RichEdit2 endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

file_read proc edit:DWORD,lpszFileName:DWORD

    LOCAL hFile :DWORD
    LOCAL ofs   :OFSTRUCT
    LOCAL est   :EDITSTREAM

    invoke CreateFile,lpszFileName,GENERIC_READ,FILE_SHARE_READ,NULL,
                      OPEN_EXISTING,NULL,FILE_ATTRIBUTE_NORMAL
    mov hFile, eax

    m2m est.dwCookie, hFile
    mov est.dwError, 0
    mov eax, offset cbOpenFile
    mov est.pfnCallback, eax

    IFNDEF UNICODE_EDIT
      invoke SendMessage,edit,EM_STREAMIN,SF_TEXT,ADDR est
    ELSE
      invoke SendMessage,edit,EM_STREAMIN,SF_TEXT or SF_UNICODE,ADDR est
    ENDIF

    invoke CloseHandle,hFile

    invoke SendMessage,edit,EM_SETMODIFY,0,0

    xor eax, eax
    ret

file_read endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

cbOpenFile proc dwCookie:DWORD,pbBuff:DWORD,cb:DWORD,pcb:DWORD

  ; --------------------------------------------------------------
  ; this callback procedure is called by the "file_read" procedure
  ; --------------------------------------------------------------

    invoke ReadFile,dwCookie,pbBuff,cb,pcb,NULL
    xor eax, eax
    ret

cbOpenFile endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

file_write proc edit:DWORD,lpszFileName:DWORD

    LOCAL hFile :DWORD
    LOCAL ofs   :OFSTRUCT
    LOCAL est   :EDITSTREAM

    invoke CreateFile,lpszFileName,GENERIC_WRITE,FILE_SHARE_WRITE,NULL,
                      CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
    mov hFile, eax

    m2m est.dwCookie, hFile
    mov est.dwError, 0
    mov eax, offset cbSaveFile
    mov est.pfnCallback, eax

    IFNDEF UNICODE_EDIT
      invoke SendMessage,edit,EM_STREAMOUT,SF_TEXT,ADDR est
    ELSE
      invoke SendMessage,edit,EM_STREAMOUT,SF_TEXT or SF_UNICODE,ADDR est
    ENDIF

    invoke CloseHandle,hFile

    invoke SendMessage,edit,EM_SETMODIFY,0,0

    xor eax, eax
    ret

file_write endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

cbSaveFile proc dwCookie:DWORD,pbBuff:DWORD,cb:DWORD,pcb:DWORD

  ; ---------------------------------------------------------------
  ; this callback procedure is called by the "file_write" procedure
  ; ---------------------------------------------------------------

    invoke WriteFile,dwCookie,pbBuff,cb,pcb,NULL
    xor eax, eax
    ret

cbSaveFile endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

Select_All Proc Edit:DWORD

    LOCAL tl :DWORD
    LOCAL Cr :CHARRANGE

    mov Cr.cpMin,0
    invoke GetWindowTextLength,Edit
    inc eax
    mov Cr.cpMax, eax
    invoke SendMessage,Edit,EM_EXSETSEL,0,ADDR Cr

    ret

Select_All endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
