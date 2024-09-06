//===- X86.cpp ------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "ABIInfoImpl.h"
#include "TargetInfo.h"
// #include "clang/Basic/DiagnosticFrontend.h"
// #include "llvm/ADT/SmallBitVector.h"

using namespace clang;
using namespace clang::CodeGen;

namespace {
class KVXABIInfo : public DefaultABIInfo {
public:
  KVXABIInfo(CodeGenTypes &CGT) : DefaultABIInfo(CGT) {}

  void computeInfo(CGFunctionInfo &FI) const override;

  Address EmitVAArg(CodeGenFunction &CGF, Address VAListAddr, QualType Ty) const
      override;

private:
  static const unsigned Alignment;
  static const unsigned RegSize;
  static const unsigned NumRegs;
  ABIArgInfo classifyType(QualType Ty) const;
  ABIArgInfo classifyBigType(QualType Ty) const;

  // Coercion type builder for structs passed in registers. The coercion type
  // serves one purpose:
  //
  // 1. Pad structs to a multiple of 64 bits, so they are passed 'left-aligned'
  //    in registers.
  //
  struct CoerceBuilder {
    llvm::LLVMContext &Context;
    const llvm::DataLayout &DL;
    SmallVector<llvm::Type *, 4> Elems;
    uint64_t Size;

    CoerceBuilder(llvm::LLVMContext &c, const llvm::DataLayout &dl)
        : Context(c), DL(dl), Size(0) {}

    // Pad Elems with integers until Size is ToSize.
    void pad(uint64_t ToSize) {
      assert(ToSize >= Size && "Cannot remove elements");
      if (ToSize == Size)
        return;

      // Finish the current alignment-bit word.
      uint64_t Aligned = llvm::alignTo(Size, Alignment);
      if (Aligned > Size && Aligned <= ToSize) {
        Elems.push_back(llvm::IntegerType::get(Context, Aligned - Size));
        Size = Aligned;
      }

      // Add whole alignment-bit words.
      while (Size + Alignment <= ToSize) {
        Elems.push_back(llvm::Type::getInt64Ty(Context));
        Size += Alignment;
      }
    }

    // Add a struct type to the coercion type, starting at Offset (in bits).
    void addStruct(uint64_t Offset, llvm::StructType *StrTy) {
      const llvm::StructLayout *Layout = DL.getStructLayout(StrTy);
      for (unsigned i = 0, e = StrTy->getNumElements(); i != e; ++i) {
        llvm::Type *ElemTy = StrTy->getElementType(i);
        uint64_t ElemOffset = Offset + Layout->getElementOffsetInBits(i);
        switch (ElemTy->getTypeID()) {
        case llvm::Type::StructTyID:
          addStruct(ElemOffset, cast<llvm::StructType>(ElemTy));
          break;
        case llvm::Type::PointerTyID:
          if (ElemOffset % Alignment == 0) {
            pad(ElemOffset);
            Elems.push_back(ElemTy);
            Size += Alignment;
          }
          break;
        default:
          break;
        }
      }
    }

    // Check if Ty is a usable substitute for the coercion type.
    bool isUsableType(llvm::StructType *Ty) const {
      return llvm::ArrayRef(Elems) == Ty->elements();
    }

    // Get the coercion type as a literal struct type.
    llvm::Type *getType() const {
      if (Elems.size() == 1)
        return Elems.front();

      return llvm::StructType::get(Context, Elems);
    }
  };
};
} // end anonymous namespace

namespace {
class KVXTargetCodeGenInfo : public TargetCodeGenInfo {
public:
  KVXTargetCodeGenInfo(CodeGen::CodeGenTypes &CGT)
      : TargetCodeGenInfo(std::make_unique<KVXABIInfo>(CGT)) {}
};
} // end anonymous namespace

std::unique_ptr<TargetCodeGenInfo>
CodeGen::createKVXTargetCodeGenInfo(CodeGenModule &CGM) {
  return std::make_unique<KVXTargetCodeGenInfo>(CGM.getTypes());
}

const unsigned KVXABIInfo::Alignment = 64;
const unsigned KVXABIInfo::RegSize = 64;
const unsigned KVXABIInfo::NumRegs = 4;

void KVXABIInfo::computeInfo(CGFunctionInfo &FI) const {
  if (!getCXXABI().classifyReturnType(FI))
    FI.getReturnInfo() = classifyBigType(FI.getReturnType());

  for (auto &I : FI.arguments())
    I.info = classifyBigType(I.type);
}

Address KVXABIInfo::EmitVAArg(CodeGenFunction &CGF, Address VAListAddr,
                              QualType Ty) const {
  CharUnits SlotSize = CharUnits::fromQuantity(8);

  if (getContext().getTypeSize(Ty) > RegSize * NumRegs) {
    auto TInfo = getContext().getTypeInfoInChars(Ty);
    return emitVoidPtrVAArg(CGF, VAListAddr, Ty, /*Indirect=*/true, TInfo,
                            SlotSize, /*AllowHigherAlign=*/false);
  }

  ABIArgInfo AI = classifyType(Ty);
  llvm::Type *ArgTy = CGT.ConvertType(Ty);
  if (AI.canHaveCoerceToType() && !AI.getCoerceToType())
    AI.setCoerceToType(ArgTy);

  CGBuilderTy &Builder = CGF.Builder;
  Address CurPtr = Address(Builder.CreateLoad(VAListAddr, "ap.cur"),
                         getVAListElementType(CGF), SlotSize);
  Address EltAddress = Address(CurPtr.getBasePointer(), ArgTy, SlotSize);

  auto AllocSize = getDataLayout().getTypeAllocSize(AI.getCoerceToType());
  CharUnits Stride = CharUnits::fromQuantity(AllocSize).alignTo(SlotSize);

  Address NextPtr = Builder.CreateConstInBoundsByteGEP(CurPtr, Stride, "ap.next");
  Builder.CreateStore(NextPtr.getBasePointer(), VAListAddr);

  return EltAddress;
}

ABIArgInfo KVXABIInfo::classifyBigType(QualType Ty) const {
  // Anything too big to fit in registers is passed with an explicit indirect
  // pointer / sret pointer.
  if (getContext().getTypeSize(Ty) > RegSize * NumRegs)
    return getNaturalAlignIndirect(Ty, /*ByVal=*/false);

  return classifyType(Ty);
}

ABIArgInfo KVXABIInfo::classifyType(QualType Ty) const {
  if (Ty->isVoidType())
    return ABIArgInfo::getIgnore();

  // C++ non-trivially-copyable structures/classes are passed by
  // reference
  if (!Ty.isTriviallyCopyableType(getContext()))
    return DefaultABIInfo::classifyArgumentType(Ty);

  // Treat an enum type as its underlying type.
  if (const EnumType *EnumTy = Ty->getAs<EnumType>())
    Ty = EnumTy->getDecl()->getIntegerType();

  // Other non-aggregates go in registers.
  if (!isAggregateTypeForABI(Ty))
    return ABIArgInfo::getDirect();

  // This is a small aggregate type that should be passed in registers.
  // Build a coercion type from the LLVM struct type.
  llvm::StructType *StrTy = dyn_cast<llvm::StructType>(CGT.ConvertType(Ty));
  if (!StrTy)
    return ABIArgInfo::getDirect();

  CoerceBuilder CB(getVMContext(), getDataLayout());
  CB.addStruct(0, StrTy);
  CB.pad(llvm::alignTo(CB.DL.getTypeSizeInBits(StrTy), Alignment));

  // Try to use the original type for coercion.
  llvm::Type *CoerceTy = CB.isUsableType(StrTy) ? StrTy : CB.getType();

  return ABIArgInfo::getDirect(CoerceTy);
}
