# Instructions that are invalid in the R5900
#
# RUN: not llvm-mc %s -triple=mips64-ps2-elf -show-encoding -mcpu=r5900 2>%t1
# RUN: FileCheck %s < %t1

foo:
    # COP2 has qword sized registers
    swc2 $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    lwc2 $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    ldc2 $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    sdc2 $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    
    # COP3 is not present
    mfc3 $2, $2, 0  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: unknown instruction, did you mean: mfc0, mfc2?
    mtc3 $2, $2, 0  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: unknown instruction, did you mean: mtc0, mtc2?
    swc3 $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    lwc3 $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    ldc3 $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    sdc3 $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    dmfc3 $2, $2, 0 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: unknown instruction, did you mean: dmfc0, dmfc2?
    dmtc3 $2, $2, 0 # CHECK: :[[@LINE]]:{{[0-9]+}}: error: unknown instruction, did you mean: dmtc0, dmtc2?

    # R5900 is single core
    ll $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    sc $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    lld $2, 0($2) # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    scd $2, 0($2) # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction

    # R5900 does not support ll/sc
    ll $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    sc $2, 0($2)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    lld $2, 0($2) # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
    scd $2, 0($2) # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction