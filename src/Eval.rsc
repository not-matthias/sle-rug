module Eval

import AST;
import Resolve;
import IO;
import vis::Text;

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

Value Value_from_value(value v) {
  switch (v) {
    case int n: return vint(n);
    case bool b: return vbool(b);
    case str s: return vstr(s);
  }
  throw "Unsupported value <v>";
}

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);

  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  VEnv init = ();
  for (/AQuestion q <- f) {
    switch(q) {
      case question(id(name), _, AType qtype): {
        switch(qtype) {
          case integer(): init[name] = vint(0);
          case boolean(): init[name] = vbool(false);
          case string(): init[name] = vstr("");
        };
      }
      case calculatedQuestion(id(name), _, AType qtype, _): {
        switch(qtype) {
          case integer(): init[name] = vint(0);
          case boolean(): init[name] = vbool(false);
          case string(): init[name] = vstr("");
        };
      }
      default: { ; // nothing to do for other kinds of questions
      }
    }
    
  }

  return init;
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  
  // update venv with input
  venv[inp.question] = inp.\value;

  // evaluate questions using updated venv
  for (AQuestion q <- f.questions) {
    venv = eval(q, inp, venv);
  }
  return venv;
}


// keep track of questions currently being evaluated for cyclic dependencies


VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  switch (q) {
    case question(_, _, _): {
      // nothing to do for "input" question
      return venv;
    }
    case calculatedQuestion(AId id, _, _, AExpr expr): {
      // evaluate expr using current venv if needed
      venv = venv + (id.name: eval(expr, venv));

      return venv;
    }
    case ifQuestion(AExpr cond, qs): {
      // evaluate cond using venv
      if (eval(cond, venv).b) {
        
        // continue evaluation of branch
        for (AQuestion q <- qs) {
          venv = eval(q, inp, venv);
        }
        return venv;
      }
      else {
        return venv;
      }
    }
    case ifElseQuestion(AExpr cond, qs, qsElse): {
      if (eval(cond, venv).b) {
        for (AQuestion q <- qs) {
          venv = eval(q, inp, venv);
        }
        return venv;
      }
      else {
        for (AQuestion q <- qsElse) {
          venv = eval(q, inp, venv);
        }
        return venv;
      }
    } 
  }
  
  throw "Unsupported question in eval: <q>"; 
}

Value eval(AExpr e, VEnv venv) {
  
  switch (e) {
    case ref(id(str x)): {      
      return venv[x];
    }
    case intLit(int n): return vint(n);
    case strLit(str s): return vstr(s);
    case boolLit(bool b): return vbool(b);
    case add(AExpr left, AExpr right): return vint(eval(left, venv).n + eval(right, venv).n);
    case sub(AExpr left, AExpr right): return vint(eval(left, venv).n - eval(right, venv).n);
    case mul(AExpr left, AExpr right): return vint(eval(left, venv).n * eval(right, venv).n);
    case div(AExpr left, AExpr right): return vint(eval(left, venv).n / eval(right, venv).n);
    // BOOLEAN
    case not(AExpr e): return vbool(!eval(e, venv).b);
    case and(AExpr left, AExpr right): return vbool(eval(left, venv).b && eval(right, venv).b);
    case or(AExpr left, AExpr right): return vbool(eval(left, venv).b || eval(right, venv).b);
    // COMPARISON
    case equal(AExpr left, AExpr right): {
      l_val = eval(left, venv);
      r_val = eval(right, venv);

      switch(l_val) {
        case vint(n): return vbool(n == r_val.n);
        case vbool(b): return vbool(b == r_val.b);
        case vstr(s): return vbool(s == r_val.s);
        default: throw "Unexpected equal evaluation operand types <e>";
      }
    }
    case neq(AExpr left, AExpr right): {
      l_val = eval(left, venv);
      r_val = eval(right, venv);

      switch(l_val) {
        case vint(n): return vbool(n != r_val.n);
        case vbool(b): return vbool(b != r_val.b);
        case vstr(s): return vbool(s != r_val.s);
        default: throw "Unexpected inequlity evaluation operand types <e>";
      }
    }

    case lt(AExpr left, AExpr right): return vbool(eval(left, venv).n < eval(right, venv).n);
    case lte(AExpr left, AExpr right): return vbool(eval(left, venv).n <= eval(right, venv).n);
    case gt(AExpr left, AExpr right): return vbool(eval(left, venv).n > eval(right, venv).n);
    case gte(AExpr left, AExpr right): return vbool(eval(left, venv).n >= eval(right, venv).n);
    
    default: throw "Unsupported expression <e>";
  }
}