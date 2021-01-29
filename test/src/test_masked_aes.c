#include <stdint.h>

#include "xoshiro.h"
#include "masked_aes_keyschedule.h"
#include "masked_utils.h"
#include "masked_aes.h"

int test_vectors_aes(int seed)
{
    int nb_err = 0;
    prng_init(seed);
    
    uint8_t state[16] = {0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff};
    uint8_t key[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};
    uint16_t rkeys[11][8][8];

    uint16_t masked_bs_key[8][8];
    uint16_t masked_bs_state[8][8];
    uint32_t fresh_randoms[3200];

    prng_fill((uint8_t *)fresh_randoms, 4*3200);
    mask_bitslice_state(state, masked_bs_state);
    mask_bitslice_state(key, masked_bs_key);

    masked_aes_keyschedule128(masked_bs_key, rkeys, fresh_randoms);
    prng_fill((uint8_t *)fresh_randoms, 4*3200);
    masked_aes_encrypt128(masked_bs_state, rkeys, fresh_randoms);

    unbitslice_unmask_state(masked_bs_state, state);
    uint8_t state_ref[16] = { 0x69, 0xc4, 0xe0, 0xd8, 0x6a, 0x7b, 0x04, 0x30, 0xd8, 0xcd, 0xb7, 0x80, 0x70, 0xb4, 0xc5, 0x5a };

    for (int i = 0; i < 16; i++) {
        if (state[i] != state_ref[i]) nb_err++;
    }

    return nb_err;
    

}
