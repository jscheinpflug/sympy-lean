import SymbolicLean

open SymbolicLean

private def sameEncodedTerm (lhs rhs : Term σ) : Bool :=
  (encodeTerm lhs).compress == (encodeTerm rhs).compress

-- This module intentionally batches the deeper scalar runtime smoke tests.
-- It is kept separate from `Examples/Scalars.lean` so the main standalone example stays fast.

-- Public scalar runtime surface on one backend session.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)

    let expandExpr : Term (Scalar Rat) := x ^ 2 + 2 * x * y + y ^ 2
    let factored ← factor expandExpr
    let factoredText ← pretty factored

    let fieldExpr : Term (Scalar Rat) := x ^ 2 - 1
    let fieldFactored ← fieldExpr.factor
    let fieldFactoredText ← pretty fieldFactored

    let derived : Term (Scalar Rat) := SymPy.Derivative (x ^ 2) x
    let derivedSimplified ← SymPy.simplify derived
    let derivedText ← pretty derivedSimplified

    let unaryText ← pretty (Smoke.smokeUnary x)
    let binaryText ← pretty (Smoke.smokeBinary x y)

    let realized ← realize (x + 1 : Term (Scalar Rat))
    let sreprText ← Smoke.sreprText realized

    let canceledExpr : Term (Scalar Rat) := (x ^ 2 - 1) / (x - 1)
    let canceled ← cancel canceledExpr
    let canceledText ← pretty canceled

    let divLeftText ← pretty (x / 2 : Term (Scalar Rat))
    let divRightText ← pretty ((1 : Rat) / x : Term (Scalar Rat))

    let substituted ← (x + y)[x ↦ 2, y ↦ 3]
    let substitutedText ← pretty substituted

    pure <| String.intercalate "\n"
      [ s!"factor={factoredText}"
      , s!"fieldFactor={fieldFactoredText}"
      , s!"derivativeSimplify={derivedText}"
      , s!"smokeUnary={unaryText}"
      , s!"smokeBinary={binaryText}"
      , s!"srepr={sreprText}"
      , s!"cancel={canceledText}"
      , s!"divLeft={divLeftText}"
      , s!"divRight={divRightText}"
      , s!"substitute={substitutedText}"
      ]
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

noncomputable section

-- Reify and cache-reuse checks on one backend session.
#eval do
  let result ← sympy Rat do
    symbols (x : Rat) (y : Rat)

    let lhsTerm : Term (Scalar Rat) := x + 0
    let lhs ← realize lhsTerm
    let rhs ← realize (x : Term (Scalar Rat))
    let reused := lhs.ref.ident == rhs.ref.ident

    let relationTerm : Term .boolean := gt 0 lhsTerm
    let relationReified ← reify (← realize relationTerm)
    let relationOk := sameEncodedTerm relationReified relationTerm.canonicalize

    let integralBody : Term (Scalar Rat) := x ^ 2 + 0
    let integralTerm : Term (Scalar Rat) := SymPy.Integral integralBody (x, 0, 1)
    let integralReified ← reify (← realize integralTerm)
    let integralOk := sameEncodedTerm integralReified integralTerm.canonicalize

    let simplified ← simplify (x + x)
    let simplifiedReified ← reify simplified
    let simplifiedTarget : Term (Scalar Rat) := 2 * x
    let simplifiedOk := sameEncodedTerm simplifiedReified simplifiedTarget.canonicalize

    let smokeUnaryTerm : Term (Scalar Rat) := Smoke.smokeUnary x
    let smokeUnaryReified ← reify (← simplify smokeUnaryTerm)
    let smokeUnaryOk := sameEncodedTerm smokeUnaryReified smokeUnaryTerm.canonicalize

    let smokeUnaryDupATerm : Term (Scalar Rat) := Smoke.smokeUnaryDupA x
    let smokeUnaryDupAReified ← reify (← simplify smokeUnaryDupATerm)
    let smokeUnaryDupAOk := sameEncodedTerm smokeUnaryDupAReified smokeUnaryDupATerm.canonicalize

    let smokeUnaryDupBTerm : Term (Scalar Rat) := Smoke.smokeUnaryDupB x
    let smokeUnaryDupBReified ← reify (← simplify smokeUnaryDupBTerm)
    let smokeUnaryDupBOk := sameEncodedTerm smokeUnaryDupBReified smokeUnaryDupBTerm.canonicalize

    let smokeBinaryTerm : Term (Scalar Rat) := Smoke.smokeBinary x y
    let smokeBinaryReified ← reify (← simplify smokeBinaryTerm)
    let smokeBinaryOk := sameEncodedTerm smokeBinaryReified smokeBinaryTerm.canonicalize

    pure <| String.intercalate "\n"
      [ s!"reusedRef={reused}"
      , s!"relationRoundTrip={relationOk}"
      , s!"integralRoundTrip={integralOk}"
      , s!"simplifyRoundTrip={simplifiedOk}"
      , s!"smokeUnaryRoundTrip={smokeUnaryOk}"
      , s!"smokeUnaryDupARoundTrip={smokeUnaryDupAOk}"
      , s!"smokeUnaryDupBRoundTrip={smokeUnaryDupBOk}"
      , s!"smokeBinaryRoundTrip={smokeBinaryOk}"
      ]
  match result with
  | .ok text => IO.println text
  | .error err => IO.println (repr err)

end
