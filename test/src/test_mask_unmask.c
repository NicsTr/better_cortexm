#include <stdint.h>

#include "xoshiro.h"
#include "masking.h"

int test_mask_unmask(int seed)
{
    prng_init(seed);
    uint16_t masked[8];
    uint16_t v = (uint16_t)(next() & 0xFFFF);
    mask_8(v, masked);

    if (unmask_8(masked) != v) return 1;

    return 0;
}
