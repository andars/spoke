#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <termios.h>
#include <unistd.h>

#define FILENAME "/dev/ttyUSB1"

#define FAIL_ERRNO(...) \
    do { \
        fprintf(stderr, __VA_ARGS__); \
        fprintf(stderr, " - failed at %s:%d - %s\n", __FILE__, __LINE__, strerror(errno)); \
        exit(EXIT_FAILURE); \
    } while (0);

static int fd;

static void sendbyte(uint8_t v) {
    int n = write(fd, &v, sizeof(char));
    if (n < 0) {
        FAIL_ERRNO("writing byte to serial port");
    }
}
static uint8_t recvbyte() {
    uint8_t v;
    int n = read(fd, &v, sizeof(char));
    if (n < 0) {
        FAIL_ERRNO("reading byte from serial port");
    }
    return v;
}

int main(int argc, char *argv[]) {

    fd = open(FILENAME, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        FAIL_ERRNO("opening serial port %s", FILENAME);
    }
    
    struct termios options = { 0 };

    cfmakeraw(&options);
    cfsetispeed(&options, B9600);
    cfsetospeed(&options, B9600);
    options.c_cflag |= CLOCAL | CREAD;
    options.c_cc[VTIME] = 0;
    options.c_cc[VMIN] = 1;

    tcsetattr(fd,TCSANOW,&options);

    for (int i = 0; i < 256; i++) {
        uint8_t c = i;
        printf("sending 0x%x\n", c);
        sendbyte(c);
    }
    printf("---\n");

    for (int i = 0; i < 256; i++) {
        uint8_t c = recvbyte();
        printf("received 0x%x\n", c);
    }
    printf("---\n");
}
