# Instructions that are added/valid in the R5900
#
# RUN: llvm-mc %s -triple=mips64-ps2-elf -show-encoding -mcpu=r5900 | FileCheck %s

# TODO: Actually populate this
foo:
    nop # CHECK: nop # encoding: [0x00,0x00,0x00,0x00]