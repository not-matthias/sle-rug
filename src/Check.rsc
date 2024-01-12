module Check

import AST;
import Resolve;
import Message; // see standard library
import IO;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  TEnv tenv = {};
  
  // TODO: If/IfElse questions? -> no, they only consume env (no new bindings)
  visit (f) {
    case question(id, label, ty):
      tenv += { <id.src, id.name, label, convertType(ty)> };
    case calculatedQuestion(id, label, ty, _):
      tenv += { <id.src, id.name, label, convertType(ty)> }; // independent of expression type
  }

  return tenv;
}

Type convertType(AType ty) {
  switch(ty) {
  	case integer(): return tint();
  	case boolean(): return tbool();
  	case string(): return tstr();
  	default: return tunknown();
  }
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  // check for duplicate questions
  for (/AQuestion q <- f) {
    msgs += check(q, tenv, useDef);
  }
  
  return msgs;
}


// wrapper for convenience
set[Message] check(AForm f) { 
  return check(f, collect(f), resolve(f).useDef);
}

// - [ ] produce an error if there are declared questions with the same name but different types.
// - [X] duplicate labels should trigger a warning 
// - [ ] the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch(q) {
    case question( id, str label, AType _): {
      // check for duplicate labels
      for( <a_loc, _, label, _> <- tenv, <b_loc, _, label, _> <- tenv, a_loc != b_loc, (label notin {""})) {
        msgs += { warning("Duplicate label", a_loc) };
      }
      // declared questions with the same name but different types
      for (<a_loc, name, _, Type t1> <- tenv, <b_loc, name, _, Type t2> <- tenv, a_loc != b_loc, t1 != t2) {
        msgs += { error("Same question with different type", a_loc) };
      }
    }
    case calculatedQuestion(AId id, str label, AType qtype, AExpr expr): { 
      // check for duplicate labels
      for( <a_loc, _, label, _> <- tenv, <b_loc, _, label, _> <- tenv, a_loc != b_loc, (label notin {""})) {
        msgs += { warning("Duplicate label", a_loc) };
      }
    }
    default: { println("default"); }
  }



  // check for type compatibility between declared type and expression type

  // check each expression
  for (/AExpr expr <- q) {
    msgs += check(expr, tenv, useDef);
  }

  return msgs; 
}


// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    case intLit(_): return tint();
    case strLit(_): return tstr();
    case boolLit(_): return tbool();
    case add(lhs, rhs): return tint();
    case sub(lhs, rhs): return tint();
    case mul(lhs, rhs): return tint();
    case div(lhs, rhs): return tint();
    case eq(lhs, rhs): return tbool();
    case neq(lhs, rhs): return tbool();
    case lt(lhs, rhs): return tbool();
    case lte(lhs, rhs): return tbool();
    case gt(lhs, rhs): return tbool();
    case gte(lhs, rhs): return tbool();
    default: return tunknown();
  }
  
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

