//===- MipsEEInstrInfo.td - EE Core instructions formats ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Enable/disable interrupt instruction format <Cop0|CO|0|11100|sc>
//===----------------------------------------------------------------------===//

class EE_EI_FM<bits<1> sc> : StdArch {
  bits<32> Inst;
  
  let Inst{31-26} = 0x10;
  let Inst{25}    = 1;
  let Inst{24-6}  = 0;
  let Inst{5-1}   = 0b11100;
  let Inst{0}     = sc;
}

class EE_MULT_FM<bits<6> op, bits<6> funct> : StdArch {
  bits<5> rs;
  bits<5> rt;
  bits<5> rd; 

  bits<32> Inst;

  let Inst{31-26} = op;
  let Inst{25-21} = rs;
  let Inst{20-16} = rt;
  let Inst{15-11} = rd;
  let Inst{10-6}  = 0;
  let Inst{5-0}   = funct;
}

class EE_MFLOHI_FM<bits<6> op, bits<6> funct> : StdArch {
  bits<5> rd;

  bits<32> Inst;

  let Inst{31-26} = op;
  let Inst{25-16} = 0;
  let Inst{15-11} = rd;
  let Inst{10-6}  = 0;
  let Inst{5-0}   = funct;
}

class EE_MTLOHI_FM<bits<6> op, bits<6> funct> : StdArch {
  bits<5> rs;

  bits<32> Inst;

  let Inst{31-26} = op;
  let Inst{25-21} = rs;
  let Inst{20-6}  = 0;
  let Inst{5-0}   = funct;
}

class MMI_MFSA_FM : StdArch {
  bits<5> rd;

  bits<32> Inst;

  let Inst{31-26} = 0;
  let Inst{25-16} = 0;
  let Inst{15-11} = rd;
  let Inst{10-6}  = 0;
  let Inst{5-0}   = 0x28;
}

class MMI_MTSA_FM : StdArch {
  bits<5> rs;

  bits<32> Inst;

  let Inst{31-26} = 0;
  let Inst{25-21} = rs;
  let Inst{20-6}  = 0;
  let Inst{5-0}   = 0x29;
}

class MMI_MTSA_2_FM<bits<1> half> : StdArch {
  bits<5> rs;
  bits<16> imm;

  bits<32> Inst;

  let Inst{31-26} = 1;
  let Inst{25-21} = rs;
  let Inst{20-17} = 0xc;
  let Inst{16}    = half;
  let Inst{15-0}  = imm;
}

class MMI_2_OP_FM<bits<5> funct1, bits<6> funct2> : StdArch {
  bits<5> rd;
  bits<5> rt;

  bits<32> Inst;

  let Inst{31-26} = 0x1c;
  let Inst{25-21} = 0;
  let Inst{20-16} = rt;
  let Inst{15-11} = rd;
  let Inst{10-6}  = funct1;
  let Inst{5-0}   = funct2;
}

class MMI_PAR_SHIFT_FM<bits<6> funct> : StdArch {
  bits<5> rd;
  bits<5> rt;
  bits<5> sa;

  bits<32> Inst;

  let Inst{31-26} = 0x1c;
  let Inst{25-21} = 0;
  let Inst{20-16} = rt;
  let Inst{15-11} = rd;
  let Inst{10-6}  = sa;
  let Inst{5-0}   = funct;
}

class MMI_3_OP_FM<bits<5> funct1, bits<6> funct2> : StdArch {
  bits<5> rd;
  bits<5> rs;
  bits<5> rt;

  bits<32> Inst;

  let Inst{31-26} = 0x1c;
  let Inst{25-21} = rs;
  let Inst{20-16} = rt;
  let Inst{15-11} = rd;
  let Inst{10-6}  = funct1;
  let Inst{5-0}   = funct2;
}

class MMI_DIV_FM<bits<5> funct1, bits<6> funct2> : StdArch {
  bits<5> rs;
  bits<5> rt;

  bits<32> Inst;

  let Inst{31-26} = 0x1c;
  let Inst{25-21} = rs;
  let Inst{20-16} = rt;
  let Inst{15-11} = 0;
  let Inst{10-6}  = funct1;
  let Inst{5-0}   = funct2;
}

class MMI_MTLOHI_FM<bits<5> funct1, bits<6> funct2> : StdArch {
  bits<5> rs;

  bits<32> Inst;

  let Inst{31-26} = 0x1c;
  let Inst{25-21} = rs;
  let Inst{20-16} = 0;
  let Inst{15-11} = 0;
  let Inst{10-6}  = funct1;
  let Inst{5-0}   = funct2;
}

class MMI_MFLOHI_FM<bits<5> funct1, bits<6> funct2> : StdArch {
  bits<5> rd;

  bits<32> Inst;

  let Inst{31-26} = 0x1c;
  let Inst{25-21} = 0;
  let Inst{20-16} = 0;
  let Inst{15-11} = rd;
  let Inst{10-6}  = funct1;
  let Inst{5-0}   = funct2;
}