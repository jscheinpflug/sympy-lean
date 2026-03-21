import SymbolicLean.Term.Core

namespace SymbolicLean

def indexHeadName : Lean.Name := `getitem
def index2HeadName : Lean.Name := `getitem2
def sliceAtHeadName : Lean.Name := `sliceAt
def sliceRangeHeadName : Lean.Name := `sliceRange
def dictEmptyHeadName : Lean.Name := `dictEmpty
def dictInsertHeadName : Lean.Name := `dictInsert

private def indexHeadSpec (σ : SSort) (ι : SSort) (ρ : SSort) :
    ExtHeadSpec { args := [σ, ι], result := ρ } :=
  { name := indexHeadName }

private def index2HeadSpec (σ : SSort) (ι : SSort) (κ : SSort) (ρ : SSort) :
    ExtHeadSpec { args := [σ, ι, κ], result := ρ } :=
  { name := index2HeadName }

private def sliceAtHeadSpec (σ : SSort) (ρ : SSort) :
    ExtHeadSpec { args := [σ, .scalar (.ground .ZZ)], result := ρ } :=
  { name := sliceAtHeadName }

private def sliceRangeHeadSpec (σ : SSort) (ρ : SSort) :
    ExtHeadSpec { args := [σ, .scalar (.ground .ZZ), .scalar (.ground .ZZ)], result := ρ } :=
  { name := sliceRangeHeadName }

private def dictEmptyHeadSpec (κ ν : SSort) :
    ExtHeadSpec (HeadSchema.nullary (.map κ ν)) :=
  { name := dictEmptyHeadName }

private def dictInsertHeadSpec (κ ν : SSort) :
    ExtHeadSpec { args := [.map κ ν, κ, ν], result := .map κ ν } :=
  { name := dictInsertHeadName }

def index1 (container : Term σ) (index : Term ι) : Term ρ :=
  .headApp (.ext (indexHeadSpec σ ι ρ)) (.pair container index)

def index2 (container : Term σ) (row : Term ι) (col : Term κ) : Term ρ :=
  .headApp (.ext (index2HeadSpec σ ι κ ρ)) (.cons container (.cons row (.cons col .nil)))

def sliceAt (container : Term σ) (index : Term (.scalar (.ground .ZZ))) : Term ρ :=
  .headApp (.ext (sliceAtHeadSpec σ ρ)) (.pair container index)

def sliceRange (container : Term σ) (start stop : Term (.scalar (.ground .ZZ))) : Term ρ :=
  .headApp (.ext (sliceRangeHeadSpec σ ρ)) (.cons container (.cons start (.cons stop .nil)))

def dictEmpty : Term (.map κ ν) :=
  .headApp (.ext (dictEmptyHeadSpec κ ν)) .nil

def dictInsert (dict : Term (.map κ ν)) (key : Term κ) (value : Term ν) : Term (.map κ ν) :=
  .headApp (.ext (dictInsertHeadSpec κ ν)) (.cons dict (.cons key (.cons value .nil)))

end SymbolicLean
