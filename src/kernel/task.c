#include <onix/task.h>
#include <onix/printk.h>
#include <onix/debug.h>

#define PAGE_SIZE 0x1000

task_t *a = (task_t *)0x1000;
task_t *b = (task_t *)0x2000;

extern void task_switch(task_t *next);

// 根据栈顶指针得到当前是哪个进程在运行
task_t *running_task()
{
    asm volatile(
        "movl %esp, %eax\n"
        "andl $0xfffff000, %eax\n");
}

void schedule()
{
    task_t *current = running_task();
    // 切换进程
    task_t *next = current == a ? b : a;

    task_switch(next);
}

u32 thread_a()
{
    while (true)
    {
        printk("A");
        schedule();
    }
}

u32 thread_b()
{
    while (true)
    {
        printk("B");
        schedule();
    }
}

// 创建进程
static void task_create(task_t *task, target_t target)
{
    u32 stack = (u32)task + PAGE_SIZE; // 设置顶底到最底端

    stack -= sizeof(task_frame_t); // 留出栈空间设置数据,  这里很巧妙, 用顺序写的方式代替了栈反着写
    task_frame_t *frame = (task_frame_t *)stack;
    frame->ebx = 0x11111111;
    frame->esi = 0x22222222;
    frame->edi = 0x33333333;
    frame->ebp = 0x44444444;
    frame->eip = (void *)target; // 记录程序位置

    task->stack = (u32 *)stack; // 设置栈值
}

void task_init()
{
    task_create(a, thread_a); // 创建进程
    task_create(b, thread_b);
    schedule();
}
