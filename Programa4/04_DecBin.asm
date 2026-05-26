; ============================================================
; 04_dec_bin.asm - Conversor de Decimal a Binario
; NASM + MinGW (Windows)
; Ensamblar: nasm -f win32 04_dec_bin.asm -o 04_dec_bin.obj
; Enlazar:   gcc -m32 04_dec_bin.obj -o 04_dec_bin.exe -nostartfiles -e_start
; ============================================================

global _start
extern _GetStdHandle@4
extern _WriteFile@20
extern _ReadFile@20
extern _ExitProcess@4

section .data
    msg_input   db "Ingresa un numero (0-255): "
    msg_input_l equ $ - msg_input
    msg_result  db "En binario: "
    msg_result_l equ $ - msg_result
    newline     db 13, 10

section .bss
    buf         resb 16
    written     resd 1
    hStdOut     resd 1
    hStdIn      resd 1
    ; bin_buf: guardamos los bits YA en orden correcto (MSB primero)
    ; máximo 8 bits para 0-255
    bin_buf     resb 9

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

    ; --- Parsear número decimal ---
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
    mov     ebx, eax            ; ebx = número a convertir

    ; --- Construir bits MSB->LSB usando rotación de bits ---
    ; Usamos 8 bits fijos (para 0-255)
    ; Recorremos del bit 7 al bit 0 con SHR+AND
    lea     edi, [bin_buf]
    mov     ecx, 8              ; 8 bits

.bit_loop:
    ; Tomar el bit más significativo que queda
    ; Rotamos ebx a la izquierda; el bit que sale por CF es el MSB actual
    mov     eax, ebx
    ; Desplazar según posición: bit (ecx-1)
    ; Calculamos: (ebx >> (ecx-1)) AND 1
    push    ecx
    dec     ecx                 ; ecx = posición del bit
    shr     eax, cl             ; desplazar a la derecha cl veces
    and     eax, 1              ; quedarnos con el bit menos significativo
    add     al, '0'             ; convertir a '0' o '1'
    ; Guardar en bin_buf en posición (8 - ecx_original) = posición actual
    pop     ecx
    mov     edx, 8
    sub     edx, ecx            ; índice en buffer = 8 - ecx
    mov     [edi + edx], al
    dec     ecx
    jnz     .bit_loop

    ; --- Imprimir "En binario: " ---
    push    0
    push    written
    push    msg_result_l
    push    msg_result
    push    dword [hStdOut]
    call    _WriteFile@20

    ; --- Imprimir los 8 bits de bin_buf de una sola vez ---
    push    0
    push    written
    push    8
    push    bin_buf
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    push    written
    push    2
    push    newline
    push    dword [hStdOut]
    call    _WriteFile@20

    push    0
    call    _ExitProcess@4