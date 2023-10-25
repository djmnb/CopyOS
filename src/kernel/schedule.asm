;假设是从a切换到b
global task_switch
task_switch:
    push ebp  ; sp -= 4  来到了程序栈顶
    mov ebp, esp ; 记录程序 进来时栈的指针 - 4   

    push ebx
    push esi
    push edi

    mov eax, esp;
    and eax, 0xfffff000; current

    mov [eax], esp

    mov eax, [ebp + 8]; next
    mov esp, [eax]

    pop edi
    pop esi
    pop ebx
    pop ebp

    ret
