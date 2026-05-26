; ============================================================
; 07_multiplicacion.asm - Multiplicación por Sumas Sucesivas
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 07_multiplicacion.asm -o 07_multiplicacion.obj
; Enlazar:   gcc -m32 07_multiplicacion.obj -o 07_multiplicacion.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

section .data
    msg_a       db "Ingresa el multiplicando: "
    msg_a_l     equ $ - msg_a
    msg_b       db "Ingresa el multiplicador: "
    msg_b_l     equ $ - msg_b
    msg_res     db "Resultado: "
    msg_res_l   equ $ - msg_res
    newline     db 13, 10

section .bss
    buf         resb 16
    written     resd 1
    hStdOut     resd 1
    hStdIn      resd 1
    num_buf     resb 16
    val_a       resd 1

section .text

; --- Parsear buf -> EAX ---
parse_num:
    lea     esi, [buf]
    xor     eax, eax
.p:
    movzx   ecx, byte [esi]
    cmp     cl, '0'
    jl      .done
    cmp     cl, '9'
    jg      .done
    sub     cl, '0'
    imul    eax, eax, 10
    add     eax, ecx
    inc     esi
    jmp     .p
.done:
    ret

; --- Imprimir EAX como decimal ---
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
    jmp     .pr
.div_loop:
    xor     edx, edx
    div     ecx
    add     dl, '0'
    dec     ebx
    mov     [ebx], dl
    test    eax, eax
    jnz     .div_loop
.pr:
    lea     eax, [num_buf + 15]
    sub     eax, ebx
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

    ; Leer multiplicando
    push    0
    push    written
    push    msg_a_l
    push    msg_a
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    push    written
    push    15
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    call    parse_num
    mov     [val_a], eax        ; guardar multiplicando

    ; Leer multiplicador
    push    0
    push    written
    push    msg_b_l
    push    msg_b
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    push    written
    push    15
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    call    parse_num
    mov     ecx, eax            ; ecx = multiplicador (contador)
    mov     esi, [val_a]        ; esi = multiplicando

    ; Sumar esi, ecx veces
    xor     eax, eax
.mult_loop:
    test    ecx, ecx
    jz      .done
    add     eax, esi
    dec     ecx
    jmp     .mult_loop

.done:
    push    eax
    push    0
    push    written
    push    msg_res_l
    push    msg_res
    push    dword [hStdOut]
    call    _WriteFile@20
    pop     eax

    call    print_num

    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    call    _ExitProcess@4