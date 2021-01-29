#include "masked_and.h"
#include "masked_xor.h"
#include <stdint.h>

// TODO Align operands

void masked_aes_sbox_8(uint16_t state[8][8], uint32_t fresh_randoms[320])
{
    uint16_t  tmp0[8];
    uint16_t  tmp1[8];
    uint16_t  tmp2[8];
    uint16_t  tmp3[8];
    uint16_t  tmp4[8];
    uint16_t  tmp5[8];
    uint16_t  tmp6[8];
    uint16_t  tmp7[8];
    uint16_t  tmp8[8];
    uint16_t  tmp9[8];
    uint16_t tmp10[8];
    uint16_t tmp11[8];
    uint16_t tmp12[8];
    uint16_t tmp13[8];
    uint16_t tmp14[8];
    uint16_t tmp15[8];
    uint16_t tmp16[8];
    uint16_t tmp17[8];
    uint16_t tmp18[8];
    uint16_t tmp19[8];
    uint16_t tmp20[8];
    uint16_t tmp21[8];
    uint16_t tmp22[8];
    uint16_t tmp23[8];


    masked_xor_8(state[3],  state[5],       tmp0); // y14 = U3 + U5
    masked_xor_8(state[0],  state[6],       tmp1); // y13 = U0 + U6
    masked_xor_8(state[0],  state[3],       tmp2); // y9 = U0 + U3
    masked_xor_8(state[0],  state[5],       tmp3); // y8 = U0 + U5
    masked_xor_8(state[1],  state[2],   state[2]); // t0 = U1 + U2
    masked_xor_8(state[2],  state[7],       tmp4); // y1 = t0 + U7
    masked_xor_8(tmp4,      state[3],   state[3]); // y4 = y1 + U3
    masked_xor_8(tmp1,      tmp0,           tmp5); // y12 = y13 + y14
    masked_xor_8(tmp4,      state[0],       tmp6); // y2 = y1 + U0
    masked_xor_8(tmp4,      state[6],   state[6]); // y5 = y1 + U6
    masked_xor_8(state[6],  tmp3,           tmp7); // y3 = y5 + y8
    masked_xor_8(state[4],  tmp5,       state[4]); // t1 = U4 + y12
    masked_xor_8(state[4],  state[5],   state[5]); // y15 = t1 + U5
    masked_xor_8(state[4],  state[1],   state[1]); // y20 = t1 + U1
    masked_xor_8(state[5],  state[7],       tmp8); // y6 = y15 + U7
    masked_xor_8(state[5],  state[2],       tmp9); // y10 = y15 + t0
    masked_xor_8(state[1],  tmp2,          tmp10); // y11 = y20 + y9
    masked_xor_8(state[7],  tmp10,         tmp11); // y7 = U7 + y11
    masked_xor_8(tmp9,      tmp10,         tmp12); // y17 = y10 + y11
    masked_xor_8(tmp9,      tmp3,          tmp13); // y19 = y10 + y8
    masked_xor_8(state[2],  tmp10,      state[2]); // y16 = t0 + y11
    masked_xor_8(tmp1,      state[2],      tmp14); // y21 = y13 + y16
    masked_xor_8(state[0],  state[2],   state[0]); // y18 = U0 + y16
    masked_and_8(tmp5,      state[5], tmp7, tmp8, tmp15, tmp16, &(fresh_randoms[0])); // t2 = y12 x y15; t3 = y3 x y6
    masked_xor_8(tmp16, tmp15, tmp17); // t4 = t3 + t2
    masked_and_8(tmp1, state[2], state[3], state[7], tmp18, tmp19, &(fresh_randoms[20])); // t7 = y13 x y16; t5 = y4 x U7
    masked_xor_8(tmp19, tmp15, tmp19); // t6 = t5 + t2
    masked_and_8(tmp6, tmp11, state[6], tmp4, tmp20, tmp21, &(fresh_randoms[40])); // t10 = y2 x y7; t8 = y5 x y1
    masked_xor_8(tmp21, tmp18, tmp21); // t9 = t8 + t7
    masked_xor_8(tmp20, tmp18, tmp18); // t11 = t10 + t7
    masked_and_8(tmp2, tmp10, tmp0, tmp12, tmp20, tmp22, &(fresh_randoms[60])); // t12 = y9 x y11; t13 = y14 x y17
    masked_xor_8(tmp22, tmp20, tmp22); // t14 = t13 + t12
    masked_xor_8(tmp17, state[1], state[1]); // t17 = t4 + y20
    masked_xor_8(tmp21, tmp22, tmp21); // t19 = t9 + t14
    masked_xor_8(state[1], tmp22, tmp22); // t21 = t17 + t14
    masked_xor_8(tmp21, tmp14, tmp14); // t23 = t19 + y21
    masked_and_8(tmp22, tmp14, tmp3, tmp9, tmp21, state[1], &(fresh_randoms[80])); // t26 = t21 x t23; t15 = y8 x y10
    masked_xor_8(state[1], tmp20, tmp20); // t16 = t15 + t12
    masked_xor_8(tmp19,     tmp20, tmp19); // t18 = t6 + t16
    masked_xor_8(tmp18,     tmp20, tmp18); // t20 = t11 + t16
    masked_xor_8(tmp19,     tmp13, tmp13); // t22 = t18 + y19
    masked_xor_8(tmp18,     state[0], tmp18); // t24 = t20 + y18
    masked_xor_8(tmp22,     tmp13, tmp19); // t25 = t21 + t22
    masked_xor_8(tmp18,     tmp21, tmp20); // t27 = t24 + t26
    masked_xor_8(tmp14,     tmp18, tmp22); // t30 = t23 + t24
    masked_xor_8(tmp13,     tmp21, tmp21); // t31 = t22 + t26
    masked_and_8(tmp21,     tmp22, tmp19, tmp20, tmp21, tmp22, &(fresh_randoms[100])); // t32 = t31 x t30; t28 = t25 x t27
    masked_xor_8(tmp22,     tmp13, tmp13); // t29 = t28 + t22
    masked_xor_8(tmp21,     tmp18, tmp21); // t33 = t32 + t24
    masked_xor_8(tmp14,     tmp21, tmp14); // t34 = t23 + t33
    masked_xor_8(tmp20,     tmp21, tmp22); // t35 = t27 + t33
    masked_and_8(tmp21,     state[7], tmp18, tmp22, state[7], tmp18, &(fresh_randoms[120])); // z2 = t33 x U7; t36 = t24 x t35
    masked_xor_8(tmp18,     tmp14, tmp14); // t37 = t36 + t34
    masked_xor_8(tmp20,     tmp18, tmp18); // t38 = t27 + t36
    masked_xor_8(tmp21,     tmp14, tmp20); // t44 = t33 + t37
    masked_and_8(tmp20,     state[5], tmp13, tmp18, tmp22, tmp18, &(fresh_randoms[140])); // z0 = t44 x y15; t39 = t29 x t38
    masked_xor_8(tmp19,     tmp18, tmp18); // t40 = t25 + t39
    masked_xor_8(tmp18,     tmp14, tmp19); // t41 = t40 + t37
    masked_xor_8(tmp13,     tmp21, state[1]); // t42 = t29 + t33
    masked_xor_8(tmp13,     tmp18, state[4]); // t43 = t29 + t40
    masked_xor_8(state[1], tmp19, state[5]); // t45 = t42 + t41
    masked_and_8(tmp14, tmp8, state[4], state[2], tmp8, state[2], &(fresh_randoms[160])); // z1 = t37 x y6; z3 = t43 x y16
    masked_and_8(tmp18, tmp4, tmp13, tmp11, tmp23, tmp11, &(fresh_randoms[180])); // z4 = t40 x y1; z5 = t29 x y7
    masked_and_8(state[1], tmp10, state[5], tmp12, tmp10, tmp12, &(fresh_randoms[200])); // z6 = t42 x y11; z7 = t45 x y17
    masked_and_8(tmp19, tmp9, tmp20, tmp5, tmp9, tmp5, &(fresh_randoms[220])); // z8 = t41 x y10; z9 = t44 x y12
    masked_and_8(tmp14, tmp7, tmp21, state[3], tmp7, tmp14, &(fresh_randoms[240])); // z10 = t37 x y3; z11 = t33 x y4
    masked_and_8(state[4], tmp1, tmp18, state[6], tmp1, tmp16, &(fresh_randoms[260])); // z12 = t43 x y13; z13 = t40 x y5
    masked_and_8(tmp13, tmp6, state[1], tmp2, tmp6, tmp2, &(fresh_randoms[280])); // z14 = t29 x y2; z15 = t42 x y9
    masked_and_8(state[5], tmp0, tmp19, tmp3, tmp0, tmp3, &(fresh_randoms[300])); // z16 = t45 x y14; z17 = t41 x y8
    masked_xor_8(tmp2, tmp0, tmp0); // tc1 = z15 + z16
    masked_xor_8(tmp7, tmp0, tmp4); // tc2 = z10 + tc1
    masked_xor_8(tmp5, tmp4, tmp5); // tc3 = z9 + tc2
    masked_xor_8(tmp22, state[7], tmp7); // tc4 = z0 + z2
    masked_xor_8(tmp8, tmp22, tmp13); // tc5 = z1 + z0
    masked_xor_8(state[2], tmp23, tmp15); // tc6 = z3 + z4
    masked_xor_8(tmp1, tmp7, tmp17); // tc7 = z12 + tc4
    masked_xor_8(tmp12, tmp15, tmp12); // tc8 = z7 + tc6
    masked_xor_8(tmp9, tmp17, tmp9); // tc9 = z8 + tc7
    masked_xor_8(tmp12, tmp9, tmp9); // tc10 = tc8 + tc9
    masked_xor_8(tmp15, tmp13, tmp13); // tc11 = tc6 + tc5
    masked_xor_8(state[2], tmp11, tmp11); // tc12 = z3 + z5
    masked_xor_8(tmp16, tmp0, tmp15); // tc13 = z13 + tc1
    masked_xor_8(tmp7, tmp11, tmp7); // tc14 = tc4 + tc12

    masked_xor_8(tmp5, tmp13, state[3]); // S3 = tc3 + tc11
    masked_xor_8(tmp10, tmp12, tmp10); // tc16 = z6 + tc8
    masked_xor_8(tmp6, tmp9, tmp6); // tc17 = z14 + tc10
    masked_xor_8(tmp15, tmp7, tmp12); // tc18 = tc13 + tc14
    masked_xor_8(tmp1, tmp12, state[7]); // S7 = z12 # tc18
    state[7][0] = ~state[7][0];
    masked_xor_8(tmp2, tmp10, tmp1); // tc20 = z15 + tc16
    masked_xor_8(tmp4, tmp14, tmp2); // tc21 = tc2 + z11
    masked_xor_8(tmp5, tmp10, state[0]); // S0 = tc3 + tc16
    masked_xor_8(tmp9, tmp12, state[6]); // S6 = tc10 # tc18
    state[6][0] = ~state[6][0];
    masked_xor_8(tmp7, state[3], state[4]); // S4 = tc14 + S3
    masked_xor_8(state[3], tmp10, state[1]); // S1 = S3 # tc16
    state[1][0] = ~state[1][0];
    masked_xor_8(tmp6, tmp1, tmp1); // tc26 = tc17 + tc20
    masked_xor_8(tmp1, tmp3, state[2]); // S2 = tc26 # z17
    state[2][0] = ~state[2][0];
    masked_xor_8(tmp2, tmp6, state[5]); // S5 = tc21 + tc17

}

