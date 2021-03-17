#include <stdint.h>

#include "bitslicing.h"

int test_bitslicing(void (*rng_fill)(char *, int))
{
    int nb_err = 0;
    uint32_t state0[4];
    uint32_t state1[4];
    uint16_t bs_state[8];
    rng_fill((uint8_t *)state0, 16);
    bitslice(state0[0], state0[1], state0[2], state0[3], bs_state);
    unbitslice(bs_state, state1);

    for (int i = 0; i < 4; i++) {
        if (state0[i] != state1[i]) nb_err++;
    }
    
    return nb_err;
}
