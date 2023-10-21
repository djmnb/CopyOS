

char message[] = "hell oworld!!! ";

void kernel_init()
{
    int i = 0, j = 10, k = 1;
    int n = 10;
    char *data = (char *)0xb8000;
    for (; i < sizeof(message); i++)
    {
        data[i * 2] = message[i];
    }
}