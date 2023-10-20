

char message[] = "helloworld";
void kernel_int()
{
    char *data = (char *)0xb8000;
    for (int i = 0; i < sizeof(message); i++)
    {
        data[i * 2] = message[i];
    }
}