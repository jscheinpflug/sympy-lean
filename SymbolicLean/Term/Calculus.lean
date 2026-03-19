import SymbolicLean.Term.Core

namespace SymbolicLean

def diff (body : Term σ) (x : SymDecl (.scalar d)) (order : Nat := 1) : Term σ :=
  .diff body x order

def integral (body : Term (.scalar d)) (x : SymDecl (.scalar d)) : Term (.scalar d) :=
  .integral body x

def limit (body : Term (.scalar d)) (x : SymDecl (.scalar d)) (atPoint : Term (.scalar d)) :
    Term (.scalar d) :=
  .limit body x atPoint

end SymbolicLean
