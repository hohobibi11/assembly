format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'enter the size of the vector? ', 0
        strIncorSize db 'Incorrect size = %d !!', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strEnterX  db 'enter X: ', 10, 0
        strX  db 'X = %d', 10, 0
        strSize_2  db 'size_2 = %d', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        size_1     dd 0
        size_2     dd 0
        X          dd 0
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vec_1          rd 100
        vec_2          rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
        call VectorInput

        ;get X
        push strEnterX
        call [printf]
        add esp, 4

        push X
        push strScanInt
        call [scanf]
        add esp, 8

        call VectorExcludeX

        ;print size_2
        push [size_2]
        push strSize_2
        call [printf]

        call VectorOut

finish:
        call [getch]
        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push size_1
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [size_1]
        cmp eax, 0
        jg  getVector
; fail size
        push size_1
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec_1            ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [size_1]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorExcludeX:
        xor ecx, ecx
        xor edx, edx
        mov ebx, vec_1
        mov ebp, vec_2
exVecLoop:
        cmp ecx, [size_1]
        je endExVector
        mov eax, [ebx]
        cmp eax, [X]
        je cont
        add edx,1
        mov [ebp], eax
        add ebp,4

   cont:inc ecx
        add ebx, 4
        jmp exVecLoop
endExVector:
        mov [size_2],edx
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec_2            ; ebx = &vec
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [size_2]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'