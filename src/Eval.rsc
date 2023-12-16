module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  return ();
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  return (); 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  return (); 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case intLit(int n): return vint(n);
    case strLit(str s): return vstr(s);
    case boolLit(bool b): return vbool(b);
    
    case add(AExpr left, AExpr right): return vint(eval(left, venv).n + eval(right, venv).n);
    case sub(AExpr left, AExpr right): return vint(eval(left, venv).n - eval(right, venv).n);
    case mul(AExpr left, AExpr right): return vint(eval(left, venv).n * eval(right, venv).n);
    case div(AExpr left, AExpr right): return vint(eval(left, venv).n / eval(right, venv).n);
    case eq(AExpr left, AExpr right): return vbool(eval(left, venv).n == eval(right, venv).n);
    case neq(AExpr left, AExpr right): return vbool(eval(left, venv).n != eval(right, venv).n);

    case lt(AExpr left, AExpr right): return vbool(eval(left, venv).n < eval(right, venv).n);
    case lte(AExpr left, AExpr right): return vbool(eval(left, venv).n <= eval(right, venv).n);
    case gt(AExpr left, AExpr right): return vbool(eval(left, venv).n > eval(right, venv).n);
    case gte(AExpr left, AExpr right): return vbool(eval(left, venv).n >= eval(right, venv).n);

    // etc.
    
    default: throw "Unsupported expression <e>";
  }
}