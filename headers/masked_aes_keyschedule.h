#ifndef MASKED_AES_KEYSCHEDULE_H
#define MASKED_AES_KEYSCHEDULE_H
void masked_aes_keyschedule128(uint16_t key[8][8], uint16_t masked_bs_rkeys[11][8][8], void (*rng_fill)(char *, int));
#endif /* MASKED_AES_KEYSCHEDULE_H */
