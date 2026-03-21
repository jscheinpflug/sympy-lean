import SymbolicLean.Term.Core

namespace SymbolicLean

structure BoundSpec (d : DomainDesc) where
  var : SymDecl (.scalar d)
  lower? : Option (Term (.scalar d)) := none
  upper? : Option (Term (.scalar d)) := none

structure DerivSpec (σ : SSort) (d : DomainDesc) where
  var : SymDecl (.scalar d)
  order : Nat := 1

structure PieceBranch (σ : SSort) where
  body : Term σ
  condition : Term .boolean

abbrev BoundVar (d : DomainDesc) := SymDecl (.scalar d)
abbrev BoundUpper (d : DomainDesc) := SymDecl (.scalar d) × Term (.scalar d)
abbrev BoundRange (d : DomainDesc) := SymDecl (.scalar d) × Term (.scalar d) × Term (.scalar d)
abbrev DerivVar (d : DomainDesc) := SymDecl (.scalar d)
abbrev DerivOrder (d : DomainDesc) := SymDecl (.scalar d) × Nat
abbrev PieceCase (σ : SSort) := Term σ × Term .boolean
abbrev PieceDeclCase (σ : SSort) := SymDecl σ × Term .boolean

class IntoBoundSpec (d : DomainDesc) (α : Type) where
  intoBoundSpec : α → BoundSpec d

class IntoDerivSpec (σ : SSort) (d : DomainDesc) (α : Type) where
  intoDerivSpec : α → DerivSpec σ d

class IntoPieceBranch (σ : SSort) (α : Type) where
  intoPieceBranch : α → PieceBranch σ

instance : Coe (BoundVar d) (BoundSpec d) where
  coe var := { var := var }

instance : Coe (BoundUpper d) (BoundSpec d) where
  coe tuple := { var := tuple.1, upper? := some tuple.2 }

instance : Coe (BoundRange d) (BoundSpec d) where
  coe tuple := { var := tuple.1, lower? := some tuple.2.1, upper? := some tuple.2.2 }

instance : Coe (DerivVar d) (DerivSpec σ d) where
  coe var := { var := var }

instance : Coe (DerivOrder d) (DerivSpec σ d) where
  coe tuple := { var := tuple.1, order := tuple.2 }

instance : Coe (PieceCase σ) (PieceBranch σ) where
  coe tuple := { body := tuple.1, condition := tuple.2 }

instance : Coe (PieceDeclCase σ) (PieceBranch σ) where
  coe tuple := { body := tuple.1, condition := tuple.2 }

instance : IntoBoundSpec d (BoundSpec d) where
  intoBoundSpec := id

instance : IntoBoundSpec d (BoundVar d) where
  intoBoundSpec := fun value => (value : BoundSpec d)

instance : IntoBoundSpec d (BoundUpper d) where
  intoBoundSpec := fun value => (value : BoundSpec d)

instance : IntoBoundSpec d (BoundRange d) where
  intoBoundSpec := fun value => (value : BoundSpec d)

instance : IntoDerivSpec σ d (DerivSpec σ d) where
  intoDerivSpec := id

instance : IntoDerivSpec σ d (DerivVar d) where
  intoDerivSpec := fun value => (value : DerivSpec σ d)

instance : IntoDerivSpec σ d (DerivOrder d) where
  intoDerivSpec := fun value => (value : DerivSpec σ d)

instance : IntoPieceBranch σ (PieceBranch σ) where
  intoPieceBranch := id

instance : IntoPieceBranch σ (PieceCase σ) where
  intoPieceBranch := fun value => (value : PieceBranch σ)

instance : IntoPieceBranch σ (PieceDeclCase σ) where
  intoPieceBranch := fun value => (value : PieceBranch σ)

end SymbolicLean
