; RUN: llc -o - %s | FileCheck %s --implicit-check-not=call --implicit-check-not='$ra'
target triple = "kvx-kalray-cos"

define i8 @nofp() #0 {
  %1 = tail call i64 @foo(i32 noundef 0) #2
  %2 = trunc i64 %1 to i8
  ret i8 %2
}

define i32 @nofp128() #0 {
  %1 = tail call i128 @bar() #2
  %2 = trunc i128 %1 to i32
  ret i32 %2
}

; CHECK: {{.*}}
declare i64 @foo(i32 noundef) local_unnamed_addr #1
declare i128 @bar() local_unnamed_addr #1

attributes #0 = { convergent mustprogress nofree norecurse nounwind willreturn memory(none) "approx-func-fp-math"="true" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #1 = { convergent mustprogress nofree nounwind willreturn memory(none) "approx-func-fp-math"="true" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #2 = { convergent nounwind willreturn memory(none) }

