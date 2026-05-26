; ============================================================
; 05_primo.asm - Detector de Números Primos
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 05_primo.asm -o 05_primo.obj
; Enlazar:   gcc -m32 05_primo.obj -o 05_primo.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

section .data
    msg_input   db "Ingresa un numero mayor a 1: "
    msg_input_l equ $ - msg_input
    msg_primo   db "El numero es primo", 13, 10
    msg_primo_l equ $ - msg_primo
    msg_comp    db "El numero es compuesto", 13, 10
    msg_comp_l  equ $ - msg_comp

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
    mov     ebx, eax            ; ebx = N

    ; Caso especial: N < 2
    cmp     ebx, 2
    jl      .is_composite

    ; Caso especial: N = 2
    cmp     ebx, 2
    je      .is_prime

    ; Probar divisores desde 2 hasta sqrt(N)
    mov     ecx, 2

.prime_loop:
    ; Si ecx*ecx > ebx -> es primo
    mov     eax, ecx
    imul    eax, eax
    cmp     eax, ebx
    jg      .is_prime

    mov     eax, ebx
    xor     edx, edx
    div     ecx
    test    edx, edx
    jz      .is_composite

    inc     ecx
    jmp     .prime_loop

.is_prime:
    push    0
    push    written
    push    msg_primo_l
    push    msg_primo
    push    dword [hStdOut]
    call    _WriteFile@20
    jmp     .fin

.is_composite:
    push    0
    push    written
    push    msg_comp_l
    push    msg_comp
    push    dword [hStdOut]
    call    _WriteFile@20

.fin:
    push    0
    call    _ExitProcess@4