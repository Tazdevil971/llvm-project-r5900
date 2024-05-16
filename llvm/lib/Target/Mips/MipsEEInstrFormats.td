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