# Instructions that are added/valid in the R5900
#
# RUN: llvm-mc %s -triple=mips64-ps2-elf -show-encoding -mcpu=r5900 | FileCheck %s

foo:
    ei  # CHECK: ei  # encoding: [0x42,0x00,0x00,0x38]
    di  # CHECK: di  # encoding: [0x42,0x00,0x00,0x39]