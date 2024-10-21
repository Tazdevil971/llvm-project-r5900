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