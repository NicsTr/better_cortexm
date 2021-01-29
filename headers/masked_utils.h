#ifndef MASKED_UTILS_H
#define MASKED_UTILS_H

void mask_bitslice_state(uint8_t state[16], uint16_t masked_bs_state[8][8]);
void unbitslice_unmask_state(uint16_t masked_bs_state[8][8], uint8_t state[16]);

#endif /* MASKED_UTILS_H */
