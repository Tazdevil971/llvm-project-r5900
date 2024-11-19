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

    max.s $f1, $f2, $f3   # CHECK: max.s $f1, $f2, $f3   # encoding: [0x46,0x03,0x10,0x68]
    min.s $f1, $f2, $f3   # CHECK: min.s $f1, $f2, $f3   # encoding: [0x46,0x03,0x10,0x69]
    rsqrt.s $f1, $f2, $f3 # CHECK: rsqrt.s $f1, $f2, $f3 # encoding: [0x46,0x03,0x10,0x56]
    adda.s $f1, $f2       # CHECK: adda.s $f1, $f2       # encoding: [0x46,0x01,0x10,0x18]
    suba.s $f1, $f2       # CHECK: suba.s $f1, $f2       # encoding: [0x46,0x01,0x10,0x19]
    mula.s $f1, $f2       # CHECK: mula.s $f1, $f2       # encoding: [0x46,0x01,0x10,0x1a]
    madd.s $f1, $f2, $f3  # CHECK: madd.s $f1, $f2, $f3  # encoding: [0x46,0x02,0x18,0x5c]
    msub.s $f1, $f2, $f3  # CHECK: msub.s $f1, $f2, $f3  # encoding: [0x46,0x02,0x18,0x5d]
    madda.s $f1, $f2      # CHECK: madda.s $f1, $f2      # encoding: [0x46,0x01,0x10,0x1e] 
    msuba.s $f1, $f2      # CHECK: msuba.s $f1, $f2      # encoding: [0x46,0x01,0x10,0x1f]