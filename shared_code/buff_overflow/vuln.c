#include <stdio.h>
#include <unistd.h>

void secret() {
    printf("diverted flow!!!!!");
}

void vuln() {
    char buffer[64];
    read(0, buffer, 128);
    printf("buffer: %s\n", buffer);
}

int main(int argc, char *argv[]) {
    vuln();
    return 0;
}
