import SymbolicLean.Backend.Realize
import SymbolicLean.Ops.Algebra
import SymbolicLean.Ops.Solvers

namespace SymbolicLean

class IntoSymExpr (s : SessionTok) (α : Type) (σ : outParam SSort) where
  intoSymExpr : α → SymPyM s (SymExpr s σ)

class IntoSymSymbol (s : SessionTok) (α : Type) (σ : outParam SSort) where
  intoSymSymbol : α → SymPyM s (SymSymbol s σ)

class IntoSymFun (s : SessionTok) (α : Type) (args : outParam (List SSort))
    (ret : outParam SSort) where
  intoSymFun : α → SymPyM s (SymFun s args ret)

instance : IntoSymExpr s (Term σ) σ where
  intoSymExpr := eval

instance : IntoSymExpr s (SymExpr s σ) σ where
  intoSymExpr expr := pure expr

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

end SymbolicLean
