module CST2AST

import Syntax;
import AST;

import ParseTree;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  
  return form("", [ ], src=f.src); 
}

default AQuestion cst2ast(Question q) {
  switch(q) {
    case (SimpleQuestion sq)`<Str label> <Id i> : <Type t>`:
      return question(id("<id>", src=i.src), "<label>", cst2ast(t), src=q.src);
    case (CalculatedQuestion)`<Str label> <Id i> : <Type t> = <Expr e>`:
      return calculatedQuestion(id("<id>", src=i.src), "<label>", cst2ast(t), cst2ast(e), src=q.src);
    case ConditionalQuestion cq: {
      return conditionalQuestion(cst2ast(cq.e), [cst2ast(x) | x <- cq.ifquestions], [cst2ast(x) | x <- cq.elsequestions], src=q.src);
    }
  }
 
  throw "Not yet implemented <q>";
}


// `...` is a concrete syntax pattern which can be matched against the CST
AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=x.src);
    case (Expr)`<Expr e1> + <Expr e2>`: return add(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> - <Expr e2>`: return sub(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> * <Expr e2>`: return mul(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> / <Expr e2>`: return div(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \< <Expr e2>`: return lt(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \> <Expr e2>`: return gt(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \<= <Expr e2>`: return lte(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \>= <Expr e2>`: return gte(cst2ast(e1), cst2ast(e2), src=e.src);
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch(t) {
    case "boolean": return boolean(src=t.src);
    case "integer": return integer(src=t.src);
    case "string": return string(src=t.src);
    default: throw "Unknown type: <t>";
  }
}
