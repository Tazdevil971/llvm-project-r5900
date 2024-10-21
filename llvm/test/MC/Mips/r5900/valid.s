# Instructions that are added/valid in the R5900
#
# RUN: llvm-mc %s -triple=mips64-ps2-elf -show-encoding -mcpu=r5900 | FileCheck %s

foo:
    ei  # CHECK: ei  # encoding: [0x42,0x00,0x00,0x38]
    di  # CHECK: di  # encoding: [0x42,0x00,0x00,0x39]

    sync.l # CHECK: sync    # encoding: [0x00,0x00,0x00,0x0f]
    sync.p # CHECK: sync.p  # encoding: [0x00,0x00,0x04,0x0f]

    # Quadword instructions
    lq $2, 100($3) # CHECK: lq $2, 100($3) # encoding: [0x78,0x62,0x00,0x64]
    sq $2, 100($3) # CHECK: sq $2, 100($3) # encoding: [0x7c,0x62,0x00,0x64]

    # Instructions backported from MIPS4
    pref 0, 100($3) # CHECK: pref 0, 100($3) # encoding: [0xcc,0x60,0x00,0x64]
    movn $2, $3, $4 # CHECK: movn $2, $3, $4 # encoding: [0x00,0x64,0x10,0x0b]
    movz $2, $3, $4 # CHECK: movz $2, $3, $4 # encoding: [0x00,0x64,0x10,0x0a]