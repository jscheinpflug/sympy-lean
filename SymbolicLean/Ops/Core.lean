import SymbolicLean.Backend.Realize
import SymbolicLean.Ops.Algebra
import SymbolicLean.Ops.Calculus
import SymbolicLean.Ops.LinearAlgebra
import SymbolicLean.Ops.Solvers
import SymbolicLean.Term.Calculus
import SymbolicLean.Term.Logic

namespace SymbolicLean

open Lean Elab Command

private def elabGeneratedReceiverDef
    (ns : Name)
    (binders : Array Syntax)
    (name arg : TSyntax `ident)
    (extraBinders : Array Syntax)
    (argTy retTy body : TSyntax `term) : CommandElabM Unit := do
  let binders := binders.map TSyntax.mk
  let extraBinders := extraBinders.map TSyntax.mk
  let declName := ns ++ name.getId
  let declIdent := mkIdentFrom name declName
  elabCommand <| ← `(command|
    def $declIdent $binders* ($arg : $argTy) $extraBinders* : $retTy := $body)

private def elabGeneratedConstDef
    (ns : Name)
    (name : TSyntax `ident)
    (retTy body : TSyntax `term) : CommandElabM Unit := do
  let declName := ns ++ name.getId
  let declIdent := mkIdentFrom name declName
  elabCommand <| ← `(command|
    def $declIdent : $retTy := $body)

syntax "generate_term_method " ident bracketedBinder* " for " "(" ident " : " term ")" bracketedBinder*
  " returns " term
  " => " term : command
syntax "generate_symexpr_method " ident bracketedBinder* " for " "(" ident " : " term ")" bracketedBinder*
  " returns " term
  " => " term : command
syntax "generate_symdecl_method " ident bracketedBinder* " for " "(" ident " : " term ")" bracketedBinder*
  " returns " term
  " => " term : command
syntax "generate_sympy_alias " ident bracketedBinder* " for " "(" ident " : " term ")" bracketedBinder*
  " returns " term
  " => " term : command
syntax "generate_sympy_q_const " ident " returns " term " => " term : command
syntax "generate_sympy_s_const " ident " returns " term " => " term : command

elab_rules : command
  | `(generate_term_method $name $binders* for ($arg : $argTy) $extraBinders* returns $retTy => $body) =>
      elabGeneratedReceiverDef `Term (binders.map (·.raw)) name arg (extraBinders.map (·.raw)) argTy retTy body
  | `(generate_symexpr_method $name $binders* for ($arg : $argTy) $extraBinders* returns $retTy => $body) =>
      elabGeneratedReceiverDef `SymExpr (binders.map (·.raw)) name arg (extraBinders.map (·.raw)) argTy retTy body
  | `(generate_symdecl_method $name $binders* for ($arg : $argTy) $extraBinders* returns $retTy => $body) =>
      elabGeneratedReceiverDef `SymDecl (binders.map (·.raw)) name arg (extraBinders.map (·.raw)) argTy retTy body
  | `(generate_sympy_alias $name $binders* for ($arg : $argTy) $extraBinders* returns $retTy => $body) =>
      elabGeneratedReceiverDef `SymPy (binders.map (·.raw)) name arg (extraBinders.map (·.raw)) argTy retTy body
  | `(generate_sympy_q_const $name returns $retTy => $body) =>
      elabGeneratedConstDef `SymPy.Q name retTy body
  | `(generate_sympy_s_const $name returns $retTy => $body) =>
      elabGeneratedConstDef `SymPy.S name retTy body

class IntoSymExpr (s : SessionTok) (α : Type) (σ : outParam SSort) where
  intoSymExpr : α → SymPyM s (SymExpr s σ)

class IntoSymSymbol (s : SessionTok) (α : Type) (σ : outParam SSort) where
  intoSymSymbol : α → SymPyM s (SymSymbol s σ)

class IntoSymFun (s : SessionTok) (α : Type) (args : outParam (List SSort))
    (ret : outParam SSort) where
  intoSymFun : α → SymPyM s (SymFun s args ret)

instance : IntoSymExpr s (Term σ) σ where
  intoSymExpr := eval

instance : IntoSymExpr s (SymDecl σ) σ where
  intoSymExpr decl := eval (decl : Term σ)

instance : IntoSymExpr s (SymExpr s σ) σ where
  intoSymExpr expr := pure expr

instance : IntoSymExpr s Nat (.scalar (.ground .ZZ)) where
  intoSymExpr value := eval (Term.natLit value)

instance : IntoSymExpr s Int (.scalar (.ground .ZZ)) where
  intoSymExpr value := eval (Term.intLit value)

instance : IntoSymExpr s Rat (.scalar (.ground .QQ)) where
  intoSymExpr value := eval (Term.ratLit value)

instance : IntoSymSymbol s (SymDecl σ) σ where
  intoSymSymbol := realizeDecl

instance : IntoSymSymbol s (SymSymbol s σ) σ where
  intoSymSymbol symbol := pure symbol

instance : IntoSymFun s (FunDecl args ret) args ret where
  intoSymFun := realizeFun

instance : IntoSymFun s (SymFun s args ret) args ret where
  intoSymFun fun_ := pure fun_

def simplify [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  simplifyExpr (← IntoSymExpr.intoSymExpr expr)

def factor [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  factorExpr (← IntoSymExpr.intoSymExpr expr)

def expand [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  expandExpr (← IntoSymExpr.intoSymExpr expr)

def cancel [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  cancelExpr (← IntoSymExpr.intoSymExpr expr)

def substPair [IntoSymExpr s α σ] [IntoSymExpr s β τ] [SubstCompat σ τ]
    (fromExpr : α) (toExpr : β) : SymPyM s (SubstPair s) := do
  pure
    { fromSort := σ
      toSort := τ
      fromExpr := ← IntoSymExpr.intoSymExpr fromExpr
      toExpr := ← IntoSymExpr.intoSymExpr toExpr }

def substTermPair [SubstCompat σ τ]
    (fromExpr : Term σ) (toExpr : Term τ) : SymPyM s (SubstPair s) := do
  pure
    { fromSort := σ
      toSort := τ
      fromExpr := ← eval fromExpr
      toExpr := ← eval toExpr }

def subs [IntoSymExpr s α σ]
    (expr : α) (pairs : List (SymPyM s (SubstPair s))) : SymPyM s (SymExpr s σ) := do
  subsExpr (← IntoSymExpr.intoSymExpr expr) (← pairs.mapM id)

def solveUnivariate [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)]
    (expr : α) (x : β) : SymPyM s (FiniteSolve s (.scalar d)) := do
  solveUnivariateExpr (← IntoSymExpr.intoSymExpr expr) (← IntoSymSymbol.intoSymSymbol x)

def solveset [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)]
    (expr : α) (x : β) : SymPyM s (SolveSetResult s (.scalar d)) := do
  solvesetExpr (← IntoSymExpr.intoSymExpr expr) (← IntoSymSymbol.intoSymSymbol x)

def dsolve [IntoSymExpr s α .boolean] [IntoSymFun s β args ret]
    (ode : α) (f : β) : SymPyM s (ODESolution s) := do
  let _ ← IntoSymFun.intoSymFun f
  dsolveExpr (← IntoSymExpr.intoSymExpr ode)

def satisfiable [IntoSymExpr s α .boolean] (formula : α) : SymPyM s SatisfiableResult := do
  satisfiableExpr (← IntoSymExpr.intoSymExpr formula)

def ask [IntoSymSymbol s α (.scalar d)] (symbol : α) (query : Assumption) : SymPyM s Truth := do
  askSymbol (← IntoSymSymbol.intoSymSymbol symbol) query

def T [IntoSymExpr s α (.matrix d m n)] [DomainCarrier d] (matrix : α) :
    SymPyM s (SymExpr s (.matrix d n m)) := do
  transpose (← IntoSymExpr.intoSymExpr matrix)

def I [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] [InterpretsField d] (matrix : α) :
    SymPyM s (SymExpr s (.matrix d n n)) := do
  inv (← IntoSymExpr.intoSymExpr matrix)

generate_term_method simplify {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.Term σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.simplify expr

generate_term_method factor {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.Term σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.factor expr

generate_term_method expand {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.Term σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.expand expr

generate_term_method cancel {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.Term σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.cancel expr

generate_term_method T {s : SessionTok} {d : DomainDesc} {m n : Dim} [DomainCarrier d]
  for (matrix : SymbolicLean.Term (.matrix d m n))
  returns SymPyM s (SymExpr s (.matrix d n m)) => SymbolicLean.T matrix

generate_term_method I {s : SessionTok} {d : DomainDesc} {n : Dim}
  [DomainCarrier d] [InterpretsField d] for (matrix : SymbolicLean.Term (.matrix d n n))
  returns SymPyM s (SymExpr s (.matrix d n n)) => SymbolicLean.I matrix

generate_term_method subs {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.Term σ)
  (pairs : List (SymPyM s (SubstPair s))) returns SymPyM s (SymExpr s σ) =>
    SymbolicLean.subs expr pairs

generate_term_method solveUnivariate {s : SessionTok} {d : DomainDesc} {β : Type}
  [IntoSymSymbol s β (.scalar d)] for (expr : SymbolicLean.Term (.scalar d)) (x : β)
  returns SymPyM s (FiniteSolve s (.scalar d)) => SymbolicLean.solveUnivariate expr x

generate_term_method solveset {s : SessionTok} {d : DomainDesc} {β : Type}
  [IntoSymSymbol s β (.scalar d)] for (expr : SymbolicLean.Term (.scalar d)) (x : β)
  returns SymPyM s (SolveSetResult s (.scalar d)) => SymbolicLean.solveset expr x

generate_term_method dsolve {s : SessionTok} {β : Type} {args : List SSort} {ret : SSort}
  [IntoSymFun s β args ret] for (ode : SymbolicLean.Term .boolean) (f : β)
  returns SymPyM s (ODESolution s) => SymbolicLean.dsolve ode f

generate_term_method satisfiable {s : SessionTok} for (formula : SymbolicLean.Term .boolean)
  returns SymPyM s SatisfiableResult => SymbolicLean.satisfiable formula

generate_symexpr_method simplify {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.SymExpr s σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.simplify expr

generate_symexpr_method factor {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.SymExpr s σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.factor expr

generate_symexpr_method expand {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.SymExpr s σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.expand expr

generate_symexpr_method cancel {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.SymExpr s σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.cancel expr

generate_symexpr_method T {s : SessionTok} {d : DomainDesc} {m n : Dim} [DomainCarrier d]
  for (matrix : SymbolicLean.SymExpr s (.matrix d m n))
  returns SymPyM s (SymExpr s (.matrix d n m)) => SymbolicLean.T matrix

generate_symexpr_method I {s : SessionTok} {d : DomainDesc} {n : Dim}
  [DomainCarrier d] [InterpretsField d] for (matrix : SymbolicLean.SymExpr s (.matrix d n n))
  returns SymPyM s (SymExpr s (.matrix d n n)) => SymbolicLean.I matrix

generate_symexpr_method subs {s : SessionTok} {σ : SSort} for (expr : SymbolicLean.SymExpr s σ)
  (pairs : List (SymPyM s (SubstPair s))) returns SymPyM s (SymExpr s σ) =>
    SymbolicLean.subs expr pairs

generate_symexpr_method solveUnivariate {s : SessionTok} {d : DomainDesc} {β : Type}
  [IntoSymSymbol s β (.scalar d)] for (expr : SymbolicLean.SymExpr s (.scalar d)) (x : β)
  returns SymPyM s (FiniteSolve s (.scalar d)) => SymbolicLean.solveUnivariate expr x

generate_symexpr_method solveset {s : SessionTok} {d : DomainDesc} {β : Type}
  [IntoSymSymbol s β (.scalar d)] for (expr : SymbolicLean.SymExpr s (.scalar d)) (x : β)
  returns SymPyM s (SolveSetResult s (.scalar d)) => SymbolicLean.solveset expr x

generate_symexpr_method dsolve {s : SessionTok} {β : Type} {args : List SSort} {ret : SSort}
  [IntoSymFun s β args ret] for (ode : SymbolicLean.SymExpr s .boolean) (f : β)
  returns SymPyM s (ODESolution s) => SymbolicLean.dsolve ode f

generate_symexpr_method satisfiable {s : SessionTok}
  for (formula : SymbolicLean.SymExpr s .boolean)
  returns SymPyM s SatisfiableResult => SymbolicLean.satisfiable formula

generate_symdecl_method T {s : SessionTok} {d : DomainDesc} {m n : Dim} [DomainCarrier d]
  for (matrix : SymbolicLean.SymDecl (.matrix d m n))
  returns SymPyM s (SymExpr s (.matrix d n m)) => SymbolicLean.T matrix

generate_symdecl_method I {s : SessionTok} {d : DomainDesc} {n : Dim}
  [DomainCarrier d] [InterpretsField d] for (matrix : SymbolicLean.SymDecl (.matrix d n n))
  returns SymPyM s (SymExpr s (.matrix d n n)) => SymbolicLean.I matrix

generate_symdecl_method ask {s : SessionTok} {d : DomainDesc}
  for (symbol : SymbolicLean.SymDecl (.scalar d)) (query : Assumption)
  returns SymPyM s Truth => SymbolicLean.ask symbol query

generate_sympy_alias simplify {s : SessionTok} {α : Type} {σ : SSort} [IntoSymExpr s α σ]
  for (expr : α)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.simplify expr

generate_sympy_alias factor {s : SessionTok} {α : Type} {σ : SSort} [IntoSymExpr s α σ]
  for (expr : α)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.factor expr

generate_sympy_alias expand {s : SessionTok} {α : Type} {σ : SSort} [IntoSymExpr s α σ]
  for (expr : α)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.expand expr

generate_sympy_alias cancel {s : SessionTok} {α : Type} {σ : SSort} [IntoSymExpr s α σ]
  for (expr : α)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.cancel expr

generate_sympy_alias T {s : SessionTok} {α : Type} {d : DomainDesc} {m n : Dim}
  [IntoSymExpr s α (.matrix d m n)] [DomainCarrier d] for (matrix : α)
  returns SymPyM s (SymExpr s (.matrix d n m)) => SymbolicLean.T matrix

generate_sympy_alias I {s : SessionTok} {α : Type} {d : DomainDesc} {n : Dim}
  [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] [InterpretsField d] for (matrix : α)
  returns SymPyM s (SymExpr s (.matrix d n n)) => SymbolicLean.I matrix

generate_sympy_alias Derivative {σ : SSort} {d : DomainDesc}
  for (body : Term σ) (x : SymDecl (.scalar d)) (order : Nat := 1)
  returns Term σ => SymbolicLean.diff body x order

generate_sympy_alias Integral {d : DomainDesc}
  for (body : Term (.scalar d)) (x : SymDecl (.scalar d))
  returns Term (.scalar d) => SymbolicLean.integral body x

generate_sympy_alias Limit {d : DomainDesc}
  for (body : Term (.scalar d)) (x : SymDecl (.scalar d)) (atPoint : Term (.scalar d))
  returns Term (.scalar d) => SymbolicLean.limit body x atPoint

generate_sympy_q_const positive returns Assumption => .positive
generate_sympy_q_const nonnegative returns Assumption => .nonnegative
generate_sympy_q_const nonzero returns Assumption => .nonzero
generate_sympy_q_const integer returns Assumption => .integer
generate_sympy_q_const rational returns Assumption => .rational
generate_sympy_q_const real returns Assumption => .real
generate_sympy_q_const complex returns Assumption => .complex
generate_sympy_q_const finite returns Assumption => .finite
generate_sympy_q_const invertible returns Assumption => .invertible

generate_sympy_s_const true_ returns Term .boolean => SymbolicLean.verum
generate_sympy_s_const false_ returns Term .boolean => SymbolicLean.falsum

end SymbolicLean
