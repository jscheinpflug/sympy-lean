import SymbolicLean.Syntax.DeclareOp

namespace SymbolicLean

declare_scalar_fn₁ sin => "sin" sympy_alias
  doc "Pure scalar sine head backed by SymPy's `sin`."

declare_scalar_fn₁ cos => "cos" sympy_alias
  doc "Pure scalar cosine head backed by SymPy's `cos`."

declare_scalar_fn₁ tan => "tan" sympy_alias
  doc "Pure scalar tangent head backed by SymPy's `tan`."

declare_scalar_fn₁ asin => "asin" sympy_alias
  doc "Pure scalar inverse-sine head backed by SymPy's `asin`."

declare_scalar_fn₁ acos => "acos" sympy_alias
  doc "Pure scalar inverse-cosine head backed by SymPy's `acos`."

declare_scalar_fn₁ atan => "atan" sympy_alias
  doc "Pure scalar inverse-tangent head backed by SymPy's `atan`."

declare_scalar_fn₂ atan2 => "atan2" sympy_alias
  doc "Pure scalar two-argument inverse-tangent head backed by SymPy's `atan2`."

declare_scalar_fn₁ sinh => "sinh" sympy_alias
  doc "Pure scalar hyperbolic-sine head backed by SymPy's `sinh`."

declare_scalar_fn₁ cosh => "cosh" sympy_alias
  doc "Pure scalar hyperbolic-cosine head backed by SymPy's `cosh`."

declare_scalar_fn₁ tanh => "tanh" sympy_alias
  doc "Pure scalar hyperbolic-tangent head backed by SymPy's `tanh`."

declare_scalar_fn₁ exp => "exp" sympy_alias
  doc "Pure scalar exponential head backed by SymPy's `exp`."

declare_scalar_fn₁ log => "log" sympy_alias
  doc "Pure scalar logarithm head backed by SymPy's `log`."

declare_scalar_fn₁ sqrt => "sqrt" sympy_alias
  doc "Pure scalar square-root head backed by SymPy's `sqrt`."

declare_scalar_fn₁ Abs => "Abs" sympy_alias
  doc "Pure scalar absolute-value head backed by SymPy's `Abs`."

declare_scalar_fn₁ sign => "sign" sympy_alias
  doc "Pure scalar sign head backed by SymPy's `sign`."

declare_scalar_fn₁ floor => "floor" sympy_alias
  doc "Pure scalar floor head backed by SymPy's `floor`."

declare_scalar_fn₁ ceiling => "ceiling" sympy_alias
  doc "Pure scalar ceiling head backed by SymPy's `ceiling`."

declare_variadic_pure_head Min {d : DomainDesc}
  for (x : .scalar d) returns (.scalar d) => "Min"
  sympy_alias
  doc "Homogeneous variadic scalar minimum head backed by SymPy's `Min`."

declare_variadic_pure_head Max {d : DomainDesc}
  for (x : .scalar d) returns (.scalar d) => "Max"
  sympy_alias
  doc "Homogeneous variadic scalar maximum head backed by SymPy's `Max`."

declare_pure_head re for (z : .scalar (.ground .CC)) returns (.scalar (.ground .RR)) => "re"
  sympy_alias
  doc "Pure complex-real-part head backed by SymPy's `re`."

declare_pure_head im for (z : .scalar (.ground .CC)) returns (.scalar (.ground .RR)) => "im"
  sympy_alias
  doc "Pure complex-imaginary-part head backed by SymPy's `im`."

declare_pure_head conjugate for (z : .scalar (.ground .CC)) returns (.scalar (.ground .CC)) =>
  "conjugate"
  sympy_alias
  doc "Pure complex-conjugation head backed by SymPy's `conjugate`."

declare_pure_head arg for (z : .scalar (.ground .CC)) returns (.scalar (.ground .RR)) => "arg"
  sympy_alias
  doc "Pure complex-argument head backed by SymPy's `arg`."

end SymbolicLean
