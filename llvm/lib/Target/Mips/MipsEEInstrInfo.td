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

//===----------------------------------------------------------------------===//
// Base EE Core instructions
//===----------------------------------------------------------------------===//

// Interrupts
class EeEi<string opstr, InstrItinClass itin> :
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
  def EE_MULTU : EeMult<"multu", II_MULTU, [HI0, LO0]>, EE_MULT_FM<0, 0x19>, ASE_R5900;

  def EE_MADD  : EeMAdd<"madd", II_MADD, [HI0, LO0]>, EE_MULT_FM<0x1c, 0>, ASE_R5900;
  def EE_MADDU : EeMAdd<"maddu", II_MADDU, [HI0, LO0]>, EE_MULT_FM<0x1c, 1>, ASE_R5900;
}

def EE_PseudoMULT : EeMultPseudo<EE_MULT, MipsMult, II_MULT>, ASE_R5900;
def EE_PseudoMULTU : EeMultPseudo<EE_MULTU, MipsMultu, II_MULTU>, ASE_R5900;

def EE_PseudoMADD : EeMAddPseudo<EE_MADD, MipsMAdd, II_MADD>, ASE_R5900;
def EE_PseudoMADDU : EeMAddPseudo<EE_MADDU, MipsMAddu, II_MADDU>, ASE_R5900;

def : MipsInstAlias<"mult $rs, $rt",
                    (EE_MULT ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;
def : MipsInstAlias<"multu $rs, $rt",
                    (EE_MULTU ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;
def : MipsInstAlias<"madd $rs, $rt",
                    (EE_MADD ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;
def : MipsInstAlias<"maddu $rs, $rt",
                    (EE_MADDU ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;

// TODO: Is this actually superior to mult/mflo?
def : MipsPat<(mul GPR32:$lhs, GPR32:$rhs),
              (EE_MULT GPR32:$lhs, GPR32:$rhs)>, ASE_R5900;

// Second set of multiply hardware
let DecoderNamespace = "EE" in {
  def EE_MULT1 : EeMult<"mult1", II_MULT, [HI1, LO1]>, EE_MULT_FM<0x1c, 0x18>, ASE_R5900;
  def EE_MULTU1 : EeMult<"multu1", II_MULTU, [HI1, LO1]>, EE_MULT_FM<0x1c, 0x19>, ASE_R5900;
  
  def EE_MADD1 : EeMAdd<"madd1", II_MADD, [HI1, LO1]>, EE_MULT_FM<0x1c, 0x20>, ASE_R5900;
  def EE_MADDU1 : EeMAdd<"maddu1", II_MADDU, [HI1, LO1]>, EE_MULT_FM<0x1c, 0x21>, ASE_R5900;

  def EE_SDIV1 : Div<"div1", II_DIV, GPR32Opnd, [HI1, LO1]>, MULT_FM<0x1c, 0x1a>, ASE_R5900;
  def EE_UDIV1 : Div<"divu1", II_DIVU, GPR32Opnd, [HI1, LO1]>, MULT_FM<0x1c, 0x1b>, ASE_R5900;
  
  def EE_MTLO1 : MoveToLOHI<"mtlo1", GPR32Opnd, [LO1]>, EE_MTLOHI_FM<0x1c, 0x13>, ASE_R5900;
  def EE_MTHI1 : MoveToLOHI<"mthi1", GPR32Opnd, [HI1]>, EE_MTLOHI_FM<0x1c, 0x11>, ASE_R5900;
  def EE_MFLO1 : MoveFromLOHI<"mflo1", GPR32Opnd, AC1>, EE_MFLOHI_FM<0x1c, 0x12>, ASE_R5900;
  def EE_MFHI1 : MoveFromLOHI<"mfhi1", GPR32Opnd, AC1>, EE_MFLOHI_FM<0x1c, 0x10>, ASE_R5900;
}

def : MipsInstAlias<"mult1 $rs, $rt",
                    (EE_MULT1 ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;
def : MipsInstAlias<"multu1 $rs, $rt",
                    (EE_MULTU1 ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;
def : MipsInstAlias<"madd1 $rs, $rt",
                    (EE_MADD1 ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;
def : MipsInstAlias<"maddu1 $rs, $rt",
                    (EE_MADDU1 ZERO, GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;
def : MipsInstAlias<"div1 $rs, $rt",
                    (EE_SDIV1 GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;
def : MipsInstAlias<"divu1 $rs, $rt",
                    (EE_UDIV1 GPR32Opnd:$rs, GPR32Opnd:$rt), 1>, ASE_R5900;

//===----------------------------------------------------------------------===//
// MMI MultiMedia Instructions
//===----------------------------------------------------------------------===//

class MmiMoveFromSA<string opstr, InstrItinClass itin> : 
    InstSE<(outs), (ins GPR32Opnd:$rd), 
           !strconcat(opstr, "\t$rd"), [], itin, FrmR, opstr> {
  let Uses = [EE_SA];
}

class MmiMoveToSA<string opstr, InstrItinClass itin> : 
    InstSE<(outs), (ins GPR32Opnd:$rs), 
           !strconcat(opstr, "\t$rs"), [], itin, FrmR, opstr> {
  let Defs = [EE_SA];
}

class MmiMoveToSA2<string opstr, InstrItinClass itin> :
    InstSE<(outs), (ins GPR32Opnd:$rs, uimm16:$imm), 
           !strconcat(opstr, "\t$rs, $imm"), [], itin, FrmR, opstr> {
  let Defs = [EE_SA];
}

class Mmi2Op<string opstr, InstrItinClass itin> :
    InstSE<(outs GPR128Opnd:$rd), (ins GPR128Opnd:$rt), 
           !strconcat(opstr, "\t$rd, $rt"), [], itin, FrmR, opstr> {}

class Mmi3Op<string opstr, InstrItinClass itin> :
    InstSE<(outs GPR128Opnd:$rd), (ins GPR128Opnd:$rs, GPR128Opnd:$rt), 
           !strconcat(opstr, "\t$rd, $rs, $rt"), [], itin, FrmR, opstr> {}

class MmiMul<string opstr, InstrItinClass itin> :
    InstSE<(outs GPR128Opnd:$rd), (ins GPR128Opnd:$rs, GPR128Opnd:$rt), 
           !strconcat(opstr, "\t$rd, $rs, $rt"), [], itin, FrmR, opstr> {
  let Defs = [EE_LO_128, EE_HI_128];
}

class MmiMAdd<string opstr, InstrItinClass itin> :
    InstSE<(outs GPR128Opnd:$rd), (ins GPR128Opnd:$rs, GPR128Opnd:$rt), 
           !strconcat(opstr, "\t$rd, $rs, $rt"), [], itin, FrmR, opstr> {
  let Uses = [EE_LO_128, EE_HI_128];
  let Defs = [EE_LO_128, EE_HI_128];
}

class MmiDiv<string opstr, InstrItinClass itin> :
    InstSE<(outs), (ins GPR128Opnd:$rs, GPR128Opnd:$rt), 
           !strconcat(opstr, "\t$rs, $rt"), [], itin, FrmR, opstr> {
  let Defs = [EE_LO_128, EE_HI_128];
}

class MmiMoveToLOHI<string opstr, InstrItinClass itin, list<Register> Regs> :
    InstSE<(outs), (ins GPR128Opnd:$rs), 
           !strconcat(opstr, "\t$rs"), [], itin, FrmR, opstr> {
  let Defs = Regs;
}

class MmiMoveFromLOHI<string opstr, InstrItinClass itin, list<Register> Regs> :
    InstSE<(outs GPR128Opnd:$rd), (ins), 
           !strconcat(opstr, "\t$rd"), [], itin, FrmR, opstr> {
  let Uses = Regs;
}

class MmiParShift<string opstr, InstrItinClass itin> :
    InstSE<(outs GPR128Opnd:$rd), (ins GPR128Opnd:$rt, uimm5:$sa),
           !strconcat(opstr, "\t$rd, $rt, $sa"), [], itin, FrmR, opstr> {}

let DecoderNamespace = "EE" in {
  // To and from SA
  def MMI_MFSA      : MmiMoveFromSA<"mfsa", NoItinerary>, MMI_MFSA_FM, ASE_R5900;
  def MMI_MTSA      : MmiMoveToSA<"mtsa", NoItinerary>, MMI_MTSA_FM, ASE_R5900;
  def MMI_MTSAB     : MmiMoveToSA2<"mtsab", NoItinerary>, MMI_MTSA_2_FM<0>, ASE_R5900;
  def MMI_MTSAH     : MmiMoveToSA2<"mtsah", NoItinerary>, MMI_MTSA_2_FM<1>, ASE_R5900;
  

  // QFSRV
  let Uses = [EE_SA] in {
    def MMI_QFSRV   : Mmi3Op<"qfsrv", NoItinerary>, MMI_3_OP_FM<0x1b, 0x28>, ASE_R5900;
  }

  // MMI0
  def MMI_PADDW     : Mmi3Op<"paddw", NoItinerary>, MMI_3_OP_FM<0x0, 0x8>, ASE_R5900;
  def MMI_PSUBW     : Mmi3Op<"psubw", NoItinerary>, MMI_3_OP_FM<0x1, 0x8>, ASE_R5900;
  def MMI_PCGTW     : Mmi3Op<"pcgtw", NoItinerary>, MMI_3_OP_FM<0x2, 0x8>, ASE_R5900;
  def MMI_PMAXW     : Mmi3Op<"pmaxw", NoItinerary>, MMI_3_OP_FM<0x3, 0x8>, ASE_R5900;
  def MMI_PADDH     : Mmi3Op<"paddh", NoItinerary>, MMI_3_OP_FM<0x4, 0x8>, ASE_R5900;
  def MMI_PSUBH     : Mmi3Op<"psubh", NoItinerary>, MMI_3_OP_FM<0x5, 0x8>, ASE_R5900;
  def MMI_PCGTH     : Mmi3Op<"pcgth", NoItinerary>, MMI_3_OP_FM<0x6, 0x8>, ASE_R5900;
  def MMI_PMAXH     : Mmi3Op<"pmaxh", NoItinerary>, MMI_3_OP_FM<0x7, 0x8>, ASE_R5900;
  def MMI_PADDB     : Mmi3Op<"paddb", NoItinerary>, MMI_3_OP_FM<0x8, 0x8>, ASE_R5900;
  def MMI_PSUBB     : Mmi3Op<"psubb", NoItinerary>, MMI_3_OP_FM<0x9, 0x8>, ASE_R5900;
  def MMI_PCGTB     : Mmi3Op<"pcgtb", NoItinerary>, MMI_3_OP_FM<0xa, 0x8>, ASE_R5900;
  def MMI_PADDSW    : Mmi3Op<"paddsw", NoItinerary>, MMI_3_OP_FM<0x10, 0x8>, ASE_R5900;
  def MMI_PSUBSW    : Mmi3Op<"psubsw", NoItinerary>, MMI_3_OP_FM<0x11, 0x8>, ASE_R5900;
  def MMI_PEXTLW    : Mmi3Op<"pextlw", NoItinerary>, MMI_3_OP_FM<0x12, 0x8>, ASE_R5900;
  def MMI_PPACW     : Mmi3Op<"ppacw", NoItinerary>, MMI_3_OP_FM<0x13, 0x8>, ASE_R5900;
  def MMI_PADDSH    : Mmi3Op<"paddsh", NoItinerary>, MMI_3_OP_FM<0x14, 0x8>, ASE_R5900;
  def MMI_PSUBSH    : Mmi3Op<"psubsh", NoItinerary>, MMI_3_OP_FM<0x15, 0x8>, ASE_R5900;
  def MMI_PEXTLH    : Mmi3Op<"pextlh", NoItinerary>, MMI_3_OP_FM<0x16, 0x8>, ASE_R5900;
  def MMI_PPACH     : Mmi3Op<"ppach", NoItinerary>, MMI_3_OP_FM<0x17, 0x8>, ASE_R5900;
  def MMI_PADDSB    : Mmi3Op<"paddsb", NoItinerary>, MMI_3_OP_FM<0x18, 0x8>, ASE_R5900;
  def MMI_PSUBSB    : Mmi3Op<"psubsb", NoItinerary>, MMI_3_OP_FM<0x19, 0x8>, ASE_R5900;
  def MMI_PEXTLB    : Mmi3Op<"pextlb", NoItinerary>, MMI_3_OP_FM<0x1a, 0x8>, ASE_R5900;
  def MMI_PPACB     : Mmi3Op<"ppacb", NoItinerary>, MMI_3_OP_FM<0x1b, 0x8>, ASE_R5900;
  def MMI_PEXT5     : Mmi2Op<"pext5", NoItinerary>, MMI_2_OP_FM<0x1e, 0x8>, ASE_R5900;
  def MMI_PPAC5     : Mmi2Op<"ppac5", NoItinerary>, MMI_2_OP_FM<0x1f, 0x8>, ASE_R5900;

  // MMI1
  def MMI_PCEQW     : Mmi3Op<"pceqw", NoItinerary>, MMI_3_OP_FM<0x2, 0x28>, ASE_R5900;
  def MMI_PMINW     : Mmi3Op<"pminw", NoItinerary>, MMI_3_OP_FM<0x3, 0x28>, ASE_R5900;
  def MMI_PADSBH    : Mmi3Op<"padsbh", NoItinerary>, MMI_3_OP_FM<0x4, 0x28>, ASE_R5900;
  def MMI_PABSH     : Mmi2Op<"pabsh", NoItinerary>, MMI_2_OP_FM<0x5, 0x28>, ASE_R5900;
  def MMI_PCEQH     : Mmi3Op<"pceqh", NoItinerary>, MMI_3_OP_FM<0x6, 0x28>, ASE_R5900;
  def MMI_PMINH     : Mmi3Op<"pminh", NoItinerary>, MMI_3_OP_FM<0x7, 0x28>, ASE_R5900;
  def MMI_PCEQB     : Mmi3Op<"pceqb", NoItinerary>, MMI_3_OP_FM<0xa, 0x28>, ASE_R5900;
  def MMI_PADDUW    : Mmi3Op<"padduw", NoItinerary>, MMI_3_OP_FM<0x10, 0x28>, ASE_R5900;
  def MMI_PSUBUW    : Mmi3Op<"psubuw", NoItinerary>, MMI_3_OP_FM<0x11, 0x28>, ASE_R5900;
  def MMI_PEXTUW    : Mmi3Op<"pextuw", NoItinerary>, MMI_3_OP_FM<0x12, 0x28>, ASE_R5900;
  def MMI_PADDUH    : Mmi3Op<"padduh", NoItinerary>, MMI_3_OP_FM<0x14, 0x28>, ASE_R5900;
  def MMI_PSUBUH    : Mmi3Op<"psubuh", NoItinerary>, MMI_3_OP_FM<0x15, 0x28>, ASE_R5900;
  def MMI_PEXTUH    : Mmi3Op<"pextuh", NoItinerary>, MMI_3_OP_FM<0x16, 0x28>, ASE_R5900;
  def MMI_PADDUB    : Mmi3Op<"paddub", NoItinerary>, MMI_3_OP_FM<0x18, 0x28>, ASE_R5900;
  def MMI_PSUBUB    : Mmi3Op<"psubub", NoItinerary>, MMI_3_OP_FM<0x19, 0x28>, ASE_R5900;
  def MMI_PEXTUB    : Mmi3Op<"pextub", NoItinerary>, MMI_3_OP_FM<0x1a, 0x28>, ASE_R5900;

  // MMI2
  def MMI_PMADDW    : MmiMAdd<"pmaddw", NoItinerary>, MMI_3_OP_FM<0x0, 0x9>, ASE_R5900;
  def MMI_PSLLVW    : Mmi3Op<"psllvw", NoItinerary>, MMI_3_OP_FM<0x2, 0x9>, ASE_R5900;
  def MMI_PSRLVW    : Mmi3Op<"psrlvw", NoItinerary>, MMI_3_OP_FM<0x3, 0x9>, ASE_R5900;
  def MMI_PMSUBW    : MmiMAdd<"pmsubw", NoItinerary>, MMI_3_OP_FM<0x4, 0x9>, ASE_R5900;
  def MMI_PMFHI     : MmiMoveFromLOHI<"pmfhi", NoItinerary, [EE_HI_128]>, 
                      MMI_MFLOHI_FM<0x8, 0x9>, ASE_R5900;
  def MMI_PMFLO     : MmiMoveFromLOHI<"pmflo", NoItinerary, [EE_LO_128]>, 
                      MMI_MFLOHI_FM<0x9, 0x9>, ASE_R5900;
  def MMI_PINTH     : Mmi3Op<"pinth", NoItinerary>, MMI_3_OP_FM<0xa, 0x9>, ASE_R5900;
  def MMI_PMULTW    : MmiMul<"pmultw", NoItinerary>, MMI_3_OP_FM<0xc, 0x9>, ASE_R5900;
  def MMI_PDIVW     : MmiDiv<"pdivw", NoItinerary>, MMI_DIV_FM<0xd, 0x9>, ASE_R5900;
  def MMI_PCPYLD    : Mmi3Op<"pcpyld", NoItinerary>, MMI_3_OP_FM<0xe, 0x9>, ASE_R5900;
  def MMI_PMADDH    : MmiMAdd<"pmaddh", NoItinerary>, MMI_3_OP_FM<0x10, 0x9>, ASE_R5900;
  def MMI_PHMADH    : MmiMul<"phmadh", NoItinerary>, MMI_3_OP_FM<0x11, 0x9>, ASE_R5900;
  def MMI_PAND      : Mmi3Op<"pand", NoItinerary>, MMI_3_OP_FM<0x12, 0x9>, ASE_R5900;
  def MMI_PXOR      : Mmi3Op<"pxor", NoItinerary>, MMI_3_OP_FM<0x13, 0x9>, ASE_R5900;
  def MMI_PMSUBH    : MmiMAdd<"pmsubh", NoItinerary>, MMI_3_OP_FM<0x14, 0x9>, ASE_R5900;
  def MMI_PHMSBH    : MmiMul<"phmsbh", NoItinerary>, MMI_3_OP_FM<0x15, 0x9>, ASE_R5900;
  def MMI_PEXEH     : Mmi2Op<"pexeh", NoItinerary>, MMI_2_OP_FM<0x1a, 0x9>, ASE_R5900;
  def MMI_PREVH     : Mmi2Op<"prevh", NoItinerary>, MMI_2_OP_FM<0x1b, 0x9>, ASE_R5900;
  def MMI_PMULTH    : MmiMul<"pmulth", NoItinerary>, MMI_3_OP_FM<0x1c, 0x9>, ASE_R5900;
  def MMI_PDIVBW    : MmiDiv<"pdivbw", NoItinerary>, MMI_DIV_FM<0x1d, 0x9>, ASE_R5900;
  def MMI_PEXEW     : Mmi2Op<"pexew", NoItinerary>, MMI_2_OP_FM<0x1e, 0x9>, ASE_R5900;
  def MMI_PROT3W    : Mmi2Op<"prot3w", NoItinerary>, MMI_2_OP_FM<0x1f, 0x9>, ASE_R5900;

  // MMI3
  def MMI_PMADDUW   : MmiMAdd<"pmadduw", NoItinerary>, MMI_3_OP_FM<0x0, 0x29>, ASE_R5900;
  def MMI_PSRAVW    : Mmi3Op<"psravw", NoItinerary>, MMI_3_OP_FM<0x3, 0x29>, ASE_R5900;
  def MMI_PMTHI     : MmiMoveToLOHI<"pmthi", NoItinerary, [EE_HI_128]>, 
                      MMI_MTLOHI_FM<0x8, 0x29>, ASE_R5900;
  def MMI_PMTLO     : MmiMoveToLOHI<"pmtlo", NoItinerary, [EE_LO_128]>, 
                      MMI_MTLOHI_FM<0x9, 0x29>, ASE_R5900;
  def MMI_PINTEH    : Mmi3Op<"pinteh", NoItinerary>, MMI_3_OP_FM<0xa, 0x29>, ASE_R5900;
  def MMI_PMULTUW   : MmiMul<"pmultuw", NoItinerary>, MMI_3_OP_FM<0xc, 0x29>, ASE_R5900;
  def MMI_PDIVUW    : MmiDiv<"pdivuw", NoItinerary>, MMI_DIV_FM<0xd, 0x29>, ASE_R5900;
  def MMI_PCPYUD    : Mmi3Op<"pcpyud", NoItinerary>, MMI_3_OP_FM<0xe, 0x29>, ASE_R5900;
  def MMI_POR       : Mmi3Op<"por", NoItinerary>, MMI_3_OP_FM<0x12, 0x29>, ASE_R5900;
  def MMI_PNOR      : Mmi3Op<"pnor", NoItinerary>, MMI_3_OP_FM<0x13, 0x29>, ASE_R5900;
  def MMI_PEXCH     : Mmi2Op<"pexch", NoItinerary>, MMI_2_OP_FM<0x1a, 0x29>, ASE_R5900;
  def MMI_PCPYH     : Mmi2Op<"pcpyh", NoItinerary>, MMI_2_OP_FM<0x1b, 0x29>, ASE_R5900;
  def MMI_PEXCW     : Mmi2Op<"pexcw", NoItinerary>, MMI_2_OP_FM<0x1e, 0x29>, ASE_R5900;

  // PMFHL
  def MMI_PMFHL_LW  : MmiMoveFromLOHI<"pmfhl.lw", NoItinerary, [EE_LO_128, EE_HI_128]>, 
                      MMI_MFLOHI_FM<0x0, 0x30>, ASE_R5900;
  def MMI_PMFHL_UW  : MmiMoveFromLOHI<"pmfhl.uw", NoItinerary, [EE_LO_128, EE_HI_128]>, 
                      MMI_MFLOHI_FM<0x1, 0x30>, ASE_R5900;
  def MMI_PMFHL_SLW : MmiMoveFromLOHI<"pmfhl.slw", NoItinerary, [EE_LO_128, EE_HI_128]>, 
                      MMI_MFLOHI_FM<0x2, 0x30>, ASE_R5900;
  def MMI_PMFHL_LH  : MmiMoveFromLOHI<"pmfhl.lh", NoItinerary, [EE_LO_128, EE_HI_128]>, 
                      MMI_MFLOHI_FM<0x3, 0x30>, ASE_R5900;
  def MMI_PMFHL_SH  : MmiMoveFromLOHI<"pmfhl.sh", NoItinerary, [EE_LO_128, EE_HI_128]>, 
                      MMI_MFLOHI_FM<0x4, 0x30>, ASE_R5900;
  
  // PMTHL
  def MMI_PMTHL_LW  : MmiMoveToLOHI<"pmthl.lw", NoItinerary, [EE_LO_128, EE_HI_128]>, 
                      MMI_MTLOHI_FM<0x0, 0x31>, ASE_R5900;

  // Parallel Shifts
  def MMI_PSLLH     : MmiParShift<"psllh", NoItinerary>, MMI_PAR_SHIFT_FM<0x34>, ASE_R5900;
  def MMI_PSRLH     : MmiParShift<"psrlh", NoItinerary>, MMI_PAR_SHIFT_FM<0x36>, ASE_R5900;
  def MMI_PSRAH     : MmiParShift<"psrah", NoItinerary>, MMI_PAR_SHIFT_FM<0x37>, ASE_R5900;
  def MMI_PSLLW     : MmiParShift<"psllw", NoItinerary>, MMI_PAR_SHIFT_FM<0x3c>, ASE_R5900;
  def MMI_PSRLW     : MmiParShift<"psrlw", NoItinerary>, MMI_PAR_SHIFT_FM<0x3e>, ASE_R5900;
  def MMI_PSRAW     : MmiParShift<"psraw", NoItinerary>, MMI_PAR_SHIFT_FM<0x3f>, ASE_R5900;
}