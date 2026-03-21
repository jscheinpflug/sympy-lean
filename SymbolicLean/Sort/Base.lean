import Lean.Data.Json
import SymbolicLean.Domain.Dim
import SymbolicLean.Domain.Desc
import SymbolicLean.Sort.Relations
import SymbolicLean.Sort.Ext

namespace SymbolicLean

open Lean

inductive SymSort (ext : Type) where
  | boolean
  | scalar : DomainDesc → SymSort ext
  | matrix : DomainDesc → Dim → Dim → SymSort ext
  | tensor : DomainDesc → List Dim → SymSort ext
  | set : SymSort ext → SymSort ext
  | tuple : List (SymSort ext) → SymSort ext
  | seq : SymSort ext → SymSort ext
  | map : SymSort ext → SymSort ext → SymSort ext
  | fn : List (SymSort ext) → SymSort ext → SymSort ext
  | relation : RelKind → List (SymSort ext) → SymSort ext
  | ext : ext → SymSort ext
  deriving Repr, BEq, Hashable, ToJson, FromJson

noncomputable instance [DecidableEq ext] : DecidableEq (SymSort ext) := by
  classical
  infer_instance

abbrev SSort := SymSort SymExt

end SymbolicLean
