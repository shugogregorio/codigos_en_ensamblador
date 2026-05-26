; ============================================================
; 02_fibonacci.asm - Sucesión de Fibonacci iterativa
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 02_fibonacci.asm -o 02_fibonacci.obj
; Enlazar:   gcc -m32 02_fibonacci.obj -o 02_fibonacci.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

section .data
    msg_input   db "Cuantos terminos de Fibonacci? (1-9): "
    msg_input_l equ $ - msg_input
    comma       db ", "
    newline     db 13, 10

section .bss
    buf         resb 16
    written     resd 1
    hStdOut     resd 1
    hStdIn      resd 1
    num_buf     resb 16

section .text

; -------------------------------------------------
; print_num: imprime EAX como decimal
; Salva y restaura EBX, ECX, EDX
; -------------------------------------------------
print_num:
    push    ebx
    push    ecx
    push    edx

    lea     ebx, [num_buf + 15]
    mov     byte [ebx], 0
    mov     ecx, 10

    test    eax, eax
    jnz     .div_loop
    dec     ebx
    mov     byte [ebx], '0'
    jmp     .do_print

.div_loop:
    xor     edx, edx
    div     ecx
    add     dl, '0'
    dec     ebx
    mov     [ebx], dl
    test    eax, eax
    jnz     .div_loop

.do_print:
    lea     eax, [num_buf + 15]
    sub     eax, ebx            ; longitud

    push    0
    push    written
    push    eax
    push    ebx
    push    dword [hStdOut]
    call    _WriteFile@20

    pop     edx
    pop     ecx
    pop     ebx
    ret

_start:
    push    -10
    call    _GetStdHandle@4
    mov     [hStdIn], eax

    push    -11
    call    _GetStdHandle@4
    mov     [hStdOut], eax

    push    0
    push    written
    push    msg_input_l
    push    msg_input
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    push    written
    push    2
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    movzx   ecx, byte [buf]
    sub     ecx, '0'            ; ecx = n términos

    xor     esi, esi            ; F(0) = 0
    mov     edi, 1              ; F(1) = 1
    xor     ebx, ebx            ; contador de términos impresos

.fib_loop:
    cmp     ebx, ecx
    jge     .fin

    ; Imprimir esi (término actual)
    push    ecx
    push    esi
    push    edi
    push    ebx
    mov     eax, esi
    call    print_num
    pop     ebx
    pop     edi
    pop     esi
    pop     ecx

    inc     ebx
    cmp     ebx, ecx
    jge     .fin

    ; Imprimir ", "
    push    ecx
    push    esi
    push    edi
    push    ebx
    push    0
    push    written
    push    2
    push    comma
    push    dword [hStdOut]
    call    _WriteFile@20
    pop     ebx
    pop     edi
    pop     esi
    pop     ecx

    ; Siguiente término: esi=edi, edi=esi+edi
    mov     eax, esi
    add     eax, edi
    mov     esi, edi
    mov     edi, eax
    jmp     .fib_loop

.fin:
    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    call    _ExitProcess@4