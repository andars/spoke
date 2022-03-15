#ifndef _COMMON_H_
#define _COMMON_H_

#include <errno.h>
#include <stdlib.h>

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

#endif
