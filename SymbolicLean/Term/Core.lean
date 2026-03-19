import SymbolicLean.Decl.Core

namespace SymbolicLean

inductive Atom : SSort → Type where
  | sym : SymDecl σ → Atom σ
  | fun_ : FunDecl args ret → Atom (.fn args ret)

mutual

inductive Args : List SSort → Type where
  | nil : Args []
  | cons : Term σ → Args σs → Args (σ :: σs)

inductive Term : SSort → Type where
  | atom : Atom σ → Term σ
  | natLit : Nat → Term (.scalar (.ground .ZZ))
  | intLit : Int → Term (.scalar (.ground .ZZ))
  | ratLit : Rat → Term (.scalar (.ground .QQ))
  | scalarNeg : Term (.scalar d) → Term (.scalar d)
  | scalarAdd : Term (.scalar d) → Term (.scalar d) → Term (.scalar d)
  | scalarSub : Term (.scalar d) → Term (.scalar d) → Term (.scalar d)
  | scalarMul : Term (.scalar d) → Term (.scalar d) → Term (.scalar d)
  | scalarDiv : Term (.scalar d) → Term (.scalar d) → Term (.scalar d)
  | scalarPow :
      Term (.scalar d) → Term (.scalar (.ground .ZZ)) → Term (.scalar d)
  | matrixAdd :
      Term (.matrix d m n) → Term (.matrix d m n) → Term (.matrix d m n)
  | matrixSub :
      Term (.matrix d m n) → Term (.matrix d m n) → Term (.matrix d m n)
  | matrixMul :
      Term (.matrix d m n) → Term (.matrix d n p) → Term (.matrix d m p)
  | truth : Truth → Term .boolean
  | not_ : Term .boolean → Term .boolean
  | and_ : Term .boolean → Term .boolean → Term .boolean
  | or_ : Term .boolean → Term .boolean → Term .boolean
  | implies : Term .boolean → Term .boolean → Term .boolean
  | iff : Term .boolean → Term .boolean → Term .boolean
  | relation : RelKind → Term σ → Term τ → Term .boolean
  | membership : Term σ → Term (.set σ) → Term .boolean
  | diff : Term σ → SymDecl (.scalar d) → Nat → Term σ
  | integral : Term (.scalar d) → SymDecl (.scalar d) → Term (.scalar d)
  | limit :
      Term (.scalar d) →
      SymDecl (.scalar d) →
      Term (.scalar d) →
      Term (.scalar d)
  | app : Term (.fn params ret) → Args params → Term ret

end

namespace Atom

def ofDecl (decl : SymDecl σ) : Atom σ := .sym decl

def ofFun (decl : FunDecl args ret) : Atom (.fn args ret) := .fun_ decl

end Atom

namespace Args

def singleton (arg : Term σ) : Args [σ] := .cons arg .nil

def pair (lhs : Term σ) (rhs : Term τ) : Args [σ, τ] := .cons lhs (.cons rhs .nil)

end Args

end SymbolicLean
