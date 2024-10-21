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

let DecoderNamespace = "EE" in {
  def EE_EI : EeEi<"ei", II_EI>, EE_EI_FM<0>, ASE_R5900;
  def EE_DI : EeEi<"di", II_DI>, EE_EI_FM<1>, ASE_R5900;
}

def : MipsInstAlias<"sync.l", (SYNC 0), 1>, ASE_R5900;
def : MipsInstAlias<"sync.p", (SYNC 16), 1>, ASE_R5900;

let DecoderNamespace = "EE" in {
  def EE_LQ : LoadMemory<"lq", GPR128Opnd, mem_simmptr, load>, LW_FM<0x1e>, ASE_R5900;
  def EE_SQ : StoreMemory<"sq", GPR128Opnd, mem_simmptr, store>, LW_FM<0x1f>, ASE_R5900;
}

// These are backported from MIPS IV
let DecoderNamespace = "EE" in {
  def EE_MOVZ_I_I : CMov_I_I_FT<"movz", GPR32Opnd, GPR32Opnd, II_MOVZ>,
                    ADD_FM<0, 0xa>, ASE_R5900;

  let isCodeGenOnly = 1 in {
    def EE_MOVZ_I_I64   : CMov_I_I_FT<"movz", GPR32Opnd, GPR64Opnd, II_MOVZ>,
                          ADD_FM<0, 0xa>, ASE_R5900;
    def EE_MOVZ_I64_I   : CMov_I_I_FT<"movz", GPR64Opnd, GPR32Opnd, II_MOVZ>,
                          ADD_FM<0, 0xa>, ASE_R5900;
    def EE_MOVZ_I64_I64 : CMov_I_I_FT<"movz", GPR64Opnd, GPR64Opnd, II_MOVZ>,
                          ADD_FM<0, 0xa>, ASE_R5900;
  }

  def EE_MOVN_I_I     : CMov_I_I_FT<"movn", GPR32Opnd, GPR32Opnd, II_MOVN>,
                        ADD_FM<0, 0xb>, ASE_R5900;

  let isCodeGenOnly = 1 in {
    def EE_MOVN_I_I64   : CMov_I_I_FT<"movn", GPR32Opnd, GPR64Opnd, II_MOVN>,
                          ADD_FM<0, 0xb>, ASE_R5900;
    def EE_MOVN_I64_I   : CMov_I_I_FT<"movn", GPR64Opnd, GPR32Opnd, II_MOVN>,
                          ADD_FM<0, 0xb>, ASE_R5900;
    def EE_MOVN_I64_I64 : CMov_I_I_FT<"movn", GPR64Opnd, GPR64Opnd, II_MOVN>,
                          ADD_FM<0, 0xb>, ASE_R5900;
  }
}

  // Instantiation of conditional move patterns.
defm : MovzPats0<GPR32, GPR32, EE_MOVZ_I_I, SLT, SLTu, SLTi, SLTiu>, ASE_R5900;
defm : MovzPats1<GPR32, GPR32, EE_MOVZ_I_I, XOR>, ASE_R5900;
defm : MovzPats2<GPR32, GPR32, EE_MOVZ_I_I, XORi>, ASE_R5900;
defm : MovzPats0<GPR32, GPR64, EE_MOVZ_I_I64, SLT, SLTu, SLTi, SLTiu>, ASE_R5900;
defm : MovzPats0<GPR64, GPR32, EE_MOVZ_I_I, SLT64, SLTu64, SLTi64, SLTiu64>, ASE_R5900;
defm : MovzPats0<GPR64, GPR64, EE_MOVZ_I_I64, SLT64, SLTu64, SLTi64, SLTiu64>, ASE_R5900;
defm : MovzPats1<GPR32, GPR64, EE_MOVZ_I_I64, XOR>, ASE_R5900;
defm : MovzPats1<GPR64, GPR32, EE_MOVZ_I64_I, XOR64>, ASE_R5900;
defm : MovzPats1<GPR64, GPR64, EE_MOVZ_I64_I64, XOR64>, ASE_R5900;
defm : MovzPats2<GPR32, GPR64, EE_MOVZ_I_I64, XORi>, ASE_R5900;
defm : MovzPats2<GPR64, GPR32, EE_MOVZ_I64_I, XORi64>, ASE_R5900;
defm : MovzPats2<GPR64, GPR64, EE_MOVZ_I64_I64, XORi64>, ASE_R5900;
defm : MovnPats<GPR32, GPR32, EE_MOVN_I_I, XOR>, ASE_R5900;
defm : MovnPats<GPR32, GPR64, EE_MOVN_I_I64, XOR>, ASE_R5900;
defm : MovnPats<GPR64, GPR32, EE_MOVN_I64_I, XOR64>, ASE_R5900;
defm : MovnPats<GPR64, GPR64, EE_MOVN_I64_I64, XOR64>, ASE_R5900;