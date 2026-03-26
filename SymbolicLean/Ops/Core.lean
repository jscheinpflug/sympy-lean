import SymbolicLean.Backend.Realize
import SymbolicLean.Ops.Algebra
import SymbolicLean.Ops.Calculus
import SymbolicLean.Ops.Evaluation
import SymbolicLean.Ops.LinearAlgebra
import SymbolicLean.Ops.Solvers
import SymbolicLean.Syntax.StructuredArgs
import SymbolicLean.Term.Calculus
import SymbolicLean.Term.Logic
import SymbolicLean.Term.Sets
import SymbolicLean.Term.Structured

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

private def findSessionTokIdent? (binders : Array Syntax) : Option (TSyntax `ident) :=
  binders.findSome? fun binder =>
    match binder with
    | `(bracketedBinder| {$id:ident : SessionTok}) => some id
    | `(bracketedBinder| ($id:ident : SessionTok)) => some id
    | _ => none

private def mkReceiverArgTy (ns : Name) (sessionId? : Option (TSyntax `ident))
    (sortTy : TSyntax `term) : CommandElabM (TSyntax `term) := do
  match ns with
  | `Term => `(term| SymbolicLean.Term $sortTy)
  | `SymExpr =>
      let sessionId := sessionId?.getD (mkIdent `s)
      `(term| SymbolicLean.SymExpr $sessionId $sortTy)
  | `SymDecl => `(term| SymbolicLean.SymDecl $sortTy)
  | _ => throwError "unsupported generated receiver namespace {ns}"

private def elabGeneratedReceiverDefs
    (namespaces : Array Name)
    (binders : Array Syntax)
    (name arg : TSyntax `ident)
    (sortTy : TSyntax `term)
    (extraBinders : Array Syntax)
    (retTy body : TSyntax `term) : CommandElabM Unit := do
  let sessionId? := findSessionTokIdent? binders
  for ns in namespaces do
    let argTy ← mkReceiverArgTy ns sessionId? sortTy
    elabGeneratedReceiverDef ns binders name arg extraBinders argTy retTy body

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
syntax "generate_term_symexpr_methods " ident bracketedBinder*
  " for " "(" ident " : " term ")" bracketedBinder*
  " returns " term
  " => " term : command
syntax "generate_term_symexpr_symdecl_methods " ident bracketedBinder*
  " for " "(" ident " : " term ")" bracketedBinder*
  " returns " term
  " => " term : command

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
  | `(generate_term_symexpr_methods $name $binders* for ($arg : $sortTy) $extraBinders* returns $retTy => $body) =>
      elabGeneratedReceiverDefs #[`Term, `SymExpr] (binders.map (·.raw)) name arg sortTy
        (extraBinders.map (·.raw)) retTy body
  | `(generate_term_symexpr_symdecl_methods $name $binders* for ($arg : $sortTy) $extraBinders* returns $retTy => $body) =>
      elabGeneratedReceiverDefs #[`Term, `SymExpr, `SymDecl] (binders.map (·.raw)) name arg sortTy
        (extraBinders.map (·.raw)) retTy body

class IntoSymExpr (s : SessionTok) (α : Type) (σ : outParam SSort) where
  -- Public pure/effectful boundary conversion for APIs that operate on realized expressions.
  intoSymExpr : α → SymPyM s (SymExpr s σ)

class IntoSymSymbol (s : SessionTok) (α : Type) (σ : outParam SSort) where
  -- Public conversion for APIs that need a realized symbolic variable, not just any expression.
  intoSymSymbol : α → SymPyM s (SymSymbol s σ)

class IntoSymFun (s : SessionTok) (α : Type) (args : outParam (List SSort))
    (ret : outParam SSort) where
  -- Public conversion for APIs that need a realized function symbol.
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

def realize [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) :=
  IntoSymExpr.intoSymExpr expr

def simplify [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  simplifyExpr (← IntoSymExpr.intoSymExpr expr)

def factor [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  factorExpr (← IntoSymExpr.intoSymExpr expr)

def expand [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  expandExpr (← IntoSymExpr.intoSymExpr expr)

def cancel [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  cancelExpr (← IntoSymExpr.intoSymExpr expr)

def pretty [IntoSymExpr s α σ] (expr : α) : SymPyM s String := do
  prettyRemote (← IntoSymExpr.intoSymExpr expr).ref

def doit [IntoSymExpr s α σ] (expr : α) : SymPyM s (SymExpr s σ) := do
  doitExpr (← IntoSymExpr.intoSymExpr expr)

def evalf [IntoSymExpr s α (.scalar d)] (expr : α) (precision : Nat := 15) :
    SymPyM s (SymExpr s (.scalar d)) := do
  evalfExpr (← IntoSymExpr.intoSymExpr expr) precision

def latex [IntoSymExpr s α σ] (expr : α) : SymPyM s String := do
  latexText (← IntoSymExpr.intoSymExpr expr)

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

def integrate [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)]
    (expr : α) (x : β) : SymPyM s (SymExpr s (.scalar d)) := do
  integrateExpr (← IntoSymExpr.intoSymExpr expr) (← IntoSymSymbol.intoSymSymbol x)

def differentiate [IntoSymExpr s α σ] [IntoSymSymbol s β (.scalar d)]
    (expr : α) (x : β) (order : Nat := 1) : SymPyM s (SymExpr s σ) := do
  diffExpr (← IntoSymExpr.intoSymExpr expr) (← IntoSymSymbol.intoSymSymbol x) order

def limit [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)]
    [IntoSymExpr s γ (.scalar d)]
    (expr : α) (x : β) (atPoint : γ) : SymPyM s (SymExpr s (.scalar d)) := do
  limitExpr
    (← IntoSymExpr.intoSymExpr expr)
    (← IntoSymSymbol.intoSymSymbol x)
    (← IntoSymExpr.intoSymExpr atPoint)

def series [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)]
    [IntoSymExpr s γ (.scalar d)]
    (expr : α) (x : β) (atPoint : γ) (order : Nat) : SymPyM s (SymExpr s (.scalar d)) := do
  seriesExpr
    (← IntoSymExpr.intoSymExpr expr)
    (← IntoSymSymbol.intoSymSymbol x)
    (← IntoSymExpr.intoSymExpr atPoint)
    order

def solve [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)]
    (expr : α) (x : β) : SymPyM s (FiniteSolve s (.scalar d)) := do
  solveUnivariateExpr (← IntoSymExpr.intoSymExpr expr) (← IntoSymSymbol.intoSymSymbol x)

def solveUnivariate [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)]
    (expr : α) (x : β) : SymPyM s (FiniteSolve s (.scalar d)) := do
  solve expr x

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

def det [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] [InterpretsCommRing d] (matrix : α) :
    SymPyM s (SymExpr s (.scalar d)) := do
  detExpr (← IntoSymExpr.intoSymExpr matrix)

def rank [IntoSymExpr s α (.matrix d m n)] [DomainCarrier d] (matrix : α) :
    SymPyM s (SymExpr s (.scalar (.ground .ZZ))) := do
  rankExpr (← IntoSymExpr.intoSymExpr matrix)

def trace [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] (matrix : α) :
    SymPyM s (SymExpr s (.scalar d)) := do
  traceExpr (← IntoSymExpr.intoSymExpr matrix)

def adjugate [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] [InterpretsCommRing d]
    (matrix : α) : SymPyM s (SymExpr s (.matrix d n n)) := do
  adjugateExpr (← IntoSymExpr.intoSymExpr matrix)

def rref [IntoSymExpr s α (.matrix d m n)] [DomainCarrier d] [InterpretsField d] (matrix : α) :
    SymPyM s (RRefResult s d m n) := do
  rrefExpr (← IntoSymExpr.intoSymExpr matrix)

generate_term_symexpr_symdecl_methods pretty {s : SessionTok} {σ : SSort} for (expr : σ)
  returns SymPyM s String => SymbolicLean.pretty expr

generate_term_symexpr_symdecl_methods doit {s : SessionTok} {σ : SSort} for (expr : σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.doit expr

generate_term_symexpr_symdecl_methods latex {s : SessionTok} {σ : SSort} for (expr : σ)
  returns SymPyM s String => SymbolicLean.latex expr

generate_term_symexpr_symdecl_methods evalf {s : SessionTok} {d : DomainDesc}
  for (expr : (.scalar d)) (precision : Nat := 15)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.evalf expr precision

generate_term_symexpr_methods simplify {s : SessionTok} {σ : SSort} for (expr : σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.simplify expr

generate_term_symexpr_methods factor {s : SessionTok} {σ : SSort} for (expr : σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.factor expr

generate_term_symexpr_methods expand {s : SessionTok} {σ : SSort} for (expr : σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.expand expr

generate_term_symexpr_methods cancel {s : SessionTok} {σ : SSort} for (expr : σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.cancel expr

generate_term_symexpr_symdecl_methods T {s : SessionTok} {d : DomainDesc} {m n : Dim} [DomainCarrier d]
  for (matrix : (.matrix d m n))
  returns SymPyM s (SymExpr s (.matrix d n m)) => SymbolicLean.T matrix

generate_term_symexpr_symdecl_methods I {s : SessionTok} {d : DomainDesc} {n : Dim}
  [DomainCarrier d] [InterpretsField d] for (matrix : (.matrix d n n))
  returns SymPyM s (SymExpr s (.matrix d n n)) => SymbolicLean.I matrix

generate_term_symexpr_symdecl_methods det {s : SessionTok} {d : DomainDesc} {n : Dim}
  [DomainCarrier d] [InterpretsCommRing d] for (matrix : (.matrix d n n))
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.det matrix

generate_term_symexpr_symdecl_methods rank {s : SessionTok} {d : DomainDesc} {m n : Dim}
  [DomainCarrier d] for (matrix : (.matrix d m n))
  returns SymPyM s (SymExpr s (.scalar (.ground .ZZ))) => SymbolicLean.rank matrix

generate_term_symexpr_symdecl_methods trace {s : SessionTok} {d : DomainDesc} {n : Dim}
  [DomainCarrier d] for (matrix : (.matrix d n n))
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.trace matrix

generate_term_symexpr_symdecl_methods adjugate {s : SessionTok} {d : DomainDesc} {n : Dim}
  [DomainCarrier d] [InterpretsCommRing d] for (matrix : (.matrix d n n))
  returns SymPyM s (SymExpr s (.matrix d n n)) => SymbolicLean.adjugate matrix

generate_term_symexpr_symdecl_methods rref {s : SessionTok} {d : DomainDesc} {m n : Dim}
  [DomainCarrier d] [InterpretsField d] for (matrix : (.matrix d m n))
  returns SymPyM s (RRefResult s d m n) => SymbolicLean.rref matrix

generate_term_symexpr_methods subs {s : SessionTok} {σ : SSort} for (expr : σ)
  (pairs : List (SymPyM s (SubstPair s))) returns SymPyM s (SymExpr s σ) =>
    SymbolicLean.subs expr pairs

generate_term_symexpr_symdecl_methods integrate {s : SessionTok} {d : DomainDesc} {β : Type}
  [IntoSymSymbol s β (.scalar d)] for (expr : (.scalar d)) (x : β)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.integrate expr x

generate_term_symexpr_symdecl_methods differentiate {s : SessionTok} {σ : SSort} {d : DomainDesc}
  {β : Type} [IntoSymSymbol s β (.scalar d)] for (expr : σ) (x : β) (order : Nat := 1)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.differentiate expr x order

generate_symexpr_method limit {s : SessionTok} {d : DomainDesc} {β : Type} {γ : Type}
  [IntoSymSymbol s β (.scalar d)] [IntoSymExpr s γ (.scalar d)] for (expr : SymExpr s (.scalar d))
  (x : β) (atPoint : γ)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.limit expr x atPoint

generate_symdecl_method limit {s : SessionTok} {d : DomainDesc} {β : Type} {γ : Type}
  [IntoSymSymbol s β (.scalar d)] [IntoSymExpr s γ (.scalar d)] for (expr : SymDecl (.scalar d))
  (x : β) (atPoint : γ)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.limit expr x atPoint

generate_term_symexpr_symdecl_methods series {s : SessionTok} {d : DomainDesc} {β : Type} {γ : Type}
  [IntoSymSymbol s β (.scalar d)] [IntoSymExpr s γ (.scalar d)] for (expr : (.scalar d))
  (x : β) (atPoint : γ) (order : Nat)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.series expr x atPoint order

generate_term_symexpr_symdecl_methods solve {s : SessionTok} {d : DomainDesc} {β : Type}
  [IntoSymSymbol s β (.scalar d)] for (expr : (.scalar d)) (x : β)
  returns SymPyM s (FiniteSolve s (.scalar d)) => SymbolicLean.solve expr x

generate_term_symexpr_symdecl_methods solveUnivariate {s : SessionTok} {d : DomainDesc} {β : Type}
  [IntoSymSymbol s β (.scalar d)] for (expr : (.scalar d)) (x : β)
  returns SymPyM s (FiniteSolve s (.scalar d)) => SymbolicLean.solveUnivariate expr x

generate_term_symexpr_symdecl_methods solveset {s : SessionTok} {d : DomainDesc} {β : Type}
  [IntoSymSymbol s β (.scalar d)] for (expr : (.scalar d)) (x : β)
  returns SymPyM s (SolveSetResult s (.scalar d)) => SymbolicLean.solveset expr x

generate_term_symexpr_methods dsolve {s : SessionTok} {β : Type} {args : List SSort} {ret : SSort}
  [IntoSymFun s β args ret] for (ode : .boolean) (f : β)
  returns SymPyM s (ODESolution s) => SymbolicLean.dsolve ode f

generate_term_symexpr_methods satisfiable {s : SessionTok} for (formula : .boolean)
  returns SymPyM s SatisfiableResult => SymbolicLean.satisfiable formula

generate_symdecl_method ask {s : SessionTok} {d : DomainDesc}
  for (symbol : SymbolicLean.SymDecl (.scalar d)) (query : Assumption)
  returns SymPyM s Truth => SymbolicLean.ask symbol query

generate_term_symexpr_symdecl_methods realize {s : SessionTok} {σ : SSort} for (expr : σ)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.realize expr

generate_sympy_alias realize {s : SessionTok} {α : Type} {σ : SSort} [IntoSymExpr s α σ]
  for (expr : α)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.realize expr

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

generate_sympy_alias pretty {s : SessionTok} {α : Type} {σ : SSort} [IntoSymExpr s α σ]
  for (expr : α)
  returns SymPyM s String => SymbolicLean.pretty expr

generate_sympy_alias doit {s : SessionTok} {α : Type} {σ : SSort} [IntoSymExpr s α σ]
  for (expr : α)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.doit expr

generate_sympy_alias latex {s : SessionTok} {α : Type} {σ : SSort} [IntoSymExpr s α σ]
  for (expr : α)
  returns SymPyM s String => SymbolicLean.latex expr

generate_sympy_alias evalf {s : SessionTok} {α : Type} {d : DomainDesc}
  [IntoSymExpr s α (.scalar d)] for (expr : α) (precision : Nat := 15)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.evalf expr precision

generate_sympy_alias T {s : SessionTok} {α : Type} {d : DomainDesc} {m n : Dim}
  [IntoSymExpr s α (.matrix d m n)] [DomainCarrier d] for (matrix : α)
  returns SymPyM s (SymExpr s (.matrix d n m)) => SymbolicLean.T matrix

generate_sympy_alias I {s : SessionTok} {α : Type} {d : DomainDesc} {n : Dim}
  [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] [InterpretsField d] for (matrix : α)
  returns SymPyM s (SymExpr s (.matrix d n n)) => SymbolicLean.I matrix

generate_sympy_alias det {s : SessionTok} {α : Type} {d : DomainDesc} {n : Dim}
  [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] [InterpretsCommRing d] for (matrix : α)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.det matrix

generate_sympy_alias rank {s : SessionTok} {α : Type} {d : DomainDesc} {m n : Dim}
  [IntoSymExpr s α (.matrix d m n)] [DomainCarrier d] for (matrix : α)
  returns SymPyM s (SymExpr s (.scalar (.ground .ZZ))) => SymbolicLean.rank matrix

generate_sympy_alias trace {s : SessionTok} {α : Type} {d : DomainDesc} {n : Dim}
  [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] for (matrix : α)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.trace matrix

generate_sympy_alias adjugate {s : SessionTok} {α : Type} {d : DomainDesc} {n : Dim}
  [IntoSymExpr s α (.matrix d n n)] [DomainCarrier d] [InterpretsCommRing d] for (matrix : α)
  returns SymPyM s (SymExpr s (.matrix d n n)) => SymbolicLean.adjugate matrix

generate_sympy_alias rref {s : SessionTok} {α : Type} {d : DomainDesc} {m n : Dim}
  [IntoSymExpr s α (.matrix d m n)] [DomainCarrier d] [InterpretsField d] for (matrix : α)
  returns SymPyM s (RRefResult s d m n) => SymbolicLean.rref matrix

generate_sympy_alias integrate {s : SessionTok} {α : Type} {β : Type} {d : DomainDesc}
  [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)] for (expr : α) (x : β)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.integrate expr x

generate_sympy_alias differentiate {s : SessionTok} {α : Type} {β : Type} {σ : SSort} {d : DomainDesc}
  [IntoSymExpr s α σ] [IntoSymSymbol s β (.scalar d)] for (expr : α) (x : β) (order : Nat := 1)
  returns SymPyM s (SymExpr s σ) => SymbolicLean.differentiate expr x order

generate_sympy_alias limit {s : SessionTok} {α : Type} {β : Type} {γ : Type} {d : DomainDesc}
  [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)] [IntoSymExpr s γ (.scalar d)]
  for (expr : α) (x : β) (atPoint : γ)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.limit expr x atPoint

generate_sympy_alias series {s : SessionTok} {α : Type} {β : Type} {γ : Type} {d : DomainDesc}
  [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)] [IntoSymExpr s γ (.scalar d)]
  for (expr : α) (x : β) (atPoint : γ) (order : Nat)
  returns SymPyM s (SymExpr s (.scalar d)) => SymbolicLean.series expr x atPoint order

generate_sympy_alias solve {s : SessionTok} {α : Type} {β : Type} {d : DomainDesc}
  [IntoSymExpr s α (.scalar d)] [IntoSymSymbol s β (.scalar d)] for (expr : α) (x : β)
  returns SymPyM s (FiniteSolve s (.scalar d)) => SymbolicLean.solve expr x

generate_sympy_alias Derivative {σ : SSort} {d : DomainDesc}
  for (body : Term σ) (x : SymDecl (.scalar d)) (order : Nat := 1)
  returns Term σ => SymbolicLean.diff body x order

generate_sympy_alias Integral {d : DomainDesc} {α : Type} [IntoBoundSpec d α]
  for (body : Term (.scalar d)) (bound : α)
  returns Term (.scalar d) => SymbolicLean.integralWith body (IntoBoundSpec.intoBoundSpec bound)

generate_sympy_alias Sum {d : DomainDesc} {α : Type} {β : Type}
  [IntoScalarTerm α d] [IntoBoundSpec d β] for (body : α) (bound : β)
  returns Term (.scalar d) =>
    SymbolicLean.summation (IntoTerm.intoTerm body) (IntoBoundSpec.intoBoundSpec bound)

generate_sympy_alias Product {d : DomainDesc} {α : Type} {β : Type}
  [IntoScalarTerm α d] [IntoBoundSpec d β] for (body : α) (bound : β)
  returns Term (.scalar d) =>
    SymbolicLean.productTerm (IntoTerm.intoTerm body) (IntoBoundSpec.intoBoundSpec bound)

generate_sympy_alias Limit {d : DomainDesc} {α : Type} [IntoScalarTerm α d]
  for (body : Term (.scalar d)) (x : SymDecl (.scalar d)) (atPoint : α)
  returns Term (.scalar d) => SymbolicLean.limitTerm body x (IntoTerm.intoTerm atPoint)

generate_sympy_alias Piecewise {σ : SSort} {α : Type} {β : Type}
  [IntoPieceBranch σ α] [IntoTerm β σ] for (branch : α) (fallback : β)
  returns Term σ =>
    SymbolicLean.piecewise (IntoPieceBranch.intoPieceBranch branch) (IntoTerm.intoTerm fallback)

generate_sympy_q_const positive returns Assumption => .positive
generate_sympy_q_const negative returns Assumption => .negative
generate_sympy_q_const nonnegative returns Assumption => .nonnegative
generate_sympy_q_const nonpositive returns Assumption => .nonpositive
generate_sympy_q_const nonzero returns Assumption => .nonzero
generate_sympy_q_const zero returns Assumption => .zero
generate_sympy_q_const integer returns Assumption => .integer
generate_sympy_q_const rational returns Assumption => .rational
generate_sympy_q_const irrational returns Assumption => .irrational
generate_sympy_q_const real returns Assumption => .real
generate_sympy_q_const complex returns Assumption => .complex
generate_sympy_q_const imaginary returns Assumption => .imaginary
generate_sympy_q_const odd returns Assumption => .odd
generate_sympy_q_const even returns Assumption => .even
generate_sympy_q_const finite returns Assumption => .finite
generate_sympy_q_const infinite returns Assumption => .infinite
generate_sympy_q_const prime returns Assumption => .prime
generate_sympy_q_const invertible returns Assumption => .invertible

generate_sympy_s_const true_ returns Term .boolean => SymbolicLean.verum
generate_sympy_s_const false_ returns Term .boolean => SymbolicLean.falsum
generate_sympy_s_const Reals returns Term (.set (.scalar (.ground .RR))) => SymbolicLean.Reals
generate_sympy_s_const Complexes returns Term (.set (.scalar (.ground .CC))) => SymbolicLean.Complexes
generate_sympy_s_const Rationals returns Term (.set (.scalar (.ground .QQ))) => SymbolicLean.Rationals
generate_sympy_s_const Integers returns Term (.set (.scalar (.ground .ZZ))) => SymbolicLean.Integers
generate_sympy_s_const Naturals returns Term (.set (.scalar (.ground .ZZ))) => SymbolicLean.Naturals
generate_sympy_s_const Naturals0 returns Term (.set (.scalar (.ground .ZZ))) => SymbolicLean.Naturals0

def SymPy.S.EmptySet {d : DomainDesc} : Term (.set (.scalar d)) :=
  SymbolicLean.EmptySet

def SymPy.S.UniversalSet {d : DomainDesc} : Term (.set (.scalar d)) :=
  SymbolicLean.UniversalSet

end SymbolicLean
