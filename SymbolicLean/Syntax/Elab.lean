import SymbolicLean.Syntax.Registry
import SymbolicLean.Term.Containers
import SymbolicLean.Term.Logic
import SymbolicLean.Term.Relations
import SymbolicLean.Term.Structured

namespace SymbolicLean

open Lean Elab Term Macro

declare_syntax_cat symCallArg

syntax term : symCallArg
syntax ident " := " term : symCallArg

syntax "symcall% " ident "(" symCallArg,* ")" : term

private def normalizeSurfaceName (name : String) : String :=
  match name with
  | "Derivative" => "diff"
  | "Integral" => "integral"
  | "Limit" => "limit"
  | "Sum" => "summation"
  | "Product" => "product"
  | "Lambda" => "lambda"
  | "Piecewise" => "piecewise"
  | other => other

private def findHeadEntry? (backend : String) : TermElabM (Option RegistryEntry) := do
  let backend := normalizeSurfaceName backend
  pure <| (registryEntries (← getEnv)).find? fun entry =>
    entry.kind == .head && entry.backendName == backend

private def throwCallError {α} (backend : String) (detail : String) : TermElabM α := do
  match ← findHeadEntry? backend with
  | some entry =>
      match entry.metadata.errorTemplate with
      | some template => throwError s!"{template}: {detail}"
      | none => throwError s!"invalid symbolic call for `{backend}`: {detail}"
  | none => throwError s!"unknown symbolic head `{backend}`"

private def ensureHeadRegistered (backend : String) : TermElabM Unit := do
  if (← findHeadEntry? backend).isNone then
    throwError s!"symbolic head `{backend}` is not registered"

private def splitCallArgs
    (args : Array (TSyntax `symCallArg)) :
    TermElabM (Array (TSyntax `term) × Array (String × TSyntax `term)) := do
  let mut positional : Array (TSyntax `term) := #[]
  let mut named : Array (String × TSyntax `term) := #[]
  for arg in args do
    match arg with
    | `(symCallArg| $term:term) =>
        positional := positional.push term
    | `(symCallArg| $name:ident := $term:term) =>
        named := named.push (name.getId.toString, term)
    | _ => throwUnsupportedSyntax
  pure (positional, named)

private def findNamed? (named : Array (String × TSyntax `term)) (key : String) :
    Option (TSyntax `term) :=
  named.findSome? fun (name, term) => if name = key then some term else none

private partial def foldBool (ctor : Name) (args : List (TSyntax `term)) :
    TermElabM (TSyntax `term) := do
  match args with
  | [] | [_] => throwError "expected at least two boolean arguments"
  | [lhs, rhs] =>
      let fn := mkIdent ctor
      `(term| $fn $lhs $rhs)
  | lhs :: rest => do
      let tail ← foldBool ctor rest
      let fn := mkIdent ctor
      `(term| $fn $lhs $tail)

private def mkBoundSpec
    (var : TSyntax `term) (lower? upper? : Option (TSyntax `term)) :
    TermElabM (TSyntax `term) := do
  match lower?, upper? with
  | none, none => `(term| ($var : BoundSpec _))
  | none, some upper => `(term| (show BoundSpec _ from ($var, $upper)))
  | some lower, none => `(term| ({ var := $var, lower? := some $lower : BoundSpec _ }))
  | some lower, some upper => `(term| (show BoundSpec _ from ($var, $lower, $upper)))

private def expandBackendCall
    (backend : String)
    (positional : Array (TSyntax `term))
    (named : Array (String × TSyntax `term)) :
    TermElabM (TSyntax `term) := do
  let backend := normalizeSurfaceName backend
  ensureHeadRegistered backend
  match backend with
  | "diff" =>
      match positional.toList with
      | [body, spec] => `(term| SymbolicLean.diffWith $body $spec)
      | [body, var, order] => `(term| SymbolicLean.diff $body $var $order)
      | [body] =>
          match findNamed? named "var", findNamed? named "order" with
          | some var, some order => `(term| SymbolicLean.diff $body $var $order)
          | some var, none => `(term| SymbolicLean.diffWith $body ($var : DerivSpec _ _))
          | _, _ =>
              throwCallError backend
                "expected `Derivative body var`, `Derivative body spec`, or named `var`"
      | _ => throwCallError backend "expected one, two, or three arguments"
  | "integral" =>
      match positional.toList with
      | [body, bound] => `(term| SymbolicLean.integralWith $body $bound)
      | [body] =>
          match findNamed? named "var", findNamed? named "lower", findNamed? named "upper" with
          | some var, lower?, upper? =>
              let bound ← mkBoundSpec var lower? upper?
              `(term| SymbolicLean.integralWith $body $bound)
          | _, _, _ =>
              throwCallError backend
                "expected `Integral body var`, `Integral body bound`, or named `var`"
      | _ => throwCallError backend "expected one or two arguments"
  | "limit" =>
      match positional.toList with
      | [body, var, atPoint] => `(term| SymbolicLean.limit $body $var $atPoint)
      | [body] =>
          match findNamed? named "var", findNamed? named "at" with
          | some var, some atPoint => `(term| SymbolicLean.limit $body $var $atPoint)
          | _, _ =>
              throwCallError backend
                "expected `Limit body var at` or named `var` and `at`"
      | _ => throwCallError backend "expected one or three arguments"
  | "summation" =>
      match positional.toList with
      | [body, bound] => `(term| SymbolicLean.summation $body $bound)
      | [body] =>
          match findNamed? named "var", findNamed? named "lower", findNamed? named "upper" with
          | some var, lower?, upper? =>
              let bound ← mkBoundSpec var lower? upper?
              `(term| SymbolicLean.summation $body $bound)
          | _, _, _ =>
              throwCallError backend "expected `Sum body bound` or named `var` with bounds"
      | _ => throwCallError backend "expected one or two arguments"
  | "product" =>
      match positional.toList with
      | [body, bound] => `(term| SymbolicLean.productTerm $body $bound)
      | [body] =>
          match findNamed? named "var", findNamed? named "lower", findNamed? named "upper" with
          | some var, lower?, upper? =>
              let bound ← mkBoundSpec var lower? upper?
              `(term| SymbolicLean.productTerm $body $bound)
          | _, _, _ =>
              throwCallError backend
                "expected `Product body bound` or named `var` with bounds"
      | _ => throwCallError backend "expected one or two arguments"
  | "lambda" =>
      match positional.toList with
      | [body, var] => `(term| SymbolicLean.lambdaTerm $body $var)
      | [body] =>
          match findNamed? named "var" with
          | some var => `(term| SymbolicLean.lambdaTerm $body $var)
          | none => throwCallError backend "expected `Lambda body var` or named `var`"
      | _ => throwCallError backend "expected one or two arguments"
  | "piecewise" =>
      match positional.toList with
      | [branch, fallback] => `(term| SymbolicLean.piecewise $branch $fallback)
      | [body] =>
          match findNamed? named "if", findNamed? named "otherwise" with
          | some cond, some fallback =>
              `(term| SymbolicLean.piecewise (show PieceBranch _ from ($body, $cond)) $fallback)
          | _, _ =>
              throwCallError backend
                "expected `Piecewise branch fallback` or named `if` and `otherwise`"
      | _ => throwCallError backend "expected one or two arguments"
  | "and" =>
      if !named.isEmpty then
        throwCallError backend "named arguments are not supported for variadic boolean conjunction"
      foldBool ``SymbolicLean.and_ positional.toList
  | "or" =>
      if !named.isEmpty then
        throwCallError backend "named arguments are not supported for variadic boolean disjunction"
      foldBool ``SymbolicLean.or_ positional.toList
  | _ => throwCallError backend "no elaboration rule is defined for this head"

private def expandSymcall
    (surface : TSyntax `ident) (args : Array (TSyntax `symCallArg)) :
    TermElabM (TSyntax `term) := do
  let (positional, named) ← splitCallArgs args
  expandBackendCall surface.getId.toString positional named

elab_rules : term
  | `(symcall% $name:ident ($args:symCallArg,*)) => do
      let expanded ← expandSymcall name args.getElems
      elabTerm expanded none

def Derivative (body : Term σ) (spec : DerivSpec σ d) : Term σ :=
  diffWith body spec

def Integral (body : Term (.scalar d)) (bound : BoundSpec d) : Term (.scalar d) :=
  integralWith body bound

def Limit (body : Term (.scalar d)) (x : SymDecl (.scalar d)) (atPoint : Term (.scalar d)) :
    Term (.scalar d) :=
  limit body x atPoint

def Sum (body : Term (.scalar d)) (bound : BoundSpec d) : Term (.scalar d) :=
  summation body bound

def Product (body : Term (.scalar d)) (bound : BoundSpec d) : Term (.scalar d) :=
  productTerm body bound

def Lambda (body : Term σ) (x : SymDecl (.scalar d)) : Term (.fn [.scalar d] σ) :=
  lambdaTerm body x

def Piecewise (branch : PieceBranch σ) (fallback : Term σ) : Term σ :=
  piecewise branch fallback

end SymbolicLean
