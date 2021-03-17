#ifndef MASKING_H
#define MASKING_H

void mask_8(uint16_t v, uint16_t dst[8], void (*rng_fill)(char *, int));
void mask32_8(uint32_t v, uint32_t dst[8], void (*rng_fill)(char *, int));
uint16_t unmask_8(uint16_t v[8]);
uint32_t unmask32_8(uint32_t v[8]);

#endif /* MASKING_H */
