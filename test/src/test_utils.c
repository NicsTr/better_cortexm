#include <stdint.h>

#include "xoshiro.h"
#include "masked_utils.h"

int test_utils(int seed)
{
    prng_init(seed);

    uint8_t state[16];
    uint8_t state1[16];
    int nb_err = 0;
    prng_fill(state, 16);

    uint16_t masked_bs_state[8][8];
    mask_bitslice_state(state, masked_bs_state);
    unbitslice_unmask_state(masked_bs_state, state1);

    for (int i = 0; i < 16; i++) {
        if (state[i] != state1[i]) nb_err++;
    }

    return nb_err;
}
