//===- MipsEEInstrInfo.td - EE Core instructions -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes EE Core instructions.
//
//===----------------------------------------------------------------------===//

// Interrupts
class EeEi<string opstr, InstrItinClass itin = NoItinerary> :
    InstSE<(outs), (ins), opstr, [], itin, FrmOther, opstr>;

def EE_EI : EeEi<"ei", II_EI>, EE_EI_FM<0>, ASE_R5900;
def EE_DI : EeEi<"di", II_DI>, EE_EI_FM<1>, ASE_R5900;

def : MipsInstAlias<"sync.l", (SYNC 0), 1>, ASE_R5900;
def : MipsInstAlias<"sync.p", (SYNC 16), 1>, ASE_R5900;