import SymbolicLean.Term.Literals

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

def eq_ {α : Type} {β : Type} {σ : SSort} [IntoTerm α σ] [IntoTerm β σ]
    (lhs : α) (rhs : β) : Term .boolean :=
  compare (rel := .eq) (IntoTerm.intoTerm lhs) (IntoTerm.intoTerm rhs)

def ne_ {α : Type} {β : Type} {σ : SSort} [IntoTerm α σ] [IntoTerm β σ]
    (lhs : α) (rhs : β) : Term .boolean :=
  compare (rel := .ne) (IntoTerm.intoTerm lhs) (IntoTerm.intoTerm rhs)

def lt {α : Type} {β : Type} {d : DomainDesc} [IntoScalarTerm α d] [IntoScalarTerm β d]
    (lhs : α) (rhs : β) : Term .boolean :=
  compare (rel := .lt) (IntoTerm.intoTerm lhs) (IntoTerm.intoTerm rhs)

def le {α : Type} {β : Type} {d : DomainDesc} [IntoScalarTerm α d] [IntoScalarTerm β d]
    (lhs : α) (rhs : β) : Term .boolean :=
  compare (rel := .le) (IntoTerm.intoTerm lhs) (IntoTerm.intoTerm rhs)

def gt {α : Type} {β : Type} {d : DomainDesc} [IntoScalarTerm α d] [IntoScalarTerm β d]
    (lhs : α) (rhs : β) : Term .boolean :=
  compare (rel := .gt) (IntoTerm.intoTerm lhs) (IntoTerm.intoTerm rhs)

def ge {α : Type} {β : Type} {d : DomainDesc} [IntoScalarTerm α d] [IntoScalarTerm β d]
    (lhs : α) (rhs : β) : Term .boolean :=
  compare (rel := .ge) (IntoTerm.intoTerm lhs) (IntoTerm.intoTerm rhs)

def mem {α : Type} {β : Type} {σ : SSort} [IntoTerm α σ] [IntoTerm β (.set σ)]
    (elem : α) (setTerm : β) : Term .boolean :=
  Term.headApp (.core (.mem σ)) (.pair (IntoTerm.intoTerm elem) (IntoTerm.intoTerm setTerm))

end SymbolicLean
