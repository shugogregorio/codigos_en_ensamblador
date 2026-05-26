; ============================================================
; 10_mayus_minus.asm - Conversor de Mayúsculas a Minúsculas
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 10_mayus_minus.asm -o 10_mayus_minus.obj
; Enlazar:   gcc -m32 10_mayus_minus.obj -o 10_mayus_minus.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

section .data
    msg_orig    db "Cadena original:  HOLA MUNDO DESDE ENSAMBLADOR", 13, 10
    msg_orig_l  equ $ - msg_orig
    msg_conv    db "Cadena convertida: "
    msg_conv_l  equ $ - msg_conv
    newline     db 13, 10

section .bss
    buf         resb 128
    written     resd 1
    hStdOut     resd 1
    hStdIn      resd 1
    char_out    resb 2

section .text
_start:
    push    -10
    call    _GetStdHandle@4
    mov     [hStdIn], eax

    push    -11
    call    _GetStdHandle@4
    mov     [hStdOut], eax

    ; Mostrar cadena original
    push    0
    push    written
    push    msg_orig_l
    push    msg_orig
    push    dword [hStdOut]
    call    _WriteFile@20

    ; Pedir cadena al usuario
    push    0
    push    written
    push    msg_conv_l
    push    msg_conv
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    push    written
    push    127
    push    buf
    push    dword [hStdIn]
    call    _ReadFile@20

    ; Convertir e imprimir carácter a carácter
    lea     esi, [buf]

.loop:
    movzx   eax, byte [esi]
    cmp     al, 0
    je      .done
    cmp     al, 13
    je      .done
    cmp     al, 10
    je      .done

    ; Si es mayúscula (A=65 .. Z=90), sumar 32
    cmp     al, 'A'
    jl      .print_it
    cmp     al, 'Z'
    jg      .print_it
    add     al, 32

.print_it:
    mov     [char_out], al
    push    esi
    push    0
    push    written
    push    1
    push    char_out
    push    dword [hStdOut]
    call    _WriteFile@20
    pop     esi

    inc     esi
    jmp     .loop

.done:
    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    call    _ExitProcess@4