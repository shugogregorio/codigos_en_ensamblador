; ============================================================
; 09_analizador.asm - Contador de Vocales, Consonantes y Dígitos
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 09_analizador.asm -o 09_analizador.obj
; Enlazar:   gcc -m32 09_analizador.obj -o 09_analizador.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

section .data
    msg_input   db "Ingresa una frase: "
    msg_input_l equ $ - msg_input
    msg_voc     db "Vocales:     "
    msg_voc_l   equ $ - msg_voc
    msg_con     db "Consonantes: "
    msg_con_l   equ $ - msg_con
    msg_dig     db "Digitos:     "
    msg_dig_l   equ $ - msg_dig
    newline     db 13, 10

section .bss
    buf         resb 256
    written     resd 1
    hStdOut     resd 1
    hStdIn      resd 1
    num_buf     resb 16
    cnt_voc     resd 1
    cnt_con     resd 1
    cnt_dig     resd 1

section .text

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

; --- Es vocal? AL -> ZF=1 si es vocal ---
es_vocal:
    cmp     al, 'a'
    je      .si
    cmp     al, 'e'
    je      .si
    cmp     al, 'i'
    je      .si
    cmp     al, 'o'
    je      .si
    cmp     al, 'u'
    je      .si
    cmp     al, 'A'
    je      .si
    cmp     al, 'E'
    je      .si
    cmp     al, 'I'
    je      .si
    cmp     al, 'O'
    je      .si
    cmp     al, 'U'
    je      .si
    ; No es vocal: limpiar ZF
    or      al, al              ; ZF=0 (al != 0 siempre aquí)
    ret
.si:
    ; Es vocal: poner ZF=1
    xor     al, al              ; ZF=1
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
    push    255
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    mov     dword [cnt_voc], 0
    mov     dword [cnt_con], 0
    mov     dword [cnt_dig], 0

    lea     esi, [buf]

.char_loop:
    movzx   eax, byte [esi]
    cmp     al, 0
    je      .print_results
    cmp     al, 13
    je      .print_results
    cmp     al, 10
    je      .print_results

    ; ¿Dígito?
    cmp     al, '0'
    jl      .check_letter
    cmp     al, '9'
    jg      .check_letter
    inc     dword [cnt_dig]
    jmp     .next_char

.check_letter:
    ; ¿Letra mayúscula o minúscula?
    cmp     al, 'A'
    jl      .next_char
    cmp     al, 'z'
    jg      .next_char
    cmp     al, 'Z'
    jle     .is_letter
    cmp     al, 'a'
    jge     .is_letter
    jmp     .next_char          ; entre Z y a (no es letra)

.is_letter:
    call    es_vocal
    jz      .vocal
    inc     dword [cnt_con]
    jmp     .next_char
.vocal:
    inc     dword [cnt_voc]

.next_char:
    inc     esi
    jmp     .char_loop

.print_results:
    ; Vocales
    push    0
    push    written
    push    msg_voc_l
    push    msg_voc
    push    dword [hStdOut]
    call    _WriteFile@20
    mov     eax, [cnt_voc]
    call    print_num
    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

    ; Consonantes
    push    0
    push    written
    push    msg_con_l
    push    msg_con
    push    dword [hStdOut]
    call    _WriteFile@20
    mov     eax, [cnt_con]
    call    print_num
    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

    ; Dígitos
    push    0
    push    written
    push    msg_dig_l
    push    msg_dig
    push    dword [hStdOut]
    call    _WriteFile@20
    mov     eax, [cnt_dig]
    call    print_num
    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    call    _ExitProcess@4