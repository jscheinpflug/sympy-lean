import SymbolicLean.Term.Head

namespace SymbolicLean

def diffHeadSpec (σ : SSort) (d : DomainDesc) :
    ExtHeadSpec { args := [σ, .scalar d, .scalar (.ground .ZZ)], result := σ } :=
  { name := diffHeadName }

def integralHeadSpec (d : DomainDesc) :
    ExtHeadSpec (HeadSchema.binary (.scalar d) (.scalar d) (.scalar d)) :=
  { name := integralHeadName }

def limitHeadSpec (d : DomainDesc) :
    ExtHeadSpec { args := [.scalar d, .scalar d, .scalar d], result := .scalar d } :=
  { name := limitHeadName }

def diff (body : Term σ) (x : SymDecl (.scalar d)) (order : Nat := 1) : Term σ :=
  .headApp (.ext (diffHeadSpec σ d))
    (.cons body (.cons (x : Term (.scalar d)) (.cons (.natLit order) .nil)))

def integral (body : Term (.scalar d)) (x : SymDecl (.scalar d)) : Term (.scalar d) :=
  .headApp (.ext (integralHeadSpec d)) (.pair body (x : Term (.scalar d)))

def limitTerm (body : Term (.scalar d)) (x : SymDecl (.scalar d)) (atPoint : Term (.scalar d)) :
    Term (.scalar d) :=
  .headApp (.ext (limitHeadSpec d))
    (.cons body (.cons (x : Term (.scalar d)) (.cons atPoint .nil)))

end SymbolicLean
