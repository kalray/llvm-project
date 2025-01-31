; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=kvx -O2 -debug-pass=Structure %s -o /dev/null 2>&1 | grep -v "Verify generated machine code" | FileCheck %s

; REQUIRES: asserts
; CHECK: Target Library Information
; CHECK-NEXT: Target Pass Configuration
; CHECK-NEXT: Machine Module Information
; CHECK-NEXT: Target Transform Information
; CHECK-NEXT: Assumption Cache Tracker
; CHECK-NEXT: Type-Based Alias Analysis
; CHECK-NEXT: Scoped NoAlias Alias Analysis
; CHECK-NEXT: Profile summary info
; CHECK-NEXT: Create Garbage Collector Module Metadata
; CHECK-NEXT: Machine Branch Probability Analysis
; CHECK-NEXT: Default Regalloc Eviction Advisor
; CHECK-NEXT: ModulePass Manager
; CHECK-NEXT: Pre-ISel Intrinsic Lowering
; CHECK-NEXT: FunctionPass Manager
; CHECK-NEXT: Expand Atomic instructions
; CHECK-NEXT: Dead Code Elimination
; CHECK-NEXT: Simplify the CFG
; CHECK-NEXT: Module Verifier
; CHECK-NEXT: Dominator Tree Construction
; CHECK-NEXT: Basic Alias Analysis (stateless AA impl)
; CHECK-NEXT: Natural Loop Information
; CHECK-NEXT: Canonicalize natural loops
; CHECK-NEXT: Scalar Evolution Analysis
; CHECK-NEXT: Loop Pass Manager
; CHECK-NEXT: Canonicalize Freeze Instructions in Loops
; CHECK-NEXT: Induction Variable Users
; CHECK-NEXT: Loop Strength Reduction
; CHECK-NEXT: Basic Alias Analysis (stateless AA impl)
; CHECK-NEXT: Function Alias Analysis Results
; CHECK-NEXT: Merge contiguous icmps into a memcmp
; CHECK-NEXT: Natural Loop Information
; CHECK-NEXT: Lazy Branch Probability Analysis
; CHECK-NEXT: Lazy Block Frequency Analysis
; CHECK-NEXT: Expand memcmp() to load/stores
; CHECK-NEXT: Lower Garbage Collection Instructions
; CHECK-NEXT: Shadow Stack GC Lowering
; CHECK-NEXT: Lower constant intrinsics
; CHECK-NEXT: Remove unreachable blocks from the CFG
; CHECK-NEXT: Natural Loop Information
; CHECK-NEXT: Post-Dominator Tree Construction
; CHECK-NEXT: Branch Probability Analysis
; CHECK-NEXT: Block Frequency Analysis
; CHECK-NEXT: Constant Hoisting
; CHECK-NEXT: Replace intrinsics with calls to vector library
; CHECK-NEXT: Partially inline calls to library functions
; CHECK-NEXT: Expand vector predication intrinsics
; CHECK-NEXT: Scalarize Masked Memory Intrinsics
; CHECK-NEXT: Expand reduction intrinsics
; CHECK-NEXT: Natural Loop Information
; CHECK-NEXT: TLS Variable Hoist
; CHECK-NEXT: CodeGen Prepare
; CHECK-NEXT: SJLJ Exception Handling preparation
; CHECK-NEXT: Dominator Tree Construction
; CHECK-NEXT: Exception handling preparation
; CHECK-NEXT: Natural Loop Information
; CHECK-NEXT: Scalar Evolution Analysis
; CHECK-NEXT: Lazy Branch Probability Analysis
; CHECK-NEXT: Lazy Block Frequency Analysis
; CHECK-NEXT: Optimization Remark Emitter
; CHECK-NEXT: Hardware Loop Insertion
; CHECK-NEXT: KVX Hardware loops Prepare
; CHECK-NEXT: KVX CodeGen Prepare
; CHECK-NEXT: Safe Stack instrumentation pass
; CHECK-NEXT: Insert stack protectors
; CHECK-NEXT: Module Verifier
; CHECK-NEXT: Dominator Tree Construction
; CHECK-NEXT: Basic Alias Analysis (stateless AA impl)
; CHECK-NEXT: Function Alias Analysis Results
; CHECK-NEXT: Natural Loop Information
; CHECK-NEXT: Post-Dominator Tree Construction
; CHECK-NEXT: Branch Probability Analysis
; CHECK-NEXT: Lazy Branch Probability Analysis
; CHECK-NEXT: Lazy Block Frequency Analysis
; CHECK-NEXT: KVX DAG->DAG Pattern Instruction Selection
; CHECK-NEXT: Finalize ISel and expand pseudo-instructions
; CHECK-NEXT: Optimize machine instruction PHIs
; CHECK-NEXT: Slot index numbering
; CHECK-NEXT: Merge disjoint stack slots
; CHECK-NEXT: Local Stack Slot Allocation
; CHECK-NEXT: Remove dead machine instructions
; CHECK-NEXT: MachineDominator Tree Construction
; CHECK-NEXT: Machine Natural Loop Construction
; CHECK-NEXT: Machine Block Frequency Analysis
; CHECK-NEXT: Early Machine Loop Invariant Code Motion
; CHECK-NEXT: MachineDominator Tree Construction
; CHECK-NEXT: Machine Block Frequency Analysis
; CHECK-NEXT: Machine Common Subexpression Elimination
; CHECK-NEXT: MachinePostDominator Tree Construction
; CHECK-NEXT: Machine Cycle Info Analysis
; CHECK-NEXT: Machine code sinking
; CHECK-NEXT: Peephole Optimizations
; CHECK-NEXT: Remove dead machine instructions
; CHECK-NEXT: KVX pseudo instruction expansion pass
; CHECK-NEXT: kvx-load-store-packing
; CHECK-NEXT: MachineDominator Tree Construction
; CHECK-NEXT: Machine Natural Loop Construction
; CHECK-NEXT: KVX Hardware loops
; CHECK-NEXT: Detect Dead Lanes
; CHECK-NEXT: Process Implicit Definitions
; CHECK-NEXT: Remove unreachable machine basic blocks
; CHECK-NEXT: Live Variable Analysis
; CHECK-NEXT: MachineDominator Tree Construction
; CHECK-NEXT: Machine Natural Loop Construction
; CHECK-NEXT: Eliminate PHI nodes for register allocation
; CHECK-NEXT: Two-Address instruction pass
; CHECK-NEXT: Slot index numbering
; CHECK-NEXT: Live Interval Analysis
; CHECK-NEXT: Simple Register Coalescing
; CHECK-NEXT: Rename Disconnected Subregister Components
; CHECK-NEXT: Machine Instruction Scheduler
; CHECK-NEXT: Machine Block Frequency Analysis
; CHECK-NEXT: Debug Variable Analysis
; CHECK-NEXT: Live Stack Slot Analysis
; CHECK-NEXT: Virtual Register Map
; CHECK-NEXT: Live Register Matrix
; CHECK-NEXT: Bundle Machine CFG Edges
; CHECK-NEXT: Spill Code Placement Analysis
; CHECK-NEXT: Lazy Machine Block Frequency Analysis
; CHECK-NEXT: Machine Optimization Remark Emitter
; CHECK-NEXT: Greedy Register Allocator
; CHECK-NEXT: Virtual Register Rewriter
; CHECK-NEXT: Register Allocation Pass Scoring
; CHECK-NEXT: Stack Slot Coloring
; CHECK-NEXT: Machine Copy Propagation Pass
; CHECK-NEXT: Machine Loop Invariant Code Motion
; CHECK-NEXT: Remove Redundant DEBUG_VALUE analysis
; CHECK-NEXT: Fixup Statepoint Caller Saved
; CHECK-NEXT: PostRA Machine Sink
; CHECK-NEXT: Machine Block Frequency Analysis
; CHECK-NEXT: MachineDominator Tree Construction
; CHECK-NEXT: MachinePostDominator Tree Construction
; CHECK-NEXT: Lazy Machine Block Frequency Analysis
; CHECK-NEXT: Machine Optimization Remark Emitter
; CHECK-NEXT: Shrink Wrapping analysis
; CHECK-NEXT: Prologue/Epilogue Insertion & Frame Finalization
; CHECK-NEXT: Control Flow Optimizer
; CHECK-NEXT: Lazy Machine Block Frequency Analysis
; CHECK-NEXT: Tail Duplication
; CHECK-NEXT: Machine Copy Propagation Pass
; CHECK-NEXT: Post-RA pseudo instruction expansion pass
; CHECK-NEXT: KVX pseudo instruction expansion pass
; CHECK-NEXT: MachineDominator Tree Construction
; CHECK-NEXT: Machine Natural Loop Construction
; CHECK-NEXT: Machine Block Frequency Analysis
; CHECK-NEXT: If Converter
; CHECK-NEXT: Analyze Machine Code For Garbage Collection
; CHECK-NEXT: MachineDominator Tree Construction
; CHECK-NEXT: Machine Natural Loop Construction
; CHECK-NEXT: Machine Block Frequency Analysis
; CHECK-NEXT: MachinePostDominator Tree Construction
; CHECK-NEXT: Branch Probability Basic Block Placement
; CHECK-NEXT: Insert fentry calls
; CHECK-NEXT: Insert XRay ops
; CHECK-NEXT: Implement the 'patchable-function' attribute
; CHECK-NEXT: KVX pseudo instruction expansion pass
; CHECK-NEXT: Branch relaxation pass
; CHECK-NEXT: MachineDominator Tree Construction
; CHECK-NEXT: Machine Natural Loop Construction
; CHECK-NEXT: PostRA Machine Instruction Scheduler
; CHECK-NEXT: KVX pseudo instruction expansion pass
; CHECK-NEXT: Contiguously Lay Out Funclets
; CHECK-NEXT: StackMap Liveness Analysis
; CHECK-NEXT: Live DEBUG_VALUE analysis
; CHECK-NEXT: Insert CFI remember/restore state instructions
; CHECK-NEXT: Lazy Machine Block Frequency Analysis
; CHECK-NEXT: Machine Optimization Remark Emitter
; CHECK-NEXT: KVX Assembly Printer
; CHECK-NEXT: Free MachineFunction
