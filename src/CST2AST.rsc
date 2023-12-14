module CST2AST

import Syntax;
import AST;
import ParseTree;

import IO; //for println

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
  
  switch (f) {
    case (Form)`form <Id name> { <Question* questions> }`:
      return form(id("<name>", src=name.src), [cst2ast(q) | Question q <- questions], src=f.src);
      default: throw "Unhandled form: <f>";
  }
}

default AQuestion cst2ast(Question q) {
  println(q);

  switch(q) {
    case (Question)`<Str label> <Id i> : <Type t>`:
      return question(id("<i>", src=i.src), "<label>", cst2ast(t), src=q.src);
      
    case (Question)`<Str label> <Id i> : <Type t> = <Expr e>`:
      return calculatedQuestion(id("<i>", src=i.src), "<label>", cst2ast(t), cst2ast(e), src=q.src);

    case (Question) cq: {
      //return conditionalQuestion(cst2ast(cq.e), [cst2ast(x) | x <- cq.ifquestions], [cst2ast(x) | x <- cq.elsequestions], src=q.src);
      throw "case cq";
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
  println(t); // does indeed get printed!! xD
  switch(t) {
    case (Type)`boolean`: return boolean(src=t.src);
    case (Type)`integer`: return integer(src=t.src);
    case (Type)`string`: return string(src=t.src);
    default: throw "Unknown type: <t>";
  }
}
