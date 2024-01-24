module Check

import AST;
import Resolve;
import Message; // see standard library
import IO;


bool hasErrors(set[Message] msgs) {
  return { error(_, _) | error(_) <- msgs } != {};
}

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

// - [X] produce an error if there are declared questions with the same name but different types.
// - [X] duplicate labels should trigger a warning 
// - [X] the declared type computed questions should match the type of the expression.
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
      // declared questions with the same name but different types
      for (<a_loc, name, _, Type t1> <- tenv, <b_loc, name, _, Type t2> <- tenv, a_loc != b_loc, t1 != t2) {
        msgs += { error("Same question with different type", a_loc) };
      }
      // check computed type matches declared type
      if (typeOf(expr, tenv, useDef) != convertType(qtype)) {
        msgs += { error("Computed type does not match declared type", id.src) };
      }
    }
    case ifQuestion(AExpr expr, list[AQuestion] _): {
      // for this question match the type of the expression to boolean
      e_t = typeOf(expr, tenv, useDef);
      if (e_t != tbool()) {
        msgs += { error("If-expression type does not match boolean type got: <e_t>", expr.src) };
      }
    }
    case ifElseQuestion(AExpr expr, list[AQuestion] _, list[AQuestion] _): {
      // for this question match the type of the expression to boolean
      e_t = typeOf(expr, tenv, useDef);
      if (e_t != tbool()) {
        msgs += { error("If-else-expression does not match boolean type <e_t>", expr.src) };
      }
    }
    default: { println("default"); }
  }

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
    case ref(AId x): {
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
    }
    case intLit(_): { ; }
    case strLit(_): { ; }
    case boolLit(_): { ; }
    case add(lhs, rhs): { 
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Addition operands must be of type int", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Addition operands must be of type int", rhs.src) };
      }
     }
    case sub(lhs, rhs):{ 
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Subtraction operands must be of type int", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Subtraction operands must be of type int", rhs.src) };
      }
     }
    case mul(lhs, rhs):{ 
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Multiplication operands must be of type int", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Multiplication operands must be of type int", rhs.src) };
      }
     }
    case div(lhs, rhs):{ 
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Division numerator must be of type int", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Division denumerator must be of type int", rhs.src) };
      }
     }

    // BOOLEAN
    case not(lhs): {
      e_t = typeOf(lhs, tenv, useDef);
      if (e_t != tbool()) {
        msgs += { error("NOT operand must be of type bool got <e_t>", lhs.src) };
      }
    }
    case and(lhs, rhs): { 
      if (typeOf(lhs, tenv, useDef) != tbool()) {
        msgs += { error("AND operands must be of type bool", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += { error("AND operands must be of type bool", rhs.src) };
      }
    }
    case or(lhs, rhs): { 
      if (typeOf(lhs, tenv, useDef) != tbool()) {
        msgs += { error("OR operands must be of type bool", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += { error("OR operands must be of type bool", rhs.src) };
      }
    }
    case equal(lhs, rhs): { 
      //arithmetic, equality and logical equality
      left_t = typeOf(lhs, tenv, useDef);
      right_t = typeOf(rhs, tenv, useDef);

      if(left_t == tunknown()){
       msgs += { error("Equality operands cannot be type unknown", lhs.src) }; 
      }
      if(right_t == tunknown()){
       msgs += { error("Equality operands cannot be type unknown", lhs.src) }; 
      }

      // covers all known types 
      if (left_t != right_t) {
        // error for both locations
        msgs += { error("Equality operands must be of same type", lhs.src) };
        msgs += { error("Equality operands must be of same type", rhs.src) };
      }
    }
    case neq(lhs, rhs): { 
      //arithmetic equality and logical equality
      left_t = typeOf(lhs, tenv, useDef);
      right_t = typeOf(rhs, tenv, useDef);

      if(left_t == tunknown()){
       msgs += { error("Inequality operands cannot be type unknown", lhs.src) }; 
      }
      if(right_t == tunknown()){
       msgs += { error("Inequality operands cannot be type unknown", lhs.src) }; 
      }

      // covers all known types 
      if (left_t != right_t) {
        // error for both locations
        msgs += { error("Inequality operands must be of same type", lhs.src) };
        msgs += { error("Inequality operands must be of same type", rhs.src) };
      }
    }
    case lt(lhs, rhs): { 
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Less than operands must be of type int", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Less than operands must be of type int", rhs.src) };
      }
     }
    case lte(lhs, rhs): { 
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Less than or equal to operands must be of type int", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Less than or equal to operands must be of type int", rhs.src) };
      }
    }
    case gt(lhs, rhs): { 
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Greater than operands must be of type int", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Greater than operands must be of type int", rhs.src) };
      }
    }
    case gte(lhs, rhs): { 
      if (typeOf(lhs, tenv, useDef) != tint()) {
        msgs += { error("Greater than or equal to operands must be of type int", lhs.src) };
      }
      if (typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Greater than or equal to operands must be of type int", rhs.src) };
      }
    }
    default: { println("check(AExpr...): default case hit"); }
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):
      // lookup reference type  
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
    // BOOLEAN
    case and(lhs, rhs): return tbool();
    case or(lhs, rhs): return tbool();
    case not(lhs): return tbool();
    case equal(lhs, rhs): return tbool();
    case neq(lhs, rhs): return tbool();
    case lt(lhs, rhs): return tbool();
    case lte(lhs, rhs): return tbool();
    case gt(lhs, rhs): return tbool();
    case gte(lhs, rhs): return tbool();
  }
  println("typeOf default case hit! <e>");
  return tunknown(); 
}

 