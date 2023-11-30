module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Question* questions "}"; 

syntax SimpleQuestion = Str Id id ":" Type type ("=" Expr expr)?;
syntax ConditionalQuestion = "if" "(" Expr expr ")" "{" Question* questions "}" ("else" "{" Question* questions "}")?;

syntax Question = SimpleQuestion | ConditionalQuestion;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  ;
  
syntax Type = "boolean" | "integer" | "string";

lexical Str = [a-zA-Z][a-zA-Z0-9]*;

lexical Int = [0-9]+;

lexical Bool = "true" | "false";



