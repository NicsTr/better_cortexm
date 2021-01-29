#include <stdint.h>

#include "masking.h"
#include "masked_aes_sbox.h"
#include "masked_rotword_xorcol.h"

void static inline copy_state(const uint16_t state_in[8][8], uint16_t state_out[8][8])
{
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            state_out[i][j] = state_in[i][j];
        }
    }
}

void masked_aes_keyschedule128(uint16_t key[8][8], uint16_t masked_bs_rkeys[11][8][8])
{
    // Init first round key to be the key itself
    copy_state(key, masked_bs_rkeys[0]);


    // Derive each key from the previous one
    copy_state(masked_bs_rkeys[0], masked_bs_rkeys[1]);
    masked_aes_sbox_8(masked_bs_rkeys[1]);
    // Row 1 col 3, such that it is at the right place after rotword
    // RCON0 = 0x01
    masked_bs_rkeys[1][7][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[0], masked_bs_rkeys[1]);

    copy_state(masked_bs_rkeys[1], masked_bs_rkeys[2]);
    masked_aes_sbox_8(masked_bs_rkeys[2]);
    // RCON1 = 0x02
    masked_bs_rkeys[2][6][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[1], masked_bs_rkeys[2]);

    copy_state(masked_bs_rkeys[2], masked_bs_rkeys[3]);
    masked_aes_sbox_8(masked_bs_rkeys[3]);
    // RCON2 = 0x04
    masked_bs_rkeys[3][5][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[2], masked_bs_rkeys[3]);

    copy_state(masked_bs_rkeys[3], masked_bs_rkeys[4]);
    masked_aes_sbox_8(masked_bs_rkeys[4]);
    // RCON3 = 0x08
    masked_bs_rkeys[4][4][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[3], masked_bs_rkeys[4]);

    copy_state(masked_bs_rkeys[4], masked_bs_rkeys[5]);
    masked_aes_sbox_8(masked_bs_rkeys[5]);
    // RCON4 = 0x10
    masked_bs_rkeys[5][3][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[4], masked_bs_rkeys[5]);

    copy_state(masked_bs_rkeys[5], masked_bs_rkeys[6]);
    masked_aes_sbox_8(masked_bs_rkeys[6]);
    // RCON5 = 0x20
    masked_bs_rkeys[6][2][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[5], masked_bs_rkeys[6]);

    copy_state(masked_bs_rkeys[6], masked_bs_rkeys[7]);
    masked_aes_sbox_8(masked_bs_rkeys[7]);
    // RCON6 = 0x40
    masked_bs_rkeys[7][1][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[6], masked_bs_rkeys[7]);

    copy_state(masked_bs_rkeys[7], masked_bs_rkeys[8]);
    masked_aes_sbox_8(masked_bs_rkeys[8]);
    // RCON7 = 0x80
    masked_bs_rkeys[8][0][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[7], masked_bs_rkeys[8]);

    copy_state(masked_bs_rkeys[8], masked_bs_rkeys[9]);
    masked_aes_sbox_8(masked_bs_rkeys[9]);
    // RCON8 = 0x1B
    masked_bs_rkeys[9][3][0] ^= 0x0010;
    masked_bs_rkeys[9][4][0] ^= 0x0010;
    masked_bs_rkeys[9][6][0] ^= 0x0010;
    masked_bs_rkeys[9][7][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[8], masked_bs_rkeys[9]);

    copy_state(masked_bs_rkeys[9], masked_bs_rkeys[10]);
    masked_aes_sbox_8(masked_bs_rkeys[10]);
    // RCON9 = 0x36
    masked_bs_rkeys[10][2][0] ^= 0x0010;
    masked_bs_rkeys[10][3][0] ^= 0x0010;
    masked_bs_rkeys[10][5][0] ^= 0x0010;
    masked_bs_rkeys[10][6][0] ^= 0x0010;
    masked_rotword_xorcol(masked_bs_rkeys[9], masked_bs_rkeys[10]);
}
