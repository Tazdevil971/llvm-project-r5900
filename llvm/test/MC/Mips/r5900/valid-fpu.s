# Instructions that are added/valid in the R5900 (FPU/COP1)
#
# RUN: llvm-mc %s -triple=mips64-ps2-elf -show-encoding -mcpu=r5900 | FileCheck %s

foo:
    c.eq.s $f1, $f2  # CHECK: c.eq.s $f1, $f2  # encoding: [0x46,0x02,0x08,0x32]
    c.f.s $f1, $f2   # CHECK: c.f.s $f1, $f2   # encoding: [0x46,0x02,0x08,0x30]
    c.le.s $f1, $f2  # CHECK: c.le.s $f1, $f2  # encoding: [0x46,0x02,0x08,0x36]
    c.lt.s $f1, $f2  # CHECK: c.lt.s $f1, $f2  # encoding: [0x46,0x02,0x08,0x34]
    c.ole.s $f1, $f2 # CHECK: c.le.s $f1, $f2  # encoding: [0x46,0x02,0x08,0x36]
    c.olt.s $f1, $f2 # CHECK: c.lt.s $f1, $f2  # encoding: [0x46,0x02,0x08,0x34]

    cvt.s.w $f1, $f2   # CHECK: cvt.s.w $f1, $f2    # encoding: [0x46,0x80,0x10,0x60]
    cvt.w.s $f1, $f2   # CHECK: trunc.w.s $f1, $f2  # encoding: [0x46,0x00,0x10,0x64]
    trunc.w.s $f1, $f2 # CHECK: trunc.w.s $f1, $f2  # encoding: [0x46,0x00,0x10,0x64]