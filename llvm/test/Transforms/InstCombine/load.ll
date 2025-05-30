; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=instcombine -S < %s | FileCheck %s

target datalayout = "e-m:e-p:64:64:64-i64:64-f80:128-n8:16:32:64-S128-ni:1"

@X = constant i32 42		; <ptr> [#uses=2]
@X2 = constant i32 47		; <ptr> [#uses=1]
@Y = constant [2 x { i32, float }] [ { i32, float } { i32 12, float 1.000000e+00 }, { i32, float } { i32 37, float 0x3FF3B2FEC0000000 } ]		; <ptr> [#uses=2]
@Z = constant [2 x { i32, float }] zeroinitializer		; <ptr> [#uses=1]

@GLOBAL = internal constant [4 x i32] zeroinitializer


define i32 @test1() {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i32 42
;
  %B = load i32, ptr @X		; <i32> [#uses=1]
  ret i32 %B
}

define float @test2() {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    ret float 0x3FF3B2FEC0000000
;
  %A = getelementptr [2 x { i32, float }], ptr @Y, i64 0, i64 1, i32 1		; <ptr> [#uses=1]
  %B = load float, ptr %A		; <float> [#uses=1]
  ret float %B
}

define i32 @test3() {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    ret i32 12
;
  %A = getelementptr [2 x { i32, float }], ptr @Y, i64 0, i64 0, i32 0		; <ptr> [#uses=1]
  %B = load i32, ptr %A		; <i32> [#uses=1]
  ret i32 %B
}

define i32 @test4() {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    ret i32 0
;
  %A = getelementptr [2 x { i32, float }], ptr @Z, i64 0, i64 1, i32 0		; <ptr> [#uses=1]
  %B = load i32, ptr %A		; <i32> [#uses=1]
  ret i32 %B
}

define i32 @test5(i1 %C) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[Z:%.*]] = select i1 [[C:%.*]], i32 42, i32 47
; CHECK-NEXT:    ret i32 [[Z]]
;
  %Y = select i1 %C, ptr @X, ptr @X2		; <ptr> [#uses=1]
  %Z = load i32, ptr %Y		; <i32> [#uses=1]
  ret i32 %Z
}

; FIXME: Constants should be allowed for this optimization.
define i32 @test5_asan(i1 %C) sanitize_address {
; CHECK-LABEL: @test5_asan(
; CHECK-NEXT:    [[Y:%.*]] = select i1 [[C:%.*]], ptr @X, ptr @X2
; CHECK-NEXT:    [[Z:%.*]] = load i32, ptr [[Y]], align 4
; CHECK-NEXT:    ret i32 [[Z]]
;
  %Y = select i1 %C, ptr @X, ptr @X2		; <ptr> [#uses=1]
  %Z = load i32, ptr %Y		; <i32> [#uses=1]
  ret i32 %Z
}

define i32 @load_gep_null_inbounds(i64 %X) {
; CHECK-LABEL: @load_gep_null_inbounds(
; CHECK-NEXT:    store i1 true, ptr poison, align 1
; CHECK-NEXT:    ret i32 poison
;
  %V = getelementptr inbounds i32, ptr null, i64 %X
  %R = load i32, ptr %V
  ret i32 %R
}

define i32 @load_gep_null_not_inbounds(i64 %X) {
; CHECK-LABEL: @load_gep_null_not_inbounds(
; CHECK-NEXT:    store i1 true, ptr poison, align 1
; CHECK-NEXT:    ret i32 poison
;
  %V = getelementptr i32, ptr null, i64 %X
  %R = load i32, ptr %V
  ret i32 %R
}

define i32 @test7_no_null_opt(i32 %X) #0 {
; CHECK-LABEL: @test7_no_null_opt(
; CHECK-NEXT:    [[TMP1:%.*]] = sext i32 [[X:%.*]] to i64
; CHECK-NEXT:    [[V:%.*]] = getelementptr i32, ptr null, i64 [[TMP1]]
; CHECK-NEXT:    [[R:%.*]] = load i32, ptr [[V]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %V = getelementptr i32, ptr null, i32 %X               ; <ptr> [#uses=1]
  %R = load i32, ptr %V          ; <i32> [#uses=1]
  ret i32 %R
}
attributes #0 = { null_pointer_is_valid }

define i32 @test8(ptr %P) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    store i32 1, ptr [[P:%.*]], align 4
; CHECK-NEXT:    ret i32 1
;
  store i32 1, ptr %P
  %X = load i32, ptr %P		; <i32> [#uses=1]
  ret i32 %X
}

define i32 @test9(ptr %P) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    ret i32 0
;
  %X = load i32, ptr %P		; <i32> [#uses=1]
  %Y = load i32, ptr %P		; <i32> [#uses=1]
  %Z = sub i32 %X, %Y		; <i32> [#uses=1]
  ret i32 %Z
}

define i32 @test10(i1 %C.upgrd.1, ptr %P, ptr %Q) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    br i1 [[C_UPGRD_1:%.*]], label [[T:%.*]], label [[F:%.*]]
; CHECK:       T:
; CHECK-NEXT:    store i32 1, ptr [[Q:%.*]], align 4
; CHECK-NEXT:    br label [[C:%.*]]
; CHECK:       F:
; CHECK-NEXT:    br label [[C]]
; CHECK:       C:
; CHECK-NEXT:    store i32 0, ptr [[P:%.*]], align 4
; CHECK-NEXT:    ret i32 0
;
  br i1 %C.upgrd.1, label %T, label %F
T:		; preds = %0
  store i32 1, ptr %Q
  store i32 0, ptr %P
  br label %C
F:		; preds = %0
  store i32 0, ptr %P
  br label %C
C:		; preds = %F, %T
  %V = load i32, ptr %P		; <i32> [#uses=1]
  ret i32 %V
}

define double @test11(ptr %p) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[T0:%.*]] = getelementptr i8, ptr [[P:%.*]], i64 8
; CHECK-NEXT:    store double 2.000000e+00, ptr [[T0]], align 8
; CHECK-NEXT:    ret double 2.000000e+00
;
  %t0 = getelementptr double, ptr %p, i32 1
  store double 2.0, ptr %t0
  %t1 = getelementptr double, ptr %p, i32 1
  %x = load double, ptr %t1
  ret double %x
}

define i32 @test12(ptr %P) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    ret i32 123
;
  %A = alloca i32
  store i32 123, ptr %A
  ; Cast the result of the load not the source
  %V = load i32, ptr %A
  ret i32 %V
}

define <16 x i8> @test13(<2 x i64> %x) {
; CHECK-LABEL: @test13(
; CHECK-NEXT:    ret <16 x i8> zeroinitializer
;
  %tmp = load <16 x i8>, ptr @GLOBAL
  ret <16 x i8> %tmp
}

; This test must not have the store of %x forwarded to the load -- there is an
; intervening store if %y. However, the intervening store occurs with a different
; type and size and to a different pointer value. This is ensuring that none of
; those confuse the analysis into thinking that the second store does not alias
; the first.

define i8 @test14(i8 %x, i32 %y) {
; CHECK-LABEL: @test14(
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i8 [[X:%.*]], ptr [[A]], align 1
; CHECK-NEXT:    store i32 [[Y:%.*]], ptr [[A]], align 4
; CHECK-NEXT:    [[R:%.*]] = load i8, ptr [[A]], align 1
; CHECK-NEXT:    ret i8 [[R]]
;
  %a = alloca i32
  store i8 %x, ptr %a
  store i32 %y, ptr %a
  %r = load i8, ptr %a
  ret i8 %r
}

@test15_global = external global i32

; Same test as @test14 essentially, but using a global instead of an alloca.

define i8 @test15(i8 %x, i32 %y) {
; CHECK-LABEL: @test15(
; CHECK-NEXT:    store i8 [[X:%.*]], ptr @test15_global, align 1
; CHECK-NEXT:    store i32 [[Y:%.*]], ptr @test15_global, align 4
; CHECK-NEXT:    [[R:%.*]] = load i8, ptr @test15_global, align 1
; CHECK-NEXT:    ret i8 [[R]]
;
  store i8 %x, ptr @test15_global
  store i32 %y, ptr @test15_global
  %r = load i8, ptr @test15_global
  ret i8 %r
}

; Check that we canonicalize loads which are only stored to use integer types
; when there is a valid integer type.

define void @test16(ptr %x, ptr %a, ptr %b, ptr %c) {
; CHECK-LABEL: @test16(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X1:%.*]] = load float, ptr [[X:%.*]], align 4
; CHECK-NEXT:    store float [[X1]], ptr [[A:%.*]], align 4
; CHECK-NEXT:    store float [[X1]], ptr [[B:%.*]], align 4
; CHECK-NEXT:    [[X2:%.*]] = load float, ptr [[X]], align 4
; CHECK-NEXT:    store float [[X2]], ptr [[B]], align 4
; CHECK-NEXT:    store float [[X2]], ptr [[C:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:

  %x1 = load float, ptr %x
  store float %x1, ptr %a
  store float %x1, ptr %b

  %x2 = load float, ptr %x
  store float %x2, ptr %b
  %x2.cast = bitcast float %x2 to i32
  store i32 %x2.cast, ptr %c

  ret void
}

define void @test16-vect(ptr %x, ptr %a, ptr %b, ptr %c) {
; CHECK-LABEL: @test16-vect(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X1:%.*]] = load <4 x i8>, ptr [[X:%.*]], align 4
; CHECK-NEXT:    store <4 x i8> [[X1]], ptr [[A:%.*]], align 4
; CHECK-NEXT:    store <4 x i8> [[X1]], ptr [[B:%.*]], align 4
; CHECK-NEXT:    [[X2:%.*]] = load <4 x i8>, ptr [[X]], align 4
; CHECK-NEXT:    store <4 x i8> [[X2]], ptr [[B]], align 4
; CHECK-NEXT:    store <4 x i8> [[X2]], ptr [[C:%.*]], align 4
; CHECK-NEXT:    ret void
;
entry:

  %x1 = load <4 x i8>, ptr %x
  store <4 x i8> %x1, ptr %a
  store <4 x i8> %x1, ptr %b

  %x2 = load <4 x i8>, ptr %x
  store <4 x i8> %x2, ptr %b
  %x2.cast = bitcast <4 x i8> %x2 to i32
  store i32 %x2.cast, ptr %c

  ret void
}


; Check that in cases similar to @test16 we don't try to rewrite a load when
; its only use is a store but it is used as the pointer to that store rather
; than the value.

define void @test17(ptr %x, i8 %y) {
; CHECK-LABEL: @test17(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X_LOAD:%.*]] = load ptr, ptr [[X:%.*]], align 8
; CHECK-NEXT:    store i8 [[Y:%.*]], ptr [[X_LOAD]], align 1
; CHECK-NEXT:    ret void
;
entry:
  %x.load = load ptr, ptr %x
  store i8 %y, ptr %x.load

  ret void
}

; Check that we don't try change the type of the load by inserting a bitcast
; generating invalid IR.
%swift.error = type opaque
declare void @useSwiftError(ptr swifterror)

define void @test18(ptr swifterror %err) {
; CHECK-LABEL: @test18(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SWIFTERROR:%.*]] = alloca swifterror ptr, align 8
; CHECK-NEXT:    store ptr null, ptr [[SWIFTERROR]], align 8
; CHECK-NEXT:    call void @useSwiftError(ptr nonnull swifterror [[SWIFTERROR]])
; CHECK-NEXT:    [[ERR_RES:%.*]] = load ptr, ptr [[SWIFTERROR]], align 8
; CHECK-NEXT:    store ptr [[ERR_RES]], ptr [[ERR:%.*]], align 8
; CHECK-NEXT:    ret void
;
entry:
  %swifterror = alloca swifterror ptr, align 8
  store ptr null, ptr %swifterror, align 8
  call void @useSwiftError(ptr nonnull swifterror %swifterror)
  %err.res = load ptr, ptr %swifterror, align 8
  store ptr %err.res, ptr %err, align 8
  ret void
}

; Make sure we preseve the type of the store to a swifterror pointer.

declare void @initi8(ptr)
define void @test19(ptr swifterror %err) {
; CHECK-LABEL: @test19(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP:%.*]] = alloca ptr, align 8
; CHECK-NEXT:    call void @initi8(ptr nonnull [[TMP]])
; CHECK-NEXT:    [[ERR_RES:%.*]] = load ptr, ptr [[TMP]], align 8
; CHECK-NEXT:    store ptr [[ERR_RES]], ptr [[ERR:%.*]], align 8
; CHECK-NEXT:    ret void
;
entry:
  %tmp = alloca ptr, align 8
  call void @initi8(ptr %tmp)
  %err.res = load ptr, ptr %tmp, align 8
  store ptr %err.res, ptr %err, align 8
  ret void
}

; Make sure we don't canonicalize accesses to scalable vectors.
define void @test20(ptr %x, ptr %y) {
; CHECK-LABEL: @test20(
; CHECK-NEXT:    [[X_LOAD:%.*]] = load <vscale x 4 x i8>, ptr [[X:%.*]], align 1
; CHECK-NEXT:    store <vscale x 4 x i8> [[X_LOAD]], ptr [[Y:%.*]], align 1
; CHECK-NEXT:    ret void
;
  %x.load = load <vscale x 4 x i8>, ptr %x, align 1
  store <vscale x 4 x i8> %x.load, ptr %y, align 1
  ret void
}


; Check that non-integral pointers are not coverted using inttoptr

declare void @use(ptr)
declare void @use.p1(ptr addrspace(1))

define i64 @test21(ptr %P) {
; CHECK-LABEL: @test21(
; CHECK-NEXT:    [[X:%.*]] = load i64, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[Y_CAST:%.*]] = inttoptr i64 [[X]] to ptr
; CHECK-NEXT:    call void @use(ptr [[Y_CAST]])
; CHECK-NEXT:    ret i64 [[X]]
;
  %X = load i64, ptr %P
  %Y = load ptr, ptr %P
  call void @use(ptr %Y)
  ret i64 %X
}

define i64 @test22(ptr %P) {
; CHECK-LABEL: @test22(
; CHECK-NEXT:    [[X:%.*]] = load i64, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[Y:%.*]] = load ptr addrspace(1), ptr [[P]], align 8
; CHECK-NEXT:    call void @use.p1(ptr addrspace(1) [[Y]])
; CHECK-NEXT:    ret i64 [[X]]
;
  %X = load i64, ptr %P
  %Y = load ptr addrspace(1), ptr %P
  call void @use.p1(ptr addrspace(1) %Y)
  ret i64 %X
}

declare void @use.v2.p0(<2 x ptr>)
declare void @use.v2.p1(<2 x ptr addrspace(1)>)

define <2 x i64> @test23(ptr %P) {
; CHECK-LABEL: @test23(
; CHECK-NEXT:    [[X:%.*]] = load <2 x i64>, ptr [[P:%.*]], align 16
; CHECK-NEXT:    [[Y:%.*]] = load <2 x ptr>, ptr [[P]], align 16
; CHECK-NEXT:    call void @use.v2.p0(<2 x ptr> [[Y]])
; CHECK-NEXT:    ret <2 x i64> [[X]]
;
  %X = load <2 x i64>, ptr %P
  %Y = load <2 x ptr>, ptr %P
  call void @use.v2.p0(<2 x ptr> %Y)
  ret <2 x i64> %X
}

define <2 x i64> @test24(ptr %P) {
; CHECK-LABEL: @test24(
; CHECK-NEXT:    [[X:%.*]] = load <2 x i64>, ptr [[P:%.*]], align 16
; CHECK-NEXT:    [[Y:%.*]] = load <2 x ptr addrspace(1)>, ptr [[P]], align 16
; CHECK-NEXT:    call void @use.v2.p1(<2 x ptr addrspace(1)> [[Y]])
; CHECK-NEXT:    ret <2 x i64> [[X]]
;
  %X = load <2 x i64>, ptr %P
  %Y = load <2 x ptr addrspace(1)>, ptr %P
  call void @use.v2.p1(<2 x ptr addrspace(1)> %Y)
  ret <2 x i64> %X
}

define i16 @load_from_zero_with_dynamic_offset(i64 %idx) {
; CHECK-LABEL: @load_from_zero_with_dynamic_offset(
; CHECK-NEXT:    ret i16 0
;
  %gep = getelementptr i16, ptr @GLOBAL, i64 %idx
  %v = load i16, ptr %gep
  ret i16 %v
}

declare ptr @llvm.strip.invariant.group.p0(ptr %p)

define i32 @load_via_strip_invariant_group() {
; CHECK-LABEL: @load_via_strip_invariant_group(
; CHECK-NEXT:    ret i32 37
;
  %a = call ptr @llvm.strip.invariant.group.p0(ptr @Y)
  %b = getelementptr i8, ptr %a, i64 8
  %d = load i32, ptr %b
  ret i32 %d
}

; TODO: For non-byte-sized vectors, current implementation assumes there is
; padding to the next byte boundary between elements.
@foo = constant <2 x i4> <i4 u0x1, i4 u0x2>, align 8

define i4 @test_vector_load_i4_non_byte_sized() {
; CHECK-LABEL: @test_vector_load_i4_non_byte_sized(
; CHECK-NEXT:    [[RES0:%.*]] = load i4, ptr @foo, align 1
; CHECK-NEXT:    ret i4 [[RES0]]
;
  %ptr0 = getelementptr i8, ptr @foo, i64 0
  %res0 = load i4, ptr %ptr0, align 1
  ret i4 %res0
}

define i32 @load_select_with_null_gep(i1 %cond, ptr %p, i64 %off) {
; CHECK-LABEL: @load_select_with_null_gep(
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i8, ptr [[SEL:%.*]], i64 [[OFF:%.*]]
; CHECK-NEXT:    [[RES:%.*]] = load i32, ptr [[GEP]], align 4
; CHECK-NEXT:    ret i32 [[RES]]
;
  %sel = select i1 %cond, ptr %p, ptr null
  %gep = getelementptr i8, ptr %sel, i64 %off
  %res = load i32, ptr %gep, align 4
  ret i32 %res
}

define i16 @load_select_with_null_gep2(i1 %cond, ptr %p, i64 %x) {
; CHECK-LABEL: @load_select_with_null_gep2(
; CHECK-NEXT:    [[INVARIANT_GEP:%.*]] = getelementptr i8, ptr [[SEL:%.*]], i64 -2
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i16, ptr [[INVARIANT_GEP]], i64 [[X:%.*]]
; CHECK-NEXT:    [[RES:%.*]] = load i16, ptr [[GEP]], align 2
; CHECK-NEXT:    ret i16 [[RES]]
;
  %sel = select i1 %cond, ptr %p, ptr null
  %invariant.gep = getelementptr i8, ptr %sel, i64 -2
  %gep = getelementptr i16, ptr %invariant.gep, i64 %x
  %res = load i16, ptr %gep, align 2
  ret i16 %res
}

define i16 @load_select_with_null_gep3(i1 %cond, ptr %p, i64 %x, i64 %y) {
; CHECK-LABEL: @load_select_with_null_gep3(
; CHECK-NEXT:    [[INVARIANT_GEP:%.*]] = getelementptr i8, ptr [[SEL:%.*]], i64 -2
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i16, ptr [[INVARIANT_GEP]], i64 [[X:%.*]]
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr i16, ptr [[GEP]], i64 [[Y:%.*]]
; CHECK-NEXT:    [[RES:%.*]] = load i16, ptr [[GEP2]], align 2
; CHECK-NEXT:    ret i16 [[RES]]
;
  %sel = select i1 %cond, ptr %p, ptr null
  %invariant.gep = getelementptr i8, ptr %sel, i64 -2
  %gep = getelementptr i16, ptr %invariant.gep, i64 %x
  %gep2 = getelementptr i16, ptr %gep, i64 %y
  %res = load i16, ptr %gep2, align 2
  ret i16 %res
}

define i32 @test_load_phi_with_select(ptr %p, i1 %cond1) {
; CHECK-LABEL: @test_load_phi_with_select(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP_BODY:%.*]]
; CHECK:       loop.body:
; CHECK-NEXT:    [[TARGET:%.*]] = getelementptr inbounds nuw i8, ptr [[BASE:%.*]], i64 24
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, ptr [[TARGET]], align 4
; CHECK-NEXT:    [[COND21:%.*]] = icmp eq i32 [[LOAD]], 0
; CHECK-NEXT:    br i1 [[COND21]], label [[LOOP_BODY]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 [[LOAD]]
;
entry:
  br label %loop.body

loop.body:
  %base = phi ptr [ %p, %entry ], [ %sel, %loop.body ]
  %target = getelementptr inbounds i8, ptr %base, i64 24
  %load = load i32, ptr %target, align 4
  %sel = select i1 %cond1, ptr null, ptr %p
  %cond2 = icmp eq i32 %load, 0
  br i1 %cond2, label %loop.body, label %exit

exit:
  ret i32 %load
}
