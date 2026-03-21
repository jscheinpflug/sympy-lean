import SymbolicLean.Term.Containers

namespace SymbolicLean

open Lean Macro

scoped macro:max container:term noWs "[" row:term "," col:term "]" : term =>
  `(index2 $container $row $col)

scoped macro:max container:term noWs "[" ":" "," col:term "]" : term =>
  `(sliceAt $container $col)

scoped macro:max container:term noWs "[" start:term ":" stop:term "]" : term =>
  `(sliceRange $container $start $stop)

scoped macro:max container:term noWs "[" index:term "]" : term =>
  `(index1 $container $index)

end SymbolicLean
