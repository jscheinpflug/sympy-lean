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

private def resetRemoteState : SessionState → SessionState :=
  fun st =>
    { st with
      worker := none
      workerReady := false
      liveRefs := {}
      declIntern := {}
      canonicalRefs := {}
      prettyCache := {} }

private def spawnWorkerIO (config : SessionConfig) : IO WorkerProcess := do
  let child ← IO.Process.spawn
    { cmd := "python3"
      args := #[workerScript config |>.toString]
      stdin := .piped
      stdout := .piped
      stderr := .piped }
  let (stdin, child) ← child.takeStdin
  pure { stdin := stdin, child := child }

private def cleanupWorkerIO (worker : WorkerProcess) : IO Unit := do
  try
    worker.stdin.flush
  catch _ =>
    pure ()
  try
    worker.child.kill
  catch _ =>
    pure ()
  try
    discard <| worker.child.wait
  catch _ =>
    pure ()

private def readLineWithTimeoutIO (worker : WorkerProcess) (timeoutMs : UInt32) : IO String := do
  let readTask ← IO.asTask do
    pure <| (← worker.child.stdout.getLine.toBaseIO)
  let timeoutTask ← IO.asTask do
    IO.sleep timeoutMs
    pure <| Except.error <| IO.userError "timed out waiting for worker response"
  let result : Except IO.Error String ← IO.ofExcept (← IO.waitAny [readTask, timeoutTask])
  IO.ofExcept result

private def readWorkerLine (kind : String) (worker : WorkerProcess) : SymPyM s String := do
  let timeoutMs := (← read).config.workerTimeoutMs
  match (← (readLineWithTimeoutIO worker timeoutMs).toBaseIO) with
  | .ok line => pure line
  | .error err =>
      runIO "shutdown" <| cleanupWorkerIO worker
      modify resetRemoteState
      throw <| adaptIO kind err.toString

def startWorker : SymPyM s Unit := do
  let state ← get
  if state.workerReady then
    pure ()
  else
    let config := (← read).config
    let worker ← runIO "startup" <| spawnWorkerIO config
    let pingLine := (toJson (pingRequest 0)).compress
    runIO "startup" <| worker.stdin.putStrLn pingLine
    runIO "startup" <| worker.stdin.flush
    let responseLine ← readWorkerLine "startup" worker
    if responseLine.isEmpty then
      throw <| .worker <| .startupFailed "worker closed stdout during startup ping"
    let pong ←
      match parseResponseText responseLine >>= decodePong with
      | .ok pong => pure pong
      | .error err => throw err
    if pong.manifestVersion != manifestVersion then
      throw <| .protocol <| .invalidResponse
        s!"worker manifest version mismatch: expected {manifestVersion}, got {pong.manifestVersion}"
    modify fun st => { st with worker := some worker, workerReady := true }

def stopWorker : SymPyM s Unit := do
  let state ← get
  match state.worker with
  | none => pure ()
  | some worker =>
      runIO "shutdown" <| cleanupWorkerIO worker
      modify resetRemoteState

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
  let responseLine ← readWorkerLine "request" worker
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

noncomputable def reifyRemote (σ : SSort) (target : Ref) : SymPyM s (Term σ) := do
  let request := reifyRequest (← nextRequestId) target.ident
  let payload ← decodeJsonInfo (← sendRequest request)
  match decodeTermAs σ payload with
  | .ok term => pure term
  | .error err => throw err

end SymbolicLean
