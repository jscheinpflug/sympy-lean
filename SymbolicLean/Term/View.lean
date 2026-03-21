import SymbolicLean.Term.Head

namespace SymbolicLean

structure BinaryView where
  lhsSort : SSort
  rhsSort : SSort
  lhs : Term lhsSort
  rhs : Term rhsSort

structure IntegralView where
  domain : DomainDesc
  body : Term (.scalar domain)
  var : SymDecl (.scalar domain)

inductive CoreView : SSort → Type where
  | atom : Atom σ → CoreView σ
  | natLit : Nat → CoreView (.scalar (.ground .ZZ))
  | intLit : Int → CoreView (.scalar (.ground .ZZ))
  | ratLit : Rat → CoreView (.scalar (.ground .QQ))
  | head : (head : Head schema) → Args schema.args → CoreView schema.result
  | diff : Term σ → SymDecl (.scalar d) → Nat → CoreView σ
  | integral : Term (.scalar d) → SymDecl (.scalar d) → CoreView (.scalar d)
  | limit : Term (.scalar d) → SymDecl (.scalar d) → Term (.scalar d) → CoreView (.scalar d)
  | app : Term (.fn params ret) → Args params → CoreView ret

namespace Term

def coreView (term : Term σ) : CoreView σ := by
  cases term with
  | atom atom =>
      exact CoreView.atom atom
  | natLit value =>
      exact CoreView.natLit value
  | intLit value =>
      exact CoreView.intLit value
  | ratLit value =>
      exact CoreView.ratLit value
  | scalarNeg arg =>
      exact CoreView.head (.core (.scalarNeg _)) (.singleton arg)
  | scalarAdd lhs rhs =>
      exact CoreView.head (.core (@CoreHead.scalarAdd _ _ _ inferInstance)) (.pair lhs rhs)
  | scalarSub lhs rhs =>
      exact CoreView.head (.core (@CoreHead.scalarSub _ _ _ inferInstance)) (.pair lhs rhs)
  | scalarMul lhs rhs =>
      exact CoreView.head (.core (@CoreHead.scalarMul _ _ _ inferInstance)) (.pair lhs rhs)
  | scalarDiv lhs rhs =>
      exact CoreView.head (.core (.scalarDiv _)) (.pair lhs rhs)
  | scalarPow lhs rhs =>
      exact CoreView.head (.core (.scalarPow _)) (.pair lhs rhs)
  | matrixAdd lhs rhs =>
      exact CoreView.head (.core (.matrixAdd _ _ _)) (.pair lhs rhs)
  | matrixSub lhs rhs =>
      exact CoreView.head (.core (.matrixSub _ _ _)) (.pair lhs rhs)
  | matrixMul lhs rhs =>
      exact CoreView.head (.core (.matrixMul _ _ _ _)) (.pair lhs rhs)
  | truth value =>
      exact CoreView.head (.core (.truth value)) .nil
  | not_ arg =>
      exact CoreView.head (.core .not_) (.singleton arg)
  | and_ lhs rhs =>
      exact CoreView.head (.core .and_) (.pair lhs rhs)
  | or_ lhs rhs =>
      exact CoreView.head (.core .or_) (.pair lhs rhs)
  | implies lhs rhs =>
      exact CoreView.head (.core .implies) (.pair lhs rhs)
  | iff lhs rhs =>
      exact CoreView.head (.core .iff) (.pair lhs rhs)
  | relation rel lhs rhs =>
      exact CoreView.head (.core (.relation rel _ _)) (.pair lhs rhs)
  | membership elem setTerm =>
      exact CoreView.head (.core (.mem _)) (.pair elem setTerm)
  | diff body var order =>
      exact CoreView.diff body var order
  | integral body var =>
      exact CoreView.integral body var
  | limit body var value =>
      exact CoreView.limit body var value
  | headApp head args =>
      exact CoreView.head head args
  | app fn args =>
      exact CoreView.app fn args

def asAdd? (term : Term σ) : Option BinaryView :=
  match term.coreView with
  | .head (.core (@CoreHead.scalarAdd _ _ _ _)) (.cons lhs (.cons rhs .nil)) =>
      some { lhsSort := _, rhsSort := _, lhs := lhs, rhs := rhs }
  | .head (.core (.matrixAdd _ _ _)) (.cons lhs (.cons rhs .nil)) =>
      some { lhsSort := _, rhsSort := _, lhs := lhs, rhs := rhs }
  | _ => none

def asIntegral? (term : Term σ) : Option IntegralView :=
  match term.coreView with
  | .integral body var => some { domain := _, body := body, var := var }
  | _ => none

def asPiecewise? (_term : Term σ) : Option PUnit :=
  none

end Term

end SymbolicLean
