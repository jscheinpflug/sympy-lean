import SymbolicLean.Session.Errors
import SymbolicLean.Session.State

namespace SymbolicLean

abbrev SymPyM (_s : SessionTok) :=
  ReaderT SessionEnv <| StateT SessionState <| ExceptT SymPyError IO

def withSession (config : SessionConfig) (k : ∀ s : SessionTok, SymPyM s α) :
    IO (Except SymPyError α) := do
  let env : SessionEnv := { config := config }
  let init : SessionState := {}
  let tok : SessionTok := { nonce := ← IO.monoNanosNow }
  match (← (((k tok).run env).run init).run) with
  | .error err => return .error err
  | .ok (value, _) => return .ok value

end SymbolicLean
