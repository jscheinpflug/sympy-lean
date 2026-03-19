import SymbolicLean.Term.Core

namespace SymbolicLean

def applyN (fnTerm : Term (.fn params ret)) (args : Args params) : Term ret := .app fnTerm args

def apply1 (fnTerm : Term (.fn [σ] ret)) (arg : Term σ) : Term ret :=
  applyN fnTerm (.singleton arg)

def apply2 (fnTerm : Term (.fn [σ, τ] ret)) (lhs : Term σ) (rhs : Term τ) : Term ret :=
  applyN fnTerm (.pair lhs rhs)

instance : CoeFun (Term (.fn [σ] ret)) (fun _ => Term σ → Term ret) where
  coe fnTerm := apply1 fnTerm

end SymbolicLean
