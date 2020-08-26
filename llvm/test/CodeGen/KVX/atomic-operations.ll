; RUN: llc --asm-verbose=false < %s -mtriple=kvx-kalray-cos | FileCheck %s

; Tests for atomic_fence operations
define i64 @thread_fence(i64 %0) {
  fence release
  ret i64 %0
  ; CHECK-LABEL: thread_fence:
  ; CHECK: fence
  ; CHECK: ret
}

define i64 @signal_fence(i64 %0) {
  fence syncscope("singlethread") acquire
  ret i64 %0
  ; CHECK-LABEL: signal_fence:
  ; CHECK-NOT: fence
  ; CHECK: ret
}


; Tests for atomic_swap operations
define i64 @atomicrmw_i64_xchg(i64* %ptr, i64 %c, i64 %s) {
  %res = atomicrmw xchg i64* %ptr, i64 %c release
  ret i64 %res
  ; CHECK-LABEL: atomicrmw_i64_xchg:
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: ld.u $[[EXPECTED:r[0-9]+]] = 0[$r0]
  ; CHECK: copyd [[DESIRED:\$r[0-9]+]] = $r1
  ; CHECK: acswapd 0[$r0] = [[DESIRED]][[EXPECTED]]
  ; CHECK: cb.even [[DESIRED]] ? [[LABEL]]
  ; CHECK: copyd $r0 = $[[EXPECTED]]
  ; CHECK-NEXT: fence
  ; CHECK-NEXT: ret
}

define i32 @atomicrmw_i32_xchg(i32* %ptr, i32 %c, i32 %s) {
  %res = atomicrmw xchg i32* %ptr, i32 %c monotonic
  ret i32 %res
  ; CHECK-LABEL: atomicrmw_i32_xchg:
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: lwz.u $[[EXPECTED:r[0-9]+]] = 0[$r0]
  ; CHECK-NEXT: copyw [[DESIRED:\$r[0-9]+]] = $r1
  ; CHECK: acswapw 0[$r0] = [[DESIRED]][[EXPECTED]]
  ; CHECK: cb.even [[DESIRED]] ? [[LABEL]]
  ; CHECK: copyw $r0 = $[[EXPECTED]]
  ; CHECK-NEXT: ret
}

define i64 @atomicrmw_i64_xchg_as(i64 addrspace(1)* %ptr, i64 %c, i64 %s) {
  %res = atomicrmw xchg i64 addrspace(1)* %ptr, i64 %c seq_cst
  ret i64 %res
  ; CHECK-LABEL: atomicrmw_i64_xchg_as:
  ; CHECK: call __kvx_atomic_global_in
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: ld.u $[[EXPECTED:r[0-9]+]] = 0[$r19]
  ; CHECK: copyd [[DESIRED:\$r[0-9]+]] = $r18
  ; CHECK: acswapd 0[$r19] = [[DESIRED]][[EXPECTED]]
  ; CHECK: cb.even [[DESIRED]] ? [[LABEL]]
  ; CHECK: copyd $r18 = $[[EXPECTED]]
  ; CHECK: call __kvx_atomic_global_out
  ; CHECK: ret
}

define i8 @atomic_test_and_set(i8* %ptr) {
  %res = atomicrmw xchg i8* %ptr, i8 1 seq_cst
  %tobool = icmp ne i8 %res, 0
  %conv = zext i1 %tobool to i8
  ret i8 %conv
  ; CHECK-LABEL: atomic_test_and_set:
  ; CHECK: fence
  ; CHECK-NEXT: make [[ONE:\$r[0-9]+]] = 1
  ; CHECK-NEXT: andd [[POS:\$r[0-9]+]] = $r0, 3
  ; CHECK: sbfd [[OFFSET:\$r[0-9]+]] = [[POS]], 0
  ; CHECK-NEXT: slld [[POS]] = [[POS]], 3
  ; CHECK: [[CSLOOP:.LBB[0-9_]+]]
  ; CHECK-NEXT: lwz.u $[[EXPECTED:r[0-9]+]] = [[OFFSET]][$r0]
  ; CHECK: srlw [[OUTPUT:\$r[0-9]+]] = $[[EXPECTED]], [[POS]]
  ; CHECK-NEXT: sllw [[MASK:\$r[0-9]+]] = [[ONE]], [[POS]]
  ; CHECK: andw [[OUTPUT]] = [[OUTPUT]], 255
  ; CHECK-NEXT: orw [[DESIRED:\$r[0-9]+]] = $[[EXPECTED]], [[MASK]]
  ; CHECK: cb.wnez [[OUTPUT]] ? [[DONE:.LBB[0-9_]+]]
  ; CHECK: acswapw [[OFFSET]][$r0] = [[DESIRED]][[EXPECTED]]
  ; CHECK: cb.even [[DESIRED]] ? [[CSLOOP]]
  ; CHECK: [[DONE]]
  ; CHECK: fence
  ; CHECK: ret
}


; Tests for atomic_cmp_swap operations
define i64 @cmpxchg_i64(i64* %ptr, i64 %c, i64 %s) {
  %cx = cmpxchg i64* %ptr, i64 %c, i64 %s seq_cst seq_cst
  %res = extractvalue { i64, i1 } %cx, 0
  ret i64 %res
  ; CHECK-LABEL= cmpxchg_i64:
  ; CHECK: fence
  ; CHECK-NEXT: copyd $[[EXPECTED:r[0-9]+]] = $r1
  ; CHECK: [[CSLOOP:.LBB[0-9_]+]]
  ; CHECK: copyd [[DESIRED:\$r[0-9]+]] = $r2
  ; CHECK: acswapd 0[$r0] = [[DESIRED]][[EXPECTED]]
  ; CHECK: cb.odd [[DESIRED]] ? [[PASS:.LBB[0-9_]+]]
  ; CHECK: ld.u [[OUTPUT:\$r[0-9]+]] = 0[$r0]
  ; CHECK: compd.eq [[DESIRED]] = [[OUTPUT]], $[[EXPECTED]]
  ; CHECK: cb.odd [[DESIRED]] ? [[CSLOOP]]
  ; CHECK: goto [[DONE:.LBB[0-9_]+]]
  ; CHECK: [[PASS]]
  ; CHECK: copyd [[OUTPUT]] = $[[EXPECTED]]
  ; CHECK: [[DONE]]
  ; CHECK: copyd $r0 = [[OUTPUT]]
  ; CHECK: ret
}


; Tests for atomic_load operations
define i8 @atomic_load_i8(i8 *%ptr) {
  %res = load atomic i8, i8 *%ptr monotonic, align 1 ; i.e. relaxed
  ret i8 %res
  ; CHECK-LABEL: atomic_load_i8:
  ; CHECK: lbz.u $r0 = 0[$r0]
  ; CHECK-NEXT: ret
}

define i16 @atomic_load_i16(i16 *%ptr) {
  %res = load atomic i16, i16 *%ptr seq_cst, align 2
  ret i16 %res
  ; CHECK-LABEL: atomic_load_i16:
  ; CHECK: fence
  ; CHECK: lhz.u $r0 = 0[$r0]
  ; CHECK: fence
  ; CHECK-NEXT: ret
}

define i32 @atomic_load_i32(i32 addrspace(1)*%ptr) {
  %res = load atomic i32, i32 addrspace(1)*%ptr seq_cst, align 4
  ret i32 %res
  ; CHECK-LABEL: atomic_load_i32:
  ; CHECK: call __kvx_atomic_global_in
  ; CHECK: lwz.u $r18 = 0[$r18]
  ; CHECK: call __kvx_atomic_global_out
  ; CHECK: ret
}


; Tests for atomic_store operations
define void @atomic_store_i32(i32* %ptr, i32 %l) {
entry:
  store atomic i32 %l, i32* %ptr release, align 4
  ret void
  ; CHECK-LABEL: atomic_store_i32:
  ; CHECK: sw 0[$r0] = $r1
  ; CHECK: fence
  ; CHECK-NEXT: ret
}

define void @atomic_store_i64(i64 addrspace(1)* %ptr, i64 %l) {
entry:
  store atomic i64 %l, i64 addrspace(1)* %ptr release, align 8
  ret void
  ; CHECK-LABEL: atomic_store_i64:
  ; CHECK: call __kvx_atomic_global_in
  ; CHECK: sd 0[$r19] = $r18
  ; CHECK: call __kvx_atomic_global_out
  ; CHECK: ret
}


; Tests for atomic rmw operations
define i8 @atomicrmw_i8_min(i8 *%src, i8 %b) {
  %res = atomicrmw min i8 *%src, i8 %b seq_cst
  ret i8 %res
  ; CHECK-LABEL: atomicrmw_i8_min:
  ; CHECK: __sync_fetch_and_min_1
  ; CHECK: ret
}

define i64 @atomicrmw_i64_max(i64 *%src, i64 %b) {
  %res = atomicrmw max i64 *%src, i64 %b seq_cst
  ret i64 %res
  ; CHECK-LABEL: atomicrmw_i64_max:
  ; CHECK: fence
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: ld.u $[[EXPECTED:r[0-9]+]] = 0[$r0]
  ; CHECK: maxd [[MAX:\$r[0-9]+]] = $r1, $[[EXPECTED]]
  ; CHECK: acswapd 0[$r0] = [[MAX]][[EXPECTED]]
  ; CHECK: cb.even [[MAX]] ? [[LABEL]]
  ; CHECK: copyd $r0 = $[[EXPECTED]]
  ; CHECK-NEXT: fence
  ; CHECK-NEXT: ret
}

define i64 @atomicrmw_i64_add(i64 *%src, i64 %b) {
  %res = atomicrmw add i64 *%src, i64 %b release
  ret i64 %res
  ; CHECK-LABEL: atomicrmw_i64_add:
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: ld.u $[[EXPECTED:r[0-9]+]] = 0[$r0]
  ; CHECK: addd [[MAX:\$r[0-9]+]] = $r1, $[[EXPECTED]]
  ; CHECK: acswapd 0[$r0] = [[MAX]][[EXPECTED]]
  ; CHECK: cb.even [[MAX]] ? [[LABEL]]
  ; CHECK: copyd $r0 = $[[EXPECTED]]
  ; CHECK-NEXT: fence
  ; CHECK-NEXT: ret
}

define i64 @atomicrmw_i64_sub(i64 *%src, i64 %b) {
  %res = atomicrmw sub i64 *%src, i64 %b release
  ret i64 %res
  ; CHECK-LABEL: atomicrmw_i64_sub:
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: ld.u $[[EXPECTED:r[0-9]+]] = 0[$r0]
  ; CHECK: sbfd [[MAX:\$r[0-9]+]] = $r1, $[[EXPECTED]]
  ; CHECK: acswapd 0[$r0] = [[MAX]][[EXPECTED]]
  ; CHECK: cb.even [[MAX]] ? [[LABEL]]
  ; CHECK: copyd $r0 = $[[EXPECTED]]
  ; CHECK-NEXT: fence
  ; CHECK-NEXT: ret
}

define i64 @atomicrmw_i64_nand(i64 *%src, i64 %b) {
  %res = atomicrmw nand i64 *%src, i64 %b release
  ret i64 %res
  ; CHECK-LABEL: atomicrmw_i64_nand:
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: ld.u $[[EXPECTED:r[0-9]+]] = 0[$r0]
  ; CHECK: nandd [[MAX:\$r[0-9]+]] = $r1, $[[EXPECTED]]
  ; CHECK: acswapd 0[$r0] = [[MAX]][[EXPECTED]]
  ; CHECK: cb.even [[MAX]] ? [[LABEL]]
  ; CHECK: copyd $r0 = $[[EXPECTED]]
  ; CHECK-NEXT: fence
  ; CHECK-NEXT: ret
}

define i32 @atomicrmw_i32_xor(i32 *%src, i32 %b) {
  %res = atomicrmw xor i32 *%src, i32 %b release
  ret i32 %res
  ; CHECK-LABEL: atomicrmw_i32_xor:
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: lwz.u $[[EXPECTED:r[0-9]+]] = 0[$r0]
  ; CHECK: xorw [[MAX:\$r[0-9]+]] = $r1, $[[EXPECTED]]
  ; CHECK: acswapw 0[$r0] = [[MAX]][[EXPECTED]]
  ; CHECK: cb.even [[MAX]] ? [[LABEL]]
  ; CHECK: copyw $r0 = $[[EXPECTED]]
  ; CHECK-NEXT: fence
  ; CHECK-NEXT: ret
}

; Test for __global OpenCL AS
define i64 @atomicrmw_i64_sub_global_as(i64 addrspace(1)*%src, i64 %b) {
  %res = atomicrmw sub i64 addrspace(1)*%src, i64 %b release
  ret i64 %res
  ; CHECK-LABEL: atomicrmw_i64_sub_global_as:
  ; CHECK: copyd [[R1:\$r[0-9]+]] = $r1
  ; CHECK: copyd $[[R0:r[0-9]+]] = $r0
  ; CHECK: call __kvx_atomic_global_in
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: ld.u $[[EXPECTED:r[0-9]+]] = 0[$[[R0]]]
  ; CHECK: sbfd [[MAX:\$r[0-9]+]] = [[R1]], $[[EXPECTED]]
  ; CHECK: acswapd 0[$[[R0]]] = [[MAX]][[EXPECTED]]
  ; CHECK: cb.even [[MAX]] ? [[LABEL]]
  ; CHECK: copyd [[RES:\$r[0-9]+]] = $[[EXPECTED]]
  ; CHECK: call __kvx_atomic_global_out
  ; CHECK: copyd $r0 = [[RES]]
  ; CHECK: ret
}


; Test for immediates that doesn't hold on 37 bits
define i64 @bigimm(i64* %0, i64 %1) {
  %3 = getelementptr inbounds i64, i64* %0, i64 549755813888
  %4 = atomicrmw add i64* %3, i64 %1 seq_cst
  ret i64 %4
  ; CHECK-LABEL: bigimm:
  ; CHECK: addd $r0 = $r0, 4398046511104
  ; CHECK: [[LABEL:.LBB[0-9_]+]]
  ; CHECK: ld.u $[[EXPECTED:r[0-9]+]] = 0[$r0]
  ; CHECK: addd [[MAX:\$r[0-9]+]] = $r1, $[[EXPECTED]]
  ; CHECK: acswapd 0[$r0] = [[MAX]][[EXPECTED]]
  ; CHECK: cb.even [[MAX]] ? [[LABEL]]
  ; CHECK: copyd $r0 = $[[EXPECTED]]
  ; CHECK: ret
}
