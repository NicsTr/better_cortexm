#include <stdint.h>

#include "masking.h"
#include "bitslicing.h"


void mask_bitslice_state(uint8_t state[16], uint16_t masked_bs_state[8][8], void (*rng_fill)(char *, int))
{
    uint32_t tmp0[8];
    uint32_t tmp1[8];
    uint32_t tmp2[8];
    uint32_t tmp3[8];
    mask32_8(((uint32_t *) state)[0], tmp0, rng_fill);
    mask32_8(((uint32_t *) state)[1], tmp1, rng_fill);
    mask32_8(((uint32_t *) state)[2], tmp2, rng_fill);
    mask32_8(((uint32_t *) state)[3], tmp3, rng_fill);

    uint16_t tmp[8];
    for (int i = 0; i < 8; i++) {
        bitslice(tmp0[i], tmp1[i], tmp2[i], tmp3[i], tmp);
        for (int j = 0; j < 8; j++) {
            masked_bs_state[j][i] = tmp[j];
        }
    }

}

void unbitslice_unmask_state(uint16_t masked_bs_state[8][8], uint8_t state[16])
{
    uint16_t bs_state[8];

    for (int i = 0; i < 8; i++) {
            bs_state[i] = unmask_8(masked_bs_state[i]);
    }
    unbitslice(bs_state, (uint32_t *)state);

}
