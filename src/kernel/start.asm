[bits 32]

global _start
extern kernel_int

_start:

    
   call kernel_int

    jmp $


print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret

;start: db "start HardOs....",10,13,0