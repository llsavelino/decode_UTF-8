#include "core.h"
#include <stdint.h>

uint32_t Bytes2_utf8(uc8 *x, uc8* y) {
    
    return ((void*)x == NULL || 
        (void*)y == NULL) ? 0x00 : 

            ((uint32_t)(*x & 0x1F) << 6) | 
            (uint32_t)(*y & 0x3F);

}

uint32_t Bytes3_utf8(uc8 *x, uc8 *y, uc8 *z) {
    
    return ((void*)x == NULL || 
        (void*)y == NULL || (void*)z == NULL) ? 0x00 : 

            ((uint32_t)(*x & 0x0F) << 12) | 
            ((uint32_t)(*y & 0x3F) << 6) | 
            (uint32_t)(*z & 0x3F);

}

uint32_t Bytes4_utf8(uc8 *x, uc8 *y, uc8 *z, uc8 *w) {
    
    return ((void*)x == NULL || 
        (void*)y == NULL || (void*)z == NULL || (void*)w == NULL) ? 0x00 : 

            ((uint32_t)(*x & 0x07) << 18) | 
            ((uint32_t)(*y & 0x3F) << 12) | 
            ((uint32_t)(*z & 0x3F) << 6) | 
            (uint32_t)(*w & 0x3F);

}