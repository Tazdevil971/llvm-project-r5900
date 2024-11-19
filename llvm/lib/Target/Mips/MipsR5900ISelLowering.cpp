//===- MipsSEISelLowering.h - MipsSE DAG Lowering Interface -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Subclass of MipsTargetLowering specialized for R5900.
//
//===----------------------------------------------------------------------===//

#include "MipsR5900ISelLowering.h"
#include "MipsISelLowering.h"
#include "MipsSEISelLowering.h"
#include "MipsSubtarget.h"
#include "llvm/CodeGen/ISDOpcodes.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include <tuple>

using namespace llvm;

#define DEBUG_TYPE "r5900-isel"

static cl::opt<bool> DisableEeMAddChainCombine(
    "disable-ee-madd-chain-combine", cl::init(false),
    cl::desc("MIPS R5900: Disable madd chain combine (debug)."), cl::Hidden);

static cl::opt<bool> DisableEeMAddsChainCombine(
    "disable-ee-madds-chain-combine", cl::init(false),
    cl::desc("MIPS R5900: Disable madd.s chain combine (debug)."), cl::Hidden);

MipsR5900TargetLowering::MipsR5900TargetLowering(const MipsTargetMachine &TM,
                                                 const MipsSubtarget &STI)
    : MipsSETargetLowering(TM, STI) {
  // The R5900 doesn't support ll/sc, use libcalls for them
  for (MVT VT : MVT::integer_valuetypes()) {
    setOperationAction(ISD::ATOMIC_CMP_SWAP, VT, LibCall);
    setOperationAction(ISD::ATOMIC_SWAP, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_ADD, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_SUB, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_AND, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_OR, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_XOR, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_NAND, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_MIN, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_MAX, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_UMIN, VT, LibCall);
    setOperationAction(ISD::ATOMIC_LOAD_UMAX, VT, LibCall);
  }

  // This CPU requires custom handling for optimized lowering of mul operations
  setOperationAction(ISD::SMUL_LOHI, MVT::i32, Custom);
  setOperationAction(ISD::UMUL_LOHI, MVT::i32, Custom);
  setOperationAction(ISD::MULHS, MVT::i32, Custom);
  setOperationAction(ISD::MULHU, MVT::i32, Custom);

  setOperationAction(ISD::MUL, MVT::i32, Legal);

  // The R5900 doesn't have 64bit mul/div hardware
  setOperationAction(ISD::MUL, MVT::i64, Expand);
  setOperationAction(ISD::SMUL_LOHI, MVT::i64, Expand);
  setOperationAction(ISD::UMUL_LOHI, MVT::i64, Expand);
  setOperationAction(ISD::MULHS, MVT::i64, Expand);
  setOperationAction(ISD::MULHU, MVT::i64, Expand);
  setOperationAction(ISD::SDIVREM, MVT::i64, Expand);
  setOperationAction(ISD::UDIVREM, MVT::i64, Expand);

  // TODO: For some reason the R5900 requires this? Why?
  // (Probably required due to the quirky nature of having 32bit mul HW but
  // 64bit registers)
  setOperationAction(ISD::BUILD_PAIR, MVT::i64, Expand);

  // The R5900 has extra FPU instructions
  if (!Subtarget.useSoftFloat()) {
    setOperationAction(ISD::FMINNUM, MVT::f32, Legal);
    setOperationAction(ISD::FMAXNUM, MVT::f32, Legal);
    setOperationAction(ISD::FSQRT, MVT::f32, Legal);
  }

  setTargetDAGCombine({ISD::ADD, ISD::FDIV, ISD::FADD, ISD::FSUB});
}

SDValue MipsR5900TargetLowering::LowerOperation(SDValue Op,
                                                SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  case ISD::SMUL_LOHI:
    return lowerMUL(Op, MipsISD::EE_MULT, true, DAG);
  case ISD::UMUL_LOHI:
    return lowerMUL(Op, MipsISD::EE_MULTU, true, DAG);
  case ISD::MULHS:
    return lowerMUL(Op, MipsISD::EE_MULT, false, DAG);
  case ISD::MULHU:
    return lowerMUL(Op, MipsISD::EE_MULTU, false, DAG);
  default:
    return MipsSETargetLowering::LowerOperation(Op, DAG);
  }
}

SDValue MipsR5900TargetLowering::PerformDAGCombine(SDNode *N,
                                                   DAGCombinerInfo &DCI) const {
  SDValue Val;
  switch (N->getOpcode()) {
  case ISD::ADD:
    // Try performing (add (mul ...), ...) chain combine
    Val = tryPerformMADDChainCombine(N, DCI);
    break;
  case ISD::FDIV:
    // Try performing (div ..., (sqrt ...)) combine
    Val = tryPerformRSQRTCombine(N, DCI);
    break;
  case ISD::FADD:
  case ISD::FSUB:
    // Try performing (fadd/fsub (fmul ...), ...) chain combine
    Val = tryPerformMADDSChainCombine(N, DCI);
    break;
  }

  if (Val.getNode()) {
    return Val;
  }

  return MipsSETargetLowering::PerformDAGCombine(N, DCI);
}

SDValue MipsR5900TargetLowering::lowerMUL(SDValue Op, unsigned NewOpc,
                                          bool HasLo, SelectionDAG &DAG) const {
  SDLoc DL(Op);

  SDVTList VTs = DAG.getVTList(MVT::i32, MVT::Untyped);
  SDValue Mult =
      DAG.getNode(NewOpc, DL, VTs, Op.getOperand(0), Op.getOperand(1));

  SDValue MfHi = DAG.getNode(MipsISD::MFHI, DL, MVT::i32, Mult.getValue(1));
  if (!HasLo)
    return MfHi;

  return DAG.getMergeValues({Mult, MfHi}, DL);
}

SDValue MipsR5900TargetLowering::tryPerformMADDChainCombine(
    SDNode *N, DAGCombinerInfo &DCI) const {
  // This might be forcefully disabled
  if (DisableEeMAddChainCombine)
    return SDValue();

  // MADD is only supported on 32/64bit adds
  if (N->getValueType(0) != MVT::i64 && N->getValueType(0) != MVT::i32)
    return SDValue();

  SelectionDAG &DAG = DCI.DAG;

  // Convenient function to check if a Node is a zero extended 32bit value
  auto Is32BitZExt = [&DAG](SDValue &Node) {
    APInt HighMask = APInt::getHighBitsSet(64, 32);
    return DAG.MaskedValueIsZero(Node, HighMask);
  };

  // Convenient function to check if a Node is a sign extended 32bit value
  auto Is32BitSExt = [&DAG](SDValue &Node) {
    return DAG.ComputeMaxSignificantBits(Node) <= 32;
  };

  bool Is32Bit = N->getValueType(0) == MVT::i32;

  llvm::SmallVector<std::tuple<SDValue, SDValue, bool>, 6> Chain;
  SDValue Cur(N, 0);

  // First, find all ADD/MUL nodes to convert to MADD
  do {
    // Check if at least one of the inputs is a MUL
    if (Cur.getOperand(0)->getOpcode() != ISD::MUL &&
        Cur.getOperand(1)->getOpcode() != ISD::MUL)
      break;

    SDValue Mult = Cur.getOperand(0).getOpcode() == ISD::MUL
                       ? Cur.getOperand(0)
                       : Cur.getOperand(1);
    SDValue Acc = Cur.getOperand(0).getOpcode() == ISD::MUL ? Cur.getOperand(1)
                                                            : Cur.getOperand(0);

    // If the mult result is used multiple times, don't combine
    if (!Mult.hasOneUse())
      break;

    SDValue MultLHS = Mult.getOperand(0);
    SDValue MultRHS = Mult.getOperand(1);

    bool IsSigned;
    if (Is32Bit || (Is32BitSExt(MultLHS) && Is32BitSExt(MultRHS))) {
      IsSigned = true;
    } else if (Is32BitZExt(MultLHS) && Is32BitZExt(MultRHS)) {
      IsSigned = false;
    } else {
      break;
    }

    Chain.push_back({MultLHS, MultRHS, IsSigned});
    Cur = Acc;
  } while (Cur.getOpcode() == ISD::ADD && Cur.hasOneUse());

  // We didn't find any valid madd candidates
  if (Chain.empty())
    return SDValue();

  SDValue AccIn = Cur;

  std::reverse(Chain.begin(), Chain.end());

  // Start of codegen
  SDLoc DL(N);

  auto LastInfo = Chain.pop_back_val();

  // Initialize HI/LO
  SDValue Acc;

  // If the accumulator comes from a mul, try to generate a multa/multau
  if (AccIn.getOpcode() == ISD::MUL && AccIn.hasOneUse()) {
    SDValue LHS = AccIn.getOperand(0);
    SDValue RHS = AccIn.getOperand(1);

    bool IsValid = false;
    bool IsSigned;
    if (Is32Bit || (Is32BitSExt(LHS) && Is32BitSExt(RHS))) {
      IsSigned = true;
      IsValid = true;
    } else if (Is32BitZExt(LHS) && Is32BitZExt(RHS)) {
      IsSigned = false;
      IsValid = true;
    }

    if (IsValid) {
      if (!Is32Bit) {
        LHS = DAG.getNode(ISD::TRUNCATE, DL, MVT::i32, LHS);
        RHS = DAG.getNode(ISD::TRUNCATE, DL, MVT::i32, RHS);
      }

      Acc = DAG.getNode(IsSigned ? MipsISD::EE_MULTA : MipsISD::EE_MULTUA, DL,
                        MVT::Untyped, LHS, RHS);
    }
  }

  if (!Acc.getNode()) {
    // We failed to initialize the Acc, fallback to MTLOHI
    SDValue Lo, Hi;
    if (Is32Bit) {
      Lo = AccIn;
      Hi = DAG.getConstant(0, DL, MVT::i32);
    } else {
      std::tie(Lo, Hi) = DAG.SplitScalar(AccIn, DL, MVT::i32, MVT::i32);
    }

    Acc = DAG.getNode(MipsISD::MTLOHI, DL, MVT::Untyped, Lo, Hi);
  }

  // Build the madd/maddu chain (this chain uses $zero as the target register)
  for (auto [LHS, RHS, IsSigned] : Chain) {
    if (!Is32Bit) {
      // We need to truncate inputs to 32bits, the discovery phase already
      // asserted that this is safe
      LHS = DAG.getNode(ISD::TRUNCATE, DL, MVT::i32, LHS);
      RHS = DAG.getNode(ISD::TRUNCATE, DL, MVT::i32, RHS);
    }

    Acc = DAG.getNode(IsSigned ? MipsISD::EE_MADDA : MipsISD::EE_MADDUA, DL,
                      MVT::Untyped, LHS, RHS, Acc);
  }

  auto [LHS, RHS, IsSigned] = LastInfo;
  if (!Is32Bit) {
    LHS = DAG.getNode(ISD::TRUNCATE, DL, MVT::i32, LHS);
    RHS = DAG.getNode(ISD::TRUNCATE, DL, MVT::i32, RHS);
  }

  // Build the final madd/maddu node
  SDVTList VTs = DAG.getVTList(MVT::i32, MVT::Untyped);
  SDValue MAdd = DAG.getNode(IsSigned ? MipsISD::EE_MADD : MipsISD::EE_MADDU,
                             DL, VTs, LHS, RHS, Acc);
  if (Is32Bit)
    return MAdd;

  SDValue MfHi = DAG.getNode(MipsISD::MFHI, DL, MVT::i32, MAdd.getValue(1));
  return DAG.getNode(ISD::BUILD_PAIR, DL, MVT::i64, MAdd, MfHi);
}

SDValue MipsR5900TargetLowering::tryPerformMADDSChainCombine(
    SDNode *N, DAGCombinerInfo &DCI) const {
  // This might be forcefully disabled
  if (DisableEeMAddsChainCombine)
    return SDValue();

  // Check that we actually have hard floats enabled
  if (Subtarget.useSoftFloat())
    return SDValue();

  // The FPU only supports floats
  if (N->getValueType(0) != MVT::f32)
    return SDValue();

  llvm::SmallVector<std::tuple<SDValue, SDValue, bool>, 6> Chain;
  SDValue Cur(N, 0);

  do {
    bool IsAdd = Cur.getOpcode() == ISD::FADD;

    SDValue Mult, Acc;

    if (IsAdd) {
      // Check if at least one of the inputs is a FMUL
      if (Cur.getOperand(0)->getOpcode() != ISD::FMUL &&
          Cur.getOperand(1)->getOpcode() != ISD::FMUL)
        break;

      Mult = Cur.getOperand(0).getOpcode() == ISD::FMUL ? Cur.getOperand(0)
                                                        : Cur.getOperand(1);
      Acc = Cur.getOperand(0).getOpcode() == ISD::FMUL ? Cur.getOperand(1)
                                                       : Cur.getOperand(0);
    } else {
      Mult = Cur.getOperand(1);
      Acc = Cur.getOperand(0);

      // Check that the input is actually a mult
      if (Mult.getOpcode() != ISD::FMUL)
        break;
    }

    // The accumulator must come from a FSUB/FADD/FMUL
    if (Acc.getOpcode() != ISD::FADD && Acc.getOpcode() != ISD::FSUB &&
        Acc.getOpcode() != ISD::FMUL)
      break;

    // If the mult or the acc result is used multiple times, don't combine
    if (!Mult.hasOneUse() || !Acc.hasOneUse())
      break;

    SDValue MultLHS = Mult.getOperand(0);
    SDValue MultRHS = Mult.getOperand(1);

    Chain.push_back({MultLHS, MultRHS, IsAdd});
    Cur = Acc;
  } while (Cur.getOpcode() == ISD::FADD || Cur.getOpcode() == ISD::FSUB);

  // We didn't find any valid candidate
  if (Chain.empty())
    return SDValue();

  SDValue AccIn = Cur;

  std::reverse(Chain.begin(), Chain.end());

  // Start of codegen
  SelectionDAG &DAG = DCI.DAG;
  SDLoc DL(N);

  auto LastInfo = Chain.pop_back_val();

  // Create the initial adda.s/suba.s/mula.s to fill the accumulator register
  unsigned Opcode = AccIn.getOpcode() == ISD::FADD   ? MipsISD::EE_ADDAS
                    : AccIn.getOpcode() == ISD::FSUB ? MipsISD::EE_SUBAS
                                                     : MipsISD::EE_MULAS;
  SDValue AccGlue = DAG.getNode(Opcode, DL, MVT::Glue, AccIn.getOperand(0),
                                AccIn.getOperand(1));

  // Build the madda.s/msuba.s chain
  for (auto [LHS, RHS, IsAdd] : Chain) {
    AccGlue = DAG.getNode(IsAdd ? MipsISD::EE_MADDAS : MipsISD::EE_MSUBAS, DL,
                          MVT::Glue, LHS, RHS, AccGlue);
  }

  // Build the final madd.s/msub.s node
  auto [LHS, RHS, IsAdd] = LastInfo;

  return DAG.getNode(IsAdd ? MipsISD::EE_MADDS : MipsISD::EE_MSUBS, DL,
                     MVT::f32, LHS, RHS, AccGlue);
}

SDValue
MipsR5900TargetLowering::tryPerformRSQRTCombine(SDNode *N,
                                                DAGCombinerInfo &DCI) const {
  // Check that we actually have hard floats enabled
  if (Subtarget.useSoftFloat())
    return SDValue();

  // The FPU only supports floats
  if (N->getValueType(0) != MVT::f32)
    return SDValue();

  // Verify that the other argument is actually a square root
  SDValue Sqrt = N->getOperand(1);
  if (Sqrt.getOpcode() != ISD::FSQRT)
    return SDValue();

  // If the square root is used multiple times, this is not worth it
  if (!Sqrt.hasOneUse())
    return SDValue();

  SelectionDAG &DAG = DCI.DAG;
  SDLoc DL(N);

  return DAG.getNode(MipsISD::EE_RSQRTS, DL, MVT::f32, N->getOperand(0),
                     Sqrt.getOperand(0));
}
