import Lean.Data.Json
import SymbolicLean.Backend.Protocol
import SymbolicLean.Term.Core

namespace SymbolicLean

open Lean

private def mkTagged (tag : String) (fields : List (String × Json)) : Json :=
  Json.mkObj <| ("tag", toJson tag) :: fields

def encodeTruth : Truth → Json
  | .true_ => toJson "true"
  | .false_ => toJson "false"
  | .unknown => toJson "unknown"

def encodeRelKind : RelKind → Json
  | .eq => toJson "eq"
  | .ne => toJson "ne"
  | .lt => toJson "lt"
  | .le => toJson "le"
  | .gt => toJson "gt"
  | .ge => toJson "ge"
  | .mem => toJson "mem"
  | .subset => toJson "subset"

mutual

def encodeAtom : Atom σ → Json
  | .sym decl =>
      mkTagged "atomSym"
        [("name", toJson decl.name), ("assumptions", toJson decl.assumptions)]
  | @Atom.fun_ args _ decl =>
      mkTagged "atomFun" [("name", toJson decl.name), ("arity", toJson args.length)]

def encodeTerm : Term σ → Json
  | .atom atom => encodeAtom atom
  | .natLit value => mkTagged "natLit" [("value", toJson value)]
  | .intLit value => mkTagged "intLit" [("value", toJson value)]
  | .ratLit value =>
      mkTagged "ratLit" [("num", toJson value.num), ("den", toJson value.den)]
  | .scalarNeg arg => mkTagged "scalarNeg" [("arg", encodeTerm arg)]
  | @Term.scalarAdd _ _ _ _ lhs rhs =>
      mkTagged "scalarAdd" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | @Term.scalarSub _ _ _ _ lhs rhs =>
      mkTagged "scalarSub" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | @Term.scalarMul _ _ _ _ lhs rhs =>
      mkTagged "scalarMul" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .scalarDiv lhs rhs => mkTagged "scalarDiv" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .scalarPow lhs rhs => mkTagged "scalarPow" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .matrixAdd lhs rhs => mkTagged "matrixAdd" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .matrixSub lhs rhs => mkTagged "matrixSub" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .matrixMul lhs rhs => mkTagged "matrixMul" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .truth value => mkTagged "truth" [("value", encodeTruth value)]
  | .not_ arg => mkTagged "not" [("arg", encodeTerm arg)]
  | .and_ lhs rhs => mkTagged "and" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .or_ lhs rhs => mkTagged "or" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .implies lhs rhs => mkTagged "implies" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .iff lhs rhs => mkTagged "iff" [("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .relation rel lhs rhs =>
      mkTagged "relation"
        [("kind", encodeRelKind rel), ("lhs", encodeTerm lhs), ("rhs", encodeTerm rhs)]
  | .membership elem setTerm =>
      mkTagged "membership" [("elem", encodeTerm elem), ("set", encodeTerm setTerm)]
  | .diff body var order =>
      mkTagged "diff"
        [("body", encodeTerm body), ("var", toJson { name := var.name, assumptions := var.assumptions : SymbolSpec}), ("order", toJson order)]
  | .integral body var =>
      mkTagged "integral"
        [("body", encodeTerm body), ("var", toJson { name := var.name, assumptions := var.assumptions : SymbolSpec})]
  | .limit body var value =>
      mkTagged "limit"
        [("body", encodeTerm body), ("var", toJson { name := var.name, assumptions := var.assumptions : SymbolSpec}), ("value", encodeTerm value)]
  | .app fn args =>
      mkTagged "app" [("fn", encodeTerm fn), ("args", toJson (encodeArgs args))]

def encodeArgs : Args σs → List Json
  | .nil => []
  | .cons head tail => encodeTerm head :: encodeArgs tail

end

def encodeRefArg (ref : WireRef) : Json := Json.mkObj [("ref", toJson ref)]

def encodeTermArg (term : Term σ) : Json := Json.mkObj [("term", encodeTerm term)]

def pingRequest (id : Nat) : WorkerRequest where
  id := id
  payload := .ping

def mkSymbolRequest (id : Nat) (decl : SymDecl σ) : WorkerRequest where
  id := id
  payload := .mkSymbol { name := decl.name, assumptions := decl.assumptions }

def mkFunctionRequest (id : Nat) (decl : FunDecl args ret) : WorkerRequest where
  id := id
  payload := .mkFunction { name := decl.name, arity := args.length }

def evalTermRequest (id : Nat) (term : Term σ) : WorkerRequest where
  id := id
  payload := .evalTerm { term := encodeTerm term }

def applyOpRequest (id : Nat) (op : String) (target : WireRef)
    (args : List Json := []) (kwargs : Json := Json.mkObj []) : WorkerRequest where
  id := id
  payload := .applyOp { op := op, target := target, args := args, kwargs := kwargs }

def prettyRequest (id : Nat) (ref : WireRef) : WorkerRequest where
  id := id
  payload := .pretty { ref := ref }

def releaseRequest (id : Nat) (refs : List WireRef) : WorkerRequest where
  id := id
  payload := .release { refs := refs }

end SymbolicLean
