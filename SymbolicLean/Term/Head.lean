import SymbolicLean.Term.Core

namespace SymbolicLean

namespace CoreHead

def backendName : CoreHead schema → String
  | @CoreHead.scalarNeg _ => "scalarNeg"
  | @CoreHead.scalarAdd _ _ _ _ => "scalarAdd"
  | @CoreHead.scalarSub _ _ _ _ => "scalarSub"
  | @CoreHead.scalarMul _ _ _ _ => "scalarMul"
  | @CoreHead.scalarDiv _ => "scalarDiv"
  | @CoreHead.scalarPow _ => "scalarPow"
  | @CoreHead.matrixAdd _ _ _ => "matrixAdd"
  | @CoreHead.matrixSub _ _ _ => "matrixSub"
  | @CoreHead.matrixMul _ _ _ _ => "matrixMul"
  | @CoreHead.truth _ => "truth"
  | @CoreHead.not_ => "not"
  | @CoreHead.and_ => "and"
  | @CoreHead.or_ => "or"
  | @CoreHead.implies => "implies"
  | @CoreHead.iff => "iff"
  | @CoreHead.relation rel _ _ =>
      match rel with
      | .eq => "relation"
      | .ne => "relation"
      | .lt => "relation"
      | .le => "relation"
      | .gt => "relation"
      | .ge => "relation"
      | .mem => "relation"
      | .subset => "relation"
  | @CoreHead.eq _ => "eq"
  | @CoreHead.ne _ => "ne"
  | @CoreHead.lt _ => "lt"
  | @CoreHead.le _ => "le"
  | @CoreHead.gt _ => "gt"
  | @CoreHead.ge _ => "ge"
  | @CoreHead.mem _ => "membership"

end CoreHead

namespace Head

def backendName : Head schema → String
  | .core head => head.backendName
  | .ext spec => spec.name.toString

end Head

end SymbolicLean
