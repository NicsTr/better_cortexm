#include <stdint.h>

#include "masking.h"

int test_mask_unmask(void (*rng_fill)(char *, int))
{
    uint16_t masked[8];
    uint16_t v;
    rng_fill((char *)(&v), 2);
    mask_8(v, masked, rng_fill);

    if (unmask_8(masked) != v) return 1;

    return 0;
}
