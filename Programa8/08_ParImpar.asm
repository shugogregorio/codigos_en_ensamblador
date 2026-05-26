; ============================================================
; 08_par_impar.asm - Identificador de Número Par o Impar
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 08_par_impar.asm -o 08_par_impar.obj
; Enlazar:   gcc -m32 08_par_impar.obj -o 08_par_impar.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

section .data
    msg_input   db "Ingresa un numero entero: "
    msg_input_l equ $ - msg_input
    msg_par     db "Es par", 13, 10
    msg_par_l   equ $ - msg_par
    msg_impar   db "Es impar", 13, 10
    msg_impar_l equ $ - msg_impar

section .bss
    buf         resb 16
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
    push    15
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    ; Parsear número
    lea     esi, [buf]
    xor     eax, eax
.parse_loop:
    movzx   ecx, byte [esi]
    cmp     cl, '0'
    jl      .parse_done
    cmp     cl, '9'
    jg      .parse_done
    sub     cl, '0'
    imul    eax, eax, 10
    add     eax, ecx
    inc     esi
    jmp     .parse_loop
.parse_done:

    ; Bit menos significativo: AND 1
    test    eax, 1
    jnz     .impar

.par:
    push    0
    push    written
    push    msg_par_l
    push    msg_par
    push    dword [hStdOut]
    call    _WriteFile@20
    jmp     .fin

.impar:
    push    0
    push    written
    push    msg_impar_l
    push    msg_impar
    push    dword [hStdOut]
    call    _WriteFile@20

.fin:
    push    0
    call    _ExitProcess@4