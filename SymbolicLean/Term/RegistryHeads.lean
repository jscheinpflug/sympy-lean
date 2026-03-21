import SymbolicLean.Syntax.DeclareOp

namespace SymbolicLean

declare_head scalarNegHead => "scalarNeg"
  doc "Registry manifest entry for the pure scalar negation head."

declare_head scalarAddHead => "scalarAdd"
  doc "Registry manifest entry for the pure scalar addition head."

declare_head scalarSubHead => "scalarSub"
  doc "Registry manifest entry for the pure scalar subtraction head."

declare_head scalarMulHead => "scalarMul"
  doc "Registry manifest entry for the pure scalar multiplication head."

declare_head scalarDivHead => "scalarDiv"
  doc "Registry manifest entry for the pure scalar division head."

declare_head scalarPowHead => "scalarPow"
  doc "Registry manifest entry for the pure scalar power head."

declare_head matrixAddHead => "matrixAdd"
  doc "Registry manifest entry for the pure matrix addition head."

declare_head matrixSubHead => "matrixSub"
  doc "Registry manifest entry for the pure matrix subtraction head."

declare_head matrixMulHead => "matrixMul"
  doc "Registry manifest entry for the pure matrix multiplication head."

declare_head truthHead => "truth"
  doc "Registry manifest entry for the pure truth-value head."

declare_head notHead => "not"
  doc "Registry manifest entry for the pure boolean negation head."

declare_head andHead => "and"
  doc "Registry manifest entry for the pure boolean conjunction head."

declare_head orHead => "or"
  doc "Registry manifest entry for the pure boolean disjunction head."

declare_head impliesHead => "implies"
  doc "Registry manifest entry for the pure boolean implication head."

declare_head iffHead => "iff"
  doc "Registry manifest entry for the pure boolean iff head."

declare_head relationHead => "relation"
  doc "Registry manifest entry for the generic relation head."

declare_head eqHead => "eq"
  doc "Registry manifest entry for the pure equality head."

declare_head neHead => "ne"
  doc "Registry manifest entry for the pure disequality head."

declare_head ltHead => "lt"
  doc "Registry manifest entry for the pure less-than head."

declare_head leHead => "le"
  doc "Registry manifest entry for the pure less-or-equal head."

declare_head gtHead => "gt"
  doc "Registry manifest entry for the pure greater-than head."

declare_head geHead => "ge"
  doc "Registry manifest entry for the pure greater-or-equal head."

declare_head membershipHead => "membership"
  doc "Registry manifest entry for the pure membership head."

declare_head diffHead => "diff"
  doc "Registry manifest entry for the pure derivative head."

declare_head integralHead => "integral"
  doc "Registry manifest entry for the pure integral head."

declare_head limitHead => "limit"
  doc "Registry manifest entry for the pure limit head."

declare_head integralUpperHead => "integralUpper"
  doc "Registry manifest entry for the pure upper-bounded integral head."

declare_head integralLowerHead => "integralLower"
  doc "Registry manifest entry for the pure lower-bounded integral head."

declare_head integralRangeHead => "integralRange"
  doc "Registry manifest entry for the pure range-bounded integral head."

declare_head summationUpperHead => "summationUpper"
  doc "Registry manifest entry for the pure upper-bounded summation head."

declare_head summationLowerHead => "summationLower"
  doc "Registry manifest entry for the pure lower-bounded summation head."

declare_head summationRangeHead => "summationRange"
  doc "Registry manifest entry for the pure range-bounded summation head."

declare_head productUpperHead => "productUpper"
  doc "Registry manifest entry for the pure upper-bounded product head."

declare_head productLowerHead => "productLower"
  doc "Registry manifest entry for the pure lower-bounded product head."

declare_head productRangeHead => "productRange"
  doc "Registry manifest entry for the pure range-bounded product head."

declare_head lambdaHead => "lambda"
  doc "Registry manifest entry for the pure lambda head."

declare_head piecewiseHead => "piecewise"
  doc "Registry manifest entry for the pure piecewise head."

declare_head getitemHead => "getitem"
  doc "Registry manifest entry for the pure unary indexing head."

declare_head getitem2Head => "getitem2"
  doc "Registry manifest entry for the pure two-index head."

declare_head sliceAtPureHead => "sliceAt"
  doc "Registry manifest entry for the pure column or slice-at head."

declare_head sliceRangePureHead => "sliceRange"
  doc "Registry manifest entry for the pure slice-range head."

declare_head dictEmptyPureHead => "dictEmpty"
  doc "Registry manifest entry for the pure empty-dict head."

declare_head dictInsertPureHead => "dictInsert"
  doc "Registry manifest entry for the pure dict-insert head."

end SymbolicLean
