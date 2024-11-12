# Instructions that are invalid in the R5900 (FPU/COP1)
#
# RUN: not llvm-mc %s -triple=mips64-ps2-elf -show-encoding -mcpu=r5900 2>%t1
# RUN: FileCheck %s < %t1

foo:
    # Comparisons that don't make sense with no NaN/Inf support
    c.un.s $f1, $f2   # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.ueq.s $f1, $f2  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.ult.s $f1, $f2  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.ule.s $f1, $f2  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.sf.s $f1, $f2   # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.ngle.s $f1, $f2 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.seq.s $f1, $f2  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.ngl.s $f1, $f2  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.nge.s $f1, $f2  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    c.ngt.s $f1, $f2  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled

    ceil.w.s $f1, $f2  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    floor.w.s $f1, $f2 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    round.w.s $f1, $f2 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled

    # These should be disabled for this target, but they currently aren't
    # abs.d $f1, $f2
    # add.d $f1, $f2, $f3
    # c.f.d $f1, $f2
    # c.un.d $f1, $f2
    # c.eq.d $f1, $f2
    # c.ueq.d $f1, $f2
    # c.olt.d $f1, $f2
    # c.ult.d $f1, $f2
    # c.ole.d $f1, $f2
    # c.ule.d $f1, $f2
    # c.sf.d $f1, $f2
    # c.ngle.d $f1, $f2
    # c.seq.d $f1, $f2
    # c.ngl.d $f1, $f2
    # c.lt.d $f1, $f2
    # c.nge.d $f1, $f2
    # c.le.d $f1, $f2
    # c.ngt.d $f1, $f2
    # cvt.d.s $f1, $f2
    # cvt.d.w $f1, $f2
    # cvt.s.d $f1, $f2
    # cvt.w.d $f1, $f2
    # div.d $f1, $f2, $f3
    # mov.d $f1, $f2
    # mul.d $f1, $f2, $f3
    # neg.d $f1, $f2
    # sub.d $f1, $f2, $f3
    # ceil.w.d $f1, $f2
    # floor.w.d $f1, $f2
    # round.w.d $f1, $f2
    # sqrt.d $f1, $f2
    # trunc.w.d $f1, $f2
    # ldc1 $f0, 0($2)
    # sdc1 $f0, 0($2)
    # dmfc1 $2, $f0 
    # dmtc1 $2, $f0