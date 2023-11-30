module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id "{" Question* "}"; 

//syntax SimpleQuestion = Label Id ":" Type;
syntax SimpleQuestion = Label;
//syntax CalculatedQuestion = Label l Id id ":" Type "=" Expr expr;
//syntax ConditionalQuestion = "if" "(" Expr expr ")" "{" Question* questions "}" ("else" "{" Question* questions "}")?;

syntax Question = SimpleQuestion;

//keyword ControlKeywords = "if" | "else";

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
/* syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  ; */
  
syntax Type = "boolean" | "integer" | "string";

syntax Label = LabelLiteral;

//regex: https://www.rascal-mpl.org/docs/Rascal/Patterns/Regular/
lexical LabelLiteral = [\"][a-zA-Z0-9] *[\"];

//lexical Str = [a-zA-Z][a-zA-Z0-9]*;

//lexical Int = [0-9]+;

// lexical Bool = "true" | "false";
