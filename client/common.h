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

#define ASSERT_EQ(a, b) \
    do { \
        int _a = (a); \
        int _b = (b); \
        if ((_a) != (_b)) { \
            FAIL("%s (0x%x) != %s (0x%x)\n", #a, _a, #b, _b); \
        } \
    } while (0)

#endif
