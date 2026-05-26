; ============================================================
; 06_mayor_arreglo.asm - Búsqueda del Número Mayor en un Arreglo
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 06_mayor_arreglo.asm -o 06_mayor_arreglo.obj
; Enlazar:   gcc -m32 06_mayor_arreglo.obj -o 06_mayor_arreglo.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4

section .data
    arreglo     dd 45, 12, 78, 3, 99, 56, 23, 67, 11, 88
    LEN         equ 10
    msg_res     db "El numero mayor es: "
    msg_res_l   equ $ - msg_res
    newline     db 13, 10

section .bss
    written     resd 1
    hStdOut     resd 1
    ; buffer donde armamos el número como texto, de atrás para adelante
    num_buf     resb 12
    ; guardamos el máximo aquí para no perderlo
    maximo      resd 1

section .text
_start:
    push    -11
    call    _GetStdHandle@4
    mov     [hStdOut], eax

    ; --- Buscar el máximo en el arreglo ---
    lea     esi, [arreglo]
    mov     eax, [esi]          ; primer elemento
    mov     ecx, 1

.loop:
    cmp     ecx, LEN
    jge     .found
    mov     ebx, [esi + ecx*4]
    cmp     ebx, eax
    jle     .no_update
    mov     eax, ebx
.no_update:
    inc     ecx
    jmp     .loop

.found:
    mov     [maximo], eax       ; guardar máximo en memoria

    ; --- Imprimir mensaje ---
    push    0
    push    written
    push    msg_res_l
    push    msg_res
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --- Convertir [maximo] a texto en num_buf ---
    ; Llenamos de atrás para adelante, terminando con newline
    ; num_buf[11] = LF, num_buf[10] = CR, luego dígitos hacia atrás
    mov     byte [num_buf + 10], 13
    mov     byte [num_buf + 11], 10

    mov     eax, [maximo]
    lea     edi, [num_buf + 9]  ; empezamos desde la posición 9 hacia atrás
    mov     ecx, 10             ; divisor

    ; caso especial: si el número es 0
    test    eax, eax
    jnz     .convert_loop
    mov     byte [edi], '0'
    dec     edi
    jmp     .print_num

.convert_loop:
    test    eax, eax
    jz      .print_num
    xor     edx, edx
    div     ecx                 ; eax = cociente, edx = resto
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    jmp     .convert_loop

.print_num:
    ; edi apunta UN BYTE ANTES del primer dígito, así que avanzamos uno
    inc     edi
    ; longitud = dirección del CR - dirección del primer dígito
    lea     eax, [num_buf + 10]
    sub     eax, edi            ; longitud de dígitos
    add     eax, 2              ; + CR + LF

    push    0
    push    written
    push    eax
    push    edi
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    call    _ExitProcess@4