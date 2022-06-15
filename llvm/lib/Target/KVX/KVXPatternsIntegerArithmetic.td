//===----------------------------------------------------------------------===//
//  Integer Instructions - Patterns helpers
//===----------------------------------------------------------------------===//
def EXTFZDp : KVX_PSEUDO<(outs SingleReg:$out), (ins SingleReg:$a, Wrapped64:$andm, Wrapped64:$shifc), []>;
def EXTFZWp : KVX_PSEUDO<(outs SingleReg:$out), (ins SingleReg:$a, Wrapped32:$andm, Wrapped64:$shifc), []>;

def ORNDriPat : PatFrag<(ops node:$op0, node:$op1), (xor node:$op0, node:$op1), [{
    ConstantSDNode *c1 = dyn_cast<ConstantSDNode>(N->getOperand(1));
    if (!c1)
      return false;
    SDValue op0 = N->getOperand(0);

    if (op0.getOpcode() != ISD::OR)
      return false;

    ConstantSDNode *c2 = dyn_cast<ConstantSDNode>(op0->getOperand(1));
    if (!c2)
      return false;

    return ((c1->getSExtValue()+1) == (-c2->getSExtValue()));
  }]>;

def nswadd : PatFrag<(ops node:$op0, node:$op1), (add node:$op0, node:$op1), [{
    return N->getFlags().hasNoSignedWrap();
  }]>;

def nuwadd : PatFrag<(ops node:$op0, node:$op1), (add node:$op0, node:$op1), [{
    return N->getFlags().hasNoUnsignedWrap();
  }]>;

def notShiftMaskStart : SDNodeXForm<imm, [{
  const auto AP = N->getAPIntValue();
  return CurDAG->getTargetConstant(
      AP.countTrailingOnes(),
      SDLoc(N), MVT::i32);
}]>;

def notShiftMaskEnd : SDNodeXForm<imm, [{
  const auto AP = N->getAPIntValue();
  return CurDAG->getTargetConstant(
      AP.getBitWidth() - AP.countLeadingOnes() - 1,
      SDLoc(N), MVT::i32);

}]>;

def isNotShiftMask : PatLeaf<(imm), [{
  return (~N->getAPIntValue()).isShiftedMask();
}]>;

def ShiftMaskStart : SDNodeXForm<imm, [{
  const auto AP = N->getAPIntValue();
  return CurDAG->getTargetConstant(
      std::max(0l, (long)(AP.countTrailingZeros())-1),
      SDLoc(N), MVT::i32);
}]>;

def ShiftMaskEnd : SDNodeXForm<imm, [{
  const auto AP = N->getAPIntValue();
  return CurDAG->getTargetConstant(
      AP.getBitWidth() - AP.countLeadingZeros() -1,
      SDLoc(N), MVT::i32);
}]>;

def isShiftMask : PatLeaf<(imm), [{
  return N->getAPIntValue().isShiftedMask();
}]>;

def isMask : PatLeaf<(imm), [{
  return N->getAPIntValue().isMask();
}]>;

defm : ZEFPat<(and (srl i32:$v, Wrapped64:$shiftc), isMask:$andm), (EXTFZWp SingleReg:$v, Wrapped32:$andm, Wrapped64:$shiftc)>;

//===----------------------------------------------------------------------===//
//  Integer Instructions - Patterns
//===----------------------------------------------------------------------===//

// ABDD
def : Pat<(i64 (abs (sub imm:$lhs, i64:$rhs))), (i64 (ABDDri10 SingleReg:$rhs, Signed10:$lhs))>;
def : Pat<(i64 (abs (sub imm:$lhs, i64:$rhs))), (i64 (ABDDri37 SingleReg:$rhs, Signed37:$lhs))>;
def : Pat<(i64 (abs (sub imm:$lhs, i64:$rhs))), (i64 (ABDDri64 SingleReg:$rhs, Wrapped64:$lhs))>;
def : Pat<(i64 (abs (sub i64:$lhs, i64:$rhs))), (i64 (ABDDrr SingleReg:$rhs, SingleReg:$lhs))>;

// ABDBO
def : Pat<(v2i8 (abs (sub (v2i8 (is_imm_vec:$IMM)), v2i8:$rhs))), (v2i8 (ABDBOri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(v2i8 (abs (sub v2i8:$lhs, v2i8:$rhs))), (v2i8 (ABDBOrr SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV2]>;
def : Pat<(v4i8 (abs (sub (v4i8 (is_imm_vec_kvx_splat32_:$IMM)), v4i8:$rhs))), (v4i8 (ABDBOri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(v4i8 (abs (sub v4i8:$lhs, v4i8:$rhs))), (v4i8 (ABDBOrr SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV2]>;
def : Pat<(v8i8 (abs (sub (v8i8 (is_imm_vec_kvx_splat32_:$IMM)), v8i8:$rhs))), (v8i8 (ABDBOri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(v8i8 (abs (sub (v8i8 (is_imm_vec_kvx_splat32_at:$IMM)), v8i8:$rhs))), (v8i8 (ABDBOri SingleReg:$rhs, (build_imm_vec $IMM), splat32_at ) )>, Requires<[IsV2]>;
def : Pat<(v8i8 (abs (sub v8i8:$lhs, v8i8:$rhs))), (v8i8 (ABDBOrr SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV2]>;

// ABDHQ
def : Pat<(v2i16 (abs (sub (v2i16 (is_imm_vec:$IMM)), v2i16:$rhs))), (v2i16 (ABDHQri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>;
def : Pat<(v2i16 (abs (sub v2i16:$lhs, v2i16:$rhs))), (v2i16 (ABDHQrr SingleReg:$rhs, SingleReg:$lhs))>;

def : Pat<(v4i16 (abs (sub (v4i16 (is_imm_vec_kvx_splat32_:$IMM)), v4i16:$rhs))), (v4i16 (ABDHQri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>;
def : Pat<(v4i16 (abs (sub (v4i16 (is_imm_vec_kvx_splat32_at:$IMM)), v4i16:$rhs))), (v4i16 (ABDHQri SingleReg:$rhs, (build_imm_vec $IMM), splat32_at ) )>;
def : Pat<(v4i16 (abs (sub v4i16:$lhs, v4i16:$rhs))), (v4i16 (ABDHQrr SingleReg:$rhs, SingleReg:$lhs))>;

multiclass ABDS_64bit <ValueType vt, KVX_INSTRUCTION rr, KVX_INSTRUCTION ri> {
def : Pat<(vt (abs (ssubsat vt:$lhs, (vt (is_imm_vec_kvx_splat32_:$IMM))))), (vt (ri SingleReg:$lhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(vt (abs (ssubsat (vt (is_imm_vec_kvx_splat32_:$IMM)), vt:$rhs))), (vt (ri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(vt (abs (ssubsat vt:$lhs,  (vt (is_imm_vec_kvx_splat32_at:$IMM))))), (vt (ri SingleReg:$lhs, (build_imm_vec $IMM), splat32_at ) )>, Requires<[IsV2]>;
def : Pat<(vt (abs (ssubsat (vt (is_imm_vec_kvx_splat32_at:$IMM)), vt:$rhs))), (vt (ri SingleReg:$rhs, (build_imm_vec $IMM), splat32_at ) )>, Requires<[IsV2]>;
def : Pat<(vt (abs (ssubsat vt:$lhs, vt:$rhs))), (vt(rr SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV2]>;
}

// ABDSBO
foreach vt = [v2i8, v4i8] in {
def : Pat<(vt (abs (ssubsat (vt (is_imm_vec_kvx_splat32_:$IMM)), vt:$rhs))), (vt (ABDSBOri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(vt (abs (ssubsat vt:$lhs, (vt (is_imm_vec_kvx_splat32_:$IMM))))), (vt (ABDSBOri SingleReg:$lhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(vt (abs (ssubsat vt:$lhs, vt:$rhs))), (vt(ABDSBOrr SingleReg:$lhs, SingleReg:$rhs))>, Requires<[IsV2]>;
}

defm : ABDS_64bit<v8i8, ABDSBOrr, ABDSBOri>;

// ABDSHQ
def : Pat<(v2i16 (abs (ssubsat (v2i16 (is_imm_vec_kvx_splat32_:$IMM)), v2i16:$rhs))), (v2i16 (ABDSHQri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(v2i16 (abs (ssubsat v2i16:$lhs, (v2i16 (is_imm_vec_kvx_splat32_:$IMM))))), (v2i16 (ABDSHQri SingleReg:$lhs, (build_imm_vec $IMM), splat32_ ) )>, Requires<[IsV2]>;
def : Pat<(v2i16 (abs (ssubsat v2i16:$lhs, v2i16:$rhs))), (v2i16(ABDSHQrr SingleReg:$lhs, SingleReg:$rhs))>, Requires<[IsV2]>;

defm : ABDS_64bit<v4i16, ABDSHQrr, ABDSHQri>;

// ABDSD
def : Pat<(i64(abs (ssubsat Unsigned64W:$lhs, i64:$rhs))),
          (ABDSDri SingleReg:$rhs, (i32(trunc_imm_32 $lhs)), splat32_)>, Requires<[IsV2]>;

def : Pat<(i64(abs(ssubsat UnsignedSplat32Imm:$lhs, i64:$rhs))),
          (ABDSDri SingleReg:$rhs, (i32(trunc_imm_32 $lhs)), splat32_at)>, Requires<[IsV2]>;

def : Pat<(i64(abs(ssubsat i64:$lhs, i64:$rhs))),
          (ABDSDrr SingleReg:$rhs, SingleReg:$lhs)>, Requires<[IsV2]>;

// ABDSW
def : Pat<(i32 (trunc (i64 (umin (abs (sub Wrapped64W:$lhs, (sext (i32 SingleReg:$rhs)))), i64_i32_max)))),
          (i32 (ABDSWri SingleReg:$rhs, (trunc_imm_32 $lhs), splat32_))>, Requires<[IsV2]>;

def : Pat<(i32 (trunc (i64 (umin (abs (sub (sext(i32 SingleReg:$lhs)), (sext (i32 SingleReg:$rhs)))), i64_i32_max)))),
          (i32 (ABDSWrr SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV2]>;

def : Pat<(i32 (abs (ssubsat i32:$lhs, Wrapped32:$rhs))),
          (i32 (ABDSWri SingleReg:$rhs, Wrapped32:$lhs, splat32_ ) )>, Requires<[IsV2]>;

def : Pat<(i32 (abs (ssubsat i32:$lhs, i32:$rhs))),
          (i32 (ABDSWrr SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV2]>;

// ABDSWP
defm : ABDS_64bit<v2i32, ABDSWPrr, ABDSWPri>;

// ABDW
def : Pat<(i32 (abs (sub imm:$lhs, i32:$rhs))), (i32 (ABDWri10 SingleReg:$rhs, Signed10W:$lhs))>;
def : Pat<(i32 (abs (sub imm:$lhs, i32:$rhs))), (i32 (ABDWri37 SingleReg:$rhs, Wrapped32:$lhs))>;
def : Pat<(i32 (abs (sub i32:$lhs, i32:$rhs))), (i32 (ABDWrr SingleReg:$rhs, SingleReg:$lhs))>;

// ABDWP
def : Pat<(v2i32 (abs (sub (v2i32 (is_imm_vec_kvx_splat32_:$IMM)), v2i32:$rhs))), (v2i32 (ABDWPri SingleReg:$rhs, (build_imm_vec $IMM), splat32_ ) )>;
def : Pat<(v2i32 (abs (sub (v2i32 (is_imm_vec_kvx_splat32_at:$IMM)), v2i32:$rhs))), (v2i32 (ABDWPri SingleReg:$rhs, (build_imm_vec $IMM), splat32_at ) )>;
def : Pat<(v2i32 (abs (sub v2i32:$lhs, v2i32:$rhs))), (v2i32 (ABDWPrr SingleReg:$rhs, SingleReg:$lhs))>;

// ABSD
def : Pat<(smax i64:$v, (i64 (ineg i64:$v))), (ABSD SingleReg:$v)>;

// ABSBO
def : Pat<(abs v2i8:$v), (ABSBO SingleReg:$v)>, Requires<[IsV2]>;
def : Pat<(smax v2i8:$v, (v2i8 (vineg v2i8:$v))), (ABSBO SingleReg:$v)>, Requires<[IsV2]>;
def : Pat<(abs v4i8:$v), (ABSBO SingleReg:$v)>, Requires<[IsV2]>;
def : Pat<(smax v4i8:$v, (v4i8 (vineg v4i8:$v))), (ABSBO SingleReg:$v)>, Requires<[IsV2]>;
def : Pat<(smax v8i8:$v, (v8i8 (vineg v8i8:$v))), (ABSBO SingleReg:$v)>, Requires<[IsV2]>;

// ABSHQ
def : Pat<(abs v2i16:$v), (ABSHQ SingleReg:$v)>;
def : Pat<(smax v2i16:$v, (v2i16 (vineg v2i16:$v))), (ABSHQ SingleReg:$v)>;
def : Pat<(smax v4i16:$v, (v4i16 (vineg v4i16:$v))), (ABSHQ SingleReg:$v)>;

// ABSW
def : Pat<(smax i32:$v, (i32 (ineg i32:$v))), (ABSW SingleReg:$v)>;

// ADDCHCP
// TODO: add ri variants
def : Pat<(i64 (or
                  (and
                        (add i64:$t4, i64:$t2),
                        (i64 0xffff)),
                  (and (sub i64:$t4, (and i64:$t2, (i64 0xffff0000))), (i64 0xffff0000)))),
          (ADDCHCPrr SingleReg:$t2, SingleReg:$t4)>, Requires<[IsV1]>;

def : Pat<(i64 (or
                  (or
                        (or
                              (and
                                    (add (and i64:$t2, (i64 0xffff00000000)), i64:$t4),
                                    (i64 0xffff00000000)),
                              (and
                                    (add i64:$t2, i64:$t4),
                                    (i64 0xffff))),
                        (and (sub i64:$t2, (and i64:$t4, (i64 0xffff000000000000))), (i64 0xffff000000000000))),
                  (and (sub i64:$t2, (and i64:$t4, (i64 0xffff0000))), (i64 0xffff0000)))),
          (ADDCHCPrr SingleReg:$t4, SingleReg:$t2)>, Requires<[IsV1]>;

// ADDCWC
// TODO: ri variants
def : Pat<(i64(or(and (sub i64:$r0, (and i64:$r1, (i64 0xffffffff00000000))), (i64 0xffffffff00000000) ),
              (and (add i64:$r0, i64:$r1), (i64 0xffffffff)))),
          (ADDCWCrr SingleReg:$r1, SingleReg:$r0)>, Requires<[IsV1]>;

// ADDD
def : Pat<(add i64:$rs1, i64:$rs2), (ADDDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(add i64:$rs1, Signed10:$rs2), (ADDDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(add i64:$rs1, Signed37:$rs2), (ADDDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(add i64:$rs1, Wrapped64:$rs2), (ADDDri64 SingleReg:$rs1, Wrapped64:$rs2)>;

// ADDBO
def : Pat<(add v2i8:$rs1, (v2i8(is_imm_vec:$IMM))), (ADDBOri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(sub v2i8:$rs1, (v2i8(is_imm_vec:$IMM))), (ADDBOri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(add v2i8:$rs1, v2i8:$rs2), (ADDBOrr SingleReg:$rs1, SingleReg:$rs2)>, Requires<[IsV2]>;

def : Pat<(add v4i8:$rs1, (v4i8(is_imm_vec:$IMM))), (ADDBOri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(sub v4i8:$rs1, (v4i8(is_imm_vec:$IMM))), (ADDBOri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(add v4i8:$rs1, v4i8:$rs2), (ADDBOrr SingleReg:$rs1, SingleReg:$rs2)>, Requires<[IsV2]>;

def : Pat<(add v8i8:$rs1, (v8i8(is_imm_vec_kvx_splat32_:$IMM))), (ADDBOri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(add v8i8:$rs1, (v8i8(is_imm_vec_kvx_splat32_at:$IMM))), (ADDBOri SingleReg:$rs1, (build_imm_vec $IMM), splat32_at)>, Requires<[IsV2]>;
def : Pat<(sub v8i8:$rs1, (v8i8(is_imm_vec_kvx_splat32_:$IMM))), (ADDBOri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(sub v8i8:$rs1, (v8i8(is_imm_vec_kvx_splat32_at:$IMM))), (ADDBOri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_at)>, Requires<[IsV2]>;
def : Pat<(add v8i8:$rs1, v8i8:$rs2), (ADDBOrr SingleReg:$rs1, SingleReg:$rs2)>, Requires<[IsV2]>;

// ADDHQ
def : Pat<(add v2i16:$rs1, (v2i16(is_imm_vec:$IMM))), (ADDHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>;
def : Pat<(add v2i16:$rs1, v2i16:$rs2), (ADDHQrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sub v2i16:$rs1, (v2i16(is_imm_vec:$IMM))), (ADDHQri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_)>;

def : Pat<(add v4i16:$rs1, (v4i16(is_imm_vec_kvx_splat32_:$IMM))), (ADDHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>;
def : Pat<(add v4i16:$rs1, (v4i16(is_imm_vec_kvx_splat32_at:$IMM))), (ADDHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_at)>;
def : Pat<(add v4i16:$rs1, v4i16:$rs2), (ADDHQrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sub v4i16:$rs1, (v4i16(is_imm_vec_kvx_splat32_:$IMM))), (ADDHQri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_)>;
def : Pat<(sub v4i16:$rs1, (v4i16(is_imm_vec_kvx_splat32_at:$IMM))), (ADDHQri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_at)>;

// ADDSBO
def : Pat<(v2i8(saddsat v2i8:$v0, (is_imm_vec:$IMM))),
          (ADDSBOri SingleReg:$v0, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(v2i8(saddsat v2i8:$v0, v2i8:$v1)), (ADDSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v4i8(saddsat v4i8:$v0, (v4i8(is_imm_vec:$IMM)) ) ),
           (ADDSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v4i8(saddsat v4i8:$v0, v4i8:$v1)), (ADDSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v8i8(saddsat v8i8:$v0, (v8i8(is_imm_vec_kvx_splat32_:$IMM)) ) ),
           (ADDSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v8i8(saddsat v8i8:$v0, (v8i8(is_imm_vec_kvx_splat32_at:$IMM)) ) ),
           (ADDSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>, Requires<[IsV2]>;
def : Pat<(v8i8(saddsat v8i8:$v0, v8i8:$v1)), (ADDSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

// ADDSD
def : Pat<(i64(saddsat i64:$v, Signed10:$i)), (ADDSDri10 SingleReg:$v, Signed10:$i)>;
def : Pat<(i64(saddsat i64:$v, Signed37:$i)), (ADDSDri37 SingleReg:$v, Signed37:$i)>;
def : Pat<(i64(saddsat i64:$v, Wrapped64:$i)), (ADDSDri64 SingleReg:$v, Wrapped64:$i)>;
def : Pat<(i64(saddsat i64:$v0, i64:$v1)), (ADDSDrr SingleReg:$v0, SingleReg:$v1)>;

// ADDSHQ
def : Pat<(v2i16(saddsat v2i16:$v0, (is_imm_vec:$IMM))),
          (ADDSHQri SingleReg:$v0, (build_imm_vec $IMM), splat32_)>;
def : Pat<(v2i16(saddsat v2i16:$v0, v2i16:$v1)), (ADDSHQrr SingleReg:$v0, SingleReg:$v1)>;

def : Pat<(v4i16(saddsat v4i16:$v0, (v4i16(is_imm_vec_kvx_splat32_:$IMM)) ) ),
           (ADDSHQri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>;
def : Pat<(v4i16(saddsat v4i16:$v0, (v4i16(is_imm_vec_kvx_splat32_at:$IMM)) ) ),
           (ADDSHQri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>;
def : Pat<(v4i16(saddsat v4i16:$v0, v4i16:$v1)), (ADDSHQrr SingleReg:$v0, SingleReg:$v1)>;

// ADDSW
def : Pat<(i32(saddsat i32:$v, Wrapped32:$i)), (ADDSWri SingleReg:$v, Wrapped32:$i)>;
def : Pat<(i32(saddsat i32:$v0, i32:$v1)), (ADDSWrr SingleReg:$v0, SingleReg:$v1)>;

// ADDSWP
def : Pat<(v2i32(saddsat v2i32:$v0, v2i32:$v1)), (ADDSWPrr SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(v2i32(saddsat v2i32:$v0, v2i32:$v1)), (ADDSWPrr SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(v2i32(saddsat v2i32:$v0, (v2i32 (build_vector (i32 Wrapped32:$i), (i32 0)) ))),
          (ADDSWPri SingleReg:$v0, (trunc_imm_32 imm:$i), splat32_)>;
def : Pat<(v2i32(saddsat v2i32:$v0, (v2i32 (v2_splat (i32 Wrapped32:$i))))),
          (ADDSWPri SingleReg:$v0, (trunc_imm_32 imm:$i), splat32_at)>;

def isZeroExtended : PatLeaf<(i64 SingleReg:$src), [{
  return KVX_LOW::isExtended(N, CurDAG, false);
}]>;

def isSignExtended : PatLeaf<(i64 SingleReg:$src), [{
  return KVX_LOW::isExtended(N, CurDAG, true);
}]>;

// ADDUSBO
def : Pat<(v2i8(uaddsat v2i8:$v0, (is_imm_vec:$IMM))),
          (ADDUSBOri SingleReg:$v0, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(v2i8(uaddsat v2i8:$v0, v2i8:$v1)), (ADDUSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v4i8(uaddsat v4i8:$v0, (v4i8(is_imm_vec:$IMM)) ) ),
           (ADDUSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v4i8(uaddsat v4i8:$v0, v4i8:$v1)), (ADDUSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v8i8(uaddsat v8i8:$v0, (v8i8(is_imm_vec_kvx_splat32_:$IMM)) ) ),
           (ADDUSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v8i8(uaddsat v8i8:$v0, (v8i8(is_imm_vec_kvx_splat32_at:$IMM)) ) ),
           (ADDUSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>, Requires<[IsV2]>;
def : Pat<(v8i8(uaddsat v8i8:$v0, v8i8:$v1)), (ADDUSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

// ADDUSD
def : Pat<(i64(uaddsat i64:$v, Wrapped64W:$i)), (ADDUSDri SingleReg:$v, (i32(trunc_imm_32 $i)), splat32_)>;
def : Pat<(i64(uaddsat i64:$v, UnsignedSplat32Imm:$i)), (ADDUSDri SingleReg:$v, (i32(trunc_imm_32 $i)), splat32_at)>;
def : Pat<(i64(uaddsat i64:$v0, i64:$v1)), (ADDUSDrr SingleReg:$v0, SingleReg:$v1)>;

// ADDUSHQ
def : Pat<(v2i16(uaddsat v2i16:$v0, (v2i16(is_imm_vec:$IMM)) ) ),
           (ADDUSHQri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v2i16(uaddsat v2i16:$v0, v2i16:$v1)), (ADDUSHQrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v4i16(uaddsat v4i16:$v0, (v4i16(is_imm_vec_kvx_splat32_:$IMM)) ) ),
           (ADDUSHQri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v4i16(uaddsat v4i16:$v0, (v4i16(is_imm_vec_kvx_splat32_at:$IMM)) ) ),
           (ADDUSHQri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>, Requires<[IsV2]>;
def : Pat<(v4i16(uaddsat v4i16:$v0, v4i16:$v1)), (ADDUSHQrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

// ADDUSW
def : Pat<(i32(uaddsat i32:$v, Wrapped32:$i)), (ADDUSWri SingleReg:$v, Wrapped32:$i, splat32_)>;
def : Pat<(i32(uaddsat i32:$v0, i32:$v1)), (ADDUSWrr SingleReg:$v0, SingleReg:$v1)>;

// ADDUSWP
def : Pat<(v2i32(uaddsat v2i32:$v0, (v2i32(is_imm_vec_kvx_splat32_:$IMM)) ) ),
           (ADDUSWPri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v2i32(uaddsat v2i32:$v0, (v2i32(is_imm_vec_kvx_splat32_at:$IMM)) ) ),
           (ADDUSWPri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>, Requires<[IsV2]>;
def : Pat<(v2i32(uaddsat v2i32:$v0, v2i32:$v1)), (ADDUSWPrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

// ADDUWD
// TODO: Add ri variant
def : Pat<(i64(add i64:$v0, (zext i32:$v1))), (ADDUWDrr SingleReg:$v1, SingleReg:$v0)>;
def : Pat<(i64(add i64:$v0, isZeroExtended:$v1)), (ADDUWDrr SingleReg:$v1, SingleReg:$v0)>;

// ADDW
defm : ZEFPat<(add i32:$rs1, i32:$rs2), (ADDWrr SingleReg:$rs1, SingleReg:$rs2)>;
defm : ZEFPat<(add i32:$rs1, Signed10W:$rs2), (ADDWri10 SingleReg:$rs1, Signed10W:$rs2)>;
defm : ZEFPat<(add i32:$rs1, Signed37W:$rs2), (ADDWri37 SingleReg:$rs1, Signed37W:$rs2)>;

// ADDWD
// TODO: Add ri variant
def : Pat<(i64(add i64:$v0, (sext i32:$v1))), (ADDWDrr SingleReg:$v1, SingleReg:$v0)>;
def : Pat<(i64(add i64:$v0, isSignExtended:$v1)), (ADDWDrr SingleReg:$v1, SingleReg:$v0)>;

// ADDWP
def : Pat<(add v2i32:$r, (v2i32 (build_vector (i32 Wrapped32:$i), (i32 0)))), (ADDWPri SingleReg:$r, Wrapped32:$i, splat32_)>;
def : Pat<(add v2i32:$r, (v2i32 (v2_splat (i32 Wrapped32:$i)))), (ADDWPri SingleReg:$r, Wrapped32:$i, splat32_at)>;
def : Pat<(add v2i32:$rs1, v2i32:$rs2), (ADDWPrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sub v2i32:$rs1, (v2i32(is_imm_vec_kvx_splat32_:$IMM))), (ADDWPri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_)>;
def : Pat<(sub v2i32:$rs1, (v2i32(is_imm_vec_kvx_splat32_at:$IMM))), (ADDWPri SingleReg:$rs1, (build_imm_vec_neg $IMM), splat32_at)>;
// TODO: Add immediate sub-vector creation so we can
// add immediate variants to v4i32, e.g.
def : Pat<(v4i32 (add v4i32:$a1, v4i32:$a2)),
          (REG_SEQUENCE PairedReg,
            (v2i32(ADDWPrr (v2i32(EXTRACT_SUBREG PairedReg:$a1, sub_s0)),
                      (v2i32(EXTRACT_SUBREG PairedReg:$a2, sub_s0)))),
            sub_s0,
            (v2i32(ADDWPrr (v2i32(EXTRACT_SUBREG PairedReg:$a1, sub_s1)),
                      (v2i32(EXTRACT_SUBREG PairedReg:$a2, sub_s1)))),
            sub_s1)>;

// ADDX*
multiclass ADDXDPAT<dag sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(add i64:$r1, (shl i64:$r2, sc)), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(add (shl i64:$r2, sc), i64:$r1), (RRInstr SingleReg:$r2, SingleReg:$r1)>;

def : Pat<(add (shl i64:$r2, sc), Wrapped64W:$r1), (RIInstr SingleReg:$r2, (trunc_imm_32 imm:$r1), splat32_)>;
def : Pat<(add (shl i64:$r2, sc), SignedSplat32Imm:$r1), (RIInstr SingleReg:$r2, (trunc_imm_32 imm:$r1), splat32_at)>;
}
defm : ADDXDPAT<(i64 6), ADDX64Drr, ADDX64Dri>, Requires<[IsV2]>;
defm : ADDXDPAT<(i64 5), ADDX32Drr, ADDX32Dri>, Requires<[IsV2]>;
defm : ADDXDPAT<(i64 4), ADDX16Drr, ADDX16Dri>;
defm : ADDXDPAT<(i64 3), ADDX8Drr, ADDX8Dri>;
defm : ADDXDPAT<(i64 2), ADDX4Drr, ADDX4Dri>;
defm : ADDXDPAT<(i64 1), ADDX2Drr, ADDX2Dri>;

multiclass ADDXUWDPAT<dag sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(add i64:$r1, (i64 (zext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(add (i64 (zext (shl i32:$r2, sc))), i64:$r1), (RRInstr SingleReg:$r2, SingleReg:$r1)>;

def : Pat<(add (i64 (zext (shl i32:$r2, sc))), Wrapped64W:$r1), (RIInstr SingleReg:$r2, (trunc_imm_32 imm:$r1))>;
}
defm : ADDXUWDPAT<(i64 6), ADDX64UWDrr, ADDX64UWDri>, Requires<[IsV2]>;
defm : ADDXUWDPAT<(i64 5), ADDX32UWDrr, ADDX32UWDri>, Requires<[IsV2]>;
defm : ADDXUWDPAT<(i64 4), ADDX16UWDrr, ADDX16UWDri>;
defm : ADDXUWDPAT<(i64 3), ADDX8UWDrr, ADDX8UWDri>;
defm : ADDXUWDPAT<(i64 2), ADDX4UWDrr, ADDX4UWDri>;
defm : ADDXUWDPAT<(i64 1), ADDX2UWDrr, ADDX2UWDri>;

multiclass ADDXWPAT<dag sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
defm : ZEFPat<(add i32:$r1, (shl i32:$r2, sc)), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
defm : ZEFPat<(add (shl i32:$r2, sc), i32:$r1), (RRInstr SingleReg:$r2, SingleReg:$r1)>;

defm : ZEFPat<(add (shl i32:$r2, sc), Wrapped32:$r1), (RIInstr SingleReg:$r2, Wrapped32:$r1)>;
}
defm : ADDXWPAT<(i64 6), ADDX64Wrr, ADDX64Wri>, Requires<[IsV2]>;
defm : ADDXWPAT<(i64 5), ADDX32Wrr, ADDX32Wri>, Requires<[IsV2]>;
defm : ADDXWPAT<(i64 4), ADDX16Wrr, ADDX16Wri>;
defm : ADDXWPAT<(i64 3), ADDX8Wrr, ADDX8Wri>;
defm : ADDXWPAT<(i64 2), ADDX4Wrr, ADDX4Wri>;
defm : ADDXWPAT<(i64 1), ADDX2Wrr, ADDX2Wri>;

multiclass ADDXWDPAT<dag sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(add i64:$r1, (i64 (sext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(add (i64 (sext (shl i32:$r2, sc))), i64:$r1), (RRInstr SingleReg:$r2, SingleReg:$r1)>;

def : Pat<(add (i64 (sext (shl i32:$r2, sc))), Wrapped64W:$r1), (RIInstr SingleReg:$r2, (trunc_imm_32 imm:$r1))>;
}
defm : ADDXWDPAT<(i64 6), ADDX64WDrr, ADDX64WDri>, Requires<[IsV2]>;
defm : ADDXWDPAT<(i64 5), ADDX32WDrr, ADDX32WDri>, Requires<[IsV2]>;
defm : ADDXWDPAT<(i64 4), ADDX16WDrr, ADDX16WDri>;
defm : ADDXWDPAT<(i64 3), ADDX8WDrr, ADDX8WDri>;
defm : ADDXWDPAT<(i64 2), ADDX4WDrr, ADDX4WDri>;
defm : ADDXWDPAT<(i64 1), ADDX2WDrr, ADDX2WDri>;

multiclass ADDXPAT_HalfSReg<ValueType vt, dag sc, KVX_INSTRUCTION RR, KVX_INSTRUCTION RI, PatLeaf VC> {
def : Pat<(vt(add (shl vt:$v, (vt(v2_splat sc))), (vt(is_imm_vec:$IMM)))),
          (RI $v, (build_imm_vec $IMM), splat32_)>;
def : Pat<(vt(or (shl vt:$v, (vt(v2_splat sc))), (vt(VC:$IMM)))),
          (RI $v, (build_imm_vec $IMM), splat32_)>;
def : Pat<(vt(sub (shl vt:$v, (vt(v2_splat sc))), (vt(is_imm_vec:$IMM)))),
          (RI $v, (build_imm_vec_neg $IMM), splat32_)>;
def : Pat<(vt(add vt:$v0, (shl vt:$v1, (vt(v2_splat sc))))), (RR SingleReg:$v1, SingleReg:$v0)>;
}
foreach vt = [v2i8, v4i8] in {
defm : ADDXPAT_HalfSReg<vt, (i32 1), ADDX2BOrr,  ADDX2BOri,  is_imm_vec_leq1bit>, Requires<[IsV2]>;
defm : ADDXPAT_HalfSReg<vt, (i32 2), ADDX4BOrr,  ADDX4BOri,  is_imm_vec_leq2bits>, Requires<[IsV2]>;
defm : ADDXPAT_HalfSReg<vt, (i32 3), ADDX8BOrr,  ADDX8BOri,  is_imm_vec_leq3bits>, Requires<[IsV2]>;
defm : ADDXPAT_HalfSReg<vt, (i32 4), ADDX16BOrr, ADDX16BOri, is_imm_vec_leq4bits>, Requires<[IsV2]>;
}

defm : ADDXPAT_HalfSReg<v2i16, (i32 1), ADDX2HQrr,  ADDX2HQri,  is_imm_vec_leq1bit>;
defm : ADDXPAT_HalfSReg<v2i16, (i32 2), ADDX4HQrr,  ADDX4HQri,  is_imm_vec_leq2bits>;
defm : ADDXPAT_HalfSReg<v2i16, (i32 3), ADDX8HQrr,  ADDX8HQri,  is_imm_vec_leq3bits>;
defm : ADDXPAT_HalfSReg<v2i16, (i32 4), ADDX16HQrr, ADDX16HQri, is_imm_vec_leq4bits>;

multiclass VECADDXPAT<ValueType vt, dag sc, KVX_INSTRUCTION RR, KVX_INSTRUCTION RI, PatFrag v_splat, PatLeaf VC_, PatLeaf VC_at, PatLeaf VC_rr> {
def : Pat<(vt(add (shl vt:$v, (vt(v_splat sc))), (vt(is_imm_vec_kvx_splat32_:$IMM)))), (RI $v, (build_imm_vec $IMM), splat32_)>;
def : Pat<(vt(or (shl vt:$v, (vt(v_splat sc))), (vt(VC_:$IMM)))), (RI $v, (build_imm_vec $IMM), splat32_)>;
def : Pat<(vt(sub (shl vt:$v, (vt(v_splat sc))), (vt(is_imm_vec_kvx_splat32_:$IMM)))), (RI $v, (build_imm_vec_neg $IMM), splat32_)>;

def : Pat<(vt(add (shl vt:$v, (vt(v_splat sc))), (vt(is_imm_vec_kvx_splat32_at:$IMM)))), (RI $v, (build_imm_vec $IMM), splat32_at)>;
def : Pat<(vt(or (shl vt:$v, (vt(v_splat sc))), (vt(VC_at:$IMM)))), (RI $v, (build_imm_vec $IMM), splat32_at)>;
def : Pat<(vt(sub (shl vt:$v, (vt(v_splat sc))), (vt(is_imm_vec_kvx_splat32_at:$IMM)))), (RI $v, (build_imm_vec_neg $IMM), splat32_at)>;

def : Pat<(vt(add vt:$v0, (shl vt:$v1, (vt(v_splat sc))))), (RR SingleReg:$v1, SingleReg:$v0)>;
def : Pat<(vt(or (VC_rr:$IMM), (shl vt:$v, (vt(v_splat sc))))), (RR SingleReg:$v, $IMM)>;
}

defm : VECADDXPAT<v8i8, (i32 1), ADDX2BOrr,  ADDX2BOri,  v8_splat, imm_vec_1bit_splat_, imm_vec_1bit_splat_at, is_imm_vec_leq1bit>, Requires<[IsV2]>;
defm : VECADDXPAT<v8i8, (i32 2), ADDX4BOrr,  ADDX4BOri,  v8_splat, imm_vec_2bit_splat_, imm_vec_2bit_splat_at, is_imm_vec_leq2bits>, Requires<[IsV2]>;
defm : VECADDXPAT<v8i8, (i32 3), ADDX8BOrr,  ADDX8BOri,  v8_splat, imm_vec_3bit_splat_, imm_vec_3bit_splat_at, is_imm_vec_leq3bits>, Requires<[IsV2]>;
defm : VECADDXPAT<v8i8, (i32 4), ADDX16BOrr, ADDX16BOri, v8_splat, imm_vec_4bit_splat_, imm_vec_4bit_splat_at, is_imm_vec_leq4bits>, Requires<[IsV2]>;

defm : VECADDXPAT<v4i16, (i32 1), ADDX2HQrr,  ADDX2HQri,  v4_splat, imm_vec_1bit_splat_, imm_vec_1bit_splat_at, is_imm_vec_leq1bit>;
defm : VECADDXPAT<v4i16, (i32 2), ADDX4HQrr,  ADDX4HQri,  v4_splat, imm_vec_2bit_splat_, imm_vec_2bit_splat_at, is_imm_vec_leq2bits>;
defm : VECADDXPAT<v4i16, (i32 3), ADDX8HQrr,  ADDX8HQri,  v4_splat, imm_vec_3bit_splat_, imm_vec_3bit_splat_at, is_imm_vec_leq3bits>;
defm : VECADDXPAT<v4i16, (i32 4), ADDX16HQrr, ADDX16HQri, v4_splat, imm_vec_4bit_splat_, imm_vec_4bit_splat_at, is_imm_vec_leq4bits>;

defm : VECADDXPAT<v2i32, (i32 1), ADDX2WPrr,  ADDX2WPri,  v2_splat, imm_vec_1bit_splat_, imm_vec_1bit_splat_at, is_imm_vec_leq1bit>;
defm : VECADDXPAT<v2i32, (i32 2), ADDX4WPrr,  ADDX4WPri,  v2_splat, imm_vec_2bit_splat_, imm_vec_2bit_splat_at, is_imm_vec_leq2bits>;
defm : VECADDXPAT<v2i32, (i32 3), ADDX8WPrr,  ADDX8WPri,  v2_splat, imm_vec_3bit_splat_, imm_vec_3bit_splat_at, is_imm_vec_leq3bits>;
defm : VECADDXPAT<v2i32, (i32 4), ADDX16WPrr, ADDX16WPri, v2_splat, imm_vec_4bit_splat_, imm_vec_4bit_splat_at, is_imm_vec_leq4bits>;

// ANDD, CLRF
def : Pat<(and i64:$rs1, Signed10:$rs2), (ANDDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(and i64:$rs1, isNotShiftMask:$imm), (i64(CLRF SingleReg:$rs1, (notShiftMaskEnd $imm), (notShiftMaskStart $imm) ))>;
def : Pat<(and i64:$rs1, isShiftMask:$imm), (CLRF SingleReg:$rs1, (ShiftMaskStart $imm), (ShiftMaskEnd $imm) )>;
def : Pat<(and i64:$rs1, i64:$rs2), (ANDDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and i64:$rs1, Signed37:$rs2), (ANDDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(and i64:$rs1, Wrapped64:$rs2), (ANDDri64 SingleReg:$rs1, Wrapped64:$rs2)>;

foreach vtype = [ v8i8, v4i16, v2i32 ] in {
    def : Pat<(and vtype:$rs1, (vtype (is_imm_vec:$IMM))), (ANDDri64 SingleReg:$rs1, (build_imm_vec $IMM))>;
    def : Pat<(and vtype:$rs1, vtype:$rs2), (ANDDrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// ANDND
def : Pat<(and (not i64:$rs1), i64:$rs2), (ANDNDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(and (not i64:$rs1), Signed10:$rs2), (ANDNDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(and (not i64:$rs1), Signed37:$rs2), (ANDNDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(and (not i64:$rs1), Wrapped64:$rs2), (ANDNDri64 SingleReg:$rs1, Wrapped64:$rs2)>;

foreach vtype = [ v8i8, v4i16, v2i32 ] in {
    def : Pat<(and (vnot vtype:$rs1), (vtype (is_imm_vec:$IMM))), (ANDNDri64 SingleReg:$rs1, (build_imm_vec $IMM))>;
    def : Pat<(and (vnot vtype:$rs1), vtype:$rs2), (ANDNDrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// ANDNW
def : Pat<(i32(and (not i32:$rs1), i32:$rs2)), (ANDNWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(i32(and (not i32:$r), Signed37W:$i)), (ANDNWri37 SingleReg:$r, imm:$i)>;

foreach vtype = [ v2i8, v2i16, v4i8 ] in {
    def : Pat<(and (vnot vtype:$rs1), (vtype (is_imm_vec:$IMM))), (ANDNWri37 SingleReg:$rs1, (build_imm_vec $IMM))>;
    def : Pat<(and (vnot vtype:$rs1), vtype:$rs2), (ANDNWrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// ANDW
defm : ZEFPat<(and i32:$rs1, i32:$rs2), (ANDWrr SingleReg:$rs1, SingleReg:$rs2)>;
defm : ZEFPat<(and i32:$rs1, Signed10W:$rs2), (ANDWri10 SingleReg:$rs1, Signed10W:$rs2)>;
defm : ZEFPat<(and i32:$rs1, Signed37W:$rs2), (ANDWri37 SingleReg:$rs1, Signed37W:$rs2)>;

foreach vtype = [ v2i8, v4i8, v2i16 ] in {
    def : Pat<(and vtype:$rs1, (vtype (is_imm_vec:$IMM))), (ANDWri37 SingleReg:$rs1, (build_imm_vec $IMM))>;
    def : Pat<(and vtype:$rs1, vtype:$rs2), (ANDWrr SingleReg:$rs1, SingleReg:$rs2)>;
}

//                        VectorType,   vector_splat_1,  signed avg rr,      signed avg ri,      signed avgr rr
multiclass AVG_leq_32bits<ValueType vt, PatFrags splat_1, KVX_INSTRUCTION rr, KVX_INSTRUCTION ri, KVX_INSTRUCTION Rrr> {
def : Pat<(sra ( add vt:$v, (vt (is_imm_vec_ri37:$IMM))), (vt (splat_1))),
          (ri SingleReg:$v, (i32 (build_imm_vec $IMM) ), splat32_)>;

def : Pat<(sra ( add vt:$v0, vt:$v1 ), (vt (splat_1))),
          (rr SingleReg:$v1, SingleReg:$v0)>;

def : Pat<(sra ( add ( add vt:$v0, vt:$v1 ), (vt (splat_1)) ), (vt (splat_1))),
          (Rrr SingleReg:$v1, SingleReg:$v0)>;
}

//                        VectorType,   vector_splat_1,  signed avg rr,      signed avg ri,      signed avgr rr
multiclass AVG_64bits <ValueType vt, PatFrags splat_1, KVX_INSTRUCTION rr, KVX_INSTRUCTION ri, KVX_INSTRUCTION Rrr> {
def : Pat<(sra ( add vt:$v, (vt (is_imm_vec_kvx_splat32_:$IMM) ) ), (vt (splat_1))),
          (ri SingleReg:$v, (i32 (build_imm_vec $IMM)), splat32_)>;

def : Pat<(sra ( add vt:$v, (vt (is_imm_vec_kvx_splat32_at:$IMM) ) ), (vt (splat_1))),
          (ri SingleReg:$v, (i32 (build_imm_vec $IMM)), splat32_at)>;

def : Pat<(sra ( add vt:$v0, vt:$v1 ), (vt (splat_1))),
          (rr SingleReg:$v1, SingleReg:$v0)>;

def : Pat<(sra ( add ( add vt:$v0, vt:$v1 ), (vt (splat_1))), (vt (splat_1))),
          (Rrr SingleReg:$v1, SingleReg:$v0)>;
}

// AVGBO / AVGRBO
// v2i8
defm : AVG_leq_32bits <v2i8, v2_splat_1, AVGBOrr, AVGBOri, AVGRBOrr>, Requires<[IsV2]>;
// v4i8
defm : AVG_leq_32bits <v4i8, v4_splat_1, AVGBOrr, AVGBOri, AVGRBOrr>, Requires<[IsV2]>;
// v8i8
defm : AVG_64bits <v8i8, v8_splat_1, AVGBOrr, AVGBOri, AVGRBOrr>, Requires<[IsV2]>;

// AVGHQ / AVGRHQ
// v2i16
defm : AVG_leq_32bits<v2i16, v2_splat_1, AVGHQrr, AVGHQri, AVGRHQrr>;
// v4i16
defm : AVG_64bits<v4i16, v4_splat_1, AVGHQrr, AVGHQri, AVGRHQrr>;

//                        VectorType,   vector_splat_1,  unsigned avg rr,     unsigned avg ri,    unsigned avgr rr
multiclass AVGU_leq_32bits<ValueType vt, PatFrags splat_1, KVX_INSTRUCTION rr, KVX_INSTRUCTION ri, KVX_INSTRUCTION Rrr> {
def : Pat<(srl ( nuwadd vt:$v, (vt (is_imm_vec_ri37:$IMM) ) ), (vt (splat_1))),
          (ri SingleReg:$v, (build_imm_vec $IMM), splat32_)>;

def : Pat<(srl ( nuwadd vt:$v0, vt:$v1 ), (vt (splat_1))),
          (rr SingleReg:$v1, SingleReg:$v0)>;

def : Pat<(srl ( nuwadd ( nuwadd vt:$v0, vt:$v1 ), (vt (splat_1)) ), (vt (splat_1))),
          (Rrr SingleReg:$v1, SingleReg:$v0)>;
}

multiclass AVGU_64bits <ValueType vt, PatFrags splat_1, KVX_INSTRUCTION rr, KVX_INSTRUCTION ri, KVX_INSTRUCTION Rrr> {
def : Pat<(srl ( nuwadd vt:$v, (vt (is_imm_vec_kvx_splat32_:$IMM) ) ),
          (vt (splat_1))), (ri SingleReg:$v, (i32 (build_imm_vec $IMM)), splat32_)>;

def : Pat<(srl ( nuwadd vt:$v, (vt (is_imm_vec_kvx_splat32_at:$IMM) ) ),
          (vt (splat_1))), (ri SingleReg:$v, (i32 (build_imm_vec $IMM)), splat32_at)>;

def : Pat<(srl ( nuwadd vt:$v0, vt:$v1 ), (vt (splat_1))),
          (rr SingleReg:$v1, SingleReg:$v0)>;

def : Pat<(srl ( nuwadd ( nuwadd vt:$v0, vt:$v1 ), (vt (splat_1))), (vt (splat_1))),
          (Rrr SingleReg:$v1, SingleReg:$v0)>;
}

// AVGUBO / AVGRUBO
// v2i8
defm : AVGU_leq_32bits<v2i8, v2_splat_1, AVGUBOrr, AVGUBOri, AVGRUBOrr>, Requires<[IsV2]>;
// v4i8
defm : AVGU_leq_32bits<v4i8, v4_splat_1, AVGUBOrr, AVGUBOri, AVGRUBOrr>, Requires<[IsV2]>;
// v8i8
defm : AVGU_64bits<v8i8, v8_splat_1, AVGUBOrr, AVGUBOri, AVGRUBOrr>, Requires<[IsV2]>;

// AVGUHQ / AVGRUHQ
// v2i16
defm : AVGU_leq_32bits<v2i16, v2_splat_1, AVGUHQrr, AVGUHQri, AVGRUHQrr>;
// v4i16
defm : AVGU_64bits<v4i16, v4_splat_1, AVGUHQrr, AVGUHQri, AVGRUHQrr>;

// AVGUW / AVGRUW
def : Pat<(srl  (nuwadd i32:$v0, Wrapped32:$v1), (i64 1)), (AVGUWri SingleReg:$v0, Wrapped32:$v1)>;
def : Pat<(srl  (nuwadd i32:$v0, i32:$v1),       (i64 1)), (AVGUWrr SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(i32(trunc(i64(srl (add (zext i32:$v0), Unsigned64W:$v1), (i64 1))))), (AVGUWri SingleReg:$v0, (trunc_imm_32 $v1))>;
def : Pat<(i32(trunc(i64(srl (add (zext i32:$v0), (zext i32:$v1)), (i64 1))))), (AVGUWrr SingleReg:$v0, SingleReg:$v1)>;

def : Pat<(srl (nuwadd (nuwadd i32:$v0, i32:$v1),  (i32 1)), (i32 1)), (AVGRUWrr SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(i32 (trunc(i64(srl  (add (add (zext i32:$v0), (zext i32:$v1)), (i64 1)), (i64 1))))), (AVGRUWrr SingleReg:$v0, SingleReg:$v1)>;

// AVGUWP / AVGRUWP
def : Pat<(srl ( nuwadd v2i32:$v, (v2i32 (build_vector (Wrapped32:$i), (i32 0))) ), (v2i32 (v2_splat_1) ) ), (AVGUWPri SingleReg:$v, (i32 (trunc_imm_32 imm:$i)), splat32_)>;
def : Pat<(srl ( nuwadd v2i32:$v, (v2i32 (build_vector (Wrapped32:$i), (Wrapped32:$i))) ), (v2i32 (v2_splat_1) ) ), (AVGUWPri SingleReg:$v, (i32 (trunc_imm_32 imm:$i)), splat32_at)>;
def : Pat<(srl ( nuwadd v2i32:$v, (v2i32 (build_vector (i32 Unsigned32PlusOne:$i), (i32 1)))), (v2i32 (v2_splat_1))), (AVGRWPri SingleReg:$v, (imm32u_sub_1(imm:$i)), splat32_ )>;

def : Pat<(srl ( nuwadd v2i32:$v0, v2i32:$v1 ), (v2i32 (v2_splat_1) ) ), (AVGUWPrr SingleReg:$v1, SingleReg:$v0)>;

def : Pat<(srl ( nuwadd ( nuwadd v2i32:$v0, v2i32:$v1 ), (v2i32 (v2_splat_1))), (v2i32 (v2_splat_1)) ), (AVGRUWPrr SingleReg:$v1, SingleReg:$v0)>;

// AVGW / AVGRW
def : Pat<(sra  (add i32:$v0, Wrapped32:$v1), (i64 1)), (AVGWri SingleReg:$v0, Wrapped32:$v1)>;
def : Pat<(sra  (add i32:$v0, i32:$v1),       (i64 1)), (AVGWrr SingleReg:$v0, SingleReg:$v1)>;

def : Pat<(srl  (nswadd i32:$v0, Wrapped32:$v1), (i64 1)), (AVGWri SingleReg:$v0, Wrapped32:$v1)>;
def : Pat<(srl  (nswadd i32:$v0, i32:$v1),       (i64 1)), (AVGWrr SingleReg:$v0, SingleReg:$v1)>;

def : Pat<(sra  (add (add i32:$v0, i32:$v1),  (i32 1)), (i64 1)), (AVGRWrr SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(srl  (nswadd (nswadd i32:$v0, i32:$v1),  (i32 1)), (i64 1)), (AVGRWrr SingleReg:$v0, SingleReg:$v1)>;

// AVGWP / AVGRWP
def : Pat<(sra ( add v2i32:$v, (build_vector Wrapped32:$i, (i32 0) )), (v2i32 (v2_splat_1))),
          (AVGWPri SingleReg:$v, imm:$i, splat32_)>;
def : Pat<(sra ( add v2i32:$v, (build_vector Wrapped32:$i, Wrapped32:$i )), (v2i32 (v2_splat_1))),
          (AVGWPri SingleReg:$v, Wrapped32:$i, splat32_at)>;
def : Pat<(sra ( add v2i32:$v0, v2i32:$v1 ), (v2i32 (v2_splat_1)) ),
          (AVGWPrr SingleReg:$v1, SingleReg:$v0)>;

def : Pat<(sra ( add v2i32:$v, (v2i32(build_vector (i32 Wrapped32PlusOne:$i), (i32 1)))), (v2i32 (v2_splat_1) )),
          (AVGRWPri SingleReg:$v, (imm32s_sub_1(imm:$i)), splat32_ )>;
def : Pat<(sra (add ( add v2i32:$v0, v2i32:$v1 ), (v2i32 (v2_splat_1) ) ), (v2i32 (v2_splat_1)) ),
          (AVGRWPrr SingleReg:$v1, SingleReg:$v0)>;
def : Pat<(sra (add ( add v2i32:$v0, v2i32:$v1 ), (v2i32 (v2_splat_1)) ), (v2i32 (v2_splat_1)) ),
          (AVGRWPrr SingleReg:$v1, SingleReg:$v0)>;

// CBSWP
def : Pat<(v4i32(ctpop v4i32:$v0)),
          (REG_SEQUENCE PairedReg,
            (CBSWP(v2i32(EXTRACT_SUBREG PairedReg:$v0, sub_s0))),
            sub_s0,
            (CBSWP(v2i32(EXTRACT_SUBREG PairedReg:$v0, sub_s1))),
            sub_s1)>;


multiclass SELECT_COMP_PAT<PatFrag Comp, Comparison Mod, KVX_INSTRUCTION COMPrr, KVX_INSTRUCTION COMPri, ValueType SelectVT, ValueType CompareVT, KVX_INSTRUCTION NEG, Operand RIOp> {
  def : Pat<(SelectVT (select (i32 (Comp CompareVT:$r, RIOp:$imm)), (SelectVT -1), (SelectVT 0))),
        (NEG (COMPri SingleReg:$r, RIOp:$imm, Mod))>;

  def : Pat<(SelectVT (select (i32 (Comp CompareVT:$lhs, CompareVT:$rhs)), (SelectVT -1), (SelectVT 0))),
        (NEG (COMPrr SingleReg:$lhs, SingleReg:$rhs, Mod))>;
}

multiclass COMP_Pat<PatFrag Node, Comparison Mod, Comparison RevMod> {
  // COMPD
  def : Pat<(i32 (Node i64:$lhs, i64:$rhs)),
        (COMPDrr SingleReg:$lhs, SingleReg:$rhs, Mod)>;
  def : Pat<(i32 (Node i64:$lhs, Signed10:$rhs)),
        (COMPDri10 SingleReg:$lhs, Signed10:$rhs, Mod)>;
  def : Pat<(i32 (Node i64:$lhs, Signed37:$rhs)),
        (COMPDri37 SingleReg:$lhs, Signed37:$rhs, Mod)>;
  def : Pat<(i32 (Node i64:$lhs, Wrapped64:$rhs)),
        (COMPDri64 SingleReg:$lhs, Wrapped64:$rhs, Mod)>;

  //COMPNBO
  def : Pat<(v2i8 (Node v2i8:$lhs, v2i8:$rhs)),
        (COMPNBO SingleReg:$lhs, SingleReg:$rhs, Mod)>, Requires<[IsV2]>;
  def : Pat<(sra (shl (v2i8 (Node v2i8:$lhs, v2i8:$rhs)), (v2i8 v2_splat_7)), (v2i8 v2_splat_7)),
        (COMPNBO SingleReg:$lhs, SingleReg:$rhs, Mod)>, Requires<[IsV2]>;

  def : Pat<(v4i8 (Node v4i8:$lhs, v4i8:$rhs)),
        (COMPNBO SingleReg:$lhs, SingleReg:$rhs, Mod)>, Requires<[IsV2]>;
  def : Pat<(sra (shl (v4i8 (Node v4i8:$lhs, v4i8:$rhs)), (v4i8 v4_splat_7)), (v4i8 v4_splat_7)),
        (COMPNBO SingleReg:$lhs, SingleReg:$rhs, Mod)>, Requires<[IsV2]>;

  def : Pat<(v8i8 (Node v8i8:$lhs, v8i8:$rhs)),
        (COMPNBO SingleReg:$lhs, SingleReg:$rhs, Mod)>, Requires<[IsV2]>;
  def : Pat<(sra (shl (v8i8 (Node v8i8:$lhs, v8i8:$rhs)), (v8i8 v8_splat_7)), (v8i8 v8_splat_7)),
        (COMPNBO SingleReg:$lhs, SingleReg:$rhs, Mod)>, Requires<[IsV2]>;

//COMPNHQ
  def : Pat<(v4i16 (Node v4i16:$lhs, v4i16:$rhs)),
        (COMPNHQ SingleReg:$lhs, SingleReg:$rhs, Mod)>;
  def : Pat<(sra (shl (v4i16 (Node v4i16:$lhs, v4i16:$rhs)), (v4i16 v4_splat_15)), (v4i16 v4_splat_15)),
        (COMPNHQ SingleReg:$lhs, SingleReg:$rhs, Mod)>;

  def : Pat<(v2i16 (Node v2i16:$lhs, v2i16:$rhs)),
        (COMPNHQ SingleReg:$lhs, SingleReg:$rhs, Mod)>;
  def : Pat<(sra (shl (v2i16 (Node v2i16:$lhs, v2i16:$rhs)), (v2i16 v2_splat_15)), (v2i16 v2_splat_15)),
        (COMPNHQ SingleReg:$lhs, SingleReg:$rhs, Mod)>;

  //COMPNWP
  def : Pat<(v2i32 (Node v2i32:$lhs, v2i32:$rhs)),
        (COMPNWP SingleReg:$lhs, SingleReg:$rhs, Mod)>;
  def : Pat<(sra (shl (v2i32 (Node v2i32:$lhs, v2i32:$rhs)), (v2i32 v2_splat_31)), (v2i32 v2_splat_31)),
        (COMPNWP SingleReg:$lhs, SingleReg:$rhs, Mod)>;
  def : Pat<(v4i32 (Node v4i32:$lhs, v4i32:$rhs)),
        (v4i32 (REG_SEQUENCE PairedReg,
            (v2i32 ( COMPNWP (v2i32 (EXTRACT_SUBREG PairedReg:$lhs, sub_s0)),
                            (v2i32 (EXTRACT_SUBREG PairedReg:$rhs, sub_s0)),
                   Mod)),
            sub_s0,
            (v2i32 (COMPNWP (v2i32 (EXTRACT_SUBREG PairedReg:$lhs, sub_s1)),
                            (v2i32 (EXTRACT_SUBREG PairedReg:$rhs, sub_s1)),
                   Mod)),
            sub_s1))>;

  // COMPUWD
  def : Pat<(i32 (Node (i64(zext i32:$lhs)), i64:$rhs)),
        (COMPUWD SingleReg:$lhs, SingleReg:$rhs, Mod)>;

  def : Pat<(i32 (Node i64:$lhs, (i64(zext i32:$rhs)))),
        (COMPUWD SingleReg:$rhs, SingleReg:$lhs, RevMod)>;

  // COMPW
  def : Pat<(i32 (Node i32:$lhs, i32:$rhs)),
        (COMPWrr SingleReg:$lhs, SingleReg:$rhs, Mod)>;
  def : Pat<(i32 (Node i32:$lhs, Wrapped32:$rhs)),
        (COMPWri SingleReg:$lhs, Wrapped32:$rhs, Mod)>;
  def : Pat<(i32 (Node (i64(zext i32:$lhs)), Unsigned64W:$rhs)),
        (COMPWri SingleReg:$lhs, (trunc_imm_32 imm:$rhs), Mod)>;
  def : Pat<(i32 (Node (i64(sext i32:$lhs)), Wrapped64W:$rhs)),
        (COMPWri SingleReg:$lhs, (trunc_imm_32 imm:$rhs), Mod)>;

  // COMPWD
  def : Pat<(i32 (Node (i64(sext i32:$lhs)), i64:$rhs)),
        (COMPWD SingleReg:$lhs, SingleReg:$rhs, Mod)>;

  def : Pat<(i32 (Node i64:$lhs, (i64(sext i32:$rhs)))),
        (COMPWD SingleReg:$rhs, SingleReg:$lhs, RevMod)>;

  // COMPND
  def : Pat<(i64 (select (i32 (Node i64:$lhs, Wrapped64W:$rhs)), (i64 -1), (i64 0))),
        (COMPNDri SingleReg:$lhs, (trunc_imm_32 imm:$rhs), Mod)>, Requires<[IsV2]>;
  def : Pat<(i64 (select (i32 (Node i64:$lhs, i64:$rhs)), (i64 -1), (i64 0))),
        (COMPNDrr SingleReg:$lhs, SingleReg:$rhs, Mod)>, Requires<[IsV2]>;

  // COMPNW
  def : Pat<(i32 (select (i32 (Node i32:$lhs, i32:$rhs)), (i32 -1), (i32 0))),
        (COMPNWrr SingleReg:$lhs, SingleReg:$rhs, Mod)>, Requires<[IsV2]>;
  def : Pat<(i32 (select (i32 (Node i32:$lhs, Wrapped32:$rhs)), (i32 -1), (i32 0))),
        (COMPNWri SingleReg:$lhs, Wrapped32:$rhs, Mod)>, Requires<[IsV2]>;
  def : Pat<(i32 (select (i32 (Node (i64(zext i32:$lhs)), Unsigned64W:$rhs)), (i32 -1), (i32 0))),
        (COMPNWri SingleReg:$lhs, (trunc_imm_32 imm:$rhs), Mod)>, Requires<[IsV2]>;
  def : Pat<(i32 (select (i32 (Node (i64(sext i32:$lhs)), Wrapped64W:$rhs)), (i32 -1), (i32 0))),
        (COMPNWri SingleReg:$lhs, (trunc_imm_32 imm:$rhs), Mod)>, Requires<[IsV2]>;

  defm : SELECT_COMP_PAT<Node, Mod, COMPWrr, COMPWri, i32, i32, NEGW, Wrapped32>;
  // COMPW + NEGW
  def : Pat<(i32 (select (i64 (Node (i64(zext i32:$lhs)), Unsigned64W:$rhs)), (i32 -1), (i32 0))),
        (NEGW (COMPWri SingleReg:$lhs, (trunc_imm_32 imm:$rhs), Mod))>;
  def : Pat<(i32 (select (i64 (Node (i64(sext i32:$lhs)), Wrapped64W:$rhs)), (i32 -1), (i32 0))),
        (NEGW (COMPWri SingleReg:$lhs, (trunc_imm_32 imm:$rhs), Mod))>;

  // COMPW + NEGD
  defm : SELECT_COMP_PAT<Node, Mod, COMPWrr, COMPWri, i64, i32, NEGD, Wrapped32>;

  // COMPD + NEGD
  defm : SELECT_COMP_PAT<Node, Mod, COMPDrr, COMPDri10, i64, i64, NEGD, Signed10>, Requires<[IsV1]>;
  defm : SELECT_COMP_PAT<Node, Mod, COMPDrr, COMPDri37, i64, i64, NEGD, Signed37>, Requires<[IsV1]>;
  defm : SELECT_COMP_PAT<Node, Mod, COMPDrr, COMPDri64, i64, i64, NEGD, Wrapped64>, Requires<[IsV1]>;

  // COMPD + NEGW
  defm : SELECT_COMP_PAT<Node, Mod, COMPDrr, COMPDri10, i32, i64, NEGW, Signed10>, Requires<[IsV1]>;
  defm : SELECT_COMP_PAT<Node, Mod, COMPDrr, COMPDri37, i32, i64, NEGW, Signed37>, Requires<[IsV1]>;
  defm : SELECT_COMP_PAT<Node, Mod, COMPDrr, COMPDri64, i32, i64, NEGW, Wrapped64>, Requires<[IsV1]>;
}

defm : COMP_Pat<seteq,   comparison_eq, comparison_eq>;
defm : COMP_Pat<setne,   comparison_ne, comparison_ne>;
defm : COMP_Pat<setugt,  comparison_gtu, comparison_ltu>;
defm : COMP_Pat<setuge,  comparison_geu, comparison_leu>;
defm : COMP_Pat<setult,  comparison_ltu, comparison_gtu>;
defm : COMP_Pat<setule,  comparison_leu, comparison_geu>;
defm : COMP_Pat<setgt,   comparison_gt, comparison_lt>;
defm : COMP_Pat<setge,   comparison_ge, comparison_le>;
defm : COMP_Pat<setlt,   comparison_lt, comparison_gt>;
defm : COMP_Pat<setle,   comparison_le, comparison_ge>;

// TODO: add ri variants
multiclass DOT2_RR_SingleReg<SDNode ExtMul, KVX_INSTRUCTION RR> {
def : Pat<(i64 (add ( ExtMul
                        (i32 (vector_extract v2i32:$lhs, 0)),
                        (i32 (vector_extract v2i32:$rhs, 0))
                    ),
                    ( ExtMul
                    (i32 (vector_extract v2i32:$lhs, 1)),
                    (i32 (vector_extract v2i32:$rhs, 1))
                    ))),
           (i64 (RR SingleReg:$lhs, SingleReg:$rhs))>;

def : Pat<(i64 (add ( ExtMul
                        (i32 (trunc (i64 SingleReg:$lhs))),
                        (i32 (trunc (i64 SingleReg:$rhs)))
                    ),
                    ( ExtMul
                    (i32 (trunc (i64 (srl (i64 SingleReg:$lhs), (i64 32))))),
                    (i32 (trunc (i64 (srl (i64 SingleReg:$rhs), (i64 32)))))
                    ))),
           (i64 (RR SingleReg:$lhs, SingleReg:$rhs))>;

def : Pat<(i64 (add ( ExtMul
                        (i32 (vector_extract v2i32:$lhs, 0)),
                        (i32 (trunc (i64 SingleReg:$rhs)))
                    ),
                    ( ExtMul
                    (i32 (vector_extract v2i32:$lhs, 1)),
                    (i32 (trunc (i64 (srl (i64 SingleReg:$rhs), (i64 32)))))
                    ))),
           (i64 (RR SingleReg:$lhs, SingleReg:$rhs))>;

def : Pat<(i64 (add ( ExtMul
                        (i32 (trunc (i64 SingleReg:$lhs))),
                        (i32 (vector_extract v2i32:$rhs, 0))
                    ),
                    ( ExtMul
                    (i32 (trunc (i64 (srl (i64 SingleReg:$lhs), (i64 32))))),
                    (i32 (vector_extract v2i32:$rhs, 1))
                    ))),
           (i64 (RR SingleReg:$lhs, SingleReg:$rhs))>;
}
// DOT2SUWD
defm : DOT2_RR_SingleReg<KVX_szext_mul, DOT2SUWDrr>;

// DOT2UWD
defm : DOT2_RR_SingleReg<KVX_zext_mul, DOT2UWDrr>;

// DOT2W
// TODO: add ri37 variation
def : Pat<(i32 (add (i32 (vector_extract (v2i32 (mul v2i32:$lhs, (is_imm_vec:$rhs))), (i64 0))),
                    (i32 (vector_extract (v2i32 (mul v2i32:$lhs, (is_imm_vec:$rhs))), (i64 1))))),
          (i32 (DOT2Wri64 SingleReg:$lhs, (build_imm_vec $rhs)))>, Requires<[IsV1]>;

def : Pat<(i32 (add (i32 (vector_extract (v2i32 (mul v2i32:$lhs, v2i32:$rhs)), (i64 0))),
                    (i32 (vector_extract (v2i32 (mul v2i32:$lhs, v2i32:$rhs)), (i64 1))))),
          (i32 (DOT2Wrr SingleReg:$lhs, SingleReg:$rhs))>;

def : Pat<(i32 (add (i32 (mul (i32 (trunc (i64 (srl i64:$lhs, (i64 32))))), (i32 (trunc (i64 (srl i64:$rhs, (i64 32))))))),
                    (i32 (mul (i32 (trunc i64:$lhs)), (i32 (trunc i64:$rhs)))))),
          (i32 (DOT2Wrr SingleReg:$lhs, SingleReg:$rhs))>;

def : Pat<(i32 (add (i32 (mul (i32 (vector_extract v2i32:$lhs, (i64 1))), (i32 (trunc (i64 (srl i64:$rhs, (i64 32))))))),
                    (i32 (mul (i32 (vector_extract v2i32:$lhs, (i64 0))), (i32 (trunc i64:$rhs)))))),
          (i32 (DOT2Wrr SingleReg:$lhs, SingleReg:$rhs))>;

// DOT2WD
defm : DOT2_RR_SingleReg<KVX_sext_mul, DOT2WDrr>;

// DOT2WZP
def dotMulFrag : PatFrag<(ops node:$lhs, node:$rhs, node:$idx), (extractelt (mul node:$rhs, node:$lhs), node:$idx)>;
def : Pat<(v2i64 (zext (v2i32 (build_vector
                              (i32 (add
                                    (dotMulFrag v4i32:$lhs, v4i32:$rhs, (i64 0)),
                                    (dotMulFrag v4i32:$lhs, v4i32:$rhs, (i64 1))
                              )),
                              (i32 (add
                                    (dotMulFrag v4i32:$lhs, v4i32:$rhs, (i64 2)),
                                    (dotMulFrag v4i32:$lhs, v4i32:$rhs, (i64 3))
         )))))),
         (v2i64 (DOT2WZP PairedReg:$lhs, PairedReg:$rhs))>;
// EXTF
def : Pat<(and (srl i64:$v, Wrapped64:$shiftc), isMask:$andm), (EXTFZDp SingleReg:$v, Wrapped64:$andm, Wrapped64:$shiftc)>;

// LANDD
defm : ZEFPat<(and (i32 (setne i64:$v1, (i64 0))), (i32 (setne i64:$v2, (i64 0)))),
      (LANDDrr SingleReg:$v1, SingleReg:$v2)>;

multiclass PAT_LNAND_VEC<ValueType vt, PatFrags zext, PatFrags splat, KVX_INSTRUCTION LNAND, KVX_INSTRUCTION NEG> {
def : Pat<(vt (zext (seteq vt:$rhs, immAllZerosV), (seteq vt:$lhs, immAllZerosV))),
          (vt (LNAND SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV1]>;

def : Pat<(vt (sra (shl ( or (seteq vt:$rhs, immAllZerosV), (seteq vt:$lhs, immAllZerosV)), (vt splat)), (vt splat))),
          (vt (NEG (LNAND SingleReg:$rhs, SingleReg:$lhs)))>, Requires<[IsV1]>;
}

// RI variants don't seem usuable, as they turn into vselects.
multiclass VECLANDPAT<ValueType ty, KVX_INSTRUCTION RR, KVX_INSTRUCTION NEG, dag SplatVal> {
def : Pat<(ty(and (setne ty:$v0, immAllZerosV), (setne ty:$v1, immAllZerosV))),
            (RR SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV1]>;

def : Pat<(ty(sra( shl
                  ( and (setne ty:$v0, immAllZerosV), (setne ty:$v1, immAllZerosV)),
            SplatVal),SplatVal)), (NEG(RR SingleReg:$v0, SingleReg:$v1))>, Requires<[IsV1]>;
}

// LANDHQ
defm : VECLANDPAT<v2i16, LANDHQrr, NEGHQ, (v2i16 v2_splat_15)>;
defm : VECLANDPAT<v4i16, LANDHQrr, NEGHQ, (v4i16 v4_splat_15)>;

// LANDW
defm : ZEFPat<(and (i32 (setne i32:$v1, (i32 0))), (i32 (setne i32:$v2, (i32 0)))),
      (LANDWrr SingleReg:$v1, SingleReg:$v2)>;


// LANDWP
defm : VECLANDPAT<v2i32, LANDWPrr, NEGWP, (v2i32 v2_splat_31)>;

// LNANDD
defm : ZEFPat<(or (i32 (seteq i64:$v1, (i64 0))), (i32 (seteq i64:$v2, (i64 0)))),
      (LNANDDrr SingleReg:$v1, SingleReg:$v2)>;

multiclass PAT_LOR_VEC<ValueType vt, PatFrags and_splat, PatFrags splat, KVX_INSTRUCTION LOR, KVX_INSTRUCTION NEG, PatFrag cmp> {
def : Pat<(vt (and (cmp (or vt:$lhs, vt:$rhs), immAllZerosV), and_splat)),
          (vt (LOR SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV1]>;

def : Pat<(vt (cmp (or vt:$lhs, vt:$rhs), immAllZerosV)),
          (vt (LOR SingleReg:$rhs, SingleReg:$lhs))>, Requires<[IsV1]>;

def : Pat<(vt (sra (shl ( cmp (or vt:$lhs, vt:$rhs), immAllZerosV), (vt splat)), (vt splat))),
          (vt (NEG (LOR SingleReg:$rhs, SingleReg:$lhs)))>, Requires<[IsV1]>;
}

// LNANDHQ
defm : PAT_LNAND_VEC<v2i16, ZEXT_VEC2_SETCC_Pat, v2_splat_15, LNANDHQrr, NEGHQ>;
defm : PAT_LNAND_VEC<v4i16, ZEXT_VEC4_SETCC_Pat, v4_splat_15, LNANDHQrr, NEGHQ>;

// LNANDW
defm : ZEFPat<(or (i32 (seteq i32:$v1, (i32 0))), (i32 (seteq i32:$v2, (i32 0)))),
      (LNANDWrr SingleReg:$v1, SingleReg:$v2)>;

// LNANDWP
defm : PAT_LNAND_VEC<v2i32, ZEXT_VEC2_SETCC_Pat, v2_splat_31, LNANDWPrr, NEGWP>;

// LNORD
def : Pat<(i32 (seteq (or i64:$v1, i64:$v2), (i64 0))), (LNORDrr SingleReg:$v1, SingleReg:$v2)>;

// LNORHQ
defm : PAT_LOR_VEC<v2i16, v2_splat_1, v2_splat_15, LNORHQrr, NEGHQ, seteq>;
defm : PAT_LOR_VEC<v4i16, v4_splat_1, v4_splat_15, LNORHQrr, NEGHQ, seteq>;

// LNORW
def : Pat<(i32 (seteq (or i32:$v1, i32:$v2), (i32 0))), (LNORWrr SingleReg:$v1, SingleReg:$v2)>;

// LNORWP
defm : PAT_LOR_VEC<v2i32, v2_splat_1, v2_splat_31, LNORWPrr, NEGWP, seteq>;

// LORD
def : Pat<(i32 (setne (or i64:$v1, i64:$v2), (i64 0))),
      (LORDrr SingleReg:$v1, SingleReg:$v2)>;

// LORHQ
defm : PAT_LOR_VEC<v2i16, v2_splat_1, v2_splat_15, LORHQrr, NEGHQ, setne>;
defm : PAT_LOR_VEC<v4i16, v4_splat_1, v4_splat_15, LORHQrr, NEGHQ, setne>;

// LORW
def : Pat<(i32 (setne (or i32:$v1, i32:$v2), (i32 0))),
      (LORWrr SingleReg:$v1, SingleReg:$v2)>;

// LORWP
defm : PAT_LOR_VEC<v2i32, v2_splat_1, v2_splat_31, LORWPrr, NEGWP, setne>;

// MADDD
def : Pat<(add i64:$a1, (mul i64:$a2, i64:$a3)), (MADDDrr SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;
def : Pat<(add i64:$a1, (mul i64:$a2, Wrapped64:$a3)), (MADDDri64 SingleReg:$a1, SingleReg:$a2, Wrapped64:$a3)>, Requires<[IsV1]>;
def : Pat<(add i64:$a1, (mul i64:$a2, Signed10:$a3)), (MADDDri10 SingleReg:$a1, SingleReg:$a2, Wrapped64:$a3)>, Requires<[IsV1]>;
def : Pat<(add i64:$a1, (mul i64:$a2, Signed37:$a3)), (MADDDri37 SingleReg:$a1, SingleReg:$a2, Wrapped64:$a3)>, Requires<[IsV1]>;

// MADDHQ
def : Pat<(add v2i16:$a1, (mul v2i16:$a2, (v2i16(is_imm_vec:$IMM)))), (MADDHQri37 SingleReg:$a1, SingleReg:$a2, (build_imm_vec $IMM))>, Requires<[IsV1]>;
def : Pat<(add v2i16:$a1, (mul v2i16:$a2, v2i16:$a3)), (MADDHQrr SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;
def : Pat<(add v4i16:$a1, (mul v4i16:$a2, (v4i16(is_imm_vec:$IMM)))), (MADDHQri64 SingleReg:$a1, SingleReg:$a2, (build_imm_vec $IMM))>, Requires<[IsV1]>;
def : Pat<(add v4i16:$a1, (mul v4i16:$a2, v4i16:$a3)), (MADDHQrr SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;

// MADDHWQ
def : Pat<(v2i32(add (v2i32(KVX_sext_mul v2i16:$v0, v2i16:$v1)), v2i32:$v2)),
          (v2i32 (EXTRACT_SUBREG (v4i32
                  (MADDHWQ (INSERT_SUBREG (v4i32 (IMPLICIT_DEF)), SingleReg:$v2, sub_s0), SingleReg:$v0, SingleReg:$v1)),
            sub_s0))>;

def : Pat<(v4i32(add (v4i32(KVX_sext_mul v4i16:$v0, v4i16:$v1)), v4i32:$v2)),
          (v4i32(MADDHWQ PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDSUHWQ
def : Pat<(v2i32(add (v2i32(KVX_szext_mul v2i16:$v0, v2i16:$v1)), v2i32:$v2)),
          (v2i32 (EXTRACT_SUBREG (v4i32
                  (MADDSUHWQ (INSERT_SUBREG (v4i32 (IMPLICIT_DEF)), SingleReg:$v2, sub_s0), SingleReg:$v0, SingleReg:$v1)),
            sub_s0))>;

def : Pat<(v4i32(add (v4i32(KVX_szext_mul v4i16:$v0, v4i16:$v1)), v4i32:$v2)),
          (v4i32(MADDSUHWQ PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDSUWD
def : Pat<(i64(add (i64(KVX_szext_mul i32:$v0, Wrapped32:$v1)), i64:$v2)),
            (i64(MADDSUWDri SingleReg:$v2, SingleReg:$v0, Wrapped32:$v1))>;

def : Pat<(i64(add (i64(KVX_szext_mul i32:$v0, i32:$v1)), i64:$v2)),
            (i64(MADDSUWDrr SingleReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDSUWDP
def : Pat<(v2i64(add (v2i64(KVX_szext_mul v2i32:$v0, v2i32:$v1)), v2i64:$v2)),
          (v2i64(MADDSUWDP PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDUHWQ
def : Pat<(v2i32(add (v2i32(KVX_zext_mul v2i16:$v0, v2i16:$v1)), v2i32:$v2)),
          (v2i32 (EXTRACT_SUBREG (v4i32
                  (MADDUHWQ (INSERT_SUBREG (v4i32 (IMPLICIT_DEF)), SingleReg:$v2, sub_s0), SingleReg:$v0, SingleReg:$v1)),
            sub_s0))>;

def : Pat<(v4i32(add (v4i32(KVX_zext_mul v4i16:$v0, v4i16:$v1)), v4i32:$v2)),
          (v4i32(MADDUHWQ PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDUWD
def : Pat<(i64(add (i64(KVX_zext_mul i32:$v0, Wrapped32:$v1)), i64:$v2)),
            (i64(MADDUWDri SingleReg:$v2, SingleReg:$v0, Wrapped32:$v1))>;

def : Pat<(i64(add (i64(KVX_zext_mul i32:$v0, i32:$v1)), i64:$v2)),
            (i64(MADDUWDrr SingleReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDUWDP
def : Pat<(v2i64(add (v2i64(KVX_zext_mul v2i32:$v0, v2i32:$v1)), v2i64:$v2)),
          (v2i64(MADDUWDP PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDW
defm : ZEFPat<(add i32:$a1, (mul i32:$a2, i32:$a3)), (MADDWrr SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;
defm : ZEFPat<(add i32:$a1, (mul i32:$a2, Wrapped32:$a3)), (MADDWri SingleReg:$a1, SingleReg:$a2, Wrapped32:$a3)>;

// MADDWDP
def : Pat<(v2i64(add (v2i64(KVX_sext_mul v2i32:$v0, v2i32:$v1)), v2i64:$v2)),
          (v2i64(MADDWDP PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDWD
def : Pat<(i64(add (i64(KVX_sext_mul i32:$v0, Wrapped32:$v1)), i64:$v2)),
            (i64(MADDWDri SingleReg:$v2, SingleReg:$v0, Wrapped32:$v1))>;

def : Pat<(i64(add (i64(KVX_sext_mul i32:$v0, i32:$v1)), i64:$v2)),
            (i64(MADDWDrr SingleReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MADDWP
// TODO: ri37 & ri10 variants
def : Pat<(v2i32 (add v2i32:$a1, (mul v2i32:$a2, (v2i32(is_imm_vec:$IMM))))),
      (MADDWPri64 SingleReg:$a1, SingleReg:$a2, (build_imm_vec $IMM))>, Requires<[IsV1]>;

def : Pat<(v2i32 (add v2i32:$a1, (mul v2i32:$a2, v2i32:$a3))),
      (MADDWPrr SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;

// TODO: Add immediate sub-vector creation so we can
// add immediate variant to v4i32, e.g.
def : Pat<(v4i32 (add v4i32:$a1, (mul v4i32:$a2, v4i32:$a3))),
      (REG_SEQUENCE PairedReg,
            (v2i32 (MADDWPrr
                  (v2i32 (EXTRACT_SUBREG PairedReg:$a1, sub_s0)),
                  (v2i32 (EXTRACT_SUBREG PairedReg:$a2, sub_s0)),
                  (v2i32 (EXTRACT_SUBREG PairedReg:$a3, sub_s0)))),
            sub_s0,
            (v2i32 (MADDWPrr
                  (v2i32 (EXTRACT_SUBREG PairedReg:$a1, sub_s1)),
                  (v2i32 (EXTRACT_SUBREG PairedReg:$a2, sub_s1)),
                  (v2i32 (EXTRACT_SUBREG PairedReg:$a3, sub_s1)))),
            sub_s1)>;

// MAXD
def : Pat<(smax i64:$v1, i64:$v2), (MAXDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smax i64:$v1, Signed10:$v2), (MAXDri10 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(smax i64:$v1, Signed37:$v2), (MAXDri37 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(smax i64:$v1, Wrapped64:$v2), (MAXDri64 SingleReg:$v1, Wrapped64:$v2)>;

multiclass Word_RR_RIsplat_select_B <SDNode irnode, KVX_INSTRUCTION rinode, KVX_INSTRUCTION rrnode>
{
  foreach vt = [ v2i8, v4i8 ] in {
  //v[24]i8
  def : Pat<(irnode vt:$v1, (vt (is_imm_vec:$IMM))), (rinode SingleReg:$v1, (build_imm_vec $IMM), splat32_)>;
  def : Pat<(irnode vt:$v1, vt:$v2), (rrnode SingleReg:$v1, SingleReg:$v2)>;
  }
  //v8i8
  def : Pat<(irnode v8i8:$v1, (v8i8 (is_imm_vec_kvx_splat32_:$IMM))), (rinode SingleReg:$v1, (build_imm_vec $IMM), splat32_)>;
  def : Pat<(irnode v8i8:$v1, (v8i8 (is_imm_vec_kvx_splat32_at:$IMM))), (rinode SingleReg:$v1, (build_imm_vec $IMM), splat32_at)>;
  def : Pat<(irnode v8i8:$v1, v8i8:$v2), (rrnode SingleReg:$v1, SingleReg:$v2)>;
}

defm MAXBO : Word_RR_RIsplat_select_B<smax, MAXBOri, MAXBOrr>;

multiclass Word_RR_RIsplat_select_H <SDNode irnode, KVX_INSTRUCTION rinode, KVX_INSTRUCTION rrnode>
{
  //v2i16
  def : Pat<(irnode v2i16:$v1, (v2i16 (is_imm_vec:$IMM))), (rinode SingleReg:$v1, (build_imm_vec $IMM), splat32_)>;
  def : Pat<(irnode v2i16:$v1, v2i16:$v2), (rrnode SingleReg:$v1, SingleReg:$v2)>;
  //v4i16 & v3i16
  def : Pat<(irnode v4i16:$v1, (v4i16 (is_imm_vec_kvx_splat32_:$IMM))), (rinode SingleReg:$v1, (build_imm_vec $IMM), splat32_)>;
  def : Pat<(irnode v4i16:$v1, (v4i16 (is_imm_vec_kvx_splat32_at:$IMM))), (rinode SingleReg:$v1, (build_imm_vec $IMM), splat32_at)>;
  def : Pat<(irnode v4i16:$v1, v4i16:$v2), (rrnode SingleReg:$v1, SingleReg:$v2)>;
}

// MAXHQ
defm MAXHQ : Word_RR_RIsplat_select_H<smax, MAXHQri, MAXHQrr>;

// MAXUD
def : Pat<(umax i64:$v1, i64:$v2), (MAXUDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umax i64:$v1, Signed10:$v2), (MAXUDri10 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(umax i64:$v1, Signed37:$v2), (MAXUDri37 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(umax i64:$v1, Wrapped64:$v2), (MAXUDri64 SingleReg:$v1, Wrapped64:$v2)>;

// MAXUBO
defm MAXUBO : Word_RR_RIsplat_select_B<umax, MAXUBOri, MAXUBOrr>;

// MAXUHQ
defm MAXUHQ : Word_RR_RIsplat_select_H<umax, MAXUHQri, MAXUHQrr>;

// MAXUW
defm : ZEFPat<(umax i32:$v1, i32:$v2), (MAXUWrr SingleReg:$v1, SingleReg:$v2)>;
defm : ZEFPat<(umax i32:$v1, Signed10W:$v2), (MAXUWri10 SingleReg:$v1, Signed10W:$v2)>;
defm : ZEFPat<(umax i32:$v1, Signed37W:$v2), (MAXUWri37 SingleReg:$v1, Signed37W:$v2)>;

multiclass Word_RR_RIsplat_select_v2 <SDNode irnode, KVX_INSTRUCTION rinode, KVX_INSTRUCTION rrnode>
{
  def : Pat<(irnode v2i32:$v1, (v2i32 (build_vector (i32 Wrapped32:$i), (i32 0)))), (rinode SingleReg:$v1, Wrapped32:$i, splat32_)>;
  def : Pat<(irnode v2i32:$v1, (v2i32 (build_vector (i32 Wrapped32:$i), (i32 Wrapped32:$i)))), (rinode SingleReg:$v1, Wrapped32:$i, splat32_at)>;
  def : Pat<(irnode v2i32:$v1, v2i32:$v2), (rrnode SingleReg:$v1, SingleReg:$v2)>;
}

// MAXUWP
defm MAXUWP : Word_RR_RIsplat_select_v2<umax, MAXUWPri, MAXUWPrr>;

// MAXW
def : Pat<(smax i32:$v1, i32:$v2), (MAXWrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smax i32:$v1, Signed10W:$v2), (MAXWri10 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(smax i32:$v1, Signed37W:$v2), (MAXWri37 SingleReg:$v1, Signed37W:$v2)>;

// MAXWP
defm MAXWP : Word_RR_RIsplat_select_v2<smax, MAXWPri, MAXWPrr>;

// MIND
def : Pat<(smin i64:$v1, i64:$v2), (MINDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smin i64:$v1, Signed10:$v2), (MINDri10 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(smin i64:$v1, Signed37:$v2), (MINDri37 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(smin i64:$v1, Wrapped64:$v2), (MINDri64 SingleReg:$v1, Wrapped64:$v2)>;

// MINBO
defm MINBO : Word_RR_RIsplat_select_B<smin, MINBOri, MINBOrr>;

// MINHQ
defm MINHQ : Word_RR_RIsplat_select_H<smin, MINHQri, MINHQrr>;

// MINUD
def : Pat<(umin i64:$v1, i64:$v2), (MINUDrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(umin i64:$v1, Signed10:$v2), (MINUDri10 SingleReg:$v1, Signed10:$v2)>;
def : Pat<(umin i64:$v1, Signed37:$v2), (MINUDri37 SingleReg:$v1, Signed37:$v2)>;
def : Pat<(umin i64:$v1, Wrapped64:$v2), (MINUDri64 SingleReg:$v1, Wrapped64:$v2)>;

// MINUBO
defm MINUBO : Word_RR_RIsplat_select_B<umin, MINUBOri, MINUBOrr>;

// MINUHQ
defm MINUHQ : Word_RR_RIsplat_select_H<umin, MINUHQri, MINUHQrr>;

// MINUW
defm : ZEFPat<(umin i32:$v1, i32:$v2), (MINUWrr SingleReg:$v1, SingleReg:$v2)>;
defm : ZEFPat<(umin i32:$v1, Signed10W:$v2), (MINUWri10 SingleReg:$v1, Signed10W:$v2)>;
defm : ZEFPat<(umin i32:$v1, Signed37W:$v2), (MINUWri37 SingleReg:$v1, Signed37W:$v2)>;

// MINUWP
defm MINUWP : Word_RR_RIsplat_select_v2<umin, MINUWPri, MINUWPrr>;

// MINW
def : Pat<(smin i32:$v1, i32:$v2), (MINWrr SingleReg:$v1, SingleReg:$v2)>;
def : Pat<(smin i32:$v1, Signed10W:$v2), (MINWri10 SingleReg:$v1, Signed10W:$v2)>;
def : Pat<(smin i32:$v1, Signed37W:$v2), (MINWri37 SingleReg:$v1, Signed37W:$v2)>;

// MINWP
defm MINWP : Word_RR_RIsplat_select_v2<smin, MINWPri, MINWPrr>;

// MSBFD
def : Pat<(sub i64:$a1, (mul i64:$a2, i64:$a3)), (MSBFD SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;

// MSBFHQ
def : Pat<(sub v2i16:$a1, (mul v2i16:$a2, v2i16:$a3)), (MSBFHQ SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;
def : Pat<(sub v4i16:$a1, (mul v4i16:$a2, v4i16:$a3)), (MSBFHQ SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;

// MSBFHWQ
def : Pat<(v2i32(sub v2i32:$v2, (v2i32(KVX_sext_mul v2i16:$v0, v2i16:$v1)))),
          (v2i32 (EXTRACT_SUBREG (v4i32
                  (MSBFHWQ (INSERT_SUBREG (v4i32 (IMPLICIT_DEF)), SingleReg:$v2, sub_s0), SingleReg:$v0, SingleReg:$v1)),
            sub_s0))>;

def : Pat<(v4i32(sub v4i32:$v2, (v4i32(KVX_sext_mul v4i16:$v0, v4i16:$v1)))),
          (v4i32(MSBFHWQ PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MSBFSUHWQ
def : Pat<(v2i32(sub v2i32:$v2, (v2i32(KVX_szext_mul v2i16:$v0, v2i16:$v1)))),
          (v2i32 (EXTRACT_SUBREG (v4i32
                  (MSBFSUHWQ (INSERT_SUBREG (v4i32 (IMPLICIT_DEF)), SingleReg:$v2, sub_s0), SingleReg:$v0, SingleReg:$v1)),
            sub_s0))>;

def : Pat<(v4i32(sub v4i32:$v2, (v4i32(KVX_szext_mul v4i16:$v0, v4i16:$v1)))),
          (v4i32(MSBFSUHWQ PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MSBFSUWD
def : Pat<(i64(sub i64:$v2, (i64(KVX_szext_mul i32:$v0, Wrapped32:$v1)))),
            (i64(MSBFSUWDri SingleReg:$v2, SingleReg:$v0, Wrapped32:$v1))>;

def : Pat<(i64(sub i64:$v2, (i64(KVX_szext_mul i32:$v0, i32:$v1)))),
            (i64(MSBFSUWDrr SingleReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MSBFSUWDP
def : Pat<(v2i64(sub v2i64:$v2, (v2i64(KVX_szext_mul v2i32:$v0, v2i32:$v1)))),
          (v2i64(MSBFSUWDP PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MSBFUHWQ
def : Pat<(v2i32(sub v2i32:$v2, (v2i32(KVX_zext_mul v2i16:$v0, v2i16:$v1)))),
          (v2i32 (EXTRACT_SUBREG (v4i32
                  (MSBFUHWQ (INSERT_SUBREG (v4i32 (IMPLICIT_DEF)), SingleReg:$v2, sub_s0), SingleReg:$v0, SingleReg:$v1)),
            sub_s0))>;

def : Pat<(v4i32(sub v4i32:$v2, (v4i32(KVX_zext_mul v4i16:$v0, v4i16:$v1)))),
          (v4i32(MSBFUHWQ PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MSBFUWD
def : Pat<(i64(sub i64:$v2, (i64(KVX_zext_mul i32:$v0, Wrapped32:$v1)))),
            (i64(MSBFUWDri SingleReg:$v2, SingleReg:$v0, Wrapped32:$v1))>;

def : Pat<(i64(sub i64:$v2, (i64(KVX_zext_mul i32:$v0, i32:$v1)))),
            (i64(MSBFUWDrr SingleReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MSBFUWDP
def : Pat<(v2i64(sub v2i64:$v2, (v2i64(KVX_zext_mul v2i32:$v0, v2i32:$v1)))),
          (v2i64(MSBFUWDP PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MSBFW
defm : ZEFPat<(sub i32:$a1, (mul i32:$a2, i32:$a3)), (MSBFWrr SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;
defm : ZEFPat<(sub i32:$a1, (mul i32:$a2, Wrapped32:$a3)), (MSBFWri SingleReg:$a1, SingleReg:$a2, Wrapped32:$a3)>;

// MSBFWD
def : Pat<(sub i64:$a1, (KVX_szext_mul i32:$a2, Wrapped32:$a3)), (MSBFWDri SingleReg:$a1, SingleReg:$a2, Wrapped32:$a3)>;
def : Pat<(sub i64:$a1, (KVX_sext_mul i32:$a2, Wrapped32:$a3)), (MSBFWDri SingleReg:$a1, SingleReg:$a2, (trunc_imm_32 imm:$a3))>;
def : Pat<(sub i64:$a1, (KVX_sext_mul i32:$a2, i32:$a3)), (MSBFWDrr SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;

// MSBFWDP
def : Pat<(v2i64(sub v2i64:$v2, (v2i64(KVX_sext_mul v2i32:$v0, v2i32:$v1)))),
          (v2i64(MSBFWDP PairedReg:$v2, SingleReg:$v0, SingleReg:$v1))>;

// MSBFWP
def : Pat<(sub v2i32:$a1, (mul v2i32:$a2, v2i32:$a3)), (MSBFWP SingleReg:$a1, SingleReg:$a2, SingleReg:$a3)>;

// MULD
def : Pat<(mul i64:$rs1, i64:$rs2), (MULDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul i64:$rs1, Signed10:$rs2), (MULDri10 SingleReg:$rs1, Signed10:$rs2)>, Requires<[IsV1]>;
def : Pat<(mul i64:$rs1, Signed37:$rs2), (MULDri37 SingleReg:$rs1, Signed37:$rs2)>, Requires<[IsV1]>;
def : Pat<(mul i64:$rs1, Wrapped64:$rs2), (MULDri64 SingleReg:$rs1, Wrapped64:$rs2)>, Requires<[IsV1]>;

// MULDT
def : Pat<(mulhs i64:$rs1, Signed10:$rs2), (i64 (EXTRACT_SUBREG (MULDTri10 SingleReg:$rs1, Signed10:$rs2), sub_s1))>, Requires<[IsV1]>;
def : Pat<(mulhs i64:$rs1, Signed37:$rs2), (i64 (EXTRACT_SUBREG (MULDTri37 SingleReg:$rs1, Signed37:$rs2), sub_s1))>, Requires<[IsV1]>;
def : Pat<(mulhs i64:$rs1, Wrapped64:$rs2), (i64 (EXTRACT_SUBREG (MULDTri64 SingleReg:$rs1, Wrapped64:$rs2), sub_s1))>, Requires<[IsV1]>;
def : Pat<(mulhs i64:$rs1, i64:$rs2), (i64 (EXTRACT_SUBREG (MULDTrr SingleReg:$rs1, SingleReg:$rs2), sub_s1))>;

def : Pat<(v2i64(KVX_sext_mul i64:$rs1, Signed10:$rs2)),  (v2i64(MULDTri10 SingleReg:$rs1, Signed10:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_sext_mul i64:$rs1, Signed37:$rs2)),  (v2i64(MULDTri37 SingleReg:$rs1, Signed37:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_sext_mul i64:$rs1, Wrapped64:$rs2)), (v2i64(MULDTri64 SingleReg:$rs1, Wrapped64:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_sext_mul i64:$rs1, i64:$rs2)), (v2i64(MULDTrr SingleReg:$rs1, SingleReg:$rs2))>;

// MULHQ
def : Pat<(mul v2i16:$rs1, v2i16:$rs2), (MULHQrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(mul v4i16:$rs1, v4i16:$rs2), (MULHQrr SingleReg:$rs1, SingleReg:$rs2)>;

// MULHWQ
def : Pat<(v2i32(KVX_sext_mul v2i16:$v0, v2i16:$v1)), (v2i32(EXTRACT_SUBREG (v4i32 (MULHWQ SingleReg:$v0, SingleReg:$v1)), sub_s0))>;
def : Pat<(v4i32(KVX_sext_mul v4i16:$v0, v4i16:$v1)), (v4i32(MULHWQ SingleReg:$v0, SingleReg:$v1))>;

// MULSUDT
def : Pat<(v2i64(KVX_szext_mul i64:$rs1, Signed10:$rs2)),  (v2i64(MULSUDTri10 SingleReg:$rs1, Signed10:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_szext_mul i64:$rs1, Signed37:$rs2)),  (v2i64(MULSUDTri37 SingleReg:$rs1, Signed37:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_szext_mul i64:$rs1, Wrapped64:$rs2)), (v2i64(MULSUDTri64 SingleReg:$rs1, Wrapped64:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_szext_mul i64:$rs1, i64:$rs2)), (v2i64(MULSUDTrr SingleReg:$rs1, SingleReg:$rs2))>;

// MULSUHWQ
def : Pat<(v2i32(KVX_szext_mul v2i16:$v0, v2i16:$v1)), (v2i32(EXTRACT_SUBREG (v4i32 (MULSUHWQ SingleReg:$v0, SingleReg:$v1)), sub_s0))>;
def : Pat<(v4i32(KVX_szext_mul v4i16:$v0, v4i16:$v1)), (v4i32(MULSUHWQ SingleReg:$v0, SingleReg:$v1))>;

// MULSUWD
def : Pat<(i64(KVX_szext_mul i32:$v0, Wrapped32:$v1)), (i64(MULSUWDri SingleReg:$v0, Wrapped32:$v1))>;
def : Pat<(i64(KVX_szext_mul i32:$v0, i32:$v1)), (i64(MULSUWDrr SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(i64(KVX_szext_mul (i32(trunc i64:$v0)), (i32 (trunc i64:$v1)))), (i64(MULSUWDrr SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(i64(KVX_szext_mul (i32(trunc i64:$v0)), i32:$v1)), (i64(MULSUWDrr SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(i64(KVX_szext_mul i32:$v0, (i32 (trunc i64:$v1)))), (i64(MULSUWDrr SingleReg:$v0, SingleReg:$v1))>;

// MULSUWDP
def : Pat<(v2i64(KVX_szext_mul v2i32:$v0, v2i32:$v1)), (v2i64 (MULSUWDP SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(v4i64(KVX_szext_mul v4i32:$v0, v4i32:$v1)), (v4i64 (REG_SEQUENCE QuadReg,
                                                                  (v2i64 (MULSUWDP (v2i32 (EXTRACT_SUBREG PairedReg:$v0, sub_s0)),
                                                                                   (v2i32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)))),
                                                                  sub_p0,
                                                                  (v2i64 (MULSUWDP (v2i32 (EXTRACT_SUBREG PairedReg:$v0, sub_s1)),
                                                                                   (v2i32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)))),
                                                                  sub_p1))>;

// MULUDT
def : Pat<(mulhu i64:$rs1, Signed10:$rs2), (i64 (EXTRACT_SUBREG (MULUDTri10 SingleReg:$rs1, Signed10:$rs2), sub_s1))>, Requires<[IsV1]>;
def : Pat<(mulhu i64:$rs1, Wrapped64W:$rs2), (i64 (EXTRACT_SUBREG (MULUDTri37 SingleReg:$rs1, Wrapped64W:$rs2), sub_s1))>, Requires<[IsV1]>;
def : Pat<(mulhu i64:$rs1, Wrapped64:$rs2), (i64 (EXTRACT_SUBREG (MULUDTri64 SingleReg:$rs1, Wrapped64:$rs2), sub_s1))>, Requires<[IsV1]>;
def : Pat<(mulhu i64:$rs1, i64:$rs2), (i64 (EXTRACT_SUBREG (MULUDTrr SingleReg:$rs1, SingleReg:$rs2), sub_s1))>;

def : Pat<(v2i64(KVX_zext_mul i64:$rs1, Unsigned10:$rs2)),  (v2i64(MULUDTri10 SingleReg:$rs1, Unsigned10:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_zext_mul i64:$rs1, Signed37:$rs2)),  (v2i64(MULUDTri37 SingleReg:$rs1, Signed37:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_zext_mul i64:$rs1, Wrapped64:$rs2)), (v2i64(MULUDTri64 SingleReg:$rs1, Wrapped64:$rs2))>, Requires<[IsV1]>;
def : Pat<(v2i64(KVX_zext_mul i64:$rs1, i64:$rs2)), (v2i64(MULUDTrr SingleReg:$rs1, SingleReg:$rs2))>;

// MULUHWQ
def : Pat<(v2i32(KVX_zext_mul v2i16:$v0, v2i16:$v1)), (v2i32(EXTRACT_SUBREG (v4i32 (MULUHWQ SingleReg:$v0, SingleReg:$v1)), sub_s0))>;
def : Pat<(v4i32(KVX_zext_mul v4i16:$v0, v4i16:$v1)), (v4i32(MULUHWQ SingleReg:$v0, SingleReg:$v1))>;

// MULUWD
def : Pat<(i32(mulhu i32:$rs1, i32:$rs2)), (i32 (SRLDri (MULUWDrr SingleReg:$rs1, SingleReg:$rs2), 32))>;
def : Pat<(i32(mulhu i32:$rs1, imm:$rs2)), (i32 (SRLDri (MULUWDri SingleReg:$rs1, Wrapped32:$rs2), 32))>;
def : Pat<(i64(KVX_zext_mul (i32(trunc i64:$v0)), Wrapped32:$v1)), (i64(MULUWDri SingleReg:$v0, Wrapped32:$v1))>;
def : Pat<(i64(KVX_zext_mul i32:$v0, Wrapped32:$v1)), (i64(MULUWDri SingleReg:$v0, Wrapped32:$v1))>;
def : Pat<(i64(KVX_zext_mul i32:$v0, i32:$v1)), (i64(MULUWDrr SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(i64(KVX_zext_mul (i32(trunc i64:$v0)), (i32 (trunc i64:$v1)))), (i64(MULUWDrr SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(i64(KVX_zext_mul (i32(trunc i64:$v0)), i32:$v1)), (i64(MULUWDrr SingleReg:$v0, SingleReg:$v1))>;

// MULUWDP
def : Pat<(v2i64(KVX_zext_mul v2i32:$v0, v2i32:$v1)), (v2i64 (MULUWDP SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(v4i64(KVX_zext_mul v4i32:$v0, v4i32:$v1)), (v4i64 (REG_SEQUENCE QuadReg,
                                                                  (v2i64 (MULUWDP (v2i32 (EXTRACT_SUBREG PairedReg:$v0, sub_s0)),
                                                                                  (v2i32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)))),
                                                                  sub_p0,
                                                                  (v2i64 (MULUWDP (v2i32 (EXTRACT_SUBREG PairedReg:$v0, sub_s1)),
                                                                                  (v2i32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)))),
                                                                  sub_p1))>;

// MULW
defm : ZEFPat<(mul i32:$rs1, i32:$rs2), (MULWrr SingleReg:$rs1, SingleReg:$rs2)>;
defm : ZEFPat<(mul i32:$rs1, Wrapped32:$rs2), (MULWri SingleReg:$rs1, Wrapped32:$rs2)>;

// MULWD
def : Pat<(i32(mulhs i32:$rs1, i32:$rs2)), (i32 (SRADri (MULWDrr SingleReg:$rs1, SingleReg:$rs2), 32))>;
def : Pat<(i32(mulhs i32:$rs1, imm:$rs2)), (i32 (SRADri (MULWDri SingleReg:$rs1, Wrapped32:$rs2), 32))>;
def : Pat<(i64(KVX_sext_mul i32:$v0, Wrapped32:$v1)), (i64(MULWDri SingleReg:$v0, Wrapped32:$v1))>;
def : Pat<(i64(KVX_sext_mul i32:$v0, i32:$v1)), (i64(MULWDrr SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(i64(KVX_sext_mul (i32(trunc i64:$v0)), (i32 (trunc i64:$v1)))), (i64(MULWDrr SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(i64(KVX_sext_mul (i32(trunc i64:$v0)), i32:$v1)), (i64(MULWDrr SingleReg:$v0, SingleReg:$v1))>;

// MULWDP
def : Pat<(v2i64(KVX_sext_mul v2i32:$v0, v2i32:$v1)), (v2i64 (MULWDP SingleReg:$v0, SingleReg:$v1))>;
def : Pat<(v4i64(KVX_sext_mul v4i32:$v0, v4i32:$v1)), (v4i64 (REG_SEQUENCE QuadReg,
                                                                  (v2i64 (MULWDP (v2i32 (EXTRACT_SUBREG PairedReg:$v0, sub_s0)),
                                                                                 (v2i32 (EXTRACT_SUBREG PairedReg:$v1, sub_s0)))),
                                                                  sub_p0,
                                                                  (v2i64 (MULWDP (v2i32 (EXTRACT_SUBREG PairedReg:$v0, sub_s1)),
                                                                                 (v2i32 (EXTRACT_SUBREG PairedReg:$v1, sub_s1)))),
                                                                  sub_p1))>;

// MULWP
def : Pat<(mul v2i32:$rs1, v2i32:$rs2), (MULWPrr SingleReg:$rs1, SingleReg:$rs2)>;

// MULWQ
def : Pat<(mul v4i32:$rs1, v4i32:$rs2), (MULWQ PairedReg:$rs1, PairedReg:$rs2)>;

// NANDD
def : Pat<(i64 (or (not i64:$r), (i64 Signed10:$i))), (NANDDri10 SingleReg:$r, (get_not_imm $i) )>;
def : Pat<(i64 (or (not i64:$r), (i64 Signed37:$i))), (NANDDri37 SingleReg:$r, (get_not_imm $i) )>;
def : Pat<(i64 (or (not i64:$r), (i64 Wrapped64:$i))), (NANDDri64 SingleReg:$r, (get_not_imm $i) )>;
def : Pat<(not (and i64:$rs1, i64:$rs2)), (NANDDrr SingleReg:$rs1, SingleReg:$rs2)>;

// TODO: ri10 patterns
foreach vtype = [ v2i32, v4i16, v8i8 ] in {
    def : Pat<(vnot (and vtype:$r, (vtype (is_imm_vec_ri37:$IMM)))), (NANDDri37 SingleReg:$r, (build_imm_vec $IMM))>;
    def : Pat<(vnot (and vtype:$r, (vtype (is_imm_vec:$IMM)))), (NANDDri64 SingleReg:$r, (build_imm_vec $IMM))>;
    def : Pat<(vnot (and vtype:$rs1, vtype:$rs2)), (NANDDrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// NANDW
def : Pat<(i32 (or (not i32:$r), (i32 Signed10W:$i))), (NANDWri10 SingleReg:$r, (get_not_imm $i) )>;
def : Pat<(i32 (or (not i32:$r), (i32 Wrapped32:$i))), (NANDWri37 SingleReg:$r, (get_not_imm $i) )>;
def : Pat<(not (and i32:$rs1, i32:$rs2)), (NANDWrr SingleReg:$rs1, SingleReg:$rs2)>;

// TODO: ri10 patterns
foreach vtype = [ v2i8, v4i8, v2i16 ] in {
    def : Pat<(vnot (and vtype:$r, (vtype (is_imm_vec:$IMM)))), (NANDWri37 SingleReg:$r, (build_imm_vec $IMM))>;
    def : Pat<(vnot (and vtype:$rs1, vtype:$rs2)), (NANDWrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// NEGBO
foreach vt = [ v2i8, v4i8 ] in
def : Pat<(vineg vt:$v), (NEGBO SingleReg:$v)>, Requires<[IsV2]>;

// NEGHQ - v4i16 pattern in instruction definition
def : Pat<(vineg v2i16:$v), (NEGHQ SingleReg:$v)>;

// NEGSBO - v8i8 pattern in instruction definition
foreach vt = [v2i8, v4i8] in
def : Pat<(vineg_ssat vt:$v),
          (NEGSBO SingleReg:$v)>, Requires<[IsV2]>;

// NEGSHQ - v4i16 pattern in instruction definition
def : Pat<(vineg_ssat v2i16:$v),
          (NEGSHQ SingleReg:$v)>, Requires<[IsV2]>;

// NXOR ri variants are not easy, as they become a single xor
// NXORD
def : Pat<(xor (xor i64:$rs1, i64:$rs2), (i64 -1)), (NXORDrr SingleReg:$rs1, SingleReg:$rs2)>;
foreach vtype = [ v2i32, v4i16, v8i8 ] in
    def : Pat<(vnot (xor vtype:$rs1, vtype:$rs2)), (NXORDrr SingleReg:$rs1, SingleReg:$rs2)>;

// NXORW
def : Pat<(xor (xor i32:$rs1, i32:$rs2), (i32 -1)), (NXORWrr SingleReg:$rs1, SingleReg:$rs2)>;
foreach vtype = [ v2i8, v2i16, v4i8 ] in
    def : Pat<(vnot (xor vtype:$rs1, vtype:$rs2)), (NXORWrr SingleReg:$rs1, SingleReg:$rs2)>;

// ORD
def : Pat<(or i64:$rs1, i64:$rs2), (ORDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(or i64:$rs1, Signed10:$rs2), (ORDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(or i64:$rs1, Signed37:$rs2), (ORDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(or i64:$rs1, Wrapped64:$rs2), (ORDri64 SingleReg:$rs1, Wrapped64:$rs2)>;

foreach vtype = [ v8i8, v4i16, v2i32 ] in {
    def : Pat<(or vtype:$rs1, vtype:$rs2), (ORDrr SingleReg:$rs1, SingleReg:$rs2)>;
    def : Pat<(or vtype:$rs1, (vtype (is_imm_vec:$IMM))), (ORDri64 SingleReg:$rs1, (build_imm_vec $IMM))>;
}

// ORND
def : Pat<(or (not i64:$rs1), i64:$rs2), (ORNDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(ORNDriPat (or i64:$rs1, Signed10:$c1), Signed10), (ORNDri10 SingleReg:$rs1, Signed10:$c1)>;
def : Pat<(ORNDriPat (or i64:$rs1, Signed37:$c1), Signed37), (ORNDri37 SingleReg:$rs1, Signed37:$c1)>;
def : Pat<(ORNDriPat (or i64:$rs1, Wrapped64:$c1), Wrapped64), (ORNDri64 SingleReg:$rs1, Wrapped64:$c1)>;
// TODO: Add ri37 and ri10 to vector types
foreach vtype = [ v8i8, v4i16, v2i32 ] in {
    def : Pat<(or (vnot vtype:$rs1), (vtype (is_imm_vec:$IMM))), (ORNDri64 SingleReg:$rs1, (build_imm_vec $IMM))>;
    def : Pat<(or (vnot vtype:$rs1), vtype:$rs2), (ORNDrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// ORNW
def : Pat<(or (not i32:$rs1), i32:$rs2), (ORNWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(ORNDriPat (or i32:$rs1, Signed10W:$c1), Signed10W), (ORNWri10 SingleReg:$rs1, Signed10W:$c1)>;
def : Pat<(ORNDriPat (or i32:$rs1, Signed37W:$c1), Signed37W), (ORNWri37 SingleReg:$rs1, Signed37W:$c1)>;
// TODO: Add ri10 to vector types
foreach vtype = [ v2i8, v4i8, v2i16 ] in {
    def : Pat<(or (vnot vtype:$rs1), (vtype (is_imm_vec:$IMM))), (ORNWri37 SingleReg:$rs1, (build_imm_vec $IMM))>;
    def : Pat<(or (vnot vtype:$rs1), vtype:$rs2), (ORNDrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// ORW
defm : ZEFPat<(or i32:$rs1, i32:$rs2), (ORWrr SingleReg:$rs1, SingleReg:$rs2)>;
defm : ZEFPat<(or i32:$rs1, Signed10W:$rs2), (ORWri10 SingleReg:$rs1, Signed10W:$rs2)>;
defm : ZEFPat<(or i32:$rs1, Signed37W:$rs2), (ORWri37 SingleReg:$rs1, Signed37W:$rs2)>;

foreach vtype = [ v2i8, v4i8, v2i16 ] in {
    def : Pat<(or vtype:$rs1, vtype:$rs2), (ORWrr SingleReg:$rs1, SingleReg:$rs2)>;
    def : Pat<(or vtype:$rs1, (vtype (is_imm_vec:$IMM))), (ORWri37 SingleReg:$rs1, (build_imm_vec $IMM))>;
}

// ROLW
def : Pat<(rotl i32:$rs1, i64:$rs2), (ROLWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(rotl i32:$rs, Unsigned6:$is), (ROLWri SingleReg:$rs, Unsigned6:$is)>;

multiclass WPShiftScalarOps <SDNode Op, KVX_INSTRUCTION RI, KVX_INSTRUCTION RR, KVX_INSTRUCTION RI_w, KVX_INSTRUCTION RR_w>
{
def : Pat<(Op v2i32:$v0, (v2i32 ( v2_splat (i32 imm:$i)))), (RI SingleReg:$v0, (mod_32_imm_64 imm:$i))>;
def : Pat<(Op v2i32:$v0, (v2i32 ( v2_splat i32:$v1))), (RR SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(Op v2i32:$v, (v2i32 ( build_vector (i32 imm:$i0), (i32 imm:$i1)))),
      (INSF(RI SingleReg:$v, (mod_32_imm_64 imm:$i1)), (RI_w SingleReg:$v, (mod_32_imm_64 imm:$i0)), 31, 0)>;
def : Pat<(Op v2i32:$v0, v2i32:$v1),
      (INSF(RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 36, 32)), (RR_w SingleReg:$v0, SingleReg:$v1), 31, 0) >;
}
// ROLWP
defm : WPShiftScalarOps<rotl, ROLWPSri, ROLWPSrr, ROLWri, ROLWrr>;
// LLVM does not detect the rotation across build_vectors. We need to do it manually
def : Pat<(v2i32(or (srl v2i32:$r0, (v2i32 (v2_splat (i32 (sub (i32 32), i32:$r1)))) ), (shl v2i32:$r0, (v2i32 (v2_splat i32:$r1))))),
          (ROLWPSrr SingleReg:$r0, SingleReg:$r1)>;

// RORW
def : Pat<(rotr i32:$rs1, i64:$rs2), (RORWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(rotr i32:$rs, Unsigned6:$is), (RORWri SingleReg:$rs, Unsigned6:$is)>;

// RORWP
defm : WPShiftScalarOps<rotr, RORWPSri, RORWPSrr, RORWri, RORWrr>;
// LLVM does not detect the rotation across build_vectors. We need to do it manually
def : Pat<(v2i32(or (shl v2i32:$r0, (v2i32 (v2_splat (i32 (sub (i32 32), i32:$r1)))) ), (srl v2i32:$r0, (v2i32 (v2_splat i32:$r1))))),
          (RORWPSrr SingleReg:$r0, SingleReg:$r1)>;

let Predicates = [IsV1] in {
// SATD
multiclass SATDW_PAT<int min_val, int max_val, int num_bits> {
def : Pat<(i64(smin (smax i64:$v, (i64 min_val)), (i64 max_val))), (SATDri SingleReg:$v, num_bits)>;
def : Pat<(i64(smax (smin i64:$v, (i64 max_val)), (i64 min_val))), (SATDri SingleReg:$v, num_bits)>;
}
foreach Bits = {2-15, 17-31} in {
      defm : SATDW_PAT<!sub(0, !shl(1, !sub(Bits, 1))), !sub(!shl(1, !sub(Bits, 1)), 1), Bits>;
}

multiclass SATD_PAT<int min_val, int max_val, int num_bits> {
def : Pat<(i64(smin (smax i64:$v, (i64 min_val)), (i64 max_val))), (SATDri SingleReg:$v, num_bits)>;
def : Pat<(i64(smax (smin i64:$v, (i64 max_val)), (i64 min_val))), (SATDri SingleReg:$v, num_bits)>;
}

defm : SATD_PAT<-4294967296, 4294967295, 33>;
defm : SATD_PAT<-8589934592, 8589934591, 34>;
defm : SATD_PAT<-17179869184, 17179869183, 35>;
defm : SATD_PAT<-34359738368, 34359738367, 36>;
defm : SATD_PAT<-68719476736, 68719476735, 37>;
defm : SATD_PAT<-137438953472, 137438953471, 38>;
defm : SATD_PAT<-274877906944, 274877906943, 39>;
defm : SATD_PAT<-549755813888, 549755813887, 40>;
defm : SATD_PAT<-1099511627776, 1099511627775, 41>;
defm : SATD_PAT<-2199023255552, 2199023255551, 42>;
defm : SATD_PAT<-4398046511104, 4398046511103, 43>;
defm : SATD_PAT<-8796093022208, 8796093022207, 44>;
defm : SATD_PAT<-17592186044416, 17592186044415, 45>;
defm : SATD_PAT<-35184372088832, 35184372088831, 46>;
defm : SATD_PAT<-70368744177664, 70368744177663, 47>;
defm : SATD_PAT<-140737488355328, 140737488355327, 48>;
defm : SATD_PAT<-281474976710656, 281474976710655, 49>;
defm : SATD_PAT<-562949953421312, 562949953421311, 50>;
defm : SATD_PAT<-1125899906842624, 1125899906842623, 51>;
defm : SATD_PAT<-2251799813685248, 2251799813685247, 52>;
defm : SATD_PAT<-4503599627370496, 4503599627370495, 53>;
defm : SATD_PAT<-9007199254740992, 9007199254740991, 54>;
defm : SATD_PAT<-18014398509481984, 18014398509481983, 55>;
defm : SATD_PAT<-36028797018963968, 36028797018963967, 56>;
defm : SATD_PAT<-72057594037927936, 72057594037927935, 57>;
defm : SATD_PAT<-144115188075855872, 144115188075855871, 58>;
defm : SATD_PAT<-288230376151711744, 288230376151711743, 59>;
defm : SATD_PAT<-576460752303423488, 576460752303423487, 60>;
defm : SATD_PAT<-1152921504606846976, 1152921504606846975, 61>;
defm : SATD_PAT<-2305843009213693952, 2305843009213693951, 62>;
defm : SATD_PAT<-4611686018427387904, 4611686018427387903, 63>;

// SATDH
def : Pat<(i64( smin (smax i64:$v, -32768), 32767 )), (SATDH SingleReg:$v)>;
def : Pat<(i64( smax (smin i64:$v, 32767), -32768 )), (SATDH SingleReg:$v)>;

// SATDW
def : Pat<(i64( smin (smax i64:$v, i64_i32_min), i64_i32_max )), (SATDW SingleReg:$v)>;
def : Pat<(i64( smax (smin i64:$v, i64_i32_max), i64_i32_min )), (SATDW SingleReg:$v)>;
} // let Requires<[IsV1]>

// SBFCHCP TODO: add ri variants
def : Pat<(i64 (or
                  (and (sub i64:$t4, i64:$t2), (i64 0xffff)),
                  (and
                    (add (and i64:$t4, (i64 0xffff0000)), i64:$t2),
                    (i64 0xffff0000))
              )
            ),
          (SBFCHCPrr SingleReg:$t4, SingleReg:$t2)>, Requires<[IsV1]>;

def : Pat<(i64 (or
                  (or
                    (or
                       (and(sub i64:$t4, (and i64:$t2, (i64 0xffff00000000))), (i64 0xffff00000000)),
                       (and (sub i64:$t4, i64:$t2), (i64 0xffff))),
                    (and
                       (add (and i64:$t2, (i64 0xffff000000000000)), i64:$t4),
                       (i64 0xffff000000000000))),
                  (and
                    (add (and i64:$t4, (i64 0xffff0000)), i64:$t2),
                    (i64 0xffff0000))
              )
            ),
          (SBFCHCPrr SingleReg:$t4, SingleReg:$t2)>, Requires<[IsV1]>;


// SBFCWC
// TODO: ri variants
def : Pat<(i64(or(and (add i64:$r1, (and i64:$r0, (i64 0xffffffff00000000))), (i64 0xffffffff00000000) ),
              (and (sub i64:$r0, i64:$r1), (i64 0xffffffff)))),
          (SBFCWCrr SingleReg:$r1, SingleReg:$r0)>, Requires<[IsV1]>;

// SBFD
def : Pat<(sub i64:$rs1, i64:$rs2), (SBFDrr SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub Signed10:$rs1, i64:$rs2), (SBFDri10 SingleReg:$rs2, Signed10:$rs1)>;
def : Pat<(sub Signed37:$rs1, i64:$rs2), (SBFDri37 SingleReg:$rs2, Signed37:$rs1)>;
def : Pat<(sub Wrapped64:$rs1, i64:$rs2), (SBFDri64 SingleReg:$rs2, Wrapped64:$rs1)>;

// SBFBO
def : Pat<(sub (v2i8(is_imm_vec:$IMM)), v2i8:$rs1), (SBFBOri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(sub v2i8:$rs1, v2i8:$rs2), (SBFBOrr SingleReg:$rs2, SingleReg:$rs1)>, Requires<[IsV2]>;
def : Pat<(sub (v4i8(is_imm_vec:$IMM)), v4i8:$rs1), (SBFBOri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(sub v4i8:$rs1, v4i8:$rs2), (SBFBOrr SingleReg:$rs2, SingleReg:$rs1)>, Requires<[IsV2]>;
def : Pat<(sub (v8i8(is_imm_vec_kvx_splat32_:$IMM)), v8i8:$rs1), (SBFBOri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(sub (v8i8(is_imm_vec_kvx_splat32_at:$IMM)), v8i8:$rs1), (SBFBOri SingleReg:$rs1, (build_imm_vec $IMM), splat32_at)>, Requires<[IsV2]>;
def : Pat<(sub v8i8:$rs1, v8i8:$rs2), (SBFBOrr SingleReg:$rs2, SingleReg:$rs1)>, Requires<[IsV2]>;

// SBFHQ
def : Pat<(sub (v2i16(is_imm_vec:$IMM)), v2i16:$rs1), (SBFHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>;
def : Pat<(sub v2i16:$rs1, v2i16:$rs2), (SBFHQrr SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(sub (v4i16(is_imm_vec_kvx_splat32_:$IMM)), v4i16:$rs1), (SBFHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>;
def : Pat<(sub (v4i16(is_imm_vec_kvx_splat32_at:$IMM)), v4i16:$rs1), (SBFHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_at)>;
def : Pat<(sub v4i16:$rs1, v4i16:$rs2), (SBFHQrr SingleReg:$rs2, SingleReg:$rs1)>;

// SBFSD
// v1 immediate allows sext to i64
def : Pat<(i64(ssubsat Signed10:$im, i64:$r)),
          (SBFSDri10 SingleReg:$r, Signed10:$im)>, Requires<[IsV1]>;

def : Pat<(i64(ssubsat Signed37:$im, i64:$r)),
          (SBFSDri37 SingleReg:$r, Signed37:$im)>, Requires<[IsV1]>;

def : Pat<(i64(ssubsat Wrapped64:$im, i64:$r)),
          (SBFSDri64 SingleReg:$r, Wrapped64:$im)>, Requires<[IsV1]>;

// v2 immediates
def : Pat<(i64(ssubsat Unsigned64W:$lhs, i64:$rhs)),
          (SBFSDri SingleReg:$rhs, (i32(trunc_imm_32 $lhs)), splat32_)>, Requires<[IsV2]>;

def : Pat<(i64(ssubsat UnsignedSplat32Imm:$lhs, i64:$rhs)),
          (SBFSDri SingleReg:$rhs, (i32(trunc_imm_32 $lhs)), splat32_at)>, Requires<[IsV2]>;

// rr
def : Pat<(i64(ssubsat i64:$lhs, i64:$rhs)),
          (SBFSDrr SingleReg:$rhs, SingleReg:$lhs)>;

// SBFSBO
def : Pat<(v2i8(ssubsat (is_imm_vec:$IMM), v2i8:$v0)),
          (SBFSBOri SingleReg:$v0, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(v2i8(ssubsat v2i8:$v1, v2i8:$v0)), (SBFSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v4i8(ssubsat (v4i8(is_imm_vec:$IMM)), v4i8:$v0) ),
           (SBFSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v4i8(ssubsat v4i8:$v1, v4i8:$v0)), (SBFSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v8i8(ssubsat (v8i8(is_imm_vec_kvx_splat32_:$IMM)), v8i8:$v0) ),
           (SBFSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v8i8(ssubsat (v8i8(is_imm_vec_kvx_splat32_at:$IMM)), v8i8:$v0) ),
           (SBFSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>, Requires<[IsV2]>;
def : Pat<(v8i8(ssubsat v8i8:$v1, v8i8:$v0)), (SBFSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

// SBFSHQ
def : Pat<(ssubsat (v2i16(is_imm_vec:$IMM)), v2i16:$rs1), (SBFSHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>;
def : Pat<(ssubsat v2i16:$rs1, v2i16:$rs2), (SBFSHQrr SingleReg:$rs2, SingleReg:$rs1)>;
def : Pat<(ssubsat (v4i16(is_imm_vec_kvx_splat32_:$IMM)), v4i16:$rs1), (SBFSHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_)>;
def : Pat<(ssubsat (v4i16(is_imm_vec_kvx_splat32_at:$IMM)), v4i16:$rs1), (SBFSHQri SingleReg:$rs1, (build_imm_vec $IMM), splat32_at)>;
def : Pat<(ssubsat v4i16:$v0, v4i16:$v1), (SBFSHQrr SingleReg:$v1, SingleReg:$v0)>;

// SBFSW
def : Pat<(i32(ssubsat Wrapped32:$i, i32:$v)), (SBFSWri SingleReg:$v, Wrapped32:$i)>;
def : Pat<(i32(ssubsat i32:$v1, i32:$v0)), (SBFSWrr SingleReg:$v0, SingleReg:$v1)>;

// SBFSWP
def : Pat<(v2i32(ssubsat (v2i32(is_imm_vec_kvx_splat32_:$IMM)), v2i32:$v0) ),
           (SBFSWPri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>;
def : Pat<(v2i32(ssubsat (v2i32(is_imm_vec_kvx_splat32_at:$IMM)), v2i32:$v0) ),
           (SBFSWPri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>;
def : Pat<(v2i32(ssubsat v2i32:$v1, v2i32:$v0)), (SBFSWPrr SingleReg:$v0, SingleReg:$v1)>;

// SBFUSBO
def : Pat<(v2i8(usubsat (is_imm_vec:$IMM), v2i8:$v0)),
          (SBFUSBOri SingleReg:$v0, (build_imm_vec $IMM), splat32_)>, Requires<[IsV2]>;
def : Pat<(v2i8(usubsat v2i8:$v1, v2i8:$v0)), (SBFUSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v4i8(usubsat (v4i8(is_imm_vec:$IMM)), v4i8:$v0) ),
           (SBFUSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v4i8(usubsat v4i8:$v1, v4i8:$v0)), (SBFUSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v8i8(usubsat (v8i8(is_imm_vec_kvx_splat32_:$IMM)), v8i8:$v0) ),
           (SBFUSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v8i8(usubsat (v8i8(is_imm_vec_kvx_splat32_at:$IMM)), v8i8:$v0) ),
           (SBFUSBOri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>, Requires<[IsV2]>;
def : Pat<(v8i8(usubsat v8i8:$v1, v8i8:$v0)), (SBFUSBOrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

// SBFUSD
def : Pat<(i64(usubsat Wrapped64W:$i, i64:$v)), (SBFUSDri SingleReg:$v, (i32(trunc_imm_32 $i)), splat32_)>;
def : Pat<(i64(usubsat UnsignedSplat32Imm:$i, i64:$v)), (SBFUSDri SingleReg:$v, (i32(trunc_imm_32 $i)), splat32_at)>;
def : Pat<(i64(usubsat i64:$v1, i64:$v0)), (SBFUSDrr SingleReg:$v0, SingleReg:$v1)>;

// SBFUHQ
def : Pat<(v2i16(usubsat (v2i16(is_imm_vec:$IMM)), v2i16:$v0) ),
           (SBFUSHQri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v2i16(usubsat v2i16:$v1, v2i16:$v0)), (SBFUSHQrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

def : Pat<(v4i16(usubsat (v4i16(is_imm_vec_kvx_splat32_:$IMM)), v4i16:$v0) ),
           (SBFUSHQri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v4i16(usubsat (v4i16(is_imm_vec_kvx_splat32_at:$IMM)), v4i16:$v0) ),
           (SBFUSHQri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>, Requires<[IsV2]>;
def : Pat<(v4i16(usubsat v4i16:$v1, v4i16:$v0)), (SBFUSHQrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

// SBFUSW
def : Pat<(i32(usubsat Wrapped32:$i, i32:$v)), (SBFUSWri SingleReg:$v, Wrapped32:$i, splat32_)>;
def : Pat<(i32(usubsat i32:$v1, i32:$v0)), (SBFUSWrr SingleReg:$v0, SingleReg:$v1)>;

// SBFUSWP
def : Pat<(v2i32(usubsat (v2i32(is_imm_vec_kvx_splat32_:$IMM)), v2i32:$v0) ),
           (SBFUSWPri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>, Requires<[IsV2]>;
def : Pat<(v2i32(usubsat (v2i32(is_imm_vec_kvx_splat32_at:$IMM)), v2i32:$v0) ),
           (SBFUSWPri SingleReg:$v0, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>, Requires<[IsV2]>;
def : Pat<(v2i32(usubsat v2i32:$v1, v2i32:$v0)), (SBFUSWPrr SingleReg:$v0, SingleReg:$v1)>, Requires<[IsV2]>;

// SBFUWD ri variants are not usefull, as SBFD is cheaper
// FIXME: In most cases we don't produce a zxwd,
// so using SBFUWD is worse than using a SBFD
// def : Pat<(i64 (sub i64:$d, (zext i32:$w))), (SBFUWDrr SingleReg:$d, SingleReg:$w)>;

// SBFWD ri variants are not usefull, as SBFD is cheaper
def : Pat<(i64 (sub i64:$d, (sext i32:$w))), (SBFWDrr SingleReg:$w, SingleReg:$d)>;

// SBFW
defm : ZEFPat<(sub i32:$rs1, i32:$rs2), (SBFWrr SingleReg:$rs2, SingleReg:$rs1)>;
defm : ZEFPat<(sub Signed10W:$rs1, i32:$rs2), (SBFWri10 SingleReg:$rs2, Signed10W:$rs1)>;
defm : ZEFPat<(sub Signed37W:$rs1, i32:$rs2), (SBFWri37 SingleReg:$rs2, Signed37W:$rs1)>;

// SBFWP
def : Pat<(sub (v2i32 (v2i32(is_imm_vec_kvx_splat32_:$IMM))), v2i32:$r),
          (SBFWPri SingleReg:$r, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_)>;

def : Pat<(sub (v2i32(is_imm_vec_kvx_splat32_at:$IMM)), v2i32:$r),
          (SBFWPri SingleReg:$r, (i32(trunc_imm_32 (i32(build_imm_vec $IMM)))), splat32_at)>;

def : Pat<(sub v2i32:$rs1, v2i32:$rs2), (SBFWPrr SingleReg:$rs2, SingleReg:$rs1)>;

def : Pat<(sub v4i32:$rs1, v4i32:$rs2),
      (REG_SEQUENCE PairedReg,
            (v2i32 (SBFWPrr (v2i32(EXTRACT_SUBREG PairedReg:$rs2, sub_s1)),
                            (v2i32(EXTRACT_SUBREG PairedReg:$rs1, sub_s1)))),
            sub_s1,
            (v2i32 (SBFWPrr (v2i32(EXTRACT_SUBREG PairedReg:$rs2, sub_s0)),
                            (v2i32(EXTRACT_SUBREG PairedReg:$rs1, sub_s0)))),
            sub_s0)>;

// SBFX*
multiclass SBFXDPAT<dag sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(sub Wrapped64W:$r1, (shl i64:$r2, sc)), (RIInstr SingleReg:$r2, (trunc_imm_32 imm:$r1), splat32_)>;
def : Pat<(sub SignedSplat32Imm:$r1, (shl i64:$r2, sc)), (RIInstr SingleReg:$r2, (trunc_imm_32 imm:$r1), splat32_at)>;
def : Pat<(sub i64:$r1, (shl i64:$r2, sc)), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
}

defm : SBFXDPAT<(i64 6), SBFX64Drr, SBFX64Dri>, Requires<[IsV2]>;
defm : SBFXDPAT<(i64 5), SBFX32Drr, SBFX32Dri>, Requires<[IsV2]>;
defm : SBFXDPAT<(i64 4), SBFX16Drr, SBFX16Dri>;
defm : SBFXDPAT<(i64 3), SBFX8Drr, SBFX8Dri>;
defm : SBFXDPAT<(i64 2), SBFX4Drr, SBFX4Dri>;
defm : SBFXDPAT<(i64 1), SBFX2Drr, SBFX2Dri>;


multiclass SBFXUWDPAT<dag sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(sub i64:$r1, (i64 (zext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(sub Wrapped64W:$r1, (i64 (zext (shl i32:$r2, sc))) ), (RIInstr SingleReg:$r2, (trunc_imm_32 imm:$r1))>;
}
defm : SBFXUWDPAT<(i64 6), SBFX64UWDrr, SBFX64UWDri>, Requires<[IsV2]>;
defm : SBFXUWDPAT<(i64 5), SBFX32UWDrr, SBFX32UWDri>, Requires<[IsV2]>;
defm : SBFXUWDPAT<(i64 4), SBFX16UWDrr, SBFX16UWDri>;
defm : SBFXUWDPAT<(i64 3), SBFX8UWDrr, SBFX8UWDri>;
defm : SBFXUWDPAT<(i64 2), SBFX4UWDrr, SBFX4UWDri>;
defm : SBFXUWDPAT<(i64 1), SBFX2UWDrr, SBFX2UWDri>;

multiclass SBFXWPAT<dag sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
defm : ZEFPat<(sub i32:$r1, (shl i32:$r2, sc)), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
defm : ZEFPat<(sub Wrapped32:$r1, (shl i32:$r2, sc)), (RIInstr SingleReg:$r2, Wrapped32:$r1)>;
}

defm : SBFXWPAT<(i64 6), SBFX64Wrr, SBFX64Wri>, Requires<[IsV2]>;
defm : SBFXWPAT<(i64 5), SBFX32Wrr, SBFX32Wri>, Requires<[IsV2]>;
defm : SBFXWPAT<(i64 4), SBFX16Wrr, SBFX16Wri>;
defm : SBFXWPAT<(i64 3), SBFX8Wrr, SBFX8Wri>;
defm : SBFXWPAT<(i64 2), SBFX4Wrr, SBFX4Wri>;
defm : SBFXWPAT<(i64 1), SBFX2Wrr, SBFX2Wri>;

multiclass SBFXWDPAT<dag sc, KVX_INSTRUCTION RRInstr, KVX_INSTRUCTION RIInstr> {
def : Pat<(sub i64:$r1, (i64 (sext (shl i32:$r2, sc))) ), (RRInstr SingleReg:$r2, SingleReg:$r1)>;
def : Pat<(sub Wrapped64W:$r1, (i64 (sext (shl i32:$r2, sc)))), (RIInstr SingleReg:$r2, (trunc_imm_32 imm:$r1))>;
}

defm : SBFXWDPAT<(i64 6), SBFX64WDrr, SBFX64WDri>, Requires<[IsV2]>;
defm : SBFXWDPAT<(i64 5), SBFX32WDrr, SBFX32WDri>, Requires<[IsV2]>;
defm : SBFXWDPAT<(i64 4), SBFX16WDrr, SBFX16WDri>;
defm : SBFXWDPAT<(i64 3), SBFX8WDrr, SBFX8WDri>;
defm : SBFXWDPAT<(i64 2), SBFX4WDrr, SBFX4WDri>;
defm : SBFXWDPAT<(i64 1), SBFX2WDrr, SBFX2WDri>;

multiclass SBFXPAT_HalfSReg<ValueType vt, dag sc, KVX_INSTRUCTION RR, KVX_INSTRUCTION RI> {
def : Pat<(vt(sub (vt(is_imm_vec:$IMM)), (shl vt:$v, (vt(v2_splat sc))))),
          (RI $v, (build_imm_vec $IMM), splat32_)>;
def : Pat<(vt(sub vt:$v0, (shl vt:$v1, (vt(v2_splat sc))))), (RR SingleReg:$v1, SingleReg:$v0)>;
}

foreach vt = [ v2i8, v4i8 ] in {
defm : SBFXPAT_HalfSReg<vt, (i32 1), SBFX2BOrr,  SBFX2BOri>, Requires<[IsV2]>;
defm : SBFXPAT_HalfSReg<vt, (i32 2), SBFX4BOrr,  SBFX4BOri>, Requires<[IsV2]>;
defm : SBFXPAT_HalfSReg<vt, (i32 3), SBFX8BOrr,  SBFX8BOri>, Requires<[IsV2]>;
defm : SBFXPAT_HalfSReg<vt, (i32 4), SBFX16BOrr, SBFX16BOri>, Requires<[IsV2]>;
}

defm : SBFXPAT_HalfSReg<v2i16, (i32 1), SBFX2HQrr,  SBFX2HQri>;
defm : SBFXPAT_HalfSReg<v2i16, (i32 2), SBFX4HQrr,  SBFX4HQri>;
defm : SBFXPAT_HalfSReg<v2i16, (i32 3), SBFX8HQrr,  SBFX8HQri>;
defm : SBFXPAT_HalfSReg<v2i16, (i32 4), SBFX16HQrr, SBFX16HQri>;

multiclass VECSBFXPAT<ValueType vt, dag sc, KVX_INSTRUCTION RR, KVX_INSTRUCTION RI, PatFrag v_splat> {
def : Pat<(vt(sub (vt(is_imm_vec_kvx_splat32_:$IMM)), (shl vt:$v, (vt(v_splat sc))) )),
          (RI $v, (build_imm_vec $IMM), splat32_)>;
def : Pat<(vt(sub (vt(is_imm_vec_kvx_splat32_at:$IMM)), (shl vt:$v, (vt(v_splat sc))))),
          (RI $v, (build_imm_vec $IMM), splat32_at)>;
def : Pat<(vt(sub vt:$v0, (shl vt:$v1, (vt(v_splat sc))))), (RR SingleReg:$v1, SingleReg:$v0)>;
}
defm : VECSBFXPAT<v8i8, (i32 1), SBFX2BOrr,  SBFX2BOri,  v8_splat>, Requires<[IsV2]>;
defm : VECSBFXPAT<v8i8, (i32 2), SBFX4BOrr,  SBFX4BOri,  v8_splat>, Requires<[IsV2]>;
defm : VECSBFXPAT<v8i8, (i32 3), SBFX8BOrr,  SBFX8BOri,  v8_splat>, Requires<[IsV2]>;
defm : VECSBFXPAT<v8i8, (i32 4), SBFX16BOrr, SBFX16BOri, v8_splat>, Requires<[IsV2]>;

defm : VECSBFXPAT<v4i16, (i32 1), SBFX2HQrr,  SBFX2HQri,  v4_splat>;
defm : VECSBFXPAT<v4i16, (i32 2), SBFX4HQrr,  SBFX4HQri,  v4_splat>;
defm : VECSBFXPAT<v4i16, (i32 3), SBFX8HQrr,  SBFX8HQri,  v4_splat>;
defm : VECSBFXPAT<v4i16, (i32 4), SBFX16HQrr, SBFX16HQri, v4_splat>;

defm : VECSBFXPAT<v2i32, (i32 1), SBFX2WPrr,  SBFX2WPri,  v2_splat>;
defm : VECSBFXPAT<v2i32, (i32 2), SBFX4WPrr,  SBFX4WPri,  v2_splat>;
defm : VECSBFXPAT<v2i32, (i32 3), SBFX8WPrr,  SBFX8WPri,  v2_splat>;
defm : VECSBFXPAT<v2i32, (i32 4), SBFX16WPrr, SBFX16WPri, v2_splat>;

multiclass HQShiftScalarOps <SDNode Op, KVX_INSTRUCTION RI, KVX_INSTRUCTION RR>
{
def : Pat<(Op v2i16:$v, (v2i16 ( v2_splat (i32 imm:$i)))), (RI SingleReg:$v, (mod_16_imm_64 imm:$i))>;
def : Pat<(Op v2i16:$v0, (v2i16 ( v2_splat i32:$v1))), (RR SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(Op v4i16:$v, (v4i16 ( v4_splat (i32 imm:$i)))), (RI SingleReg:$v, (mod_16_imm_64 imm:$i))>;
def : Pat<(Op v4i16:$v0, (v4i16 ( v4_splat i32:$v1))), (RR SingleReg:$v0, SingleReg:$v1)>;

def : Pat<(Op v4i16:$v, (v4i16 ( v3_splat (i32 imm:$i)))), (RI SingleReg:$v, (mod_16_imm_64 imm:$i))>;
def : Pat<(Op v4i16:$v0, (v4i16 (v3_splat i32:$v1))), (RR SingleReg:$v0, SingleReg:$v1)>;

def : Pat<(Op v2i16:$v, (v2i16 ( build_vector (i32 imm:$i0), (i32 imm:$i1)))),
      (INSF (RI SingleReg:$v, (mod_16_imm_64 imm:$i1)), (RI SingleReg:$v, (mod_16_imm_64 imm:$i0)), 15, 0)>;

def : Pat<(Op v2i16:$v, (v2i16 ( build_vector (i32 i32:$s0), (i32 i32:$s1)))),
      (INSF (RR SingleReg:$v, SingleReg:$s1), (RR SingleReg:$v, SingleReg:$s0), 15, 0)>;

def : Pat<(Op v2i16:$v0, v2i16:$v1),
      (INSF(RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 19, 16)), (RR SingleReg:$v0, SingleReg:$v1), 15, 0) >;

// We can detect when some immediates are the same, and avoid all insf operations.
def : Pat<(Op v4i16:$v, (v4i16 ( build_vector (i32 imm:$i0), (i32 imm:$i1), (i32 imm:$i2), (i32 undef)))),
                  (INSF (RI SingleReg:$v, (mod_16_imm_64 imm:$i2)),
                        (INSF (RI SingleReg:$v, (mod_16_imm_64 imm:$i1)),
                              (RI SingleReg:$v, (mod_16_imm_64 imm:$i0)),
                              15, 0),
                        31, 0)>;

def : Pat<(Op v4i16:$v, (v4i16 ( build_vector (i32 i32:$s0), (i32 i32:$s1), (i32 i32:$s2), (i32 undef)))),
            (INSF (RR SingleReg:$v, SingleReg:$s2),
                        (INSF (RR SingleReg:$v, SingleReg:$s1),
                              (RR SingleReg:$v, SingleReg:$s0),
                              15, 0),
                        31, 0)>;

def : Pat<(Op v4i16:$v, (v4i16 ( build_vector (i32 imm:$i0), (i32 imm:$i1), (i32 imm:$i2), (i32 imm:$i3)))),
            (INSF (RI SingleReg:$v, (mod_16_imm_64 imm:$i3)),
                  (INSF (RI SingleReg:$v, (mod_16_imm_64 imm:$i2)),
                        (INSF (RI SingleReg:$v, (mod_16_imm_64 imm:$i1)),
                              (RI SingleReg:$v, (mod_16_imm_64 imm:$i0)),
                              15, 0),
                        31, 0),
                  47, 0)>;

def : Pat<(Op v4i16:$v, (v4i16 ( build_vector (i32 i32:$s0), (i32 i32:$s1), (i32 i32:$s2), (i32 i32:$s3)))),
            (INSF (RR SingleReg:$v, SingleReg:$s3),
                  (INSF (RR SingleReg:$v, SingleReg:$s2),
                        (INSF (RR SingleReg:$v, SingleReg:$s1),
                              (RR SingleReg:$v, SingleReg:$s0),
                              15, 0),
                        31, 0),
                  47, 0)>;

def : Pat<(Op v4i16:$v0, v4i16:$v1),
            (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 51, 48)),
                  (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 35, 32)),
                        (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 19, 16)),
                              (RR SingleReg:$v0, $v1),
                              15, 0),
                        31, 0),
                  47, 0)>;
}

multiclass BOShiftScalarOps <SDNode Op, KVX_INSTRUCTION RI, KVX_INSTRUCTION RR>
{
def : Pat<(Op v2i8:$v, (v2i8 ( v2_splat (i32 imm:$i)))), (RI SingleReg:$v, (mod_8_imm_64 imm:$i))>;
def : Pat<(Op v2i8:$v0, (v2i8 ( v2_splat i32:$v1))), (RR SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(Op v4i8:$v, (v4i8 ( v4_splat (i32 imm:$i)))), (RI SingleReg:$v, (mod_8_imm_64 imm:$i))>;
def : Pat<(Op v4i8:$v0, (v4i8 ( v4_splat i32:$v1))), (RR SingleReg:$v0, SingleReg:$v1)>;
def : Pat<(Op v8i8:$v, (v8i8 ( v8_splat (i32 imm:$i)))), (RI SingleReg:$v, (mod_8_imm_64 imm:$i))>;
def : Pat<(Op v8i8:$v0, (v8i8 ( v8_splat i32:$v1))), (RR SingleReg:$v0, SingleReg:$v1)>;

def : Pat<(Op v4i8:$v, (v4i8 ( v3_splat (i32 imm:$i)))), (RI SingleReg:$v, (mod_8_imm_64 imm:$i))>;
def : Pat<(Op v4i8:$v0, (v4i8 (v3_splat i32:$v1))), (RR SingleReg:$v0, SingleReg:$v1)>;

def : Pat<(Op v2i8:$v, (v2i8 ( build_vector (i32 imm:$i0), (i32 imm:$i1)))),
      (INSF (RI SingleReg:$v, (mod_8_imm_64 imm:$i1)), (RI SingleReg:$v, (mod_8_imm_64 imm:$i0)), 7, 0)>;

def : Pat<(Op v2i8:$v, (v2i8 ( build_vector (i32 i32:$s0), (i32 i32:$s1)))),
      (INSF (RR SingleReg:$v, SingleReg:$s1), (RR SingleReg:$v, SingleReg:$s0), 7, 0)>;

def : Pat<(Op v2i8:$v0, v2i8:$v1),
      (INSF(RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 10, 8)), (RR SingleReg:$v0, SingleReg:$v1), 7, 0) >;

// We can detect when some immediates are the same, and avoid all insf operations.
def : Pat<(Op v4i8:$v, (v4i8 ( build_vector (i32 imm:$i0), (i32 imm:$i1), (i32 imm:$i2), (i32 undef)))),
                  (INSF (RI SingleReg:$v, (mod_8_imm_64 imm:$i2)),
                        (INSF (RI SingleReg:$v, (mod_8_imm_64 imm:$i1)),
                              (RI SingleReg:$v, (mod_8_imm_64 imm:$i0)),
                              7, 0),
                        15, 0)>;

def : Pat<(Op v4i8:$v, (v4i8 ( build_vector (i32 i32:$s0), (i32 i32:$s1), (i32 i32:$s2), (i32 undef)))),
            (INSF (RR SingleReg:$v, SingleReg:$s2),
                        (INSF (RR SingleReg:$v, SingleReg:$s1),
                              (RR SingleReg:$v, SingleReg:$s0),
                              7, 0),
                        15, 0)>;

def : Pat<(Op v4i8:$v, (v4i8 ( build_vector (i32 imm:$i0), (i32 imm:$i1), (i32 imm:$i2), (i32 imm:$i3)))),
            (INSF (RI SingleReg:$v, (mod_8_imm_64 imm:$i3)),
                  (INSF (RI SingleReg:$v, (mod_8_imm_64 imm:$i2)),
                        (INSF (RI SingleReg:$v, (mod_8_imm_64 imm:$i1)),
                              (RI SingleReg:$v, (mod_8_imm_64 imm:$i0)),
                              7, 0),
                        15, 0),
                  23, 0)>;

def : Pat<(Op v4i8:$v, (v4i8 ( build_vector (i32 i32:$s0), (i32 i32:$s1), (i32 i32:$s2), (i32 i32:$s3)))),
            (INSF (RR SingleReg:$v, SingleReg:$s3),
                  (INSF (RR SingleReg:$v, SingleReg:$s2),
                        (INSF (RR SingleReg:$v, SingleReg:$s1),
                              (RR SingleReg:$v, SingleReg:$s0),
                              7, 0),
                        15, 0),
                  23, 0)>;

def : Pat<(Op v4i8:$v0, v4i8:$v1),
            (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 26, 24)),
                  (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 18, 16)),
                        (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 10, 8)),
                              (RR SingleReg:$v0, $v1),
                              7, 0),
                        15, 0),
                  23, 0)>;

def : Pat<(Op v8i8:$v0, v8i8:$v1),
            (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 58, 56)),
                  (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 50, 48)),
                        (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 42, 40)),
                              (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 34, 32)),
                                    (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 26, 24)),
                                          (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 18, 16)),
                                                (INSF (RR SingleReg:$v0, (EXTFZ SingleReg:$v1, 10, 8)),
                                                      (RR SingleReg:$v0, $v1),
                                                7, 0),
                                          15, 0),
                                    23, 0),
                              31, 0),
                        39, 0),
                  47, 0),
            55, 0)>;
}

// SLLD
def : Pat<(shl i64:$rs1, i64:$rs2), (SLLDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(shl i64:$rs1, Unsigned6:$rs2), (SLLDri SingleReg:$rs1, Unsigned6:$rs2)>;

// SLLBOS
defm : BOShiftScalarOps<shl, SLLBOSri, SLLBOSrr>, Requires<[IsV2]>;

// SLLHQS
defm : HQShiftScalarOps<shl, SLLHQSri, SLLHQSrr>;

// SLLW
defm : ZEFPat<(shl i32:$rs1, i64:$rs2), (SLLWrr SingleReg:$rs1, SingleReg:$rs2)>;
defm : ZEFPat<(shl i32:$rs1, Unsigned6:$rs2), (SLLWri SingleReg:$rs1, Unsigned6:$rs2)>;

// SLLWPS
defm : WPShiftScalarOps<shl, SLLWPSri, SLLWPSrr, SLLWri, SLLWrr>;

// SLSBOS
defm : BOShiftScalarOps<sshlsat, SLSBOSri, SLSBOSrr>, Requires<[IsV2]>;

// SLSD
def : Pat<(i64 (sshlsat i64:$r, Unsigned6:$im)),
          (SLSDri SingleReg:$r, Unsigned6:$im)>;

def : Pat<(i64 (sshlsat i64:$rs1, i64:$rs2)),
          (SLSDrr SingleReg:$rs1, SingleReg:$rs2)>;

// SLSHQS
defm : HQShiftScalarOps<sshlsat, SLSHQSri, SLSHQSrr>;

// SLSW
defm : ZEFPat<(i32 (sshlsat i32:$r, Unsigned6W:$im)),
              (SLSWri SingleReg:$r, (imm32_to_imm64 imm:$im))>;

defm : ZEFPat<(i32 (sshlsat i32:$rs1, i32:$rs2)),
              (SLSWrr SingleReg:$rs1, SingleReg:$rs2)>;

// SLSWPS
defm: WPShiftScalarOps<sshlsat, SLSWPSri, SLSWPSrr, SLSWri, SLSWrr>;

// SLUSBOS
defm : BOShiftScalarOps<ushlsat, SLUSBOSri, SLUSBOSrr>, Requires<[IsV2]>;

// SLUSD
def : Pat<(i64 (ushlsat i64:$r, Unsigned6:$im)),
          (SLUSDri SingleReg:$r, Unsigned6:$im)>, Requires<[IsV2]>;

def : Pat<(i64 (ushlsat i64:$rs1, i64:$rs2)),
          (SLUSDrr SingleReg:$rs1, SingleReg:$rs2)>, Requires<[IsV2]>;

// SLUSHQS
defm : HQShiftScalarOps<ushlsat, SLUSHQSri, SLUSHQSrr>;

// SLUSW
defm : ZEFPat<(i32 (ushlsat i32:$r, Unsigned6W:$im)),
              (SLUSWri SingleReg:$r, (imm32_to_imm64 imm:$im))>, Requires<[IsV2]>;

defm : ZEFPat<(i32 (ushlsat i32:$rs1, i32:$rs2)),
              (SLUSWrr SingleReg:$rs1, SingleReg:$rs2)>, Requires<[IsV2]>;

defm : ZEFPat<(i32 (ushlsat i32:$r, Unsigned6W:$im)),
              (MINUDri37 (SLLDri (ZXWD SingleReg:$r), (imm32_to_imm64 imm:$im)), i64_ui32_max)>;

defm : ZEFPat<(i32 (ushlsat i32:$rs1, i32:$rs2)),
              (MINUDri37 (SLLDrr (ZXWD SingleReg:$rs1), SingleReg:$rs2), i64_ui32_max)>;

// SLUSWPS
defm: WPShiftScalarOps<ushlsat, SLUSWPSri, SLUSWPSrr, SLUSWri, SLUSWrr>, Requires<[IsV2]>;

// SRAD
def : Pat<(sra i64:$rs1, i64:$rs2), (SRADrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sra i64:$rs1, Unsigned6:$rs2), (SRADri SingleReg:$rs1, Unsigned6:$rs2)>;

// SRABOS
defm : BOShiftScalarOps<sra, SRABOSri, SRABOSrr>, Requires<[IsV2]>;

// SRAHQS
defm : HQShiftScalarOps<sra, SRAHQSri, SRAHQSrr>;

// SRAW
def : Pat<(sra i32:$rs1, i64:$rs2), (SRAWrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(sra i32:$rs1, Unsigned6:$rs2), (SRAWri SingleReg:$rs1, Unsigned6:$rs2)>;

// SRAWPS
defm : WPShiftScalarOps<sra, SRAWPSri, SRAWPSrr, SRAWri, SRAWrr>;

// SRLD
def : Pat<(srl i64:$rs1, i64:$rs2), (SRLDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(srl i64:$rs1, Unsigned6:$rs2), (SRLDri SingleReg:$rs1, Unsigned6:$rs2)>;

// SRLBOS
defm : BOShiftScalarOps<srl, SRLBOSri, SRLBOSrr>, Requires<[IsV2]>;

// SRLHQS
defm : HQShiftScalarOps<srl, SRLHQSri, SRLHQSrr>;

// SRLW
defm : ZEFPat<(srl i32:$rs1, i64:$rs2), (SRLWrr SingleReg:$rs1, SingleReg:$rs2)>;
defm : ZEFPat<(srl i32:$rs1, Unsigned6:$rs2), (SRLWri SingleReg:$rs1, Unsigned6:$rs2)>;

// SRLWPS
defm : WPShiftScalarOps<srl, SRLWPSri, SRLWPSrr, SRLWri, SRLWrr>;

multiclass SRS <ValueType vt, KVX_INSTRUCTION I, KVX_INSTRUCTION NEG> {
      def : Pat<(vt (KVX_srs vt:$r, Unsigned6:$im)),
                (I SingleReg:$r, Unsigned6:$im)>;

      def : Pat<(vt (KVX_srsneg vt:$r, Unsigned6:$im)),
                (NEG (I SingleReg:$r, Unsigned6:$im))>;
}

// SRSBOS
foreach vt = [v2i8, v4i8, v8i8] in {
defm : SRS <vt, SRSBOSri, NEGBO>, Requires<[IsV2]>;
}

// SRSD
defm : SRS <i64, SRSDri, NEGD>;

// SRSHQS
foreach vt = [v2i16, v4i16] in {
defm : SRS <vt, SRSHQSri, NEGHQ>;
}

// SRSW
defm : SRS <i32, SRSWri, NEGW>;

// SRSWPS
defm : SRS <v2i32, SRSWPSri, NEGWP>;

// SXLBHQ
def : Pat<(v2i16(sanyext v2i8:$v)), (SXLBHQ $v)>;
def : Pat<(v2i16(zext v2i8:$v)), (SBMM8ri37 $v, 0x020001)>;

def : Pat<(v4i16(sanyext v4i8:$v)), (SXLBHQ $v)>;
def : Pat<(v4i16(zext v4i8:$v)), (SBMM8ri64 $v, 0x08000400020001)>;
def : Pat<(v4i16(sanyext (v4i8( extract_subvector v8i8:$v, (i64 0))))), (SXLBHQ $v)>;
def : Pat<(v4i16(zext (v4i8( extract_subvector v8i8:$v, (i64 0))))), (SBMM8ri64 $v, 0x08000400020001)>;

// SXLHWP
def : Pat<(v2i32(sext v2i8:$v)), (SXLHWP(SXLBHQ $v))>;
def : Pat<(v2i32(zanyext v2i8:$v)), (SBMM8ri37 $v, 0x200000001)>;
def : Pat<(v2i32(sanyext v2i16:$v)), (SXLHWP $v)>;
def : Pat<(v2i32(zext v2i16:$v)), (SBMM8ri64 $v, 0x80400000201)>;

// SXLHWP + SXLBHQ + SXMHWP + SXMBHQ
def : Pat<(v4i32(sext (v4i8( extract_subvector v8i8:$v, (i64 4))))), (REG_SEQUENCE PairedReg, (SXLHWP(SXMBHQ $v)), sub_s0, (SXMHWP(SXMBHQ $v)), sub_s1)>;
def : Pat<(v4i32(zanyext (v4i8( extract_subvector v8i8:$v, (i64 4))))), (REG_SEQUENCE PairedReg, (SBMM8ri64 $v, 0x2000000010), sub_s0,
                                                          (SBMM8ri64 $v, 0x8000000040), sub_s1)>;

def : Pat<(v4i32(sext (v4i8( extract_subvector v8i8:$v, (i64 0))))), (REG_SEQUENCE PairedReg, (SXLHWP(SXLBHQ $v)), sub_s0, (SXMHWP(SXLBHQ $v)), sub_s1)>;
def : Pat<(v4i32(zanyext (v4i8( extract_subvector v8i8:$v, (i64 0))))), (REG_SEQUENCE PairedReg, (SBMM8ri37 $v, 0x200000001), sub_s0,
                                                          (SBMM8ri37 $v, 0x800000004), sub_s1)>;

def : Pat<(v4i32(sext v4i8:$v)), (REG_SEQUENCE PairedReg, (SXLHWP(SXLBHQ $v)), sub_s0, (SXMHWP(SXLBHQ $v)), sub_s1)>;
def : Pat<(v4i32(zanyext v4i8:$v)), (REG_SEQUENCE PairedReg, (SBMM8ri37 $v, 0x200000001), sub_s0,
                                                          (SBMM8ri37 $v, 0x800000004), sub_s1)>;

def : Pat<(v4i32(sanyext v4i16:$v)), (REG_SEQUENCE PairedReg, (SXMHWP $v), sub_s1, (SXLHWP $v), sub_s0)>;
def : Pat<(v4i32(zext v4i16:$v)), (REG_SEQUENCE PairedReg, (SBMM8ri64 $v, 0x80400000201), sub_s0,
                                                           (SBMM8ri64 $v, 0x804000002010), sub_s1)>;
// SXMBHQ
def : Pat<(v4i16(sanyext (v4i8( extract_subvector v8i8:$v, (i64 4))))), (SXMBHQ $v)>;
def : Pat<(v4i16(zext (v4i8( extract_subvector v8i8:$v, (i64 4))))), (SBMM8ri64 $v, 0x80004000200010)>;

// XORD
def : Pat<(xor i64:$rs1, i64:$rs2), (XORDrr SingleReg:$rs1, SingleReg:$rs2)>;
def : Pat<(xor i64:$rs1, Signed10:$rs2), (XORDri10 SingleReg:$rs1, Signed10:$rs2)>;
def : Pat<(xor i64:$rs1, Signed37:$rs2), (XORDri37 SingleReg:$rs1, Signed37:$rs2)>;
def : Pat<(xor i64:$rs1, Wrapped64:$rs2), (XORDri64 SingleReg:$rs1, Wrapped64:$rs2)>;

foreach vtype = [ v8i8, v4i16, v2i32 ] in {
    def : Pat<(xor vtype:$rs1, (vtype (is_imm_vec:$IMM))), (XORDri64 SingleReg:$rs1, (build_imm_vec $IMM))>;
    def : Pat<(xor vtype:$rs1, vtype:$rs2), (XORDrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// XORW
defm : ZEFPat<(xor i32:$rs1, i32:$rs2), (XORWrr SingleReg:$rs1, SingleReg:$rs2)>;
defm : ZEFPat<(xor i32:$rs1, Signed10W:$rs2), (XORWri10 SingleReg:$rs1, Signed10W:$rs2)>;
defm : ZEFPat<(xor i32:$rs1, Signed37W:$rs2), (XORWri37 SingleReg:$rs1, Signed37W:$rs2)>;

foreach vtype = [ v2i8, v4i8, v2i16 ] in {
    def : Pat<(xor vtype:$rs1, (vtype (is_imm_vec:$IMM))), (XORWri37 SingleReg:$rs1, (build_imm_vec $IMM))>;
    def : Pat<(xor vtype:$rs1, vtype:$rs2), (XORWrr SingleReg:$rs1, SingleReg:$rs2)>;
}

// Sign/Zero/Any extensions to v2i64
def : Pat<(v2i64(sext v2i8:$v)), (v2i64 (REG_SEQUENCE PairedReg, (SXBD $v), sub_s0, (EXTFS $v, 15, 8), sub_s1))>;
def : Pat<(v2i64(zanyext v2i8:$v)), (v2i64 (REG_SEQUENCE PairedReg, (ZXBD $v), sub_s0, (EXTFZ $v, 15, 8), sub_s1))>;
def : Pat<(v2i64(sext v2i16:$v)), (v2i64 (REG_SEQUENCE PairedReg, (SXHD $v), sub_s0, (EXTFS $v, 31, 16), sub_s1))>;
def : Pat<(v2i64(zanyext v2i16:$v)), (v2i64 (REG_SEQUENCE PairedReg, (ZXHD $v), sub_s0, (EXTFZ $v, 31, 16), sub_s1))>;
def : Pat<(v2i64(sext v2i32:$v)), (v2i64 (REG_SEQUENCE PairedReg, (SXWD $v), sub_s0, (EXTFS $v, 63, 32), sub_s1))>;
def : Pat<(v2i64(zanyext v2i32:$v)), (v2i64 (REG_SEQUENCE PairedReg, (ZXWD $v), sub_s0, (EXTFZ $v, 63, 32), sub_s1))>;

def : Pat<(add v8i8:$v1, v8i8:$v2),
      (XORDrr
            (ADDDrr
                  (ANDDri64 SingleReg:$v1, 0x7f7f7f7f7f7f7f7f),
                  (ANDDri64 SingleReg:$v2, 0x7f7f7f7f7f7f7f7f)
            ),
            (ANDDri64
                  (XORDrr
                        SingleReg:$v1, SingleReg:$v2
                  ),
                  0x8080808080808080
            )
      )>;

def : Pat<(sub v8i8:$v1, v8i8:$v2),
      (XORDrr
            (ANDDri64
                  (NXORDrr SingleReg:$v1, SingleReg:$v2),
                  0x8080808080808080
            ),
            (SBFDrr
                  (ANDDri64 SingleReg:$v2, 0x7f7f7f7f7f7f7f7f),
                  (ORDri64 SingleReg:$v1, 0x8080808080808080)
            )
      )>;

def : Pat<(abs v8i8:$v),
      (INSF
            (SBMM8ri37 (ABSHQ (SXLBHQ SingleReg:$v)), 0x40100401),
            (SBMM8ri37 (ABSHQ (SXMBHQ SingleReg:$v)), 0x40100401),
      32, 63)>;

def : Pat<(v8i8(shl v8i8:$v, (v8i8 (v8_splat i32:$s)))),
          (ORDrr
            (ANDDri64
                  (SLLDrr
                        (ANDDri64 SingleReg:$v, 0xff00ff00ff00ff00),
                  SingleReg:$s),
            0xff00ff00ff00ff00),
            (ANDDri64
                  (SLLDrr
                        (ANDDri64 SingleReg:$v, 0xff00ff00ff00ff),
                  SingleReg:$s),
            0xff00ff00ff00ff))>;


def : Pat<(v8i8(srl v8i8:$v, (v8i8 (v8_splat i32:$s)))),
          (ORDrr
            (ANDDri64
                  (SRLDrr
                        (ANDDri64 SingleReg:$v, 0xff00ff00ff00ff00),
                  SingleReg:$s),
            0xff00ff00ff00ff00),
            (ANDDri64
                  (SRLDrr
                        (ANDDri64 SingleReg:$v, 0xff00ff00ff00ff),
                  SingleReg:$s),
            0xff00ff00ff00ff))>;

def : Pat<(v8i8(or (srl v8i8:$v, (v8i8 (v8_splat (i32 (sub (i32 8), i32:$s)))) ), (shl v8i8:$v, (v8i8 (v8_splat i32:$s))))),
          (ORDrr
            (ANDDri64
                  (SLLHQSrr
                        (SBMM8ri64 SingleReg:$v, 0x8080202008080202),
                  SingleReg:$s),
            0xff00ff00ff00ff00),
            (SRLHQSri
                  (SLLHQSrr
                        (SBMM8ri64 SingleReg:$v, 0x4040101004040101),
                  SingleReg:$s),
            8))>;

def : Pat<(v8i8(rotl v8i8:$v, (v8i8 (v8_splat i32:$s)))),
          (ORDrr
            (ANDDri64
                  (SLLHQSrr
                        (SBMM8ri64 SingleReg:$v, 0x8080202008080202),
                  SingleReg:$s),
            0xff00ff00ff00ff00),
            (SRLHQSri
                  (SLLHQSrr
                        (SBMM8ri64 SingleReg:$v, 0x4040101004040101),
                  SingleReg:$s),
            8))>;

def : Pat<(v8i8(or (shl v8i8:$v, (v8i8 (v8_splat (i32 (sub (i32 8), i32:$s)))) ), (srl v8i8:$v, (v8i8 (v8_splat i32:$s))))),
          (ORDrr
            (ANDNDri64
                  (SRLHQSrr
                        (SBMM8ri64 SingleReg:$v, 0x4040101004040101),
                  SingleReg:$s),
            0xff00ff00ff00ff00),
            (SLLHQSri
                  (SRLHQSrr
                        (SBMM8ri64 SingleReg:$v, 0x8080202008080202),
                  SingleReg:$s),
            8))>;

def : Pat<(v8i8(rotr v8i8:$v, (v8i8 (v8_splat i32:$s)))),
          (ORDrr
            (ANDNDri64
                  (SRLHQSrr
                        (SBMM8ri64 SingleReg:$v, 0x4040101004040101),
                  SingleReg:$s),
            0xff00ff00ff00ff00),
            (SLLHQSri
                  (SRLHQSrr
                        (SBMM8ri64 SingleReg:$v, 0x8080202008080202),
                  SingleReg:$s),
            8))>;

// LOR between v2i32 elements
def : Pat<(i32 (setne (or (extractelt v2i32:$v, 0), (extractelt v2i32:$v, 1)), 0)),
          (COMPDri10 SingleReg:$v, 0, comparison_ne)>;
