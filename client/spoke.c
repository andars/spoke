#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <limits.h>

#include "common.h"
#include "serial.h"

#define FILENAME "/dev/ttyUSB1"

#define SPOKE_CTRL_READ  (0x0)
#define SPOKE_CTRL_WRITE (0x1)
#define SPOKE_WRITE_ACK_VALUE (0xaa)

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
    printf("write 0x%x to 0x%x...", data, addr); fflush(stdout);
    spoke_write(addr, data);
    printf("done\n"); fflush(stdout);
}

static uint32_t spoke_read_v(uint32_t addr) {
    printf("read from 0x%x...", addr); fflush(stdout);
    uint32_t data = spoke_read(addr);
    printf(" data 0x%x done\n", data); fflush(stdout);
    return data;
}

static void write_file(const char *fname, uint32_t addr, int length) {
    FILE *in = fopen(fname, "rb");
    uint8_t data;
    uint32_t offset = 0;
    int count = 0;

    while ((fread(&data, 1, 1, in) == 1) && (count < length)) {
        uint32_t d = data;
        spoke_write_v(addr + offset, d);
        offset += 4;
        count++;
    }
}

int main(int argc, char *argv[]) {
    uint32_t addr = 0;
    char *fname = NULL;
    int opt;
    int length = INT_MAX;
    while ((opt = getopt(argc, argv, "f:a:l:")) != -1) {
        switch (opt) {
        case 'a':
            addr = strtoul(optarg, NULL, 16);
            break;
        case 'f':
            fname = optarg;
            break;
        case 'l':
            length = atoi(optarg);
            break;
        default:
            FAIL("invalid option");
            break;
        }
    }

    serial_open(FILENAME);

    if (fname) {
        write_file(fname, addr, length);
    } else {
        // wishbone 2 reg test (responds to all addresses)

        uint32_t wr0, rd0;
        uint32_t wr1, rd1;

        // write to an even address
        wr0 = 0xaa223311;
        spoke_write_v(0x77bbaa88, wr0);

        // read it back
        rd0 = spoke_read_v(0x77bbaa88);
        ASSERT_EQ(wr0, rd0);

        // read back an odd address
        (void)spoke_read_v(0x99eedd89);

        // write to an odd address
        wr1 = 0xaabbccdd;
        spoke_write_v(0x99eedd89, wr1);

        // read it back
        rd1 = spoke_read_v(0x99eedd89);
        ASSERT_EQ(wr1, rd1);

        // check that the even register did not change
        rd0 = spoke_read_v(0x77bbaa88);
        ASSERT_EQ(wr0, rd0);

        printf("done\n");
    }
}
