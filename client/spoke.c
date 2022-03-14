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

#define SPOKE_CTRL_READ  (0x0)
#define SPOKE_CTRL_WRITE (0x1)
#define SPOKE_WRITE_ACK_VALUE (0xaa)

#define FAIL_ERRNO(...) \
    do { \
        fprintf(stderr, __VA_ARGS__); \
        fprintf(stderr, " - failed at %s:%d - %s\n", __FILE__, __LINE__, strerror(errno)); \
        exit(EXIT_FAILURE); \
    } while (0);

#define FAIL(...) \
    do { \
        fprintf(stderr, __VA_ARGS__); \
        fprintf(stderr, " - failed at %s:%d\n", __FILE__, __LINE__); \
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

static void send_4byte(uint32_t v) {
    sendbyte((v      ) & 0xff);
    sendbyte((v >>  8) & 0xff);
    sendbyte((v >> 16) & 0xff);
    sendbyte((v >> 24) & 0xff);
}

static void spoke_write(uint32_t addr, uint32_t data) {
    const uint8_t control = SPOKE_CTRL_WRITE;

    // send the write request
    sendbyte(control);
    send_4byte(addr);
    send_4byte(data);

    // wait for the ack
    uint8_t ack = recvbyte();
    if (ack != SPOKE_WRITE_ACK_VALUE) {
        FAIL("write ack was not the expected value. got 0x%x, expected 0x%x\n", ack, SPOKE_WRITE_ACK_VALUE);
    }
}

static uint32_t spoke_read(uint32_t addr) {
    const uint8_t control = SPOKE_CTRL_READ;

    // send the read request
    sendbyte(control);
    send_4byte(addr);

    // receive the response data
    uint32_t data = 0;
    data |= recvbyte();
    data |= recvbyte() << 8;
    data |= recvbyte() << 16;
    data |= recvbyte() << 24;

    return data;
}

static void spoke_write_v(uint32_t addr, uint32_t data) {
    spoke_write(addr, data);
    printf("wrote 0x%x to 0x%x\n", data, addr);
}

static uint32_t spoke_read_v(uint32_t addr) {
    uint32_t data = spoke_read(addr);
    printf("read 0x%x from 0x%x\n", data, addr);
    return data;
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

    // write to an even address
    spoke_write_v(0x77bbaa88, 0xaa223311);

    // read it back
    (void)spoke_read_v(0x77bbaa88);

    // read back an odd address
    (void)spoke_read_v(0x99eedd89);

    printf("done\n");
}
