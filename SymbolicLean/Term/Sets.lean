import SymbolicLean.Syntax.DeclareOp

namespace SymbolicLean

declare_pure_head Interval {d : DomainDesc}
  for (lower : .scalar d) (upper : .scalar d) returns (.set (.scalar d)) => "Interval"
  sympy_alias
  doc "Pure interval-set constructor backed by SymPy's `Interval`."

declare_pure_head Union {d : DomainDesc}
  for (lhs : .set (.scalar d)) (rhs : .set (.scalar d)) returns (.set (.scalar d)) => "Union"
  sympy_alias
  doc "Pure set-union constructor backed by SymPy's `Union`."

declare_pure_head Intersection {d : DomainDesc}
  for (lhs : .set (.scalar d)) (rhs : .set (.scalar d)) returns (.set (.scalar d)) =>
  "Intersection"
  sympy_alias
  doc "Pure set-intersection constructor backed by SymPy's `Intersection`."

declare_pure_head Complement {d : DomainDesc}
  for (lhs : .set (.scalar d)) (rhs : .set (.scalar d)) returns (.set (.scalar d)) =>
  "Complement"
  sympy_alias
  doc "Pure set-complement constructor backed by SymPy's `Complement`."

declare_variadic_pure_head FiniteSet {d : DomainDesc}
  for (elem : .scalar d) returns (.set (.scalar d)) => "FiniteSet"
  sympy_alias
  doc "Homogeneous variadic finite-set constructor backed by SymPy's `FiniteSet`."

declare_pure_head Reals returns (.set (.scalar (.ground .RR))) => "S.Reals"
  call_style attr
  doc "Pure real-number set constant backed by SymPy's `S.Reals`."

declare_pure_head Integers returns (.set (.scalar (.ground .ZZ))) => "S.Integers"
  call_style attr
  doc "Pure integer set constant backed by SymPy's `S.Integers`."

end SymbolicLean
