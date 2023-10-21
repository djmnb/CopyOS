[bits 32]

global _start
extern kernel_init

_start: 
   
   mov ax,10
   mov bx,11


   call kernel_init

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