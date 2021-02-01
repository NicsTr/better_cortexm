#include <stdint.h>

void masked_aes_keyschedule128(uint16_t key[8][8], uint16_t masked_bs_rkeys[11][8][8], uint32_t fresh_randoms[320]);
void masked_aes_encrypt128(uint16_t state[8][8], uint16_t rkeys[11][8][8], uint32_t fresh_randoms[3200]);

//
void prng_init(int seed);
void prng_fill(char *dst, int size);
void mask_bitslice_state(uint8_t state[16], uint16_t masked_bs_state[8][8]);
void mask_8(uint16_t v, uint16_t dst[8]);
void masked_mixcolumns_8(uint16_t state[8][8]);
void masked_shiftrows_8(uint16_t state[8][8]);
void masked_aes_sbox_8(uint16_t state[8][8], uint32_t fresh_randoms[320]);
void masked_and_8(uint16_t a0[8], uint16_t b0[8], uint16_t a1[8], uint16_t b1[8], uint16_t res0[8], uint16_t res1[8], uint32_t fresh_randoms[20]);
