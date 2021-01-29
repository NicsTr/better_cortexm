#include <stdint.h>

#include "masked_ror.h"
#include "masked_xor.h"


void masked_mixcolumns_8(uint16_t state[8][8])
{
    uint16_t tmp0[8];
    uint16_t tmp1[8];
    uint16_t tmp2[8];

    masked_ror4_8(state[0], tmp0);
    masked_xor_8(tmp0,      state[0],       tmp0);      // R0 + (R0 >>> 4) 

    // Start R'0
    masked_ror4_8(state[1], tmp1);
    masked_xor_8(tmp1,      state[1],       tmp1);      // R1 + (R1 >>> 4)

    masked_ror4_8(state[0], state[0]);
    masked_xor_8(state[0],  tmp1,           state[0]);  // (R0 >>> 4) + (R1 + (R1 >>> 4))
    masked_ror8_8(tmp0,     tmp2);                      // (R0 + (R0 >>> 4)) >>> 16
    masked_xor_8(state[0],  tmp2,           state[0]);
    
    //Start R'1
    masked_ror4_8(state[2], tmp2);
    masked_xor_8(tmp2,      state[2],       tmp2);      // R2 + (R2 >>> 4)

    masked_ror4_8(state[1], state[1]);
    masked_xor_8(state[1],  tmp2,           state[1]);
    masked_ror8_8(tmp1,     tmp1);                      // (R1 + (R1 >>> 4)) >>> 16
    masked_xor_8(state[1],  tmp1,           state[1]);

    //Start R'2
    masked_ror4_8(state[3], tmp1);
    masked_xor_8(tmp1,      state[3],       tmp1);      // R3 + (R3 >>> 4)

    masked_ror8_8(tmp2,     tmp2);                      // (R2 + (R2 >>> 4)) >>> 16
    masked_ror4_8(state[2], state[2]);
    masked_xor_8(state[2],  tmp1,           state[2]);
    masked_xor_8(state[2],  tmp2,           state[2]);

    //Start R'3
    masked_ror4_8(state[4], tmp2);
    masked_xor_8(tmp2,      state[4],       tmp2);      // R4 + (R4 >>> 4)

    masked_ror8_8(tmp1,     tmp1);                      // (R3 + (R3 >>> 4)) >>> 16
    masked_ror4_8(state[3], state[3]);
    masked_xor_8(state[3],  tmp2,           state[3]);
    masked_xor_8(state[3],  tmp1,           state[3]);
    masked_xor_8(state[3],  tmp0,           state[3]);  // Adding R0

    //Start R'4
    masked_ror4_8(state[5], tmp1);
    masked_xor_8(tmp1,      state[5],       tmp1);      // R5 + (R5 >>> 4)

    masked_ror8_8(tmp2,     tmp2);                      // (R4 + (R4 >>> 4)) >>> 16
    masked_ror4_8(state[4], state[4]);
    masked_xor_8(state[4],  tmp1,           state[4]);
    masked_xor_8(state[4],  tmp2,           state[4]);
    masked_xor_8(state[4],  tmp0,           state[4]);  // Adding R0

    //Start R'5
    masked_ror4_8(state[6], tmp2);
    masked_xor_8(tmp2,      state[6],       tmp2);      // R6 + (R6 >>> 4)

    masked_ror8_8(tmp1,     tmp1);                      // (R5 + (R5 >>> 4)) >>> 16
    masked_ror4_8(state[5], state[5]);
    masked_xor_8(state[5],  tmp2,           state[5]);
    masked_xor_8(state[5],  tmp1,           state[5]);

    //Start R'6
    masked_ror4_8(state[7], tmp1);
    masked_xor_8(tmp1,      state[7],       tmp1);      // R7 + (R7 >>> 4)

    masked_ror8_8(tmp2,     tmp2);                      // (R6 + (R6 >>> 4)) >>> 16
    masked_ror4_8(state[6], state[6]);
    masked_xor_8(state[6],  tmp1,           state[6]);
    masked_xor_8(state[6],  tmp2,           state[6]);
    masked_xor_8(state[6],  tmp0,           state[6]);  // Adding R0

    // Start R'7
    masked_ror4_8(state[7], state[7]);
    masked_xor_8(state[7],  tmp0,           state[7]);
    masked_ror8_8(tmp1,     tmp1);                      // (R7 + (R7 >>> 4)) >>> 16
    masked_xor_8(state[7],  tmp1,           state[7]);

}
