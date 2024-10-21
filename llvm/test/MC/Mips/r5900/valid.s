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
    
    # Multiplication with extra argument
    mult $2, $3, $4  # CHECK: mult $2, $3, $4     # encoding: [0x00,0x64,0x10,0x18]
    multu $2, $3, $4 # CHECK: multu $2, $3, $4    # encoding: [0x00,0x64,0x10,0x19]
    mult $3, $4      # CHECK: mult $3, $4         # encoding: [0x00,0x64,0x00,0x18]
    multu $3, $4     # CHECK: multu $3, $4        # encoding: [0x00,0x64,0x00,0x19]
    madd $2, $3, $4  # CHECK: madd $2, $3, $4     # encoding: [0x70,0x64,0x10,0x00]
    maddu $2, $3, $4 # CHECK: maddu $2, $3, $4    # encoding: [0x70,0x64,0x10,0x01]
    madd $3, $4      # CHECK: madd $3, $4         # encoding: [0x70,0x64,0x00,0x00]
    maddu $3, $4     # CHECK: maddu $3, $4        # encoding: [0x70,0x64,0x00,0x01]

    # Multiplication with second mul unit
    mult1 $2, $3, $4  # CHECK: mult1 $2, $3, $4     # encoding: [0x70,0x64,0x10,0x18]
    multu1 $2, $3, $4 # CHECK: multu1 $2, $3, $4    # encoding: [0x70,0x64,0x10,0x19]
    mult1 $3, $4      # CHECK: mult1 $3, $4         # encoding: [0x70,0x64,0x00,0x18]
    multu1 $3, $4     # CHECK: multu1 $3, $4        # encoding: [0x70,0x64,0x00,0x19]
    madd1 $2, $3, $4  # CHECK: madd1 $2, $3, $4     # encoding: [0x70,0x64,0x10,0x20]
    maddu1 $2, $3, $4 # CHECK: maddu1 $2, $3, $4    # encoding: [0x70,0x64,0x10,0x21]
    madd1 $3, $4      # CHECK: madd1 $3, $4         # encoding: [0x70,0x64,0x00,0x20]
    maddu1 $3, $4     # CHECK: maddu1 $3, $4        # encoding: [0x70,0x64,0x00,0x21]
    div1 $2, $3       # CHECK: div1 $2, $3          # encoding: [0x70,0x43,0x00,0x1a]
    divu1 $2, $3      # CHECK: divu1 $2, $3         # encoding: [0x70,0x43,0x00,0x1b]
    mtlo1 $2          # CHECK: mtlo1 $2             # encoding: [0x70,0x40,0x00,0x13]
    mthi1 $2          # CHECK: mthi1 $2             # encoding: [0x70,0x40,0x00,0x11]
    mflo1 $2          # CHECK: mflo1 $2             # encoding: [0x70,0x00,0x10,0x12]
    mfhi1 $2          # CHECK: mfhi1 $2             # encoding: [0x70,0x00,0x10,0x10]
