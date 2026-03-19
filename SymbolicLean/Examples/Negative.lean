import SymbolicLean

open SymbolicLean

/--
error: failed to synthesize instance of type class
  HMul (Term (SymSort.matrix (DomainDesc.ground GroundDom.QQ) (Dim.static 2) (Dim.static 2)))
    (Term (SymSort.matrix (DomainDesc.ground GroundDom.QQ) (Dim.static 3) (Dim.static 1))) ?m.30

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
-/
#guard_msgs in
example : Term (.matrix (.ground .QQ) (.static 2) (.static 1)) :=
  let A : SymDecl (.matrix (.ground .QQ) (.static 2) (.static 2)) := { name := `A }
  let v : SymDecl (.matrix (.ground .QQ) (.static 3) (.static 1)) := { name := `v }
  term![A * v]

/--
error: failed to synthesize instance of type class
  InterpretsField (DomainDesc.ground GroundDom.ZZ)

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
-/
#guard_msgs in
example {s : SessionTok} (matrix : SymExpr s (.matrix (.ground .ZZ) (.static 2) (.static 2))) :
    SymPyM s (SymExpr s (.matrix (.ground .ZZ) (.static 2) (.static 2))) :=
  inv matrix

/--
error: Application type mismatch: The last
  x
argument has type
  Term (SymSort.scalar (DomainDesc.ground GroundDom.ZZ))
but is expected to have type
  SymDecl (SymSort.scalar ?m.7)
in the application
  @diff (SymSort.scalar (DomainDesc.ground GroundDom.ZZ)) ?m.7 x x
-/
#guard_msgs in
example : Term (.scalar (.ground .ZZ)) :=
  let x : Term (.scalar (.ground .ZZ)) := (1 : Term (.scalar (.ground .ZZ)))
  diff x x
