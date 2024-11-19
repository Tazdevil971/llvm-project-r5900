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

#ifndef LLVM_LIB_TARGET_MIPS_MIPSR5900ISELLOWERING_H
#define LLVM_LIB_TARGET_MIPS_MIPSR5900ISELLOWERING_H

#include "MipsSEISelLowering.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"

namespace llvm {

class MipsSubtarget;
class MipsTargetMachine;

class MipsR5900TargetLowering : public MipsSETargetLowering {
public:
  explicit MipsR5900TargetLowering(const MipsTargetMachine &TM,
                                   const MipsSubtarget &STI);

  SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

  SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;

private:
  SDValue lowerMUL(SDValue Op, unsigned NewOpc, bool HasLo,
                   SelectionDAG &DAG) const;

  SDValue tryPerformMADDChainCombine(SDNode *N, DAGCombinerInfo &DCI) const;
  SDValue tryPerformMADDSChainCombine(SDNode *N, DAGCombinerInfo &DCI) const;
  SDValue tryPerformRSQRTCombine(SDNode *N, DAGCombinerInfo &DCI) const;
};

} // namespace llvm

#endif