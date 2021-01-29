#include <stdint.h>
#include "xoshiro.h"
#include "masked_and.h"

int test_and(int seed)
{
    prng_init(seed);
    uint16_t a0[8];
    uint16_t b0[8];
    uint16_t a1[8];
    uint16_t b1[8];
    uint16_t res0[8];
    uint16_t res1[8];

    prng_fill((char *)a0, 2*8);
    prng_fill((char *)b0, 2*8);
    prng_fill((char *)a1, 2*8);
    prng_fill((char *)b1, 2*8);

    masked_and_8(a0, b0, a1, b1, res0, res1);

    // Verif
    uint16_t a0_unmasked  = 0;
    uint16_t b0_unmasked  = 0;
    uint16_t a1_unmasked  = 0;
    uint16_t b1_unmasked  = 0;
    uint16_t res0_unmasked = 0;
    uint16_t res1_unmasked = 0;
    for (int i = 0; i < 8; i++) {
        a0_unmasked  ^= a0[i];
        b0_unmasked  ^= b0[i];
        a1_unmasked  ^= a1[i];
        b1_unmasked  ^= b1[i];
        res0_unmasked ^= res0[i];
        res1_unmasked ^= res1[i];
    }

    uint16_t res0_true = (a0_unmasked & b0_unmasked); 
    uint16_t res1_true = (a1_unmasked & b1_unmasked);
    if (res0_true != res0_unmasked || res1_true != res1_unmasked) {
        return -1;
    }
    return 0;

}
