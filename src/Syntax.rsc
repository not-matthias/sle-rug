module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

keyword ControlKeywords = "if" | "else" | "form";

start syntax Form = "form" Id "{" Question* "}"; 

syntax SimpleQuestion = Str Id ":" Type;
syntax CalculatedQuestion = SimpleQuestion "=" Expr;
syntax ConditionalQuestion 
  = "if" "(" Expr e ")" "{" Question* ifQuestions "}" "else" "{" Question* elseQuestions "}"
  | "if" "(" Expr e ")" "{" Question* ifQuestions "}";

// indirection tradeoff?
syntax Question = SimpleQuestion | CalculatedQuestion | ConditionalQuestion;

// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
// Associativity reference: https://www.rascal-mpl.org/docs/Rascal/Declarations/SyntaxDefinition/Disambiguation/Associativity/
// Priority reference: https://www.rascal-mpl.org/docs/Rascal/Declarations/SyntaxDefinition/Disambiguation/Priority/
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Int
  | Str
  | Bool
  | "(" Expr ")"

  // Unary operators
  > right "!" Expr

  // Arithmetic operators
  > left (
    Expr a "*" Expr b
  | Expr a "/" Expr b
  )
  > left (
    Expr a "+" Expr b
  | Expr a "-" Expr b
  )

  // Boolean operators
  // no-assoc -> types change
  > left (
    Expr a "\<" Expr b
  | Expr a "\<=" Expr b
  | Expr a "\>" Expr b
  | Expr a "\>=" Expr b
  )
  > left (
    Expr a "==" Expr b
  | Expr a "!=" Expr b
  )
  > left (
    Expr a "&&" Expr b
  | Expr a "||" Expr b
  )
  ; 
  
lexical Type = "boolean" | "integer" | "string";

//regex: https://www.rascal-mpl.org/docs/Rascal/Patterns/Regular/
// lexical Str = [\"][\w\d\s\p]*[\"]; // TODO: Why does this not work? Would be much cleaner.
lexical Str = [\"] ![\"]* [\"];
lexical Int = [0-9]+;
lexical Bool = "true" | "false";
