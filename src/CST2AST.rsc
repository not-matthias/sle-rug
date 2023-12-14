module CST2AST

import Syntax;
import AST;
import ParseTree;
import String;
import Boolean;

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
  switch(q) {
    case (Question)`<Str label> <Id i> : <Type t> = <Expr e>`:
      return calculatedQuestion(id("<i>", src=i.src), "<label>", cst2ast(t), cst2ast(e), src=q.src);

    case (Question)`<Str label> <Id i> : <Type t>`:
      return question(id("<i>", src=i.src), "<label>", cst2ast(t), src=q.src);
      
    case (Question) `if ( <Expr cond> ) { <Question* ifQuestions> } else { <Question* elseQuestions> }`: 
      return ifElseQuestion(cst2ast(cond), [cst2ast(x) | x <- ifQuestions], [cst2ast(x) | x <- elseQuestions], src=q.src);

    case (Question) `if ( <Expr cond> ) { <Question* ifQuestions> }`: 
      return ifQuestion(cst2ast(cond), [cst2ast(x) | x <- ifQuestions], src=q.src);

    default: throw "Unhandled question: <q>";
  }
}

// `...` is a concrete syntax pattern which can be matched against the CST
AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=e.src);
    case (Expr)`<Int n>`: return intLit(toInt("<n>"), src=n.src);
    case (Expr)`<Str s>`: return strLit("<s>", src=s.src);
    case (Expr)`<Bool b>`: return boolLit(fromString("<b>"), src=b.src);
    case (Expr)`(<Expr e>)`: return cst2ast(e);

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
