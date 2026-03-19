namespace SymbolicLean

inductive WorkerError where
  | startupFailed : String → WorkerError
  | requestFailed : String → WorkerError
  | shutdownFailed : String → WorkerError
  deriving Repr, DecidableEq, Inhabited

inductive DecodeError where
  | missingField : String → DecodeError
  | unexpectedTag : String → DecodeError
  | malformedPayload : String → DecodeError
  deriving Repr, DecidableEq, Inhabited

inductive ProtocolError where
  | invalidRequest : String → ProtocolError
  | invalidResponse : String → ProtocolError
  deriving Repr, DecidableEq, Inhabited

inductive SymPyError where
  | worker : WorkerError → SymPyError
  | decode : DecodeError → SymPyError
  | protocol : ProtocolError → SymPyError
  | user : String → SymPyError
  deriving Repr, DecidableEq, Inhabited

end SymbolicLean
