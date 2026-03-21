import Lean.Data.Json
import SymbolicLean.Backend.Protocol
import SymbolicLean.Term.Calculus
import SymbolicLean.Term.Head

namespace SymbolicLean

open Lean

private def mkTagged (tag : String) (fields : List (String × Json)) : Json :=
  Json.mkObj <| ("tag", toJson tag) :: fields

private def encodeDim : Dim → Json
  | .static value => mkTagged "static" [("value", toJson value)]
  | .dyn name => mkTagged "dyn" [("name", toJson name.toString)]

private def encodeSort : SSort → Json
  | .boolean => mkTagged "boolean" []
  | .scalar domain => mkTagged "scalar" [("domain", toJson domain)]
  | .matrix domain rows cols =>
      mkTagged "matrix" [("domain", toJson domain), ("rows", encodeDim rows), ("cols", encodeDim cols)]
  | .tensor domain dims =>
      mkTagged "tensor" [("domain", toJson domain), ("dims", toJson dims)]
  | .set elem =>
      mkTagged "set" [("elem", encodeSort elem)]
  | .tuple items =>
      mkTagged "tuple" [("items", toJson <| items.map encodeSort)]
  | .seq elem =>
      mkTagged "seq" [("elem", encodeSort elem)]
  | .map key value =>
      mkTagged "map" [("key", encodeSort key), ("value", encodeSort value)]
  | .fn args ret =>
      mkTagged "fn" [("args", toJson <| args.map encodeSort), ("ret", encodeSort ret)]
  | .relation rel args =>
      mkTagged "relationSort" [("kind", toJson rel), ("args", toJson <| args.map encodeSort)]
  | .ext ext =>
      mkTagged "ext" [("value", toJson ext)]

private def withSort (tag : String) (sort : SSort) (fields : List (String × Json)) : Json :=
  mkTagged tag (("sort", encodeSort sort) :: fields)

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

private def encodeHeadIdentity {schema : HeadSchema} (head : Head schema) : Json :=
  match head with
  | .core coreHead =>
      match coreHead with
      | @CoreHead.truth value =>
          Json.mkObj [("name", toJson "truth"), ("truth", encodeTruth value)]
      | @CoreHead.relation rel _ _ =>
          Json.mkObj [("name", toJson "relation"), ("rel", encodeRelKind rel)]
      | _ =>
          Json.mkObj [("name", toJson coreHead.backendName)]
  | .ext spec =>
      Json.mkObj [("name", toJson spec.name.toString)]

mutual

partial def encodeAtom : Atom σ → Json
  | @Atom.sym σ decl =>
      withSort "atomSym" σ
        [("name", toJson decl.name), ("assumptions", toJson decl.assumptions)]
  | @Atom.fun_ args ret decl =>
      withSort "atomFun" (.fn args ret) [("name", toJson decl.name), ("arity", toJson args.length)]

private partial def encodeHeadApp {schema : HeadSchema} (head : Head schema) (args : Args schema.args) : Json :=
  withSort "headApp" schema.result
    [("head", encodeHeadIdentity head), ("args", toJson (encodeArgs args))]

partial def encodeTerm : Term σ → Json
  | .atom atom => encodeAtom atom
  | .natLit value => withSort "natLit" σ [("value", toJson value)]
  | .intLit value => withSort "intLit" σ [("value", toJson value)]
  | .ratLit value =>
      withSort "ratLit" σ [("num", toJson value.num), ("den", toJson value.den)]
  | @Term.scalarAdd d1 d2 out _ lhs rhs =>
      encodeHeadApp (.core (.scalarAdd d1 d2 out)) (.pair lhs rhs)
  | @Term.scalarSub d1 d2 out _ lhs rhs =>
      encodeHeadApp (.core (.scalarSub d1 d2 out)) (.pair lhs rhs)
  | @Term.scalarMul d1 d2 out _ lhs rhs =>
      encodeHeadApp (.core (.scalarMul d1 d2 out)) (.pair lhs rhs)
  | @Term.scalarNeg d arg => encodeHeadApp (.core (.scalarNeg d)) (.singleton arg)
  | @Term.scalarDiv d lhs rhs => encodeHeadApp (.core (.scalarDiv d)) (.pair lhs rhs)
  | @Term.scalarPow d lhs rhs => encodeHeadApp (.core (.scalarPow d)) (.pair lhs rhs)
  | @Term.matrixAdd d m n lhs rhs => encodeHeadApp (.core (.matrixAdd d m n)) (.pair lhs rhs)
  | @Term.matrixSub d m n lhs rhs => encodeHeadApp (.core (.matrixSub d m n)) (.pair lhs rhs)
  | @Term.matrixMul d m n p lhs rhs => encodeHeadApp (.core (.matrixMul d m n p)) (.pair lhs rhs)
  | Term.truth value => encodeHeadApp (.core (.truth value)) .nil
  | Term.not_ arg => encodeHeadApp (.core .not_) (.singleton arg)
  | Term.and_ lhs rhs => encodeHeadApp (.core .and_) (.pair lhs rhs)
  | Term.or_ lhs rhs => encodeHeadApp (.core .or_) (.pair lhs rhs)
  | Term.implies lhs rhs => encodeHeadApp (.core .implies) (.pair lhs rhs)
  | Term.iff lhs rhs => encodeHeadApp (.core .iff) (.pair lhs rhs)
  | @Term.relation σ τ rel lhs rhs => encodeHeadApp (.core (.relation rel σ τ)) (.pair lhs rhs)
  | @Term.membership σ elem setTerm => encodeHeadApp (.core (.mem σ)) (.pair elem setTerm)
  | @Term.diff σ d body var order =>
      encodeHeadApp (.ext (diffHeadSpec σ d))
        (.cons body (.cons (var : Term (.scalar d)) (.cons (.natLit order) .nil)))
  | @Term.integral d body var =>
      encodeHeadApp (.ext (integralHeadSpec d)) (.pair body (var : Term (.scalar d)))
  | @Term.limit d body var value =>
      encodeHeadApp (.ext (limitHeadSpec d))
        (.cons body (.cons (var : Term (.scalar d)) (.cons value .nil)))
  | .headApp head args => encodeHeadApp head args
  | .app fn args =>
      withSort "app" σ [("fn", encodeTerm fn), ("args", toJson (encodeArgs args))]

partial def encodeArgs : Args σs → List Json
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
  payload := .mkSymbol { name := decl.name, assumptions := decl.assumptions, sort := encodeSort σ }

def mkFunctionRequest (id : Nat) (decl : FunDecl args ret) : WorkerRequest where
  id := id
  payload := .mkFunction { name := decl.name, arity := args.length, sort := encodeSort (.fn args ret) }

def evalTermRequest (id : Nat) (term : Term σ) : WorkerRequest where
  id := id
  payload := .evalTerm { term := encodeTerm term }

def applyOpRequest (id : Nat) (op : String) (target : WireRef)
    (args : List Json := []) (kwargs : Json := Json.mkObj []) : WorkerRequest where
  id := id
  payload := .applyOp { op := op, target := target, args := args, kwargs := kwargs }

def reifyRequest (id : Nat) (ref : WireRef) : WorkerRequest where
  id := id
  payload := .reify { ref := ref }

def prettyRequest (id : Nat) (ref : WireRef) : WorkerRequest where
  id := id
  payload := .pretty { ref := ref }

def releaseRequest (id : Nat) (refs : List WireRef) : WorkerRequest where
  id := id
  payload := .release { refs := refs }

end SymbolicLean
