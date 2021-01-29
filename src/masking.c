#include <stdint.h>
#include "xoshiro.h"

void mask_8(uint16_t v, uint16_t dst[8])
{
    prng_fill((char *)dst, 7*2);

    uint16_t tmp = 0;
    for (int i = 0; i < 7; i++) {
        tmp ^= dst[i];
    }
    dst[7] = tmp ^ v;
}

void mask32_8(uint32_t v, uint32_t dst[8])
{
    prng_fill((char *)dst, 7*4);

    uint32_t tmp = 0;
    for (int i = 0; i < 7; i++) {
        tmp ^= dst[i];
    }
    dst[7] = tmp ^ v;
}
            
uint16_t unmask_8(uint16_t v[8])
{
    uint16_t res = 0;
    for (int i = 0; i < 8; i++) {
        res ^= v[i];
    }
    return res;
}

uint32_t unmask32_8(uint32_t v[8])
{
    uint32_t res = 0;
    for (int i = 0; i < 8; i++) {
        res ^= v[i];
    }
    return res;
}
