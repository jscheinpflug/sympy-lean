import SymbolicLean.Backend.Client
import SymbolicLean.Backend.Realize
import SymbolicLean.Session.Monad
import SymbolicLean.Syntax.Binders
import SymbolicLean.Syntax.Term

namespace SymbolicLean

open Lean Macro

syntax:lead "sympy " termBeforeDo " do " doSeq : term

macro_rules
  | `(sympy $d do $seq) =>
      `(letI : DefaultScalarDomain := { domain := $d };
        withSession {} fun _s => do
          $seq)

private partial def expandExploreSymTerm (d : TSyntax `term) (stx : TSyntax `symterm) :
    MacroM (TSyntax `term) := do
  match stx with
  | `(symterm| $n:num) => `(($n : Term (.scalar (.ground .ZZ))))
  | `(symterm| $id:ident) =>
      `(show Term (.scalar $d) from
          Term.atom (Atom.sym (mkDefaultSymbol $(quote id.getId))))
  | `(symterm| ($x:symterm)) => expandExploreSymTerm d x
  | `(symterm| - $x:symterm) => `(- $(← expandExploreSymTerm d x))
  | `(symterm| $x:symterm + $y:symterm) =>
      `($(← expandExploreSymTerm d x) + $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm - $y:symterm) =>
      `($(← expandExploreSymTerm d x) - $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm * $y:symterm) =>
      `($(← expandExploreSymTerm d x) * $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm / $y:symterm) =>
      `($(← expandExploreSymTerm d x) / $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm ^ $y:symterm) =>
      `($(← expandExploreSymTerm d x) ^ $(← expandExploreSymTerm d y))
  | `(symterm| ¬ $x:symterm) => `(not_ $(← expandExploreSymTerm d x))
  | `(symterm| $x:symterm ∧ $y:symterm) =>
      `(and_ $(← expandExploreSymTerm d x) $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm ∨ $y:symterm) =>
      `(or_ $(← expandExploreSymTerm d x) $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm = $y:symterm) =>
      `(eq_ $(← expandExploreSymTerm d x) $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm < $y:symterm) =>
      `(lt $(← expandExploreSymTerm d x) $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm ≤ $y:symterm) =>
      `(le $(← expandExploreSymTerm d x) $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm > $y:symterm) =>
      `(gt $(← expandExploreSymTerm d x) $(← expandExploreSymTerm d y))
  | `(symterm| $x:symterm ≥ $y:symterm) =>
      `(ge $(← expandExploreSymTerm d x) $(← expandExploreSymTerm d y))
  | `(symterm| $_x:symterm ∈ $_y:symterm) =>
      Macro.throwErrorAt stx "`#sympy` v1 does not auto-create set-valued names"
  | `(symterm| diff($_body:symterm, $_x:ident)) =>
      Macro.throwErrorAt stx "`#sympy` v1 does not auto-create differentiation variables"
  | `(symterm| diff($_body:symterm, $_x:ident, $_order:num)) =>
      Macro.throwErrorAt stx "`#sympy` v1 does not auto-create differentiation variables"
  | `(symterm| $_f:ident $_arg:symterm) =>
      Macro.throwErrorAt stx "`#sympy` v1 only auto-creates scalar symbols, not function symbols"
  | _ => Macro.throwUnsupported

elab "#sympy " d:term " => " body:symterm : command => do
  let expr ← Elab.liftMacroM <| expandExploreSymTerm d body
  Elab.Command.elabCommand (← `(command|
    #eval do
      let result ← sympy $d do
        let expr := $expr
        let realized ← eval expr
        prettyRemote realized.ref
      match result with
      | Except.ok text => IO.println text
      | Except.error err => IO.println (repr err)))

end SymbolicLean
