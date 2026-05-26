; ============================================================
; 03_palindromo.asm - Validador de Cadenas Palíndromas
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 03_palindromo.asm -o 03_palindromo.obj
; Enlazar:   gcc -m32 03_palindromo.obj -o 03_palindromo.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

section .data
    msg_input   db "Ingresa una cadena: "
    msg_input_l equ $ - msg_input
    msg_yes     db "Es palindromo", 13, 10
    msg_yes_l   equ $ - msg_yes
    msg_no      db "No es palindromo", 13, 10
    msg_no_l    equ $ - msg_no

section .bss
    buf         resb 128
    written     resd 1
    hStdOut     resd 1
    hStdIn      resd 1

section .text
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
    push    127
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    ; Calcular longitud (hasta CR, LF o 0)
    lea     esi, [buf]
    xor     ecx, ecx
.len_loop:
    movzx   eax, byte [esi + ecx]
    cmp     al, 13
    je      .len_done
    cmp     al, 10
    je      .len_done
    cmp     al, 0
    je      .len_done
    inc     ecx
    jmp     .len_loop
.len_done:
    ; ecx = longitud

    cmp     ecx, 0
    je      .not_palindrome

    lea     esi, [buf]          ; puntero izquierdo
    lea     edi, [buf]
    add     edi, ecx
    dec     edi                 ; puntero derecho

.compare_loop:
    cmp     esi, edi
    jge     .is_palindrome

    movzx   eax, byte [esi]
    movzx   ebx, byte [edi]
    cmp     eax, ebx
    jne     .not_palindrome

    inc     esi
    dec     edi
    jmp     .compare_loop

.is_palindrome:
    push    0
    push    written
    push    msg_yes_l
    push    msg_yes
    push    dword [hStdOut]
    call    _WriteFile@20
    jmp     .fin

.not_palindrome:
    push    0
    push    written
    push    msg_no_l
    push    msg_no
    push    dword [hStdOut]
    call    _WriteFile@20

.fin:
    push    0
    call    _ExitProcess@4