import SymbolicLean.Term.Head

namespace SymbolicLean

class CanCompare (rel : RelKind) (lhs rhs : SSort) where
  compare : Term lhs → Term rhs → Term .boolean

instance : CanCompare .eq σ σ where
  compare lhs rhs := Term.headApp (.core (.eq σ)) (.pair lhs rhs)

instance : CanCompare .ne σ σ where
  compare lhs rhs := Term.headApp (.core (.ne σ)) (.pair lhs rhs)

instance : CanCompare .lt (.scalar d) (.scalar d) where
  compare lhs rhs := Term.headApp (.core (.lt d)) (.pair lhs rhs)

instance : CanCompare .le (.scalar d) (.scalar d) where
  compare lhs rhs := Term.headApp (.core (.le d)) (.pair lhs rhs)

instance : CanCompare .gt (.scalar d) (.scalar d) where
  compare lhs rhs := Term.headApp (.core (.gt d)) (.pair lhs rhs)

instance : CanCompare .ge (.scalar d) (.scalar d) where
  compare lhs rhs := Term.headApp (.core (.ge d)) (.pair lhs rhs)

def compare [inst : CanCompare rel σ τ] (lhs : Term σ) (rhs : Term τ) : Term .boolean :=
  inst.compare lhs rhs

def eq_ (lhs rhs : Term σ) : Term .boolean := compare (rel := .eq) lhs rhs

def ne_ (lhs rhs : Term σ) : Term .boolean := compare (rel := .ne) lhs rhs

def lt (lhs rhs : Term (.scalar d)) : Term .boolean := compare (rel := .lt) lhs rhs

def le (lhs rhs : Term (.scalar d)) : Term .boolean := compare (rel := .le) lhs rhs

def gt (lhs rhs : Term (.scalar d)) : Term .boolean := compare (rel := .gt) lhs rhs

def ge (lhs rhs : Term (.scalar d)) : Term .boolean := compare (rel := .ge) lhs rhs

def mem (elem : Term σ) (setTerm : Term (.set σ)) : Term .boolean :=
  Term.headApp (.core (.mem σ)) (.pair elem setTerm)

end SymbolicLean
