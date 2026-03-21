import SymbolicLean.Backend.Encode

namespace SymbolicLean

namespace Term

private def key (term : Term σ) : String :=
  (encodeTerm term).compress

private def orderPair (lhs rhs : Term σ) : Term σ × Term σ :=
  if key rhs < key lhs then (rhs, lhs) else (lhs, rhs)

private def sortTerms (terms : List (Term σ)) : List (Term σ) :=
  terms.mergeSort fun lhs rhs => key lhs < key rhs

private def mkAssocTerm (ctor : Term σ → Term σ → Term σ) (identity : Term σ)
    (terms : List (Term σ)) : Term σ :=
  match terms with
  | [] => identity
  | head :: tail => tail.foldl ctor head

private def zzLit (value : Int) : Term (.scalar (.ground .ZZ)) :=
  if value < 0 then
    .intLit value
  else
    .natLit value.toNat

private def isZeroZZ : Term (.scalar (.ground .ZZ)) → Bool
  | .natLit 0 => true
  | .intLit 0 => true
  | _ => false

private def isOneZZ : Term (.scalar (.ground .ZZ)) → Bool
  | .natLit 1 => true
  | .intLit 1 => true
  | _ => false

private def isZeroQQ : Term (.scalar (.ground .QQ)) → Bool
  | .ratLit q => q = 0
  | _ => false

private def isOneQQ : Term (.scalar (.ground .QQ)) → Bool
  | .ratLit q => q = 1
  | _ => false

private def isFalse : Term .boolean → Bool
  | .truth .false_ => true
  | _ => false

private def isTrue : Term .boolean → Bool
  | .truth .true_ => true
  | _ => false

private partial def collectZZAdd : Term (.scalar (.ground .ZZ)) → List (Term (.scalar (.ground .ZZ)))
  | @Term.scalarAdd (.ground .ZZ) (.ground .ZZ) (.ground .ZZ) _ lhs rhs =>
      collectZZAdd lhs ++ collectZZAdd rhs
  | term => [term]

private partial def collectQQAdd : Term (.scalar (.ground .QQ)) → List (Term (.scalar (.ground .QQ)))
  | @Term.scalarAdd (.ground .QQ) (.ground .QQ) (.ground .QQ) _ lhs rhs =>
      collectQQAdd lhs ++ collectQQAdd rhs
  | term => [term]

private partial def collectZZMul : Term (.scalar (.ground .ZZ)) → List (Term (.scalar (.ground .ZZ)))
  | @Term.scalarMul (.ground .ZZ) (.ground .ZZ) (.ground .ZZ) _ lhs rhs =>
      collectZZMul lhs ++ collectZZMul rhs
  | term => [term]

private partial def collectQQMul : Term (.scalar (.ground .QQ)) → List (Term (.scalar (.ground .QQ)))
  | @Term.scalarMul (.ground .QQ) (.ground .QQ) (.ground .QQ) _ lhs rhs =>
      collectQQMul lhs ++ collectQQMul rhs
  | term => [term]

private partial def collectBoolAnd : Term .boolean → List (Term .boolean)
  | .and_ lhs rhs => collectBoolAnd lhs ++ collectBoolAnd rhs
  | term => [term]

private partial def collectBoolOr : Term .boolean → List (Term .boolean)
  | .or_ lhs rhs => collectBoolOr lhs ++ collectBoolOr rhs
  | term => [term]

private partial def collectMatrixAdd : Term (.matrix d m n) → List (Term (.matrix d m n))
  | .matrixAdd lhs rhs => collectMatrixAdd lhs ++ collectMatrixAdd rhs
  | term => [term]

mutual

partial def canonicalize : Term σ → Term σ
  | term@(Term.atom _) => term
  | term@(Term.natLit _) => term
  | term@(Term.intLit _) => term
  | term@(Term.ratLit _) => term
  | .headApp head args =>
      match head with
      | .core coreHead =>
          match coreHead, args with
          | @CoreHead.scalarNeg _, .cons arg .nil =>
              canonicalize (.scalarNeg arg)
          | @CoreHead.scalarAdd _ _ _ inst, .cons lhs (.cons rhs .nil) =>
              canonicalize (@Term.scalarAdd _ _ _ inst lhs rhs)
          | @CoreHead.scalarSub _ _ _ inst, .cons lhs (.cons rhs .nil) =>
              canonicalize (@Term.scalarSub _ _ _ inst lhs rhs)
          | @CoreHead.scalarMul _ _ _ inst, .cons lhs (.cons rhs .nil) =>
              canonicalize (@Term.scalarMul _ _ _ inst lhs rhs)
          | @CoreHead.scalarDiv _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.scalarDiv lhs rhs)
          | @CoreHead.scalarPow _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.scalarPow lhs rhs)
          | @CoreHead.matrixAdd _ _ _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.matrixAdd lhs rhs)
          | @CoreHead.matrixSub _ _ _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.matrixSub lhs rhs)
          | @CoreHead.matrixMul _ _ _ _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.matrixMul lhs rhs)
          | @CoreHead.truth value, .nil =>
              .truth value
          | @CoreHead.not_, .cons arg .nil =>
              canonicalize (.not_ arg)
          | @CoreHead.and_, .cons lhs (.cons rhs .nil) =>
              canonicalize (.and_ lhs rhs)
          | @CoreHead.or_, .cons lhs (.cons rhs .nil) =>
              canonicalize (.or_ lhs rhs)
          | @CoreHead.implies, .cons lhs (.cons rhs .nil) =>
              canonicalize (.implies lhs rhs)
          | @CoreHead.iff, .cons lhs (.cons rhs .nil) =>
              canonicalize (.iff lhs rhs)
          | @CoreHead.relation rel _ _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.relation rel lhs rhs)
          | @CoreHead.eq _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.relation .eq lhs rhs)
          | @CoreHead.ne _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.relation .ne lhs rhs)
          | @CoreHead.lt _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.relation .lt lhs rhs)
          | @CoreHead.le _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.relation .le lhs rhs)
          | @CoreHead.gt _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.relation .gt lhs rhs)
          | @CoreHead.ge _, .cons lhs (.cons rhs .nil) =>
              canonicalize (.relation .ge lhs rhs)
          | @CoreHead.mem _, .cons elem (.cons setTerm .nil) =>
              canonicalize (.membership elem setTerm)
      | .ext spec =>
          .headApp (.ext spec) (canonicalizeArgs args)
  | @Term.scalarNeg (.ground .ZZ) arg =>
      match canonicalize arg with
      | .natLit n => zzLit (-Int.ofNat n)
      | .intLit n => zzLit (-n)
      | @Term.scalarNeg (.ground .ZZ) inner => inner
      | arg' => .scalarNeg arg'
  | @Term.scalarNeg (.ground .QQ) arg =>
      match canonicalize arg with
      | .ratLit q => .ratLit (-q)
      | @Term.scalarNeg (.ground .QQ) inner => inner
      | arg' => .scalarNeg arg'
  | .scalarNeg arg => .scalarNeg (canonicalize arg)
  | @Term.scalarAdd (.ground .ZZ) (.ground .ZZ) (.ground .ZZ) _ lhs rhs =>
      let pieces := collectZZAdd (canonicalize lhs) ++ collectZZAdd (canonicalize rhs)
      let (const, others) :=
        pieces.foldl
          (init := ((0 : Int), ([] : List (Term (.scalar (.ground .ZZ))))))
          fun (const, others) piece =>
            match piece with
            | .natLit n => (const + Int.ofNat n, others)
            | .intLit n => (const + n, others)
            | other => (const, other :: others)
      let ordered := sortTerms others.reverse
      let withConst :=
        if const = 0 then
          ordered
        else
          sortTerms (zzLit const :: ordered)
      mkAssocTerm Term.scalarAdd (.natLit 0) withConst
  | @Term.scalarAdd (.ground .QQ) (.ground .QQ) (.ground .QQ) _ lhs rhs =>
      let pieces := collectQQAdd (canonicalize lhs) ++ collectQQAdd (canonicalize rhs)
      let (const, others) :=
        pieces.foldl
          (init := ((0 : Rat), ([] : List (Term (.scalar (.ground .QQ))))))
          fun (const, others) piece =>
            match piece with
            | .ratLit q => (const + q, others)
            | other => (const, other :: others)
      let ordered := sortTerms others.reverse
      let withConst :=
        if const = 0 then
          ordered
        else
          sortTerms (.ratLit const :: ordered)
      mkAssocTerm Term.scalarAdd (.ratLit 0) withConst
  | @Term.scalarSub (.ground .ZZ) (.ground .ZZ) (.ground .ZZ) _ lhs rhs =>
      let lhs' := canonicalize lhs
      let rhs' := canonicalize rhs
      match lhs', rhs' with
      | .natLit a, .natLit b => zzLit (Int.ofNat a - Int.ofNat b)
      | .intLit a, .intLit b => zzLit (a - b)
      | .natLit a, .intLit b => zzLit (Int.ofNat a - b)
      | .intLit a, .natLit b => zzLit (a - Int.ofNat b)
      | _, _ =>
          if isZeroZZ rhs' then lhs' else .scalarSub lhs' rhs'
  | @Term.scalarSub (.ground .QQ) (.ground .QQ) (.ground .QQ) _ lhs rhs =>
      let lhs' := canonicalize lhs
      let rhs' := canonicalize rhs
      match lhs', rhs' with
      | .ratLit a, .ratLit b => .ratLit (a - b)
      | _, _ =>
          if isZeroQQ rhs' then lhs' else .scalarSub lhs' rhs'
  | @Term.scalarMul (.ground .ZZ) (.ground .ZZ) (.ground .ZZ) _ lhs rhs =>
      let pieces := collectZZMul (canonicalize lhs) ++ collectZZMul (canonicalize rhs)
      let (zeroSeen, const, others) :=
        pieces.foldl
          (init := (false, (1 : Int), ([] : List (Term (.scalar (.ground .ZZ))))))
          fun (zeroSeen, const, others) piece =>
            match piece with
            | .natLit 0 => (true, 0, others)
            | .intLit 0 => (true, 0, others)
            | .natLit n => (zeroSeen, const * Int.ofNat n, others)
            | .intLit n => (zeroSeen, const * n, others)
            | other => (zeroSeen, const, other :: others)
      if zeroSeen then
        .natLit 0
      else
        let ordered := sortTerms others.reverse
        let withConst :=
          if const = 1 then
            ordered
          else
            sortTerms (zzLit const :: ordered)
        mkAssocTerm Term.scalarMul (.natLit 1) withConst
  | @Term.scalarMul (.ground .QQ) (.ground .QQ) (.ground .QQ) _ lhs rhs =>
      let pieces := collectQQMul (canonicalize lhs) ++ collectQQMul (canonicalize rhs)
      let (zeroSeen, const, others) :=
        pieces.foldl
          (init := (false, (1 : Rat), ([] : List (Term (.scalar (.ground .QQ))))))
          fun (zeroSeen, const, others) piece =>
            match piece with
            | .ratLit q =>
                if q = 0 then
                  (true, 0, others)
                else
                  (zeroSeen, const * q, others)
            | other => (zeroSeen, const, other :: others)
      if zeroSeen then
        .ratLit 0
      else
        let ordered := sortTerms others.reverse
        let withConst :=
          if const = 1 then
            ordered
          else
            sortTerms (.ratLit const :: ordered)
        mkAssocTerm Term.scalarMul (.ratLit 1) withConst
  | @Term.scalarAdd _d₁ _d₂ out _ lhs rhs => .scalarAdd (canonicalize lhs) (canonicalize rhs)
  | @Term.scalarSub _d₁ _d₂ out _ lhs rhs => .scalarSub (canonicalize lhs) (canonicalize rhs)
  | @Term.scalarMul _d₁ _d₂ out _ lhs rhs => .scalarMul (canonicalize lhs) (canonicalize rhs)
  | .scalarDiv lhs rhs => .scalarDiv (canonicalize lhs) (canonicalize rhs)
  | .scalarPow lhs rhs => .scalarPow (canonicalize lhs) (canonicalize rhs)
  | .matrixAdd lhs rhs =>
      let pieces := collectMatrixAdd (canonicalize lhs) ++ collectMatrixAdd (canonicalize rhs)
      let ordered := sortTerms pieces
      mkAssocTerm Term.matrixAdd (canonicalize lhs) ordered
  | .matrixSub lhs rhs => .matrixSub (canonicalize lhs) (canonicalize rhs)
  | .matrixMul lhs rhs => .matrixMul (canonicalize lhs) (canonicalize rhs)
  | .truth value => .truth value
  | .not_ arg =>
      match canonicalize arg with
      | .truth .true_ => .truth .false_
      | .truth .false_ => .truth .true_
      | .not_ inner => inner
      | arg' => .not_ arg'
  | .and_ lhs rhs =>
      let pieces := collectBoolAnd (canonicalize lhs) ++ collectBoolAnd (canonicalize rhs)
      if pieces.any isFalse then
        .truth .false_
      else
        let filtered := sortTerms <| (pieces.filter fun piece => !isTrue piece)
        mkAssocTerm Term.and_ (.truth .true_) filtered
  | .or_ lhs rhs =>
      let pieces := collectBoolOr (canonicalize lhs) ++ collectBoolOr (canonicalize rhs)
      if pieces.any isTrue then
        .truth .true_
      else
        let filtered := sortTerms <| (pieces.filter fun piece => !isFalse piece)
        mkAssocTerm Term.or_ (.truth .false_) filtered
  | .implies lhs rhs => .implies (canonicalize lhs) (canonicalize rhs)
  | .iff lhs rhs =>
      let (lhs', rhs') := orderPair (canonicalize lhs) (canonicalize rhs)
      .iff lhs' rhs'
  | .relation .eq lhs rhs => .relation .eq (canonicalize lhs) (canonicalize rhs)
  | .relation .ne lhs rhs => .relation .ne (canonicalize lhs) (canonicalize rhs)
  | .relation rel lhs rhs => .relation rel (canonicalize lhs) (canonicalize rhs)
  | .membership elem setTerm => .membership (canonicalize elem) (canonicalize setTerm)
  | .diff body var order => .diff (canonicalize body) var order
  | .integral body var => .integral (canonicalize body) var
  | .limit body var value => .limit (canonicalize body) var (canonicalize value)
  | .app fn args => .app (canonicalize fn) (canonicalizeArgs args)

partial def canonicalizeArgs : {σs : List SSort} → Args σs → Args σs
  | [], .nil => .nil
  | _ :: _, .cons head tail => .cons (canonicalize head) (canonicalizeArgs tail)

end

def fingerprint (term : Term σ) : UInt64 :=
  hash (key (canonicalize term))

end Term

end SymbolicLean
