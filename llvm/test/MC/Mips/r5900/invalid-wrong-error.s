# Instructions that are invalid in the R5900
#
# RUN: not llvm-mc %s -triple=mips64-ps2-elf -show-encoding -mcpu=r5900 2>%t1
# RUN: FileCheck %s < %t1

foo:
    # COP3 is not present
    mfc3 $2, $2, 0  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: unknown instruction, did you mean: mfc0, mfc1, mfc2?
    mtc3 $2, $2, 0  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: unknown instruction, did you mean: mtc0, mtc1, mtc2?
    dmfc3 $2, $2, 0 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: unknown instruction, did you mean: dmfc0, dmfc1, dmfc2?
    dmtc3 $2, $2, 0 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: unknown instruction, did you mean: dmtc0, dmtc1, dmtc2?