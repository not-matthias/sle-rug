module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(AId name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(AId id, str label, AType qtype)
  | calculatedQuestion(AId id, str label, AType qtype, AExpr expr)
  | ifQuestion(AExpr expr, list[AQuestion] ifQuestions)
  | ifElseQuestion(AExpr expr, list[AQuestion] ifQuestions, list[AQuestion] elseQuestions)
  ;

/* So far no distinction between arithmetic expressions and boolean expressions
*/
data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | intLit(int integer)
  | strLit(str string)
  | boolLit(bool boolean)
  // ARITHMETIC
  | add(AExpr left, AExpr right)
  | sub(AExpr left, AExpr right)
  | mul(AExpr left, AExpr right)
  | div(AExpr left, AExpr right)
  // BOOLEAN
  | not(AExpr expr)
  | and(AExpr left, AExpr right)
  | or(AExpr left, AExpr right)
  // COMPARISON
  | equal(AExpr left, AExpr right)
  | neq(AExpr left, AExpr right)
  | lt(AExpr left, AExpr right)
  | lte(AExpr left, AExpr right)
  | gt(AExpr left, AExpr right)
  | gte(AExpr left, AExpr right)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
   = integer()
    | string()
    | boolean()
  ;