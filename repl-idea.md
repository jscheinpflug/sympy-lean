The key insight: Lean's InfoView in VSCode is already a live REPL. #check, #eval, custom # commands — they all display in the InfoView as you type. We just need to hook
  SymPy into it.

  Three levels of ambition

  Level 1: Works today with just a good API (no custom commands)

  #eval sympy! QQ do
    symbols x
    show (← simplify (← eval term![x^2 + 2*x + 1]))
  -- InfoView displays: (x + 1)^2

  #eval sympy! QQ do
    symbols x
    show (← solve (← eval term![x^2 - 1 = 0]) x)
  -- InfoView displays: [-1, 1]

  sympy! wraps withSession, runs the computation, and returns a String. #eval displays it. No custom commands needed — just a function that returns IO String.

  The caveat: #eval with IO can be flaky in the InfoView (re-evaluates unpredictably). But returning a pure String result from IO should be stable.

  Level 2: Custom #sympy command (reliable, clean)

  #sympy QQ diff(x^3, x)
  -- InfoView: 3*x^2

  #sympy QQ solve(x^2 + y - 1, x)
  -- InfoView: [1/2 - sqrt(4*y - 3)/2, 1/2 + sqrt(4*y - 3)/2]

  #sympy QQ simplify(sin(x)^2 + cos(x)^2)
  -- InfoView: 1

  A command elaborator that:
  1. Parses the expression (reusing the term! syntax category)
  2. Scans for free variables, auto-creates them as symbols
  3. Starts/reuses a SymPy session (via IO.Ref initialized once)
  4. Evals and asks SymPy for the string representation
  5. logInfo displays it in the InfoView

  initialize sessionRef : IO.Ref (Option SymPySession) ← IO.mkRef none

  elab "#sympy" d:ident body:sympyExpr : command => do
    let session ← getOrCreateSession d
    let freeVars := collectFreeVars body
    -- create symbols for freeVars, eval body, get string result
    let result ← liftIO (runSymPy session freeVars body)
    logInfo m!"{result}"

  This is reliable — logInfo in command elaborators is the standard way to display in the InfoView (it's how #check works). Session persists across multiple #sympy invocations
   in the same file via IO.Ref.

  Level 3: Widgets with LaTeX rendering (the dream)

  Using ProofWidgets4, render SymPy output as formatted math:

  #sympy QQ integrate(1/(x^2 + 1), x)
  -- InfoView shows: arctan(x) rendered in beautiful LaTeX

  The #sympy command asks SymPy for both the string repr and the LaTeX repr (sympy.latex(expr)), then renders via a KaTeX widget:

  @[widget_module] def sympyWidget : Widget.Module where
    javascript := "
      import * as React from 'react';
      export default function({latex, plain}) {
        // render LaTeX if available, fallback to plain text
        ...
      }
    "

  ProofWidgets4 already supports HTML-in-Lean syntax (#html <div>...</div>), so this could integrate cleanly.

  The multi-step session experience

  With persistent IO.Ref state, multiple commands in the same file share a session:

  -- Each line shows its result in InfoView when cursor is on it:
  #sympy QQ symbols x y

  #sympy QQ let expr = x^2 + 2*x*y + y^2

  #sympy QQ factor(expr)           -- (x + y)^2

  #sympy QQ diff(expr, x)          -- 2*x + 2*y

  #sympy QQ solve(expr, x)         -- [-y]

  The session and symbol bindings persist. Move your cursor to any line, see its result. This is a Jupyter-in-VSCode experience — but inside a .lean file, so you can
  transition from exploration to typed code seamlessly.

  What this means for the library design

  The #sympy REPL and the typed Term/Expr API are complementary:

  - #sympy for exploration: untyped, auto-symbol, quick feedback — like SymPy's Python REPL
  - sympy QQ do for production: typed, explicit, safe — the library's core value

  You explore with #sympy, then write proper typed code when you know what you want. Same file, same tool.