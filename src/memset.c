#include <stdint.h>
#include <stddef.h>

void* memset (void* ptr, int value, size_t num ) {
    uint8_t* p = (uint8_t*)ptr;
    for (size_t i = 0; i < num; i++, p++) {
        *p = value;
    }
    return ptr;
}
