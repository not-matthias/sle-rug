module Transform

import Syntax;
import Resolve;
import AST;
import IO;
import ParseTree;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  AForm flat = form(f.name, []);
  for(q <- f.questions){
    flat.questions += flatten(q, boolLit(true));
  }
  
  return flat; 
}

list[AQuestion] flatten(AQuestion q, AExpr pre_cond) {
  switch(q){
    case question(id(name), _, _): {
      // BASE CASE
      AQuestion res = ifQuestion(pre_cond, [q]);
      //println("Flatten result <name>: <res.expr>");
      return [res];
    }
    case calculatedQuestion(id(name), _, _, _): {
      // BASE CASE
      AQuestion res = ifQuestion(pre_cond, [q]);
      //println("Flatten result <name>: <res.expr>");
      return [res];
    }
    case ifQuestion(AExpr e, list[AQuestion] qs): {
      // RECURSIVE CASE 
      list[AQuestion] res = [];
      for(x <- qs){
        res += flatten(x, and(pre_cond, e));
      }
      return res;
    }
    case ifElseQuestion(AExpr e, list[AQuestion] qs1, list[AQuestion] qs2): {
      // RECURSIVE CASE
      list[AQuestion] res = [];
      for(x <- qs1){
        res += flatten(x, and(pre_cond, e));
      }
      for(x <- qs2){
        res += flatten(x, and(pre_cond, not(e)));
      }
      return res;
    }
  }
  throw "Unreachable flatten case: <q>"; 
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
   
   // syntax has src loc

   // https://www.rascal-mpl.org/docs/Rascal/Expressions/Values/Relation/Subscription/
   // https://www.rascal-mpl.org/docs/Rascal/Expressions/Values/Relation/FieldProjection/

   
  set[loc] equivClass = { useOrDef };

  bool isDef = useOrDef in useDef<1>; // def has no corresponding def when used  
  if(isDef) {
    // add its uses
    equivClass += { u | <loc u, useOrDef> <- useDef };
  } else {
    // add its def
    if( <useOrDef, loc d> <- useDef) {
      equivClass += d;
      equivClass += { u | <loc u, d> <- useDef };
    }
  }

  // https://www.rascal-mpl.org/docs/Rascal/Expressions/Visit/
  updatedTree = visit(f) {
    case Id x => [Id] newName
      when x.src in equivClass
  }
  
  return updatedTree; 
} 
 
 
 

