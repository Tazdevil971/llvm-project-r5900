# Instructions that are invalid in the R5900
#
# RUN: not llvm-mc %s -triple=mips64-ps2-elf -show-encoding -mcpu=r5900 2>%t1
# RUN: FileCheck %s < %t1

foo:
    # COP0 has word sized registers
    dmfc0 $2, $2, 0 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    dmtc0 $2, $2, 0 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled

    # COP2 has qword sized registers
    mfc2 $2, $2, 0  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    mtc2 $2, $2, 0  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    dmfc2 $2, $2, 0 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
    dmtc2 $2, $2, 0 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: instruction requires a CPU feature not currently enabled
