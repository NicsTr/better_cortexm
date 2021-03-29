.syntax unified
.thumb

// Sharedsliced /!\
// Require:
// - r0 input sharing
// - r1 output sharing
// - r3
.globl masked_ror4_8
.type masked_ror4_8,%function
masked_ror4_8:
    // Don't need to save r2, r3 or r12, they are scratch registers
    // lr = r14
    push {r4, r5, r6, lr}
    
    ldr  r2, [r0, #0 ]
    ldr  r3, [r0, #4 ]
    ldr r12, [r0, #8 ]
    ldr r14, [r0, #12]

    movw r6, #0x0fff
    movt r6, #0x0fff

    bic r5, r2, r6, LSL #4
    and r2, r6, r2, LSR #4
    orr r2, r2, r5, LSL #12
    
    bic r5, r3, r6, LSL #4
    and r3, r6, r3, LSR #4
    orr r3, r3, r5, LSL #12

    bic  r5, r12,  r6, LSL #4
    and r12,  r6, r12, LSR #4
    orr r12, r12,  r5, LSL #12

    bic  r5, r14,  r6, LSL #4
    and r14, r6,  r14, LSR #4
    orr r14, r14,  r5, LSL #12

    str  r2, [r1, #0 ]
    str  r3, [r1, #4 ]
    str r12, [r1, #8 ]
    str r14, [r1, #12]

    pop {r4, r5, r6, pc}
.size masked_ror4_8,.-masked_ror4_8

// Require:
// - r0 input sharing
// - r1 output sharing
// Result:
// ROR 8 for each share (a share is 16 bits)
.globl masked_ror8_8
.type masked_ror8_8,%function
masked_ror8_8:
    // Don't need to save r2, r3 or r12, they are scratch registers
    // lr = r14
    push {r4, r5, r6, lr}
    

    ldr  r2, [r0, #0 ]
    ldr  r3, [r0, #4 ]
    ldr r12, [r0, #8 ]
    ldr r14, [r0, #12]

    movw r6, #0x00ff
    movt r6, #0x00ff

    bic r5, r2, r6, ROR #8
    and r2, r6, r2, LSR #8
    orr r2, r2, r5, LSL #8
    
    bic r5, r3, r6, ROR #8
    and r3, r6, r3, LSR #8
    orr r3, r3, r5, LSL #8

    bic  r5, r12,  r6, ROR #8
    and r12,  r6, r12, LSR #8
    orr r12, r12,  r5, LSL #8

    bic  r5, r14,  r6, ROR #8
    and r14, r6,  r14, LSR #8
    orr r14, r14,  r5, LSL #8

    str  r2, [r1, #0 ]
    str  r3, [r1, #4 ]
    str r12, [r1, #8 ]
    str r14, [r1, #12]

    pop {r4, r5, r6, pc}
.size masked_ror8_8,.-masked_ror8_8
