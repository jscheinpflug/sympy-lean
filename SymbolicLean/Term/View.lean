import SymbolicLean.Term.Structured

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

structure PiecewiseView (σ : SSort) where
  branch : PieceBranch σ
  fallback : Term σ

inductive PackedTerm where
  | mk (σ : SSort) (term : Term σ)

def Args.toPackedList : Args σs → List PackedTerm
  | .nil => []
  | .cons head tail => .mk _ head :: toPackedList tail

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

def coreView (term : Term σ) : CoreView σ :=
  Term.casesOn
    (motive_2 := fun σ _ => CoreView σ)
    term
    (fun atom => CoreView.atom atom)
    (fun value => CoreView.natLit value)
    (fun value => CoreView.intLit value)
    (fun value => CoreView.ratLit value)
    (fun {d} arg => CoreView.head (.core (.scalarNeg d)) (.singleton arg))
    (fun {d1} {d2} {out} _ lhs rhs => CoreView.head (.core (.scalarAdd d1 d2 out)) (.pair lhs rhs))
    (fun {d1} {d2} {out} _ lhs rhs => CoreView.head (.core (.scalarSub d1 d2 out)) (.pair lhs rhs))
    (fun {d1} {d2} {out} _ lhs rhs => CoreView.head (.core (.scalarMul d1 d2 out)) (.pair lhs rhs))
    (fun {d} lhs rhs => CoreView.head (.core (.scalarDiv d)) (.pair lhs rhs))
    (fun {d} lhs rhs => CoreView.head (.core (.scalarPow d)) (.pair lhs rhs))
    (fun {d} {m} {n} lhs rhs => CoreView.head (.core (.matrixAdd d m n)) (.pair lhs rhs))
    (fun {d} {m} {n} lhs rhs => CoreView.head (.core (.matrixSub d m n)) (.pair lhs rhs))
    (fun {d} {m} {n} {p} lhs rhs => CoreView.head (.core (.matrixMul d m n p)) (.pair lhs rhs))
    (fun value => CoreView.head (.core (.truth value)) .nil)
    (fun arg => CoreView.head (.core .not_) (.singleton arg))
    (fun lhs rhs => CoreView.head (.core .and_) (.pair lhs rhs))
    (fun lhs rhs => CoreView.head (.core .or_) (.pair lhs rhs))
    (fun lhs rhs => CoreView.head (.core .implies) (.pair lhs rhs))
    (fun lhs rhs => CoreView.head (.core .iff) (.pair lhs rhs))
    (fun {σ} {τ} rel lhs rhs => CoreView.head (.core (.relation rel σ τ)) (.pair lhs rhs))
    (fun {σ} elem setTerm => CoreView.head (.core (.mem σ)) (.pair elem setTerm))
    (fun {_} {_} body var order => CoreView.diff body var order)
    (fun {_} body var => CoreView.integral body var)
    (fun {_} body var value => CoreView.limit body var value)
    (fun head args => CoreView.head head args)
    (fun fn args => CoreView.app fn args)

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

private def castTerm {σ τ : SSort} (h : σ = τ) (term : Term σ) : Term τ :=
  h ▸ term

private noncomputable def asPiecewiseFromPacked (sort : SSort) (headName : Lean.Name)
    (args : List PackedTerm) : Option (PiecewiseView sort) :=
  match args with
  | [.mk bodySort body, .mk .boolean condition, .mk fallbackSort fallback] =>
      if hBody : bodySort = sort then
        if hFallback : fallbackSort = sort then
          let body' : Term sort := castTerm hBody body
          let fallback' : Term sort := castTerm hFallback fallback
          if headName = piecewiseHeadName then
            some { branch := { body := body', condition := condition }, fallback := fallback' }
          else
            none
        else
          none
      else
        none
  | _ => none

private noncomputable def asPiecewiseOf (sort : SSort) (term : Term sort) :
    Option (PiecewiseView sort) :=
  Term.casesOn
    (motive_2 := fun σ _ => Option (PiecewiseView σ))
    term
    (fun {_} _ => none)
    (fun _ => none)
    (fun _ => none)
    (fun _ => none)
    (fun {_} _ => none)
    (fun {_} {_} {_} {_} _ _ => none)
    (fun {_} {_} {_} {_} _ _ => none)
    (fun {_} {_} {_} {_} _ _ => none)
    (fun {_} _ _ => none)
    (fun {_} _ _ => none)
    (fun {_} {_} {_} _ _ => none)
    (fun {_} {_} {_} _ _ => none)
    (fun {_} {_} {_} {_} _ _ => none)
    (fun _ => none)
    (fun _ => none)
    (fun _ _ => none)
    (fun _ _ => none)
    (fun _ _ => none)
    (fun _ _ => none)
    (fun {_} {_} _ _ _ => none)
    (fun {_} _ _ => none)
    (fun {_} {_} _ _ _ => none)
    (fun {_} _ _ => none)
    (fun {_} _ _ _ => none)
    (fun {_} head args =>
      match head with
      | .ext spec => asPiecewiseFromPacked _ spec.name args.toPackedList
      | .core _ => none)
    (fun {_} {_} _ _ => none)

noncomputable def asPiecewise? {σ : SSort} (term : Term σ) : Option (PiecewiseView σ) :=
  asPiecewiseOf σ term

end Term

end SymbolicLean
