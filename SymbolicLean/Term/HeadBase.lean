import SymbolicLean.Sort.Base
import SymbolicLean.Domain.Classes

namespace SymbolicLean

structure HeadSchema where
  args : List SSort
  result : SSort

namespace HeadSchema

def nullary (res : SSort) : HeadSchema :=
  { args := ([] : List SSort), result := res }

def unary (arg res : SSort) : HeadSchema :=
  { args := ([arg] : List SSort), result := res }

def binary (lhs rhs res : SSort) : HeadSchema :=
  { args := ([lhs, rhs] : List SSort), result := res }

end HeadSchema

inductive CoreHead : HeadSchema → Type where
  | scalarNeg (d : DomainDesc) :
      CoreHead (HeadSchema.unary (.scalar d) (.scalar d))
  | scalarAdd (d1 d2 out : DomainDesc) [UnifyDomain d1 d2 out] :
      CoreHead (HeadSchema.binary
        (.scalar d1)
        (.scalar d2)
        (.scalar out))
  | scalarSub (d1 d2 out : DomainDesc) [UnifyDomain d1 d2 out] :
      CoreHead (HeadSchema.binary
        (.scalar d1)
        (.scalar d2)
        (.scalar out))
  | scalarMul (d1 d2 out : DomainDesc) [UnifyDomain d1 d2 out] :
      CoreHead (HeadSchema.binary
        (.scalar d1)
        (.scalar d2)
        (.scalar out))
  | scalarDiv (d : DomainDesc) :
      CoreHead (HeadSchema.binary
        (.scalar d)
        (.scalar d)
        (.scalar d))
  | scalarPow (d : DomainDesc) :
      CoreHead (HeadSchema.binary
        (.scalar d)
        (.scalar (.ground .ZZ))
        (.scalar d))
  | matrixAdd (d : DomainDesc) (m n : Dim) :
      CoreHead (HeadSchema.binary
        (.matrix d m n)
        (.matrix d m n)
        (.matrix d m n))
  | matrixSub (d : DomainDesc) (m n : Dim) :
      CoreHead (HeadSchema.binary
        (.matrix d m n)
        (.matrix d m n)
        (.matrix d m n))
  | matrixMul (d : DomainDesc) (m n p : Dim) :
      CoreHead (HeadSchema.binary
        (.matrix d m n)
        (.matrix d n p)
        (.matrix d m p))
  | truth (value : Truth) :
      CoreHead (HeadSchema.nullary .boolean)
  | not_ :
      CoreHead (HeadSchema.unary .boolean .boolean)
  | and_ :
      CoreHead (HeadSchema.binary
        .boolean
        .boolean
        .boolean)
  | or_ :
      CoreHead (HeadSchema.binary
        .boolean
        .boolean
        .boolean)
  | implies :
      CoreHead (HeadSchema.binary
        .boolean
        .boolean
        .boolean)
  | iff :
      CoreHead (HeadSchema.binary
        .boolean
        .boolean
        .boolean)
  | relation (rel : RelKind) (lhs rhs : SSort) :
      CoreHead (HeadSchema.binary lhs rhs .boolean)
  | eq (σ : SSort) :
      CoreHead (HeadSchema.binary σ σ .boolean)
  | ne (σ : SSort) :
      CoreHead (HeadSchema.binary σ σ .boolean)
  | lt (d : DomainDesc) :
      CoreHead (HeadSchema.binary
        (.scalar d)
        (.scalar d)
        .boolean)
  | le (d : DomainDesc) :
      CoreHead (HeadSchema.binary
        (.scalar d)
        (.scalar d)
        .boolean)
  | gt (d : DomainDesc) :
      CoreHead (HeadSchema.binary
        (.scalar d)
        (.scalar d)
        .boolean)
  | ge (d : DomainDesc) :
      CoreHead (HeadSchema.binary
        (.scalar d)
        (.scalar d)
        .boolean)
  | mem (σ : SSort) :
      CoreHead
        { args := ([σ, .set σ] : List SSort)
          result := .boolean }

structure ExtHeadSpec (schema : HeadSchema) where
  name : Lean.Name

inductive Head : HeadSchema → Type where
  | core : CoreHead schema → Head schema
  | ext : ExtHeadSpec schema → Head schema

def diffHeadName : Lean.Name := `diff
def integralHeadName : Lean.Name := `integral
def limitHeadName : Lean.Name := `limit

end SymbolicLean
