#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <termios.h>
#include <unistd.h>

#include "common.h"

static int fd;

void serial_open(const char *filename) {
    fd = open(filename, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        FAIL_ERRNO("opening serial port %s", filename);
    }

    struct termios options = { 0 };

    cfmakeraw(&options);
    cfsetispeed(&options, B57600);
    cfsetospeed(&options, B57600);
    options.c_cflag |= CLOCAL | CREAD;
    options.c_cc[VTIME] = 0;
    options.c_cc[VMIN] = 1;

    tcsetattr(fd,TCSANOW,&options);
}

void sendbyte(uint8_t v) {
    int n = write(fd, &v, sizeof(char));
    if (n < 0) {
        FAIL_ERRNO("writing byte to serial port");
    }
}

uint8_t recvbyte() {
    uint8_t v;
    int n = read(fd, &v, sizeof(char));
    if (n < 0) {
        FAIL_ERRNO("reading byte from serial port");
    }
    return v;
}

void send_4byte(uint32_t v) {
    sendbyte((v      ) & 0xff);
    sendbyte((v >>  8) & 0xff);
    sendbyte((v >> 16) & 0xff);
    sendbyte((v >> 24) & 0xff);
}
