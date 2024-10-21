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

class EeMult<string opstr, InstrItinClass itin, list<Register> Regs> :
    InstSE<(outs GPR32Opnd:$rd), (ins GPR32Opnd:$rs, GPR32Opnd:$rt), 
           !strconcat(opstr, "\t$rd, $rs, $rt"), [], itin, FrmR, opstr> {
  let Defs = Regs;
  let isCommutable = 1;
}

class EeMAdd<string opstr, InstrItinClass itin, list<Register> Regs> :
    InstSE<(outs GPR32Opnd:$rd), (ins GPR32Opnd:$rs, GPR32Opnd:$rt), 
           !strconcat(opstr, "\t$rd, $rs, $rt"), [], itin, FrmR, opstr> {
  let isCommutable = 1;
  let Defs = Regs;
  let Uses = Regs;
}

class EeMultPseudo<Instruction RealInst, SDPatternOperator OpNode, 
                   InstrItinClass Itin> :
    PseudoSE<(outs ACC64:$ac), (ins GPR32Opnd:$rs, GPR32Opnd:$rt),
             [(set ACC64:$ac, (OpNode GPR32Opnd:$rs, GPR32Opnd:$rt))], Itin>,
    PseudoInstExpansion<(RealInst ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt)> {
  let hasNoSchedulingInfo = 1;
  let isCommutable = 1;
}

class EeMAddPseudo<Instruction RealInst, SDPatternOperator OpNode,
                   InstrItinClass itin> : 
    PseudoSE<(outs ACC64:$ac),
             (ins GPR32Opnd:$rs, GPR32Opnd:$rt, ACC64:$acin),
             [(set ACC64:$ac,
              (OpNode GPR32Opnd:$rs, GPR32Opnd:$rt, ACC64:$acin))],
             itin>,
    PseudoInstExpansion<(RealInst ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt)> {
  let hasNoSchedulingInfo = 1;
  string Constraints = "$acin = $ac";
}

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

let DecoderNamespace = "EE" in {
  def EE_MULT  : EeMult<"mult", II_MULT, [HI0, LO0]>, EE_MULT_FM<0, 0x18>, ASE_R5900;
  def EE_MULTU : EeMult<"multu", II_MULT, [HI0, LO0]>, EE_MULT_FM<0, 0x19>, ASE_R5900;

  def EE_MADD  : EeMAdd<"madd", II_MADD, [HI0, LO0]>, EE_MULT_FM<0x1c, 0>, ASE_R5900;
  def EE_MADDU : EeMAdd<"maddu", II_MADD, [HI0, LO0]>, EE_MULT_FM<0x1c, 1>, ASE_R5900;
}

def EE_PseudoMULT : EeMultPseudo<EE_MULT, MipsMult, II_MULT>, ASE_R5900;
def EE_PseudoMULTU : EeMultPseudo<EE_MULTU, MipsMultu, II_MULT>, ASE_R5900;

def EE_PseudoMADD : EeMAddPseudo<EE_MADD, MipsMAdd, II_MADD>, ASE_R5900;
def EE_PseudoMADDU : EeMAddPseudo<EE_MADDU, MipsMAddu, II_MADD>, ASE_R5900;

def : MipsInstAlias<"mult $rs, $rt",
                    (EE_MULT ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;
def : MipsInstAlias<"multu $rs, $rt",
                    (EE_MULTU ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;
def : MipsInstAlias<"madd $rs, $rt",
                    (EE_MADD ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;
def : MipsInstAlias<"maddu $rs, $rt",
                    (EE_MADDU ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;

// TODO: Is this actually superior to mult/mflo?
def : MipsPat<(mul GPR32:$lhs, GPR32:$rhs),
              (EE_MULT GPR32:$lhs, GPR32:$rhs)>, ASE_R5900;

// Second set of multiply hardware
let DecoderNamespace = "EE" in {
  def EE_MULT1 : EeMult<"mult1", II_MULT, [HI1, LO1]>, EE_MULT_FM<0x1c, 0x18>, ASE_R5900;
  def EE_MULTU1 : EeMult<"multu1", II_MULT, [HI1, LO1]>, EE_MULT_FM<0x1c, 0x19>, ASE_R5900;
  
  def EE_MADD1 : EeMAdd<"madd1", II_MADD, [HI1, LO1]>, EE_MULT_FM<0x1c, 0x20>, ASE_R5900;
  def EE_MADDU1 : EeMAdd<"maddu1", II_MADD, [HI1, LO1]>, EE_MULT_FM<0x1c, 0x21>, ASE_R5900;

  def EE_SDIV1 : Div<"div1", II_DIV, GPR32Opnd, [HI1, LO1]>, MULT_FM<0x1c, 0x1a>, ASE_R5900;
  def EE_UDIV1 : Div<"divu1", II_DIV, GPR32Opnd, [HI1, LO1]>, MULT_FM<0x1c, 0x1b>, ASE_R5900;
  
  def EE_MTLO1 : MoveFromLOHI<"mtlo1", GPR32Opnd, AC1>, EE_MFLOHI_FM<0x1c, 0x10>, ASE_R5900;
  def EE_MTHI1 : MoveFromLOHI<"mthi1", GPR32Opnd, AC1>, EE_MFLOHI_FM<0x1c, 0x12>, ASE_R5900;
  def EE_MFLO1 : MoveToLOHI<"mflo1", GPR32Opnd, [LO1]>, EE_MTLOHI_FM<0x1c, 0x11>, ASE_R5900;
  def EE_MFHI1 : MoveToLOHI<"mfhi1", GPR32Opnd, [HI1]>, EE_MTLOHI_FM<0x1c, 0x13>, ASE_R5900;
}

def : MipsInstAlias<"mult1 $rs, $rt",
                    (EE_MULT1 ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;
def : MipsInstAlias<"multu1 $rs, $rt",
                    (EE_MULTU1 ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;
def : MipsInstAlias<"madd1 $rs, $rt",
                    (EE_MADD1 ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;
def : MipsInstAlias<"maddu1 $rs, $rt",
                    (EE_MADDU1 ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;
def : MipsInstAlias<"div1 $rs, $rt",
                    (EE_SDIV1 GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;
def : MipsInstAlias<"divu1 $rs, $rt",
                    (EE_UDIV1 GPR32Opnd:$rs, GPR32Opnd:$rt), 0>, ASE_R5900;