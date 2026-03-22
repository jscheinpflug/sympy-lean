import SymbolicLean

open SymbolicLean

/--
error: failed to synthesize instance of type class
  HMul (SymDecl (Mat ℚ 2 2)) (SymDecl (Vec ℚ 3)) ?m.16

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
-/
#guard_msgs in
example : Term (Vec Rat 2) :=
  let A : SymDecl (Mat Rat 2 2) := sym `A
  let v : SymDecl (Vec Rat 3) := sym `v
  A * v

/--
error: failed to synthesize instance of type class
  InterpretsField (carrierDomain ℤ)

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
-/
#guard_msgs in
example {s : SessionTok} (matrix : SymExpr s (Mat Int 2 2)) :
    SymPyM s (SymExpr s (Mat Int 2 2)) :=
  inv matrix

/--
error: Application type mismatch: The last
  x
argument has type
  Term (Scalar ℤ)
but is expected to have type
  SymDecl (SymSort.scalar ?m.6)
in the application
  @diff (Scalar ℤ) ?m.6 x x
-/
#guard_msgs in
example : Term (Scalar Int) :=
  let x : Term (Scalar Int) := zz 1
  diff x x

/--
error: Unknown identifier `term!`
-/
#guard_msgs in
#check term!

/--
error: Application type mismatch: The argument
  DomainDesc.ground GroundDom.QQ
has type
  DomainDesc
of sort `Type` but is expected to have type
  Type
of sort `Type 1` in the application
  @Scalar (DomainDesc.ground GroundDom.QQ)
-/
#guard_msgs in
#eval do
  let result ← withSession {} fun _s => do
    symbols (x : DomainDesc.ground GroundDom.QQ)
    let _xTerm : Term (Scalar Rat) := x
    pure ()
  pure ()

/--
error: failed to synthesize instance of type class
  OfNat (Term (Scalar ℝ)) 2
numerals are polymorphic in Lean, but the numeral `2` cannot be used in a context where the expected type is
  Term (Scalar ℝ)
due to the absence of the instance above

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
-/
#guard_msgs in
example : Term (Scalar Real) := 2

/--
warning: `#sympy` falling back to an undefined scalar function for unresolved qualified head `Foo.bar`
---
info: Foo̅.(x)
-/
#guard_msgs in
#sympy Rat => Foo.bar x

-- Startup should fail immediately if the worker replies with the wrong protocol version.
#eval do
  let result ←
    withSession { workerPath := some "tools/bad_protocol_worker.py" } fun _s => do
      let _ ← pingWorker
      pure ()
  match result with
  | .error (.protocol (.invalidResponse message)) =>
      if message = s!"worker protocol version mismatch: expected {protocolVersion}, got 999" then
        pure ()
      else
        throw <| IO.userError s!"unexpected protocol mismatch message: {message}"
  | other =>
      throw <| IO.userError s!"expected protocol version mismatch, got {repr other}"

-- Startup should also fail immediately if the worker manifest version is stale.
#eval do
  let result ←
    withSession { workerPath := some "tools/bad_manifest_worker.py" } fun _s => do
      let _ ← pingWorker
      pure ()
  match result with
  | .error (.protocol (.invalidResponse message)) =>
      if message = s!"worker manifest version mismatch: expected {manifestVersion}, got 999" then
        pure ()
      else
        throw <| IO.userError s!"unexpected manifest mismatch message: {message}"
  | other =>
      throw <| IO.userError s!"expected manifest version mismatch, got {repr other}"
