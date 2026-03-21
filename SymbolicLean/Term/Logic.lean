import SymbolicLean.Term.Head

namespace SymbolicLean

def verum : Term .boolean := Term.headApp (.core (.truth .true_)) .nil

def falsum : Term .boolean := Term.headApp (.core (.truth .false_)) .nil

def not_ (term : Term .boolean) : Term .boolean :=
  Term.headApp (.core .not_) (.singleton term)

def and_ (lhs rhs : Term .boolean) : Term .boolean :=
  Term.headApp (.core .and_) (.pair lhs rhs)

def or_ (lhs rhs : Term .boolean) : Term .boolean :=
  Term.headApp (.core .or_) (.pair lhs rhs)

def implies (lhs rhs : Term .boolean) : Term .boolean :=
  Term.headApp (.core .implies) (.pair lhs rhs)

def iff (lhs rhs : Term .boolean) : Term .boolean :=
  Term.headApp (.core .iff) (.pair lhs rhs)

end SymbolicLean
