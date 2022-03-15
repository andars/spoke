#ifndef _SERIAL_H_
#define _SERIAL_H_

void serial_open(const char *);
void sendbyte(uint8_t v);
uint8_t recvbyte();
void send_4byte(uint32_t v);

#endif
