import SymbolicLean.Term.Core

namespace SymbolicLean

class CanCompare (rel : RelKind) (lhs rhs : SSort) where
  compare : Term lhs → Term rhs → Term .boolean

instance : CanCompare .eq σ σ where
  compare := Term.relation .eq

instance : CanCompare .ne σ σ where
  compare := Term.relation .ne

instance : CanCompare .lt (.scalar d) (.scalar d) where
  compare := Term.relation .lt

instance : CanCompare .le (.scalar d) (.scalar d) where
  compare := Term.relation .le

instance : CanCompare .gt (.scalar d) (.scalar d) where
  compare := Term.relation .gt

instance : CanCompare .ge (.scalar d) (.scalar d) where
  compare := Term.relation .ge

def compare [inst : CanCompare rel σ τ] (lhs : Term σ) (rhs : Term τ) : Term .boolean :=
  inst.compare lhs rhs

def eq_ (lhs rhs : Term σ) : Term .boolean := compare (rel := .eq) lhs rhs

def ne_ (lhs rhs : Term σ) : Term .boolean := compare (rel := .ne) lhs rhs

def lt (lhs rhs : Term (.scalar d)) : Term .boolean := compare (rel := .lt) lhs rhs

def le (lhs rhs : Term (.scalar d)) : Term .boolean := compare (rel := .le) lhs rhs

def gt (lhs rhs : Term (.scalar d)) : Term .boolean := compare (rel := .gt) lhs rhs

def ge (lhs rhs : Term (.scalar d)) : Term .boolean := compare (rel := .ge) lhs rhs

def mem (elem : Term σ) (setTerm : Term (.set σ)) : Term .boolean := .membership elem setTerm

end SymbolicLean
