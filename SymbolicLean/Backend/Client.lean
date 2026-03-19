import SymbolicLean.Backend.Decode
import SymbolicLean.Backend.Encode
import SymbolicLean.Session.Monad

namespace SymbolicLean

open Lean

private def adaptIO (kind : String) (message : String) : SymPyError :=
  .worker <|
    match kind with
    | "startup" => .startupFailed message
    | "shutdown" => .shutdownFailed message
    | _ => .requestFailed message

private def runIO (kind : String) (io : IO α) : SymPyM s α := do
  match (← io.toBaseIO) with
  | .ok value => pure value
  | .error err => throw <| adaptIO kind err.toString

private def workerScript (config : SessionConfig) : System.FilePath :=
  config.workerPath.getD "tools/sympy_worker.py"

private def spawnWorkerIO (config : SessionConfig) : IO WorkerProcess := do
  let child ← IO.Process.spawn
    { cmd := "python3"
      args := #[workerScript config |>.toString]
      stdin := .piped
      stdout := .piped
      stderr := .piped }
  let (stdin, child) ← child.takeStdin
  pure { stdin := stdin, child := child }

def startWorker : SymPyM s Unit := do
  let state ← get
  if state.worker.isSome then
    pure ()
  else
    let config := (← read).config
    let worker ← runIO "startup" <| spawnWorkerIO config
    modify fun st => { st with worker := some worker }

def stopWorker : SymPyM s Unit := do
  let state ← get
  match state.worker with
  | none => pure ()
  | some worker =>
      runIO "shutdown" worker.stdin.flush
      runIO "shutdown" worker.child.kill
      discard <| runIO "shutdown" worker.child.wait
      modify fun st => { st with worker := none }

private def nextRequestId : SymPyM s Nat := do
  let state ← get
  let requestId := state.nextRequestId
  modify fun st => { st with nextRequestId := requestId + 1 }
  pure requestId

private def getWorker : SymPyM s WorkerProcess := do
  startWorker
  match (← get).worker with
  | some worker => pure worker
  | none => throw <| .worker <| .startupFailed "worker state missing after startup"

private def rememberRef (ref : Ref) (sort : SSort) : SymPyM s Unit :=
  modify fun st => { st with liveRefs := st.liveRefs.insert ref sort }

private def forgetRefs (refs : List Ref) : SymPyM s Unit :=
  modify fun st =>
    let liveRefs := refs.foldl (fun acc ref => acc.erase ref) st.liveRefs
    let prettyCache := refs.foldl (fun acc ref => acc.erase ref) st.prettyCache
    { st with liveRefs := liveRefs, prettyCache := prettyCache }

def sendRequest (request : WorkerRequest) : SymPyM s WorkerResponse := do
  let worker ← getWorker
  let line := (toJson request).compress
  runIO "request" <| worker.stdin.putStrLn line
  runIO "request" <| worker.stdin.flush
  let responseLine ← runIO "request" <| worker.child.stdout.getLine
  if responseLine.isEmpty then
    throw <| .worker <| .requestFailed "worker closed stdout before replying"
  match parseResponseText responseLine with
  | .ok response => pure response
  | .error err => throw err

def pingWorker : SymPyM s PongInfo := do
  let request := pingRequest (← nextRequestId)
  decodePong (← sendRequest request)

def mkSymbolRemote (decl : SymDecl σ) : SymPyM s Ref := do
  let request := mkSymbolRequest (← nextRequestId) decl
  let ref ← decodeRef (← sendRequest request)
  rememberRef ref σ
  pure ref

def mkFunctionRemote (decl : FunDecl args ret) : SymPyM s Ref := do
  let request := mkFunctionRequest (← nextRequestId) decl
  let ref ← decodeRef (← sendRequest request)
  rememberRef ref (.fn args ret)
  pure ref

def evalTermRemote (term : Term σ) : SymPyM s Ref := do
  let request := evalTermRequest (← nextRequestId) term
  let ref ← decodeRef (← sendRequest request)
  rememberRef ref σ
  pure ref

def applyOpRemote (op : String) (target : Ref) (args : List Json := [])
    (kwargs : Json := Json.mkObj []) : SymPyM s WorkerResponse := do
  let request := applyOpRequest (← nextRequestId) op target.ident args kwargs
  sendRequest request

def applyOpRemoteRef (σ : SSort) (op : String) (target : Ref) (args : List Json := [])
    (kwargs : Json := Json.mkObj []) : SymPyM s Ref := do
  let ref ← decodeRef (← applyOpRemote op target args kwargs)
  rememberRef ref σ
  pure ref

def prettyRemote (target : Ref) : SymPyM s String := do
  let request := prettyRequest (← nextRequestId) target.ident
  let rendered ← decodePretty (← sendRequest request)
  modify fun st => { st with prettyCache := st.prettyCache.insert target rendered }
  pure rendered

def releaseRemote (refs : List Ref) : SymPyM s (List Ref) := do
  let request := releaseRequest (← nextRequestId) (refs.map Ref.ident)
  let released ← decodeReleased (← sendRequest request)
  forgetRefs released
  pure released

end SymbolicLean
