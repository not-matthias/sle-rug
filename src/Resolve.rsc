module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  // find all uses of names. 
  // In QL this is only in expressions (AExpr)
  // and uses are AId nodes
  
  Use uses = {};

  // Deep match / https://www.rascal-mpl.org/docs/Rascal/Patterns/Descendant/
  // Boolean match := https://www.rascal-mpl.org/docs/Rascal/Expressions/Values/Boolean/Match/
  for (/AExpr expr <- f) {
    uses += {<id.src, id.name> | /AId id := expr};
  }

  return uses;
}

Def defs(AForm f) {
  // find all definitions of names. 
  // In QL this is only questions (AQuestion) using AId nodes
  Def defs = {};

  for (/AQuestion q <- f) {
    defs += {<id.name, id.src> | /AId id := q};
  }

  return defs;
}