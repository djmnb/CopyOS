[bits 32]
extern puts

global main

section .data
    message db "heo world", 0

section .text

main:
    push message
    call puts
    add esp, 4  ; Clean up the stack
    mov eax, 1   ; syscall number for sys_exit
    xor ebx, ebx ; exit status 0
    int 0x80     ; interrupt to invoke syscall
