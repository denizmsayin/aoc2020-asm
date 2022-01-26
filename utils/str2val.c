#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum mode {
    BYTE,
    SHORT,
    DEFAULT,
    LONG
};

enum mode get_mode(const char *mode)
{
    if (!strcmp(mode, "byte"))
        return BYTE;
    else if (!strcmp(mode, "short"))
        return SHORT;
    else if (!strcmp(mode, "long"))
        return LONG;
    else
        return DEFAULT;
}

int main(int argc, char *argv[])
{
    static char buf[256];
    enum mode mode = DEFAULT;

    if (argc > 1)
        mode = get_mode(argv[1]);

    while (fgets(buf, 256, stdin)) {
        buf[strcspn(buf, "\n")] = 0;
        switch (mode) {
            case BYTE: {
                unsigned char x = *(unsigned char *) buf;
                printf("0x%02hhx\n", x);
                break;
            }
            case SHORT: {
                unsigned short x = *(unsigned short *) buf;
                printf("0x%04hx\n", x);
                break;
            }
            case DEFAULT: {
                unsigned int x = *(unsigned int *) buf;
                printf("0x%08x\n", x);
                break;
            }
            case LONG: {
                unsigned long x = *(unsigned long *) buf;
                printf("0x%016lx\n", x);
                break;
            }
        }
        memset(buf, 0, 256);
    }

    return 0;
}
