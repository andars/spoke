#include <stdio.h>
#include <stdint.h>

#include "common.h"
#include "serial.h"

#define FILENAME "/dev/ttyUSB1"

int main(int argc, char *argv[]) {
    serial_open(FILENAME);

    for (int i = 1; i < 16; i++) {
        uint8_t c = i;
        printf("sending 0x%x\n", c);
        sendbyte(c);
        uint8_t r = recvbyte();
        printf("received 0x%x\n", r);
    }
    printf("---\n");


    for (int i = 0; i < 256; i++) {
        uint8_t c = i;
        printf("sending 0x%x\n", c);
        sendbyte(c);
    }
    printf("---\n");

    for (int i = 0; i < 256; i++) {
        uint8_t c = recvbyte();
        printf("received 0x%x\n", c);
        ASSERT_EQ(c, i);
    }
    printf("---\n");
    for (int i = 0; i < 1024; i++) {
        uint8_t c = i;
        printf("sending 0x%x\n", c);
        sendbyte(c);
    }
    printf("---\n");

    for (int i = 0; i < 1024;i++) {
        uint8_t c = recvbyte();
        printf("received 0x%x\n", c);
        ASSERT_EQ(c, (uint8_t)i);
    }
}
