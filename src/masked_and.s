.syntax unified
.thumb


// Load inside a single register the share at offset off for both r0 and r1
// Require:
//  - One register to store the result (rd) which can be equal to r0 (but
//  trashed)
//  - One temporary register (tmp) which can be equal to r2 (but trashed)
//  - a0 and a1 containing the address of the shared value to load
//  - off the offset to load
// Result:
//  - rd contains (a0[off] << 16) || a1[off]
.macro double_ldr rd, a0, a1, off, tmp
    ldrh \rd,  [\a0, \off]
    ldrh \tmp, [\a1, \off]
    orr  \rd,  \tmp, \rd, LSL #16
.endm

.macro prologue
    push {r4-r11, lr} // Save registers of caller, somehow r12 is a scratch register
.endm

.macro epilogue
    pop {r4-r11, pc} // Restore saved registers of caller and resume inside caller
.endm

// intertwined operands to prepare for masked and
// Require:
//  - r0, r1, r2, r3 containing the address of the operands (r0 & r1 and r2 & r3)
//  - 

// /!\ Every gp registers (r0 - r15) will be used /!\
// /!\ except for r15 (PC) and r13 (SP) /!\

// Result:
// ai = (r0[i] << 16) || r2[i]
// bi = (r1[i] << 16) || r3[i]
// Layout at the end:
// Registers:
// r0:  X
// r1:  X
// r2:  X
// r3:  X
// r4:  a0
// r5:  a1
// r6:  a2
// r7:  a3
// r8:  b0
// r9:  b1
// r10: b2
// r11: b3
// r12: b4
// r14: b5

// Stack:
// sp +  36: result array addr
// sp +  32: start of saved registers
// ...
// sp     : end of saved registers
// sp -   4: a4
// sp -   8: a5
// sp -  12: a6
// sp -  16: a7
// sp -  20: b6
// sp -  24: b7

// 4 blocks of load/store and start with load (hopefully pipelined with random storing)
.macro load_operands_masked_and_8

    ldrh r8,  [r2, #8]   // half of a4
    ldrh r9,  [r2, #10]  // half of a5
    ldrh r10, [r2, #12]  // half of a6
    ldrh r11, [r2, #14]  // half of a7


    ldrh r4, [r0, #8]   // other half of a4
    ldrh r5, [r0, #10]  // other half of a5
    ldrh r6, [r0, #12]  // other half of a6
    ldrh r7, [r0, #14]  // other half of a7

    orr  r4, r8, r4,  LSL #16 // combine a4
    orr  r5, r9, r5,  LSL #16 // combine a5

    ldrh r12,  [r3, #12]  // half of b6
    ldrh r14,  [r3, #14]  // half of b7

    ldrh r8,  [r1, #12]  // other half of b6
    ldrh r9,  [r1, #14]  // other half of b7

    orr  r6, r10, r6,  LSL #16 // combine a6
    orr  r7, r11, r7,  LSL #16 // combine a7

    orr  r8, r12, r8, LSL #16 // combine b6 
    orr  r9, r14, r9, LSL #16 // combine b7

    //stmdb      sp, {r4, r5, r6, r7, r8, r9} // /!\ not in the right order

    // Store values computed before bewteen sp-4 and sp-24 
    str  r4, [sp, #-4 ]
    str  r5, [sp, #-8 ]
    str  r6, [sp, #-12]
    str  r7, [sp, #-16]
    str  r8, [sp, #-20]
    str  r9, [sp, #-24]

    // Available registers : r4-r12, r14

    ldrh r4,  [r2,  #0] // Load r2[0] into r4
    ldrh r5,  [r2,  #2] // Load r2[1] into r5
    ldrh r6,  [r2,  #4] // Load r2[2] into r6
    ldrh r7,  [r2,  #6] // Load r2[3] into r7

    ldrh r8,  [r0, #0] // Load r0[0] into r8
    ldrh r9,  [r0, #2] // Load r0[1] into r9
    ldrh r10, [r0, #4] // Load r0[2] into r10
    ldrh r11, [r0, #6] // Load r0[3] into r11

    ldrh r0,  [r3, #0] // half of b0
    ldrh r2,  [r3, #2] // half of b1

    ldrh r12,  [r1, #0] // other half of b0
    ldrh r14,  [r1, #2] // other half of b1

    // Available registers: None

    // Load second part of the register (r0[i] << 16)
    orr  r4, r4,  r8, LSL #16 // combine a0
    orr  r5, r5,  r9, LSL #16 // combine a1
    orr  r6, r6, r10, LSL #16 // combine a2
    orr  r7, r7, r11, LSL #16 // combine a3

    orr  r8, r0, r12, LSL #16 // combine b0
    orr  r9, r2, r14, LSL #16 // combine b1

    // Available registers: r0, r2, r10, r11, r12, r14

    ldrh r10, [r3, #4] // half of b2
    ldrh r2,  [r3, #6] // half of b3
    ldrh r0,  [r3, #8] // half of b4
    ldrh r3,  [r3, #10]// half of b5

    ldrh r11, [r1, #4] // other half of b2
    ldrh r12, [r1, #6] // other half of b3
    ldrh r14, [r1, #8] // other half of b4
    ldrh r1,  [r1, #10]// other half of b5

    orr  r10, r10, r11, LSL #16 // combine b2
    orr  r11,  r2, r12, LSL #16 // combine b3
    orr  r12,  r0, r14, LSL #16 // combine b4
    orr  r14,  r3,  r1, LSL #16 // combine b5

    // Available register : r0, r1, r2, r3

.endm

// Require:
//  - One tmp register
// 
// Result:
//  - Stack:
// sp -  28: 0 
// ...
// sp - 104: 0
// TODO: More generic zeroing out memory
.macro zero_random tmp
    eor \tmp, \tmp, \tmp // \tmp = 0
    str \tmp, [sp, #-28]
    str \tmp, [sp, #-32]
    str \tmp, [sp, #-36]
    str \tmp, [sp, #-40]
    str \tmp, [sp, #-44]
    str \tmp, [sp, #-48]
    str \tmp, [sp, #-52]
    str \tmp, [sp, #-56]
    str \tmp, [sp, #-60]
    str \tmp, [sp, #-64]
    str \tmp, [sp, #-68]
    str \tmp, [sp, #-72]
    str \tmp, [sp, #-76]
    str \tmp, [sp, #-80]
    str \tmp, [sp, #-84]
    str \tmp, [sp, #-88]
    str \tmp, [sp, #-92]
    str \tmp, [sp, #-96]
    str \tmp, [sp, #-100]
    str \tmp, [sp, #-104]
.endm

// TODO: Write macro gathering random


// According to reference, str are always one cycle because pipelined with
// next instruction
// (https://developer.arm.com/documentation/ddi0439/b/Programmers-Model/Instruction-set-summary/Load-store-timings)
//
// src and tmp registers will be trashed
.macro split_and_store dst0, dst1, src, tmp, mask, off
    lsr  \tmp, \src, #16        // First half (res0) 
    strh \tmp, [\dst0, \off]
    and  \src, \src, \mask      // Other half (res1)
    strh \src, [\dst1, \off]
.endm

// Require:
//  - Address of res0 and res1 at (respectively) sp+36 and sp+40
//  - Shares of intertwined results:
//      * T0 at sp - 108
//      * T1 at sp - 132
//      * T2 at sp - 148
//      * T3 at sp - 40
//      * T4 in r12
//      * T5 in r4
//      * T6 in r3
//      * T7 in r0

// Result:
//  - res0 and res1 array correctly filled with result of masked_and
.macro store_results_masked_8
    ldr r1, [sp, #-108] // Load T0 in r1
    ldr r2, [sp, #-132] // Load T1 in r2
    ldr r5, [sp, #-148] // Load T2 in r5
    ldr r6, [sp, #-40 ] // Load T3 in r6
                        // T4 already in r12
                        // T5 already in r4
                        // T6 already in r3
                        // T7 already in r0

    ldr r7, [sp, #36  ] // Load res0 addr
    ldr r8, [sp, #40  ] // Load res1 addr

    mov r10, #0xFFFF
    split_and_store r7, r8,  r1, r9, r10, #0
    split_and_store r7, r8,  r2, r9, r10, #2
    split_and_store r7, r8,  r5, r9, r10, #4
    split_and_store r7, r8,  r6, r9, r10, #6
    split_and_store r7, r8, r12, r9, r10, #8
    split_and_store r7, r8,  r4, r9, r10, #10
    split_and_store r7, r8,  r3, r9, r10, #12
    split_and_store r7, r8,  r0, r9, r10, #14
.endm



// Require this layout at the start:

// Registers:
// r0:  X
// r1:  X
// r2:  X
// r3:  X
// r4:  a0
// r5:  a1
// r6:  a2
// r7:  a3
// r8:  b0
// r9:  b1
// r10: b2
// r11: b3
// r12: b4
// r14: b5

// Stack:
// sp +  40: res1 array addr
// sp +  36: res0 array addr
// sp +  32: start of saved registers
// ...
// sp     : end of saved registers
// sp -   4: a4
// sp -   8: a5
// sp -  12: a6
// sp -  16: a7
// sp -  20: b6
// sp -  24: b7
// sp -  28: rand00
// ...
// sp - 104: rand23

// 64 bytes of usable stack between sp and sp-63

// Result:
// - Store result at sp + 92 -> sp + 123

// prologue: 1 block, 11 stores
// zero_random: 1 block, 20 stores
// load_operands_masked_and_8: 4 blocks, 38 loads
// Body: 57 loads, 30 stores 
// store_results_masked_8: 1 block of 6 loads, 16 stores
// epilogue: 1 block, 11 loads

// Total macro: 77 stores, 112 loads (but a lot are pipelined and take only
// one cycle)

.globl masked_and_8
.type masked_and_8,%function
masked_and_8:
    prologue

    zero_random r4
    load_operands_masked_and_8

    and  r0,  r4,  r8    //Exec s00 = a0 & b0 into r0
    ldr  r1, [sp, #-28 ] //Load rand00 into r1
    eor  r2,  r0,  r1    //Exec y01 = s00 ^ rand00 into r2
    and  r3,  r4,  r9    //Exec s01 = a0 & b1 into r3
    eor  r0,  r2,  r3    //Exec y02 = y01 ^ s01 into r0
    and  r2,  r4, r10    //Exec s02 = a0 & b2 into r2
    and  r3,  r4, r11    //Exec s03 = a0 & b3 into r3
    and  r1,  r4, r12    //Exec s04 = a0 & b4 into r1
    str  r1, [sp, #-108] //Store r1/s04 on stack
    and  r1,  r4, r14    //Exec s05 = a0 & b5 into r1
    str  r1, [sp, #-112] //Store r1/s05 on stack
    ldr  r1, [sp, #-20 ] //Load b6 into r1
    str  r7, [sp, #-116] //Store r7/a3 on stack
    and  r7,  r4,  r1    //Exec s06 = a0 & b6 into r7
    str  r7, [sp, #-120] //Store r7/s06 on stack
    ldr  r7, [sp, #-24 ] //Load b7 into r7
    and  r4,  r4,  r7    //Exec s07 = a0 & b7 into r4
    str  r4, [sp, #-124] //Store r4/s07 on stack
    and  r4,  r5,  r8    //Exec s10 = a1 & b0 into r4
    eor  r0,  r0,  r4    //Exec y03 = y02 ^ s10 into r0
    ldr  r4, [sp, #-32 ] //Load rand01 into r4
    eor  r0,  r0,  r4    //Exec y04 = y03 ^ rand01 into r0
    eor  r0,  r0,  r2    //Exec y05 = y04 ^ s02 into r0
    and  r2,  r5,  r9    //Exec s11 = a1 & b1 into r2
    eor  r2,  r2,  r4    //Exec y11 = s11 ^ rand01 into r2
    and  r4,  r5, r10    //Exec s12 = a1 & b2 into r4
    eor  r2,  r2,  r4    //Exec y12 = y11 ^ s12 into r2
    and  r4,  r5, r11    //Exec s13 = a1 & b3 into r4
    str r12, [sp, #-32 ] //Store r12/b4 on stack
    and r12,  r5, r12    //Exec s14 = a1 & b4 into r12
    str r12, [sp, #-128] //Store r12/s14 on stack
    and r12,  r5, r14    //Exec s15 = a1 & b5 into r12
    str r12, [sp, #-132] //Store r12/s15 on stack
    and r12,  r5,  r1    //Exec s16 = a1 & b6 into r12
    and  r5,  r5,  r7    //Exec s17 = a1 & b7 into r5
    str  r5, [sp, #-136] //Store r5/s17 on stack
    and  r5,  r6,  r8    //Exec s20 = a2 & b0 into r5
    eor  r0,  r0,  r5    //Exec y06 = y05 ^ s20 into r0
    ldr  r5, [sp, #-60 ] //Load rand08 into r5
    eor  r0,  r0,  r5    //Exec y07 = y06 ^ rand08 into r0
    eor  r0,  r0,  r3    //Exec y08 = y07 ^ s03 into r0
    and  r3,  r6,  r9    //Exec s21 = a2 & b1 into r3
    eor  r2,  r2,  r3    //Exec y13 = y12 ^ s21 into r2
    ldr  r3, [sp, #-36 ] //Load rand02 into r3
    eor  r2,  r2,  r3    //Exec y14 = y13 ^ rand02 into r2
    eor  r2,  r2,  r4    //Exec y15 = y14 ^ s13 into r2
    and  r4,  r6, r10    //Exec s22 = a2 & b2 into r4
    eor  r3,  r4,  r3    //Exec y21 = s22 ^ rand02 into r3
    and  r4,  r6, r11    //Exec s23 = a2 & b3 into r4
    eor  r3,  r3,  r4    //Exec y22 = y21 ^ s23 into r3
    ldr  r4, [sp, #-32 ] //Load b4 into r4
    and  r5,  r6,  r4    //Exec s24 = a2 & b4 into r5
    str r12, [sp, #-36 ] //Store r12/s16 on stack
    and r12,  r6, r14    //Exec s25 = a2 & b5 into r12
    str r12, [sp, #-140] //Store r12/s25 on stack
    and r12,  r6,  r1    //Exec s26 = a2 & b6 into r12
    and  r6,  r6,  r7    //Exec s27 = a2 & b7 into r6
    str  r6, [sp, #-144] //Store r6/s27 on stack
    ldr  r6, [sp, #-116] //Load a3 into r6
    str r12, [sp, #-148] //Store r12/s26 on stack
    and r12,  r6,  r8    //Exec s30 = a3 & b0 into r12
    eor  r0,  r0, r12    //Exec y09 = y08 ^ s30 into r0
    ldr r12, [sp, #-64 ] //Load rand09 into r12
    eor  r0,  r0, r12    //Exec y0a = y09 ^ rand09 into r0
    str  r8, [sp, #-152] //Store r8/b0 on stack
    ldr  r8, [sp, #-108] //Load s04 into r8
    eor  r0,  r0,  r8    //Exec y0b = y0a ^ s04 into r0
    ldr  r8, [sp, #-92 ] //Load rand20 into r8
    eor  r0,  r0,  r8    //Exec T0  = y0b ^ rand20 into r0
    str  r0, [sp, #-108] //Store r0/T0 on stack
    and  r0,  r6,  r9    //Exec s31 = a3 & b1 into r0
    eor  r0,  r2,  r0    //Exec y16 = y15 ^ s31 into r0
    eor  r0,  r0, r12    //Exec y17 = y16 ^ rand09 into r0
    ldr  r2, [sp, #-128] //Load s14 into r2
    eor  r0,  r0,  r2    //Exec y18 = y17 ^ s14 into r0
    and  r2,  r6, r10    //Exec s32 = a3 & b2 into r2
    eor  r2,  r3,  r2    //Exec y23 = y22 ^ s32 into r2
    ldr  r3, [sp, #-40 ] //Load rand03 into r3
    eor  r2,  r2,  r3    //Exec y24 = y23 ^ rand03 into r2
    eor  r2,  r2,  r5    //Exec y25 = y24 ^ s24 into r2
    and  r5,  r6, r11    //Exec s33 = a3 & b3 into r5
    eor  r3,  r5,  r3    //Exec y31 = s33 ^ rand03 into r3
    and  r5,  r6,  r4    //Exec s34 = a3 & b4 into r5
    eor  r3,  r3,  r5    //Exec y32 = y31 ^ s34 into r3
    and  r5,  r6, r14    //Exec s35 = a3 & b5 into r5
    and r12,  r6,  r1    //Exec s36 = a3 & b6 into r12
    and  r6,  r6,  r7    //Exec s37 = a3 & b7 into r6
    ldr  r8, [sp, #-4  ] //Load a4 into r8
    str  r6, [sp, #-40 ] //Store r6/s37 on stack
    ldr  r6, [sp, #-152] //Load b0 into r6
    str r12, [sp, #-64 ] //Store r12/s36 on stack
    and r12,  r8,  r6    //Exec s40 = a4 & b0 into r12
    str r12, [sp, #-116] //Store r12/s40 on stack
    and r12,  r8,  r9    //Exec s41 = a4 & b1 into r12
    eor  r0,  r0, r12    //Exec y19 = y18 ^ s41 into r0
    ldr r12, [sp, #-68 ] //Load rand10 into r12
    eor  r0,  r0, r12    //Exec y1a = y19 ^ rand10 into r0
    str  r9, [sp, #-128] //Store r9/b1 on stack
    ldr  r9, [sp, #-132] //Load s15 into r9
    eor  r0,  r0,  r9    //Exec y1b = y1a ^ s15 into r0
    ldr  r9, [sp, #-96 ] //Load rand21 into r9
    eor  r0,  r0,  r9    //Exec T1  = y1b ^ rand21 into r0
    str  r0, [sp, #-132] //Store r0/T1 on stack
    and  r0,  r8, r10    //Exec s42 = a4 & b2 into r0
    eor  r0,  r2,  r0    //Exec y26 = y25 ^ s42 into r0
    eor  r0,  r0, r12    //Exec y27 = y26 ^ rand10 into r0
    ldr  r2, [sp, #-140] //Load s25 into r2
    eor  r0,  r0,  r2    //Exec y28 = y27 ^ s25 into r0
    and  r2,  r8, r11    //Exec s43 = a4 & b3 into r2
    eor  r2,  r3,  r2    //Exec y33 = y32 ^ s43 into r2
    ldr  r3, [sp, #-44 ] //Load rand04 into r3
    eor  r2,  r2,  r3    //Exec y34 = y33 ^ rand04 into r2
    eor  r2,  r2,  r5    //Exec y35 = y34 ^ s35 into r2
    and  r5,  r8,  r4    //Exec s44 = a4 & b4 into r5
    eor  r3,  r5,  r3    //Exec y41 = s44 ^ rand04 into r3
    and  r5,  r8, r14    //Exec s45 = a4 & b5 into r5
    eor  r3,  r3,  r5    //Exec y42 = y41 ^ s45 into r3
    and  r5,  r8,  r1    //Exec s46 = a4 & b6 into r5
    and  r8,  r8,  r7    //Exec s47 = a4 & b7 into r8
    ldr r12, [sp, #-8  ] //Load a5 into r12
    and  r9, r12,  r6    //Exec s50 = a5 & b0 into r9
    str  r9, [sp, #-4  ] //Store r9/s50 on stack
    ldr  r9, [sp, #-128] //Load b1 into r9
    str  r8, [sp, #-44 ] //Store r8/s47 on stack
    and  r8, r12,  r9    //Exec s51 = a5 & b1 into r8
    str  r8, [sp, #-68 ] //Store r8/s51 on stack
    and  r8, r12, r10    //Exec s52 = a5 & b2 into r8
    eor  r0,  r0,  r8    //Exec y29 = y28 ^ s52 into r0
    ldr  r8, [sp, #-72 ] //Load rand11 into r8
    eor  r0,  r0,  r8    //Exec y2a = y29 ^ rand11 into r0
    str r10, [sp, #-140] //Store r10/b2 on stack
    ldr r10, [sp, #-148] //Load s26 into r10
    eor  r0,  r0, r10    //Exec y2b = y2a ^ s26 into r0
    ldr r10, [sp, #-100] //Load rand22 into r10
    eor  r0,  r0, r10    //Exec T2  = y2b ^ rand22 into r0
    str  r0, [sp, #-148] //Store r0/T2 on stack
    and  r0, r12, r11    //Exec s53 = a5 & b3 into r0
    eor  r0,  r2,  r0    //Exec y36 = y35 ^ s53 into r0
    eor  r0,  r0,  r8    //Exec y37 = y36 ^ rand11 into r0
    ldr  r2, [sp, #-64 ] //Load s36 into r2
    eor  r0,  r0,  r2    //Exec y38 = y37 ^ s36 into r0
    and  r2, r12,  r4    //Exec s54 = a5 & b4 into r2
    eor  r2,  r3,  r2    //Exec y43 = y42 ^ s54 into r2
    ldr  r3, [sp, #-48 ] //Load rand05 into r3
    eor  r2,  r2,  r3    //Exec y44 = y43 ^ rand05 into r2
    eor  r2,  r2,  r5    //Exec y45 = y44 ^ s46 into r2
    and  r5, r12, r14    //Exec s55 = a5 & b5 into r5
    eor  r3,  r5,  r3    //Exec y51 = s55 ^ rand05 into r3
    and  r5, r12,  r1    //Exec s56 = a5 & b6 into r5
    eor  r3,  r3,  r5    //Exec y52 = y51 ^ s56 into r3
    and  r5, r12,  r7    //Exec s57 = a5 & b7 into r5
    ldr  r8, [sp, #-12 ] //Load a6 into r8
    and r12,  r8,  r6    //Exec s60 = a6 & b0 into r12
    and r10,  r8,  r9    //Exec s61 = a6 & b1 into r10
    str r10, [sp, #-8  ] //Store r10/s61 on stack
    ldr r10, [sp, #-140] //Load b2 into r10
    str r12, [sp, #-48 ] //Store r12/s60 on stack
    and r12,  r8, r10    //Exec s62 = a6 & b2 into r12
    str r12, [sp, #-64 ] //Store r12/s62 on stack
    and r12,  r8, r11    //Exec s63 = a6 & b3 into r12
    eor  r0,  r0, r12    //Exec y39 = y38 ^ s63 into r0
    ldr r12, [sp, #-76 ] //Load rand12 into r12
    eor  r0,  r0, r12    //Exec y3a = y39 ^ rand12 into r0
    str r11, [sp, #-72 ] //Store r11/b3 on stack
    ldr r11, [sp, #-40 ] //Load s37 into r11
    eor  r0,  r0, r11    //Exec y3b = y3a ^ s37 into r0
    ldr r11, [sp, #-104] //Load rand23 into r11
    eor  r0,  r0, r11    //Exec T3  = y3b ^ rand23 into r0
    str  r0, [sp, #-40 ] //Store r0/T3 on stack
    and  r0,  r8,  r4    //Exec s64 = a6 & b4 into r0
    eor  r0,  r2,  r0    //Exec y46 = y45 ^ s64 into r0
    eor  r0,  r0, r12    //Exec y47 = y46 ^ rand12 into r0
    ldr  r2, [sp, #-44 ] //Load s47 into r2
    eor  r0,  r0,  r2    //Exec y48 = y47 ^ s47 into r0
    and  r2,  r8, r14    //Exec s65 = a6 & b5 into r2
    eor  r2,  r3,  r2    //Exec y53 = y52 ^ s65 into r2
    ldr  r3, [sp, #-52 ] //Load rand06 into r3
    eor  r2,  r2,  r3    //Exec y54 = y53 ^ rand06 into r2
    eor  r2,  r2,  r5    //Exec y55 = y54 ^ s57 into r2
    and  r5,  r8,  r1    //Exec s66 = a6 & b6 into r5
    eor  r3,  r5,  r3    //Exec y61 = s66 ^ rand06 into r3
    and  r5,  r8,  r7    //Exec s67 = a6 & b7 into r5
    eor  r3,  r3,  r5    //Exec y62 = y61 ^ s67 into r3
    ldr  r5, [sp, #-16 ] //Load a7 into r5
    and  r6,  r5,  r6    //Exec s70 = a7 & b0 into r6
    and  r8,  r5,  r9    //Exec s71 = a7 & b1 into r8
    and  r9,  r5, r10    //Exec s72 = a7 & b2 into r9
    ldr r10, [sp, #-72 ] //Load b3 into r10
    and r10,  r5, r10    //Exec s73 = a7 & b3 into r10
    and  r4,  r5,  r4    //Exec s74 = a7 & b4 into r4
    eor  r0,  r0,  r4    //Exec y49 = y48 ^ s74 into r0
    ldr  r4, [sp, #-80 ] //Load rand13 into r4
    eor  r0,  r0,  r4    //Exec y4a = y49 ^ rand13 into r0
    ldr r12, [sp, #-116] //Load s40 into r12
    eor  r0,  r0, r12    //Exec y4b = y4a ^ s40 into r0
    ldr r12, [sp, #-92 ] //Load rand20 into r12
    eor  r12,  r0, r12    //Exec T4  = y4b ^ rand20 into r0
//  str  r12, [sp, #-12 ] //Store r0/T4 on stack
    and  r0,  r5, r14    //Exec s75 = a7 & b5 into r0
    eor  r0,  r2,  r0    //Exec y56 = y55 ^ s75 into r0
    eor  r0,  r0,  r4    //Exec y57 = y56 ^ rand13 into r0
    ldr  r2, [sp, #-4  ] //Load s50 into r2
    eor  r0,  r0,  r2    //Exec y58 = y57 ^ s50 into r0
    ldr  r2, [sp, #-112] //Load s05 into r2
    eor  r0,  r0,  r2    //Exec y59 = y58 ^ s05 into r0
    ldr  r2, [sp, #-84 ] //Load rand14 into r2
    eor  r0,  r0,  r2    //Exec y5a = y59 ^ rand14 into r0
    ldr  r4, [sp, #-68 ] //Load s51 into r4
    eor  r0,  r0,  r4    //Exec y5b = y5a ^ s51 into r0
    ldr  r4, [sp, #-96 ] //Load rand21 into r4
    eor  r4,  r0,  r4    //Exec T5  = y5b ^ rand21 into r0
//  str  r4, [sp, #-4  ] //Store r0/T5 on stack
    and  r0,  r5,  r1    //Exec s76 = a7 & b6 into r0
    eor  r0,  r3,  r0    //Exec y63 = y62 ^ s76 into r0
    ldr  r1, [sp, #-56 ] //Load rand07 into r1
    eor  r0,  r0,  r1    //Exec y64 = y63 ^ rand07 into r0
    ldr  r3, [sp, #-48 ] //Load s60 into r3
    eor  r0,  r0,  r3    //Exec y65 = y64 ^ s60 into r0
    ldr  r3, [sp, #-120] //Load s06 into r3
    eor  r0,  r0,  r3    //Exec y66 = y65 ^ s06 into r0
    eor  r0,  r0,  r2    //Exec y67 = y66 ^ rand14 into r0
    ldr  r2, [sp, #-8  ] //Load s61 into r2
    eor  r0,  r0,  r2    //Exec y68 = y67 ^ s61 into r0
    ldr  r2, [sp, #-36 ] //Load s16 into r2
    eor  r0,  r0,  r2    //Exec y69 = y68 ^ s16 into r0
    ldr  r2, [sp, #-88 ] //Load rand15 into r2
    eor  r0,  r0,  r2    //Exec y6a = y69 ^ rand15 into r0
    ldr  r3, [sp, #-64 ] //Load s62 into r3
    eor  r0,  r0,  r3    //Exec y6b = y6a ^ s62 into r0
    ldr  r3, [sp, #-100] //Load rand22 into r3
    eor  r3,  r0,  r3    //Exec T6  = y6b ^ rand22 into r0
//  str  r3, [sp, #-8  ] //Store r0/T6 on stack
    and  r0,  r5,  r7    //Exec s77 = a7 & b7 into r0
    eor  r0,  r0,  r1    //Exec y71 = s77 ^ rand07 into r0
    eor  r0,  r0,  r6    //Exec y72 = y71 ^ s70 into r0
    ldr  r1, [sp, #-124] //Load s07 into r1
    eor  r0,  r0,  r1    //Exec y73 = y72 ^ s07 into r0
    ldr  r1, [sp, #-28 ] //Load rand00 into r1
    eor  r0,  r0,  r1    //Exec y74 = y73 ^ rand00 into r0
    eor  r0,  r0,  r8    //Exec y75 = y74 ^ s71 into r0
    ldr  r1, [sp, #-136] //Load s17 into r1
    eor  r0,  r0,  r1    //Exec y76 = y75 ^ s17 into r0
    eor  r0,  r0,  r2    //Exec y77 = y76 ^ rand15 into r0
    eor  r0,  r0,  r9    //Exec y78 = y77 ^ s72 into r0
    ldr  r1, [sp, #-144] //Load s27 into r1
    eor  r0,  r0,  r1    //Exec y79 = y78 ^ s27 into r0
    ldr  r1, [sp, #-60 ] //Load rand08 into r1
    eor  r0,  r0,  r1    //Exec y7a = y79 ^ rand08 into r0
    eor  r0,  r0, r10    //Exec y7b = y7a ^ s73 into r0
    eor  r0,  r0, r11    //Exec T7  = y7b ^ rand23 into r0
    
    store_results_masked_8
    epilogue
.size masked_and_8,.-masked_and_8
