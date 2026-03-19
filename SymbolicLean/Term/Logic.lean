import SymbolicLean.Term.Core

namespace SymbolicLean

def verum : Term .boolean := .truth .true_

def falsum : Term .boolean := .truth .false_

def not_ (term : Term .boolean) : Term .boolean := .not_ term

def and_ (lhs rhs : Term .boolean) : Term .boolean := .and_ lhs rhs

def or_ (lhs rhs : Term .boolean) : Term .boolean := .or_ lhs rhs

def implies (lhs rhs : Term .boolean) : Term .boolean := .implies lhs rhs

def iff (lhs rhs : Term .boolean) : Term .boolean := .iff lhs rhs

end SymbolicLean
