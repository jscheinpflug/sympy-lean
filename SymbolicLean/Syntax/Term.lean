import Lean
import SymbolicLean.Term.Application
import SymbolicLean.Term.Arithmetic
import SymbolicLean.Term.Calculus
import SymbolicLean.Term.Logic
import SymbolicLean.Term.Relations

namespace SymbolicLean

open Lean Elab Term

declare_syntax_cat symterm

syntax ident : symterm
syntax:max num : symterm
syntax "(" symterm ")" : symterm
syntax:max "-" symterm:max : symterm
-- Match SymPy's precedence table in `sympy.printing.precedence`.
syntax:50 symterm:51 " * " symterm:50 : symterm
syntax:50 symterm:51 " / " symterm:50 : symterm
syntax:40 symterm:41 " + " symterm:40 : symterm
syntax:40 symterm:41 " - " symterm:40 : symterm
syntax:60 symterm:61 " ^ " symterm:60 : symterm
syntax:100 "¬ " symterm:100 : symterm
syntax:35 symterm:36 " = " symterm:35 : symterm
syntax:35 symterm:36 " < " symterm:35 : symterm
syntax:35 symterm:36 " ≤ " symterm:35 : symterm
syntax:35 symterm:36 " > " symterm:35 : symterm
syntax:35 symterm:36 " ≥ " symterm:35 : symterm
syntax:35 symterm:36 " ∈ " symterm:35 : symterm
syntax:30 symterm:31 " ∧ " symterm:30 : symterm
syntax:20 symterm:21 " ∨ " symterm:20 : symterm
syntax:max "diff(" symterm ", " ident ")" : symterm
syntax:max "diff(" symterm ", " ident ", " num ")" : symterm
syntax:70 ident symterm:70 : symterm

private def resolveIdentAsTerm (id : TSyntax `ident) : TermElabM (TSyntax `term) := do
  match (← getLCtx).findFromUserName? id.getId with
  | none => throwError "term! unknown identifier {id.getId}"
  | some decl =>
      let type ← Lean.Meta.inferType decl.toExpr
      let type ← instantiateMVars type
      let type ← Lean.Meta.withTransparency .all <| Lean.Meta.whnf type
      let type := type.cleanupAnnotations
      let head := type.getAppFn'.cleanupAnnotations
      if type.isAppOf ``Term || head.isConstOf ``Term then
        pure id
      else if type.isAppOf ``SymDecl || head.isConstOf ``SymDecl then
        let #[sort] := type.getAppArgs | unreachable!
        let sort ← Lean.Meta.withTransparency .all <| Lean.Meta.reduceAll (← instantiateMVars sort)
        let sort ← Lean.Elab.Term.exprToSyntax sort
        `(show Term $sort from Term.atom (Atom.sym $id))
      else if type.isAppOf ``FunDecl || head.isConstOf ``FunDecl then
        let #[args, ret] := type.getAppArgs | unreachable!
        let args ← Lean.Meta.withTransparency .all <| Lean.Meta.reduceAll (← instantiateMVars args)
        let ret ← Lean.Meta.withTransparency .all <| Lean.Meta.reduceAll (← instantiateMVars ret)
        let args ← Lean.Elab.Term.exprToSyntax args
        let ret ← Lean.Elab.Term.exprToSyntax ret
        `(show Term (.fn $args $ret) from Term.atom (Atom.fun_ $id))
      else
        throwError
          "term! expected {id.getId} to have type Term, SymDecl, or FunDecl, got {type}"

partial def expandSymTerm (stx : TSyntax `symterm) : TermElabM (TSyntax `term) := do
  match stx with
  | `(symterm| $n:num) => `(($n : Term (.scalar (.ground .ZZ))))
  | `(symterm| $id:ident) => resolveIdentAsTerm id
  | `(symterm| ($x:symterm)) => expandSymTerm x
  | `(symterm| - $x:symterm) => `(- $(← expandSymTerm x))
  | `(symterm| $x:symterm + $y:symterm) => `($(← expandSymTerm x) + $(← expandSymTerm y))
  | `(symterm| $x:symterm - $y:symterm) => `($(← expandSymTerm x) - $(← expandSymTerm y))
  | `(symterm| $x:symterm * $y:symterm) => `($(← expandSymTerm x) * $(← expandSymTerm y))
  | `(symterm| $x:symterm / $y:symterm) => `($(← expandSymTerm x) / $(← expandSymTerm y))
  | `(symterm| $x:symterm ^ $y:symterm) => `($(← expandSymTerm x) ^ $(← expandSymTerm y))
  | `(symterm| ¬ $x:symterm) => `(not_ $(← expandSymTerm x))
  | `(symterm| $x:symterm ∧ $y:symterm) => `(and_ $(← expandSymTerm x) $(← expandSymTerm y))
  | `(symterm| $x:symterm ∨ $y:symterm) => `(or_ $(← expandSymTerm x) $(← expandSymTerm y))
  | `(symterm| $x:symterm = $y:symterm) => `(eq_ $(← expandSymTerm x) $(← expandSymTerm y))
  | `(symterm| $x:symterm < $y:symterm) => `(lt $(← expandSymTerm x) $(← expandSymTerm y))
  | `(symterm| $x:symterm ≤ $y:symterm) => `(le $(← expandSymTerm x) $(← expandSymTerm y))
  | `(symterm| $x:symterm > $y:symterm) => `(gt $(← expandSymTerm x) $(← expandSymTerm y))
  | `(symterm| $x:symterm ≥ $y:symterm) => `(ge $(← expandSymTerm x) $(← expandSymTerm y))
  | `(symterm| $x:symterm ∈ $y:symterm) => `(mem $(← expandSymTerm x) $(← expandSymTerm y))
    | `(symterm| diff($body:symterm, $x:ident)) => `(diff $(← expandSymTerm body) $x)
    | `(symterm| diff($body:symterm, $x:ident, $order:num)) => `(diff $(← expandSymTerm body) $x $order)
    | `(symterm| $f:ident $arg:symterm) =>
        let fn ← resolveIdentAsTerm f
        `(apply1 $fn $(← expandSymTerm arg))
    | _ => throwUnsupportedSyntax

syntax "term![" symterm "]" : term

elab_rules : term
  | `(term![$t:symterm]) => do
      withoutAutoBoundImplicit do
        let expanded ← expandSymTerm t
        elabTerm expanded none

end SymbolicLean
