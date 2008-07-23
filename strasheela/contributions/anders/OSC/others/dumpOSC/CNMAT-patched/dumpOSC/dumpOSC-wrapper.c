#include <stdio.h>

int main()
{
    char buf[1024];
    int pos=0;
    char c;
    FILE* f = popen("./dumpOSC 8000", "r");
    if (!f) {
        printf("Couldn't execute dumpOSC.\n");
        return 1;
    }

    while (fgets(buf, 1024, f)) {
        printf("%s", buf);
    }

    return 0;
}

